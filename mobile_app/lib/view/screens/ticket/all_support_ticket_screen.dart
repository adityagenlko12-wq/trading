import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/date_converter.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/support/support_controller.dart';
import 'package:vinance/data/repo/support/support_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/app-bar/app_main_appbar.dart';
import 'package:vinance/view/components/column_widget/card_column.dart';
import 'package:vinance/view/components/custom_loader/custom_loader.dart';
import 'package:vinance/view/components/no_data.dart';
import 'package:vinance/view/components/shimmer/match_card_shimmer.dart';

class AllSupportTicketListScreen extends StatefulWidget {
  const AllSupportTicketListScreen({super.key});

  @override
  State<AllSupportTicketListScreen> createState() => _AllSupportTicketListScreenState();
}

class _AllSupportTicketListScreenState extends State<AllSupportTicketListScreen> {
  ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<SupportController>().hasNext()) {
        Get.find<SupportController>().getSupportTicket();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    final controller = Get.put(SupportController(repo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupportController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          title: MyStrings.supportTicket,
          isTitleCenter: true,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.loadData();
          },
          color: MyColor.getPrimaryColor(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: Dimensions.defaultPaddingHV,
                  child: controller.isLoading
                      ? ListView.builder(
                          itemCount: 10,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return const MatchCardShimmer();
                          },
                        )
                      : controller.ticketList.isEmpty
                          ? Center(
                              child: NoDataWidget(
                                text: MyStrings.noTicketFound.toCapitalized(),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: controller.ticketList.length + 1,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                              itemBuilder: (context, index) {
                                if (controller.ticketList.length == index) {
                                  return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    String id = controller.ticketList[index].ticket ?? '-1';
                                    String subject = controller.ticketList[index].subject ?? '';
                                    Get.toNamed(RouteHelper.supportTicketDetailsScreen, arguments: [id, subject]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space25),
                                    decoration: BoxDecoration(
                                      color: MyColor.getScreenBgSecondaryColor(),
                                      borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                                      border: Border.all(color: MyColor.getBorderColor(), width: 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                                child: Column(
                                                  children: [
                                                    CardColumn(
                                                      header: "[${MyStrings.ticket.tr}#${controller.ticketList[index].ticket}] ${controller.ticketList[index].subject}",
                                                      body: "${controller.ticketList[index].subject}",
                                                      space: 5,
                                                      headerTextStyle: regularDefault.copyWith(
                                                        color: MyColor.getPrimaryTextColor(),
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      bodyTextStyle: regularDefault.copyWith(
                                                        color: MyColor.getSecondaryTextColor(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                                              decoration: BoxDecoration(color: controller.getStatusColor(controller.ticketList[index].status ?? "0").withOpacity(0.2), border: Border.all(color: controller.getStatusColor(controller.ticketList[index].status ?? "0"), width: 1), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                                              child: Text(
                                                controller.getStatusText(controller.ticketList[index].status ?? '0'),
                                                style: regularDefault.copyWith(
                                                  color: controller.getStatusColor(controller.ticketList[index].status ?? "0"),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: Dimensions.space15),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                                              decoration: BoxDecoration(color: controller.getStatusColor(controller.ticketList[index].priority ?? "0", isPriority: true).withOpacity(0.2), border: Border.all(color: controller.getStatusColor(controller.ticketList[index].priority ?? "0", isPriority: true), width: 1), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                                              child: Text(
                                                controller.getStatus(controller.ticketList[index].priority ?? '1', isPriority: true),
                                                style: regularDefault.copyWith(
                                                  color: controller.getStatusColor(controller.ticketList[index].priority ?? "0", isPriority: true),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              DateConverter.getFormatedSubtractTime(controller.ticketList[index].createdAt ?? ''),
                                              style: regularDefault.copyWith(fontSize: 10, color: MyColor.ticketDateColor),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed(RouteHelper.addNewSupportTicketScreen)?.then((value) => {Get.find<SupportController>().getSupportTicket()});
          },
          backgroundColor: MyColor.getPrimaryColor(),
          child: const Icon(
            Icons.add,
            color: MyColor.colorWhite,
          ),
        ),
      );
    });
  }
}
