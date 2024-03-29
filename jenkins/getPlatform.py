import os, platform, re, subprocess

arch = platform.machine()

system = platform.system()

def parse_osrelease_line(line):
   k, v = line.split('=')
   return k, v.strip('"')

#---Determine the OS and version--------------------------------------
if system == 'Darwin' :
   osvers = 'mac' + ''.join(platform.mac_ver()[0].split('.')[:2])
elif system == 'Linux' :
   lines = []
   with open('/etc/os-release') as f:
      lines = f.readlines()
   parsed = dict(
      parse_osrelease_line(line.strip())
      for line in lines
      if '=' in line
   )

   dist = [ parsed['NAME'], parsed['VERSION_ID'] ]
   if re.search('SLC', dist[0]):
      osvers = 'slc' + dist[1].split('.')[0]
   elif re.search('CentOS', dist[0]):
      osvers = 'centos' + dist[1].split('.')[0]
   elif re.search('Scientific', dist[0]):
      if dist[1].split('.')[0] >= '7':
         osvers = 'centos' + dist[1].split('.')[0]
      else:
         osvers = 'slc' + dist[1].split('.')[0]
   elif re.search('Ubuntu', dist[0]):
      osvers = 'ubuntu' + dist[1].split('.')[0] + dist[1].split('.')[1]
   elif re.search('Fedora', dist[0]):
      osvers = 'fedora' + dist[1].split('.')[0]
   elif re.search('Debian', dist[0]):
      osvers = 'debian' + dist[1]
   else:
      osvers = 'linux'
elif system == 'Windows':
   osvers = win + platform.win32_ver()[0]
else:
   osvers = 'unk-os'

#---Determine the compiler and version--------------------------------
if os.getenv('COMPILER') and os.getenv('COMPILER') not in ['native', 'classic'] and not os.getenv("CC"):
  compiler = os.getenv('COMPILER')
else:
  if os.getenv('CC'):
    ccommand = os.getenv('CC')
  elif system == 'Windows':
    ccommand = 'cl'
  elif system == 'Darwin':
    ccommand = 'clang'
  else:
    ccommand = 'gcc'
  if ccommand == 'cl':
    versioninfo = os.popen(ccommand).read()
    patt = re.compile('.*Version ([0-9]+)[.].*')
    mobj = patt.match(versioninfo)
    compiler = 'vc' + str(int(mobj.group(1))-6)
  elif ccommand.startswith('gcc') or ccommand.endswith('gcc'):
     versioninfo = os.popen(ccommand + ' -dumpversion').read()
     patt = re.compile('([0-9]+)\\.([0-9]+)')
     mobj = patt.match(versioninfo)
     if mobj == None :
        pattn = re.compile('([0-9]+)')
        mobjn = pattn.match(versioninfo)
        compiler = 'gcc' + mobjn.group(1)
     else:
        compiler = 'gcc' + mobj.group(1) + mobj.group(2)
  elif ccommand.endswith('clang'):
     versioninfo = os.popen(ccommand + ' --version').read()
     patt = re.compile('.*version ([0-9]+)[.]([0-9]+)')
     mobj = patt.match(versioninfo)
     compiler = 'clang' + mobj.group(1) + mobj.group(2)
  elif ccommand == 'icc':
     versioninfo = os.popen(ccommand + ' -dumpversion').read()
     patt = re.compile('([0-9]+)')
     mobj = patt.match(versioninfo)
     compiler = 'icc' + mobj.group(1)
  else:
     compiler = 'unk-cmp'

#---Determine build type-------------------------------------------
if os.getenv('BUILDTYPE'):
   buildtype = os.getenv('BUILDTYPE')
else:
   buildtype = 'Release'

if buildtype == 'Release' : bt = 'opt'
elif buildtype == 'Debug' : bt = 'dbg'
elif buildtype == 'Optimized' : bt = 'fst'
else : bt = 'unk'

print('%s-%s-%s-%s' %  (arch, osvers, compiler, bt))
