// Iskelet duman testi: Riverpod (ProviderScope) + l10n bagliyken sayacin
// arttigini dogrular. Faz 2'de gercek akis testleriyle genisletilecek.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firaset/main.dart';

void main() {
  testWidgets('Sayac ProviderScope + l10n altinda artar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FirasetApp()));
    await tester.pumpAndSettle();

    // Sayac 0'dan baslar.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // '+' dokunusu sayaci arttirir.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
