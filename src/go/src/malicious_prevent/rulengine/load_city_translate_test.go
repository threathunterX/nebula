package rulengine

import (
	"bufio"
	"fmt"
	"github.com/cihub/seelog"
	"io"
	"os"
	"strings"
)

var (
	ProvinceMap = make(map[string]string)
	CityMap     = make(map[string]string)
)

const (
	fcity = "city.csv"
	fprov = "prov.csv"
)

func LoadCityTranslateFile() error {
	fmt.Println("==>Test_LoadCityTranslateFile called")
	// Province Information
	fp, err := os.Open(fprov)
	if err != nil {
		seelog.Errorf("Open file %s error:%v", fprov, err)
		return err
	}
	pbuf := bufio.NewReader(fp)
	for {
		line, err := pbuf.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			seelog.Errorf("Read file %s error:%v", fprov, err)
			return err
		}
		line = strings.TrimSuffix(line, "\n")
		arr := strings.Split(line, ",")
		ProvinceMap[arr[0]] = arr[1]
	}
	fp.Close()

	// City Information
	fp, err = os.Open(fcity)
	if err != nil {
		seelog.Errorf("Open file %s error:%v", fprov, err)
		return err
	}
	pbuf = bufio.NewReader(fp)
	for {
		line, err := pbuf.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			seelog.Errorf("Read file %s error:%v", fprov, err)
			return err
		}
		line = strings.TrimSuffix(line, "\n")
		arr := strings.Split(line, ",")
		CityMap[arr[0]] = arr[1]
	}
	fp.Close()

	return nil
}
