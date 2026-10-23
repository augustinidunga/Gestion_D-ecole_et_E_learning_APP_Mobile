import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class VideoLessonScreen extends StatefulWidget {
  final Lesson lesson;
  const VideoLessonScreen({super.key, required this.lesson});

  @override
  State<VideoLessonScreen> createState() => _VideoLessonScreenState();
}

class _VideoLessonScreenState extends State<VideoLessonScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final url = widget.lesson.url;
    if (url != null && url.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() => _ready = true);
        }).catchError((e) {
          if (mounted) setState(() => _error = e.toString());
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final s = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: Text(l.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (l.url != null && l.url!.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: _controller != null && _controller!.value.isInitialized
                  ? _controller!.value.aspectRatio
                  : 16 / 9,
              child: Container(
                color: AppColors.dark,
                child: _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                    : !_ready
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : Stack(alignment: Alignment.bottomCenter, children: [
                            VideoPlayer(_controller!),
                            _Controls(controller: _controller!),
                          ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppFormButton(
                text: _controller != null && _controller!.value.isPlaying ? 'Pause' : 'Lecture',
                icon: _controller != null && _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                onPressed: () {
                  if (_controller == null) return;
                  setState(() {
                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                  });
                },
              )),
              const SizedBox(width: 8),
              Expanded(child: AppFormButton(
                text: 'Terminé',
                icon: Icons.check_circle,
                color: AppColors.accent,
                onPressed: () {
                  s.markDone(l);
                  toast(context, 'Contenu marqué comme terminé');
                },
              )),
            ]),
            const SizedBox(height: 8),
            Text('Diffusion adaptative (HLS/MP4) • qualité auto selon le débit.',
                style: TextStyle(fontSize: 11, color: Neumo.of(context).textMuted)),
          ] else if (l.meetingLink != null && l.meetingLink!.isNotEmpty) ...[
            AppCardElevated(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Cours en direct / visio', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(l.meetingLink!, style: const TextStyle(color: AppColors.primary)),
                const SizedBox(height: 12),
                AppFormButton(
                  text: 'Rejoindre la classe virtuelle',
                  icon: Icons.video_call_rounded,
                  onPressed: () => toast(context, 'Ouverture du lien (navigateur externe)'),
                ),
              ]),
            ),
          ] else
            const EmptyState(Icons.videocam_off, 'Aucune vidéo disponible pour ce contenu'),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final VideoPlayerController controller;
  const _Controls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return VideoProgressIndicator(controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white38, backgroundColor: Colors.white12));
  }
}
