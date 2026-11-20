/// An AstrBot release shown in the Versions page.
class VersionEntry {
  const VersionEntry({
    required this.tag,
    required this.channel,
    required this.installed,
    this.publishedAt,
    this.sizeBytes,
    this.notes = '',
    this.usingInstances = const [],
  });

  final String tag;

  /// 'stable' or 'pre-release'; drives the chip next to the tag.
  final String channel;
  final bool installed;
  final DateTime? publishedAt;
  final int? sizeBytes;
  final String notes;

  /// Instance names currently pinned to this version.
  final List<String> usingInstances;

  bool get isPreRelease => channel == 'pre-release';
}
