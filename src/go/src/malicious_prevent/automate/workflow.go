package automate

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/cihub/seelog"
	"github.com/cloudsss/rulengine"
	"github.com/cloudsss/rulengine/facts"
	"github.com/cloudsss/rulengine/logic"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
	"strconv"
	"strings"
	"time"
)

func (routes RouteSt) GetDecision() DecisionSt {
	return routes.decision
}

func getWorkFlowIds(db *sql.DB, eventKey string) (workflowsids []int) {
	sql := "select event, id from t_workflows"
	rows, err := db.Query(sql)
	if err != nil {
		seelog.Errorf("query rules error: %v", err)
		return
	}

	defer rows.Close()
	for rows.Next() {
		var event string
		var id int
		if err := rows.Scan(&event, &id); err != nil {
			seelog.Errorf("Scan workflowsids error: %v", err)
		}

		if event == eventKey {
			workflowsids = append(workflowsids, id)
		}
	}

	if err := rows.Err(); err != nil {
		seelog.Errorf("query WorkFlow error: %v", err)
	}

	return
}

func getCheckRouteSt(db *sql.DB, workflowsids []int) (routes []RouteSt) {
	for _, v := range workflowsids {
		sql := fmt.Sprint("select id, criterias, action, decisionid from t_routes where workflowid = ", v)

		rows, err := db.Query(sql)
		if err != nil {
			seelog.Errorf("query routes error: %v", err)
			return
		}

		defer rows.Close()
		for rows.Next() {
			var critertias string
			var ID, action, decisionid int

			if err := rows.Scan(&ID, &critertias, &action, &decisionid); err != nil {
				seelog.Errorf("Scan routes error: %v", err)
			}

			if len(critertias) == 0 {
				continue
			}

			if action == ACTION_DECISION {
				var route RouteSt
				route.ID = ID
				route.critertias = critertias
				route.decision.ID = decisionid
				route.workflowID = v

				routes = append(routes, route)
			}
		}

		if err := rows.Err(); err != nil {
			seelog.Errorf("query WorkFlow error: %v", err)
			return
		}
	}

	return
}

func getMongoUserInfo(userKey string) (userinfo map[string]interface{}) {
	session, err := mgo.Dial("localhost:27017")
	if err != nil {
		seelog.Errorf("getMongoUserInfo mgo.Dial err:%v", err)
		fmt.Printf("getMongoUserInfo mgo.Dial err:%v", err)
		return
	}

	defer session.Close()
	session.SetMode(mgo.Monotonic, true)
	c := session.DB("db_mp_log").C("userlog")

	err = c.Find(bson.M{"baseinfo.email": userKey}).Select(bson.M{"_id": 0}).One(&userinfo)
	if err != nil {
		seelog.Errorf("getMongoUserInfo find user err:%v", err)
		fmt.Printf("getMongoUserInfo find user err:%v", err)
		return
	}

	// for _, v := range userinfo.Keys() {
	// 	fmt.Printf("keys:%v\n", v)
	// }

	return
}

func GetMatchDecisions(db *sql.DB, eventKey, userKey string) (decisions []DecisionSt) {
	workflowsids := getWorkFlowIds(db, eventKey)
	if workflowsids == nil || len(workflowsids) == 0 {
		seelog.Errorf("getWorkFlowIds ruturn null, event:%v", eventKey)
		fmt.Printf("getWorkFlowIds ruturn null, event:%v", eventKey)
		return
	}
	fmt.Printf("workflowsids:%v\n", workflowsids)

	checkRoutes := getCheckRouteSt(db, workflowsids)
	if checkRoutes == nil || len(checkRoutes) == 0 {
		seelog.Errorf("getCheckRouteSt ruturn null, event:%v", eventKey)
		fmt.Printf("getCheckRouteSt ruturn null, event:%v", eventKey)
		return
	}

	userinfo := getMongoUserInfo(userKey)

	// fmt.Printf("userinfo : %v\n", userinfo)

	fmt.Printf("%c[0;;32muserinfo : \n%v%c[0m\n\n", 0x1B, userinfo, 0x1B)

	//todo: rule engine  check rule
	engine := rulengine.NewRuleEngine()
	for i, route := range checkRoutes {
		fmt.Printf("checkRoute:%d, %v\n", i, route)

		// 这里有bug，action的name和reason相等时居然返回错误
		strRouteId := strconv.Itoa(route.ID) + "_" + strconv.Itoa(route.workflowID)
		decisionId := strconv.Itoa(route.decision.ID)

		engine.AddExpression(route.critertias, strRouteId)
		// fmt.Printf("string(route.decision.ID):%d, %s\n", route.decision.ID, decisionId)
		lrule := logic.Rule{Expression: strRouteId, Action: decisionId}
		engine.AddRule(&lrule)
	}

	s, _ := json.Marshal(userinfo)
	userstring := string(s)
	// fmt.Printf("userinfo string: %v\n", userstring)

	fc := facts.NewFactCollection()
	f := facts.NewFact(userstring)
	fc.Add("user", f)
	actions := engine.GetAction(fc)

	// fmt.Printf("actions : %v\n", actions)

	var decisionids []string
	mapDecision2Route := make(map[string]string)
	if actions != nil && len(actions) != 0 {
		for i, v := range actions {
			fmt.Printf("hit action%d : name(decisionid):%s,reason(routeid):%s\n", i, v.Name, v.Reason)
			decisionids = append(decisionids, v.Name)
			mapDecision2Route[v.Name] = v.Reason
		}
	}

	sql := fmt.Sprint("select id,name,category,update_at from t_decisions where id in (", strings.Join(decisionids, ","), ")")
	// fmt.Printf("insql:%s\n", sql)
	rows, err := db.Query(sql)
	if err != nil {
		seelog.Errorf("query rules error: %v", err)
		return
	}

	defer rows.Close()
	for rows.Next() {
		var name, category, update_at string
		var id int
		if err := rows.Scan(&id, &name, &category, &update_at); err != nil {
			seelog.Errorf("query decisionids error: %v", err)
		}

		var decision DecisionSt
		decision.ID = id
		decision.Name = name
		decision.Category = category
		tm, _ := time.Parse("2006-01-02 15:04:05", update_at)
		decision.Time = strconv.FormatInt(tm.Unix(), 10)
		decisions = append(decisions, decision)

		WriteDecisionLog(mapDecision2Route[strconv.Itoa(id)], decision, userinfo)
	}

	return
}
