import 'package:capstone_video_analyzer/models/category.dart';
import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:capstone_video_analyzer/services/cloud_service.dart';
import 'package:capstone_video_analyzer/thumbnail_widgets.dart';
import 'package:capstone_video_analyzer/widgets/category_list.dart';
import 'package:capstone_video_analyzer/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const historyLength = 5;

  List<String> _searchHistory = [];

  late List<String> filteredSearchHistory;

  String? selectedTerm;

  List<VideoData> searchResults = [];

  List<Category> categories = [];

  var categoryView = false;

  List<String> filterSearchTerms({
    required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }

    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  void _resetSelectedTerm() {
    selectedTerm = "Search";
  }

  Future? resultsFuture;

  _getResults(String? query) async {
    if (query == null || query.isEmpty) return;
    searchResults = await CloudService.search(query);
    _categorizeVideos();
  }

  _getAllVideoData() async {
    searchResults = await CloudService.getAllVideoData();
    _categorizeVideos();
  }

  _categorizeVideos() {
    categories = [];
    var temp = <String>[];
    for (var videoData in searchResults) {
      temp = temp + videoData.categories;
    }
    var categoryNames = temp.toSet();
    for (var categoryName in categoryNames) {
      var videoList = <VideoData>[];
      var categoryItem = Category(categoryName, videoList);
      for (var videoData in searchResults) {
        if (videoData.categories.contains(categoryName)) {
          categoryItem.videoDataList.add(videoData);
        }
      }
      categories.add(categoryItem);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _resetSelectedTerm();
      resultsFuture = _getAllVideoData();
    });
  }

  void _deleteVideo(String url) {
    var videoDataList = searchResults;
    for (var i = 0; i < videoDataList.length; i++) {
      var videoData = videoDataList[i];
      if (url == videoData.videoUrl) {
        setState(() {
          videoDataList.removeAt(i);
          _categorizeVideos();
          CloudService.deleteVideoFromCloud(videoData.filename);
        });
        break;
      }
    }
  }

  late FloatingSearchBarController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
    resultsFuture = _getAllVideoData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: showFab ? UploadButton() : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FloatingSearchBar(
            // margins: EdgeInsets.only(),
            controller: controller,
            body: FutureBuilder(
              future: resultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (searchResults.isEmpty) {
                    return Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 64,
                            ),
                            Center(
                              child: Text(
                                'No videos found',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  if (categoryView == true) {
                    return CategoryList(categories, _deleteVideo);
                  } else {
                    return SearchResultsListView(searchResults, _deleteVideo);
                  }
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.grey,
                            strokeWidth: 10,
                          ),
                        ),
                        Container(
                          child: Text("Loading videos..."),
                        )
                      ],
                    ),
                  );
                }

                return Center(
                  child: Container(
                    color: Colors.red,
                    child: Text('Something went wrong'),
                  ),
                );
              },
            ),
            transition: CircularFloatingSearchBarTransition(),
            physics: BouncingScrollPhysics(),
            title: Text(
              selectedTerm ?? 'Search',
              style: Theme.of(context).textTheme.headline6,
            ),
            hint: 'Search for a video...',
            actions: [
              FloatingSearchBarAction.searchToClear(),
            ],
            // onQueryChanged: (query) {
            //   setState(() {
            //     filteredSearchHistory = filterSearchTerms(filter: query);
            //   });
            // },
            onSubmitted: (query) {
              setState(() {
                addSearchTerm(query);
                selectedTerm = query;
                resultsFuture = _getResults(query);
              });
              controller.close();
            },
            builder: (context, transition) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  child: Builder(
                    builder: (context) {
                      if (filteredSearchHistory.isEmpty &&
                          controller.query.isEmpty) {
                        return Container(
                          height: 56,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Start searching',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        );
                      } else if (filteredSearchHistory.isEmpty) {
                        return ListTile(
                          title: Text(controller.query),
                          leading: const Icon(Icons.search),
                          onTap: () {
                            setState(() {
                              addSearchTerm(controller.query);
                              selectedTerm = controller.query;
                            });
                            controller.close();
                          },
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredSearchHistory
                              .map(
                                (term) => ListTile(
                                  title: Text(
                                    term,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: const Icon(Icons.history),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        deleteSearchTerm(term);
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    setState(() {
                                      putSearchTermFirst(term);
                                      selectedTerm = term;
                                      resultsFuture = _getResults(selectedTerm);
                                    });
                                    controller.close();
                                  },
                                ),
                              )
                              .toList(),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SearchResultsListView extends StatefulWidget {
  final List<VideoData> searchResults;
  final Function(String) onDeleteVideo;

  SearchResultsListView(this.searchResults, this.onDeleteVideo);

  @override
  _SearchResultsListViewState createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  @override
  Widget build(BuildContext context) {
    // final fsb = FloatingSearchBar.of(context);

    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ThumbnailGrid(widget.searchResults, widget.onDeleteVideo),
        ));
  }
}
