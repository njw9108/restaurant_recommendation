import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';

import '../../common/const/color.dart';
import '../../common/widget/custom_text_field.dart';

const double imageSize = 200;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    final user = context.read<AuthProvider>().userModel;
    nameController.text = user?.nickname ?? '';

    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(imageSize / 2),
                  child: user.photoUrl.isEmpty
                      ? const EmptyImage()
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: imageSize,
                          height: imageSize,
                          imageUrl: user.photoUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator.adaptive(),
                          errorWidget: (context, url, error) =>
                              const EmptyImage(),
                        ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            CustomTextFormField(
              onChanged: (String value) {},
              readOnly: true,
              hintText: '이름',
              controller: nameController,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomTextFormField(
              onChanged: (String value) {},
              readOnly: true,
              hintText: '버전',
              controller: nameController,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: GRAY_COLOR),
                ),
              ),
              child: ListTile(
                title: const Text('로그아웃'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                },
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
                title: const Text('회원탈퇴'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                '정말 탈퇴하시겠습니까?',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                '계정삭제시 모든 정보가 삭제됩니다.',
                                style: TextStyle(),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PRIMARY_COLOR,
                                ),
                                child: const Text(
                                  '다시 생각해볼게요',
                                  style: TextStyle(fontSize: 16),
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
            const SizedBox(
              height: 20,
            ),
          ],
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
    return const SizedBox(
      width: imageSize,
      height: imageSize,
      child: Icon(
        Icons.account_circle,
        color: SECONDARY_COLOR,
        size: imageSize,
      ),
    );
  }
}
