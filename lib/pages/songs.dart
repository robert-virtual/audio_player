import 'dart:async';

import 'package:audio_player/pages/fake.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
// import 'package:on_audio_query/on_audio_query.dart';

///you need include this file only.

class SongsPage extends StatefulWidget {
  const SongsPage({
    Key? key,
  }) : super(key: key);
  @override
  _SongsPageState createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  AudioPlayer audioPlayer = AudioPlayer();
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  SongInfo? current;
  final what = TextEditingController();
  int currentIdx = 0;
  bool searching = false;
  List<SongInfo>? songs;
  List<SongInfo>? songsCopy;
  bool playing = false;
  // final OnAudioQuery _audioQuery = OnAudioQuery();
  StreamSubscription? subscription;

  /// create a FlutterAudioQuery instance.

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    findSongs();
  }

  void findSongs() async {
    songs = await audioQuery.getSongs();
    songs = songs!.where((e) => e.isMusic).toList();
    songsCopy = songs;
    setState(() {});
  }

  void lookUp(any) {
    setState(() {
      songs = songsCopy!
          .where((e) =>
              e.title.toLowerCase().contains(what.text.toLowerCase()) ||
              e.artist.toLowerCase().contains(what.text.toLowerCase()))
          .toList();
    });
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

  late FocusNode focusNode;
  void search() {
    setState(() {
      searching = !searching;
    });
    if (searching) {
      focusNode.requestFocus();
    }
  }

  void openPlayer() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return FakePage();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: searching
            ? IconButton(
                onPressed: search,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        actions: [
          searching
              ? IconButton(onPressed: what.clear, icon: const Icon(Icons.clear))
              : IconButton(onPressed: search, icon: const Icon(Icons.search))
        ],
        title: searching
            ? TextField(
                onChanged: lookUp,
                focusNode: focusNode,
                cursorColor: Colors.white,
                controller: what,
                decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "search...",
                    border: InputBorder.none),
              )
            : const Text("Music"),
      ),
      body: songs != null
          ? ListView.builder(
              itemCount: songs!.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text("${songs![i].title}"),
                  subtitle: Text(songs![i].artist),
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
                    child:
                        InkWell(onTap: openPlayer, child: Text(current!.title)),
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
