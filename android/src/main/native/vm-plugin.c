#include <stdlib.h>
#include <jni.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <android/log.h>
#include "com_github_tgarm_luavm_LuaJNI.h"

static const char *s_temp_dir = "TEMP";
static const char *s_doc_dir = "DOC";

static jobject g_jobj;
static JavaVM *g_JVM;


static const char *call_plugin_invoker(const char *name, const char *args){
    JNIEnv *env;
    (*g_JVM)->GetEnv(g_JVM,(void **)&env, JNI_VERSION_1_6);

    jclass jc = (*env)->GetObjectClass(env,g_jobj);
    if(jc==0) {
        __android_log_write(ANDROID_LOG_ERROR, "flutter", "class not found from object");
        return NULL;
    }
    jmethodID mid = (*env)->GetMethodID(env, jc, "invoke_method","(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;");
    jstring methodj = (*env)->NewStringUTF(env,name);
    jstring dataj = (*env)->NewStringUTF(env,args);
    jobject jres = (*env)->CallObjectMethod(env,g_jobj,mid,methodj,dataj);
    return (*env)->GetStringUTFChars(env,(jstring)jres,NULL);
}

static int invoke_method(lua_State *L){
    const char *method = luaL_tolstring(L, 1, NULL);
    const char *args = luaL_tolstring(L, 2, NULL);

    const char *res = call_plugin_invoker(method, args);
    if(res) {
        lua_pushstring(L, res);
        return 1;
    }else{
        return 0;
    }
}

static const struct luaL_Reg vmlib[] = {
    {"invoke_method", invoke_method},
    {"platform", NULL},
    {"temp_dir", NULL},
    {"doc_dir", NULL},
  { NULL, NULL },
};

JNIEXPORT void JNICALL Java_com_github_tgarm_luavm_LuaJNI_set_1plugin
        (JNIEnv * env, jclass jni, jobject jobj){
    (*env)->GetJavaVM(env,&g_JVM);
    g_jobj = (*env)->NewGlobalRef(env,jobj);
}

JNIEXPORT void JNICALL Java_com_github_tgarm_luavm_LuaJNI_set_1dirs
        (JNIEnv *env, jclass cls, jstring temp_dir, jstring doc_dir) {
    const char *tdir = (*env)->GetStringUTFChars(env,temp_dir,NULL);
    const char *ddir = (*env)->GetStringUTFChars(env,doc_dir,NULL);
    s_temp_dir = tdir;
    s_doc_dir = ddir;
}

int luaopen_vmplugin(lua_State * L){
    luaL_newlib(L,vmlib);
    lua_pushstring(L,"android");
    lua_setfield(L,-2,"platform");
    lua_pushstring(L, s_temp_dir);
    lua_setfield(L, -2, "temp_dir");
    lua_pushstring(L, s_doc_dir);
    lua_setfield(L, -2, "doc_dir");
    return 1;
}
