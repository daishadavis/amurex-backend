# Setting Up Supabase Database

## Installation and Setup

1. Install Supabase CLI
```bash
# Download and extract the Supabase CLI
curl -sL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz

# Move the binary to your PATH
sudo mv supabase /usr/local/bin

# Verify installation
supabase --version
```

## Connecting to Remote Supabase Project

1. Log in to Supabase
```bash
supabase login
```

2. Link your local project to your Supabase project
```bash
# Navigate to your project directory
cd project/directory

# Link to your remote Supabase project
supabase link --project-ref your-project-id
```

## Working with Migrations

### Creating New Migrations
```bash
# Create a new migration file
supabase migration new your_migration_name
```

### Managing Remote Database

```bash
# Push migrations to remote database
supabase db push

# To reset and update a remote Supabase database
supabase db reset --linked

# Running migrations for the first time
supabase db reset --linked
```

## Running Supabase Locally

```bash
#  To create a new local project
supabase init
# Start local Supabase development environment
supabase start
```

### Troubleshooting

- If you encounter permission issues when installing, try using `sudo`
- Ensure your Supabase project ID is correct when linking
- For database schema issues, you may need to check migration files for errors
