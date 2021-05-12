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

  List<VideoData> allSearchResults = [];

  List<Category> categories = [];

  List<Category> allCategories = [];

  bool showCategoryView = false;

  bool showBackButton = false;

  bool showAllVideos = true;

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
    allSearchResults = await CloudService.getAllVideoData();
    searchResults = allSearchResults;
    _categorizeVideos(allVideos: true);
  }

  _categorizeVideos({bool allVideos = false}) {
    var tempCategories = <Category>[];
    var tempCategoryNames = <String>[];
    for (var videoData in searchResults) {
      tempCategoryNames = tempCategoryNames + videoData.categories;
    }
    var categoryNames = tempCategoryNames.toSet();
    for (var categoryName in categoryNames) {
      var videoList = <VideoData>[];
      var categoryItem = Category(categoryName, videoList);
      for (var videoData in searchResults) {
        if (videoData.categories.contains(categoryName)) {
          categoryItem.videoDataList.add(videoData);
        }
      }
      tempCategories.add(categoryItem);
    }
    if (allVideos) {
      allCategories = tempCategories;
      categories = allCategories;
    } else {
      categories = tempCategories;
    }
  }

  Widget _selectView() {
    var itemsToDisplay;
    if (showCategoryView == true) {
      if (showAllVideos == true) {
        itemsToDisplay = allCategories;
      } else {
        itemsToDisplay = categories;
      }
      return CategoryList(itemsToDisplay, _deleteVideo);
    } else {
      if (showAllVideos == true) {
        itemsToDisplay = allSearchResults;
      } else {
        itemsToDisplay = searchResults;
      }
      return SearchResultsListView(itemsToDisplay, _deleteVideo);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _resetSelectedTerm();
      // showAllVideos = true;
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
                  if (searchResults.isEmpty && showAllVideos == false) {
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

                  return Container(
                    padding: EdgeInsets.only(top: 60),
                    child: Stack(
                      children: [
                        Expanded(child: _selectView()),
                        Align(
                          alignment: Alignment.topRight,
                          child: MaterialButton(
                              color: Colors.white,
                              shape: CircleBorder(),
                              child: Icon(Icons.sync_alt),
                              onPressed: () {
                                setState(() {
                                  showCategoryView = !showCategoryView;
                                });
                              }),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: CircularProgressIndicator(
                            strokeWidth: 7,
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
            leadingActions: [
              FloatingSearchBarAction(
                  showIfOpened: false, child: _showBackButton()),
            ],
            actions: [
              FloatingSearchBarAction(
                showIfOpened: false,
                child: CircularButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _onRefresh();
                  },
                ),
              ),
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
                showBackButton = true;
                showAllVideos = false;
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

  Widget _showBackButton() {
    if (showBackButton) {
      return CircularButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            showAllVideos = true;
            showBackButton = false;
            _resetSelectedTerm();
          });
        },
      );
    } else {
      return Container();
    }
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
        child: ThumbnailGrid(widget.searchResults, widget.onDeleteVideo));
  }
}
