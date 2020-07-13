
package com.github.tgarm.luavm;

public class LuaJNI {
    static {
        System.loadLibrary("lua-core");
    }
    static native void set_plugin(Object obj);
    static native void set_dirs(String temp_dir, String doc_dir);
    static native int open();
    static native boolean close(int id);
    static native String load(int id, String code);
    static native String[] eval(int id, String code);
    
}
