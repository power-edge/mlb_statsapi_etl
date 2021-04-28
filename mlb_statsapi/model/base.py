"""
created by nikos at 4/21/21
"""
# import abc
import json
import os

from serde import Model, fields, tags

# from ..utils import get_api_object


__beta_stats_api_default_version__ = '1.0'
__base_path__ = os.path.join(os.path.realpath(__file__).split('/mlb_statsapi')[0], 'mlb_statsapi')
beta_stats_api_version = os.environ.get('BETA_STATS_API_VERSION', __beta_stats_api_default_version__)


class MLBStatsAPIModel(Model):

    # _fmt_rel_path: str = None

    apiVersion: fields.Str()
    src_url: fields.Str()
    swaggerVersion: fields.Str()

    @classmethod
    def get_name(cls):
        return cls.__module__.split('.')[-1]

    @classmethod
    def get_open_path(cls):
        sub_path = cls._fmt_rel_path.format(name=cls.get_name(), api_version=beta_stats_api_version)
        return f"{__base_path__}/configs/statsapi/{sub_path}"

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
        return cls.from_json(cls.read_doc_str())


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
    paramType: fields.Str()
    required: fields.Bool()
    type: fields.Str()
    items: fields.Optional(fields.Nested(ItemType))
    # optional
    items: fields.Optional(fields.Nested(ItemType))
    uniqueItems: fields.Optional(fields.Bool)
    # even more optional
    enum: fields.Optional(fields.List(fields.Str))


class Operation(Model):
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


class APIModelBase(Model):
    description: fields.Str()
    path: fields.Str()

    class Meta:
        tag = tags.Internal(tag='apis')


class EndpointAPIModel(APIModelBase):
    operations: fields.List(Operation)


class MLBStatsAPIEndpoint(MLBStatsAPIModel):
    _fmt_rel_path = 'stats-api-{api_version}/{name}.json'
    # _fmt_rel_path

    apis: fields.List(EndpointAPIModel)
    api_path: fields.Str()
    basePath: fields.Str()
    consumes: fields.List(fields.Str)
    # models: fields.Dict(fields.Str, )
    produces: fields.List(fields.Str)
    resourcePath: fields.Str()

    class Meta:
        tag = tags.Internal(tag='endpoint')

    def get(self, **kwargs):
        return get_api_object(self, **kwargs)


class RequestParams:

    def __init__(self, api: str):
        self.api = api
        self._path = {}
        self._query = {}

    # def with_path_param(self, param, value):
    #     self._path['param']
    #     return


class APIObject:

    base_api_url = 'https://statsapi.mlb.com/api'
    # base_api_path = '/statsapi.mlb.com/api'

    def __init__(self, path):
        pass


def get_api_object(api_model: EndpointAPIModel, **kwargs):
    # from .base import EndpointAPIModel
    api_model: EndpointAPIModel
    path, name = kwargs['path'], kwargs['name']
    api: EndpointAPIModel = {a.path: a for a in api_model.apis}[path]

    def paramSortKey(param):
        return param.name
    path_params = sorted([param for param in api.parameters if param.paramType == "path"], key=paramSortKey)
    query_params = sorted([param for param in api.parameters if param.paramType == "query"], key=paramSortKey)

    op = {o.nickname: o for o in api.operations if o.method == "GET"}[name]
    # print(api_model, path, name, op)
    print(api.to_json(indent=2))
