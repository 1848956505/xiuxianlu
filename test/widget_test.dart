import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiuxianlu/app.dart';

void main() {
  testWidgets('App 启动测试', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: XiuxianluApp(),
      ),
    );

    // 验证应用标题显示
    expect(find.text('修仙录'), findsOneWidget);
  });
}
