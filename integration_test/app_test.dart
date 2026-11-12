import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (var i = 1; i <= 3; i++) {
    testWidgets('passing test $i', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Text('test $i')));
      expect(find.text('test $i'), findsOneWidget);
    });
  }
}
