import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

void startTimer() {
  playNotificationTone();
}

Future<void> playNotificationTone() async {
  await _audioPlayer.play(AssetSource('ringtone/eureka.mp3'));
}