import 'package:flutter/material.dart';

import '../doorbell_themed_nav_scaffold.dart';

class NoDoorbellsRegisteredPage extends StatelessWidget {
  const NoDoorbellsRegisteredPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DoorbellThemedNavScaffold (
      title: "No Doorbells Registered",
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Text(
          "No doorbells are connected to this server..."
        ),
      ),
    );
  }
}