import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class IntoPageWidget extends StatelessWidget {

  final String image;
  final String title;
  final String description;

   IntoPageWidget({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Scrollbar(
                controller: scrollController,
                trackVisibility: true,
                thumbVisibility: true,
                thickness: 4,
                radius: const Radius.circular(20),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyNetworkImageWidget(imageUrl: image, width: MediaQuery.of(context).size.height / 3,height: 200,boxFit: BoxFit.contain,),
                      const SizedBox(
                        height: Dimensions.space15,
                      ),
                      Text(
                        title.tr,
                        textAlign: TextAlign.center,
                        style: boldMediumLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontWeight: FontWeight.w400, fontSize: Dimensions.fontOverLarge),
                      ),
                      const SizedBox(
                        height: Dimensions.space10,
                      ),
                      Text(
                        description.tr,
                        textAlign: TextAlign.center,
                        style: regularDefault.copyWith(
                          color: MyColor.getSecondaryTextColor(),
                          fontSize: Dimensions.fontLarge,
                        ),
                      ),
                      const SizedBox(
                        height: Dimensions.space50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: Dimensions.space50,
          ),
        ],
      ),
    );
  }
}
