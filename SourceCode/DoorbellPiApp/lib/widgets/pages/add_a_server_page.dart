import 'dart:ui';

import 'package:doorbell_pi_app/controllers/add_a_server_form_controller.dart';
import 'package:doorbell_pi_app/widgets/doorbell_themed_nav_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../data/app_colors.dart';

class AddAServerPage extends StatelessWidget {
  const AddAServerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddAServerFormController controller = Get.put(AddAServerFormController()); // controller

    return DoorbellThemedNavScaffold(
      title: 'Add a Server',
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Server IP Address',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textForegroundAlternateOrange,)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                      onChanged: controller.ipAddress, // controller func
                      decoration: InputDecoration(
                        labelText: '?.?.?.?',
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Server Port',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textForegroundAlternateOrange,)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                      onChanged: controller.port, // controller func
                      decoration: InputDecoration(
                        labelText: '10-65,535',
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Server Password',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textForegroundAlternateOrange,)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                      onChanged: controller.password, // controller func
                      decoration: InputDecoration(
                        labelText: '6+ Characters',
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    'Display Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textForegroundAlternateOrange,)
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextFormField(
                        onChanged: controller.displayName, // controller func
                        decoration: InputDecoration(
                          labelText: '3+ Characters',
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Obx(() {
                  return Stack(
                    children: <Widget>[
                      // Stroked text as border.
                      Text(
                        controller.errorText.string,
                        style: TextStyle(
                          fontSize: 20,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black,
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        controller.errorText.string,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 75, 110),
                        ),
                      ),
                    ],
                  );
              }),
            ),
            Obx(() => InkWell(
              child: ElevatedButton(
                onPressed: controller.submitFunc.value,
                style: ButtonStyle(
                    // https://stackoverflow.com/questions/67813752/the-argument-type-materialcolor-cant-be-assigned-to-the-parameter-type-mater - Rashid Wassan
                    backgroundColor: MaterialStateProperty.all(AppColors.pageComponentBackgroundDeepDarkBlue),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                ),
                child: const Text('Submit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textForegroundOrange,)), // obs
              ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}