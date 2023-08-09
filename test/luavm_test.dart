import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luavm/luavm.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.github.tgarm.luavm');
  final dbm = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dbm.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return 0;
    });
  });

  tearDown(() {
    dbm.setMockMethodCallHandler(channel, null);
  });

  test('open', () async {
    expect(await Luavm.open("vm1"), true);
  });
}
