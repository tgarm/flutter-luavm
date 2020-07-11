print ('Simple test for CJSON encode/decode')

local cj = cjson.new()
local tbl = {a=1,b=2,c={'a','b','c'}}
local txt = cj.encode(tbl)
print(txt)
local tres = cj.decode(txt)
print(tres.c[1])
