// ignore_for_file: file_names
import 'dart:convert';
import 'package:apptv02/utility/class.dart';
import 'package:http/http.dart' as http;

Future<List<M3USeriesItem>> parseM3uSeriesFromUrl({required String url}) async {
  try {
    final List<M3USeriesItem> playlist = [];
    final m3uContent = (await http.get(Uri.parse(url)));

    List<String> lines =
        utf8.decode(m3uContent.bodyBytes).toString().split('#EXTINF:-1 ');

    lines.removeAt(0);

    for (String line in lines) {
      if (line.isNotEmpty && !line.startsWith('#')) {
        List<String> splitResult = line
            .split('tvg-id="" tvg-name="')
            .expand((str) => str.split('" tvg-logo="'))
            .expand((str) => str.split('" group-title="'))
            .expand((str) => str.split('",'))
            .expand((str) => str.split(','))
            .expand((str) => str.split('\n'))
            .toList();
        // print(splitResult);
        // // Create M3USeriesItem object and add to the playlist

        String logo = splitResult[2];
        String groupTitle = splitResult[3];
        String title = splitResult[4];
        int year = int.parse(splitResult[5]);
        int date = int.parse(splitResult[6]);
        String ep = splitResult[7];
        String link = splitResult[8].trim();
        String subLink0 = splitResult.length > 9 ? splitResult[9].trim() : '';
        String subLink1 = splitResult.length > 10 ? splitResult[10].trim() : '';
        String subLink2 = splitResult.length > 11 ? splitResult[11].trim() : '';
        // Create M3USeriesItem object and add to playlistFilter list

        playlist.add(
          M3USeriesItem(
            title: title,
            link: link,
            groupTitle: groupTitle,
            logo: logo,
            ep: ep,
            year: year,
            date: date,
            subLink0: subLink0,
            subLink1: subLink1,
            subLink2: subLink2,
          ),
        );
      }
    }
    return playlist;
  } catch (e) {
    return [];
  }
}
