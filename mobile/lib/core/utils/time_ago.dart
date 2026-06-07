/// Formats a past [DateTime] as a short, human-readable relative string,
/// e.g. "just now", "5 minutes ago", "Yesterday", "3 days ago".
///
/// Used for comment timestamps. (The community feed card has its own compact
/// "3d / 2h / 5m" formatter; this one reads as full phrases.)
String timeAgo(DateTime dateTime) {
  final dt = dateTime.isUtc ? dateTime.toLocal() : dateTime;
  final diff = DateTime.now().difference(dt);

  // Future timestamps (clock skew / optimistic entries) read as "just now".
  if (diff.isNegative || diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes == 1) return '1 minute ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours == 1) return '1 hour ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 14) return '1 week ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
  if (diff.inDays < 60) return '1 month ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
  if (diff.inDays < 730) return '1 year ago';
  return '${(diff.inDays / 365).floor()} years ago';
}
