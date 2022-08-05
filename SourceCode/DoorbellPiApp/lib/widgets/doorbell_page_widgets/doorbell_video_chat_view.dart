import 'package:doorbell_pi_app/controllers/doorbell_page_controllers/doorbell_video_chat_controller.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
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