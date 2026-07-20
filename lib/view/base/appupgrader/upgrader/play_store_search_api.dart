/*
 * Copyright (c) 2021 William Kwabla. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

class PlayStoreSearchAPI {
  PlayStoreSearchAPI({final http.Client? client})
      : client = client ?? http.Client();

  /// Play Store Search Api URL
  final String playStorePrefixURL = 'play.google.com';

  /// Provide an HTTP Client that can be replaced for mock testing.
  final http.Client? client;

  /// Enable debugPrint statements for debugging.
  bool debugLogging = false;

  /// Look up by id.
  Future<Document?> lookupById(final String id,
      {final String? country = 'US',
      final String? language = 'en',
      final bool useCacheBuster = true}) async {
    assert(id.isNotEmpty);
    if (id.isEmpty) return null;

    final url = lookupURLById(id,
        country: country, language: language, useCacheBuster: useCacheBuster)!;
    if (debugLogging) {
      debugPrint('upgrader: lookupById url: $url');
    }

    try {
      final response = await client!.get(Uri.parse(url), headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36',
      });
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (debugLogging) {
          debugPrint(
              'upgrader: Can\'t find an app in the Play Store with the id: $id. Status code: ${response.statusCode}');
        }
        return null;
      }

      // Uncomment for creating unit test input files.
      // final file = io.File('file.txt');
      // await file.writeAsBytes(response.bodyBytes);

      final decodedResults = _decodeResults(response.body);

      return decodedResults;
    } on Exception catch (e) {
      if (debugLogging) {
        debugPrint('upgrader: lookupById exception: $e');
      }
      return null;
    }
  }

  String? lookupURLById(final String id,
      {final String? country = 'US',
      final String? language = 'en',
      final bool useCacheBuster = true}) {
    assert(id.isNotEmpty);
    if (id.isEmpty) return null;

    final Map<String, dynamic> parameters = {'id': id};
    if (country != null && country.isNotEmpty) {
      parameters['gl'] = country;
    }
    if (language != null && language.isNotEmpty) {
      parameters['hl'] = language;
    }
    if (useCacheBuster) {
      parameters['_cb'] = DateTime.now().microsecondsSinceEpoch.toString();
    }
    final url = Uri.https(playStorePrefixURL, '/store/apps/details', parameters)
        .toString();

    return url;
  }

  Document? _decodeResults(final String jsonResponse) {
    if (jsonResponse.isNotEmpty) {
      final decodedResults = parse(jsonResponse);
      return decodedResults;
    }
    return null;
  }
}

extension PlayStoreResults on PlayStoreSearchAPI {
  static RegExp releaseNotesSpan = RegExp(r'>(.*?)</span>');

  /// Return field description from Play Store results.
  String? description(final Document response) {
    try {
      final sectionElements = response.getElementsByClassName('W4P4ne');
      final descriptionElement = sectionElements[0];
      final description = descriptionElement
          .querySelector('.PHBdkd')
          ?.querySelector('.DWPxHb')
          ?.text;
      return description;
    } catch (e) {
      return redesignedDescription(response);
    }
  }

  /// Return field description from Redesigned Play Store results.
  String? redesignedDescription(final Document response) {
    try {
      final sectionElements = response.getElementsByClassName('bARER');
      final descriptionElement = sectionElements.last;
      final description = descriptionElement.text;
      return description;
    } catch (e) {
      if (debugLogging) {
        debugPrint(
            'upgrader: PlayStoreResults.redesignedDescription exception: $e');
      }
    }
    return null;
  }

  /// Return the minimum app version taken from a tag in the description field from the store response.
  /// The [tagRegExpSource] is used to represent the format of a tag using a regular expression.
  /// The format in the description by default is like this: `[Minimum supported app version: 1.2.3]`, which
  /// returns the version `1.2.3`. If there is no match, it returns null.
  Version? minAppVersion(
    final Document response, {
    final String tagRegExpSource =
        r'\[\Minimum supported app version\:[\s]*(?<version>[^\s]+)[\s]*\]',
  }) {
    Version? version;
    try {
      final desc = description(response);
      if (desc != null) {
        final regExp = RegExp(tagRegExpSource, caseSensitive: false);
        final match = regExp.firstMatch(desc);
        final mav = match?.namedGroup('version');

        if (mav != null) {
          try {
            // Verify version string using class Version
            version = Version.parse(mav);
          } on Exception catch (e) {
            if (debugLogging) {
              debugPrint(
                  'upgrader: PlayStoreResults.minAppVersion: mav=$mav, tag=$tagRegExpSource, error=$e');
            }
          }
        }
      }
    } on Exception catch (e) {
      if (debugLogging) {
        debugPrint('upgrader.PlayStoreResults.minAppVersion : $e');
      }
    }
    return version;
  }

  /// Returns field releaseNotes from Play Store results. When there are no
  /// release notes, the main app description is used.
  String? releaseNotes(final Document response) {
    try {
      final sectionElements = response.getElementsByClassName('W4P4ne');
      final releaseNotesElement = sectionElements.firstWhere(
          (final elm) => elm.querySelector('.wSaTQd')!.text == 'What\'s New',
          orElse: () => sectionElements[0]);

      final rawReleaseNotes = releaseNotesElement
          .querySelector('.PHBdkd')
          ?.querySelector('.DWPxHb');
      final releaseNotes = rawReleaseNotes == null
          ? null
          : multilineReleaseNotes(rawReleaseNotes);

      return releaseNotes;
    } catch (e) {
      return redesignedReleaseNotes(response);
    }
  }

  /// Returns field releaseNotes from Redesigned Play Store results. When there are no
  /// release notes, the main app description is used.
  String? redesignedReleaseNotes(final Document response) {
    try {
      final sectionElements =
          response.querySelectorAll('[itemprop="description"]');

      final rawReleaseNotes = sectionElements.last;
      final releaseNotes = multilineReleaseNotes(rawReleaseNotes);
      return releaseNotes;
    } catch (e) {
      if (debugLogging) {
        debugPrint(
            'upgrader: PlayStoreResults.redesignedReleaseNotes exception: $e');
      }
    }
    return null;
  }

  String? multilineReleaseNotes(final Element rawReleaseNotes) {
    final innerHtml = rawReleaseNotes.innerHtml;
    String? releaseNotes = innerHtml;

    if (releaseNotesSpan.hasMatch(innerHtml)) {
      releaseNotes = releaseNotesSpan.firstMatch(innerHtml)!.group(1);
    }
    // Detect default multiline replacement
    releaseNotes = releaseNotes!.replaceAll('<br>', '\n');

    return releaseNotes;
  }

  /// Return field version from Play Store results.
  String? version(final Document response) {
    String? version;
    try {
      final additionalInfoElements = response.getElementsByClassName('hAyfc');
      final versionElement = additionalInfoElements.firstWhere(
        (final elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
      );
      final storeVersion = versionElement.querySelector('.htlgb')!.text;
      // storeVersion might be: 'Varies with device', which is not a valid version.
      version = Version.parse(storeVersion).toString();
    } catch (e) {
      return redesignedVersion(response);
    }

    return version;
  }

  /// Return field version from Redesigned Play Store results.
  String? redesignedVersion(final Document response) {
    String? version;
    try {
      // Pattern 1: Look for the version in the script data using a more flexible regex
      // This targets the specific JSON structure where version is stored.
      final scripts = response.getElementsByTagName("script");
      for (final script in scripts) {
        final text = script.text;
        if (text.contains('AF_initDataCallback') && text.contains('ds:5')) {
          // This regex looks for a version-like string inside a JSON array structure often found in ds:5
          // It's more flexible to catch versions like "1.2", "1.2.3.4", or "1.2.3-beta"
          final versionRegex = RegExp(r'\["(\d+(\.\d+)*[^"]*)"\]');
          final matches = versionRegex.allMatches(text);
          for (final match in matches) {
            final possibleVersion = match.group(1);
            if (possibleVersion != null && _isValidVersion(possibleVersion)) {
              if (debugLogging) {
                debugPrint('upgrader: found version in ds:5: $possibleVersion');
              }
              return possibleVersion;
            }
          }
        }
      }

      // Pattern 2: Fallback to the original logic if ds:5 fails
      const patternName = ",\"name\":\"";
      const patternVersion = ",[[[\"";
      const patternCallback = "AF_initDataCallback";
      const patternEndOfString = "\"";

      final infoElements =
          scripts.where((final element) => element.text.contains(patternName));
      final additionalInfoElements = scripts
          .where((final element) => element.text.contains(patternCallback));
      final additionalInfoElementsFiltered = additionalInfoElements
          .where((final element) => element.text.contains(patternVersion));

      if (infoElements.isNotEmpty && additionalInfoElementsFiltered.isNotEmpty) {
        final nameElement = infoElements.first.text;
        final storeNameStartIndex =
            nameElement.indexOf(patternName) + patternName.length;
        final storeNameEndIndex = storeNameStartIndex +
            nameElement
                .substring(storeNameStartIndex)
                .indexOf(patternEndOfString);
        final storeName =
            nameElement.substring(storeNameStartIndex, storeNameEndIndex);

        final versionElement = additionalInfoElementsFiltered
            .where((final element) => element.text.contains("\"$storeName\""))
            .first
            .text;
        final storeVersionStartIndex =
            versionElement.lastIndexOf(patternVersion) + patternVersion.length;
        final storeVersionEndIndex = storeVersionStartIndex +
            versionElement
                .substring(storeVersionStartIndex)
                .indexOf(patternEndOfString);
        final storeVersion = versionElement.substring(
            storeVersionStartIndex, storeVersionEndIndex);

        if (_isValidVersion(storeVersion)) {
          return Version.parse(storeVersion).toString();
        }
      }
    } catch (e) {
      if (debugLogging) {
        debugPrint(
            'upgrader: PlayStoreResults.redesignedVersion exception: $e');
      }
    }

    return version;
  }

  bool _isValidVersion(String version) {
    try {
      Version.parse(version);
      return true;
    } catch (_) {
      return false;
    }
  }
}
