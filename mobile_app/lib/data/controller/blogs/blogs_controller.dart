// Import necessary dependencies or models
import 'package:get/get.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/blogs/blogs_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/blogs/blogs_repository.dart';

class BlogsController extends GetxController {
  BlogsRepository blogsRepository;

  BlogsController({required this.blogsRepository});

  bool isLoading = false;
  List<BlogData> blogList = [];
  int page = 0;
  int blogSelectedIndex = -1;
  String? imagePath;
  String? nextPageUrl;

  Future<void> getAllBlogList({bool isFromLoad = false}) async {
    page = page + 1;
    if (page == 1) {
      blogList.clear();
      isLoading = true;
      update();
    }

    try {
      ResponseModel responseModel = await blogsRepository.fetchAllBlogs(page.toString());
      if (responseModel.statusCode == 200) {
        final blogScreenResponseModel = blogScreenResponseModelFromJson(responseModel.responseJson);
        if (blogScreenResponseModel.status == MyStrings.success) {
          nextPageUrl = blogScreenResponseModel.data?.blogs?.nextPageUrl;
          imagePath = blogScreenResponseModel.data?.path;
          printx(nextPageUrl);

          List<BlogData>? tempBlogs = blogScreenResponseModel.data?.blogs?.data;
          if (tempBlogs != null && tempBlogs.isNotEmpty) {
            blogList.addAll(tempBlogs);
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: blogScreenResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }
}
