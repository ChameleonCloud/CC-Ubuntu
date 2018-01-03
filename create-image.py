#!/usr/bin/env python
'''
Called by <abracadabra repo>/ccbuild.py so should exist. Because
the Ubuntu DIB element automatically gets the newest image, there
isn't as much to do here relative to the CC-CentOS7 image...
'''
import argparse
import os
import sys

UBUNTU_RELEASES = {
    'trusty': '14.04',
    'xenial': '16.04',
    'bionic': '18.04',
}

VARIANTS = {
    'base': {
        'name-suffix': '',
        'extra-elements': '',
    },
    'gpu': {
        'name-suffix': '-CUDA8',
        'extra-elements': 'cc-cuda',
    },
}


def main():
    parser = argparse.ArgumentParser(description='__doc__')

    parser.add_argument('-r', '--revision', type=str, default='',
        help='Ignored parameter. Element chooses latest image.')
    parser.add_argument('-n', '--release', type=str, default='xenial',
        choices=['trusty', 'xenial', 'artful'],
        help='Ubuntu release adjective name')
    parser.add_argument('variant', type=str,
        help='Image variant to build')

    args = parser.parse_args()

    version_number = UBUNTU_RELEASES[args.release]
    variant_info = VARIANTS[args.variant]
    image_name = 'CC-Ubuntu{}{}'.format(version_number, variant_info['name-suffix'])
    env_updates = {
        'UBUNTU_ADJECTIVE': args.release,
        'UBUNTU_VERSION': version_number,
        'IMAGE_NAME': image_name,
        'EXTRA_ELEMENTS': variant_info['extra-elements'],
    }
    # os.exec*e obliterates current environment (was hiding DIB_CC_PROVENANCE)
    # so we need to include it, and may as well include it all to match how
    # CC-CentOS7 does it.
    env = os.environ.copy()
    env.update(env_updates)

    os.execle('create-image.sh', 'create-image.sh', env)


if __name__ == '__main__':
    sys.exit(main())
