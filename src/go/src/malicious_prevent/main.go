package main

import (
	"flag"
	"fmt"
	"github.com/cihub/seelog"
	"io"
	"log"
	"malicious_prevent/rulengine"
	"net/http"
	"runtime"
	"syscall"
)

func SetRlimit() {
	var rLimit syscall.Rlimit
	err := syscall.Getrlimit(syscall.RLIMIT_NOFILE, &rLimit)
	if err != nil {
		fmt.Println("Error Getting Rlimit ", err)
		panic("Get rlimit")
	}
	rLimit.Max = 500000
	rLimit.Cur = 500000
	err = syscall.Setrlimit(syscall.RLIMIT_NOFILE, &rLimit)
	if err != nil {
		fmt.Println("Error Setting Rlimit ", err)
		panic("Set rlimit")
	}
	err = syscall.Getrlimit(syscall.RLIMIT_NOFILE, &rLimit)
	if err != nil {
		fmt.Println("Error Getting Rlimit ", err)
		panic("Getting Rlimit")
	}
	fmt.Println("Rlimit Final", rLimit)
}

func MPVersion(w http.ResponseWriter, r *http.Request) {
	seelog.Infof("Get %s", r.URL.Path)
	info := `{"version":"1.0.0", "release_date":"2017-06-30", "baseline":2379}`
	io.WriteString(w, info)
	return
}

func main() {
	// parse the configure file
	var conf_file_name = flag.String("f", "malicious.conf", "configure file path")
	var version = flag.Bool("version", false, "version info")
	flag.Parse()

	if *version {
		fmt.Printf("Version: 1.0.1\n")
		return
	}

	err := ParseConf(*conf_file_name)
	if err != nil {
		panic("Parse configure error!")
	}

	runtime.GOMAXPROCS(runtime.NumCPU() - 1)
	SetRlimit()
	err = InitHandle()
	if err != nil {
		panic("Initiate Handle error!")
	}

	// Load Rule Engine
	err = rulengine.InitEngine(gHandle.ConfDB)
	if err != nil {
		fmt.Println(err)
		panic("Load rules error")
	}

	defer seelog.Flush()
	// CheckStatistic()

	// start statistic rutine
	mux := http.NewServeMux()
	mux.HandleFunc("/version", MPVersion)
	mux.HandleFunc("/events", MPEvents)

	srvaddr := fmt.Sprintf(":%d", gConf.SrvPort)

	fmt.Printf("\nsrvaddr:%s\n", srvaddr)
	err = http.ListenAndServe(srvaddr, mux)
	if err != nil {
		log.Fatal("Error ListenAndServe:", err)
	}
}
