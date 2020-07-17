package.path=vmplugin.doc_dir.."/?.lua"
print(package.path)

local a = require('lib-add')

local res = add(3,5)
print(res)
return res
