"""Top-level package for MLB StatsAPI ETL App."""
import os

__author__ = 'Nikolaus Philip Schuetz'
__email__ = 'nikolauspschuetz@gmail.com'
__version__ = '0.1.0.dev2'

os.environ['AWS_PROFILE'] = 'nikolauspschuetz'  # todo

REGION = os.environ.get('REGION', 'us-west-2')
ENV = os.environ.get('ENV', f'mlb-statsapi-{REGION}')
DATA_BUCKET = os.environ.get("DATA_BUCKET", f"mlb-statsapi-etl-{REGION}-data")
