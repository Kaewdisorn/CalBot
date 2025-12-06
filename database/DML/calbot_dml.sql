-- Convert string to UUID
SELECT uuid_generate_v5 (uuid_ns_url (), 'calbot_user_guest');
SELECT gen_random_uuid();

INSERT INTO v1.users (
    gid,
    uid,
    properties
) VALUES (
    'a3dfbd82-dedb-5577-bdc1-45d9e74cc5a4',
     (SELECT gen_random_uuid()), -- Group ID
    '{"email": "guest", "password_hash": "adasdsds"}'::jsonb
);