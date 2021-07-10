"""
created by nikos at 4/21/21
"""
import abc
import json
import os
from serde import Model, fields, tags

from ..utils import base_path
from ..utils.log import LogMixin
from ..utils.stats_api_object import StatsAPIObject


__beta_stats_api_default_version__ = '1.0'
beta_stats_api_version = os.environ.get('BETA_STATS_API_VERSION', __beta_stats_api_default_version__)


class MLBStatsAPIModel(Model):

    _instance = None

    apiVersion: fields.Str()
    src_url: fields.Str()
    swaggerVersion: fields.Str()

    @classmethod
    def get_name(cls):
        return cls.__module__.split('.')[-1]

    @classmethod
    def get_open_path(cls):
        sub_path = cls._fmt_rel_path.format(name=cls.get_name(), api_version=beta_stats_api_version)
        return f"{base_path}/configs/statsapi/{sub_path}"

    @classmethod
    def read_doc_str(cls):
        with open(cls.get_open_path(), 'r') as f:
            api_doc = f.read()
        return api_doc

    @classmethod
    def read_doc(cls, doc_str=None):
        if doc_str is None:
            doc_str = cls.read_doc_str()
        return json.loads(doc_str)

    @classmethod
    def from_doc(cls):
        if cls._instance is None:
            cls._instance = cls.from_json(cls.read_doc_str())
        return cls._instance


class ResponseMessage(Model):
    code: fields.Int()
    message: fields.Optional(fields.Str)
    responseModel: fields.Optional(fields.Str)


class ItemType(Model):
    type: fields.Str()


class Parameter(Model):
    allowMultiple: fields.Bool()
    defaultValue: fields.Str()
    description: fields.Str()
    name: fields.Str()
    paramType: fields.Choice(['path', 'query'])
    required: fields.Bool()
    type: fields.Str()
    items: fields.Optional(fields.Nested(ItemType))
    # optional
    items: fields.Optional(fields.Nested(ItemType))
    uniqueItems: fields.Optional(fields.Bool)
    # even more optional
    enum: fields.Optional(fields.List(fields.Str))


class OperationModel(Model):
    consumes: fields.List(fields.Str)
    deprecated: fields.Str()
    method: fields.Choice(['GET', 'POST'])
    nickname: fields.Str()
    notes: fields.Str()
    parameters: fields.List(Parameter)
    produces: fields.List(fields.Str)
    responseMessages: fields.List(ResponseMessage)
    summary: fields.Str()
    type: fields.Str()

    # optional
    items: fields.Optional(fields.Nested(ItemType))
    uniqueItems: fields.Optional(fields.Bool)

    @property
    def path_params(self):
        return [param for param in self.parameters if param.paramType == "path"]

    @property
    def query_params(self):
        return [param for param in self.parameters if param.paramType == "query"]


class APIModelBase(Model):
    description: fields.Str()
    path: fields.Str()

    class Meta:
        tag = tags.Internal(tag='apis')


class EndpointAPIModel(APIModelBase):
    operations: fields.List(OperationModel)

    @property
    def get_operations_map(self):
        return {o.nickname: o for o in self.operations if o.method == "GET"}

    @property
    def operation(self):
        return self.get_operations_map[self.description]


class MLBStatsAPIEndpointModel(MLBStatsAPIModel, LogMixin):
    """
    Each api in the api_docs gets an inheriting class to define methods to for the endpoint access patterns.

    Some of the api doc json files have small naming issues, therefore the @api_path wraps functions to make explicit
    the path and name to search, where the name corresponds to the api.description or the api.operation.nickname, but
    method names are corrected for misnaming in the underlying documentation.

    These methods return a StatsAPIFileObject which is endpoint/api aware, and can get, save, and load itself.
    """
    _methods = None
    _fmt_rel_path = 'stats-api-{api_version}/{name}.json'

    apis: fields.List(EndpointAPIModel)
    api_path: fields.Str()
    basePath: fields.Str()
    consumes: fields.List(fields.Str)
    # models: fields.Dict(fields.Str, )  # very complex serde and *not* necessary for stashing responses in a data store
    produces: fields.List(fields.Str)
    resourcePath: fields.Str()

    class Meta:
        tag = tags.Internal(tag='endpoint')

    @property
    def _api_path_name_map(self):
        return {(api.path, api.description): api for api in self.apis}

    @property
    def _api_description_map(self):
        return {api.description: api for api in self.apis}

    def get_api_file_object(self, **kwargs):
        path, name = kwargs['path'], kwargs['name']
        api = self._api_path_name_map[path, name]
        operation = api.get_operations_map[name]
        path_params, query_params = kwargs.get('path_params'), kwargs.get('query_params')
        return StatsAPIObject(
            endpoint=self,
            api=api,
            operation=operation,
            path_params=path_params,
            query_params=query_params
        )

    @property
    def methods(self):
        assert self._methods is not None, 'please define methods for %s' % self.get_name()
        return self._methods

    @abc.abstractmethod
    def run(self, **kwargs):
        raise NotImplementedError("define a run method")