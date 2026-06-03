import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';
import '../../../core/utils/url_container.dart';
import '../../../data/controller/blogs/blogs_controller.dart';
import '../../../data/model/blogs/blogs_model.dart';

class BlogCardWidget extends StatelessWidget {
  final BlogData item;
  final BlogsController controller;
  const BlogCardWidget({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10, top: Dimensions.space10),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteHelper.blogDetailScreenScreen, arguments: [item, "${UrlContainer.domainUrl}/${controller.imagePath}/${item.dataValues?.image ?? ''}"]);
        },
        child: Column(
          children: [
            Hero(
              tag: "${item.id.hashCode}",
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2.2,
                child: MyNetworkImageWidget(
                  boxFit: BoxFit.cover,
                  imageUrl: "${UrlContainer.domainUrl}/${controller.imagePath}/${item.dataValues?.image ?? ''}",
                  borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(Dimensions.cardRadius2), topEnd: Radius.circular(Dimensions.cardRadius2)),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              dense: true,
              leading: CircleAvatar(
                backgroundColor: MyColor.getPrimaryColor().withOpacity(0.3),
                child: Icon(
                  Icons.newspaper_rounded,
                  color: MyColor.getPrimaryColor(),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "${item.dataValues?.title}",
                  style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
