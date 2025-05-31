import 'package:ecoDrive/shared/app_colors.dart';
import 'package:flutter/cupertino.dart';

class CircularInfoWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String unit;

  const CircularInfoWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color: AppColors.colorAlterBackground.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 40, color: AppColors.colorBlack),
              Positioned(
                bottom: 10,
                child: Text(
                  "${value.toStringAsFixed(1)} $unit",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.colorBlack),
        ),
      ],
    );
  }
}