// Copyright 2020 tgarm. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'errors.dart';

export 'errors.dart';

// This class implements the `package:luavm`
class Luavm {
  // we use channel `com.github.tgarm.luavm`
  static const MethodChannel _channel =
      const MethodChannel('com.github.tgarm.luavm');

  // use a list to store vm names
  static List<String> _vms = [];

  // open a new Lua vm with name, return true when succeed
  static Future<bool> open(String name) async {
    bool success = false;
    try {
      if (_vms.contains(name)) return null;
      final int idx = await _channel.invokeMethod('open');
      if (idx >= 0) {
        while (_vms.length <= idx) {
          _vms.add(null);
        }
        _vms[idx] = name;
      }
      success = true;
    } on PlatformException catch (e) {
      throw LuaError.from(e);
    }
    return success;
  }

  // check Lua vm is opened now, return true/false
  static bool opened(String name) {
    if (_vms.contains(name)) {
      return true;
    }
    return false;
  }

  // close a Lua vm, return true when succeed
  static Future<bool> close(String name) async {
    bool success = false;
    try {
      if (_vms.contains(name)) {
        final int idx = _vms.indexOf(name);
        success = await _channel.invokeMethod('close', idx);
        if (success) {
          _vms[idx] = null;
        }
      }
    } on PlatformException catch (e) {
      throw LuaError.from(e);
    }
    return success;
  }

  // eval, run Lua code in named vm
  // returns a list of result, when there is no result, just return an empty list
  static Future<List> eval(String name, String code) async {
    try {
      if (name != null && _vms.contains(name)) {
        final res = await _channel.invokeMethod<List>(
            'eval', <String, dynamic>{"id": _vms.indexOf(name), "code": code});
        if (res[0] != 'OK') {
          throw LuaError(json.encode(res));
        }
        return res.sublist(1);
      } else {
        throw LuaError("VM[$name] not exists");
      }
    } on PlatformException catch (e) {
      throw LuaError.from(e);
    }
  }
}
