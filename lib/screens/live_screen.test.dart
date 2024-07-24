// ignore_for_file: deprecated_member_use, constant_identifier_names, must_be_immutable
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:apptv02/providers/expire_provider.dart';
import 'package:apptv02/providers/tv_provider.dart';
import 'package:apptv02/utility/class.dart';
import 'package:apptv02/utility/get_image.dart';
import 'package:apptv02/widgets/b_player.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  int itemsPerPage = 17;
  int currentPage = 0;
  late BetterPlayerController controller;
  ScrollController autoScrollController = ScrollController();
  ScrollController autoTvScrollController = ScrollController();
  FocusNode focusNodePlayer = FocusNode();
  bool loading = false;
  List<M3UItem> gt = [];
  List<M3UItem> playlist = [];
  List<M3UItem> playlistFilter = [];
  List<M3UItem> playlistPages = [];
  String gtSelected = '';
  String gtSelectedPlay = '';
  int selectedIndex = 0;
  int selectedIndexPlay = 0;
  bool showPlaylist = false;
  int selectedIndexTv = 0;
  bool selectedTv = true;
  int selectedIndexTvPlayed = 0;
  bool loadPlayer = false;
  int currPagePlay = 0;
  String errorPlay = '';
  bool show = true;
  Timer timer = Timer(const Duration(milliseconds: 200), () {});
  String err = '';

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    autoTvScrollController.addListener(_onScroll);
    parseM3U();
  }

  @override
  void dispose() {
    controller.dispose();
    autoScrollController.dispose();
    autoTvScrollController.removeListener(_onScroll);
    autoTvScrollController.dispose();
    focusNodePlayer.dispose();
    timer.cancel();

    WakelockPlus.disable();
    super.dispose();
  }

  Future<List> parseM3U() async {
    playlist = context.read<TvProvider>().playlist;
    gt = context.read<TvProvider>().gt;
    playlistFilter = context.read<TvProvider>().playlistFilter;
    gtSelected = gt[0].groupTitle;
    gtSelectedPlay = gt[0].groupTitle;
    loadNextPage();
    try {
      controller = BetterPlayerController(
        const BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          fit: BoxFit.fill,
          allowedScreenSleep: false,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          playlist[0].link.trim(),
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 12000, // 30 seconds
            maxBufferMs: 60000, // 30 seconds
            // bufferForPlaybackMs: 1000, // 30 seconds
            // bufferForPlaybackAfterRebufferMs: 1000,
          ),
        ),
      );
      controller.addEventsListener((p0) {
        if (controller.isBuffering()!) {
          loadPlayer = true;
        }
        if (p0.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
          loadPlayer = false;
        }
        // setState(() {
        //   err = p0.betterPlayerEventType.name;
        // });
        if (p0.betterPlayerEventType == BetterPlayerEventType.finished) {
          controller.retryDataSource();
          controller.play();
        }
        if (p0.betterPlayerEventType == BetterPlayerEventType.exception) {
          BetterPlayerEventType.exception.name;
          setState(() {
            errorPlay = 'Error Link Server';
          });
        }
        if (p0.betterPlayerEventType == BetterPlayerEventType.play) {
          setState(() {
            errorPlay = '';
          });
        }
      });

      return [];
    } catch (e) {
      return [];
    }
  }

  void loadNextPage() {
    final int startIndex = currentPage * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    final List<M3UItem> nextPageItems = playlistFilter.sublist(startIndex,
        endIndex < playlistFilter.length ? endIndex : playlistFilter.length);
    setState(() {
      playlistPages.addAll(nextPageItems);
      currentPage++;
    });
  }

  void loadPlayPage(int currPage) {
    final int startIndex = currPage * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    final List<M3UItem> nextPageItems = playlistFilter.sublist(
        0, endIndex < playlistFilter.length ? endIndex : playlistFilter.length);
    setState(() {
      playlistPages.addAll(nextPageItems);
      currentPage = currPage + 1;
    });
  }

  void _onScroll() {
    if (autoTvScrollController.position.pixels >=
            autoTvScrollController.position.maxScrollExtent - 10 &&
        playlistPages.length < playlistFilter.length) {
      loadNextPage();
    }
  }

  void handlePressOnPlayer(RawKeyEvent event) async {
    if (event is RawKeyDownEvent) {
      switch (showPlaylist) {
        case true:
          switch (selectedTv) {
            // playlist of 1 category
            case true:
              int i = 0;
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowUp:
                  i = (selectedIndexTv - 1).clamp(0, playlistFilter.length - 1);
                  if (i > 3) {
                    autoTvScrollController.animateTo((i - 4) * 50,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.linear);
                  }
                  setState(() {
                    selectedIndexTv = i;
                  });
                  break;
                case LogicalKeyboardKey.arrowDown:
                  i = (selectedIndexTv + 1).clamp(0, playlistFilter.length - 1);

                  if (i > 4) {
                    autoTvScrollController.animateTo((i - 4) * 50,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.linear);
                  }
                  setState(() {
                    selectedIndexTv = i;
                  });

                  break;

                case LogicalKeyboardKey.arrowLeft:
                  setState(() {
                    selectedTv = false;
                    selectedIndexTv = 0;
                  });
                  break;
                case LogicalKeyboardKey.select:
                  controller.clearCache();
                  controller.videoPlayerController?.setNetworkDataSource(
                      playlistFilter[selectedIndexTv].link);
                  controller.play();
                  gtSelectedPlay = gtSelected;
                  selectedIndexPlay = selectedIndex;
                  selectedIndexTvPlayed = selectedIndexTv;
                  selectedTv = true;
                  currPagePlay = currentPage - 1;
                  setState(() {});
                  break;
                case LogicalKeyboardKey.enter:
                  controller.clearCache();
                  controller.videoPlayerController?.setNetworkDataSource(
                      playlistFilter[selectedIndexTv].link);
                  controller.play();
                  gtSelectedPlay = gtSelected;
                  selectedIndexPlay = selectedIndex;
                  selectedIndexTvPlayed = selectedIndexTv;
                  selectedTv = true;
                  currPagePlay = currentPage - 1;
                  setState(() {});
                  break;
                default:
              }
              break;
            // category list
            case false:
              int i = 0;
              switch (event.logicalKey) {
                case LogicalKeyboardKey.arrowUp:
                  setState(() {
                    show = false;
                  });
                  i = (selectedIndex - 1).clamp(0, gt.length - 1);
                  setState(() {
                    selectedIndex = i;
                    gtSelected = gt[i].groupTitle;
                    playlistFilter = playlist
                        .where((e) => e.groupTitle == gt[i].groupTitle)
                        .toList();
                    currentPage = 0;
                    playlistPages = [];
                  });
                  loadNextPage();
                  await autoTvScrollController.animateTo(0,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.linear);
                  await autoScrollController.animateTo(selectedIndex * 40,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear);
                  timer.cancel();
                  timer = Timer(const Duration(milliseconds: 200), () {
                    setState(() {
                      show = true;
                    });
                  });

                  break;
                case LogicalKeyboardKey.arrowDown:
                  setState(() {
                    show = false;
                  });
                  i = (selectedIndex + 1).clamp(0, gt.length - 1);
                  setState(() {
                    selectedIndex = i;
                    gtSelected = gt[i].groupTitle;
                    playlistFilter = playlist
                        .where((e) => e.groupTitle == gtSelected)
                        .toList();
                    currentPage = 0;
                    playlistPages = [];
                  });
                  loadNextPage();
                  await autoTvScrollController.animateTo(0,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.linear);
                  await autoScrollController.animateTo(selectedIndex * 40,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear);
                  timer.cancel();
                  timer = Timer(const Duration(milliseconds: 200), () {
                    setState(() {
                      show = true;
                    });
                  });

                  break;
                case LogicalKeyboardKey.arrowRight:
                  setState(() {
                    selectedIndexTv = 0;
                    selectedTv = true;
                  });
                  autoTvScrollController.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear);
                  break;
                case LogicalKeyboardKey.select:
                  setState(() {
                    selectedIndexTv = 0;
                    selectedTv = true;
                  });
                  break;
                case LogicalKeyboardKey.enter:
                  setState(() {
                    selectedIndexTv = 0;
                    selectedTv = true;
                  });
                  break;
                default:
              }
              break;
          }
          break;
        // player
        case false:
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              int se = selectedIndexTvPlayed - 1;
              if (se < 0) {
                break;
              }
              controller.clearCache();
              controller.videoPlayerController
                  ?.setNetworkDataSource(playlistFilter[se].link);
              controller.play();
              setState(() {
                selectedIndexTvPlayed = se;
                selectedIndexTv = se;
                gtSelected = gtSelectedPlay;
                selectedIndex = selectedIndexPlay;
                currPagePlay = currentPage - 1;
              });
              break;
            case LogicalKeyboardKey.arrowDown:
              int se = selectedIndexTv + 1;
              if (se > playlistFilter.length - 1) {
                break;
              }
              controller.clearCache();
              controller.videoPlayerController
                  ?.setNetworkDataSource(playlistFilter[se].link);
              controller.play();
              setState(() {
                selectedIndexTvPlayed = se;
                selectedIndexTv = se;
                gtSelected = gtSelectedPlay;
                selectedIndex = selectedIndexPlay;
                currPagePlay = currentPage - 1;
              });
              break;
            case LogicalKeyboardKey.arrowLeft:
              setState(() {
                selectedIndex = selectedIndexPlay;
                selectedIndexTv = selectedIndexTvPlayed;
                playlistFilter = playlist
                    .where((e) => e.groupTitle == gtSelectedPlay)
                    .toList();
                currentPage = 0;
                playlistPages = [];
              });
              loadPlayPage(currPagePlay);
              Timer timer = Timer(const Duration(seconds: 1), () {});
              timer.cancel();
              timer = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  showPlaylist = true;
                  selectedTv = true;
                });
                autoTvScrollController.animateTo(
                    (selectedIndexTvPlayed - 4) * 50,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear);
                autoScrollController.animateTo(selectedIndex * 40,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear);
              });

              break;
            default:
          }
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TimeExpire timeExpire = context.watch<ExpireProvider>().timer;
    if (timeExpire.expireTime < timeExpire.correntTime) {
      context.read<ExpireProvider>().reStartApp(context);
    }
    return WillPopScope(
      onWillPop: () async {
        if (showPlaylist) {
          setState(() {
            showPlaylist = false;
          });
          return false;
        }
        return true;
      },
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: focusNodePlayer,
        onKey: handlePressOnPlayer,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: loading
              ? const Center(
                  child: SpinKitWaveSpinner(
                    color: Colors.blueAccent,
                    size: 80.0,
                  ),
                )
              : Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          selectedIndex = selectedIndexPlay;
                          gtSelected = gtSelectedPlay;
                          selectedIndexTv = selectedIndexTvPlayed;
                          playlistFilter = playlist
                              .where((e) => e.groupTitle == gtSelectedPlay)
                              .toList();
                          currentPage = 0;
                          playlistPages = [];
                        });
                        loadPlayPage(currPagePlay);
                        Timer timer =
                            Timer(const Duration(milliseconds: 500), () {});
                        timer.cancel();
                        timer = Timer(const Duration(seconds: 1), () {
                          setState(() {
                            showPlaylist = !showPlaylist;
                            selectedTv = true;
                          });
                          autoTvScrollController.animateTo(
                              (selectedIndexTvPlayed - 4) * 50,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linear);
                          autoScrollController.animateTo(selectedIndex * 40,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.linear);
                        });
                      },
                      child: Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: BPlayer(controller: controller),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: errorPlay.isNotEmpty,
                      child: Center(
                        child: Text(
                          errorPlay,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: errorPlay.isEmpty && loadPlayer,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    // Positioned(
                    //     top: 10,
                    //     right: 10,
                    //     child: Text(
                    //       err,
                    //       style: const TextStyle(color: Colors.white),
                    //     )),
                    _playlist(context),
                  ],
                ),
        ),
      ),
    );
  }

  Visibility _playlist(BuildContext context) {
    return Visibility(
      visible: true,
      child: AnimatedContainer(
        transform: Matrix4.translationValues(
            selectedTv && showPlaylist
                ? -240.0
                : showPlaylist
                    ? 0
                    : -557,
            0.0,
            0.0),
        duration: const Duration(milliseconds: 100),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 240,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 27, 27, 27).withOpacity(0.8),
                border: const Border(right: BorderSide(color: Colors.white12)),
              ),
              child: ListView(
                controller: autoScrollController,
                scrollDirection: Axis.vertical,
                children: UnmodifiableListView(
                  [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Image.asset(
                          'images/logolive.png',
                          width: 160,
                        ),
                      ),
                    ),
                    ...gt
                        .asMap()
                        .map((i, e) => MapEntry(
                            i,
                            GestureDetector(
                              onTap: () => setState(() {
                                gtSelected = gt[i].groupTitle;
                                selectedIndex = i;
                                autoScrollController.animateTo(i * 40,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.linear);

                                playlistFilter = playlist
                                    .where((e) => e.groupTitle == gtSelected)
                                    .toList();
                                currentPage = 0;
                                playlistPages = [];
                                setState(() {});
                                loadNextPage();
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                padding: EdgeInsets.only(
                                    left: selectedIndex == i ? 20 : 10,
                                    right: 0,
                                    top: 10,
                                    bottom: 10),
                                decoration: BoxDecoration(
                                  color: selectedIndex == i && !selectedTv
                                      ? const Color.fromARGB(255, 10, 101, 175)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(
                                              selectedIndex == i && !selectedTv
                                                  ? 0.5
                                                  : 0),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: const Offset(
                                          0, 1), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Text(
                                  e.groupTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )))
                        .values,
                    const SizedBox(height: 400),
                  ],
                ),
              ),
            ),
            Container(
              width: 317,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 27, 27, 27).withOpacity(0.8),
                border: const Border(right: BorderSide(color: Colors.white12)),
              ),
              child: ListView(
                controller: autoTvScrollController,
                scrollDirection: Axis.vertical,
                children: UnmodifiableListView(show
                    ? [
                        ...playlistPages
                            .asMap()
                            .map((i, e) => MapEntry(
                                i,
                                TvCom(
                                  autoTvScrollController:
                                      autoTvScrollController,
                                  ontap: () {
                                    controller.videoPlayerController!.refresh();
                                    controller.videoPlayerController
                                        ?.setNetworkDataSource(e.link);
                                    controller.play();
                                    setState(() {
                                      selectedIndexTv = i;
                                      selectedTv = true;
                                      selectedIndexPlay = selectedIndex;
                                      gtSelectedPlay = gtSelected;
                                      selectedIndexTvPlayed = i;
                                      currPagePlay = currentPage - 1;
                                    });

                                    autoTvScrollController.animateTo(
                                        (i - 4) * 50,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.linear);
                                    setState(() {
                                      selectedIndexTv = i;
                                    });
                                  },
                                  i: i,
                                  e: e,
                                  selectedIndexTv: selectedIndexTv,
                                  selectedTv: selectedTv,
                                )))
                            .values,
                        // const SizedBox(height: 400),
                      ]
                    : []),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TvCom extends StatefulWidget {
  TvCom(
      {super.key,
      required this.ontap,
      required this.i,
      required this.e,
      required this.autoTvScrollController,
      required this.selectedIndexTv,
      required this.selectedTv});

  Function() ontap;
  int i;
  M3UItem e;
  ScrollController autoTvScrollController;
  int selectedIndexTv;
  bool selectedTv;

  @override
  State<TvCom> createState() => _TvComState();
}

class _TvComState extends State<TvCom> {
  Timer timer = Timer(const Duration(seconds: 5), () {});
  bool isVisible = false;
  VisibilityDetectorController visibleController =
      VisibilityDetectorController();

  File? image;

  @override
  void dispose() {
    visibleController.forget(ValueKey('v-${widget.e.title}'));
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('v-${widget.e.title}'),
      onVisibilityChanged: (info) async {
        bool isV = info.visibleFraction > 0;
        timer.cancel();
        if (image == null) {
          if (isV) {
            File? img = await getCachedImage(widget.e.logo);
            if (img != null) {
              setState(() {
                image = img;
              });
            } else {
              timer = Timer(const Duration(seconds: 3), () async {
                File? img = await saveImageToCache(widget.e.logo);
                if (img != null) {
                  setState(() {
                    image = img;
                  });
                }
              });
            }
          } else {
            timer.cancel();
            setState(() {
              isVisible = false;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: widget.ontap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.selectedIndexTv == widget.i && widget.selectedTv
                ? const Color.fromARGB(255, 10, 101, 175)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(
                    widget.selectedIndexTv == widget.i && widget.selectedTv
                        ? 0.5
                        : 0),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
                top: 5,
                right: 5,
                bottom: 5,
                left: widget.selectedTv && widget.selectedIndexTv == widget.i
                    ? 20
                    : 0),
            child: Row(
              children: [
                const SizedBox(width: 3),
                Text(
                  "${widget.i + 1}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: image != null
                      ? Image.file(
                          image as File,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4)),
                          child: Center(
                            child: Text(
                              widget.e.title.trim()[0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),

                  // child: isVisible
                  //     ? CachedNetworkImage(
                  //         filterQuality: FilterQuality.low,
                  //         imageUrl: widget.e.logo,
                  //         width: 40,
                  //         height: 40,
                  //         fit: BoxFit.contain,
                  //         placeholder: (context, url) =>
                  //             const SizedBox(height: 40, width: 40),
                  //         errorWidget: (context, url, error) =>
                  //             const SizedBox(height: 40, width: 40),
                  //       )
                  //     : tvImageholder,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.e.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
