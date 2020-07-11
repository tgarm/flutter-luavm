print ('Listing items of directory',spath)
for file in lfs.dir(spath) do
	print ('-',file)
end
