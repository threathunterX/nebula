package rulengine

// import (
// 	"fmt"
// 	"github.com/cihub/seelog"
// )

// func WriteFrequencyLog(s *MPCheckReqSt) {
// 	/*
// 	   `id` bigint(10) unsigned Not null AUTO_INCREMENT,
// 	   `user` varchar(128) DEFAULT '',
// 	   `devid` varchar(64) DEFAULT '',
// 	   `sip` char(16) DEFAULT '',
// 	   `rtime` datetime DEFAULT NULL,
// 	   `op` char(16) default '',
// 	   `subop` int default '0',
// 	*/
// 	fmt.Printf("WriteFrequencyLog: St:%s \n", s)
// 	// db := gHandle.LogDB
// 	db := gHandle.FreqDB
// 	var tabname string
// 	// fmt.Printf("What happend\n")
// 	if s.Op == OP_LOGIN {
// 		tabname = "t_frequency_login"
// 	} else if s.Op == OP_REGISTER {
// 		tabname = "t_frequency_register"
// 	} else if s.Op == OP_CAMPAIGN {
// 		tabname = "t_frequency_campaign"
// 	} else {
// 		seelog.Errorf("Invalid operation %v", s)
// 	}
// 	sqlstr := fmt.Sprintf("insert into %s(user, devid, sip, rtime, op, subop)values(?,?,?,?,?,?)", tabname)
// 	_, err := db.Exec(sqlstr, s.User, s.Devid, s.Ip, s.Time, s.Op, s.Subop)

// 	if err != nil {
// 		fmt.Printf("====>%v\n", err)
// 		seelog.Errorf("Execute mysql error:%v, of %v", err, s)
// 	}
// 	seelog.Flush()
// }
