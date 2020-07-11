#import "Luavm.h"
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
#import "lfs.h"
#import "lua_cjson.h"

static char log_buf[256] = {0};

void lua_writestring(const char *s, size_t l){
	size_t sblen = strlen(log_buf);
	if(sblen+l>=sizeof(log_buf)){
		lua_writeline();
		sblen = 0;
		if(l>=sizeof(log_buf)){
			char *buf = alloca(l+1);
			strncpy(buf,s,l);
			buf[l] = 0;
			NSLog(@"LuaVM:%s",buf);
			l = 0;
		}
	}
	if(l>0){
		strncat(log_buf,s,l);
		log_buf[sblen+l] = 0;
	}
}

void lua_writeline(void){
	NSLog(@"LuaVM:%s",log_buf);
	memset(log_buf,0,sizeof(log_buf));
}

void lua_writestringerror(const char *s, const char *p){
	NSLog(@"LuaVM Error:%s %s",s,p);
}

@implementation Luavm
static Luavm * instance = nil;
#define MAX_VMS 100
static lua_State *vms[MAX_VMS] = {NULL};
+ (Luavm *)inst{
    if(instance==nil){
        instance = [[Luavm alloc] init];
    }
    return instance;
}
- (NSNumber *) open{
    for(int i=0;i<MAX_VMS;i++){
        if(!vms[i]){
            lua_State *L = luaL_newstate();
            if(L){
                luaL_openlibs(L);
    			luaL_requiref(L, "lfs", luaopen_lfs, 1);
				lua_pop(L,1);
    			luaL_requiref(L, "cjson", luaopen_cjson, 1);
				lua_pop(L,1);
    			luaL_requiref(L, "cjson_safe", luaopen_cjson_safe, 1);
				lua_pop(L,1);
                vms[i] = L;
                return [NSNumber numberWithInt:i];
            }
        }
    }
    return [NSNumber numberWithInt:-1];
}
- (NSNumber *) close:(int)idx{
    if(idx>=0&&idx<MAX_VMS){
        lua_State *L = vms[idx];
        if(L){
            lua_close(L);
            vms[idx] = NULL;
            return [NSNumber numberWithBool:YES];
        }
    }
    return [NSNumber numberWithBool:NO];
}

- (NSArray *)eval:(int)idx withCode:(NSString *)code{
    const char *restr = "Fail";
    NSMutableArray *rets = [[NSMutableArray alloc] init];
    if(idx>=0&&idx<MAX_VMS){
        lua_State *L = vms[idx];
        if(L){
            int base = lua_gettop(L);
            int res = luaL_dostring(L, [code UTF8String]);
            int top = lua_gettop(L);
            if(res>0){
                restr = lua_tostring(L,-1);
                lua_pop(L,1);
                top = lua_gettop(L);
            }else{
                restr = "OK";
            }
            if(top>0){
                for(int i=0;i<top;i++){
                    const char *str = lua_tostring(L, i-top);
                    if(str){
                        [rets addObject:[NSString stringWithUTF8String:str]];
                    }
                }
            }
            if(top>base){
                lua_pop(L, top-base);
            }
        }else{
            restr = "VM Not exist";
        }
    }else{
        restr = "VM ID out of range";
    }
    [rets insertObject:[NSString stringWithUTF8String:restr] atIndex:0];
    return [NSArray arrayWithArray:rets];
}

@end
