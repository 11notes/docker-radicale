import ldap3
import ldap3.core.exceptions
import radicale_auth_ldap.escape
from radicale import auth, config
from radicale.log import logger

class Auth(auth.BaseAuth):

    _server: str
    _baseDN: str
    _bindDN: str
    _bindDNpassword: str
    _filter: str
    _attribute: str

    def __init__(self, configuration: config.Configuration) -> None:
        super().__init__(configuration)

        self._server = configuration.get("auth", "ldap_url")
        self._baseDN = configuration.get("auth", "ldap_base")
        self._bindDN = configuration.get("auth", "ldap_binddn")
        self._bindDNpassword = configuration.get("auth", "ldap_password")
        self._filter = configuration.get("auth", "ldap_filter")
        self._attribute = configuration.get("auth", "ldap_attribute")

        logger.debug("LDAP config: %s:%s@%s" % (self._baseDN, "**************", self._server))

    def login(self, login: str, password: str) -> str:
        try:
            conn = ldap3.Connection(self._server, self._bindDN, self._bindDNpassword)
            conn.bind()

            try:
                user: str = "%s=%s" % (self._attribute, escape.value(login))
                filter: str = "(&(%s)%s)" % (user, self._filter)

                try:
                    conn.search(search_base=self._baseDN,
                        search_scope="SUBTREE",
                        search_filter=filter,
                        attributes=[self._attribute])
                    users = conn.response
                    if users:
                        user_dn = users[0]['dn']
                        uid = users[0]['attributes'][self._attribute]
                        try:
                            conn = ldap3.Connection(self._server, user_dn, password)
                            conn.bind()
                            status = conn.result['result'] == 0
                            if status:
                                return login
                            else:
                                match conn.result['result']:
                                    case 49:
                                        logger.error("LDAP invalid credentials")                  
                                return ""
                        except ldap3.core.exceptions.LDAPInvalidCredentialsResult:
                            logger.error("LDAP invalid credentials")
                        except Exception as e:
                            logger.error("%s" % e)
                        return ""
                    else:
                        return ""
                except Exception as e:
                    raise RuntimeError("%s" % e) from e
            except Exception as e:
                raise RuntimeError("%s" % e) from e
        except ldap3.core.exceptions.LDAPInvalidCredentialsResult:
            raise RuntimeError("LDAP invalid bind credentials!") from ldap3.core.exceptions.LDAPInvalidCredentialsResult
        except Exception as e:
            logger.error("%s" % e)
        return ""

