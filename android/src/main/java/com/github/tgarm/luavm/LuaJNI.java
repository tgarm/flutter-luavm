
package com.github.tgarm.luavm;

public class LuaJNI {
    static {
        System.loadLibrary("lua-core");
    }
    static native int open();
    static native boolean close(int id);
    static native String load(int id, String code);
    static native String[] eval(int id, String code);
    
}
