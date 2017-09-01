package automate

import (
	"fmt"
	"github.com/cihub/seelog"
	"gopkg.in/mgo.v2"
	_ "gopkg.in/mgo.v2/bson"
	"strings"
	"time"
)

func WriteDecisionLog(route_workflow string, decision DecisionSt, userinfo map[string]interface{}) {

	arr := strings.Split(route_workflow, "_")
	routeid := arr[0]
	workflowid := arr[1]

	userinfo["routeid"] = routeid
	userinfo["workflowid"] = workflowid
	userinfo["decision"] = decision
	timenow := time.Now()
	userinfo["date"] = timenow.Format("2006-01-02")
	userinfo["_time"] = timenow.Format("15:04:05")

	// fmt.Printf("[WriteDecisionLog>>>>]\nuserinfo:%v\n",
	// 	userinfo)

	session, err := mgo.Dial("localhost:27017")
	if err != nil {
		seelog.Errorf("WriteDecisionLog mgo.Dial err:%v", err)
		fmt.Printf("WriteDecisionLog mgo.Dial err:%v", err)
		return
	}

	defer session.Close()
	session.SetMode(mgo.Monotonic, true)
	c := session.DB("db_mp_log").C("decisionlog")

	err = c.Insert(&userinfo)
	if err != nil {
		seelog.Errorf("WriteDecisionLog Insert err:%v", err)
		fmt.Printf("WriteDecisionLog Insert err:%v", err)
		return
	}
}
