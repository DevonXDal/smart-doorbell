import 'package:doorbell_pi_app/controllers/server_not_configured_controller.dart';
import 'package:doorbell_pi_app/data/app_colors.dart';
import 'package:doorbell_pi_app/data/database/app_persistence_db.dart';
import 'package:doorbell_pi_app/widgets/doorbell_themed_nav_scaffold.dart';
import 'package:doorbell_pi_app/widgets/pages/add_a_server_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServerNotConfiguredPage extends StatelessWidget {
  const ServerNotConfiguredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ServerNotConfiguredController controller = Get.put(ServerNotConfiguredController());

    return DoorbellThemedNavScaffold (
      title: "Server Not Configured",
      child: InkWell(
        child: TextButton (
          onPressed: () async
          {
            if (kDebugMode) {
              AppPersistenceDb db = Get.find();
              await (db.delete(db.doorbells)).go();
              await (db.delete(db.webServers)).go();
            }
            Get.to(() => const AddAServerPage());
          },
          style: ButtonStyle(
            // https://stackoverflow.com/questions/67813752/the-argument-type-materialcolor-cant-be-assigned-to-the-parameter-type-mater - Rashid Wassan
            backgroundColor: MaterialStateProperty.all(AppColors.pageComponentBackgroundDeepDarkBlue),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            padding: MaterialStateProperty.all(const EdgeInsets.only(top: 20, bottom: 20)),
          ),
          child: Text(
              "Add a Server",
              style: Theme.of(context).textTheme.bodyLarge
          ),
        ),
      ),
    );
  }

}