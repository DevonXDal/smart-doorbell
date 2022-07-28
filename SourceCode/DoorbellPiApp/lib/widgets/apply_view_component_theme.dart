import 'package:flutter/widgets.dart';

import '../data/app_colors.dart';

/// This ApplyViewComponentTheme widget is used as the general formatter for the
/// view component elements that show across various pages with a deep dark blue background
/// and a fit to most of the page width.
///
/// This exists to reduce the duplication from each view component having to add in its background.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-07-15
class ApplyViewComponentTheme extends StatelessWidget {
  final Widget child;

  const ApplyViewComponentTheme(this.child, {Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: AppColors.pageComponentBackgroundDeepDarkBlue
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
      child: child
    );
  }

}