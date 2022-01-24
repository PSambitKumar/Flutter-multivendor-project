import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:githubit/src/utils/hex_color.dart';

class BoxType extends StatelessWidget {
  final bool? hasBottom;
  final String? price;
  final String? range;
  final bool? isActive;
  const BoxType(
      {Key? key,
      this.isActive = false,
      this.price,
      this.range,
      this.hasBottom = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw - 30,
      height: 75,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  width: 1, color: Color.fromRGBO(232, 232, 232, 0.5)),
              bottom: BorderSide(
                  width: hasBottom! ? 1 : 0,
                  color: Color.fromRGBO(232, 232, 232, 0.5)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                isActive!
                    ? const IconData(0xeb80, fontFamily: 'MIcon')
                    : const IconData(0xeb7d, fontFamily: 'MIcon'),
                color: isActive!
                    ? Color.fromRGBO(69, 165, 36, 1)
                    : HexColor("#A0A09C"),
                size: 24.sp,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                "$price",
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    letterSpacing: -0.4,
                    color: Color.fromRGBO(0, 0, 0, 1)),
              )
            ],
          ),
          Text(
            "$range",
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                letterSpacing: -0.4,
                color: Color.fromRGBO(0, 0, 0, 1)),
          )
        ],
      ),
    );
  }
}
