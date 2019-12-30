import requests
import re
import os
import json

headers = {
    'Content-Type': 'text/plain',
}

data = open('filename.aql')
response = requests.post('http:///artifactory/api/search/aql', headers=headers, data=data, auth=('admin', 'password'))
#print(response.json())
jout = response.json()
resout = jout['results']
#print(type(resout))
#print(len(resout))
#print(resout[0]['name'])
#k = resout[0]['name'].split('-')
#print(os.path.splitext(k)[0])
for i in range(len(resout)):
	names = resout[i]['path']
##	print(names)
	x = names.split('/')
#	print(x)
	k = x[-1]
        l = len(x)-2
	
	#print(k)
        print (x[l], k)
	#l = os.path.splitext(k)[0]
##	#print(k)
	#y = re.sub(r"-\d.*"," %s" %l ,names)
	#print(y)
