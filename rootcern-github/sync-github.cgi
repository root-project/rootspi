#!/usr/bin/python
# axel@cern.ch, August 2018

import cgi
import hmac
import hashlib
import json
import os
import subprocess
import sys
import githubsecret

DEBUG = False
if DEBUG:
  import cgitb
  cgitb.enable()
  sys.stderr = sys.stdout
  print "Content-Type: text/html"
  print ""
  print "<PRE>"
  sys.stdout.flush()
  subprocess.call(['env'])

out=''

try:
  sys.stderr = sys.stdout
  # Get payload
  json_payload = sys.stdin.read()
  if DEBUG:
    print json_payload

  # Validate.
  secret = githubsecret.secret
  signature = 'sha1=' + hmac.new(secret, json_payload, hashlib.sha1).hexdigest()

  if signature == os.environ['HTTP_X_HUB_SIGNATURE']:
    # Fetch.
    payload = json.loads(json_payload)
    repo = payload['repository']['name']
    githome = os.environ['GIT_PROJECT_ROOT']
    os.chdir(githome + '/' + repo + '.git/')

    if DEBUG:
      print "Content-Type: text/html"
      print
      sys.stdout.flush()
      subprocess.call(['/usr/bin/git', 'fetch', '--all', '--prune'], stderr = subprocess.STDOUT)
    else:
      pipe = subprocess.Popen(['/usr/bin/git', 'fetch', '--all', '--prune'] ,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1)
      outFetch = ""
      errFetch = ""
      with pipe.stdout:
        for line in iter(pipe.stdout.readline, b''):
          outFetch += line.decode()
      with pipe.stderr:
        for line in iter(pipe.stderr.readline, b''):
          errFetch += line.decode()
      exitcodeFetch = pipe.wait()

      exitcodeNotifier = 0
      outNotifier = ""
      postrec_stdin = None

      if os.environ['HTTP_X_GITHUB_EVENT'] == 'push':
        postrec_stdin = payload["before"] + ' ' + payload["after"] + ' ' + payload["ref"];
        gcn = subprocess.Popen(['/usr/local/bin/git-commit-notifier',
                                '/etc/git-hooks/git-notifier-config-' + repo + '.yml'],
                               stdout = subprocess.PIPE, stdin=subprocess.PIPE)
        outNotifier = gcn.communicate(postrec_stdin)
        exitcodeNotifier = gcn.wait()

      if exitcodeFetch == 0 and exitcodeNotifier == 0:
        # Response.
        print "Content-Type: text/html"
        print
        print 'Called git fetch in ' + os.getcwd() + ':<br/>'
        print '<pre>'
        print outFetch
        print errFetch
        print "HTTP_X_GITHUB_EVENT:" , os.environ['HTTP_X_GITHUB_EVENT']
        print '</pre>'

        if postrec_stdin:
          print 'Invoking commit notifier &lt; ' + postrec_stdin + '<br/>'
          print '<pre>'
          print outNotifier[0].decode()
          if outNotifier[1]:
            print outNotifier[1].decode()
          print '</pre>'
        print 'DONE.'
      else:
        print 'Status: 500 Server Error'
        print
        if exitcodeFetch != 0:
          print "Fetch failed:"
          print '<pre>'
          print outFetch
          print errFetch
          print '</pre>'
          print
        if exitcodeNotifier != 0:
          print "Notification failed:"
          print '<pre>'
          print outNotifier[0].decode()
          if outNotifier[1]:
            print outNotifier[1].decode()
          print '</pre>'
        
  else:
    # Signature mismatch.
    print 'Status: 403 Forbidden'
    print
    print "signature=" + signature + "<br/>"
    print "os.environ=" + os.environ['HTTP_X_HUB_SIGNATURE']


except Exception as inst:
    # General error.
    print 'Status: 500 Server Error'
    print
    print "\n\n"
    print type(inst)
    print inst.args
    print inst
    print "\n\n"
    print out
    print "\n\n"
    import getpass
    print "USER: " + getpass.getuser()
    import traceback
    traceback.print_exc()

