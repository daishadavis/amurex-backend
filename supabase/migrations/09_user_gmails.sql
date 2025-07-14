create table user_gmails (
    id uuid primary key default gen_random_uuid(),
    created_at timestamp with time zone default now(),
    refresh_token text,
    email_address text,
    google_cohort text,
    user_id uuid references users(id) on delete cascade,
    access_token text,
    google_clients serial references google_clients(id) on delete cascade
);