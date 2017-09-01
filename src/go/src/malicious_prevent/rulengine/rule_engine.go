package rulengine

import (
	"database/sql"
	// "encoding/json"
	//"fmt"
	//"strings"

	//"github.com/cihub/seelog"
	"github.com/cloudsss/rulengine"
	// "github.com/cloudsss/rulengine/facts"
	//"github.com/cloudsss/rulengine/logic"
)

type FreqConfSt struct {
	Ipperiad      int
	Ipthreshold   int
	Devperiad     int
	Devthreshold  int
	Userperiad    int
	Userthreshold int
}

var (
	gRE *rulengine.RuleEngine
	gFC *FreqConfSt
)

func RunCheck() error {
	// todo
	// calulate risk info
	// set mongodb user risk info

	return nil
}

// func DataCheck(data *MPDataSt) []*rulengine.Action {
// 	s, _ := json.Marshal(data)
// 	sdata := string(s)
// 	fc := facts.NewFactCollection()
// 	f := facts.NewFact(sdata)
// 	fc.Add("user", f)

// 	//fmt.Printf("facts:%s\n", f)
// 	fmt.Printf("userjson: %s\n", s)
// 	actions := gRE.GetAction(fc)
// 	fmt.Printf("actions : %s,%v\n", actions, actions)
// 	return actions
// }

func InitEngine(db *sql.DB) error {
	// todo

	return nil
}
