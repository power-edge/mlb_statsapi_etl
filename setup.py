#!/usr/bin/env python

"""The setup script."""
import setuptools
from setuptools import setup
from src.mlb_statsapi import __author__, __email__, __version__

# with open('README.rst') as readme_file:
#     readme = readme_file.read()

# with open('HISTORY.rst') as history_file:
#     history = history_file.read()

install_requires = [
    "botocore==1.20.100",
    "boto3==1.17.100",
    'requests==2.25.1',
    'serde==0.8.1',
    "pytz==2021.1",
    "PyYAML==5.4.1",
    'python-dateutil==2.8.1'
]

setup_requirements = ['pytest-runner', ]

test_requirements = [
    'pytest>=3',
    "mock==4.0.3"
]

setup(
    name='mlb_statsapi_etl',
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
    install_requires=install_requires,
    license="Apache Software License 2.0",
    # long_description=readme + '\n\n' + history,
    include_package_data=True,
    keywords='mlb_statsapi',
    # packages=find_packages(include=['mlb_statsapi', 'mlb_statsapi.*']),
    setup_requires=setup_requirements,
    test_suite='tests',
    tests_require=test_requirements,
    url='https://github.com/power-edge/mlb_statsapi_etl',
    version=__version__,
    zip_safe=False,
    packages=setuptools.find_packages("./src"),
    package_data={"configs": [
        'configs/statsapi/**',
        "configs/endpoint-model.yaml"
    ]},
    package_dir={
        "": "src"
    }
)
