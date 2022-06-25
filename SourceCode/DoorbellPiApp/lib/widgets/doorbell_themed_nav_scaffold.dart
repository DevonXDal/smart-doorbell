import 'package:flutter/material.dart';

import '../data/app_colors.dart';

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
        title: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textForegroundOrange,)
        ),
        iconTheme: IconThemeData(color: AppColors.textForegroundOrange, size: 30),
        actions: [
          Icon(Icons.wifi, color: Colors.grey, size: 30),
          SizedBox(width: 20,),
          Icon(Icons.info_outline_rounded, color: Colors.grey, size: 30,),
          SizedBox(width: 20,),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Center(
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
      drawer: Container(
        width: 250,
        child: Drawer(
          backgroundColor: AppColors.navigationBackgroundPink,

          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 40)),
              const Text(
                  'Available Doorbells',
                  style: const TextStyle(fontSize: 18, color: AppColors.textForegroundOrange,)),
              Divider(color: Colors.yellow,),
              ListTile(
                title: const Text(
                    'Front Door',
                    style: const TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,)),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text(
                    'Back Door',
                    style: const TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,)),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              // https://stackoverflow.com/questions/68707021/align-drawer-list-tile-at-the-bottom-of-the-drawer - Ravindra S. Patil
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                             Icon(Icons.logout, color: AppColors.textForegroundOrange, size: 40,),
                             Text(
                                "Logout of Server",
                                style: TextStyle(fontSize: 14, color: AppColors.textForegroundOrange,)
                            )
                          ],
                        )
                    ),
                  )
              )
            ],
          ),
        ),
      ),
      backgroundColor: AppColors.pageBackgroundPurple,
    );
  }


}