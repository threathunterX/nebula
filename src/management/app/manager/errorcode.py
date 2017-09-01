#!/usr/bin/python
# -*- coding: utf-8 -*-
from flask import jsonify
class ErrCode(object): 
    OK = 200
    UNKNOWN             = 599 
    INVALID_PARAMETER   = 510   #"invalid parameters"
    USER_NOT_FOUND      = 511   #"user not found"
    INVALID_ID          = 512   #"invalid id"

emap = {
    200: "ok",
    201: "Created",
    204: "No Content",
    304: "Not Modified",
    400: "Bad Request",
    403: "Forbidden",
    409: "Conflict",
    404: "Not Found",
    500: "Internal Server Error",
    401: "Unauthorized",
    ErrCode.INVALID_PARAMETER : "invalid parameters",
    ErrCode.USER_NOT_FOUND : "user not found",
    ErrCode.INVALID_ID : "invalid id",
}

get_error_str = lambda x : emap[x] if emap.get(x) else "unknown error"

def get_error(n, **kw):
    return dict({"status" : n, "msg" : get_error_str(n)}, **kw)

def json_error(n, **kw):
    return jsonify(dict({"status" : n, "msg" : get_error_str(n)}, **kw))