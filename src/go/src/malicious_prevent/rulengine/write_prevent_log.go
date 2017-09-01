package rulengine

// import (
// 	"fmt"
// 	"github.com/cihub/seelog"
// )

// func init() {
// 	err := ParseConf("malicious.conf")
// 	if err != nil {
// 		panic("Parse configure error!")
// 	}

// 	err = InitHandle()
// 	if err != nil {
// 		panic("Initiate Handle error!")
// 	}
// }

// func WritePreventLog(s *MPCheckReqSt, risk int, rule string) {
// 	/*
// 		`id` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
// 		`user` varchar(128) DEFAULT '',
// 		`devid` varchar(64) DEFAULT '',
// 		`sip` char(16) DEFAULT '',
// 		`rtime` datetime DEFAULT NULL,
// 		`op` char(16) DEFAULT '',
// 		`subop` int(11) DEFAULT '0',
// 		`risk` int(11) DEFAULT '0',
// 		`rule` varchar(128) DEFAULT '',
// 		`reason` varchar(256) DEFAULT '',
// 	*/
// 	fmt.Printf("WritePreventLog: St:%s, risk:%d, rule:%s\n", s, risk, rule)
// 	db := gHandle.LogDB
// 	var tabname string
// 	// fmt.Printf("What happend\n")
// 	if s.Op == OP_LOGIN {
// 		tabname = "t_prevent_login"
// 	} else if s.Op == OP_REGISTER {
// 		tabname = "t_prevent_register"
// 	} else if s.Op == OP_CAMPAIGN {
// 		tabname = "t_prevent_campaign"
// 	} else {
// 		seelog.Errorf("Invalid operation %v", s)
// 	}
// 	sqlstr := fmt.Sprintf("insert into %s(user, devid, sip, rtime, op, subop, risk, rule, reason)values(?,?,?,?,?,?,?,?,?)", tabname)
// 	_, err := db.Exec(sqlstr, s.User, s.Devid, s.Ip, s.Time, s.Op, s.Subop, risk, rule, "")

// 	if err != nil {
// 		fmt.Printf("====>%v\n", err)
// 		seelog.Errorf("Execute mysql error:%v, of %v", err, s)
// 	}
// 	seelog.Flush()
// }
