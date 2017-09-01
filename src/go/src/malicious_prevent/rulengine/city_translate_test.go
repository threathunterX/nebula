package rulengine

import (
	"fmt"
	"testing"
)

func Test_LoadCityConf(t *testing.T) {
	fmt.Println("==>Test_LoadCityConf called")
	err := LoadCityTranslateFile()
	if err != nil {
		fmt.Printf("error === >%v\n", err)
		t.Error("Test error")
	}
}
