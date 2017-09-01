// this file read config and init some db like mysql, redis, mongodb and so on
package main

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/cihub/seelog"
	"github.com/garyburd/redigo/redis"
	_ "github.com/go-sql-driver/mysql"
	"github.com/larspensjo/config"
)

const (
	// constants variable table
	SC_BLACKWHITE_REDIS = "blackwhiteredis"
	SC_STAT_REDIS       = "statredis"
	SC_FREQ_REDIS       = "freqredis"
	SC_DB_LOG           = "dblog"
	SC_PUBCONF          = "pubconf"
	SC_DB_FREQ_LOG      = "dbfreqlog"
	SC_DB_CONF          = "dbconf"

	S_IPLOCDB_FILE   = "iplocdbfile"
	S_PHONELOCDBFILE = "phonelocdbfile"
	S_TDB_HOST       = "host"
	S_TDB_PORT       = "port"
	S_TDB_USER       = "user"
	S_TDB_PASS       = "pass"
	S_TDB_DBNAME     = "dbname"
	S_ADDR           = "addr"
	S_DB             = "db"
	S_SEELOG         = "seelog"

	S_PORT = "port"

	IDENTIFY_TYPE_IP   = "1"
	IDENTIFY_TYPE_DEV  = "2"
	IDENTIFY_TYPE_USER = "3"
)

type MysqlConfSt struct {
	Host   string
	Port   int
	User   string
	Pass   string
	DBName string
}

type RedisConfSt struct {
	Addr string
	Db   int
}

type MPConfSt struct {
	LogDBConf      MysqlConfSt
	FreqDBConf     MysqlConfSt
	ConfDBConf     MysqlConfSt
	SrvPort        int
	SeelogPath     string
	BWRedisConf    RedisConfSt
	StatRedisConf  RedisConfSt
	FreqRedisConf  RedisConfSt
	IpLocDBFile    string
	PhoneLocDBFile string
}

type MPHandleSt struct {
	LogDB     *sql.DB
	FreqDB    *sql.DB
	ConfDB    *sql.DB
	BWCache   *redis.Pool
	StatCache *redis.Pool
	FreqCache *redis.Pool
}

var (
	gConf   = new(MPConfSt)
	gHandle = new(MPHandleSt)
)

func InitHandle() error {
	// Init Log first
	logger, err := seelog.LoggerFromConfigAsFile(gConf.SeelogPath)
	if err != nil {
		seelog.Critical("err parse log file", err)
		return err
	}
	seelog.ReplaceLogger(logger)
	seelog.Info("Hello from Seelog!")

	// init mysql connect of log
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	dbConf := gConf.LogDBConf
	dbDsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", dbConf.User, dbConf.Pass, dbConf.Host, dbConf.Port, dbConf.DBName)
	fmt.Println("DB PATH===>%s", dbDsn)
	db, err := sql.Open("mysql", dbDsn)
	db.SetMaxOpenConns(128)
	db.SetMaxIdleConns(32)

	if err != nil {
		fmt.Println("Initial phone mysql db error")
		return err
	}
	gHandle.LogDB = db

	// init mysql connect of Freq
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	dbConf = gConf.FreqDBConf
	dbDsn = fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", dbConf.User, dbConf.Pass, dbConf.Host, dbConf.Port, dbConf.DBName)
	fmt.Println("DB PATH===>%s", dbDsn)
	db, err = sql.Open("mysql", dbDsn)
	db.SetMaxOpenConns(128)
	db.SetMaxIdleConns(32)

	if err != nil {
		fmt.Println("Initial phone mysql db error")
		return err
	}
	gHandle.FreqDB = db

	// init mysql connect of Configure
	// [username[:password]@][protocol[(address)]]/dbname[?param1=value1&...&paramN=valueN]
	dbConf = gConf.ConfDBConf
	dbDsn = fmt.Sprintf("%s:%s@tcp(%s:%d)/%s", dbConf.User, dbConf.Pass, dbConf.Host, dbConf.Port, dbConf.DBName)
	fmt.Println("DB PATH===>%s", dbDsn)
	db, err = sql.Open("mysql", dbDsn)
	db.SetMaxOpenConns(128)
	db.SetMaxIdleConns(32)

	if err != nil {
		fmt.Println("Initial phone mysql db error")
		return err
	}
	gHandle.ConfDB = db

	gHandle.BWCache = &redis.Pool{
		MaxIdle:     8,
		IdleTimeout: 60 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", gConf.BWRedisConf.Addr)
			if err != nil {
				return nil, err
			}

			if _, err := c.Do("SELECT", gConf.BWRedisConf.Db); err != nil {
				c.Close()
				return nil, err
			}
			return c, nil
		},
	}

	gHandle.StatCache = &redis.Pool{
		MaxIdle:     8,
		IdleTimeout: 60 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", gConf.StatRedisConf.Addr)
			if err != nil {
				return nil, err
			}

			if _, err := c.Do("SELECT", gConf.StatRedisConf.Db); err != nil {
				c.Close()
				return nil, err
			}
			return c, nil
		},
	}

	return nil
}

