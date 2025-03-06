import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_applicatione/main.dart'; // Assurez-vous que le chemin est correct

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(
      find.text('0'),
      findsOneWidget,
    ); // Vérifie que le texte '0' est présent
    expect(find.text('1'), findsNothing); // Vérifie que le texte '1' est absent

    // Tap the '+' icon and trigger a frame.
    await tester.tap(
      find.byIcon(Icons.add),
    ); // Trouve et appuie sur l'icône '+'
    await tester.pump(); // Met à jour l'interface après l'interaction

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing); // Vérifie que le texte '0' est absent
    expect(
      find.text('1'),
      findsOneWidget,
    ); // Vérifie que le texte '1' est présent
  });
}
