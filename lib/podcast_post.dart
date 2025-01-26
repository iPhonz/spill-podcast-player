import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PodcastPost extends StatefulWidget {
  final String feedUrl;
  
  const PodcastPost({
    Key? key,
    required this.feedUrl,
  }) : super(key: key);

  @override
  _PodcastPostState createState() => _PodcastPostState();
}

class _PodcastPostState extends State<PodcastPost> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  List<PodcastEpisode> episodes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _loadFeed() async {
    try {
      final response = await http.get(Uri.parse(widget.feedUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          episodes = (data['items'] as List)
              .map((item) => PodcastEpisode.fromJson(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading feed: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (episodes.isNotEmpty)
              _buildEpisodeCard(episodes[0])
            else
              const Text('No episodes available',
                  style: TextStyle(color: Colors.white70))
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeCard(PodcastEpisode episode) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(episode.thumbnail),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode metadata at the top
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(episode.thumbnail),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        episode.pubDate,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  episode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            
            // Description and controls at the bottom
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_circle : Icons.play_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () => _handlePlayPause(episode.audioUrl),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPlaying)
                          const Text(
                            'Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {/* Implement share */},
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white),
                          onPressed: () {/* Implement comments */},
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlayPause(String audioUrl) async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class PodcastEpisode {
  final String title;
  final String description;
  final String audioUrl;
  final String thumbnail;
  final String pubDate;

  PodcastEpisode({
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.thumbnail,
    required this.pubDate,
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['enclosure']?['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      pubDate: json['published'] ?? '',
    );
  }
}