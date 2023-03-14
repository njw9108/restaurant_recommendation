import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableTagList extends StatelessWidget {
  final ScrollController tagController;
  final List<String> tagList;
  final String title;
  final List<String> selectedList;
  final Function(bool, int) onChanged;

  const ExpandableTagList({
    super.key,
    required this.tagController,
    required this.tagList,
    required this.title,
    required this.selectedList,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      textColor: Colors.black,
      iconColor: Colors.black,
      children: [
        SizedBox(
          height: 200.h,
          child: Scrollbar(
            thumbVisibility: true,
            controller: tagController,
            child: GridView.builder(
              controller: tagController,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
              ),
              itemCount: tagList.length,
              itemBuilder: (_, index) {
                bool isChecked = selectedList.contains(tagList[index]);
                return CheckboxListTile(
                    title: Text(tagList[index]),
                    value: isChecked,
                    onChanged: (value) {
                      onChanged(value!, index);
                    });
              },
            ),
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }
}
