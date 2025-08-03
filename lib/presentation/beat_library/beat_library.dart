import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/beat_grid_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/preview_player_widget.dart';
import './widgets/search_bar_widget.dart';
import '../../services/audio_service.dart';

class BeatLibrary extends StatefulWidget {
  const BeatLibrary({super.key});

  @override
  State<BeatLibrary> createState() => _BeatLibraryState();
}

class _BeatLibraryState extends State<BeatLibrary>
    with TickerProviderStateMixin {
  late AudioService _audioService;
  late TabController _tabController;
  late ScrollController _scrollController;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  Map<String, dynamic>? _currentPlayingBeat;
  String? _currentPlayingBeatId;
  String? _selectedBeatId;
  bool _isPlaying = false;
  bool _tempoMatchEnabled = false;
  double _currentPosition = 0.0;
  double _totalDuration = 30.0;
  bool _showFavoritesOnly = false;
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'Hip-Hop',
    'Electronic',
    'Rock',
    'Pop',
    'Jazz',
    'Latin',
    'R&B',
    'Trap',
    'House'
  ];

  final List<Map<String, dynamic>> _allBeats = [
    {
      "id": 1,
      "name": "Urban Groove",
      "bpm": 95,
      "duration": "0:32",
      "genre": "Hip-Hop",
      "isFavorite": true,
      "isInProject": false,
      "waveform": [
        0.8,
        0.6,
        0.9,
        0.4,
        0.7,
        0.5,
        0.8,
        0.3,
        0.6,
        0.9,
        0.7,
        0.4,
        0.8,
        0.5,
        0.6,
        0.9,
        0.3,
        0.7,
        0.8,
        0.4
      ],
    },
    {
      "id": 2,
      "name": "Neon Pulse",
      "bpm": 128,
      "duration": "0:28",
      "genre": "Electronic",
      "isFavorite": false,
      "isInProject": true,
      "waveform": [
        0.9,
        0.8,
        0.7,
        0.9,
        0.6,
        0.8,
        0.9,
        0.5,
        0.7,
        0.8,
        0.9,
        0.6,
        0.7,
        0.8,
        0.5,
        0.9,
        0.7,
        0.6,
        0.8,
        0.9
      ],
    },
    {
      "id": 3,
      "name": "Rock Anthem",
      "bpm": 140,
      "duration": "0:35",
      "genre": "Rock",
      "isFavorite": false,
      "isInProject": false,
      "waveform": [
        0.7,
        0.9,
        0.8,
        0.6,
        0.9,
        0.7,
        0.8,
        0.5,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.9,
        0.7,
        0.8,
        0.6
      ],
    },
    {
      "id": 4,
      "name": "Pop Vibes",
      "bpm": 120,
      "duration": "0:30",
      "genre": "Pop",
      "isFavorite": true,
      "isInProject": false,
      "waveform": [
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.7,
        0.9,
        0.5
      ],
    },
    {
      "id": 5,
      "name": "Smooth Jazz",
      "bpm": 85,
      "duration": "0:40",
      "genre": "Jazz",
      "isFavorite": false,
      "isInProject": false,
      "waveform": [
        0.5,
        0.7,
        0.6,
        0.8,
        0.4,
        0.6,
        0.7,
        0.5,
        0.8,
        0.6,
        0.7,
        0.5,
        0.8,
        0.4,
        0.6,
        0.7,
        0.5,
        0.8,
        0.6,
        0.7
      ],
    },
    {
      "id": 6,
      "name": "Latin Fire",
      "bpm": 110,
      "duration": "0:33",
      "genre": "Latin",
      "isFavorite": true,
      "isInProject": false,
      "waveform": [
        0.8,
        0.7,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.9,
        0.7,
        0.8,
        0.5,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.6
      ],
    },
    {
      "id": 7,
      "name": "Trap Beast",
      "bpm": 150,
      "duration": "0:25",
      "genre": "Trap",
      "isFavorite": false,
      "isInProject": true,
      "waveform": [
        0.9,
        0.8,
        0.9,
        0.7,
        0.9,
        0.8,
        0.9,
        0.6,
        0.9,
        0.7,
        0.9,
        0.8,
        0.9,
        0.6,
        0.9,
        0.7,
        0.9,
        0.8,
        0.9,
        0.7
      ],
    },
    {
      "id": 8,
      "name": "House Party",
      "bpm": 125,
      "duration": "0:31",
      "genre": "House",
      "isFavorite": false,
      "isInProject": false,
      "waveform": [
        0.7,
        0.8,
        0.7,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.7,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.7,
        0.9
      ],
    },
    {
      "id": 9,
      "name": "R&B Smooth",
      "bpm": 90,
      "duration": "0:38",
      "genre": "R&B",
      "isFavorite": true,
      "isInProject": false,
      "waveform": [
        0.6,
        0.7,
        0.8,
        0.5,
        0.7,
        0.6,
        0.8,
        0.4,
        0.7,
        0.6,
        0.8,
        0.5,
        0.7,
        0.6,
        0.8,
        0.4,
        0.7,
        0.6,
        0.8,
        0.5
      ],
    },
    {
      "id": 10,
      "name": "Electro Funk",
      "bpm": 115,
      "duration": "0:29",
      "genre": "Electronic",
      "isFavorite": false,
      "isInProject": false,
      "waveform": [
        0.8,
        0.6,
        0.9,
        0.7,
        0.8,
        0.5,
        0.9,
        0.6,
        0.8,
        0.7,
        0.9,
        0.5,
        0.8,
        0.6,
        0.9,
        0.7,
        0.8,
        0.5,
        0.9,
        0.6
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _simulateAudioProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _simulateAudioProgress() {
    if (_isPlaying && _currentPlayingBeat != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _isPlaying) {
          setState(() {
            _currentPosition += 0.1;
            if (_currentPosition >= _totalDuration) {
              _currentPosition = 0.0;
              _isPlaying = false;
              _currentPlayingBeat = null;
              _currentPlayingBeatId = null;
            }
          });
          _simulateAudioProgress();
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBeats {
    List<Map<String, dynamic>> filtered = _allBeats;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((beat) => beat['genre'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((beat) {
        final name = (beat['name'] as String).toLowerCase();
        final genre = (beat['genre'] as String).toLowerCase();
        final bpm = beat['bpm'].toString();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            genre.contains(query) ||
            bpm.contains(query);
      }).toList();
    }

    // Filter by favorites
    if (_showFavoritesOnly) {
      filtered = filtered.where((beat) => beat['isFavorite'] == true).toList();
    }

    return filtered;
  }

  void _onBeatPlay(Map<String, dynamic> beat) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_currentPlayingBeatId == beat['id'].toString() && _isPlaying) {
        _isPlaying = false;
        _currentPosition = 0.0;
      } else {
        _currentPlayingBeat = beat;
        _currentPlayingBeatId = beat['id'].toString();
        _selectedBeatId = beat['id'].toString();
        _isPlaying = true;
        _currentPosition = 0.0;
        _totalDuration = _parseDuration(beat['duration'] ?? '0:30');
      }
    });

    if (_isPlaying) {
      _simulateAudioProgress();
    }
  }

  void _onBeatLongPress(Map<String, dynamic> beat) {
    HapticFeedback.heavyImpact();

    setState(() {
      _selectedBeatId = beat['id'].toString();
    });

    // Show drag feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Drag "${beat['name']}" to timeline to add to project',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.darkTheme.cardColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  double _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return (minutes * 60 + seconds).toDouble();
    }
    return 30.0;
  }

  void _onPlayPause() {
    HapticFeedback.lightImpact();

    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _simulateAudioProgress();
    }
  }

  void _onSeek(double position) {
    setState(() {
      _currentPosition = position;
    });
  }

  void _onTempoMatchToggle() {
    HapticFeedback.lightImpact();

    setState(() {
      _tempoMatchEnabled = !_tempoMatchEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tempoMatchEnabled
              ? 'Tempo matching enabled - beats will sync to project tempo'
              : 'Tempo matching disabled',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.darkTheme.cardColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Beat library updated',
          style: AppTheme.darkTheme.textTheme.bodyMedium,
        ),
        backgroundColor: AppTheme.darkTheme.cardColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Options',
                        style: AppTheme.darkTheme.textTheme.titleLarge,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.textSecondary,
                          size: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show Favorites Only',
                        style: AppTheme.darkTheme.textTheme.bodyLarge,
                      ),
                      Switch(
                        value: _showFavoritesOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _showFavoritesOnly = value;
                          });
                          setState(() {
                            _showFavoritesOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'BPM Range',
                    style: AppTheme.darkTheme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '80 - 150 BPM',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.textPrimary,
              size: 6.w,
            ),
          ),
        ),
        title: Text(
          'Beat Library',
          style: AppTheme.darkTheme.textTheme.titleLarge,
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/track-editor'),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.accentColor,
                size: 6.w,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTap: _showFilterOptions,
          ),
          // Category filters
          CategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          // Beat grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Browse tab
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTheme.accentColor,
                  backgroundColor: AppTheme.darkTheme.cardColor,
                  child: BeatGridWidget(
                    beats: _filteredBeats,
                    currentPlayingBeatId: _currentPlayingBeatId,
                    selectedBeatId: _selectedBeatId,
                    onBeatPlay: _onBeatPlay,
                    onBeatLongPress: _onBeatLongPress,
                    scrollController: _scrollController,
                  ),
                ),
                // Favorites tab
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTheme.accentColor,
                  backgroundColor: AppTheme.darkTheme.cardColor,
                  child: BeatGridWidget(
                    beats: _allBeats
                        .where((beat) => beat['isFavorite'] == true)
                        .toList(),
                    currentPlayingBeatId: _currentPlayingBeatId,
                    selectedBeatId: _selectedBeatId,
                    onBeatPlay: _onBeatPlay,
                    onBeatLongPress: _onBeatLongPress,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: PreviewPlayerWidget(
        currentBeat: _currentPlayingBeat,
        isPlaying: _isPlaying,
        onPlayPause: _onPlayPause,
        tempoMatchEnabled: _tempoMatchEnabled,
        onTempoMatchToggle: _onTempoMatchToggle,
        currentPosition: _currentPosition,
        totalDuration: _totalDuration,
        onSeek: _onSeek,
      ),
    );
  }
}
