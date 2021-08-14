import 'package:audioplayers/audioplayers.dart';

enum AudioType {
  wind_up,
}

class _MyAudioPlayer {
  //私有构造函数
  _MyAudioPlayer._internal();

  //保存单例
  static _MyAudioPlayer _singleton = new _MyAudioPlayer._internal();

  //工厂构造函数
  factory _MyAudioPlayer() => _singleton;

  AudioCache _audioCache = new AudioCache();

  void play(AudioType type) async {
    switch (type) {
      case AudioType.wind_up:
        {
          await _audioCache.play('audio/wind_up.mp3');
        }
        break;
      default:
        {}
    }
  }
}

_MyAudioPlayer player = new _MyAudioPlayer();
