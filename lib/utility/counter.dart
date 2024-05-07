// ignore_for_file: unrelated_type_equality_checks, constant_pattern_never_matches_value_type

import 'package:apptv02/utility/class.dart';

enum Type { cate, ep, all }

int counterSeries({
  required List<M3USeriesItem> list,
  required Type option,
  String? value,
}) {
  switch (option) {
    case Type.cate:
      return list.where((e) => e.groupTitle == value).length;
    case Type.ep:
      return list.where((e) => e.title == value).length;
    case Type.all:
      return list.length;
    default:
      return 0;
  }
}

String counterSeriesByEp({
  required List<M3USeriesItem> list,
  required String value,
}) {
  List<M3USeriesItem> ep = list.where((e) => e.title == value).toList();

  if (ep.where((e) => e.ep.contains('ចប់')).length == 1) {
    return '${ep.length}ចប់';
  } else {
    return ep.length.toString();
  }
}
