## 0.3.0

- Each Lua VM runs in a single separated thread
- New Lua module __vmplugin__ for platform support, including invoke method call back to Dart, this enables the network connection initiated from Lua code

## 0.2.1

- Lua "print" now outputs to Flutter console and system log (ADB and iOS NSLog)
- Add Lua modules: cjson, cjson\_safe (Lua-CJSON 2.1.0) and lfs (LuaFileSystem 1.8.0)

## 0.2.0

- Upgrade to the newest Lua 5.4.0

## 0.1.1

* Fix document badges

## 0.1.0

* Fix document and format for `pub.dev` requirements.

## 0.0.1

* Vanilla Lua 5.3.5 without loslib, iOS and Android should work both
