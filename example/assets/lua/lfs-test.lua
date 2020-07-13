local spath = vmplugin.temp_dir
print ('Listing items of directory',spath)
local i = 0
for file in lfs.dir(spath) do
	print ('-',file)
	i = i + 1
end
return i
