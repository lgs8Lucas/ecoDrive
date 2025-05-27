import 'package:ecoDrive/shared/app_colors.dart';
import 'package:flutter/material.dart';

class TipBox extends StatelessWidget {
  final String tipMessage;
  final String type;

  const TipBox({Key? key, required this.tipMessage, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: type == 'good'? AppColors.colorMain: AppColors.colorError,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: type == 'good'? AppColors.colorMain: AppColors.colorError, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tipMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: type == 'good'? AppColors.colorMain: AppColors.colorError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
