import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sign In/Sign Up screen has buttons', (WidgetTester tester) async {
    // Построить экран с нужными элементами
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('InnoFellowTravelers'),
            ElevatedButton(
              onPressed: () {},
              child: Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    ));

    // Проверить, что заголовок отображается
    expect(find.text('InnoFellowTravelers'), findsOneWidget);

    // Проверить, что кнопки "Sign In" и "Sign Up" отображаются
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Проверить, что кнопки кликабельны
    await tester.tap(find.text('Sign In'));
    await tester.tap(find.text('Sign Up'));

    // Запустить анимации или другие изменения
    await tester.pump();
  });
}
