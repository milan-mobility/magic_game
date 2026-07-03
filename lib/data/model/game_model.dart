class GameModel {
  Games? featuredBanner;
  List<Sections>? sections;

  GameModel({this.featuredBanner, this.sections});

  GameModel.fromJson(Map<String, dynamic> json) {
    featuredBanner = json['featuredBanner'] != null
        ? new Games.fromJson(json['featuredBanner'])
        : null;
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(new Sections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (featuredBanner != null) {
      data['featuredBanner'] = featuredBanner!.toJson();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Games {
  int? id;
  String? name;
  String? image;
  String? gameurl;
  String? category;
  bool? offlineAvailable;
  String? orientation;
  String? badge;
  String? buttonText;
  String? action;
  String? desc;
  String? interstitialid;
  String? rewardid;

  Games({
    this.id,
    this.name,
    this.image,
    this.gameurl,
    this.category,
    this.offlineAvailable,
    this.orientation,
    this.badge,
    this.buttonText,
    this.action,
    this.desc,
    this.interstitialid,
    this.rewardid,
  });

  Games.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    gameurl = json['gameurl'];
    category = json['category'];
    offlineAvailable = json['offlineAvailable'];
    orientation = json['Orientation'];
    badge = json['badge'];
    buttonText = json['buttonText'];
    action = json['action'];
    desc = json['desc'];
    interstitialid = json['interstitialid'];
    rewardid = json['rewardid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['gameurl'] = gameurl;
    data['category'] = category;
    data['offlineAvailable'] = offlineAvailable;
    data['Orientation'] = orientation;
    data['badge'] = badge;
    data['buttonText'] = buttonText;
    data['action'] = action;
    data['desc'] = desc;
    data['interstitialid'] = interstitialid;
    data['rewardid'] = rewardid;
    return data;
  }
}

class Sections {
  String? id;
  String? title;
  String? subtitle;
  String? description;
  String? type;
  List<Games>? games;

  Sections({
    this.id,
    this.title,
    this.subtitle,
    this.description,
    this.type,
    this.games,
  });

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    subtitle = json['subtitle'];
    description = json['description'];
    type = json['type'];
    if (json['games'] != null) {
      games = <Games>[];
      json['games'].forEach((v) {
        games!.add(new Games.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['description'] = description;
    data['type'] = type;
    if (games != null) {
      data['games'] = games!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
