"""
created by nikos at 5/2/21
"""
import logging
import os

root = logging.getLogger('mlb_statsapi')
root.setLevel(logging.INFO)
console = logging.StreamHandler()
logging_format = ' '.join([
    '[%(asctime)s]',
    '{%(filename)s:%(lineno)d}',
    '%(name)s',
    '%(processName)s.%(threadName)s',
    '%(levelname)s',
    '-',
    '%(message)s'
])
bf = logging.Formatter(logging_format)
console.setFormatter(bf)
root.addHandler(console)
root.propagate = os.environ.get('AIRFLOW_CTX_EXECUTION_DATE') is None


class LogMixin:

    @property
    def log(self):
        try:
            return self._log
        except AttributeError:
            # noinspection PyAttributeOutsideInit
            self._log = logging.root.getChild(
                self.__class__.__module__ + '.' + self.__class__.__name__
            )
            return self._log
