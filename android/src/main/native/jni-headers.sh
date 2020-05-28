#!/bin/bash
javac -h . -d _jni_tmp -classpath ../java ../java/com/github/tgarm/luavm/LuaJNI.java
rm -rf _jni_tmp
