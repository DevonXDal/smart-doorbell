import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/doorbell_video_chat_controller.dart';
import 'package:doorbell_pi_app/data/app_colors.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/enumerations/loading_state.dart';
import 'package:doorbell_pi_app/widgets/apply_view_component_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controllers/doorbell_page_controllers/participant_widget.dart';
import '../../helpers/observer.dart';

class DoorbellVideoChatView extends StatelessWidget {
  final String doorbellDisplayName;
  final Observer doorbellObserver;

  const DoorbellVideoChatView(this.doorbellDisplayName, this.doorbellObserver, {super.key});

  @override
  Widget build(BuildContext context) {
    DoorbellVideoChatController controller = Get.put(DoorbellVideoChatController(doorbellDisplayName, doorbellObserver));

    return Obx( ()
    {
      if (controller.currentLoadingState.value == LoadingState.Loading) {
        return _displayLoadingConnection(context, controller);
      }

      if (controller.isInCall.value) {
        return _displayLoadedConnection(context, controller);
      }

      if (!controller.shouldShowWidget.value) {
        return _dontDisplay(context);
      }

      if (controller.currentLoadingState.value != LoadingState.Loading) {
        return _displayUnconnected(context, controller);
      }



      Get.snackbar('Incorrect Video Chat Data State', 'The data for whether or not to be in a video call does not make any sense.');
      return _dontDisplay(context);
    });
  }

  Widget _dontDisplay(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }

  Widget _displayUnconnected(BuildContext context, DoorbellVideoChatController controller) {
    return ApplyViewComponentTheme(
        Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              color: AppColors.pageComponentBackgroundDeepDarkBlue,
              child: Center(
                child: Obx( () =>
                  Text(controller.peopleInCall.value)
                ),
              ),
            ),
            Container(
              width: 300,
              height: 50,
              alignment: Alignment.bottomCenter,
              color: const Color.fromARGB(128, 0, 51, 56),
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.joinVideoChat(),
                  child: const Icon(
                    Icons.phone,
                    color: AppColors.textForegroundOrange,
                    size: 42,
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  Widget _displayLoadingConnection(BuildContext context, DoorbellVideoChatController controller) {
    return ApplyViewComponentTheme(
        Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              color: AppColors.pageComponentBackgroundDeepDarkBlue,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.textForegroundOrange,
                )
              ),
            ),
            Container(
              width: 300,
              height: 50,
              alignment: Alignment.bottomCenter,
              color: const Color.fromARGB(128, 0, 51, 56),
              child: Center(
                child: const Icon(
                  Icons.call_end,
                  color: Colors.grey,
                  size: 42,
                ),
              ),
            )
          ],
        )
    );
  }

  Widget _displayLoadedConnection(BuildContext context, DoorbellVideoChatController controller) {
    return ApplyViewComponentTheme(
        Stack(
          children: [
            Container(
              width: 300,
              height: 300,
              color: AppColors.pageComponentBackgroundDeepDarkBlue,
              child: Obx( () {
                return Stack(
                  children: [
                    for(ParticipantWidget participant in controller.participants.value) Card(child: participant,),
                  ]
                );
              }),
            ),
            Container(
              width: 300,
              height: 50,
              alignment: Alignment.bottomCenter,
              color: const Color.fromARGB(128, 0, 51, 56),
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.disconnectFromVideoCall(),
                  child: const Icon(
                    Icons.call_end,
                    color: AppColors.textForegroundOrange,
                    size: 42,
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}