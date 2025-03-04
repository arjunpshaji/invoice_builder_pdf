import 'package:flutter/material.dart';
import 'package:invoice_generator/modules/theme/colors.dart';

AppColors appColor(context) => Theme.of(context).extension<AppColors>()!;

ThemeData getAppTheme(BuildContext context) {
  return ThemeData(
    extensions: const <ThemeExtension<AppColors>>[
      AppColors(
        background: Color(0xffFAFAFA),
        text: Color(0xff202123),
        primaryText: Color(0xff4D4E4F),
        errorText: Color(0xffdb292a),
        green: Color(0xff093C39),
      ),
    ],
    fontFamily: 'Manrope',
  );
}
