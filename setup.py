#!/usr/bin/env python

"""The setup script."""
from setuptools import setup  #, find_packages

from src.mlb_statsapi import __author__, __email__, __version__

with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = []

setup_requirements = ['pytest-runner', ]

test_requirements = ['pytest>=3', ]

setup(
    author=__author__,
    author_email=__email__,
    python_requires='>=3.5',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: Apache Software License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
    ],
    description="This project generates an endpoint.event interface based on the MLB StatsAPI model",
    # entry_points={
    #     'console_scripts': [
    #         'mlb_statsapi=mlb_statsapi.cli:main',
    #     ],
    # },
    install_requires=requirements,
    license="Apache Software License 2.0",
    long_description=readme + '\n\n' + history,
    # package_data={"configs": ['configs/statsapi/**']},
    include_package_data=True,
    keywords='mlb_statsapi',
    name='mlb_statsapi',
    # packages=find_packages(include=['mlb_statsapi', 'mlb_statsapi.*']),
    setup_requires=setup_requirements,
    test_suite='tests',
    tests_require=test_requirements,
    url='https://github.com/power-edge/mlb_statsapi',
    version=__version__,
    zip_safe=False,
)
