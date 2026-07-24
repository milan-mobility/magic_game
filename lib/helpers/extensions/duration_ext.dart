import 'package:get/get.dart';

extension DateTimeExt on Duration? {
  String getTimeAgo() {
    if (this == null) {
      return '';
    } else {
      if (this!.inDays > 365) {
        final int years = this!.inDays ~/ 365;
        return years > 1
            ? '@count years ago'.trParams(<String, String>{
                'count': '$years',
              })
            : '@count year ago'.trParams(<String, String>{
                'count': '$years',
              });
      } else if (this!.inDays > 30) {
        final int months = this!.inDays ~/ 30;
        return months > 1
            ? '@count months ago'.trParams(<String, String>{
                'count': '$months',
              })
            : '@count month ago'.trParams(<String, String>{
                'count': '$months',
              });
      } else if (this!.inDays > 0) {
        return this!.inDays > 1
            ? '@count days ago'.trParams(<String, String>{
                'count': '${this!.inDays}',
              })
            : '@count day ago'.trParams(<String, String>{
                'count': '${this!.inDays}',
              });
      } else if (this!.inHours > 0) {
        return this!.inHours > 1
            ? '@count hours ago'.trParams(<String, String>{
                'count': '${this!.inHours}',
              })
            : '@count hour ago'.trParams(<String, String>{
                'count': '${this!.inHours}',
              });
      } else if (this!.inMinutes > 0) {
        return this!.inMinutes > 1
            ? '@count minutes ago'.trParams(<String, String>{
                'count': '${this!.inMinutes}',
              })
            : '@count minute ago'.trParams(<String, String>{
                'count': '${this!.inMinutes}',
              });
      } else if (this!.inSeconds > 0) {
        return this!.inSeconds > 1
            ? '@count seconds ago'.trParams(<String, String>{
                'count': '${this!.inSeconds}',
              })
            : '@count second ago'.trParams(<String, String>{
                'count': '${this!.inSeconds}',
              });
      } else {
        return 'Just now'.tr;
      }
    }
  }
}
