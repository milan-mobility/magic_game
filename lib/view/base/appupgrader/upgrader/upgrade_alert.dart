/*
 * Copyright (c) 2021-2023 Larry Aasen. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:magic_games/view/base/appupgrader/upgrader/upgrade_base.dart';
import 'package:magic_games/view/base/appupgrader/upgrader/upgrader.dart';

class UpgradeAlert extends UpgradeBase {
  /// Creates a new [UpgradeAlert].
  UpgradeAlert({
    final Key? key,
    final Upgrader? upgrader,
    this.child,
    this.navigatorKey,
  }) : super(upgrader ?? Upgrader.sharedInstance, key: key);

  /// The [child] contained by the widget.
  final Widget? child;

  /// For use by the Router architecture as part of the RouterDelegate.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Describes the part of the user interface represented by this widget.
  @override
  Widget build(final BuildContext context, final UpgradeBaseState state) {
    if (upgrader.debugLogging) {
      debugPrint('upgrader: build UpgradeAlert');
    }

    return StreamBuilder(
      initialData: state.widget.upgrader.evaluationReady,
      stream: state.widget.upgrader.evaluationStream,
      builder:
          (
            final BuildContext context,
            final AsyncSnapshot<UpgraderEvaluateNeed> snapshot,
          ) {
            if ((snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) &&
                snapshot.data != null &&
                snapshot.data!) {
              if (upgrader.debugLogging) {
                debugPrint("upgrader: need to evaluate version");
              }

              final checkContext =
                  navigatorKey != null && navigatorKey!.currentContext != null
                  ? navigatorKey!.currentContext!
                  : context;
              upgrader.checkVersion(context: checkContext);
            }
            return child ?? const SizedBox.shrink();
          },
    );
  }
}
