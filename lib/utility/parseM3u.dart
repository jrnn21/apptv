// ignore_for_file: file_names
import 'dart:convert';

import 'package:apptv02/utility/class.dart';
import 'package:http/http.dart' as http;

Future<List<M3UItem>> parseM3uFromUrl({required String url}) async {
  final List<M3UItem> playlist = [];
  final m3uContent = (await http.get(Uri.parse(url)));
  // Split content by lines
  List<String> lines =
      utf8.decode(m3uContent.bodyBytes).toString().split('#EXTINF:0 ');
  lines.removeAt(0);
  for (String line in lines) {
    if (line.isNotEmpty && !line.startsWith('#')) {
      List<String> splitResult = line
          .split('tvg-country="')
          .expand((str) => str.split('" tvg-logo="'))
          .expand((str) => str.split('" group-title="'))
          .expand((str) => str.split('",'))
          .expand((str) => str.split('\n'))
          .toList();
      // print(splitResult);
      // // Create M3UItem object and add to the playlist
      String logo = splitResult[2];
      String groupTitle = splitResult[3];
      String title = splitResult[4];
      String link = splitResult[5].trim();
      // Create M3UItem object and add to playlistFilter list

      playlist.add(M3UItem(
        title: title,
        link: link,
        groupTitle: groupTitle,
        logo: logo,
      ));
    }
  }
  return playlist;
}
