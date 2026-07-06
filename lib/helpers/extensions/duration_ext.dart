extension DateTimeExt on Duration? {
  String getTimeAgo() {
    if (this == null) {
      return '';
    } else {
      if (this!.inDays > 365) {
        final int years = this!.inDays ~/ 365;
        return "$years year${years > 1 ? 's' : ''} ago";
      } else if (this!.inDays > 30) {
        final int months = this!.inDays ~/ 30;
        return "$months month${months > 1 ? 's' : ''} ago";
      } else if (this!.inDays > 0) {
        return "${this!.inDays} day${this!.inDays > 1 ? 's' : ''} ago";
      } else if (this!.inHours > 0) {
        return "${this!.inHours} hour${this!.inHours > 1 ? 's' : ''} ago";
      } else if (this!.inMinutes > 0) {
        return "${this!.inMinutes} minute${this!.inMinutes > 1 ? 's' : ''} ago";
      } else if (this!.inSeconds > 0) {
        return "${this!.inSeconds} second${this!.inSeconds > 1 ? 's' : ''} ago";
      } else {
        return 'Just now';
      }
    }
  }
}
