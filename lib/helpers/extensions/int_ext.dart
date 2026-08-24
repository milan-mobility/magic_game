extension IntExt on int? {
  String formatFileSize() {
    double kb = this! / 1024;
    double mb = kb / 1024;

    if (kb < 1024) {
      return "${kb.toStringAsFixed(2)} KB";
    } else {
      return "${mb.toStringAsFixed(2)} MB";
    }
  }
}
