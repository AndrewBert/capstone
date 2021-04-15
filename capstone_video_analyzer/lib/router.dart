import 'package:capstone_video_analyzer/constants.dart';
import 'package:capstone_video_analyzer/gallery_page.dart';
import 'package:capstone_video_analyzer/main.dart';
import 'package:capstone_video_analyzer/search_page.dart';
import 'package:capstone_video_analyzer/video_player_arguments.dart';
import 'package:capstone_video_analyzer/video_player_page.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authenticationRoute:
        return MaterialPageRoute(builder: (_) => AuthenticationWrapper());
      case galleryRoute:
        return MaterialPageRoute(builder: (_) => GalleryPage());
      case searchRoute:
        return MaterialPageRoute(builder: (_) => SearchPage());
      case videoPlayerRoute: {
        var arguments = settings.arguments as VideoPlayerPageArguments;
        return MaterialPageRoute(builder: (_) => VideoPlayerPage(arguments.videoUrl, arguments.title));
      }        
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
