import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_detail_controller.dart';
import '../../core/constants/colors.dart';

class OrderPlacementSheet extends StatelessWidget {
  final String symbol;

  const OrderPlacementSheet({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StockDetailController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stock details
            Obx(() {
              final quote = controller.stockQuote.value;
              if (quote == null) return const SizedBox();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.symbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        quote.companyName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${quote.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${quote.change >= 0 ? '+' : ''}${quote.change.toStringAsFixed(2)} (${quote.changePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: quote.change >= 0 ? AppColors.green : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Order Side Tabs (BUY vs SELL)
            Obx(() {
              final isBuy = controller.isBuy.value;
              return Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.isBuy.value = true,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isBuy ? AppColors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BUY',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isBuy ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.isBuy.value = false,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isBuy ? AppColors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SELL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !isBuy ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Order Type Selectors (MARKET vs LIMIT)
            Obx(() {
              final isLimit = controller.isLimit.value;
              return Row(
                children: [
                  Expanded(
                    child: _buildChoiceChip(
                      title: 'Market Order',
                      isSelected: !isLimit,
                      onTap: () {
                        controller.isLimit.value = false;
                        if (controller.stockQuote.value != null) {
                          controller.priceController.text =
                              controller.stockQuote.value!.price.toStringAsFixed(2);
                        }
                      },
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildChoiceChip(
                      title: 'Limit Order',
                      isSelected: isLimit,
                      onTap: () => controller.isLimit.value = true,
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Quantity and Limit Price Text Fields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUANTITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.quantityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Qty',
                          filled: true,
                          fillColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRICE (INR)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final isLimit = controller.isLimit.value;
                        return TextFormField(
                          controller: controller.priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: isLimit,
                          style: TextStyle(
                            color: isDark
                                ? (isLimit ? Colors.white : Colors.grey[600])
                                : (isLimit ? Colors.black87 : Colors.grey[400]),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Price',
                            filled: true,
                            fillColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick quantity buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [5, 10, 25, 50, 100].map((val) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                      label: Text('+$val'),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                      onPressed: () {
                        final currentQty = int.tryParse(controller.quantityController.text) ?? 0;
                        controller.quantityController.text = (currentQty + val).toString();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Cost breakdowns
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDark : AppColors.bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() {
                return Column(
                  children: [
                    _buildCostRow('Order Value', '₹${controller.totalAmount.toStringAsFixed(2)}', isDark),
                    const SizedBox(height: 8),
                    _buildCostRow('Brokerage (0.05%)', '₹${controller.brokerage.toStringAsFixed(2)}', isDark),
                    const Divider(height: 16),
                    _buildCostRow(
                      'Estimated Total',
                      '₹${controller.finalAmount.toStringAsFixed(2)}',
                      isDark,
                      isBold: true,
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),

            // Execute Button
            Obx(() {
              final isBuy = controller.isBuy.value;
              final isPlacing = controller.orderPlacing.value;
              final buttonColor = isBuy ? AppColors.green : AppColors.red;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isPlacing
                      ? null
                      : () {
                          controller.executeOrder();
                        },
                  child: isPlacing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '${isBuy ? 'PLACE BUY' : 'PLACE SELL'} ORDER',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? AppColors.bgDark : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String value, bool isDark, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
