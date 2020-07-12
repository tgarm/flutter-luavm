import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PickFilePage extends StatefulWidget {
  PickFilePage({Key key}) : super(key: key);

  @override
  _PickFilePageState createState() => _PickFilePageState();
}

class _PickFilePageState extends State<PickFilePage> {
  List<String> luaPaths = [];
  @override
  void initState() {
    loadLuaList();
    super.initState();
  }

  Future<void> loadLuaList() async {
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final paths =
        manifestMap.keys.where((String key) => key.contains('.lua')).toList();
    setState(() {
      luaPaths = paths;
    });
  }

  Future<void> loadLuaFile(int idx) async {
    final path = luaPaths[idx];
    String src = await rootBundle.loadString(path);
    Navigator.of(context).pop(src);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemCount: luaPaths.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int idx) {
            return ListTile(
              title: Text(luaPaths[idx]),
              onTap: () async {
                await loadLuaFile(idx);
              },
            );
          }),
    );
  }
}
