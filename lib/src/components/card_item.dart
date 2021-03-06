import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardItem extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final bool? isActive;

  CardItem({this.title, this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 1.sw - 30,
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              width: 1,
              color: isActive!
                  ? Color.fromRGBO(0, 0, 0, 1)
                  : Color.fromRGBO(225, 225, 215, 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: isActive! ? 6 : 2,
                        color: isActive!
                            ? Color.fromRGBO(255, 184, 0, 1)
                            : Color.fromRGBO(225, 225, 215, 1))),
              ),
              Text(
                "$title",
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    letterSpacing: -0.4,
                    color: Color.fromRGBO(0, 0, 0, 1)),
              ),
            ],
          ),
          if (icon != null)
            Container(
              child: Icon(
                icon,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            )
        ],
      ),
    );
  }
}
