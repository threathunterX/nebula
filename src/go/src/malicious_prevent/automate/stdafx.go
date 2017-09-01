package automate

import ()

type DecisionSt struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Category string `json:"category"`
	Time     string `json:"time"`
}

type RouteSt struct {
	ID         int
	workflowID int
	critertias string
	decision   DecisionSt
}

const (
	ACTION_REVIEW   = 1
	ACTION_DECISION = 2
)
