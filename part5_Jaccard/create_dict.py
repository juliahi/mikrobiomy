#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug  8 13:41:05 2017

@author: kuba
"""

import pickle
import pysam
import sys

bamname = sys.argv[1]
name = sys.argv[2]
outdir = sys.argv[3]

AF=pysam.AlignmentFile(bamname,'rb')
#it=AF.fetch(until_eof=True)
#l=[]
#i=0
#for r in AF.header['SQ']:
#    l.append([r['SN'],[0]])
#    #s.append(r['SN'])
#    #zb1.add(read.qname)
#    i+=1
#print("ss")

s=set()

last=None

#for read in AF.fetch(until_eof=True):
#  if not read.is_unmapped:
#    if not read.is_secondary:
#      if last != None:
#        s.add(last)
#      last = (read.qname,read.reference_name)
#    else:
#      last = None
  
#if last != None:
#  s.add(last)


for read in AF.fetch(until_eof=True):
    if not read.is_unmapped:
        if not read.is_secondary:
            s.add((read.qname,read.reference_name))


s = sorted(list(s), key=lambda l:l[0],reverse=False)


#with open('%sContigi.pickle'%name, 'wb') as handle:
#    pickle.dump(l, handle, protocol=pickle.HIGHEST_PROTOCOL)
with open(outdir+'/%sZbOdczytow.pickle'%name, 'wb') as handle:
    pickle.dump(s, handle, protocol=pickle.HIGHEST_PROTOCOL)
