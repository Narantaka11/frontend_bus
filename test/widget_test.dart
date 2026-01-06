import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
