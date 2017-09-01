package mpevents

import (
	"encoding/json"
	"fmt"
	"github.com/cihub/seelog"
	"malicious_prevent/rulengine"
)

type LoginEventReqSt struct {
	Type  string `json:"type"`
	Devid string `json:"devid"`
	User  string `json:"user"`
	Ip    string `json:"ip"`
	Time  string `json:"time"`
	Op    string `json:"op"`
	Subop int    `json:"subop"`
}

func LoginEvent(result []byte) {
	fmt.Println("LoginEvent")
	// fmt.Println(jsdat)

	var event LoginEventReqSt
	err := json.Unmarshal(result, &event)
	if err != nil {
		seelog.Errorf("Parse LoginEvent error:%v of [%s]", err, result)
		return
	}

	fmt.Println(event)

	// todo
	// use jsdat and history data calulate new scores

	err = rulengine.RunCheck()

	return
}
