import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_add_provider.dart';

class RestaurantAddScreen extends StatelessWidget {
  static String get routeName => 'restaurantAdd';

  const RestaurantAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<RestaurantAddProvider>(
              create: (_) => RestaurantAddProvider(),
            ),
          ],
          child: const RestaurantAddScreenBuilder(),
        );
      },
    );
  }
}

class RestaurantAddScreenBuilder extends StatelessWidget {
  const RestaurantAddScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final restaurantAddProvider = context.watch<RestaurantAddProvider>();

    return DefaultLayout(
      title: '식당 추가',
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: restaurantAddProvider.thumbNail != null
                  ? () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (_) {
                          return AlertDialog(
                            content: const Text('이미지를 삭제할까요?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  restaurantAddProvider.clearImage();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('예'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('아니오'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  : () async {
                      await restaurantAddProvider.pickImage(
                          source: ImageSource.gallery);
                      // try {
                      //   // 1. Get image from picker
                      //   final imagePicker =
                      //   Provider.of<ImagePickerService>(context, listen: false);
                      //   final file = await imagePicker.pickImage(source: ImageSource.gallery);
                      //   if (file != null) {
                      //     // 2. Upload to storage
                      //     final storage =
                      //     Provider.of<FirebaseStorageService>(context, listen: false);
                      //     final downloadUrl = await storage.uploadAvatar(file: file);
                      //     // 3. Save url to Firestore
                      //     final database = Provider.of<FirestoreService>(context, listen: false);
                      //     await database.setAvatarReference(AvatarReference(downloadUrl));
                      //     // 4. (optional) delete local file as no longer needed
                      //     await file.delete();
                      //   }
                      // } catch (e) {
                      //   print(e);
                      // }
                    },
              child: Container(
                height: 250,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5)),
                alignment: Alignment.center,
                child: restaurantAddProvider.thumbNail != null
                    ? Image.file(
                        restaurantAddProvider.thumbNail!,
                        fit: BoxFit.cover,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add),
                          Text('대표 이미지를 추가해주세요'),
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
