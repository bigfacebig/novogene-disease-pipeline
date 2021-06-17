#!/usr/bin/python
import sys

if len(sys.argv) < 5:
    print "usage: python $0 depthSTAT flagSTAT sample seq_strategy> out"
    sys.exit()

info = sys.argv[1]
flag = sys.argv[2]
sampleID = sys.argv[3].strip()
celue = sys.argv[4].strip()

print "Sample:\t"+sampleID

for i in open(flag):
    if celue != 'WGS':
        if i.startswith('With mate mapped'):continue
        print i.strip()
    else:
        print i.strip()
for i in open(info):
    print i.strip().split('|')[0]
