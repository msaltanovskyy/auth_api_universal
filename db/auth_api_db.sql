CREATE TABLE IF NOT EXISTS me (
    me_id UUID PRIMARY KEY,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL, 
    datebirth DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS auth_user(
    auth_id UUID PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    me_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_online TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (me_id) REFERENCES me(me_id)
);

CREATE TABLE IF NOT EXISTS auth_session(
    session_id UUID PRIMARY KEY,
    auth_id UUID NOT NULL, 
    refresh_token TEXT NOT NULL,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (auth_id) REFERENCES auth_user(auth_id)
);


CREATE TABLE IF NOT EXISTS role (
    role_id UUID PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS permission (
    permission_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS role_permission (
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES role(role_id),
    FOREIGN KEY (permission_id) REFERENCES permission(permission_id)
);


CREATE TABLE IF NOT EXISTS user_role(
    user_role_id UUID PRIMARY KEY,
    role_id UUID NOT NULL, 
    auth_id UUID NOT NULL,
    FOREIGN KEY(role_id) REFERENCES role(role_id),
    FOREIGN KEY(auth_id) REFERENCES auth_user(auth_id)
);


/*INDEXS*/

CREATE INDEX idx_auth_user_email ON auth_user(email);
CREATE INDEX idx_user_role_auth_id ON user_role(auth_id);
CREATE INDEX idx_user_role_role_id ON user_role(role_id);

/*TRIGGERS*/
-- функция для updated_at
CREATE OR REPLACE FUNCTION update_auth_user_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_update_auth_user_updated_at
BEFORE UPDATE ON auth_user
FOR EACH ROW
EXECUTE PROCEDURE update_auth_user_updated_at();


/*VIEWS
    1. Sorting today is my birthday
    2. Sorting today was online
*/

CREATE OR REPLACE VIEW birthday_today AS
SELECT * FROM me
WHERE EXTRACT(MONTH FROM datebirth) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(DAY FROM datebirth) = EXTRACT(DAY FROM CURRENT_DATE);

CREATE OR REPLACE VIEW online_today AS
SELECT au.*
FROM auth_user au
WHERE DATE(au.last_online) = CURRENT_DATE;

/*connect UUID field*/
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";