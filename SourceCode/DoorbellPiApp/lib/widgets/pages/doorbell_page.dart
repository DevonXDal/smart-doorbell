import 'package:doorbell_pi_app/helpers/doorbell_timed_observer.dart';
import 'package:doorbell_pi_app/widgets/doorbell_page_widgets/doorbell_status_view.dart';
import 'package:doorbell_pi_app/widgets/doorbell_themed_nav_scaffold.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controllers/doorbell_page_controllers/doorbell_page_controller.dart';

/// This DoorbellPage class is the most important page of the app.
/// It displays information about the selected doorbell and provides options for the user to control that doorbell.
/// This page also supports video calls with the doorbell and a preview image of the person at the door.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-17
class DoorbellPage extends StatelessWidget {
  late String doorbellDisplayName;
  late DoorbellTimedObserver _observerForDoorbell;
  late DoorbellPageController _controller; // This keeps the controller properly loaded until the page is no longer loaded.

  DoorbellPage(String displayNameOfDoorbell, {Key? key}) : super(key: key) {
    doorbellDisplayName = displayNameOfDoorbell;
    _observerForDoorbell = DoorbellTimedObserver(doorbellDisplayName);
  }

  @override
  Widget build(BuildContext context) {
    _controller = Get.put(DoorbellPageController(_observerForDoorbell));

    return DoorbellThemedNavScaffold(
      title: doorbellDisplayName,
      child: DoorbellStatusView(doorbellDisplayName, _observerForDoorbell),
    );
  }


}