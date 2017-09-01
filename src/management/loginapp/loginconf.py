# Create dummy secrey key so we can use sessions
SECRET_KEY = '123456790'
WTF_CSRF_ENABLED = False

# Create in-memory database
SQLALCHEMY_ECHO = False

# pengwei test
SQLALCHEMY_DATABASE_URI = "mysql://maliciousrwuser:123456@127.0.0.1:3306/db_mp_conf?charset=utf8"
SQLALCHEMY_TRACK_MODIFICATIONS = True

# Flask-Security config
SECURITY_URL_PREFIX = "/management/login"
SECURITY_PASSWORD_HASH = "pbkdf2_sha512"
SECURITY_PASSWORD_SALT = "ATGUOHAELKiubahiughaerGOJAEGj"

# Flask-Security URLs, overridden because they don't put a / at the end
SECURITY_LOGIN_URL = "/login/"
SECURITY_LOGOUT_URL = "/logout/"
#SECURITY_CHANGE_URL = "/change"
#SECURITY_RESET_URL = "/reset/"
SECURITY_REGISTER_URL = "/register/"

SECURITY_POST_LOGIN_VIEW = "/index"
SECURITY_POST_LOGOUT_VIEW = "/"
SECURITY_POST_REGISTER_VIEW = "/"

# Flask-Security features
SECURITY_CHANGEABLE = True
SECURITY_REGISTERABLE = True
SECURITY_CONFIRMABLE = True
SECURITY_RECOVERABLE = True

# cookies过期时间, 7天
SECURITY_TOKEN_MAX_AGE = 604800

# pengwei test
SECURITY_LOGIN_WITHOUT_CONFIRMATION = True
SECURITY_SEND_REGISTER_EMAIL = False
