// ignore_for_file: deprecated_member_use, camel_case_types, unrelated_type_equality_checks

import 'dart:ui';
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
  bool showBanner = false;
  bool showPlaylist = false;
  bool showBottomPlayer = false;
  int bottomBTNselected = 7;
  bool play = true;
  BoxFit currentBoxFit = BoxFit.fill;
  bool loadPlayer = false;

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
      memCacheWidth: 30,
      imageUrl: widget.playlists[0].logo.trim(),
      width: 30,
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    autoScrollController.dispose();
    focusNodePlayer.dispose();
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
          enableAudioTracks: false,
          enableMute: false,
          enableFullscreen: true,
          enablePlayPause: true,
          enablePlaybackSpeed: false,
          // enableProgressBarDrag: false,
          enableQualities: false,
          enableOverflowMenu: false,
          enableSkips: false,
          enableSubtitles: false,
          playIcon: Icons.play_arrow,
          controlBarColor: Colors.transparent,
          progressBarPlayedColor: Colors.red,
          progressBarBackgroundColor: Colors.white38,
          progressBarHandleColor: Colors.transparent,
          // showControlsOnInitialize: true,
          showControls: false,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.playlists[0].link.trim(),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 12000,
          maxBufferMs: 60000,
          // bufferForPlaybackMs: 1000,
          // bufferForPlaybackAfterRebufferMs: 1000,
        ),
      ),
    );
    await autoScrollController.scrollToIndex(selectIndex,
        // preferPosition: AutoScrollPosition.end,
        duration: const Duration(milliseconds: 300));
    autoScrollController.highlight(selectIndex);
    controller.addEventsListener((event) {
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
        controller.videoPlayerController
            ?.setNetworkDataSource(widget.playlists[nextId].link);
        controller.play();
      }
      if (event.betterPlayerEventType ==
          BetterPlayerEventType.controlsVisible) {
        setState(() {
          showBanner = true;
        });
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.controlsHiddenEnd) {
        setState(() {
          showBanner = false;
        });
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        setState(() {
          play = true;
        });
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        setState(() {
          play = false;
        });
      }
    });
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
          controller.videoPlayerController
              ?.setNetworkDataSource(widget.playlists[selectIndex].link);
          controller.play();
          break;
        case LogicalKeyboardKey.enter:
          controller.videoPlayerController
              ?.setNetworkDataSource(widget.playlists[selectIndex].link);
          controller.play();
          break;
        default:
      }
    } else if (event is RawKeyDownEvent && showBottomPlayer) {
      int i = 0;
      if (bottomBTNselected == 7) {
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
            i = 7;
            setState(() {
              bottomBTNselected = i;
            });
            break;

          case LogicalKeyboardKey.arrowRight:
            i = (bottomBTNselected + 1).clamp(0, 6);
            setState(() {
              bottomBTNselected = i;
            });
            break;
          case LogicalKeyboardKey.arrowLeft:
            i = (bottomBTNselected - 1).clamp(0, 6);
            setState(() {
              bottomBTNselected = i;
            });
            break;
          case LogicalKeyboardKey.enter:
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
                  controller.videoPlayerController
                      ?.setNetworkDataSource(widget.playlists[prewId].link);
                  controller.play();
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
                  controller.videoPlayerController
                      ?.setNetworkDataSource(widget.playlists[nextId].link);
                  controller.play();
                }
                break;
              case 6:
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
          case LogicalKeyboardKey.select:
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
                  controller.videoPlayerController
                      ?.setNetworkDataSource(widget.playlists[prewId].link);
                  controller.play();
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
                  controller.videoPlayerController
                      ?.setNetworkDataSource(widget.playlists[nextId].link);
                  controller.play();
                }
                break;
              case 6:
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
                  setState(() {
                    showBottomPlayer = !showBottomPlayer;
                  });
                },
                child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: BPlayer(controller: controller),
                      // child:
                      //  VlcPlayer(controller: controller, aspectRatio: 16 / 9),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: loadPlayer,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              Visibility(
                visible: !showPlaylist && showBottomPlayer,
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
                                        activeTrackColor: bottomBTNselected == 7
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
              Visibility(
                visible: showPlaylist,
                child: Row(
                  children: [
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.all(8),
                          width: 300,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 87, 87, 87)
                                  .withOpacity(0.8),
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
                                            controller.videoPlayerController
                                                ?.setNetworkDataSource(e.link);
                                            controller.play();
                                          },
                                          child: AutoScrollTag(
                                            key: ValueKey(i),
                                            controller: autoScrollController,
                                            index: i,
                                            child: Container(
                                              color: selectIndex == i
                                                  ? Colors.blueAccent
                                                  : Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  image,
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: FittedBox(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '${e.title} ${e.ep}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          showPlaylist = !showPlaylist;
                        }),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
