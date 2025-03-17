import 'package:flutter/material.dart';

class SmartFarmIcon {
  final String icon;
  final String title;
  final Color? color;

  SmartFarmIcon({required this.icon, required this.title, this.color});
}

class StatsIcon {
  final String icon;
  final String title;
  final String value;

  StatsIcon({required this.icon, required this.title, required this.value});
}
