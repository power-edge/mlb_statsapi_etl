"""
created by nikos at 5/2/21
"""
import json
import os
from functools import wraps

import boto3
import requests
import tarfile
import zipfile
import gzip

from mlb_statsapi import DATA_BUCKET
from .log import LogMixin
from .endpoint_config import EndpointConfig

class StatsAPIObject(LogMixin):
    """
    Top-level dir* for to stash each endpoint, where (file_)path will also correspond to the statsapi.mlb.com/api space.
    As these are unique per object they map to a NoSQL keyspace as well
    """

    base_url_path = r'https://statsapi.mlb.com/api'
    base_file_path = os.environ.get('MLB_STATSAPI__BASE_FILE_PATH', './.var/local/mlb_statsapi')

    bucket = DATA_BUCKET

    def __init__(
        self,
        endpoint,
        api,
        operation,
        path_params=None,
        query_params=None
    ):
        super(StatsAPIObject, self).__init__()
        self.endpoint = endpoint
        self.api = api
        self.operation = operation
        self.path_params, self.query_params = dict((path_params or {}).items()), dict((query_params or {}).items())
        self.path = resolve_path(self.api, self.operation, path_params, query_params)
        self.keyspace = f"{self.endpoint.get_name()}/api" + self.path
        self.file_path = os.path.realpath(f"{self.base_file_path}/{self.keyspace}.json")
        self.url = self.base_url_path + self.path  # path should start with /
        # noinspection PyTypeChecker
        self.obj: dict = None

    def __repr__(self):
        return '{cls}(endpoint={endpoint}, api={api}, path={path})'.format(
            cls=self.__class__.__name__,
            endpoint=self.endpoint.get_name(),
            api=self.api.description,
            path=self.path
        )

    @property
    def exists(self):
        exists_is_true = os.path.isfile(self.file_path)
        return exists_is_true

    def get(self):
        response = requests.get(self.url, headers={'Accept-Encoding': 'gzip'})
        status_code = response.status_code
        assert status_code == 200, f'get {self.url} failed with status {status_code}: {response.content.decode()}'
        self.obj = response.json()
        if isinstance(self.obj, dict) and ("copyright" in self.obj.keys()):
            self.obj.pop("copyright")
        self.log.debug("got %s from %s" % (self, self.url))
        return self

    def load(self, ext='json.gz'):
        if ext == 'json':
            with open(self.file_path, 'r') as f:
                self.obj = json.load(f)
            print("loaded %s from %s" % (self, self.file_path))
        elif ext == 'json.gz':
            with gzip.open(self.gz_path, 'r') as f:  # 4. gzip
                self.obj = json.loads(f.read().decode('utf-8'))
            print("loaded %s from %s" % (self, self.gz_path))
        else:
            raise NotImplementedError("reading from %s is not supported" % ext)
        return self

    def prefix(self, ext='json.gz'):
        return f"{self.keyspace}.{ext}"

    def upload_file(self, ext='json.gz', client=None):
        from mlb_statsapi.utils.aws import S3
        kwargs = {
            'Filename': {
                'json': self.file_path,
                'json.gz': self.gz_path,
                'json.tar.gz': self.tar_gz_path
            }[ext],
            'Bucket': self.bucket,
            'Key': self.prefix(ext)
        }
        return S3(client or boto3.client('s3')).upload_file(**kwargs)

    def dumps(self, indent=0) -> str:
        return json.dumps(self.obj, indent=indent)

    def download_file(self, ext='json.gz', client=None):
        kwargs = {
            'Filename': {
                'json': self.file_path,
                'json.gz': self.gz_path,
                'json.tar.gz': self.tar_gz_path
            }[ext],
            'Bucket': self.bucket,
            'Key': self.prefix(ext)
        }
        return S3(client or boto3.client('s3')).download_file(**kwargs)

    def save(self):
        if not os.path.isdir(os.path.dirname(self.file_path)):
            os.makedirs(os.path.dirname(self.file_path))
        with open(f"{self.file_path}", 'w') as f:
            f.write(json.dumps(self.obj))
        print("saved %s to %s" % (self, self.file_path))
        # os.chmod(self.file_path, stat.S_IREAD)

    def tar(self):
        tf = tarfile.open(self.tar_gz_path, mode="w:gz")
        tf.add(self.file_path)
        tf.close()
        print(f"gzipped {self.tar_gz_path}")

    def gzip(self):
        if not os.path.isdir(os.path.dirname(self.file_path)):
            os.makedirs(os.path.dirname(self.file_path))
        with gzip.open(self.gz_path, 'wb') as f:
            f.write(json.dumps(self.obj).encode('utf-8'))
        print("gzipped %s to %s" % (self, self.gz_path))

    @property
    def tar_gz_path(self):
        return f"{self.file_path}.tar.gz"

    @property
    def gz_path(self):
        return f"{self.file_path}.gz"


