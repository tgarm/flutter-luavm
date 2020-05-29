import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'errors.dart';

export 'errors.dart';

class Luavm {
  static const MethodChannel _channel =
      const MethodChannel('com.github.tgarm.luavm');

  static List<String> _vms = [];

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

  static bool opened(String name) {
    if(_vms.contains(name)){
      return true;
    }
    return false;
  }

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
