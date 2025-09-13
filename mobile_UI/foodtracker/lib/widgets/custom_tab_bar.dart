// lib/widgets/custom_tab_bar.dart
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabTitles;
  final EdgeInsetsGeometry? margin;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabTitles,
    this.margin,
    this.indicatorColor = const Color(0xFF0386D0),
    this.labelColor = const Color(0xFF0386D0),
    this.unselectedLabelColor = const Color(0xFFA6A6A6),
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(0),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        dividerColor:Color(0xFFF6F5F5),
        indicatorColor: indicatorColor,
        labelColor: labelColor,
        unselectedLabelColor: unselectedLabelColor,
        labelStyle: labelStyle ?? TextStyle(fontWeight: FontWeight.bold, fontFamily: 'hind',),
        unselectedLabelStyle: unselectedLabelStyle ?? TextStyle(fontWeight: FontWeight.normal),
        tabs: tabTitles
            .map((title) => Tab(text: title.toUpperCase()))
            .toList(),
      ),
    );
  }
}