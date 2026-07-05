import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kamera/kamera_ekrani.dart';
import 'l10n/app_localizations.dart';

void main() {
  // ProviderScope: Riverpod'un kok kabi. Tum uygulama bunun altinda calisir.
  runApp(const ProviderScope(child: FirasetApp()));
}

/// Uygulama koku.
///
/// Tum kullanici metinleri [AppLocalizations] uzerinden gelir (locale-keyed);
/// arayuzde birebir string yazilmaz (bkz. CLAUDE.md - dil cercevesi/yerellestirme).
class FirasetApp extends StatelessWidget {
  const FirasetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

/// Iskelet ana ekranin gecici sayaci; Riverpod + l10n baglantisini dogrular.
/// Faz 2'de gercek tarama akisiyla degistirilecek.
final tapCountProvider = StateProvider<int>((ref) => 0);

/// Iskelet ana ekran. [ConsumerWidget] ile Riverpod state'ini okur.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final count = ref.watch(tapCountProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.homeTapCountLabel),
            Text('$count', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const KameraEkrani()),
              ),
              icon: const Icon(Icons.face_retouching_natural),
              label: Text(l10n.startScanButton),
            ),
            const SizedBox(height: 24),
            // Altin Kural 8: her ekranda gorunur "eglence ve kultur" ibaresi.
            Text(
              l10n.entertainmentDisclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(tapCountProvider.notifier).state++,
        tooltip: l10n.appTitle,
        child: const Icon(Icons.add),
      ),
    );
  }
}
