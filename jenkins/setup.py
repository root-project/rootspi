#!/usr/bin/env python

from __future__ import print_function
import sys, getopt, fnmatch, os, subprocess, platform, string, re

global arch, system

arch = platform.machine()
system = platform.system()

def warning(*objs):
   print("WARNING: ", *objs, file=sys.stderr)
def info(*objs):
   print("INFO: ", *objs, file=sys.stderr)

# --------------------- Setting command lines options 
def main(argv):
   global compiler, build_type, op_sys, external, rootDir
   global comp, build

   compiler = ''
   build_type = ''
   op_sys = ''
   external = ''
   build = ''
   comp = ''

   opts, args = getopt.getopt(argv,"hc:b:o:v:")
   for opt, arg in opts:
      if opt == '-h':
         print('setup.py -c <compiler> -b <build_type> -o <operating_system> -v <external>')
         sys.exit()
      elif opt in ("-c"):
         comp = arg

      elif opt in ("-b"):
         build = arg

      elif opt in ("-o"):
         op_sys = arg

      elif opt in ("-v"):
         external = arg

   
   if build == 'Release' : build_type = 'opt'
   elif build == 'Debug' : build_type = 'dbg'
   elif build == 'Optimized' : build_type = 'opt'
   else : build_type = 'unk'

   if comp == 'clang34' : 
      compiler = 'gcc48'
   elif comp == 'clang35' :
      compiler = 'gcc49'   
   elif comp == 'clang36' :
      compiler = 'gcc49'
   else :
      compiler = comp

   if os.getenv('EXTERNALDIR'):  externalDir = os.getenv('EXTERNALDIR')
   else:                         externalDir = '/afs/cern.ch/sw/lcg/app/releases/ROOT-externals'
   rootDir = os.path.join(externalDir,external)


# --------------------- Setting default OS 
def default_os():
   if system == 'Darwin' :
      osvers = 'mac' + string.join(platform.mac_ver()[0].split('.')[:2],'')
   elif system == 'Linux' :
      dist = platform.linux_distribution()
      if re.search('SLC', dist[0]):
         osvers = 'slc' + dist[1].split('.')[0]
      elif re.search('CentOS', dist[0]):
         osvers = 'cc' + dist[1].split('.')[0]
      elif re.search('Ubuntu', dist[0]):
         osvers = 'ubuntu' + dist[1].split('.')[0]
      elif re.search('Fedora', dist[0]):
         osvers = 'fedora' + dist[1].split('.')[0]
      else:
         osvers = 'linux' + string.join(platform.linux_distribution()[1].split('.')[:2],'')
   elif system == 'Windows':
      osvers = win + platform.win32_ver()[0]
   else:
      osvers = 'unk-os'

   return osvers;

# --------------------- Setting default compiler 

def default_compiler():

   if os.getenv('COMPILER'):
      compiler_orig = os.getenv('COMPILER')
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
         compiler_orig = 'vc' + str(int(mobj.group(1))-6)
      elif ccommand == 'gcc':
         versioninfo = os.popen(ccommand + ' -dumpversion').read()
         patt = re.compile('([0-9]+)\\.([0-9]+)')
         mobj = patt.match(versioninfo)
         compiler_orig = 'gcc' + mobj.group(1) + mobj.group(2)
      elif ccommand == 'clang':
         versioninfo = os.popen4(ccommand + ' -v')[1].read()
         patt = re.compile('.*version ([0-9]+)[.]([0-9]+)')
         mobj = patt.match(versioninfo)
         compiler_orig = 'clang' + mobj.group(1) + mobj.group(2)
      elif ccommand == 'icc':
         versioninfo = os.popen(ccommand + ' -dumpversion').read()
         patt = re.compile('([0-9]+)')
         mobj = patt.match(versioninfo)
         compiler_orig = 'icc' + mobj.group(1) + mobj.group(2)
      else:
         compiler_orig = 'unk-cmp'
   return compiler_orig;         

# --------------------- Setting default built type 

