package main

import (
	"encoding/json"
)

const (
	E_OK           = 200
	E_INTERNAL     = 500
	E_INVAL_PAR    = 501
	E_INVAL_METHOD = 502
	E_PERMISSION   = 503
	E_NO_REQ_QUOTA = 504
	E_PARSE_JSON   = 511
	E_MYSQL_INSRT  = 512
	E_FREQUENCY    = 520
	E_NOT_LOGIN    = 599
)

func GetMsgByCode(code int) string {
	eMap := map[int]string{
		E_OK:           "OK",
		E_INVAL_PAR:    "invalid parameters",
		E_INVAL_METHOD: "invalid method, for example POST Method use GET",
		E_PERMISSION:   "permission deny",
		E_NO_REQ_QUOTA: "no request quota",
		E_INTERNAL:     "internal error",
		E_PARSE_JSON:   "parse json error",
		E_MYSQL_INSRT:  "mysql error",
		E_FREQUENCY:    "call the api too often",
		E_NOT_LOGIN:    "login error",
	}

	v, e := eMap[code]
	if e {
		return v
	} else {
		return "Unknown error, connect administrator"
	}
}

type GeneralSt struct {
	User    string `json:"user"`
	Errcode int    `json:"errcode"`
	Errmsg  string `json:"errmsg"`
}

func GeneralFullRsp(code int, user string, status int) string {
	var rsp GeneralSt
	rsp.User = user
	rsp.Errcode = code
	rsp.Errmsg = GetMsgByCode(code)
	b, _ := json.Marshal(rsp)
	return string(b)
}

func GeneralRsp(code int) string {
	var rsp GeneralSt
	rsp.Errcode = code
	rsp.Errmsg = GetMsgByCode(code)
	b, _ := json.Marshal(rsp)
	return string(b)
}
