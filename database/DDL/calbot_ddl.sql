-- Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE user table
CREATE TABLE v1.users (
    gid             UUID NOT NULL,   
    uid             UUID NOT null PRIMARY KEY,
    properties      JSONB DEFAULT '{}'::jsonb,                 
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);