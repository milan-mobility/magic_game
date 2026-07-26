/*
 * Copyright (c) 2018-2023 Larry Aasen. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:magic_games/view/base/appupgrader/upgrader/upgrader.dart';

class UpgradeBase extends StatefulWidget {
  const UpgradeBase(this.upgrader, {final Key? key}) : super(key: key);

  /// The upgraders used to configure the upgrade dialog.
  final Upgrader upgrader;

  Widget build(final BuildContext context, final UpgradeBaseState state) {
    return Container();
  }

  @override
  UpgradeBaseState createState() => UpgradeBaseState();
}

class UpgradeBaseState extends State<UpgradeBase> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(final BuildContext context) => widget.build(context, this);

  Future<bool> initialize() => widget.upgrader.initialize();

  void forceUpdateState() => setState(() {});
}
