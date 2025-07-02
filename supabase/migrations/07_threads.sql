-- Migration script to create the threads table and necessary extensions

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create threads table
CREATE TABLE IF NOT EXISTS threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_starred BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX idx_threads_user_id ON threads(user_id);
CREATE INDEX idx_threads_created_at ON threads(created_at);
CREATE INDEX idx_threads_title ON threads(title);

-- Create messages table to store messages within threads
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  thread_id UUID NOT NULL REFERENCES threads(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  reply TEXT,
  sources JSONB,
  completion_time FLOAT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for messages
CREATE INDEX idx_messages_thread_id ON messages(thread_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Create triggers to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger for threads table
CREATE TRIGGER update_threads_updated_at
BEFORE UPDATE ON threads
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Add trigger for messages table
CREATE TRIGGER update_messages_updated_at
BEFORE UPDATE ON messages
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Update thread's last_accessed_at when a new message is added
CREATE OR REPLACE FUNCTION update_thread_last_accessed()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE threads
  SET last_accessed_at = NOW()
  WHERE id = NEW.thread_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_thread_last_accessed
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_thread_last_accessed();

-- Add comments to document tables
COMMENT ON TABLE threads IS 'Stores search conversation threads';
COMMENT ON TABLE messages IS 'Stores individual messages within conversation threads';