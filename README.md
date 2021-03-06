Flutter Lua VM Plugin
=====================

[![Pub package](https://img.shields.io/pub/v/luavm.svg)](https://pub.dev/packages/luavm)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/luavm/latest/)

A Flutter plugin provides Lua virtual machine

This plugin is inspired by [flutter_lua](https://github.com/drydart/flutter_lua), a Go based Lua implementation for Flutter.

## Getting Started

#### Features

* Supports the latest stable vanilla [Lua 5.4.1](https://www.lua.org/manual/5.4/)
* Supports multiple Lua instances (don't be too much. <=100 instances)
* Each Lua instance runs in a separate thread
* Lua "print" function outputs to Flutter console & Logging
* Lua script runs in platform thread
* Use Java/ObjC to avoid the annoying Swift version compatibility problem

#### Lua Modules

Modules are loaded when a Lua VM starts. Can be used in Lua code directly.

| Name                                                         | Global Name | Version         |
| ------------------------------------------------------------ | ----------- | --------------- |
| [LuaFileSystem](https://keplerproject.github.io/luafilesystem/) | lfs         | 1.8.0           |
| [lua-cjson](https://www.kyne.com.au/~mark/software/lua-cjson.php) | cjson       | 2.1.0           |
|                                                              | cjson_safe  | 2.1.0           |
| vmplugin                                                     | vmplugin    | Plugin Specific |



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
["Lua 5.4"]
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

## Lua Module Usage


#### about __require__

To use internal Lua modules, no __require__ is needed.

__require__ is now used to import Lua code only, please set __package.path__ properly before __require__.

This may import local __lua__ file:

```lua
package.path = vmplugin.doc_dir.."/?.lua"

local add = require('lib-add')
```




#### vmplugin

It is a plugin specific module that provides platform support.

```lua

local doc_dir = vmplugin.doc_dir	-- Absolute directory for Application Document 
local platform = vmplugin.platform  -- "ios" or "android"
local temp_dir = vmplugin.temp_dir  -- Absolute directory for Temporary files, corresponding to Temporary Directory of iOS and CacheDir of Android

local res = vmplugin.invoke_method("method-name","method-args")	-- this will invoke a Method Channel call, can be handled by Dart/Other Flutter plugins, currently only support pure string arguments

```

The __invoke\_method__ function can be very useful. 

For instance,  http get can be archieved this way (together with plugin [dio](https://pub.dev/packages/dio)) :

* In Lua

```lua
local jres = vmplugin.invoke_method('httpGet','https://api.myip.com');
```



* In Dart

```dart
Future<String> httpGet(String url) async {
  final res = await Dio().get<String>(url);
  return res.data;
}

Luavm.setMethodHandler('httpGet', httpGet);
```

Please try __http-test.lua__ in example project to see more information.

#### cjson

```lua
local cj = cjson.new()
local tbl = {a=1,b=2,c={'a','b','c'}}
local txt = cj.encode(tbl)
print(str)
local tres = cj.decode(txt)
print(tres.c[1])
```

Besides __cjson__, __cjson\_safe__ is also available to use.



#### lfs

```lua
for file in lfs.dir(spath) do
    print ('-',file)
end
```



## How to contribute

Welcome to create issue about bug, feature request, etc.

