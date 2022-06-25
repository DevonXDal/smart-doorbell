import 'package:doorbell_pi_app/data/app_colors.dart';
import 'package:doorbell_pi_app/widgets/doorbell_themed_nav_scaffold.dart';
import 'package:flutter/material.dart';

class ServerNotConfiguredPage extends StatelessWidget {
  const ServerNotConfiguredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DoorbellThemedNavScaffold (
      title: "Server Not Configured",
      child: TextButton (
        onPressed: () => throw UnimplementedError(),
        style: ButtonStyle(
          // https://stackoverflow.com/questions/67813752/the-argument-type-materialcolor-cant-be-assigned-to-the-parameter-type-mater - Rashid Wassan
          backgroundColor: MaterialStateProperty.all(AppColors.pageComponentBackgroundDeepDarkBlue),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          padding: MaterialStateProperty.all(const EdgeInsets.only(top: 20, bottom: 20)),
        ),
        child: const Text(
            "Add a Server",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textForegroundOrange,)
        ),
      ),
    );
  }

}