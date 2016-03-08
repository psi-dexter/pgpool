import urllib2
import sys
import json
#import re
import base64
import os
args = sys.argv
address = args[1]
if address == '{ipv4}' or len(address) == 0:
    address = urllib2.urlopen('http://169.254.169.254/2009-04-04/meta-data/local-ipv4').read()

def read_key(path):
    result = True
    keys_url = "http://localhost:8500/v1/kv/"+path
    keys_content=''
    try:
        keys_content = urllib2.urlopen(keys_url).read()
    except urllib2.HTTPError, e:
        result = False
    if(result):
        keys_list = json.loads(keys_content)
        output = {}
        for entry in keys_list:
            key = entry["Key"]
            output[key] = base64.b64decode(entry["Value"])
        return output[key]
    else:
        return result

def claim_master(address):
    env = os.environ['STAGE']
    baseurl = "configuration/"+env+"/postgresql_cluster/master_candidat"
    master = read_key(baseurl)
    if master:
        return master
    else:
        register_url =  "http://localhost:8500/v1/kv/" + baseurl
        request = urllib2.Request(register_url, data=address)
        request.add_header('Content-Type', 'application/json')
        request.get_method = lambda: 'PUT'
        response = urllib2.urlopen(request)
        return response.read()

claim_master(address)
