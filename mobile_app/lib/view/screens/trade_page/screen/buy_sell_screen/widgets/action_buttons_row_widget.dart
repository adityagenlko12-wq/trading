import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

class ActionButtonsRowWidget extends StatelessWidget {
  final VoidCallback? onChartTap;
  final VoidCallback? onWatchlistTap;

  const ActionButtonsRowWidget({
    super.key,
    this.onChartTap,
    this.onWatchlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<_ActionButtonData> buttons = [
      _ActionButtonData(
        icon: Icons.notifications_outlined,
        label: 'Set Alert',
        onTap: null,
      ),
      _ActionButtonData(
        icon: Icons.bookmark_outline,
        label: 'Watchlist',
        onTap: onWatchlistTap,
      ),
      _ActionButtonData(
        icon: Icons.candlestick_chart,
        label: 'Chart',
        onTap: onChartTap,
      ),
      _ActionButtonData(
        icon: Icons.flash_on,
        label: 'Flash',
        onTap: null,
      ),
      _ActionButtonData(
        icon: Icons.speed,
        label: 'Scalper',
        onTap: null,
      ),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space5),
        itemCount: buttons.length,
        separatorBuilder: (_, __) => horizontalSpace(Dimensions.space15),
        itemBuilder: (context, index) {
          return _buildActionButton(buttons[index]);
        },
      ),
    );
  }

  Widget _buildActionButton(_ActionButtonData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MyColor.colorWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: MyColor.getBorderColor(),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 22,
              color: const Color(0xFFFF9800),
            ),
          ),
          verticalSpace(Dimensions.space5),
          Text(
            data.label,
            style: regularExtraSmall.copyWith(
              color: MyColor.getSecondaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtonData {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  _ActionButtonData({
    required this.icon,
    required this.label,
    this.onTap,
  });
}
