import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final int? maxLines;
  final double fromLeft;

  const CustomText(
      this.text, {
        super.key,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.decoration,
        this.maxLines,
        required this.fromLeft,
      });

  @override
  Widget build(BuildContext context) {
    // double screenWidth =
    // double paddingValue = fromLeft * screenWidth / 375;
    return Padding(
      padding: EdgeInsets.only(left: fromLeft),
      child: Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        style: GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? Colors.black,
          decoration: decoration ?? TextDecoration.none,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
