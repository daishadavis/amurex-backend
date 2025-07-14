create table if not exists google_clients (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    client_id TEXT,
    client_secret TEXT,
    type TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

alter table google_clients add constraint unique_client_id unique (client_id);



-- -- Seed data for google_clients table
-- insert into google_clients (client_id, client_secret, type)
-- values ('your-google-client-id', 'your-google-client-secret', 'oauth')
-- on conflict (client_id) do nothing;
