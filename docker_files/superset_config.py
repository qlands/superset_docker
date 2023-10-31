# Superset specific config
ROW_LIMIT = 5000

# Generate a new key using "openssl rand -base64 42" and restart the server
SECRET_KEY = "+rANfYMEMN/bi7UmTI94w/BfenkUYCq+jeekOml04AhT85HbNu27wVTP"

# The SQLAlchemy connection string to your database backend
SQLALCHEMY_DATABASE_URI = 'mysql+mysqlconnector://mysql_user:mysql_password@mysql_server:mysql_port/superset?charset=utf8mb4&ssl_disabled=True'


# Basic configuration for http. Change and secure in https production environment
TALISMAN_ENABLED = False
WTF_CSRF_ENABLED = False
