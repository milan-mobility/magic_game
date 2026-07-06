// ignore_for_file: always_specify_types

import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';

class Parsing {
  Parsing._();

  /// Get Integer from Dynamic Data
  static int intFrom(final dynamic data, {final int defaultValue = 0}) {
    if (null == data) return defaultValue;
    if (data is int) return data;
    if (data is double) return data.toInt();
    if (data is String) return _intFromString(data, defaultValue: defaultValue);
    return defaultValue;
  }

  /// Get Double from Dynamic Data
  static double doubleFrom(
    final dynamic data, {
    final double defaultValue = 0,
  }) {
    if (null == data) return defaultValue;
    if (data is double) return data;
    if (data is int) return data.toDouble();
    if (data is String?) {
      return _doubleFromString(data, defaultValue: defaultValue);
    }
    return defaultValue;
  }

  /// Get String from Dynamic Data
  static String stringFrom(
    final dynamic data, {
    final String defaultValue = '',
  }) {
    if (null == data) return defaultValue;
    if (data is String?) return data.isNotNullAndEmpty() ? data! : '';
    if (data is int?) return '$data';
    if (data is double?) return '$data';
    return defaultValue;
  }

  /// Get Bool from Dynamic Data
  static bool boolFrom(final dynamic data, {final bool defaultValue = false}) {
    if (null == data) return defaultValue;
    if (data is bool?) return (data != null) ? data : false;
    if ((data is int?) || (data is double?)) {
      return (data != null) ? data == 1 : false;
    }
    if (data is String?) {
      return (data.isNotNullAndEmpty() &&
              (data == '1' ||
                  data!.toLowerCase() == 'true' ||
                  data.toLowerCase() == 'yes'))
          ? true
          : defaultValue;
    }
    return defaultValue;
  }

