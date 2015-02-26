#!/usr/bin/env python

import sys, getopt, fnmatch, os, subprocess, platform, string, re
global arch, system

arch = platform.machine()
system = platform.system()

# --------------------- Setting command lines options 
def main(argv):
   global compiler, build_type, op_sys, external, rootDir, targetDir, packs, destination

   build_type = ''
   op_sys = ''
   external = ''
   packs = ''
   compiler = ''
   destination = ''

   opts, args = getopt.getopt(argv,"hc:b:o:v:p:t:")
   for opt, arg in opts:
      if opt == '-h':
         print 'setup.py -c <compiler> -b <build_type> -o <operating_system> -v <external> -p <list of packages> -t <destination>'
         sys.exit()
      elif opt in ("-c"):
         compiler = arg

      elif opt in ("-b"):
         build = arg

      elif opt in ("-o"):
         op_sys = arg

      elif opt in ("-v"):
         external = arg

      elif opt in ("-p"):
         packs = arg

      elif opt in ("-t"):
         destination = arg


   if build == 'Release' : build_type = 'opt'
   elif build == 'Debug' : build_type = 'dbg'
   elif build == 'Optimized' : build_type = 'opt'
   else : build_type = 'unk'

   rootDir = "/afs/cern.ch/user/s/sftnight/tmp/"+external 
   targetDir = "/afs/cern.ch/sw/lcg/hepsoft/"+destination+"/"+arch+"-"+op_sys+"-"+compiler+"-"+build_type+"/"
# --------------------- Setting the targets
def targets():

   words = packs.split()
   return words;

# --------------------- Setting names of the main tree directory 

def directories():
   dir_hash = []

   for dirs in os.listdir(rootDir):
      if os.path.isfile(dirs):
         pass
      else:
         dir_hash.append(dirs)
   return dir_hash;      

# --------------------- Setting paths  
def directory_names():

   dir_hash = directories()
   pkg_hash = targets()

   for j in range(0,len(pkg_hash)):

      for i in dir_hash:

         fullpath = rootDir+"/"+i
         if pkg_hash[j] in fullpath:
            for dirName, subdirList, fileList in os.walk(fullpath):   

               for name in subdirList:
                  if ((name.find(compiler) != -1) and (name.find(build_type) != -1) and (name.find(op_sys) != -1)):
                     directory =  os.path.join(dirName, name)
                     if "castor" in directory:
                        directory = directory + '/usr'
                     cmd = "cp -r %s/* %s"%(directory,targetDir)

                     os.system(cmd)

# -------------------------------------------------------------------------------------------------

if __name__ == "__main__":

   main(sys.argv[1:])

   targets()
   directory_names()


