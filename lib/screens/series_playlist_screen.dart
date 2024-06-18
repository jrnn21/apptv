// ignore_for_file: deprecated_member_use, camel_case_types, unrelated_type_equality_checks

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:apptv02/providers/expire_provider.dart';
import 'package:apptv02/utility/class.dart';
import 'package:apptv02/widgets/b_player.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class SeriesPlaylistScreen extends StatefulWidget {
  SeriesPlaylistScreen({super.key, required this.playlists});
  List<M3USeriesItem> playlists;

  @override
  State<SeriesPlaylistScreen> createState() => _SeriesPlaylistScreenState();
}

class _SeriesPlaylistScreenState extends State<SeriesPlaylistScreen> {
  late BetterPlayerController controller;
  late CachedNetworkImage image;
  late AutoScrollController autoScrollController;
  NumberFormat formatter = NumberFormat("00");

  FocusNode focusNodePlayer = FocusNode();
  int selectIndex = 0;
  bool showBanner = true;
  bool showPlaylist = false;
  bool showBottomPlayer = false;
  int bottomBTNselected = 3;
  bool play = true;
  BoxFit currentBoxFit = BoxFit.fill;
  bool loadPlayer = true;
  String error = '';
  Timer showBannerTimer =
      Timer.periodic(const Duration(seconds: 3), (timer) {});
  bool showSub = false;
  List<String> subList = [];
  int selectSub = 0;

