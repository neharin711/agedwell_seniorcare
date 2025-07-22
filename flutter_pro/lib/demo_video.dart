import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'shared/widgets/gradient_background.dart';

class DemoVideo extends StatefulWidget {
  static const String routeName = '/HomePageIndividual';
  const DemoVideo({Key? key}) : super(key: key);

  @override
  State<DemoVideo> createState() => _DemoVideoState();
}

class _DemoVideoState extends State<DemoVideo> {
  @override
  void initState() {
    super.initState();
    _loadMediaData();
  }

  List<String> mediaUrls = [];
  List<String> img = [];

  Future<void> _loadMediaData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      print("IP Address: $ip");
      String categoryUrl = "$ip/api/demo_video";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        String status = jsonData['status'].toString();

        if (status == "true" && jsonData['data'] != null) {
          List<dynamic> dataList = jsonData['data'];
          setState(() {
            mediaUrls = dataList.map((item) => item['video'].toString()).where((url) => url.toLowerCase().contains('.mp4')).toList();
            img = mediaUrls.map((url) {
              String fullUrl = '$ip/${Uri.encodeComponent(url)}';
              return fullUrl;
            }).toList();
          });
        } else {
          print("API returned an error status or no data.");
        }
      } else {
        print("Failed to fetch data. Status code: ${data.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Demo Clip'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            const UniDirectionalBackground(),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 40),
                  Image.asset(
                    "assets/demo.png",
                    height: 300.h,
                    width: double.infinity,

                  ),
                  SizedBox(height: 30.h),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: img.length,
                      itemBuilder: (context, index) {
                        return DemoContent(
                          mediaUrl: img[index],
                          isVideo: true,
                          heroTag: 'media$index',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoContent extends StatelessWidget {
  final String mediaUrl;
  final bool isVideo;
  final String heroTag;

  const DemoContent({
    Key? key,
    required this.mediaUrl,
    required this.isVideo,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(videoUrl: mediaUrl),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
        child: Hero(
          tag: heroTag,
          child: Container(
            height: 300.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.3), offset: const Offset(2, 3)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: VideoPart(videoUrl: mediaUrl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoPart extends StatelessWidget {
  const VideoPart({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    double thirdScreenHeight = MediaQuery.of(context).size.height / 3;

    return Container(
      height: thirdScreenHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFC7E2E4),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Video Player'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
