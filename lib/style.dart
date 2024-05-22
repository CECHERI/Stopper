import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

class AppStyles {

  // 컬러
  // 메인 컬러 설정
  static const Color mainColor = Colors.black;

  // 서브 컬러 설정
  static const Color subColor = Colors.grey;


  // 기본 폰트 설정
  static const String fontFamily = 'OpenSans';


  // 텍스트 스타일
  // 메인 텍스트 스타일 설정
  static const TextStyle mainTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    color: Colors.black,
  );

  // 서브 텍스트 스타일 설정
  static const TextStyle subTextStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: Colors.black,
    //fontWeight: FontWeight.bold,
  );
}
