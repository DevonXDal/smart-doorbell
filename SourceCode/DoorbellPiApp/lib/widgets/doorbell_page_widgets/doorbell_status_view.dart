import 'package:doorbell_pi_app/controllers/doorbell_status_controller.dart';
import 'package:doorbell_pi_app/data/app_colors.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:doorbell_pi_app/widgets/apply_view_component_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// This DoorbellStatusView widget is responsible for various status information about the doorbell.
/// This includes its state, turn on time, and estimated remaining battery life.
class DoorbellStatusView extends StatelessWidget {
  late final String _doorbellDisplayName;
  late final Observer _observerForController;

  DoorbellStatusView(this._doorbellDisplayName, Observer doorbellObserver, {Key? key}) : super(key: key) {
    _observerForController = doorbellObserver;
  }

  @override
  Widget build(BuildContext context) {
    DoorbellStatusController controller = Get.put(DoorbellStatusController(_doorbellDisplayName, _observerForController));

    return ApplyViewComponentTheme(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Obx( () =>
                (controller.canShutdownDoorbell.value) ?
                  GestureDetector(
                    onTap: () => {},
                    child: const Icon(
                        Icons.power_settings_new_outlined,
                        color: AppColors.textForegroundOrange,
                        size: 56,
                    ),
                  ) :
                const Icon(
                    Icons.power_settings_new_outlined,
                    color: Colors.grey,
                    size: 56,
                )
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(() =>
                  Text(
                    'State: ${controller.state}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ),
                Obx(() =>
                    Text(
                      'Active Since: ${controller.activeSince}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                ),
                Obx(() =>
                    Text(
                      'Estimated Battery: ${controller.estimatedBatteryLeft}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                ),
              ],
            )
          ],
        )
    );
  }

}