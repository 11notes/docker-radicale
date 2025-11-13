package main

import (
	"os"
	"syscall"

	"github.com/11notes/go"
)

var (
	Eleven eleven.New = eleven.New{}
)

func main() {
	_ = Eleven.Container.EnvToFile("RADICALE_CONFIG", "/radicale/etc/default.conf")
	_ = Eleven.Container.EnvToFile("RADICALE_RIGHTS", "/radicale/etc/rights")
	_ = Eleven.Container.EnvToFile("RADICALE_USERS", "/radicale/etc/users")

	Eleven.Log("START", "")
	if err := syscall.Exec("/usr/local/bin/python", []string{"python", "-m", "radicale", "--config", "/radicale/etc/default.conf"}, os.Environ()); err != nil {
		os.Exit(1)
	}
}