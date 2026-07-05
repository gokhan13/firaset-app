import 'dart:async';

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'landmark_motoru.dart';

/// [LandmarkMotoru]'nun `mediapipe_face_mesh` implementasyonu.
///
/// DIKKAT: `mediapipe_face_mesh` paketini import eden **tek** dosya budur.
/// Baska motora gecis yalnizca bu dosyayi degistirir (docs/kararlar.md D-016).
///
/// Not: [kareVer] senkron bir FFI cagrisidir; kare atlama korumasi cagiran
/// katmandadir (kamera denetleyici). Islenen kareler ve landmark'lar diske
/// yazilmaz (CLAUDE.md Altin Kural 1) - burada yalniz bellek-ici donusum yapilir.
class MediapipeLandmarkMotoru implements LandmarkMotoru {
  FaceDetectorProcessor? _detector;
  FaceMeshProcessor? _mesh;
  FaceMeshInferencePipeline? _pipeline;

  final StreamController<LandmarkSonucu> _cikti =
      StreamController<LandmarkSonucu>.broadcast();
  bool _kapali = false;

  @override
  Stream<LandmarkSonucu> get sonuclar => _cikti.stream;

  @override
  Future<void> baslat() async {
    final detector = await FaceDetectorProcessor.create();
    // enableIris: true -> iris ile birlikte 478 nokta (aksi halde 468).
    final mesh = await FaceMeshProcessor.create(enableIris: true);
    _detector = detector;
    _mesh = mesh;
    _pipeline = FaceMeshInferencePipeline(detector: detector, mesh: mesh);
  }

  @override
  void kareVer(KameraKaresi kare) {
    final pipeline = _pipeline;
    if (_kapali || pipeline == null || _cikti.isClosed) return;

    if (kare.format != KareFormati.bgra) {
      // NV21/Android yolu Android testiyle (Gorev 2.1) eklenecek.
      throw UnsupportedError('Su an yalniz BGRA (iOS) kare destekleniyor.');
    }

    final image = FaceMeshImage(
      pixels: kare.bytes,
      width: kare.width,
      height: kare.height,
      pixelFormat: FaceMeshPixelFormat.bgra,
      bytesPerRow: kare.bytesPerRow,
    );

    final FaceMeshInferenceResult sonuc = pipeline.process(
      image,
      rotationDegrees: kare.rotation,
      mirrorHorizontal:
          true, // on kamera ayna goruntusu; cihazda ince ayar yapilabilir
    );

    if (_cikti.isClosed) return;
    final mesh = sonuc.meshResult;
    _cikti.add(
      LandmarkSonucu(
        noktalar: mesh == null
            ? const <Landmark>[]
            : mesh.landmarks
                  .map((l) => Landmark(l.x, l.y, l.z))
                  .toList(growable: false),
        yuzVar: sonuc.hasFace,
      ),
    );
  }

  @override
  Future<void> durdur() async {
    _kapali = true;
    _mesh?.close();
    _detector?.close();
    _mesh = null;
    _detector = null;
    _pipeline = null;
    if (!_cikti.isClosed) {
      await _cikti.close();
    }
  }
}
