import 'package:ecoDrive/pages/viagemPage.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';

class TripList extends StatelessWidget{
  const TripList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppColors.colorAlterBackground,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text('Data ', style: AppStyles.simpleText,),
        subtitle: Text('Avaliacao: ', style: AppStyles.simpleText),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViagemPage()));
        },
      ),
    );
  }
}