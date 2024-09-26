import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Sign In dialog has all required elements', (WidgetTester tester) async {
    // Построить экран с диалогом входа (Sign In)
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AlertDialog(
          title: Text('Sign In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: Key('emailField'),
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                key: Key('passwordField'),
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (_) {}),
                  Text('Remember me'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Enter'),
            ),
          ],
        ),
      ),
    ));

    // Проверить, что заголовок "Sign In" отображается
    expect(find.text('Sign In'), findsOneWidget);

    // Проверить наличие полей email и password
    expect(find.byKey(Key('emailField')), findsOneWidget);
    expect(find.byKey(Key('passwordField')), findsOneWidget);

    // Проверить наличие чекбокса и кнопок
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);

    // Взаимодействие: проверка кликабельности кнопок
    await tester.tap(find.text('Cancel'));
    await tester.tap(find.text('Enter'));

    await tester.pump();
  });
}
