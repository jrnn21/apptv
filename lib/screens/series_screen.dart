// ignore_for_file: empty_catches, deprecated_member_use
import 'dart:ui';
import 'package:apptv02/providers/series_provider.dart';
import 'package:apptv02/screens/series_playlist_screen.dart';
import 'package:apptv02/utility/class.dart';
import 'package:apptv02/widgets/series_com.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  int itemsPerPage = 18;
  int currentPage = 0;
  var seen = <String>{};
  List<Cate> gt = [];
  List<M3USeriesItem> allMoviesEp = [];
  List<M3USeriesItem> playlist = [];
  List<M3USeriesItem> playlistFilter = [];
  List<M3USeriesItem> playlistPages = [];
  ScrollController playlistScrollController = ScrollController();
  bool showCate = false;
  bool showCateText = false;
  FocusNode focusNode = FocusScopeNode();
  int selectCate = -1;
  int selectMovie = 0;

  TextStyle styleGT = const TextStyle(
      color: Colors.white,
      fontFamilyFallback: ['radley', 'koulen'],
      fontSize: 14,
      shadows: [
        Shadow(offset: Offset(-1, -1), color: Colors.black),
        Shadow(offset: Offset(1, -1), color: Colors.black),
        Shadow(offset: Offset(1, 1), color: Colors.black),
        Shadow(offset: Offset(-1, 1), color: Colors.black),
      ]);

  @override
  void initState() {
    super.initState();
    playlistScrollController.addListener(_onScroll);
    init();
  }

  @override
  void dispose() {
    playlistScrollController.removeListener(_onScroll);
    playlistScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void init() async {
    gt = context.read<SeriesProvider>().gt;
    allMoviesEp = context.read<SeriesProvider>().allMoviesEp;
    playlist = context.read<SeriesProvider>().playlist;
    playlistFilter = context.read<SeriesProvider>().playlistFilter;
    loadNextPage();
  }

  void loadNextPage() {
    final int startIndex = currentPage * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    final List<M3USeriesItem> nextPageItems = playlistFilter.sublist(startIndex,
        endIndex < playlistFilter.length ? endIndex : playlistFilter.length);
    setState(() {
      playlistPages.addAll(nextPageItems);
      currentPage++;
    });
  }

  void _onScroll() {
    if (playlistScrollController.position.pixels >=
            playlistScrollController.position.maxScrollExtent - 85 &&
        playlistPages.length < playlistFilter.length) {
      loadNextPage();
    }
  }

  void scrollToTop() {
    playlistScrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (showCate == true) {
        handlePressOnCate(event);
      } else {
        handlePressOnMovie(event);
      }
    }
  }

  void handlePressOnMovie(RawKeyEvent event) async {
    int i = 0;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.select:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SeriesPlaylistScreen(
              playlists: allMoviesEp
                  .where((ep) => ep.title == playlistPages[selectMovie].title)
                  .toList(),
            ),
          ),
        );
        break;
      case LogicalKeyboardKey.enter:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SeriesPlaylistScreen(
              playlists: allMoviesEp
                  .where((ep) => ep.title == playlistPages[selectMovie].title)
                  .toList(),
            ),
          ),
        );
        break;
      case LogicalKeyboardKey.arrowRight:
        i = (selectMovie + 1).clamp(0, playlistPages.length - 1);
        int indexFloor = (i / 6).floor();
        double itemHeight = 225.3533333333;
        await playlistScrollController.animateTo(
            indexFloor < 1
                ? 0
                : indexFloor == 1
                    ? 85
                    : (indexFloor * itemHeight) - 140,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear);

        setState(() {
          selectMovie = i;
        });
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (selectMovie % 6 == 0) {
          setState(() {
            showCate = true;
          });
          break;
        }
        i = (selectMovie - 1).clamp(0, playlistPages.length - 1);
        setState(() {
          selectMovie = i;
        });
        break;
      case LogicalKeyboardKey.arrowUp:
        if (selectMovie - 5 > 0) {
          i = (selectMovie - 6).clamp(0, playlistPages.length - 1);
          int indexFloor = (i / 6).floor();
          double itemHeight = 225.3533333333;

          await playlistScrollController.animateTo(
              indexFloor < 1
                  ? 0
                  : indexFloor == 1
                      ? 85
                      : (indexFloor * itemHeight) - 140,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
          setState(() {
            selectMovie = i;
          });
        }

        break;
      case LogicalKeyboardKey.arrowDown:
        i = (selectMovie + 6).clamp(0, playlistPages.length - 1);
        int indexFloor = (i / 6).floor();
        double itemHeight = 225.3533333333;

        await playlistScrollController.animateTo(
            indexFloor < 1
                ? 0
                : indexFloor == 1
                    ? 85
                    : (indexFloor * itemHeight) - 140,
            duration: const Duration(milliseconds: 200),
            curve: Curves.linear);
        setState(() {
          selectMovie = i;
        });
        break;
      default:
    }
  }

  void handlePressOnCate(RawKeyEvent event) async {
    int i = 0;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        i = (selectCate + 1).clamp(-1, gt.length - 1);
        if (i == -1) {
          playlistFilter = playlist;
        } else {
          playlistFilter = playlist
              .where((obj) => obj.groupTitle == gt[i].groupTitle)
              .toList();
        }

        setState(() {
          currentPage = 0;
          playlistPages = [];
          selectCate = i;
          selectMovie = 0;
        });
        loadNextPage();
        scrollToTop();
        break;
      case LogicalKeyboardKey.arrowUp:
        i = (selectCate - 1).clamp(-1, gt.length - 1);
        if (i == -1) {
          playlistFilter = playlist;
        } else {
          playlistFilter = playlist
              .where((obj) => obj.groupTitle == gt[i].groupTitle)
              .toList();
        }
        setState(() {
          currentPage = 0;
          playlistPages = [];
          selectCate = i;
          selectMovie = 0;
        });
        loadNextPage();
        scrollToTop();
        break;

      case LogicalKeyboardKey.arrowRight:
        setState(() {
          showCate = false;
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showCate) {
          setState(() {
            showCate = false;
          });
          return false;
        }
        return true;
      },
      child: RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: onKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/Bannersrb1.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                      top: 17, right: 15, left: 15, bottom: 17),
                  shrinkWrap: true,
                  controller: playlistScrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 500 / 738,
                  ),
                  itemCount: playlistPages.length,
                  itemBuilder: (BuildContext context, int i) {
                    M3USeriesItem e = playlistPages[i];
                    return SeriesCom(
                      ontap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SeriesPlaylistScreen(
                              playlists: allMoviesEp
                                  .where((ep) => ep.title == e.title)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      onselect: () {},
                      allMoviesEp: allMoviesEp,
                      e: e,
                      i: i,
                      selectMovie: selectMovie,
                    );
                  },
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 235,
                transform:
                    Matrix4.translationValues(showCate ? 0 : -235.0, 0.0, 0.0),
                height: MediaQuery.of(context).size.height,
                color: showCate
                    ? const Color.fromARGB(160, 0, 0, 0)
                    : Colors.transparent,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: selectCate == -1
                                          ? Colors.blueAccent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        playlistFilter = playlist;
                                        setState(() {
                                          currentPage = 0;
                                          playlistPages = [];
                                          selectCate = -1;
                                          selectMovie = 0;
                                        });
                                        loadNextPage();
                                        scrollToTop();
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: EdgeInsets.only(
                                            left: selectCate == -1 ? 15 : 8,
                                            top: 10,
                                            bottom: 10),
                                        width: double.infinity,
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('🌏 រឿងទាំងអស់',
                                                style: styleGT),
                                          ],
                                        ),
                                      )),
                                ),
                                ...gt
                                    .asMap()
                                    .map((i, e) => MapEntry(
                                          i,
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            decoration: BoxDecoration(
                                                color: selectCate == i
                                                    ? Colors.blueAccent
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  playlistFilter = playlist
                                                      .where((obj) =>
                                                          obj.groupTitle ==
                                                          e.groupTitle)
                                                      .toList();
                                                  setState(() {
                                                    currentPage = 0;
                                                    playlistPages = [];
                                                    selectCate = i;
                                                    selectMovie = 0;
                                                  });
                                                  loadNextPage();
                                                  scrollToTop();
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  padding: EdgeInsets.only(
                                                      left: selectCate == i
                                                          ? 15
                                                          : 8,
                                                      top: 10,
                                                      bottom: 10),
                                                  width: double.infinity,
                                                  child: Flex(
                                                    direction: Axis.horizontal,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(e.groupTitle,
                                                          style: styleGT),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        ))
                                    .values
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
