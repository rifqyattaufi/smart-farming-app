import 'package:flutter/material.dart';

// Colors
Color green1 = const Color(0xFF00623A);
Color green2 = const Color(0xFF3B9C0B);
Color green3 = const Color(0xFFEEE3D4);
Color green4 = const Color(0xFFDBE4D6);

Color yellow = const Color(0xFFFF9306);
Color yellow1 = const Color(0xFFEEE3D4);
Color yellow2 = const Color(0xFFFAC96C);
Color grey = const Color(0xFFD9D9D9);

Color dark1 = const Color(0xFF494953);
Color dark2 = const Color(0xFF4A4A4A);
Color dark3 = const Color(0xFF999798);
Color dark4 = const Color(0xFFEDEDED);

Color blue1 = const Color(0xFF37B7FF);
Color blue2 = const Color(0xFF177BFF);
Color blue3 = const Color(0xFFE0E1EE);
Color blue4 = const Color(0xFF2E8BFF);

Color red = const Color(0xFFE84140);
Color red2 = const Color(0xFFEEDFDF);
Color purple = const Color(0xFF87027B);
Color white = Colors.white;

// Typography
TextStyle _textStyle(double size, FontWeight weight,
        [double letterSpacing = 0]) =>
    TextStyle(
        fontFamily: 'Onest',
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing);

// Predefined styles
TextStyle regular10 = _textStyle(10, FontWeight.w400);
TextStyle regular12 = _textStyle(12, FontWeight.w400);
TextStyle semibold12 = _textStyle(12, FontWeight.w600);
TextStyle bold12 = _textStyle(12, FontWeight.w700);
TextStyle extraBold12 = _textStyle(12, FontWeight.w800);
TextStyle black12 = _textStyle(12, FontWeight.w900);
TextStyle medium10 = _textStyle(10, FontWeight.w500);
TextStyle medium12 = _textStyle(12, FontWeight.w500);
TextStyle light12 = _textStyle(12, FontWeight.w300);
TextStyle extraLight12 = _textStyle(12, FontWeight.w200);
TextStyle thin12 = _textStyle(12, FontWeight.w100);

// Function to create different sizes
TextStyle textSize(TextStyle baseStyle, double size,
        [double letterSpacing = 0]) =>
    baseStyle.copyWith(fontSize: size, letterSpacing: letterSpacing);

// Sizes for each weight
TextStyle regular14 = textSize(regular12, 14);
TextStyle regular16 = textSize(regular12, 16);
TextStyle regular18 = textSize(regular12, 18);
TextStyle regular20 = textSize(regular12, 20, 0.1);

TextStyle semibold14 = textSize(semibold12, 14, 0.1);
TextStyle semibold16 = textSize(semibold12, 16, 0.1);
TextStyle semibold18 = textSize(semibold12, 18, 0.1);
TextStyle semibold20 = textSize(semibold12, 20, 0.1);

TextStyle bold14 = textSize(bold12, 14);
TextStyle bold16 = textSize(bold12, 16, 0.1);
TextStyle bold18 = textSize(bold12, 18, -0.5);
TextStyle bold20 = textSize(bold12, 20, -0.5);

TextStyle extraBold14 = textSize(extraBold12, 14);
TextStyle extraBold16 = textSize(extraBold12, 16);
TextStyle extraBold18 = textSize(extraBold12, 18);
TextStyle extraBold20 = textSize(extraBold12, 20, -0.5);

TextStyle black14 = textSize(black12, 14);
TextStyle black16 = textSize(black12, 16);
TextStyle black18 = textSize(black12, 18);
TextStyle black20 = textSize(black12, 20, -0.5);

TextStyle medium14 = textSize(medium12, 14);
TextStyle medium16 = textSize(medium12, 16);
TextStyle medium18 = textSize(medium12, 18);
TextStyle medium20 = textSize(medium12, 20, 0.1);

TextStyle light14 = textSize(light12, 14);
TextStyle light16 = textSize(light12, 16);
TextStyle light18 = textSize(light12, 18);
TextStyle light20 = textSize(light12, 20, 0.1);

TextStyle extraLight14 = textSize(extraLight12, 14);
TextStyle extraLight16 = textSize(extraLight12, 16);
TextStyle extraLight18 = textSize(extraLight12, 18);
TextStyle extraLight20 = textSize(extraLight12, 20, 0.1);

TextStyle thin14 = textSize(thin12, 14);
TextStyle thin16 = textSize(thin12, 16);
TextStyle thin18 = textSize(thin12, 18);
TextStyle thin20 = textSize(thin12, 20, 0.1);
