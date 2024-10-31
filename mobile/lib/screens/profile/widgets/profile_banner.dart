import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trgtz/core/widgets/index.dart';
import 'package:trgtz/models/index.dart';
import 'package:trgtz/screens/profile/services/index.dart';
import 'package:trgtz/store/index.dart';

class ProfileBanner extends StatelessWidget {
  final GlobalKey _contextMenuKey = GlobalKey();

  final User user;
  final int friendsCount;
  final int goalsCount;
  final bool itsMe;
  final bool areFriends;
  final EdgeInsetsGeometry padding;
  final Function()? onReport;

  final ImagePicker _picker = ImagePicker();

  ProfileBanner({
    super.key,
    required this.user,
    required this.friendsCount,
    required this.goalsCount,
    this.itsMe = false,
    this.areFriends = false,
    this.padding = EdgeInsets.zero,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: constraints.maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxHeight,
                      child: ProfileImage(
                        user: user,
                      ),
                    ),
                    if (user.id ==
                        StoreProvider.of<ApplicationState>(context)
                            .state
                            .user
                            ?.id)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2.0),
                                )
                              ]),
                          child: IconButton(
                            onPressed: _openImagePicker,
                            icon: const Icon(
                              Icons.edit,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.firstName,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    user.email,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Container(
                              key: _contextMenuKey,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              height: 40.0,
                              width: 40.0,
                              clipBehavior: Clip.hardEdge,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showContextMenu(context),
                                  child: const Icon(
                                    Icons.more_vert,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Expanded(child: SizedBox.shrink()),
                        Row(
                          children: [
                            _buildInfoStat(
                              title: 'Friends',
                              value: friendsCount.toString(),
                              onTap: () {
                                if (!itsMe && areFriends) {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                  Navigator.of(context).pushNamed('/friends',
                                      arguments: user.id);
                                }
                              },
                            ),
                            const SizedBox(width: 8.0),
                            _buildInfoStat(
                              title: 'Goals',
                              value: goalsCount.toString(),
                              onTap: () {
                                // TODO: Show goals statistics
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildInfoStat({
    required String title,
    required String value,
    required Function() onTap,
  }) =>
      Expanded(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _openImagePicker() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? file = File(pickedFile.path);
      if (await file.exists()) {
        await ModuleService.setProfileImage(file);
      }
    }
  }

  static Widget placeholder({
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
  }) =>
      Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: constraints.maxHeight,
                  width: constraints.maxHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16.0,
                        width: 80.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16.0,
                        width: 180.0,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    Row(
                      children: [
                        Expanded(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                color: Colors.white,
                              ),
                              height: constraints.maxHeight - 50.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                color: Colors.white,
                              ),
                              height: constraints.maxHeight - 50.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  void _showContextMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button =
        _contextMenuKey.currentContext?.findRenderObject() as RenderBox;

    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition,
        buttonPosition.translate(buttonSize.width, buttonSize.height),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(
          value: 'report',
          child: Text('Report'),
        ),
      ],
    ).then((value) {
      switch (value) {
        case 'report':
          if (onReport != null) {
            onReport!();
          }
          break;
      }
    });
  }
}
