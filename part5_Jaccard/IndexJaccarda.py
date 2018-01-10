#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep  5 13:09:01 2017

@author: kuba
"""
from scipy.special import comb
import pysam 
import pickle
import sys


def binarySearch(alist, item):
    first = 0
    last = len(alist)-1
    found = -1
    while first<=last and found==-1:
        midpoint = (first + last)//2
        if alist[midpoint][0] == item:
            found = midpoint
        else:
            if item < alist[midpoint][0]:
                last = midpoint-1
            else:
                first = midpoint+1
	
    return alist[found][1]

probe = sys.argv[1]
expname1=sys.argv[2]
expname2=sys.argv[3]
name = probe+'_'+expname1
name2 = probe+'_'+expname2

indir = sys.argv[4]

with open(indir+'/%sZbOdczytow.pickle'%name, 'rb') as handle1:
    b = pickle.load(handle1)
#print("1")
with open(indir+'/%sZbOdczytow.pickle'%name2, 'rb') as handle2:
    d = pickle.load(handle2)
#print("2")
b=list(b)
d=list(d)
#print("3")
#b=sorted(b,key=lambda l:l[0],reverse=False)
#d=sorted(d,key=lambda l:l[0],reverse=False)
#print("5")
asss=set([i[0] for i in b])
bs=set([i[0] for i in d])
#for i in b:
#    asss.add(i[0])
#for i in d:
#    bs.add(i[0])
wspoole=list(bs.intersection(asss))
#print("5")
listaost=[0]*len(wspoole)
#print("6")
#lll=0



for ind,i in enumerate(wspoole):
    conb=binarySearch(b,i)
    cond=binarySearch(d,i)
    listaost[ind]=[i,conb,cond]
    #lll+=1
    #print(lll)


listaost= sorted(listaost, key = lambda x: (x[1], x[2]))
s11=0
s10=0
s01=0
lc1=1
lc2=1
s11temp=0
licznik=0
#print("7")
ost = len(listaost)-1
for ind,i in enumerate(listaost):
    #if ind==ost:
    #    break
    if ind == ost or listaost[ind+1][1]!=i[1]:
        if lc1==1:
            continue
        else:
            if lc2>1:
                s11temp+=comb(lc2,2)
            pods=comb(lc1,2)
            s10+=(pods-s11temp)
            s11+=s11temp
            lc1=1
            lc2=1
            s11temp=0
    else:
        lc1+=1
        if listaost[ind+1][2]==i[2]:
            lc2+=1
        else:
            if lc2>1:
                s11temp+=comb(lc2,2)
                lc2=1
    licznik+=1
    #print(licznik)
listaost= sorted(listaost, key = lambda x: (x[2], x[1]))
for ind,i in enumerate(listaost):
    #if ind==len(listaost)-1:
    #    break
    if ind == ost or listaost[ind+1][2]!=i[2]:
        if lc1==1:
            continue
        else:
            if lc2>1:
                s11temp+=comb(lc2,2)
            #s11temp+=comb()
            pods=comb(lc1,2)
            s01+=(pods-s11temp)
            lc1=1
            lc2=1
            s11temp=0
    else:
        lc1+=1
        if listaost[ind+1][1]==i[1]:
            lc2+=1
        else:
            if lc2>1:
                s11temp+=comb(lc2,2)
                lc2=1
    licznik+=1
    #print(licznik)
#print(s11, s10, s01)
indexJacckarda=s11/(s11+s10+s01)
wsp=1.0*len(wspoole)
#print("probe\tname1\tname2\tcommonreads\t%common1\t%common2\ts11\ts10\ts01\tJaccardindex")
print("%s\t%s\t%s\t%d\t%.4f\t%.4f\t%d\t%d\t%d\t%.6f"%(probe, expname1, expname2, wsp, wsp/len(asss), wsp/len(bs), s11, s10, s01, indexJacckarda))


