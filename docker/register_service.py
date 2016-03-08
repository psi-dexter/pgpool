import urllib2
import sys
args = sys.argv
name = args[1]
address = args[2]
port = args[3]
stage = args[4]
if address == '{ipv4}':
	address = urllib2.urlopen('http://169.254.169.254/2009-04-04/meta-data/local-ipv4').read()
def register_service(name, address, port, stage):
    register_url = "http://localhost:8500/v1/agent/service/register"
    service_template = '{"ID": "'+name + str(port)+'", "Name": "'+name+'", "Port": '+str(port)+', "Address":"'+ address+'","Tags":["'+stage+'"]}'
    print(service_template)
    request = urllib2.Request(register_url, data=service_template)
    request.add_header('Content-Type', 'application/json')
    request.get_method = lambda: 'PUT'
    response = urllib2.urlopen(request)
    return response.read()
register_service(name, address, port, stage)