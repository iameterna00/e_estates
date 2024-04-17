import 'package:timeago/timeago.dart' as timeago;

String customTimeAgo(DateTime uploadedAtDateTime) {
  final now = DateTime.now();
  final difference = now.difference(uploadedAtDateTime);

  if (difference.inDays < 7) {
    return timeago.format(uploadedAtDateTime);
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}
