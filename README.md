Flutter Lua VM Plugin
=====================

[![Pub package](https://img.shields.io/pub/v/flutter_lua.svg)](https://pub.dartlang.org/packages/flutter_lua)

A Flutter plugin provides Lua virtual machine 
This plugin is inspired by [flutter_lua](https://github.com/drydart/flutter_lua)

## Getting Started

#### Features

* Supports the latest stable [Lua 5.3.5](https://www.lua.org/manual/5.3/)
* Support multiple Lua instances (don't be too much. <=100 instances)
* Lua script runs in platform thread
* Use Java/ObjC to avoid the annoying Swift version compatibility problem

#### Limitations

* Lua library  "os" is **NOT** supported yet, due to unsupported functions in iOS: _system_ and _tmpnam_
* All returned values will be converted to string


## Usage

#### Open a new VM

VM instances are named to distinguish each other.

```dart
import 'package:luavm/luavm.dart';

...

await Luavm.open("vm-name");
```


#### Run Lua Code

When VM is opened, run Lua code with 'eval' function:

* To load a Lua function:

```dart

await Luavm.eval("name","function luafn(a,b) return a+b end" );
```

* To simply run Lua code:

```dart
final res = await Luavm.eval("name","return _VERSION")
```

res should be returned as:

```dart
["Lua 5.3"]
```


* To call a Lua function:

```dart
final res = await Luavm.eval("name","return luafn(1,2)");
```


Luavm.eval returns a list of String,  contains each value returned from Lua function.


```dart
final res = await Luavm.eval("name","return 1,2,'hello'");
```

should return a Dart list:

`["1","2","hello"]`

#### Close Lua VM

```dart
await Luavm.close("name");
```


#### Error Handling

Errors will be thrown as _LuaError_ which contains error message as a string.

