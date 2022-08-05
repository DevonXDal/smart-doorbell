import 'package:doorbell_pi_app/controllers/doorbell_list_drawer_controller.dart';
import 'package:doorbell_pi_app/widgets/pages/doorbell_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/app_colors.dart';

class DoorbellListDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DoorbellListDrawerController controller = Get.put(DoorbellListDrawerController());

    return Container(
      width: 250,
      child: Drawer(
        backgroundColor: AppColors.navigationBackgroundPink,

        child: Obx(() => Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 40)),
              const Text(
                  'Available Doorbells',
                  style: TextStyle(fontSize: 20, color: AppColors.textForegroundOrange,)),
              const Divider(color: Colors.yellow,),
              for (int i = 0; i < controller.sortedConnectedDoorbells.value.length; i++)
                  ListTile( // NOTE: This list tile is created from the for loop above; Flutter is finicky about curly braces during composition of widgets.
                    title: Text(
                      controller.sortedConnectedDoorbells.value[i].name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onTap: () {
                      Get.offAll(() => DoorbellPage(controller.sortedConnectedDoorbells.value[i].name));
                    },
                  ),
              // https://stackoverflow.com/questions/68707021/align-drawer-list-tile-at-the-bottom-of-the-drawer - Ravindra S. Patil
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: (controller.isConnectedToWebServer.value) ? // Then
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               GestureDetector(
                                 onTap: () => controller.performDoorbellListRefresh(),
                                 child: Row(
                                   children: [
                                     const Icon(Icons.refresh, color: AppColors.textForegroundOrange, size: 40),
                                     Text(
                                         "Refresh",
                                         style: TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,)
                                     )
                                   ],
                                 ),
                               ),
                               GestureDetector(
                                 onTap: () => _showConfirmDisconnectDialog(context, controller),
                                 child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Icon(Icons.logout, color: AppColors.textForegroundOrange, size: 40,),
                                    Text(
                                        "Disconnect",
                                        style: TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,)
                                    )
                                  ],
                                ),
                               ),
                             ],
                           ) : // Else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Icon(Icons.refresh, color: Colors.grey, size: 40),
                              Icon(Icons.logout, color: Colors.grey, size: 40,),

                            ],
                          )
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDisconnectDialog(BuildContext context, DoorbellListDrawerController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.navigationBackgroundPink,
        title: Text('Are you Sure?', style: Theme.of(context).textTheme.labelMedium),
        content: Text('Are you sure you want to disconnect from the Web server? You will have to refill the information to get back in later.', style: Theme.of(context).textTheme.labelSmall),
        actions: [
          TextButton(
            child: const Text("Yes"),
            onPressed: () => controller.disconnectFromWebServer(),
          ),
          TextButton(
            child: const Text("No"),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

}