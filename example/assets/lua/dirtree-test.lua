cj = cjson.new()
cjs = cjson_safe.new()

local item_count = 0
function attrdir (path)
	if path==nil then
		path = '.'
	end
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path..'/'..file
			print("\t "..f)
			local attr = lfs.attributes (f)
			if type(attr) == "table" then
				if attr.mode == "directory" then
					attrdir (f)
				else
					item_count = item_count + 1
					print (cj.encode(attr))
					print (cjs.encode(attr))
				end
			else
				print ("type of",name, type(attr))
				print(cjs.encode(attr))
			end
		end
	end
end


attrdir (vmplugin.temp_dir)

return item_count
