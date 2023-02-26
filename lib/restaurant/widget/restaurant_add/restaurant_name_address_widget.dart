import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/const/color.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../provider/restaurant_add_provider.dart';
import 'modal_bottom_sheet/search_modal/restaurant_search_modal_bottom_sheet.dart';

class RestaurantNameAddressWidget extends StatefulWidget {
  final String? name;
  final String? address;

  const RestaurantNameAddressWidget({
    Key? key,
    this.name,
    this.address,
  }) : super(key: key);

  @override
  State<RestaurantNameAddressWidget> createState() =>
      _RestaurantNameAddressWidgetState();
}

class _RestaurantNameAddressWidgetState
    extends State<RestaurantNameAddressWidget> {
  bool isInput = false;
  final focusNode = FocusNode();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  late StreamSubscription subscription;

  @override
  void initState() {
    subscription =
        context.read<RestaurantAddProvider>().addressModelStream.listen(
      (value) {
        nameController.text = value.place ?? '';
        addressController.text =
            "${value.roadAddressName}\n(지번)${value.address}";
      },
    );

    nameController.text = widget.name ?? '';
    addressController.text = widget.address ?? '';

    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    focusNode.dispose();
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 3,
                child: _RestaurantSearchBtn(
                  isInput: isInput,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                '직접입력',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 13),
              ),
              Checkbox(
                value: isInput,
                activeColor: PRIMARY_COLOR,
                onChanged: (value) {
                  setState(() {
                    isInput = value!;
                    if (isInput) {
                      focusNode.requestFocus();
                    } else {
                      focusNode.unfocus();
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextFormField(
            hintText: '식당 이름',
            maxLength: 30,
            counterText: '',
            focusNode: focusNode,
            readOnly: !isInput,
            controller: nameController,
            onChanged: (value) {
              context.read<RestaurantAddProvider>().name = value;
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '식당 이름을 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextFormField(
            hintText: '주소',
            maxLine: 2,
            maxLength: 50,
            counterText: '',
            readOnly: !isInput,
            controller: addressController,
            verticalPadding: 16,
            onChanged: (value) {
              context.read<RestaurantAddProvider>().address = value;
            },
          ),
        ],
      ),
    );
  }
}

class _RestaurantSearchBtn extends StatelessWidget {
  const _RestaurantSearchBtn({
    required this.isInput,
  });

  final bool isInput;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isInput == true
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                builder: (context) {
                  return GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: RestaurantSearchModalBottomSheet(),
                    ),
                  );
                },
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: PRIMARY_COLOR,
      ),
      child: const Text('식당 검색'),
    );
  }
}
