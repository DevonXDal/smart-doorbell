import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/doorbell_video_chat_controller.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/enumerations/loading_state.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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
        if (!controller.shouldShowWidget.value) {
          _dontDisplay(context);
        }

        if (controller.currentLoadingState.value != LoadingState.Loading) {
          _displayUnconnected(context, controller);
        }

        if (controller.currentLoadingState.value == LoadingState.Loading) {
          _displayLoadingConnection(context, controller);
        }

        if (controller.isInCall.value) {
          _displayLoadedConnection(context, controller);
        }

        Get.snackbar('Incorrect Video Chat Data State', 'The data for whether or not to be in a video call does not make any sense.');
        return _dontDisplay(context);
    });
  }

  Widget _dontDisplay(BuildContext context) {
    return const SizedBox(width: 0, height: 0);
  }

  Widget _displayUnconnected(BuildContext context, DoorbellVideoChatController controller) {
    throw UnimplementedError();
  }

  Widget _displayLoadingConnection(BuildContext context, DoorbellVideoChatController controller) {
    throw UnimplementedError();
  }

  Widget _displayLoadedConnection(BuildContext context, DoorbellVideoChatController controller) {
    throw UnimplementedError();
  }
}