  @override
  void initState() {
    Wakelock.enable();
    autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    init();
    image = CachedNetworkImage(
      filterQuality: FilterQuality.low,
      imageUrl: widget.playlists[0].logo.trim(),
      width: 30,
      placeholder: (context, url) => const SizedBox(height: 30, width: 30),
      errorWidget: (context, url, error) =>
          const SizedBox(height: 30, width: 30),
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    autoScrollController.dispose();
    focusNodePlayer.dispose();
    showBannerTimer.cancel();
    Wakelock.disable();
    super.dispose();
  }

  init() async {
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: currentBoxFit,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        subtitlesConfiguration:
            const BetterPlayerSubtitlesConfiguration(bottomPadding: 0),
      ),
    );
    controller.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.playlists[0].link.trim(),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 50000,
          maxBufferMs: 100000,
          // bufferForPlaybackMs: 1000,
          // bufferForPlaybackAfterRebufferMs: 1000,
        ),
        videoFormat: widget.playlists[0].link.trim().contains('.m3u8')
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
      ),
    );

    _addSubtitle(widget.playlists[0]);
    controller.addEventsListener(_listener);
    _showBottom();
  }

  _play(M3USeriesItem m) {
    setState(() {
      loadPlayer = true;
      error = '';
    });
    controller.clearCache();
    controller.dispose();
    controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: currentBoxFit,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        subtitlesConfiguration:
            const BetterPlayerSubtitlesConfiguration(bottomPadding: 0),
      ),
    );
    controller.setupDataSource(
      BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        m.link.trim(),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 50000,
          maxBufferMs: 100000,
          // bufferForPlaybackMs: 1000,
          // bufferForPlaybackAfterRebufferMs: 1000,
        ),
        videoFormat: m.link.trim().contains('.m3u8')
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
      ),
    );
    _addSubtitle(m);
    controller.addEventsListener(_listener);
    setState(() {
      showBanner = true;
    });

    _showBottom();
  }

  void _addSubtitle(M3USeriesItem m) {
    subList = [];
    selectSub = 0;

    if (m.subLink0 != '') {
      subList.add(m.subLink0);
    }
    if (m.subLink1 != '') {
      subList.add(m.subLink1);
    }
    if (m.subLink2 != '') {
      subList.add(m.subLink2);
    }
    subList.add('None---None');
    setState(() {});
    initSub(subList[0].toString());
    return;
  }

  void initSub(String subString) {
    String subS = subString.split('---')[0];
    if (subS == 'None') {
      controller.setupSubtitleSource(
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.none,
        ),
      );
      return;
    }
    controller.setupSubtitleSource(
      BetterPlayerSubtitlesSource(
        type: BetterPlayerSubtitlesSourceType.network,
        urls: [subS],
      ),
    );
  }

  _showBottom() {
    showBannerTimer.cancel();
    showBannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        showBanner = false;
      });
    });
  }

  _listener(BetterPlayerEvent event) {
    setState(() {
      loadPlayer = controller.isBuffering()!;
    });

    if (event.betterPlayerEventType == BetterPlayerEventType.finished &&
        widget.playlists.length > selectIndex + 1) {
      int nextId = selectIndex + 1;
      setState(() {
        selectIndex = nextId;
      });
      controller.setControlsVisibility(true);
      _play(widget.playlists[nextId]);
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      setState(() {
        error = '';
        play = true;
      });
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      setState(() {
        play = false;
      });
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      setState(() {
        error = 'Link Server Error...';
      });
    }
  }

  void _changeBoxFit() {
    controller.setOverriddenFit(currentBoxFit);
  }

  void _seekForward(Duration duration) {
    controller.setControlsVisibility(true);
    Duration currentPosition = controller.videoPlayerController!.value.position;
    Duration newPosition = currentPosition + duration;
    controller.seekTo(newPosition);
  }

  void _seekBackward(Duration duration) {
    controller.setControlsVisibility(true);
    Duration currentPosition = controller.videoPlayerController!.value.position;
    Duration newPosition = currentPosition - duration;
    controller.seekTo(newPosition);
  }

  void _handleKeyPress(RawKeyEvent event) async {
    // playlist
    if (event is RawKeyDownEvent && showPlaylist) {
      int i = 0;
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          i = (selectIndex - 1).clamp(0, widget.playlists.length - 1);
          setState(() {
            selectIndex = i;
          });
          await autoScrollController.scrollToIndex(i,
              // preferPosition: AutoScrollPosition.end,
              duration: const Duration(milliseconds: 1));
          autoScrollController.highlight(i);
          break;
        case LogicalKeyboardKey.arrowDown:
          i = (selectIndex + 1).clamp(0, widget.playlists.length - 1);
          setState(() {
            selectIndex = i;
          });
          await autoScrollController.scrollToIndex(i,
              // preferPosition: AutoScrollPosition.end,
              duration: const Duration(milliseconds: 1));
          autoScrollController.highlight(i);
          break;
        case LogicalKeyboardKey.select:
          _play(widget.playlists[selectIndex]);
          break;
        case LogicalKeyboardKey.enter:
          _play(widget.playlists[selectIndex]);
          break;
        default:
      }
    } else if (event is RawKeyDownEvent && showSub) {
      int i = 0;
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          i = (selectSub + 1).clamp(0, subList.length - 1);
          selectSub = i;
          setState(() {});
          break;
        case LogicalKeyboardKey.arrowUp:
          i = (selectSub - 1).clamp(0, subList.length - 1);
          selectSub = i;
          setState(() {});
          break;
        case LogicalKeyboardKey.select || LogicalKeyboardKey.enter:
          initSub(subList[selectSub]);
          setState(() {
            showSub = false;
          });
          break;
        default:
      }
    } else if (event is RawKeyDownEvent && showBottomPlayer) {
      int i = 0;
      if (bottomBTNselected == 8) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowDown:
            i = 3;
            setState(() {
              bottomBTNselected = i;
            });
            break;
          case LogicalKeyboardKey.arrowLeft:
            _seekBackward(const Duration(seconds: 10));
            break;
          case LogicalKeyboardKey.arrowRight:
            _seekForward(const Duration(seconds: 10));
            break;
          default:
        }
      } else {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
            i = 8;
            setState(() {
              bottomBTNselected = i;
            });
            break;

          case LogicalKeyboardKey.arrowRight:
            i = (bottomBTNselected + 1).clamp(0, 7);
            setState(() {
              bottomBTNselected = i;
            });

            break;
          case LogicalKeyboardKey.arrowLeft:
            i = (bottomBTNselected - 1).clamp(0, 7);
            setState(() {
              bottomBTNselected = i;
            });

            break;
          case LogicalKeyboardKey.select || LogicalKeyboardKey.enter:
            switch (bottomBTNselected) {
              case 0:
                setState(() {
                  showBottomPlayer = false;
                  showPlaylist = true;
                  bottomBTNselected = 3;
                });
                await autoScrollController.scrollToIndex(selectIndex,
                    preferPosition: AutoScrollPosition.middle,
                    duration: const Duration(milliseconds: 300));
                autoScrollController.highlight(selectIndex);
                break;
              case 1:
                if (selectIndex > 0) {
                  int prewId = selectIndex - 1;
                  setState(() {
                    selectIndex = prewId;
                  });
                  controller.setControlsVisibility(true);
                  _play(widget.playlists[prewId]);
                }
                break;
              case 2:
                _seekBackward(const Duration(seconds: 10));
                break;
              case 3:
                if (play) {
                  controller.videoPlayerController!.pause();
                  setState(() {
                    play = false;
                  });
                } else {
                  controller.videoPlayerController!.play();
                  setState(() {
                    play = true;
                  });
                }
                break;
              case 4:
                _seekForward(const Duration(seconds: 10));
                break;
              case 5:
                if (widget.playlists.length > selectIndex + 1) {
                  int nextId = selectIndex + 1;
                  setState(() {
                    selectIndex = nextId;
                  });
                  controller.setControlsVisibility(true);
                  _play(widget.playlists[nextId]);
                }
                break;
              case 6:
                setState(() {
                  showSub = !showSub;
                });

                break;
              case 7:
                if (currentBoxFit == BoxFit.contain) {
                  setState(() {
                    currentBoxFit = BoxFit.fill;
                  });
                } else if (currentBoxFit == BoxFit.fill) {
                  setState(() {
                    currentBoxFit = BoxFit.contain;
                  });
                }
                _changeBoxFit();
              default:
            }
            break;
          default:
        }
      }
    } else if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _seekBackward(const Duration(seconds: 10));
          break;
        case LogicalKeyboardKey.arrowRight:
          _seekForward(const Duration(seconds: 10));
          break;
        case LogicalKeyboardKey.arrowUp:
          setState(() {
            showBottomPlayer = true;
          });
          break;
        case LogicalKeyboardKey.enter:
          setState(() {
            showPlaylist = true;
          });
          await autoScrollController.scrollToIndex(selectIndex,
              preferPosition: AutoScrollPosition.middle,
              duration: const Duration(milliseconds: 300));
          autoScrollController.highlight(selectIndex);
          break;
        case LogicalKeyboardKey.select:
          setState(() {
            showPlaylist = true;
          });
          await autoScrollController.scrollToIndex(selectIndex,
              preferPosition: AutoScrollPosition.middle,
              duration: const Duration(milliseconds: 300));
          autoScrollController.highlight(selectIndex);
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
        if (showSub) {
          setState(() {
            showSub = false;
            showBottomPlayer = false;
          });
          return false;
        }
        if (showPlaylist) {
          setState(() {
            showPlaylist = false;
          });
          return false;
        }
        if (showBottomPlayer) {
          setState(() {
            showBottomPlayer = false;
          });
          return false;
        }
        return true;
      },
      child: RawKeyboardListener(
        focusNode: focusNodePlayer,
        onKey: _handleKeyPress,
        autofocus: true,
        child: Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (showPlaylist) {
                    showPlaylist = false;
                    return;
                  }
                  setState(() {
                    showBottomPlayer = !showBottomPlayer;
                    showSub = false;
                  });
                },
                child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: BPlayer(controller: controller),
                  ),
                ),
              ),
              error.isNotEmpty
                  ? Positioned(
                      top: 10,
                      right: 10,
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.white),
                      ))
                  : const SizedBox(),
              Visibility(
                visible: loadPlayer,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              Opacity(
                opacity: showBanner || showBottomPlayer ? 1 : 0,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.playlists[0].logo.trim(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${widget.playlists[selectIndex].title} '
                            '${widget.playlists[selectIndex].ep.trim().length == 1 ? widget.playlists[selectIndex].year : widget.playlists[selectIndex].ep}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.all(8),
                transform: Matrix4.translationValues(
                    showPlaylist ? 0 : -320, 0.0, 0.0),
                width: 300,
                height: double.infinity,
                decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(195, 43, 43, 43).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10)),
                child: SingleChildScrollView(
                  controller: autoScrollController,
                  child: Column(
                    children: [
                      ...widget.playlists.asMap().map((i, e) {
                        return MapEntry(
                          i,
                          ClipRect(
                            child: Material(
                              color: Colors.transparent,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectIndex = i;
                                  });
                                  _play(e);
                                },
                                child: AutoScrollTag(
                                  key: ValueKey(i),
                                  controller: autoScrollController,
                                  index: i,
                                  child: Container(
                                    color: selectIndex == i
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // image,
                                        const SizedBox(width: 10, height: 30),
                                        Expanded(
                                          child: FittedBox(
                                            alignment: Alignment.centerLeft,
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${e.title} ${e.ep}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).values
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 80,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  transform:
                      Matrix4.translationValues(showSub ? 0 : 200, 0.0, 0.0),
                  width: 150,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(195, 43, 43, 43)
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...subList.asMap().map((i, e) {
                        return MapEntry(
                          i,
                          GestureDetector(
                            onTap: () {
                              initSub(e.toString());
                              setState(() {
                                selectSub = i;
                                showSub = false;
                              });
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        alignment: Alignment.centerLeft,
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          e.split('---')[1],
                                          style: TextStyle(
                                              color: selectSub == i
                                                  ? Colors.blueAccent
                                                  : Colors.white,
                                              fontWeight: selectSub == i
                                                  ? FontWeight.w900
                                                  : FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.check,
                                      size: 16,
                                      weight: 4,
                                      color: selectSub == i
                                          ? Colors.blueAccent
                                          : Colors.transparent,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).values
                    ],
                  ),
                ),
              ),
              // bottom play widget
              Visibility(
                visible: showBottomPlayer && !showPlaylist,
                child: Positioned(
                  bottom: 0,
                  child: ClipRect(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [0.4, 0.6, 0.8, 1],
                          colors: [
                            Colors.black54,
                            Colors.black38,
                            Colors.black12,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      // height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          controller.isVideoInitialized() as bool
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: bottomBTNselected == 8
                                            ? Colors.blue[900]
                                            : Colors.red,
                                        inactiveTrackColor:
                                            const Color.fromARGB(
                                                125, 158, 158, 158),
                                        // trackShape: RoundedRectSliderTrackShape(),
                                        trackHeight: 1.0,
                                        thumbColor: Colors.transparent,
                                        secondaryActiveTrackColor: Colors.white,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 0.0,
                                        ),
                                        overlayColor: Colors.red.withAlpha(32),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                          overlayRadius: 10.0,
                                        ),
                                      ),
                                      child: Slider(
                                        value: controller.videoPlayerController!
                                            .value.position.inSeconds
                                            .toDouble(),
                                        min: 0.0,
                                        max: controller.videoPlayerController!
                                            .value.duration!.inSeconds
                                            .toDouble(),
                                        secondaryTrackValue: controller
                                            .videoPlayerController!
                                            .value
                                            .buffered
                                            .last
                                            .end
                                            .inSeconds
                                            .toDouble(),
                                        onChanged: (value) {
                                          controller.seekTo(
                                              Duration(seconds: value.toInt()));
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 10),
                                      child: Row(
                                        children: [
                                          Text(
                                              '${controller.videoPlayerController!.value.position.inHours % 60 == 0 ? "" : "${controller.videoPlayerController!.value.position.inHours % 60}:"}${formatter.format((controller.videoPlayerController!.value.position.inMinutes % 60))}:${formatter.format(controller.videoPlayerController!.value.position.inSeconds % 60)}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                          Text(
                                              ' / ${controller.videoPlayerController!.value.duration!.inHours % 60 == 0 ? "" : "${controller.videoPlayerController!.value.duration!.inHours % 60}:"}${formatter.format((controller.videoPlayerController!.value.duration!.inMinutes % 60))}:${formatter.format(controller.videoPlayerController!.value.duration!.inSeconds % 60)}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Flexible(
                                  child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Material(
                                    borderRadius: BorderRadius.circular(100),
                                    elevation: 1,
                                    color: bottomBTNselected == 0
                                        ? Colors.blue[900]
                                        : Colors.black87,
                                    child: ClipRRect(
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        onTap: () async {
                                          setState(() {
                                            showBottomPlayer = false;
                                            showPlaylist = true;
                                            bottomBTNselected = 3;
                                          });
                                          await Future.delayed(const Duration(
                                              milliseconds: 200));
                                          await autoScrollController
                                              .scrollToIndex(selectIndex,
                                                  preferPosition:
                                                      AutoScrollPosition.middle,
                                                  duration: const Duration(
                                                      milliseconds: 300));
                                          autoScrollController
                                              .highlight(selectIndex);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.list_outlined,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Flexible(
                                flex: 3,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 1
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {},
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.skip_previous_rounded,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 2
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {
                                            _seekBackward(
                                                const Duration(seconds: 10));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.fast_rewind_rounded,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 3
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {
                                            if (play) {
                                              controller.videoPlayerController!
                                                  .pause();
                                              setState(() {
                                                play = false;
                                              });
                                            } else {
                                              controller.videoPlayerController!
                                                  .play();
                                              setState(() {
                                                play = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Icon(
                                              play
                                                  ? Icons.pause_rounded
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 4
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {
                                            _seekForward(
                                                const Duration(seconds: 10));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.fast_forward_rounded,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 5
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {},
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.skip_next_rounded,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 6
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {
                                            setState(() {
                                              showSub = !showSub;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 6),
                                            child: const Text(
                                              'C',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Material(
                                      borderRadius: BorderRadius.circular(100),
                                      elevation: 1,
                                      color: bottomBTNselected == 7
                                          ? Colors.blue[900]
                                          : currentBoxFit == BoxFit.fill
                                              ? Colors.white
                                              : Colors.black87,
                                      child: ClipRRect(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: () {
                                            if (currentBoxFit ==
                                                BoxFit.contain) {
                                              setState(() {
                                                currentBoxFit = BoxFit.fill;
                                              });
                                            } else if (currentBoxFit ==
                                                BoxFit.fill) {
                                              setState(() {
                                                currentBoxFit = BoxFit.contain;
                                              });
                                            }
                                            _changeBoxFit();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            child: Icon(
                                              Icons.screenshot_monitor_rounded,
                                              color:
                                                  currentBoxFit == BoxFit.fill
                                                      ? Colors.black87
                                                      : Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20)
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
