local jres = vmplugin.invoke_method('httpGet','https://api.myip.com');
print('jres',jres)
return jres
