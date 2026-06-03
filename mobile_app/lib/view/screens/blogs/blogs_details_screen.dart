import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vinance/data/model/blogs/blogs_model.dart';
import 'package:vinance/view/components/divider/custom_divider.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_network_image_widget.dart';

class BlogsDetailsScreen extends StatefulWidget {
  final BlogData? blogData;
  final String? imagePath;
  const BlogsDetailsScreen({super.key, required this.blogData, required this.imagePath});

  @override
  State<BlogsDetailsScreen> createState() => _BlogsDetailsScreenState();
}

class _BlogsDetailsScreenState extends State<BlogsDetailsScreen> {
  @override
  void initState() {
    super.initState();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: "${widget.blogData?.dataValues?.title}",
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          horizontalSpace(Dimensions.space10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Hero(
              tag: "${widget.blogData?.id.hashCode}",
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200.0,
                child: MyNetworkImageWidget(
                  imageUrl: "${widget.imagePath}",
                  radius: 0,
                ),
              ),
            ),
            verticalSpace(Dimensions.space10),
            ListTile(
              contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20),
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
                  "${widget.blogData?.dataValues?.title}",
                  style: boldMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                ),
              ),
            ),
            CustomDivider(
              color: MyColor.getBorderColor(),
              space: Dimensions.space10,
            ),
            //Content
            Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
              child: HtmlWidget(
                "${widget.blogData?.dataValues?.descriptionNic}",
              ),
            )
          ],
        ),
      ),
    );
  }
}
