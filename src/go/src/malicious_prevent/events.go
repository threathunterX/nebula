package main

import (
	"encoding/json"
	"fmt"
	"github.com/cihub/seelog"
	"io"
	"io/ioutil"
	"malicious_prevent/automate"
	"malicious_prevent/mpevents"
	"net/http"
)

type EventReqSt struct {
	Type  string `json:"type"`
	User  string `json:"user"`
	Devid string `json:"devid"`
}

func MPEvents(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		info := GeneralRsp(E_INVAL_METHOD)
		io.WriteString(w, info)
		return
	}

	fmt.Println("[mp post event]")

	result, err := ioutil.ReadAll(r.Body)
	r.Body.Close()
	if err != nil {
		seelog.Errorf("read post string error:%v", err)
		info := GeneralRsp(E_INVAL_PAR)
		io.WriteString(w, info)
		return
	}

	var eventReq EventReqSt
	if err := json.Unmarshal(result, &eventReq); err != nil {
		seelog.Errorf("Parse json error:%v of [%s]", err, result)
		info := GeneralRsp(E_PARSE_JSON)
		io.WriteString(w, info)
		return
	}


	/// todo
	// data collect and calculate new scores
	switch eventReq.Type {
	case "login":
		mpevents.LoginEvent(result)
	default:
		// do nothing
	}

	// if return_workflow_status == true
	// get workflow    :   routes and decisions
	// if hit routes return decisions?

	var decisions []automate.DecisionSt
	decisions = automate.GetMatchDecisions(gHandle.ConfDB, eventReq.Type, eventReq.User)
	if decisions == nil {
		seelog.Errorf("no decisions hit")
		info := GeneralRsp(E_OK)
		io.WriteString(w, info)
		return
	}

	rspdat := make(map[string]interface{})
	rspdat["errcode"] = 200
	rspdat["errmsg"] = "OK"
	rspdat["decisions"] = decisions

	b, _ := json.Marshal(rspdat)
	info := string(b)
	io.WriteString(w, info)
	return
}
