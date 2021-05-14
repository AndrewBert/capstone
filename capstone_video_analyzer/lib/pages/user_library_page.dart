import 'package:capstone_video_analyzer/models/category.dart';
import 'package:capstone_video_analyzer/models/video_data.dart';
import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:capstone_video_analyzer/services/cloud_service.dart';
import 'package:capstone_video_analyzer/widgets/category_list.dart';
import 'package:capstone_video_analyzer/widgets/thumbnail_grid.dart';
import 'package:capstone_video_analyzer/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class UserLibraryPage extends StatefulWidget {
  @override
  _UserLibraryPageState createState() => _UserLibraryPageState();
}

class _UserLibraryPageState extends State<UserLibraryPage> {
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
  Future? resultsFuture;
  late FloatingSearchBarController controller;

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

  _addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      _putSearchTermFirst(term);
      return;
    }
    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  _deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  _putSearchTermFirst(String term) {
    _deleteSearchTerm(term);
    _addSearchTerm(term);
  }

  _resetSelectedTerm() {
    selectedTerm = "Search";
  }

  _getResults(String? query) async {
    if (query == null || query.isEmpty) return;
    searchResults = await CloudService.search(query);
    _categorizeVideos();
  }

  _getAllVideoData() async {
    allSearchResults = await CloudService.getAllVideoData();
    searchResults = allSearchResults;
    _categorizeVideos();
  }

  _search(String? query) {
    if (query == null || query.isEmpty) return;
    showAllVideos = false;
    resultsFuture = _getResults(query);
  }

  _categorizeVideos() {
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
    if (showAllVideos) {
      allCategories = tempCategories;
      categories = allCategories;
    } else {
      categories = tempCategories;
    }
  }

  _deleteVideo(String url) {
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
      return ThumbnailGrid(itemsToDisplay, _deleteVideo);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _resetSelectedTerm();
      showBackButton = false;
      resultsFuture = _getAllVideoData();
    });
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: UploadButton(),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Easily search your video catalog the same way you search text documents!',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              ListTile(
                title: Text('Sign Out'),
                onTap: () {
                  context.read<AuthService>().signOut();
                },
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: FloatingSearchBar(
          // margins: EdgeInsets.only(),
          controller: controller,
          body: FutureBuilder(
            future: resultsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (searchResults.isEmpty && showAllVideos == false ||
                    allSearchResults.isEmpty) {
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
              bool blank = query.trim().isEmpty;
              if (blank) return;
              _addSearchTerm(query);
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
                            _addSearchTerm(controller.query);
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
                                      _deleteSearchTerm(term);
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _putSearchTermFirst(term);
                                    selectedTerm = term;
                                    _search(term);
                                    showBackButton = true;
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
    );
  }
}
