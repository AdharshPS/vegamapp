import 'package:flutter/material.dart';
import 'package:m2/utilities/utilities.dart';

// Widget to show the price of the product with offer, if any, under product listing
class CartPriceAddedDetails extends StatelessWidget {
  const CartPriceAddedDetails({
    super.key,
    this.price,
    required this.priceSize,
    this.originalPrice,
    this.originalPriceSize,
    this.offer,
    this.offerSize,
    this.currency,
    this.item,
  });

  final String? price;
  final double priceSize;
  final String? originalPrice;
  final double? originalPriceSize;
  final double? offer;
  final double? offerSize;
  final String? currency;

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: currency != null ? '$currency ' : '₹ ',
        style: TextStyle(fontSize: priceSize, fontWeight: FontWeight.w600),
        children: [
          if (price != null)
            TextSpan(
              text: '${double.parse(price!) * item['quantity']}   ',
              style: AppStyles.getMediumTextStyle(
                  fontSize: priceSize, color: AppColors.fontColor),
            ),
          if (originalPrice != null && offer != 0)
            TextSpan(
                text: currency != null ? '$currency' : '₹',
                style: TextStyle(
                  color: AppColors.fadedText,
                  fontSize: offerSize,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                )),
          if (originalPrice != null && offer != 0)
            TextSpan(
              text: '${double.parse(originalPrice!) * item['quantity']} ',
              style: TextStyle(
                fontSize: offerSize,
                fontWeight: FontWeight.w500,
                color: AppColors.fadedText,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          if (originalPrice != null && offer != 0)
            TextSpan(
              text: '   $offer% off',
              style: AppStyles.getMediumTextStyle(
                  fontSize: offerSize ?? 12, color: AppColors.buttonColor),
            ),
        ],
      ),
    );
  }
}
