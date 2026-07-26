class HomeSectionConfig {
  const HomeSectionConfig({
    this.title,
    this.subtitle,
    this.sortOrder,
    this.isVisible = true,
  });

  final String? title;
  final String? subtitle;
  final int? sortOrder;
  final bool isVisible;
}

class HomeSectionConfigs {
  const HomeSectionConfigs._();

  static const Map<String, HomeSectionConfig> sections =
      <String, HomeSectionConfig>{
        // Manage home sections here using either section `id` or `type`.
        // Example:
        // '201': HomeSectionConfig(
        //   title: 'Trending Now',
        //   subtitle: 'Most played this week',
        //   sortOrder: 1,
        // ),
        // '205': HomeSectionConfig(isVisible: false),
      };
}
