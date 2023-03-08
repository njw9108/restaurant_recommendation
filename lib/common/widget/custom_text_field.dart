import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:recommend_restaurant/common/const/color.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLine;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final double verticalPadding;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final String? counterText;

  const CustomTextFormField({
    Key? key,
    required this.onChanged,
    this.autofocus = false,
    this.obscureText = false,
    this.hintText,
    this.errorText,
    this.keyboardType,
    this.readOnly = false,
    this.maxLine = 1,
    this.focusNode,
    this.controller,
    this.verticalPadding = 8,
    this.validator,
    this.maxLength,
    this.counterText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const baseBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: INPUT_BORDER_COLOR,
        width: 1,
      ),
    );

    return TextFormField(
      controller: controller,
      cursorColor: PRIMARY_COLOR,
      autofocus: autofocus,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLine,
      focusNode: focusNode,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 5.w),
        alignLabelWithHint: true,
        counterText: counterText,
        hintText: hintText,
        errorText: errorText,
        hintStyle: TextStyle(
          color: GRAY_COLOR,
          fontSize: 14.sp,
          height: 2,
        ),
        fillColor: INPUT_BG_COLOR,
        filled: false,
        label: hintText != null ? Text(hintText!) : null,
        labelStyle: const TextStyle(color: GRAY_COLOR),
        focusedBorder: baseBorder.copyWith(
          borderSide: baseBorder.borderSide.copyWith(
            color: PRIMARY_COLOR,
          ),
        ),
      ),
    );
  }
}
