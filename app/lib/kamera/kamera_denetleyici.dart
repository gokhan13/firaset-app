import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../olcum/landmark_motoru.dart';
import '../olcum/mediapipe_landmark_motoru.dart';

/// Kamera ekraninin akis asamalari.
enum KameraAsama { yukleniyor, izinYok, hata, hazir }

/// Degistirilebilir landmark motoru saglayicisi.
///
/// Uretimde [MediapipeLandmarkMotoru] doner (mediapipe_face_mesh paketini goren
/// tek yer). Testler bunu sahte bir [LandmarkMotoru] ile `override` eder; boylece
/// UI ve olcum testleri kamera/native gerektirmeden calisir (koruma #2, D-016).
final landmarkMotoruProvider = Provider.autoDispose<LandmarkMotoru>((ref) {
  final motor = MediapipeLandmarkMotoru();
  ref.onDispose(motor.durdur);
  return motor;
});
