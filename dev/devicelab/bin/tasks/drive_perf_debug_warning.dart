// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_devicelab/framework/adb.dart';
import 'package:flutter_devicelab/framework/framework.dart';
import 'package:flutter_devicelab/framework/utils.dart';

Future<String> _runWithMode(String mode, String deviceId) {
  return evalFlutter('drive', options: <String>[
    mode,
    '-t',
    'test_driver/scroll_perf.dart',
    '-d',
    deviceId,
  ]);
}

Future<TaskResult> run() async {
  cd('${flutterDirectory.path}/examples/flutter_gallery');
  final Device device = await devices.workingDevice;
  await device.unlock();
  final String deviceId = device.deviceId;
  await flutter('packages', options: <String>['get']);

  const String warningPiece = 'THIS BENCHMARK IS BEING RUN IN DEBUG MODE';

  final String debugOutput = await _runWithMode('--debug', deviceId);
  if (!debugOutput.contains(warningPiece)) {
    return TaskResult.failure(
        'Could not find the following warning message piece: $warningPiece'
    );
  }

  final String profileOutput = await _runWithMode('--profile', deviceId);
  if (profileOutput.contains(warningPiece)) {
    return TaskResult.failure(
      'Unexpected warning message piece in profile mode: $warningPiece'
    );
  }

  return TaskResult.success(null);
}

Future<void> main() async {
  deviceOperatingSystem = DeviceOperatingSystem.android;
  await task(run);
}
