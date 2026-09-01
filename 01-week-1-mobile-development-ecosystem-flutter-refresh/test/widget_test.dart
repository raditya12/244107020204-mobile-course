import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('displays the student profile', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('Raditya Riefki'), findsOneWidget);
    expect(find.text('NIM: 244107020204'), findsOneWidget);
    expect(find.text('Semester 5'), findsOneWidget);
    expect(find.text('Pemrograman Mobile - Minggu 1'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
