# SPILL Podcast Player

A Flutter widget that implements a podcast player matching SPILL's feed UI style.

## Features

- Displays podcast episodes in a visually appealing card format
- Shows episode artwork as background with gradient overlay
- Supports audio streaming and playback controls
- Matches SPILL's dark theme and UI patterns
- Auto-loads episodes from RSS feeds
- Responsive layout with proper text contrast

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  spill_podcast_player:
    git:
      url: https://github.com/iphonz/spill-podcast-player.git
```

## Usage

```dart
import 'package:spill_podcast_player/podcast_post.dart';

// In your widget tree:
PodcastPost(
  feedUrl: 'YOUR_RSS_FEED_URL',
)
```

## Dependencies

- just_audio: ^0.9.34
- http: ^1.1.0

## Contributing

Feel free to contribute to this project by opening issues or submitting pull requests.

## License

MIT License - see the [LICENSE](LICENSE) file for details