import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/app-bar/app_main_appbar.dart';

// ignore: must_be_immutable
class PreviewImage extends StatefulWidget {
  String url;
  PreviewImage({super.key, required this.url});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  void initState() {
    widget.url = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppMainAppBar(
        title: "",
        isTitleCenter: true,
        isProfileCompleted: true,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
      ),
      backgroundColor: MyColor.getScreenBgColor(),
      body: InteractiveViewer(
              child: CachedNetworkImage(
      imageUrl: widget.url.toString(),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          boxShadow: const [],
          // borderRadius:  BorderRadius.circular(radius),
          image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
          child: Center(
            child: SpinKitFadingCube(
              color: MyColor.primaryColor.withOpacity(0.3),
              size: Dimensions.space20,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
          child: Center(
            child: Icon(
              Icons.image,
              color: MyColor.colorGrey.withOpacity(0.5),
            ),
          ),
        ),
      ),
              ),
            ),
    );
  }
}
