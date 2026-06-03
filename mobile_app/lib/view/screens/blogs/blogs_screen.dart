import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/blogs/blogs_controller.dart';
import '../../../data/repo/blogs/blogs_repository.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/custom_loader/custom_loader.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/no_data.dart';
import 'blog_card_widget.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(BlogsRepository(apiClient: Get.find()));
    final controller = Get.put(BlogsController(blogsRepository: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAllBlogList();
      scrollController.addListener(scrollListener);
    });
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<BlogsController>().hasNext()) {
        Get.find<BlogsController>().getAllBlogList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BlogsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.latestNews.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : controller.blogList.isEmpty
                ?  Center(
                    child: FittedBox(
                      child: NoDataWidget(
                        text: MyStrings.noNewsFound.tr,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.blogList.length + 1,
                    itemBuilder: (context, index) {
                      if (controller.blogList.length == index) {
                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                      }
                      return BlogCardWidget(item: controller.blogList[index], controller: controller);
                    },
                  ),
      );
    });
  }
}
