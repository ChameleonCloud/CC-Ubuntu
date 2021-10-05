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
    'bionic': '18.04',
    'focal': '20.04',
}

VARIANTS = {
    'base': {
        'name-suffix': '',
        'extra-elements': '',
    },
    'gpu': {
        'name-suffix': '-',
        'extra-elements': 'cc-',
    },
    'arm64': {
        'name-suffix': '-ARM64',
        'extra-elements': 'block-device-efi',
    },
}


def main():
    parser = argparse.ArgumentParser(description='__doc__')

    parser.add_argument('-n', '--release', type=str, default='focal',
        choices=UBUNTU_RELEASES,
        help='Ubuntu release adjective name')
    parser.add_argument('-v', '--variant', type=str,
        choices=VARIANTS,
        help='Image variant to build')
    parser.add_argument('-c', '--cuda-version', type=str, default='cuda9',
        help='CUDA version to install. Ignore if the variant is not gpu.')
    parser.add_argument('-g', '--region', type=str, help='Region name')

    args = parser.parse_args()

    version_number = UBUNTU_RELEASES[args.release]
    variant_info = VARIANTS[args.variant]
    if args.variant == 'gpu':
        variant_info['name-suffix'] = variant_info['name-suffix'] + args.cuda_version.upper()
        variant_info['extra-elements'] = variant_info['extra-elements'] + args.cuda_version
    image_name = 'CC-Ubuntu{}{}'.format(version_number, variant_info['name-suffix'])
    env_updates = {
        'UBUNTU_ADJECTIVE': args.release,
        'UBUNTU_VERSION': version_number,
        'IMAGE_NAME': image_name,
        'EXTRA_ELEMENTS': variant_info['extra-elements'],
        'VARIANT': args.variant,
    }
    # os.exec*e obliterates current environment (was hiding DIB_CC_PROVENANCE)
    # so we need to include it, and may as well include it all to match how
    # CC-CentOS7 does it.
    env = os.environ.copy()
    env.update(env_updates)

    os.execle('create-image.sh', 'create-image.sh', env)


if __name__ == '__main__':
    sys.exit(main())
