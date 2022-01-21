import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
// import 'package:on_audio_query/on_audio_query.dart';

///you need include this file only.

class _AudioProvider {
  AudioPlayer audioPlayer = AudioPlayer();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  SongInfo? current;
  int currentIdx = 0;
  List<SongInfo>? songs;
  bool playing = false;
  // final OnAudioQuery _audioQuery = OnAudioQuery();
  StreamSubscription? subscription;

  /// create a FlutterAudioQuery instance.

  void findSongs() async {
    songs = await audioQuery.getSongs();
    songs = songs!.where((e) => e.isMusic).toList();
  }

  void play(idx) async {
    if (subscription != null) {
      subscription!.cancel();
    }

    await audioPlayer.stop();
    currentIdx = idx;
    current = songs![idx];
    playing = true;
    audioPlayer.play(current!.filePath, isLocal: true);
    var future =
        Future.delayed(Duration(milliseconds: int.parse(current!.duration)));
    subscription = future.asStream().listen((_) {
      play(++currentIdx);
    });
  }

  void nextSong([int to = 1]) {
    play(currentIdx + to);
  }

  void toggle() {
    if (playing) {
      audioPlayer.pause();
      subscription!.pause();
    } else {
      audioPlayer.resume();
      subscription!.resume();
    }
    playing = !playing;
  }
}

final audioProvider = _AudioProvider();
