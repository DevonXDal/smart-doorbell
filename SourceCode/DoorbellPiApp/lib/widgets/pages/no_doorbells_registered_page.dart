import 'package:doorbell_pi_app/controllers/no_doorbells_registered_controller.dart';
import 'package:doorbell_pi_app/widgets/apply_view_component_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../doorbell_themed_nav_scaffold.dart';

class NoDoorbellsRegisteredPage extends StatelessWidget {
  const NoDoorbellsRegisteredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    NoDoorbellsRegisteredController controller = Get.put(NoDoorbellsRegisteredController());
    return DoorbellThemedNavScaffold (
      title: "No Doorbells Registered",
      child: ApplyViewComponentTheme (
          Column(
            children: [
              Text(
              "No doorbells are connected to this server...",
              style: Theme.of(context).textTheme.bodyMedium,
        ),
              GestureDetector(
                onTap: () => controller.tryFetchingNewDoorbells(),
                child: Icon(Icons.lock_reset_rounded),
              )
            ],
          ),
      ),
    );
  }
}