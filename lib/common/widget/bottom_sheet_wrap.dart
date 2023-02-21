import 'package:flutter/material.dart';

class BottomSheetWrap extends StatelessWidget {
  final String title;
  final Widget child;

  const BottomSheetWrap({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSheetItemWidget extends StatelessWidget {
  final String title;
  final Function(String) onTap;
  final Widget? selectedWidget;

  const BottomSheetItemWidget({
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
        ),
        const Divider(
          height: 1,
        ),
      ],
    );
  }
}
