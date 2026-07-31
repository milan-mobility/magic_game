class GameModel {
  List<Gamecategory>? gamecategory;
  List<Featurebannerbagde>? featurebannerbagde;
  Sectiontype? sectiontype;
  List<Featuredbanner>? featuredbanner;
  List<Games>? games;
  List<Sections>? sections;

  GameModel({
    this.gamecategory,
    this.featurebannerbagde,
    this.sectiontype,
    this.featuredbanner,
    this.games,
    this.sections,
  });

  GameModel.fromJson(Map<String, dynamic> json) {
    if (json['gamecategory'] != null) {
      gamecategory = <Gamecategory>[];
      json['gamecategory'].forEach((v) {
        gamecategory!.add(Gamecategory.fromJson(v));
      });
    }
    if (json['featurebannerbagde'] != null) {
      featurebannerbagde = <Featurebannerbagde>[];
      json['featurebannerbagde'].forEach((v) {
        featurebannerbagde!.add(Featurebannerbagde.fromJson(v));
      });
    }
    sectiontype = json['sectiontype'] != null
        ? Sectiontype.fromJson(json['sectiontype'])
        : null;
    if (json['featuredbanner'] != null) {
      featuredbanner = <Featuredbanner>[];
      json['featuredbanner'].forEach((v) {
        featuredbanner!.add(Featuredbanner.fromJson(v));
      });
    }
    if (json['games'] != null) {
      games = <Games>[];
      json['games'].forEach((v) {
        games!.add(Games.fromJson(v));
      });
    }
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (gamecategory != null) {
      data['gamecategory'] = gamecategory!.map((v) => v.toJson()).toList();
    }
    if (featurebannerbagde != null) {
      data['featurebannerbagde'] = featurebannerbagde!
          .map((v) => v.toJson())
          .toList();
    }
    if (sectiontype != null) {
      data['sectiontype'] = sectiontype!.toJson();
    }
    if (featuredbanner != null) {
      data['featuredbanner'] = featuredbanner!.map((v) => v.toJson()).toList();
    }
    if (games != null) {
      data['games'] = games!.map((v) => v.toJson()).toList();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gamecategory {
  String? id;
  String? name;
  String? url;

  Gamecategory({this.id, this.name, this.url});

  Gamecategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class Featurebannerbagde {
  int? id;
  String? name;
  String? url;

  Featurebannerbagde({this.id, this.name, this.url});

  Featurebannerbagde.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class Sectiontype {
  String? s201;
  String? s202;
  String? s203;
  String? s204;
  String? s205;
  String? s206;

  Sectiontype({
    this.s201,
    this.s202,
    this.s203,
    this.s204,
    this.s205,
    this.s206,
  });

  Sectiontype.fromJson(Map<String, dynamic> json) {
    s201 = json['201'];
    s202 = json['202'];
    s203 = json['203'];
    s204 = json['204'];
    s205 = json['205'];
    s206 = json['206'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['201'] = s201;
    data['202'] = s202;
    data['203'] = s203;
    data['204'] = s204;
    data['205'] = s205;
    data['206'] = s206;
    return data;
  }

  String? labelForType(final String? type) {
    switch (type) {
      case '201':
        return s201;
      case '202':
        return s202;
      case '203':
        return s203;
      case '204':
        return s204;
      case '205':
        return s205;
      case '206':
        return s206;
      default:
        return null;
    }
  }
}

class Featuredbanner {
  int? id;
  String? name;
  String? shortname;
  String? banner;
  String? icon;
  String? gameurl;
  String? storeurl;
  String? category;
  String? orientation;
  String? rating;
  bool? subscription;
  bool? play;
  bool? install;
  String? interstitialid;
  String? rewardid;
  String? keyword;
  String? badgeid;
  String? categoryName;
  String? tag;
  String? desc;

  Featuredbanner({
    this.id,
    this.name,
    this.shortname,
    this.banner,
    this.icon,
    this.gameurl,
    this.storeurl,
    this.category,
    this.orientation,
    this.rating,
    this.subscription,
    this.play,
    this.install,
    this.interstitialid,
    this.rewardid,
    this.keyword,
    this.badgeid,
    this.categoryName,
    this.tag,
    this.desc,
  });

  Featuredbanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortname = json['shortname'];
    banner = json['banner'];
    icon = json['icon'];
    gameurl = json['gameurl'];
    storeurl = json['storeurl'];
    category = json['category'];
    orientation = json['orientation'];
    rating = json['rating'];
    subscription = json['subscription'];
    play = json['play'];
    install = json['install'];
    interstitialid = json['interstitialid'];
    rewardid = json['rewardid'];
    keyword = json['keyword'];
    badgeid = json['badgeid'];
    categoryName = json['categoryName'];
    tag = json['tag'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['shortname'] = shortname;
    data['banner'] = banner;
    data['icon'] = icon;
    data['gameurl'] = gameurl;
    data['storeurl'] = storeurl;
    data['category'] = category;
    data['orientation'] = orientation;
    data['rating'] = rating;
    data['subscription'] = subscription;
    data['play'] = play;
    data['install'] = install;
    data['interstitialid'] = interstitialid;
    data['rewardid'] = rewardid;
    data['keyword'] = keyword;
    data['badgeid'] = badgeid;
    data['categoryName'] = categoryName;
    data['tag'] = tag;
    data['desc'] = desc;
    return data;
  }
}

class Games {
  int? id;
  String? name;
  String? shortname;
  String? banner;
  String? icon;
  String? gameurl;
  String? storeurl;
  String? category;
  String? categoryName;
  String? orientation;
  String? rating;
  String? badge;
  bool? subscription;
  bool? play;
  bool? install;
  String? interstitialid;
  String? rewardid;
  String? keyword;
  String? shortdesc;

  Games({
    this.id,
    this.name,
    this.shortname,
    this.banner,
    this.icon,
    this.gameurl,
    this.storeurl,
    this.category,
    this.categoryName,
    this.orientation,
    this.rating,
    this.badge,
    this.subscription,
    this.play,
    this.install,
    this.interstitialid,
    this.rewardid,
    this.keyword,
    this.shortdesc,
  });

  Games.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortname = json['shortname'];
    banner = json['banner'];
    icon = json['icon'];
    gameurl = json['gameurl'];
    storeurl = json['storeurl'];
    category = json['category'];
    categoryName = json['categoryName'];
    orientation = json['orientation'];
    rating = json['rating'];
    badge = json['badge'];
    subscription = json['subscription'];
    play = json['play'];
    install = json['install'];
    interstitialid = json['interstitialid'];
    rewardid = json['rewardid'];
    keyword = json['keyword'];
    shortdesc = json['shortdesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['shortname'] = shortname;
    data['banner'] = banner;
    data['icon'] = icon;
    data['gameurl'] = gameurl;
    data['storeurl'] = storeurl;
    data['category'] = category;
    data['categoryName'] = categoryName;
    data['orientation'] = orientation;
    data['rating'] = rating;
    data['badge'] = badge;
    data['subscription'] = subscription;
    data['play'] = play;
    data['install'] = install;
    data['interstitialid'] = interstitialid;
    data['rewardid'] = rewardid;
    data['keyword'] = keyword;
    data['shortdesc'] = shortdesc;
    return data;
  }
}

class Sections {
  String? id;
  String? title;
  List<String>? emails;
  String? subtitle;
  String? description;
  String? type;
  List<int>? games;
  List<FooterBanner>? footerBanner;

  Sections({
    this.id,
    this.title,
    this.emails,
    this.subtitle,
    this.description,
    this.type,
    this.games,
    this.footerBanner,
  });

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    emails = (json['emails'] as List<dynamic>?)
        ?.map((final dynamic value) => value.toString().trim())
        .where((final String value) => value.isNotEmpty)
        .toList();
    subtitle = json['subtitle'];
    description = json['description'];
    type = json['type'];
    games = (json['games'] as List<dynamic>?)?.cast<int>();
    if (json['footerBanner'] != null) {
      footerBanner = <FooterBanner>[];
      json['footerBanner'].forEach((v) {
        footerBanner!.add(FooterBanner.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['emails'] = emails;
    data['subtitle'] = subtitle;
    data['description'] = description;
    data['type'] = type;
    data['games'] = games;
    if (footerBanner != null) {
      data['footerBanner'] = footerBanner!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FooterBanner {
  int? category;
  String? bannerurl;
  String? badge;
  String? badgeid;
  String? tag;
  String? desc;

  FooterBanner({
    this.category,
    this.bannerurl,
    this.badge,
    this.badgeid,
    this.tag,
    this.desc,
  });

  FooterBanner.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    bannerurl = json['bannerurl'];
    badge = json['badge'];
    badgeid = json['badgeid'];
    tag = json['tag'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['bannerurl'] = bannerurl;
    data['badge'] = badge;
    data['badgeid'] = badgeid;
    data['tag'] = tag;
    data['desc'] = desc;
    return data;
  }
}
