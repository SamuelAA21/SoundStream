import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    final sliderMax =
        (player.duration.inSeconds <= 0 ? 1 : player.duration.inSeconds)
            .toDouble();
    final sliderValue = player.position.inSeconds <= 0
        ? 0.0
        : (player.position.inSeconds.toDouble() > sliderMax
              ? sliderMax
              : player.position.inSeconds.toDouble());

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: AppGradients.brand,
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${song.artist} • ${song.genre}',
                      style: TextStyle(color: AppColors.textMid, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => player.seekRelative(-10),
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: AppColors.textMid,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.brand,
                ),
                child: IconButton(
                  onPressed: player.isPlaying ? player.pause : player.resume,
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => player.seekRelative(10),
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.purple,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.pink,
              overlayColor: AppColors.purple.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: sliderValue,
              max: sliderMax,
              onChanged: (_) {},
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(player.position),
                style: TextStyle(color: AppColors.textMid, fontSize: 12),
              ),
              Text(
                _formatDuration(player.duration),
                style: TextStyle(color: AppColors.textMid, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration value) {
    final m = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
