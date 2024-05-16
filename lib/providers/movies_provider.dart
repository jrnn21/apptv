// ignore_for_file: empty_catches

import 'dart:convert';

import 'package:apptv02/utility/class.dart';
import 'package:apptv02/utility/parseM3uSeries.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier {
  var seen = <String>{};
  bool loading = false;
  double _download = 0.0;
  List<Cate> _gt = [];
  List<M3USeriesItem> _allMoviesEp = [];
  List<M3USeriesItem> _playlist = [];
  List<M3USeriesItem> _playlistFilter = [];

  List<Cate> get gt => _gt;
  List<M3USeriesItem> get allMoviesEp => _allMoviesEp;
  List<M3USeriesItem> get playlist => _playlist;
  List<M3USeriesItem> get playlistFilter => _playlistFilter;
  double get download => _download;

  Future<bool> init(String link) async {
    try {
      List<Cate> cates = [];
      List<M3USeriesItem> series = [];
      List<M3USeriesItem> seriesEp = [];
      List<M3USeriesItem> movies = [];
      _download = 1.0;
      notifyListeners();
      final m3uContent = (await http.get(Uri.parse(link)));
      List<String> cates0 =
          utf8.decode(m3uContent.bodyBytes).toString().split('\n');
      int i = 1;
      for (String line in cates0) {
        if (line.isNotEmpty && !line.startsWith('#')) {
          List<String> splitResult = line.split(',');
          // String groupTitle = splitResult[0].trim();
          String link = splitResult[1].trim();
          // Create M3USeriesItem object and add to playlistFilter list

          List<M3USeriesItem> series0 = await parseM3uSeriesFromUrl(url: link);
          seriesEp = [...seriesEp, ...series0];
          List<M3USeriesItem> movies0 =
              series0.where((obj) => seen.add(obj.title)).toList();
          series = [...series, ...series0];
          movies = [...movies, ...movies0];

          notifyListeners();
        }
        _download = i * 100 / cates0.length;
        i++;
      }

      List<M3USeriesItem> mByCates =
          movies.where((obj) => seen.add(obj.groupTitle)).toList();
      for (M3USeriesItem cate in mByCates) {
        cates.add(Cate(
          groupTitle: cate.groupTitle,
          link: cate.link,
        ));
      }
      movies.sort((a, b) => b.date.compareTo(a.date));
      series.sort((a, b) => b.date.compareTo(a.date));
      _gt = cates;
      _allMoviesEp = seriesEp;
      _playlist = movies;
      _playlistFilter = movies;
      notifyListeners();
      loading = false;
      return true;
    } catch (e) {
      return false;
    }
  }
}
