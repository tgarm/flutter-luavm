import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
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

  String _luaRes = 'Unknown';
  bool _luaError = false;

  @override
  void initState() {
    Luavm.setMethodHandler('httpGet', httpGet);
    super.initState();
  }

  Future<String> httpGet(String url) async {
    final res = await Dio().get<String>(url);
    return res.data;
  }

  Future<void> runCode() async {
    String luaRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final reslist = await Luavm.eval(_nameCtrl.text, _codeCtrl.text);
      luaRes = reslist.join("\n");

      _luaError = false;
    } on LuaError catch (e) {
      setState(() {
        _luaError = true;
        _luaRes = e.toString();
      });
    }

    if (luaRes != null && luaRes.length > 0) {
      setState(() {
        _luaRes = luaRes;
      });
    }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example of LuaVM'),
      ),
      body: Center(
          child: Column(children: [
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
      ], mainAxisAlignment: MainAxisAlignment.spaceEvenly)),
    );
  }
}
