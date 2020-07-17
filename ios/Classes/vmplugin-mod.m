#include <stdlib.h>

#include <Foundation/Foundation.h>
#include "LuavmPlugin.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


static int invoke_method(lua_State *L){
    const char *method = luaL_tolstring(L, 1, NULL);
    const char *args = luaL_tolstring(L, 2, NULL);
    
    NSString *res = [LuavmPlugin invokeMethod:[NSString stringWithUTF8String:method] withData:[NSString stringWithUTF8String:args]];
    lua_pushstring(L, [res UTF8String]);
	return 1;
}

static const struct luaL_Reg vmlib[] = {
    {"invoke_method", invoke_method},
    {"platform", NULL},
    {"temp_dir", NULL},
    {"doc_dir", NULL},
  { NULL, NULL },
};

static const char *nsPath(NSSearchPathDirectory dir){
	NSArray *paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
	return [paths.firstObject UTF8String];
}

int luaopen_vmplugin(lua_State * L){
	luaL_newlib(L,vmlib);
    lua_pushstring(L,"ios");
    lua_setfield(L,-2,"platform");
    lua_pushstring(L, nsPath(NSCachesDirectory));
    lua_setfield(L, -2, "temp_dir");
    lua_pushstring(L, nsPath(NSDocumentDirectory));
    lua_setfield(L, -2, "doc_dir");
	return 1;
}
