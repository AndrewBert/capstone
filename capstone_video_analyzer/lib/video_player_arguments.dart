class VideoPlayerPageArguments {
  final String videoUrl;
  final String labels;
  final Function(String) onDeleteVideo;
  

  VideoPlayerPageArguments(this.videoUrl, this.labels, this.onDeleteVideo);
}
