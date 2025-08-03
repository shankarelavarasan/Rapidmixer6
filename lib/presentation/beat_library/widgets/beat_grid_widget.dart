import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './beat_card_widget.dart';

class BeatGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> beats;
  final String? currentPlayingBeatId;
  final Function(Map<String, dynamic>) onBeatPlay;
  final Function(Map<String, dynamic>) onBeatLongPress;
  final String? selectedBeatId;
  final ScrollController? scrollController;

  const BeatGridWidget({
    super.key,
    required this.beats,
    this.currentPlayingBeatId,
    required this.onBeatPlay,
    required this.onBeatLongPress,
    this.selectedBeatId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (beats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'music_off',
              color: AppTheme.textSecondary,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No beats found',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: beats.length,
      itemBuilder: (context, index) {
        final beat = beats[index];
        final beatId = beat['id']?.toString();
        final isPlaying = beatId == currentPlayingBeatId;
        final isSelected = beatId == selectedBeatId;

        return BeatCardWidget(
          beatData: beat,
          isPlaying: isPlaying,
          isSelected: isSelected,
          onPlay: () => onBeatPlay(beat),
          onLongPress: () => onBeatLongPress(beat),
        );
      },
    );
  }
}
