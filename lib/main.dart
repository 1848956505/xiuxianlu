import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'data/database/database_helper.dart';

void main() {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 桌面端（Windows/Linux/macOS）需要初始化 sqflite FFI
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