func ParseConf(fileName string) error {
	fmt.Printf("Configure file name is %s\n", fileName)

	cfg, err := config.ReadDefault(fileName)
	if err != nil {
		return err
	}

	// seelog
	gConf.SeelogPath, err = cfg.String(SC_PUBCONF, S_SEELOG)
	if err != nil {
		return err
	}

	// Log Mysql Database
	gConf.LogDBConf.Host, _ = cfg.String(SC_DB_LOG, S_TDB_HOST)
	gConf.LogDBConf.Port, _ = cfg.Int(SC_DB_LOG, S_TDB_PORT)
	gConf.LogDBConf.User, _ = cfg.String(SC_DB_LOG, S_TDB_USER)
	gConf.LogDBConf.Pass, _ = cfg.String(SC_DB_LOG, S_TDB_PASS)
	gConf.LogDBConf.DBName, _ = cfg.String(SC_DB_LOG, S_TDB_DBNAME)

	// Freq Log Mysql Database
	gConf.FreqDBConf.Host, _ = cfg.String(SC_DB_FREQ_LOG, S_TDB_HOST)
	gConf.FreqDBConf.Port, _ = cfg.Int(SC_DB_FREQ_LOG, S_TDB_PORT)
	gConf.FreqDBConf.User, _ = cfg.String(SC_DB_FREQ_LOG, S_TDB_USER)
	gConf.FreqDBConf.Pass, _ = cfg.String(SC_DB_FREQ_LOG, S_TDB_PASS)
	gConf.FreqDBConf.DBName, _ = cfg.String(SC_DB_FREQ_LOG, S_TDB_DBNAME)

	// Conf Mysql Database
	gConf.ConfDBConf.Host, _ = cfg.String(SC_DB_CONF, S_TDB_HOST)
	gConf.ConfDBConf.Port, _ = cfg.Int(SC_DB_CONF, S_TDB_PORT)
	gConf.ConfDBConf.User, _ = cfg.String(SC_DB_CONF, S_TDB_USER)
	gConf.ConfDBConf.Pass, _ = cfg.String(SC_DB_CONF, S_TDB_PASS)
	gConf.ConfDBConf.DBName, _ = cfg.String(SC_DB_CONF, S_TDB_DBNAME)

	// statistic redis db
	gConf.StatRedisConf.Addr, _ = cfg.String(SC_STAT_REDIS, S_ADDR)
	gConf.StatRedisConf.Db, _ = cfg.Int(SC_STAT_REDIS, S_DB)

	// BlackWhite redis db
	gConf.BWRedisConf.Addr, _ = cfg.String(SC_BLACKWHITE_REDIS, S_ADDR)
	gConf.BWRedisConf.Db, _ = cfg.Int(SC_BLACKWHITE_REDIS, S_DB)

	// listen port
	gConf.SrvPort, _ = cfg.Int(SC_PUBCONF, S_PORT)

	// Location DB File
	gConf.IpLocDBFile, _ = cfg.String(SC_PUBCONF, S_IPLOCDB_FILE)
	gConf.PhoneLocDBFile, _ = cfg.String(SC_PUBCONF, S_PHONELOCDBFILE)

	fmt.Println(gConf)

	return nil
}
