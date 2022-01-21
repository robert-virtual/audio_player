import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class PLayerPage extends StatefulWidget {
  const PLayerPage(
      {Key? key,
      required this.audioPlayer,
      required this.songs,
      required this.currentIdx})
      : super(key: key);
  final AudioPlayer audioPlayer;
  final List<SongInfo> songs;
  final int currentIdx;

  @override
  _PLayerPageState createState() => _PLayerPageState();
}

class _PLayerPageState extends State<PLayerPage> {
  bool playing = true;
  late int currentIdx;
  late SongInfo current;
  @override
  void initState() {
    super.initState();
    currentIdx = widget.currentIdx;
    current = widget.songs[widget.currentIdx];
  }

  void play(idx) async {
    await widget.audioPlayer.stop();
    setState(() {
      currentIdx = idx;
      current = widget.songs[idx];
      playing = true;
      widget.audioPlayer.play(current.filePath, isLocal: true);
    });
  }

  void nextSong([int to = 1]) {
    play(currentIdx + to);
  }

  void toggle() {
    if (playing) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.resume();
    }
    setState(() {
      playing = !playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(
                context,
                currentIdx
              );
            },
            icon: const Icon(Icons.keyboard_arrow_down,color: Colors.black,)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(current.title),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                    onTap: () => nextSong(-1),
                    child: const Icon(Icons.skip_previous)),
                const SizedBox(
                  width: 25,
                ),
                InkWell(
                    onTap: toggle,
                    child: Icon(playing ? Icons.stop : Icons.play_arrow)),
                const SizedBox(
                  width: 25,
                ),
                InkWell(onTap: nextSong, child: const Icon(Icons.skip_next)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
