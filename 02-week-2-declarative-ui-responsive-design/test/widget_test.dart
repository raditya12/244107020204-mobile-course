import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('displays the student profile card', (WidgetTester tester) async {
    await tester.pumpWidget(const ProfileApp());

    expect(find.text('Nama Mahasiswa'), findsOneWidget);
    expect(find.text('Raditya Riefki'), findsOneWidget);
    expect(find.text('NIM'), findsOneWidget);
    expect(find.text('244107020204'), findsOneWidget);
    expect(find.text('Kelas'), findsOneWidget);
    expect(find.text('TI-3E'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('radityariefki5@gmail.com'), findsOneWidget);
  });
}
