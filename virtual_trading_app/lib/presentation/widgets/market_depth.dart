import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class MarketDepthView extends StatelessWidget {
  final List<Map<String, dynamic>> bids;
  final List<Map<String, dynamic>> asks;
  final double totalBidQty;
  final double totalAskQty;

  const MarketDepthView({
    super.key,
    required this.bids,
    required this.asks,
    required this.totalBidQty,
    required this.totalAskQty,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double totalVolume = totalBidQty + totalAskQty;
    final double bidRatio = totalVolume > 0 ? (totalBidQty / totalVolume) * 100 : 50.0;
    final double askRatio = totalVolume > 0 ? (totalAskQty / totalVolume) * 100 : 50.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Depth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Live Order Book',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bid/Ask ratio bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: bidRatio.round(),
                  child: Container(color: AppColors.green),
                ),
                const SizedBox(width: 1),
                Expanded(
                  flex: askRatio.round(),
                  child: Container(color: AppColors.red),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${bidRatio.toStringAsFixed(1)}% BUYERS',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green),
            ),
            Text(
              '${askRatio.toStringAsFixed(1)}% SELLERS',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bids vs Asks Lists Header
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bid Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  Text('Ask Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 16, thickness: 0.5),

        // Depth lists
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bids side
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bids.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final bid = bids[index];
                  final double rate = double.tryParse(bid['rate']?.toString() ?? '') ?? 0.0;
                  final double qty = double.tryParse(bid['amount']?.toString() ?? '') ?? 0.0;
                  final double maxQty = bids.fold(0.0, (max, item) => (item['amount'] as double) > max ? item['amount'] : max);
                  final double percent = maxQty > 0 ? (qty / maxQty) : 0.0;

                  return Stack(
                    children: [
                      // Percentage background indicator
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: percent.clamp(0.0, 1.0),
                          child: Container(
                            height: 20,
                            color: AppColors.green.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rate.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            qty.toInt().toString(),
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 24),
            // Asks side
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: asks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ask = asks[index];
                  final double rate = double.tryParse(ask['rate']?.toString() ?? '') ?? 0.0;
                  final double qty = double.tryParse(ask['amount']?.toString() ?? '') ?? 0.0;
                  final double maxQty = asks.fold(0.0, (max, item) => (item['amount'] as double) > max ? item['amount'] : max);
                  final double percent = maxQty > 0 ? (qty / maxQty) : 0.0;

                  return Stack(
                    children: [
                      // Percentage background indicator
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: percent.clamp(0.0, 1.0),
                          child: Container(
                            height: 20,
                            color: AppColors.red.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            qty.toInt().toString(),
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                          Text(
                            rate.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12, color: AppColors.red, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
