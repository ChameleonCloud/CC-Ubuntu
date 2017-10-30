#!/usr/bin/env python
'''
Called by <abracadabra repo>/ccbuild.py so should exist. Because
the Ubuntu DIB element automatically gets the newest image, there
isn't as much to do here relative to the CC-CentOS7 image...
'''
import argparse
import os
import sys


def main():
    parser = argparse.ArgumentParser(description='__doc__')

    parser.add_argument('-r', '--revision', type=str, default='',
        help='Ignored parameter. Element chooses latest image.')
    parser.add_argument('variant', type=str,
        help='Image variant to build')

    args = parser.parse_args()

    os.execl('create-image.sh', 'create-image.sh', args.variant)


if __name__ == '__main__':
    sys.exit(main())
