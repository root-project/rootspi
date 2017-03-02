#!/usr/bin/env python
from __future__ import print_function 
import os, sys, platform, string, re


arch = platform.machine()
system = platform.system()

if len(sys.argv) < 2 :
  print('Usage: getCompatible.py <platform>')
  sys.exit(1)

platform =  sys.argv[1]

#x86_64-slc6-gcc44-fst
arch, osvers, compiler, btype = platform.split('-')

new_arch =  arch
new_osvers = osvers

if   (compiler == 'clang34') : new_compiler = 'gcc48'
elif (compiler == 'clang35') : new_compiler = 'gcc49'
elif (compiler == 'clang36') : new_compiler = 'gcc49'
elif (compiler == 'clang39') : new_compiler = 'gcc49'
elif (compiler.startswith('clang_gcc')) : new_compiler = compiler[6:]
elif (compiler == 'icc') : new_compiler = 'gcc48'
elif (compiler == 'icc14') : new_compiler = 'gcc48'
elif (compiler == 'icc15') : new_compiler = 'gcc49'
elif (compiler == 'icc16') : new_compiler = 'gcc49'
elif (compiler == 'icc17') : new_compiler = 'gcc62'
else : new_compiler = compiler

if   (btype == 'dbg') : new_btype = 'opt'
elif (btype == 'fst') : new_btype = 'opt'
else :  new_btype = btype

new_platform = '-'.join([new_arch, new_osvers, new_compiler, new_btype])
print(new_platform)
