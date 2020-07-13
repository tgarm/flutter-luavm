// Copyright 2020 tgarm. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'errors.dart';

export 'errors.dart';

// This class implements the `package:luavm`
class Luavm {
  // we use channel `com.github.tgarm.luavm`
  static const MethodChannel _channel =
      const MethodChannel('com.github.tgarm.luavm');

  static const MethodChannel _bchannel =
      const MethodChannel('com.github.tgarm.luavm/back');

  // use a list to store vm names
  static List<String> _vms = [];
  static Map<String, Function> _mthandlers = {};
  static bool _initialized = false;
  static void _init() {
    if (!_initialized) {
      _bchannel.setMethodCallHandler((call) async {
        if (_mthandlers.containsKey(call.method)) {
          return await _mthandlers[call.method](call.arguments);
        } else {
          throw LuaError("Unhandled Method ${call.method} from Lua");
        }
      });
      _initialized = true;
    }
  }

  static void setMethodHandler(String name, Function handler) {
    _mthandlers[name] = handler;
  }

  // open a new Lua vm with name, return true when succeed
  static Future<bool> open(String name) async {
    bool success = false;
    _init();
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
        final List res = await _channel.invokeMethod<List>(
            'eval', <String, dynamic>{"id": _vms.indexOf(name), "code": code});
        if (res.length > 1) {
          if (res[0] == 'OK') {
            return res.sublist(1);
          } else {
            throw LuaError(res[0]);
          }
        }
        throw LuaError('Luavm error');
      }
      throw LuaError("VM[$name] not exists");
    } on PlatformException catch (e) {
      throw LuaError.from(e);
    }
  }
}
