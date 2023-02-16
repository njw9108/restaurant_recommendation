import 'package:flutter/material.dart';

class OverlayLoader {
  static final OverlayEntry _overlay =
      OverlayEntry(builder: (_) => const LoadingOverlayWidget());

  static showLoading(BuildContext context) async {
    Navigator.of(context).overlay!.insert(_overlay);
  }

  static removeLoading() async {
    _overlay.remove();
  }
}

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.7),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
