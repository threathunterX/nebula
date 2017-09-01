package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"malicious_prevent/rulengine"
	"net/http"
	"net/http/httptest"
	"testing"
)

func init() {
	err := ParseConf("malicious.conf")
	if err != nil {
		panic("Parse configure error!")
	}

	err = InitHandle()
	if err != nil {
		panic("Initiate Handle error!")
	}

	// Load Rule Engine
	err = rulengine.InitEngine(gHandle.ConfDB)
	if err != nil {
		panic("Load rules error")
	}
}

func TestCheck(t *testing.T) {
	s := map[string]interface{}{
		"type":  "login",
		"Devid": "ZiNzdkMDM0OWMyZmVkMTA2MmYwMT",
		"User":  "smithjose@yahoo.com",
		"Ip":    "211.83.10.203",
		"Time":  "2017-07-01 15:26:00",
		"Op":    "campaign",
		"Subop": 7,
	}

	sstr, _ := json.Marshal(s)

	req, err := http.NewRequest("POST", "/events", bytes.NewReader(sstr))
	if err != nil {
		t.Fatal(err)
	}

	// Content-Type:application/json
	req.Header.Add("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(MPEvents)
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check the response body is what we expect.
	fmt.Printf("response body: %v\n",
		rr.Body.String())
}