def default_bt():
   if os.getenv('BUILDTYPE'):
      buildtype = os.getenv('BUILDTYPE')
   else:
      buildtype = 'Release'
      
   if buildtype == 'Release' : bt = 'opt'
   elif buildtype == 'Debug' : bt = 'dbg'
   elif buildtype == 'Optimized' : bt = 'opt'
   else : bt = 'unk'

   return bt;   

# --------------------- Setting names of the main tree directory 

def directories():
   dir_hash = []
   for d in os.listdir(rootDir):
      if os.path.isdir(os.path.join(rootDir,d)):
         if d in ('MCGenerators', 'Grid') :
             for s in os.listdir(os.path.join(rootDir,d)):
                 if os.path.isdir(os.path.join(rootDir,d,s)) :
                     dir_hash.append(os.path.join(d,s))
         else :
             dir_hash.append(d)
   return dir_hash;      

# --------------------- Setting paths  

def directory_names():
   str = ":"
   dirlist = []
   binlist = []
   liblist = []
   dir_hash = directories()

   Flag = False
   subFlagbins = False
   
   platform_patt = re.compile('%s-%s-%s-(%s|opt)' % (arch, op_sys, compiler, build_type))
   dummy_patt = re.compile('(x86_64|i686)-(.*)-(.*)-(.*)')
   
   for i in dir_hash:

      fullpath = rootDir+"/"+i

      for dirName, subdirList, fileList in os.walk(fullpath):   
         subdirList.sort()   # -dbg will be checked first than -opt. Taking -opt will only be fallback 
         for name in subdirList:
            if platform_patt.match(name) :
               Flag = True
               directory =  os.path.join(dirName, name)
               if "castor" in directory:
                  directory = directory + '/usr'
               if "alien" in directory:
                  directory = directory + '/api'
               dirlist.append(directory);
               for subdirName, subsubdirList, fileList2 in os.walk(directory):
                  for name2 in sorted(subsubdirList):
                     if (name2 == "lib" or name2 == "lib64"):
                        subFlaglibs = True
                        libs = directory+"/"+name2
                        liblist.append(libs)
                        break
                     elif (name2 == "bin"):
                        subFlagbins = True
                        bins = directory+"/"+name2
                        binlist.append(bins)
                     else:
                        subFlaglibs = False
                  if (subFlaglibs):break         
               break
            elif dummy_patt.match(name) :
               Flag = True   
            else:
               Flag = False
         if Flag : break

   all_dirs = (sorted(dirlist), binlist, liblist)

   return all_dirs;

if __name__ == "__main__":

   main(sys.argv[1:])

   if not compiler or compiler == 'native':
      compiler = default_compiler()

   if not build_type:
      build_type = default_bt()

   if not op_sys:
      op_sys = default_os()

   # txt_directory is not used anymore.
   txt_directory = rootDir+"/"+arch+"-"+op_sys+"-"+compiler+"-"+build_type+".txt"

   if os.path.exists(txt_directory):
      fh = open(txt_directory, "r")
      env_var = fh.readlines()
      fh.close()

      prefix = env_var[0].rstrip('\r\n')
      path = env_var[1].rstrip('\r\n')+":"+os.environ["PATH"]
      ld_libs = env_var[2].rstrip('\r\n')+":"+os.environ["LD_LIBRARY_PATH"] 

      print(prefix)
      print(path)
      print(ld_libs)

   else:
      if os.path.exists(rootDir):
         prefix, path, ld_libs = directory_names()
         if os.getenv('PATH') : path.append(os.getenv('PATH'))
         if system == 'Darwin':
            if os.getenv('DYLD_LIBRARY_PATH') : ld_libs.append(os.getenv('DYLD_LIBRARY_PATH'))
         else:
            if os.getenv('LD_LIBRARY_PATH') : ld_libs.append(os.getenv('LD_LIBRARY_PATH'))

         print('%s=%s' % ("export CMAKE_PREFIX_PATH", ':'.join(prefix)))
         print('%s=%s' % ("export PATH", ':'.join(path)))
         if system == 'Darwin' :
            print('%s=%s' % ("export DYLD_LIBRARY_PATH", ':'.join(ld_libs)))
         else :
            print('%s=%s' % ("export LD_LIBRARY_PATH", ':'.join(ld_libs)))
      else:
         info("No externals in /afs for this platform / build combination!")


