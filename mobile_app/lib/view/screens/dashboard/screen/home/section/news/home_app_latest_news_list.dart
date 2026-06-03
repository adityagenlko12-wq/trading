import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../../data/model/blogs/blogs_model.dart';
import '../../../../../../components/shimmer/home_page_news_shimmer.dart';

class HomeAppLatestNewsWidget extends StatelessWidget {
  final HomeController controller;
  const HomeAppLatestNewsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return !controller.isBlogListLoading && controller.blogListData.isEmpty
        ? const SizedBox()
        : Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.latestNews.tr,
                      style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.all(Dimensions.space2)),
                          onPressed: () {
                            Get.toNamed(RouteHelper.blogScreenScreen);
                          },
                          child: Row(
                            children: [
                              Text(
                                MyStrings.all.tr,
                                style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                              ),
                              horizontalSpace(Dimensions.space5),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: MyColor.getPrimaryTextColor(),
                                size: Dimensions.space15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                verticalSpace(Dimensions.space10),
                if (controller.isBlogListLoading) ...[
                  const HomePageMarketListHorizontalNewsShimmer(),
                ] else ...[
                  SizedBox(
                      width: double.infinity,
                      child: CarouselSlider.builder(
                        itemCount: controller.blogListData.length,
                        itemBuilder: (context, index, realIndex) {
                          BlogData item = controller.blogListData[index];
                          return InkWell(
                            onTap: () {
                              Get.toNamed(RouteHelper.blogDetailScreenScreen, arguments: [item, "${UrlContainer.domainUrl}/${controller.blogImagePath}/${item.dataValues?.image ?? ''}"]);
                            },
                            child: MyNetworkImageWidget(
                              imageUrl: "${UrlContainer.domainUrl}/${controller.blogImagePath}/${item.dataValues?.image ?? ''}",
                              width: double.infinity,
                              radius: Dimensions.cardRadius2,
                            ),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1,
                          height: 200,
                          enableInfiniteScroll: true,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // controller.setCurrentIndex(index);
                          },
                        ),
                      )),
                ],
              ],
            ),
          );
  }
}
