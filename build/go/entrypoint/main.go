package main

import (
	"os"
	"encoding/base64"
	"strings"

	"github.com/11notes/go-eleven"
)

const ENV_LDAP_CALENDAR_GROUPS string = "RADICALE_LDAP_CALENDAR_GROUPS"
const ENV_LDAP_ADDRESSBOOK_GROUPS string = "RADICALE_LDAP_ADDRESSBOOK_GROUPS"
const ROOT_LDAP_GROUPS string = "/radicale/var/collection-root/GROUPS"

func LDAPCreateCalendars(){
	if value, ok := os.LookupEnv(ENV_LDAP_CALENDAR_GROUPS); ok {
		groups := strings.Split(value, ",")
		for _, group := range groups {
			groupNameBase64 := base64.StdEncoding.EncodeToString([]byte(group))
			root := ROOT_LDAP_GROUPS + "/" + groupNameBase64 + "/.Radicale.cache/sync-token"
			if _, err := os.Stat(root); os.IsNotExist(err){
				if err := os.MkdirAll(root, os.ModePerm); err != nil {
					eleven.Log("ERR", "could not create LDAP group calendar %s", group)
				}else{
					if err := eleven.Util.WriteFile(ROOT_LDAP_GROUPS + "/" + groupNameBase64 + "/.Radicale.props", `{"C:calendar-description": "`+group+`", "C:supported-calendar-component-set": "VEVENT,VJOURNAL,VTODO", "D:displayname": "`+group+`", "ICAL:calendar-color": "#0692c9ff", "ICAL:calendar-order": "2", "tag": "VCALENDAR"}`); err != nil {
						eleven.Log("ERR", "could not create LDAP group calendar %s property object", group)
					}else{
						eleven.Log("INF", "created LDAP group calendar %s", group)
					}
				}
			}else{
				eleven.Log("INF", "LDAP group calendar %s already exists", group)
			}
		}
	}
}

func LDAPCreateAddressBooks(){
	if value, ok := os.LookupEnv(ENV_LDAP_ADDRESSBOOK_GROUPS); ok {
		groups := strings.Split(value, ",")
		for _, group := range groups {
			groupNameBase64 := base64.StdEncoding.EncodeToString([]byte(group))
			root := ROOT_LDAP_GROUPS + "/" + groupNameBase64 + "/.Radicale.cache/sync-token"
			if _, err := os.Stat(root); os.IsNotExist(err){
				if err := os.MkdirAll(root, os.ModePerm); err != nil {
					eleven.Log("ERR", "could not create LDAP group address book %s", group)
				}else{
					if err := eleven.Util.WriteFile(ROOT_LDAP_GROUPS + "/" + groupNameBase64 + "/.Radicale.props", `{"D:displayname": "`+group+`", "tag": "VADDRESSBOOK", "{http://inf-it.com/ns/ab/}addressbook-color": "#cfaedbff"}`); err != nil {
						eleven.Log("ERR", "could not create LDAP group address book %s property object", group)
					}else{
						eleven.Log("INF", "created LDAP group address book %s", group)
					}
				}
			}else{
				eleven.Log("INF", "LDAP group address book %s already exists", group)
			}
		}
	}
}

func main() {
	LDAPCreateCalendars()
	LDAPCreateAddressBooks()

	_ = eleven.Container.EnvToFile("RADICALE_CONFIG", "/radicale/etc/default.conf")
	_ = eleven.Container.EnvToFile("RADICALE_RIGHTS", "/radicale/etc/rights")
	_ = eleven.Container.EnvToFile("RADICALE_USERS", "/radicale/etc/users")

	eleven.Container.Run("/usr/local/bin", "python", []string{"-m", "radicale", "--config", "/radicale/etc/default.conf"})
}