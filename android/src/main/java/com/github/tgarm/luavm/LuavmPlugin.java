package com.github.tgarm.luavm;

import androidx.annotation.NonNull;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.ArrayList;

/** LuavmPlugin */
public class LuavmPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static MethodChannel bchannel;

  private void init_plugin_data(Context context){
    String temp_dir = context.getCacheDir().getAbsolutePath();
    String doc_dir = "DOC_DIR";
    if(Build.VERSION.SDK_INT>=24) {
      doc_dir = context.getDataDir().getAbsolutePath();
    }else{
      doc_dir = temp_dir;
    }
    LuaJNI.set_dirs(temp_dir,doc_dir);
    LuaJNI.set_plugin(this);
  }

  public String invoke_method(final String method, final String data) throws InterruptedException {
    final boolean[] done = {false};
    final String[] res = {""};
    Runnable main_invoker = new Runnable(){
      @Override public void run(){
        bchannel.invokeMethod(method,data,new Result(){
          @Override public void success(Object o){
            res[0] = o.toString();
            synchronized (done) {
              done[0] = true;
              done.notify();
            }
          }
          @Override public void error(String s, String s1, Object o){
            Log.e(s,s1);
            res[0] = o.toString();
            synchronized (done) {
              done[0] = true;
              done.notify();
            }
          }

          @Override
          public void notImplemented() {
            res[0] = "not implemented";
            synchronized (done) {
              done[0] = true;
              done.notify();
            }
          }
        });
      }
    };

    new Handler(Looper.getMainLooper()).post(main_invoker);
    synchronized (done) {
      while (done[0] == false) {
        done.wait();
      }
    }
    return res[0];
  }


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.github.tgarm.luavm");
    bchannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.github.tgarm.luavm/back");
    init_plugin_data(flutterPluginBinding.getApplicationContext());
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It
  // supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new
  // Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith
  // to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith
  // will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both
  // be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.github.tgarm.luavm");
    bchannel = new MethodChannel(registrar.messenger(), "com.github.tgarm.luavm/back");
    final LuavmPlugin plugin = new LuavmPlugin();
    plugin.init_plugin_data(registrar.context());
    channel.setMethodCallHandler(plugin);
  }
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    final int id;
    switch (call.method) {
      case "open":
        id = LuaJNI.open();
        result.success(id);
        break;
    case "close":
        id = ((Integer)call.arguments).intValue();
        Boolean bres = LuaJNI.close(id);
        result.success(bres);
        break;
      case "eval":
        id = call.argument("id");
        final String code = call.argument("code");
        new Thread(new Runnable(){
          @Override public void run() {
            String restr[] = LuaJNI.eval(id, code);
            final ArrayList<String> res = new ArrayList<String>();
            for (int i = 0; i < restr.length; i++) {
              res.add(restr[i]);
            }
            new Handler(Looper.getMainLooper()).post(new Runnable(){
              @Override public void run() {
                result.success(res);
              }
            });
          }
        }).start();
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
