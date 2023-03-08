import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';

import '../../common/const/color.dart';
import '../../common/provider/app_version_provider.dart';
import '../../common/widget/custom_text_field.dart';

const double imageSize = 200;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    if (user == null) {
      return DefaultLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('유저 정보가 없습니다.'),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      );
    }

    return DefaultLayout(
      title: '프로필',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  builder: (_) {
                    return const _NameUpdateWidget();
                  },
                );
              },
              child: _LabelTextWidget(
                label: '이름',
                content: user.nickname,
                isUpdatable: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.h,
                bottom: 10.0.h,
              ),
              child: const Divider(
                thickness: 1,
              ),
            ),
            _LabelTextWidget(
              label: '버전',
              content: context.watch<AppVersionProvider>().appVersion,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 5.h,
                bottom: 10.0.h,
              ),
              child: const Divider(
                thickness: 1,
              ),
            ),
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GRAY_COLOR),
                ),
              ),
              child: ListTile(
                title: const Text('로그아웃'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18.sp,
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                },
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GRAY_COLOR),
                ),
              ),
              child: ListTile(
                title: const Text('회원탈퇴'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18.sp,
                ),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Padding(
                          padding: REdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '정말 탈퇴하시겠습니까?',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              const Text(
                                '계정삭제시 모든 정보가 삭제됩니다.',
                                style: TextStyle(),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_COLOR,
                                ),
                                child: Text(
                                  '다시 생각해볼게요',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await context
                                      .read<AuthProvider>()
                                      .withdrawal();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                child: const Text('회원 탈퇴'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelTextWidget extends StatelessWidget {
  final String label;
  final String content;
  final bool isUpdatable;

  const _LabelTextWidget({
    required this.label,
    required this.content,
    this.isUpdatable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(
          height: 5.h,
        ),
        Row(
          children: [
            Text(
              content,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(
              width: 5.w,
            ),
            if (isUpdatable)
              Icon(
                Icons.edit,
                color: GRAY_COLOR,
                size: 15.sp,
              ),
          ],
        ),
      ],
    );
  }
}

class _NameUpdateWidget extends StatefulWidget {
  const _NameUpdateWidget({
    super.key,
  });

  @override
  State<_NameUpdateWidget> createState() => _NameUpdateWidgetState();
}

class _NameUpdateWidgetState extends State<_NameUpdateWidget> {
  String editValue = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20.h,
              ),
              const Text('이름'),
              SizedBox(
                height: 10.h,
              ),
              CustomTextFormField(
                onChanged: (String value) {
                  setState(() {
                    editValue = value;
                  });
                },
                maxLength: 10,
              ),
              SizedBox(
                height: 20.h,
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().updateUserName(editValue);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                child: const Text('수정'),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyImage extends StatelessWidget {
  const EmptyImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: imageSize,
      height: imageSize,
      child: Icon(
        Icons.account_circle,
        color: SECONDARY_COLOR,
        size: imageSize.sp,
      ),
    );
  }
}
