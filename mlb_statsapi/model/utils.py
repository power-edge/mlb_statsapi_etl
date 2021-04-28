"""
created by nikos at 4/25/21
"""
from functools import wraps


def api_path(path, name=None):
    """
    A decorator that adds the path (.apis[].path) to kwargs, and optionally sets another name to look for under either
     apis[].description or apis[].operations[].nickname, which should match. When name does not match the function,
     consider this an indication of misnaming in beta-statsapi.
    """
    def deco(func):
        """
        Function decorator that provides api.path and api.description if it isn't provided.
        """
        @wraps(func)
        def wrapper(*args, **kwargs):
            arg_path = 'path'
            func_params = func.__code__.co_varnames
            path_in_args = arg_path in func_params and func_params.index(arg_path) < len(args)
            path_in_kwargs = arg_path in kwargs
            kwargs['name'] = name or func.__name__
            if path_in_kwargs or path_in_args:
                return func(*args, **kwargs)
            else:
                kwargs[arg_path] = path
                return func(*args, **kwargs)

        return wrapper

    return deco
