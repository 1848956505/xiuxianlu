import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/database_helper.dart';

void main() {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: XiuxianluApp(),
    ),
  );

  // 在首帧渲染后初始化数据库
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await DatabaseHelper.instance.database;
  });
}
