import 'package:capstone_video_analyzer/services/search.dart';
import 'package:capstone_video_analyzer/thumbnail_widgets.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  Future<List<VideoData>>? searchResults;

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

  Future<List<VideoData>> getSearchResults(String q) async{
    return await search(q);
  }

  late FloatingSearchBarController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingSearchBar(
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
          child: SearchResultsListView(
            searchTerm: selectedTerm,
          ),
        ),
        transition: CircularFloatingSearchBarTransition(),
        physics: BouncingScrollPhysics(),
        title: Text(
          selectedTerm ?? 'The Search App',
          style: Theme.of(context).textTheme.headline6,
        ),
        hint: 'Search and find out...',
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
            searchResults = getSearchResults(query);
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
    );
  }
}

class SearchResultsListView extends StatefulWidget {
  final String? searchTerm;

  SearchResultsListView({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  _SearchResultsListViewState createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  Future? searchFuture;

  List<VideoData> searchResults = [];

  // search(String? query) async {
  //   if (query == null) return;
  //   final HttpsCallable callable =
  //       FirebaseFunctions.instance.httpsCallable('search');
  //   // ..timeout = const Duration(seconds: 60);
  //   try {
  //     final HttpsCallableResult result = await callable.call(
  //       <String, dynamic>{'text': query},
  //     );
  //     final List<VideoData> response =
  //         result.data['hits'].map<VideoData>((hit) {
  //       bool timestampGuess =
  //           hit["timestampGuess"] == null ? false : hit["timestampGuess"];
  //       return VideoData(hit["filepath"], hit["thumbnail"], hit["video"],
  //           hit["timestamp"], timestampGuess, hit["entities"]);
  //     }).toList();
  //     searchResults = response;
  //   } catch (err) {
  //     print('Error in search! $err');
  //     return [];
  //   }
  // }

  //TODO search method is not getting hit because it is not called on rebuild.
  //initState is only called when the widget loads
  //Maybe i can ahve it return a new searchresultslistview every time a search is submitted

  @override
  void initState() {
    super.initState();
    searchFuture = search(widget.searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchTerm == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
            ),
            Text(
              'Start searching',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      );
    }

    // final fsb = FloatingSearchBar.of(context);

    return FutureBuilder(
      future: searchFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Container(
            color: Colors.blueGrey, 
            child: ThumbnailGrid(searchResults));
      },
    );

    // return ListView(
    //   padding: EdgeInsets.only(
    //       top: fsb!.widget.height * 2),
    //   children: List.generate(
    //     50,
    //     (index) => ListTile(
    //       title: Text('$searchTerm search result'),
    //       subtitle: Text(index.toString()),
    //     ),
    //   ),
    // );
  }
}
