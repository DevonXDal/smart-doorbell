import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/doorbell_activity_controller.dart';
import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/doorbell_status_controller.dart';
import 'package:doorbell_pi_app/data/app_colors.dart';
import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:doorbell_pi_app/widgets/apply_view_component_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// This DoorbellStatusView widget is responsible for various status information about the doorbell.
/// This includes its state, turn on time, and estimated remaining battery life.
class DoorbellActivityView extends StatelessWidget {
  late final String _doorbellDisplayName;
  late final Observer _observerForController;

  DoorbellActivityView(this._doorbellDisplayName, Observer doorbellObserver, {Key? key}) : super(key: key) {
    _observerForController = doorbellObserver;
  }

  @override
  Widget build(BuildContext context) {
    DoorbellActivityController controller = Get.put(DoorbellActivityController(_doorbellDisplayName, _observerForController));

    return ApplyViewComponentTheme(
        Column(
          children: [
            Obx( () =>
              (controller.imageContent.value == null) ?
                const SizedBox(width: 0, height: 0) :
                Image.memory(
                  controller.imageContent.value!,
                  width: 300,
                  height: 300,
                ),
            ),
            Obx( () =>
              Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  controller.viewMessage.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          ],
        )
    );
  }

}