def resolve_path(api, operation, path_params=None, query_params=None):
    path_params, query_params = path_params or {}, query_params or {}
    path = api.path
    assert isinstance(path_params, dict)
    assert isinstance(query_params, dict)
    assert path[0] == '/'

    # PATH PARAMS
    fmt_path_params = {}
    for path_param in operation.path_params:
        param_name = path_param.name
        assert not (path_param.required and (param_name not in path_params)), 'path_param %s is required' % param_name
        if param_name in path_params:
            arg_val = path_params.pop(param_name)
            if isinstance(arg_val, list):
                assert len(arg_val) == 1, 'Multiple %s not allowed, found %s' % (param_name, str(arg_val))
                arg_val = arg_val[0]
            arg_val = str(arg_val)
            if path_param.enum is not None:
                enums = {*map(str.lower, path_param.enum)}
                assert arg_val in enums, ("Unrecognized %s %s choice:'%s'. Please choose from [%s]" % (
                    operation.nickname, param_name, arg_val, ', '.join(enums)))
            fmt_path_params[param_name] = arg_val
    assert not path_params, "Unrecognized %s path_params: '%s'. Please choose from [%s]" % (
        operation.nickname, "', '".join(path_params.keys()), ", ".join([p.name for p in operation.path_params]))

    # resolve path elements
    path = os.path.join(
        path,
        *[value for param, value in fmt_path_params.items() if (r'{%s}' % param) not in path]
    ).format(**{param: value for param, value in fmt_path_params.items() if (r'{%s}' % param) in path})

    # QUERY PARAMS
    fmt_query_params = {}
    for query_param in operation.query_params:
        param_name = query_param.name
        assert not (query_param.required and (param_name not in query_params)), "%s query_param '%s' is required!" % (
            operation.nickname, param_name)
        if param_name in query_params:
            arg_val = query_params.pop(param_name)
            if isinstance(arg_val, list):
                assert (len(arg_val) == 1) or query_param.allowMultiple, f'multiple {param_name} not allowed, got %s' % arg_val
                arg_val = ','.join([*map(str, arg_val)])
            else:
                arg_val = str(arg_val)
            fmt_query_params[param_name] = arg_val
    assert not query_params, "Unrecognized %s query_params: '%s'. Please choose from [%s]" % (
        operation.nickname, "', '".join(query_params.keys()), ", ".join([qp.name for qp in operation.query_params]))
    queries = [f'{p}={v}' for p, v in sorted(fmt_query_params.items(), key=lambda x: x[0])]
    if queries:
        path += ('?' + '&'.join(queries))

    return path


def configure_api(func):
    """
    A decorator that adds the path (.apis[].path) to kwargs, and optionally sets another name to look for under either
     apis[].description or apis[].operations[].nickname, which should match. When name does not match the function,
     consider this an indication of misnaming in beta-statsapi.
    """
    arg_path = 'path'
    endpoint_name = func.__module__.split('.')[-1]
    api_name = func.__name__
    func_params = func.__code__.co_varnames
    func_cfg = EndpointConfig().config[endpoint_name][api_name]

    @wraps(func)
    def wrapper(*args, **kwargs):
        path_in_args = arg_path in func_params and func_params.index(arg_path) < len(args)
        path_in_kwargs = arg_path in kwargs
        kwargs['name'] = func_cfg.get('name', api_name)
        if path_in_kwargs or path_in_args:
            return func(*args, **kwargs)
        else:
            kwargs[arg_path] = func_cfg['path']
            return func(*args, **kwargs)

    return wrapper
