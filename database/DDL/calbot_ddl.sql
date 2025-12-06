-- CREATE user table
CREATE TABLE v1.users (
    -- Unique Identifiers ------------------------------------------
    uid             UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Primary Key (User ID)
    gid             UUID NOT NULL,                              -- Group ID (Foreign Key to Groups)

    -- Authentication and Security ---------------------------------
    email           VARCHAR(255) UNIQUE NOT NULL,               -- Unique email address
    password_hash   VARCHAR(255) NOT NULL,                      -- Hashed password (NEVER plaintext)

    -- Dynamic Data ------------------------------------------------
    properties      JSONB DEFAULT '{}'::jsonb,                  -- Flexible storage for metadata/settings

    -- Timestamps --------------------------------------------------
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);