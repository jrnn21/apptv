import 'package:apptv02/utility/class.dart';
import 'package:apptv02/utility/parseM3u.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TvProvider extends ChangeNotifier {
  DefaultCacheManager cacheManager = DefaultCacheManager();
  var seen = <String>{};
  bool loading = false;
  double _download = 0.0;
  List<M3UItem> _gt = [];
  List<M3UItem> _playlist = [];
  List<M3UItem> _playlistFilter = [];

  List<M3UItem> get gt => _gt;
  List<M3UItem> get playlist => _playlist;
  List<M3UItem> get playlistFilter => _playlistFilter;
  double get download => _download;

  M3UItem allTv = M3UItem(
      title: '🌏 ប៉ុស្ដិ៍ទាំងអស់',
      link: '',
      groupTitle: '🌏 ប៉ុស្ដិ៍ទាំងអស់',
      logo: '');

  Future<bool> init() async {
    try {
      _download = 0.1;
      notifyListeners();
      List<M3UItem> playlist = await parseM3uFromUrl(
          url:
              'https://onedrive.live.com/download?resid=EA093E3A43CE7C5C%21382&authkey=!ADCtDvdxtFOhjzY');
      List<M3UItem> groupTitles =
          playlist.where((obj) => seen.add(obj.groupTitle)).toList();
      _gt = groupTitles;
      _playlist = playlist;
      _playlistFilter =
          playlist.where((e) => e.groupTitle == _gt[0].groupTitle).toList();
      _download = 100.0;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
