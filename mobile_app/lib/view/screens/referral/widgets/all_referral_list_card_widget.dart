import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';

import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/model/referral/referral_model.dart';
import '../../../components/divider/custom_spacer.dart';

class ReferralCardWidget extends StatelessWidget {
  final List<AllReferral> referrals;
  final int levelNo;

  const ReferralCardWidget({super.key, required this.referrals, required this.levelNo});

  @override
  Widget build(BuildContext context) {
    if (referrals.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        var item = referrals[index];

        return Container(
          decoration: BoxDecoration(border: BorderDirectional(start: BorderSide(color: MyColor.getSecondaryTextColor().withOpacity(0.5)))),
          padding: const EdgeInsetsDirectional.only(start: Dimensions.space10),
          // ignore: prefer_const_constructors
          margin: EdgeInsetsDirectional.only(
            bottom: Dimensions.space10,
            top: Dimensions.space10,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    color: MyColor.getSecondaryTextColor().withOpacity(0.5),
                    height: 1,
                    width: Dimensions.space10,
                  ),
                  horizontalSpace(Dimensions.space10),
                  Flexible(
                    child: Text(
                      "${item.getFullName()} (${item.username})",
                      style: regularDefault.copyWith(
                        color: MyColor.getPrimaryTextColor(),
                        fontSize: Dimensions.fontLarge,
                      ),
                    ),
                  ),
                ],
              ),
              ReferralCardWidget(
                referrals: item.allReferrals ?? [],
                levelNo: levelNo + 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
