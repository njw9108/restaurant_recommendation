import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/home_provider.dart';

class ExpandableTagList extends StatelessWidget {
  final ScrollController tagController;
  final List<String> tagList;
  final String title;

  const ExpandableTagList({
    super.key,
    required this.tagController,
    required this.tagList,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.tag),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textColor: Colors.black,
      iconColor: Colors.black,
      children: [
        SizedBox(
          height: 200,
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
                bool isChecked = context
                    .watch<HomeProvider>()
                    .selectedTagList
                    .contains(tagList[index]);
                return CheckboxListTile(
                  title: Text(tagList[index]),
                  value: isChecked,
                  onChanged: (bool? value) {
                    final temp = context.read<HomeProvider>().selectedTagList;

                    if (!value!) {
                      temp.remove(tagList[index]);
                    } else {
                      if (temp.length < 10) {
                        temp.add(tagList[index]);
                      }
                    }
                    context.read<HomeProvider>().selectedTagList =
                        List.from(temp.toSet());
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
