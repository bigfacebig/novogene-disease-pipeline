#!/usr/bin/env python
# -*- coding=utf-8 -*-
import os
import sys
import json
import argparse

try:
    import fuzzywuzzy.process
    import colorama
except ImportError:
    sys.path.append('/ifs/TJPROJ3/DISEASE/share/Software/python/site-packages')
    import fuzzywuzzy.process
    import colorama


# colorama needs init before used
colorama.init()


BASE_DIR = os.path.dirname(os.path.realpath(__file__))
DEAULT_DB = os.path.join(BASE_DIR, 'DisGeNet.json')


def addFore(text, color=colorama.Fore.CYAN):
    return '%s%s%s' % (color, text, colorama.Fore.RESET)


def getDoID(diseaseName, data=DEAULT_DB):

    print 'Use disease data: %s' % addFore(data, colorama.Fore.BLUE)

    with open(data) as f:
        diseaseDict = json.load(f)

    result = fuzzywuzzy.process.extractBests(diseaseName, diseaseDict.keys())
    disease, score = result[0]
    DoID = diseaseDict.get(disease)
    print 'Your input disease name: %s' % addFore(diseaseName)
    print 'Matched disease: %s[DoID:%s] (sorce:%s)' % (addFore(disease, colorama.Fore.YELLOW), addFore(DoID, colorama.Fore.RED), score)
    if int(score) < 90:
        print 'But the score is too low, maybe you should try again with another name'
    # elif int(score) < 100:
    if int(score) < 95:
        print 'Other matched results: \n\t%s\n\t%s\n\t%s\n\t%s ' % tuple(
            map(
                lambda x: '{disease}[DoID:{doid}] (score:{score})'.format(
                    disease = addFore(x[0], colorama.Fore.YELLOW),
                    doid = addFore(diseaseDict.get(x[0]), colorama.Fore.RED),
                    score = x[1]
                ),
                result[1:6]
            )
        )

    return DoID


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        prog='getDoID',
        description='get the disease id for given disease name',
        epilog='contact: suqingdong@novogene.com')

    parser.add_argument('disease_name', help='the input disease name', nargs='*')
    parser.add_argument('-db', '--database', help='the database to search[default=%(default)s]', default=DEAULT_DB)

    args = vars(parser.parse_args())

    if not args['disease_name']:
        parser.print_help()
        exit(1)

    getDoID(' '.join(args['disease_name']), args['database'])