  /// Get Array from Dynamic Data
  static List? arrayFrom(final dynamic data, {final bool makeNull = false}) {
    if (null == data) return makeNull ? null : <dynamic>[];
    if (data is List?) return data;
    if (data is String) {
      try {
        final dynamic newData = convert.jsonDecode(data);
        if (newData is List) return newData;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return makeNull ? null : <dynamic>[];
  }

  /// Get Map from Dynamic Data
  static Map<String, dynamic>? mapFrom(
    final dynamic data, {
    final bool makeNull = false,
  }) {
    if (null == data) return makeNull ? null : <String, dynamic>{};
    if (data is Map) {
      return data.map(
        (final key, final value) => MapEntry(key.toString(), value),
      );
    }
    if (data is String) {
      try {
        final newData = convert.jsonDecode(data);
        if (newData is Map) {
          return newData.map(
            (final key, final value) => MapEntry(key.toString(), value),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return makeNull ? null : <String, dynamic>{};
  }

  /// Get Map from Dynamic Data
  static Map<String, dynamic>? cloneMap(
    final Map<String, dynamic> data, {
    final bool makeNull = false,
  }) {
    try {
      final String stringData = convert.jsonEncode(data);
      final newData = convert.jsonDecode(stringData);
      if (newData is Map) {
        return newData.map(
          (final key, final value) => MapEntry(key.toString(), value),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return makeNull ? null : <String, dynamic>{};
  }

  static int _intFromString(final String? data, {final int defaultValue = 0}) {
    return data.isNotNullAndEmpty()
        ? (int.tryParse(data!) ??
              double.tryParse(data)?.toInt() ??
              defaultValue.toDouble().toInt())
        : 0;
  }

  static double _doubleFromString(
    final String? data, {
    final double defaultValue = 0,
  }) {
    return data.isNotNullAndEmpty()
        ? (double.tryParse(data!) ??
              int.tryParse(data)?.toDouble() ??
              defaultValue.toInt().toDouble())
        : 0.0;
  }

  /// Helper Method - [containValues]
  /// Return true if given [data] contains values
  /// or return false
  static bool containValues(final dynamic data) {
    if (data == null) return false;
    if (data is String) return data.isNotEmpty;
    if (data is List) return data.isNotEmpty;
    if (data is Map) return data.isNotEmpty;
    if (data is int) return true;
    if (data is double) return true;
    return false;
  }
}

extension ParsingExtension on dynamic {
  /// Get Integer from Dynamic Data
  int intFrom({final int defaultValue = 0}) {
    if (null == this) return defaultValue;
    if (this is int) return this;
    if (this is double) return this.toInt();
    if (this is String) return _intFromString(defaultValue: defaultValue);
    return defaultValue;
  }

  /// Get Double from Dynamic Data
  double doubleFrom({final double defaultValue = 0}) {
    if (null == this) return defaultValue;
    if (this is double) return this;
    if (this is int) return this.toDouble();
    if (this is String?) {
      return _doubleFromString(defaultValue: defaultValue);
    }
    return defaultValue;
  }

  /// Get String from Dynamic Data
  String stringFrom({final String defaultValue = ''}) {
    if (null == this) return defaultValue;
    if (this is String?) return this.isNotNullAndEmpty() ? this! : '';
    if (this is int?) return '$this';
    if (this is double?) return '$this';
    return defaultValue;
  }

  /// Get Bool from Dynamic Data
  bool boolFrom({final bool defaultValue = false}) {
    if (null == this) return defaultValue;
    if (this is bool?) return (this != null) ? this : false;
    if ((this is int?) || (this is double?)) {
      return (this != null) ? this == 1 : false;
    }
    if (this is String?) {
      return (this.isNotNullAndEmpty() &&
              (this == '1' ||
                  this!.toLowerCase() == 'true' ||
                  this.toLowerCase() == 'yes'))
          ? true
          : defaultValue;
    }
    return defaultValue;
  }

  /// Get Array from Dynamic Data
  List<dynamic>? arrayFrom({final bool makeNull = false}) {
    if (null == this) return makeNull ? null : <dynamic>[];
    if (this is List?) return this;
    if (this is String) {
      try {
        final newData = convert.jsonDecode(this);
        if (newData is List) return newData;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return makeNull ? null : <dynamic>[];
  }

  /// Get Map from Dynamic Data
  Map<String, dynamic>? mapFrom({final bool makeNull = false}) {
    if (null == this) return makeNull ? null : <String, dynamic>{};
    if (this is Map) {
      return this.map(
        (final key, final value) => MapEntry(key.toString(), value),
      );
    }
    if (this is String) {
      try {
        final newData = convert.jsonDecode(this);
        if (newData is Map) {
          return newData.map(
            (final key, final value) => MapEntry(key.toString(), value),
          );
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return makeNull ? null : <String, dynamic>{};
  }

  /// Get Map from Dynamic Data
  Map<String, dynamic>? cloneMap({final bool makeNull = false}) {
    if (null == this) return makeNull ? null : <String, dynamic>{};
    try {
      final String stringData = convert.jsonEncode(this);
      final newData = convert.jsonDecode(stringData);
      if (newData is Map) {
        return newData.map(
          (final key, final value) => MapEntry(key.toString(), value),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return makeNull ? null : <String, dynamic>{};
  }

  int _intFromString({final int defaultValue = 0}) {
    return this.isNotNullAndEmpty()
        ? (int.tryParse(this!) ??
              double.tryParse(this)?.toInt() ??
              defaultValue.toDouble().toInt())
        : 0;
  }

  double _doubleFromString({final double defaultValue = 0}) {
    return this.isNotNullAndEmpty()
        ? (double.tryParse(this!) ??
              int.tryParse(this)?.toDouble() ??
              defaultValue.toInt().toDouble())
        : 0.0;
  }

  /// Helper Method - [containValues]
  /// Return true if given [user] contains values
  /// or return false
  bool containValues() {
    if (this == null) return false;
    if (this is String) return this.isNotEmpty;
    if (this is List) return this.isNotEmpty;
    if (this is Map) return this.isNotEmpty;
    if (this is int) return true;
    if (this is double) return true;
    return false;
  }
}

class SafeParse {
  static String? toStringValue(dynamic value) {
    if (value == null || value == false) return null;
    return value.toString();
  }

  static double? toDoubleValue(dynamic value) {
    if (value == null || value == false) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? toIntValue(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? toBoolValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }
}
