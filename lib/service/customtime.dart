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

String shortTimeAgo(DateTime dateTime) {
  String result = timeago.format(dateTime, allowFromNow: true);

  result = result.replaceAll('minutes', 'min');
  result = result.replaceAll('minute', 'min');
  result = result.replaceAll('hours', 'h');
  result = result.replaceAll('hour', '');
  result = result.replaceAll('days', 'd');
  result = result.replaceAll('day', 'd');
  result = result.replaceAll('months', 'm');
  result = result.replaceAll('month', 'm');
  result = result.replaceAll('years', 'y');
  result = result.replaceAll('year', 'y');
  result = result.replaceAll('about', '');
  result = result.replaceAll('an', '1h');
  result = result.replaceAllMapped(
      RegExp(r'(\d+)\s+(min)'), (Match m) => '${m[1]}${m[2]}');
  result = result.replaceAllMapped(
      RegExp(r'(\d+)\s+(h)'), (Match m) => '${m[1]}${m[2]}');
  result = result.replaceAllMapped(
      RegExp(r'(\d+)\s+(d)'), (Match m) => '${m[1]}${m[2]}');
  result = result.replaceAllMapped(
      RegExp(r'(\d+)\s+(mo)'), (Match m) => '${m[1]}${m[2]}');
  result = result.replaceAllMapped(
      RegExp(r'(\d+)\s+(yr)'), (Match m) => '${m[1]}${m[2]}');
  return result;
}
