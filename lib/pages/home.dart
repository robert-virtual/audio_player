import 'dart:async';

import 'package:audio_player/pages/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
// import 'package:on_audio_query/on_audio_query.dart';

///you need include this file only.

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  SongInfo? current;
  int currentIdx = 0;
  List<SongInfo>? songs;
  bool playing = false;
  // final OnAudioQuery _audioQuery = OnAudioQuery();
  StreamSubscription? subscription;

  /// create a FlutterAudioQuery instance.

  @override
  void initState() {
    super.initState();
    findSongs();
  }

  void findSongs() async {
    songs = await audioQuery.getSongs();
    songs = songs!.where((e) => e.isMusic).toList();
    setState(() {});
  }

  void play(idx) async {
    if (subscription != null) {
      subscription!.cancel();
    }

    await audioPlayer.stop();
    setState(() {
      currentIdx = idx;
      current = songs![idx];
      playing = true;
      audioPlayer.play(current!.filePath, isLocal: true);
      var future =
          Future.delayed(Duration(milliseconds: int.parse(current!.duration)));
      subscription = future.asStream().listen((_) {
        play(++currentIdx);
      });
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
    setState(() {
      playing = !playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Canciones ${songs!.length}"),
      ),
      body: songs != null
          ? ListView.builder(
              itemCount: songs!.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text("${songs![i].title}"),
                  subtitle: Text("artista: ${songs![i].artist}"),
                  trailing: Text("${songs![i].duration}"),
                  onTap: () {
                    play(i);
                  },
                  selected: i == currentIdx,
                );
              })
          : const Center(child: CircularProgressIndicator()),
      bottomSheet: current == null
          ? const Text("")
          : Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)]),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                        onTap: () async {
                          int res = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => PLayerPage(
                                        audioPlayer: audioPlayer,
                                        songs: songs!,
                                        currentIdx: currentIdx,
                                      )));
                          setState(() {
                            currentIdx = res;
                          });
                        },
                        child: Text(current!.title)),
                  ),
                  Row(
                    children: [
                      InkWell(
                        child: Icon(playing ? Icons.stop : Icons.play_arrow),
                        onTap: toggle,
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      InkWell(
                        child: const Icon(Icons.skip_next),
                        onTap: nextSong,
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
