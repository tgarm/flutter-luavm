#pragma once

void lua_writestring(const char *s, size_t l);
void lua_writeline(void);
void lua_writestringerror(const char *s,const char *p);

int luaopen_vmplugin(lua_State * L);
