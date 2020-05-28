import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luavm/luavm.dart';

void main() {
  const MethodChannel channel = MethodChannel('luavm');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '0';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('open', () async {
    expect(await Luavm.open(), 0);
  });
}
