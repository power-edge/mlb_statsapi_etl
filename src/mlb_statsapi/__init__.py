"""Top-level package for MLB StatsAPI ETL App."""
import os

__author__ = 'Nikolaus Philip Schuetz'
__email__ = 'nikolauspschuetz@gmail.com'
__version__ = '0.1.0.dev2'

os.environ['AWS_PROFILE'] = 'nikolauspschuetz'  # todo

ENV = os.environ.get('ENV', 'dev')
REGION = os.environ.get('REGION', 'us-west-1')
