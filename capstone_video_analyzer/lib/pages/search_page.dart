import 'dart:io';

import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:capstone_video_analyzer/services/search.dart';
import 'package:capstone_video_analyzer/thumbnail_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';



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

  Future? resultsFuture;

  _getResults(String? query) async {
    if (query == null) return;
    searchResults = await search(query);
  }

  late FloatingSearchBarController controller;

  Future<UploadTask?> uploadFile(PickedFile? file, BuildContext context) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file was selected'),
      ));
      return null;
    }

    User? currentUser = context.read<AuthService>().currentUser;
    //TODO throw proper exception instead?
    if (currentUser == null) return null;

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(currentUser.uid)
        .child('/${path.basename(file.path)}');

    final metadata = SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {'picked-file-path': file.path});

    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  Future<void> handleUploadType(BuildContext context) async {
    PickedFile? file =
        await ImagePicker().getVideo(source: ImageSource.gallery);
    await uploadFile(file, context);
    // UploadTask? task = await uploadFile(file, context);
    // if (task != null) {
    //   setState(() {
    //     _uploadTasks = [..._uploadTasks, task];
    //   });
    // }
  }

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
      floatingActionButton: Container(
      child: FloatingActionButton(
        onPressed: () => handleUploadType(context),
        backgroundColor: Colors.red,
        child: Icon(Icons.file_upload),

      ),
    ),
      body: FloatingSearchBar(
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
          child: FutureBuilder(
            future: resultsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SearchResultsListView(
                  searchResults: searchResults,
                );
              }

              return Container(
                color: Colors.blueGrey,
              );
            },
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
  final List<VideoData> searchResults;

  SearchResultsListView({
    Key? key,
    required this.searchResults,
  }) : super(key: key);

  @override
  _SearchResultsListViewState createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.searchResults == null) {
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
    // TODO replace hardcoded padding below

    return Container(
        color: Colors.blueGrey, 
        child: Padding(
          padding: const EdgeInsets.only(top: 65),
          child: ThumbnailGrid(widget.searchResults),
        ));

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
