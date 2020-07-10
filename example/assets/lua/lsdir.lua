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
					for name, value in pairs(attr) do
						print (name, value)
					end
				end
			else
				print ("type of",name, type(attr))
			end
		end
	end
end

attrdir (spath)
