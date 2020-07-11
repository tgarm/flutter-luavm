cmake_minimum_required(VERSION 3.6)
set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)
set(JAVA_INCLUDE_PATH2 NotNeeded)
set(JAVA_AWT_INCLUDE_PATH NotNeeded)
find_package(JNI REQUIRED)
set(LUA_SOURCE_DIR "../lua-src")
include_directories(
	${LUA_SOURCE_DIR}
	${LUA_SOURCE_DIR}/lfs
	${LUA_SOURCE_DIR}/cjson
)
if (JNI_FOUND)
	include_directories(${JNI_INCLUDE_DIRS})
endif (JNI_FOUND)

file(GLOB SOURCES 
	${LUA_SOURCE_DIR}/*.c
	${LUA_SOURCE_DIR}/lfs/*.c
	${LUA_SOURCE_DIR}/cjson/*.c
	src/main/native/lua-core.c
)

add_definitions(-Wno-deprecated)	# supress warning for tmpnam in lua source code
add_library(lua-core SHARED ${SOURCES})
target_link_libraries(lua-core m log)
