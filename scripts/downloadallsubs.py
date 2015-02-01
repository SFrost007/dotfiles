#!/usr/bin/python

#from subprocess import Popen, PIPE
from subprocess import call
import struct, os, xmlrpclib

proxy = xmlrpclib.ServerProxy("http://api.opensubtitles.org/xml-rpc")
session = proxy.LogIn("", "", "en", "OSTestUserAgent")

movie_exts = ['.avi','.mp4','.m4v','.mpg','.mkv','.mpeg','.mov','.wmv','.ts']
sub_exts = ['.srt','.sub','.ssa','.smi','.txt']

for subdirs, dirs, files in os.walk('./'):
  for file in files:
    for movie_ext in movie_exts:
      fn = file.replace(movie_ext, '')
      if file == fn:
        continue
      #print 'Found movie ' + subdirs + '/' + file

      # Check for subtitles with the matching filename
      hasSubtitles = 0
      for file2 in os.listdir('./'+subdirs):
        for sub_ext in sub_exts:
          fn2 = file2.replace(sub_ext, '')
          if fn2 == fn:
            #print "Found subtitles for " + file
            hasSubtitles = 1

      if hasSubtitles == 0:
        #print 'Found movie without subtitles: ' + subdirs + '/' + file
        call(['downloadsubs.py', subdirs+'/'+file, session['token']])
        #process = Popen(["downloadsubs.py", subdirs+'/'+file, session['token']], stdout=PIPE)
        #process.communicate()
        #exit_code = process.wait()
        #if not exit_code == 0:
        #  exit(exit_code)

