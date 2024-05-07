class M3UItem {
  String title;
  String link;
  String groupTitle;
  String logo;
  M3UItem({
    required this.title,
    required this.link,
    required this.groupTitle,
    required this.logo,
  });
}

class M3USeriesItem {
  String title;
  String link;
  String groupTitle;
  String logo;
  String ep;
  int year;
  int date;
  M3USeriesItem({
    required this.title,
    required this.link,
    required this.groupTitle,
    required this.logo,
    required this.ep,
    required this.year,
    required this.date,
  });
}

class Cate {
  String groupTitle;
  String link;

  Cate({
    required this.groupTitle,
    required this.link,
  });
}
