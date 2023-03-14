import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetListItem extends StatelessWidget {
  final String title;
  final Function(String) onTap;
  final Widget? selectedWidget;

  const BottomSheetListItem({
    super.key,
    required this.title,
    required this.onTap,
    this.selectedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            onTap(title);
          },
          title: selectedWidget ??
              Text(
                title,
              ),
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: 0,
          trailing: const Icon(Icons.drag_indicator),
        ),
        Divider(
          height: 1.h,
        ),
      ],
    );
  }
}
