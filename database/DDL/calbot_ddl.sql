-- Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE users table
CREATE TABLE v1.users (
	gid uuid NOT NULL,
	uid uuid NOT NULL,
	properties jsonb DEFAULT '{}'::jsonb NULL,
	created_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT gid_uid_same CHECK ((gid = uid)),
	CONSTRAINT users_pkey PRIMARY KEY (gid, uid)
);

-- CREATE schedules table
CREATE TABLE v1.schedules (
    gid             UUID NOT NULL,   
    uid             UUID NOT null PRIMARY KEY,
    properties      JSONB DEFAULT '{}'::jsonb,                 
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);