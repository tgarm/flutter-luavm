import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:luavm/luavm.dart';
import 'pickfile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameCtrl = TextEditingController(text: 'base');
  final _codeCtrl = TextEditingController(text: "return _VERSION");

  bool _running = false;
  String _luaRes = 'Unknown';
  bool _luaError = false;

  @override
  void initState() {
    Luavm.setMethodHandler('httpGet', httpGet);
    copyAssets(context);
    super.initState();
  }

  Future<void> copyAssets(BuildContext context, {List paths}) async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final docPath = (await getApplicationDocumentsDirectory()).path;

    print("docPath:$docPath");
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    if (paths == null) {
      paths =
          manifestMap.keys.where((String key) => key.contains('.lua')).toList();
    }

    paths.forEach((path) async {
      final src = await rootBundle.loadString(path);
      final name = Path.basename(path);
      new File("$docPath/$name").writeAsString(src);
    });
  }

  Future<String> httpGet(String url) async {
    final res = await Dio().get<String>(url);
    return res.data;
  }

  Future<void> runCode() async {
    String luaRes;
    setState(() {
      _running = true;
    });
    try {
      final reslist = await Luavm.eval(_nameCtrl.text, _codeCtrl.text);
      luaRes = reslist.join("\n");
      _luaError = false;
    } on LuaError catch (e) {
      _luaError = true;
      _luaRes = e.toString();
    }

    if (luaRes != null && luaRes.length > 0) {
      _luaRes = luaRes;
    }
    setState(() {
      _running = false;
    });
    if (!mounted) return;
  }

  // Switch Lua VM between opened/closed
  Future<void> vmSwitch(String name) async {
    if (Luavm.opened(name)) {
      await Luavm.close(name);
    } else {
      await Luavm.open(name);
    }
    setState(() {});
  }

  Future<void> pickLuaFile(BuildContext context) async {
    final src =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PickFilePage();
    }));
    if (src != null) {
      _codeCtrl.text = src;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Widget nameLine() {
    String btnTitle = '--';
    if (_nameCtrl.text != '' && _nameCtrl.text != null) {
      if (Luavm.opened(_nameCtrl.text)) {
        btnTitle = 'Close';
      } else {
        btnTitle = 'Open';
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: TextField(
          controller: _nameCtrl,
          autocorrect: false,
          onChanged: (_) {
            setState(() {});
          },
        )),
        MaterialButton(
            onPressed: () async {
              await vmSwitch(_nameCtrl.text);
            },
            child: Text(btnTitle))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    if (_luaError) {
      style = TextStyle(color: Colors.red);
    }
    Widget body = Column(children: [
      nameLine(),
      Row(children: <Widget>[
        MaterialButton(
            color: Colors.blue,
            onPressed: () async {
              await runCode();
            },
            child: Text('Run')),
        MaterialButton(
            color: Colors.blue,
            onPressed: () async {
              await pickLuaFile(context);
            },
            child: Text('Pick'))
      ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
      TextField(controller: _codeCtrl, autocorrect: false, maxLines: 15),
      Text(_luaRes, style: style),
    ], mainAxisAlignment: MainAxisAlignment.spaceEvenly);
    if (_running) {
      body = Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          body,
          Container(
              color: Colors.black38,
              child: Text('Running...'),
              alignment: Alignment.center)
        ],
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Example of LuaVM'),
        ),
        body: Center(child: body));
  }
}
