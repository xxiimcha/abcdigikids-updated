import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Story {
  final String title;
  final String videoUrl;

  Story({required this.title, required this.videoUrl});
}

class StorytellingScreen extends StatefulWidget {
  @override
  _StorytellingScreenState createState() => _StorytellingScreenState();
}

class _StorytellingScreenState extends State<StorytellingScreen> {
  final List<Story> stories = [
    Story(
      title: 'The Bear and the Bee',
      videoUrl: 'https://res.cloudinary.com/dhv95tw6x/video/upload/v1/the_bear_and_the_bee_gvesad.mp4',
    ),
    Story(
      title: 'The Fox and the Crow',
      videoUrl: 'https://res.cloudinary.com/dhv95tw6x/video/upload/v1/The_Fox_and_the_Crow_ckrras.mp4',
    ),
    Story(
      title: 'The Dog and His Bone',
      videoUrl: 'https://res.cloudinary.com/dhv95tw6x/video/upload/v1/The_Dog_and_his_Bone_vzm6ax.mp4',
    ),
    Story(
      title: 'The Frightened Lion',
      videoUrl: 'https://res.cloudinary.com/dhv95tw6x/video/upload/v1/The_Frightened_Lion_abcd1234.mp4',
    ),
  ];

  late VideoPlayerController _controller;
  int _currentStoryIndex = 0;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _loadVideo(_currentStoryIndex);
  }

  void _loadVideo(int index) {
    if (_isInitialized) {
      _controller.dispose();
    }

    _controller = VideoPlayerController.network(stories[index].videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _currentStoryIndex = index;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.replay_10, color: Colors.white, size: 32),
                          onPressed: () {
                            final newPosition = _controller.value.position - Duration(seconds: 10);
                            _controller.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
                          },
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 42,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying ? _controller.pause() : _controller.play();
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.forward_10, color: Colors.white, size: 32),
                          onPressed: () {
                            final max = _controller.value.duration;
                            final newPosition = _controller.value.position + Duration(seconds: 10);
                            _controller.seekTo(newPosition < max ? newPosition : max);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            VideoProgressIndicator(_controller, allowScrubbing: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return GestureDetector(
          onTap: () => _loadVideo(index),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_stories, size: 36, color: Colors.purple),
              ),
              title: Text(
                story.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.play_circle_fill, color: Colors.purple, size: 36),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDEFFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isInitialized)
                _buildVideoPlayer()
              else
                Container(
                  height: 200,
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator()),
                ),
              SizedBox(height: 24),
              _buildStoryList(),
            ],
          ),
        ),
      ),
    );
  }
}
