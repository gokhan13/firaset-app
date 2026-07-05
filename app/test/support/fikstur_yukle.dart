import 'dart:convert';
import 'dart:io';

import 'package:firaset/olcum/landmark_motoru.dart';
import 'package:firaset/olcum/olcum_girdisi.dart';

/// `test/fixtures/<ad>.json` fikstürünü [OlcumGirdisi]'ne yükler.
OlcumGirdisi fiksturuYukle(String ad) {
  final data =
      jsonDecode(File('test/fixtures/$ad.json').readAsStringSync())
          as Map<String, dynamic>;
  final noktalar = (data['noktalar'] as List)
      .map(
        (p) => Landmark(
          (p[0] as num).toDouble(),
          (p[1] as num).toDouble(),
          (p[2] as num).toDouble(),
        ),
      )
      .toList();
  return OlcumGirdisi(
    noktalar: noktalar,
    enPiksel: data['enPiksel'] as int,
    boyPiksel: data['boyPiksel'] as int,
  );
}
