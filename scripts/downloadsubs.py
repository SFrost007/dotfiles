#!/usr/bin/python
#
# Downloads subtitles for a movie from opensubtitles.org
# Dev readme: http://trac.opensubtitles.org/projects/opensubtitles/wiki/DevReadFirst
# API doc: http://trac.opensubtitles.org/projects/opensubtitles/wiki/XMLRPC

import gzip, os, StringIO, struct, sys, urllib2, xmlrpclib

proxy = xmlrpclib.ServerProxy("http://api.opensubtitles.org/xml-rpc")

def usage():
	print "Usage: " + sys.argv[0] + " filename [sessiontoken]"
	print "  - filename should be the path to the movie file"
	print "  - sessiontoken is optional, can specify an existing session token."
	print "    If no session token is specified, a new one will be generated through a login call"
	print " "


# Common implementation for checking response status from opensubtitles.org
# API calls
def checkStatus(response):
	return response['status'].startswith('200')


# Requests a login token from opensubtitles.org. If the request fails or returns
# any error status, the script will exit.
# Users should change OSTestUserAgent to a user agent requested through an
# opensubtitles.org account.
# See http://trac.opensubtitles.org/projects/opensubtitles/wiki/DevReadFirst
def getlogintoken():
	session = proxy.LogIn("", "", "en", "OSTestUserAgent")
	if checkStatus(session):
		return session['token']
	else:
		print "Failed to get API token"
		exit(1)


# Common implementation for getting size of file
def getfilesize(fn):
	return os.path.getsize(fn)


# Example implementation taken from
# http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Python
def getfilehash(fn):
	try:
		longlongformat = '<q'
		bytesize = struct.calcsize(longlongformat)
		
		f = open(fn, "rb")
		
		filesize = os.path.getsize(fn)
		hash = filesize
		
		if filesize < 65536 * 2:
			   return "SizeError"
		
		for x in range(65536/bytesize):
				buffer = f.read(bytesize)
				(l_value,)= struct.unpack(longlongformat, buffer)
				hash += l_value
				hash = hash & 0xFFFFFFFFFFFFFFFF #to remain as 64bit number
		
		f.seek(max(0,filesize-65536),0)
		for x in range(65536/bytesize):
				buffer = f.read(bytesize)
				(l_value,)= struct.unpack(longlongformat, buffer)
				hash += l_value
				hash = hash & 0xFFFFFFFFFFFFFFFF
		
		f.close()
		returnedhash =  "%016x" % hash
		return returnedhash
	except(IOError): 
		return "IOError"


# Downloads the subtitles from the given url, unzips them and saves to the
# specified output file.
def downloadSub(url, fn):
	request = urllib2.Request(url)
	response = urllib2.urlopen(request)
	# We will just assume the response is gzipped
	buf = StringIO.StringIO(response.read())
	f = gzip.GzipFile(fileobj=buf)

	# Write to the output file
	out = open(fn, 'w+')
	out.write(f.read())
	out.close()
	print "Downloaded to " + fn


# Searches opensubtitles.org for subtitles for the given file. This method uses
# the filesize and hash lookup methods for the most accurate results. Results are
# filtered to English-only, and the most downloaded version is retrieved. If
# there are no results or the API call returns an error, the script will exit.
# If a token is specified this will be used, otherwise a fresh login token will
# be requested.
def findSub(fn, token):
	hash = getfilehash(fn)
	size = getfilesize(fn)
	if token == '':
		token = getlogintoken()

	response = proxy.SearchSubtitles(token, [{'moviehash': hash, 'moviebytesize': size}])
	url=''
	fmt=''
	downloads=0

	if checkStatus(response):
		for result in response['data']:
			if result['ISO639'] == 'en':
				if result['SubDownloadsCnt'] > downloads:
					downloads = int(result['SubDownloadsCnt'])
					url = result['SubDownloadLink']
					fmt = result['SubFormat']
	
	if downloads > 0:
		extpos = fn.rfind('.')
		downloadSub(url, fn[:extpos]+'.'+fmt)
	else:
		print "Failed to find subtitles for " + fn
		exit(1)


# Main
argc = len(sys.argv)
if argc == 2:
	findSub(sys.argv[1], '')
elif argc == 3:
	findSub(sys.argv[1], sys.argv[2])
else:
	usage()
