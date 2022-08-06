import 'package:doorbell_pi_app/widgets/server_icons_view.dart';
import 'package:flutter/material.dart';

import '../data/app_colors.dart';
import 'doorbell_list_drawer.dart';

/// Prepares the common drawer, app bar, and similar navigation components for each page.
/// This is done in order to avoid large amounts of code duplications and make page code concise.
///
/// Author: Devon X. Dalrymple
/// Version 2022-06-24
class DoorbellThemedNavScaffold extends StatelessWidget {
  const DoorbellThemedNavScaffold({super.key, required this.child, required this.title});

  final Widget child;
  final String title;

  /// Note that this will provide the scaffold.
  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navigationBackgroundPink,
        title: Tooltip( // Helps when the page name is cutoff on smaller devices
          message: title,
          waitDuration: const Duration(milliseconds: 200),
          child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textForegroundOrange,)
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textForegroundOrange, size: 30),
        actions: const [
          ServerIconsView()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: child
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: DoorbellListDrawer(),
      backgroundColor: AppColors.pageBackgroundPurple,
      resizeToAvoidBottomInset: false,
    );
  }


}