/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_github_tgarm_luavm_LuaJNI */

#ifndef _Included_com_github_tgarm_luavm_LuaJNI
#define _Included_com_github_tgarm_luavm_LuaJNI
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    set_plugin
 * Signature: (Ljava/lang/Object;)V
 */
JNIEXPORT void JNICALL Java_com_github_tgarm_luavm_LuaJNI_set_1plugin
  (JNIEnv *, jclass, jobject);

/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    set_dirs
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_github_tgarm_luavm_LuaJNI_set_1dirs
  (JNIEnv *, jclass, jstring, jstring);

/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    open
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_com_github_tgarm_luavm_LuaJNI_open
  (JNIEnv *, jclass);

/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    close
 * Signature: (I)Z
 */
JNIEXPORT jboolean JNICALL Java_com_github_tgarm_luavm_LuaJNI_close
  (JNIEnv *, jclass, jint);

/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    load
 * Signature: (ILjava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_github_tgarm_luavm_LuaJNI_load
  (JNIEnv *, jclass, jint, jstring);

/*
 * Class:     com_github_tgarm_luavm_LuaJNI
 * Method:    eval
 * Signature: (ILjava/lang/String;)[Ljava/lang/String;
 */
JNIEXPORT jobjectArray JNICALL Java_com_github_tgarm_luavm_LuaJNI_eval
  (JNIEnv *, jclass, jint, jstring);

#ifdef __cplusplus
}
#endif
#endif
