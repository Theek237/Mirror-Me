-- Supabase SQL Schema for Mirror Me App
-- Run this in your Supabase SQL Editor

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    email TEXT,
    photo_url TEXT,
    auth_provider TEXT DEFAULT 'email',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own data
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Create policy for users to update their own data
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Create policy for users to insert their own data
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- IMPORTANT: Auto-create user profile on signup
-- This trigger automatically creates a user profile when someone signs up
-- =====================================================

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, auth_provider, created_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', ''),
        COALESCE(NEW.raw_app_meta_data->>'provider', 'email'),
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to call function on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create wardrobe table
CREATE TABLE IF NOT EXISTS public.wardrobe (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.wardrobe ENABLE ROW LEVEL SECURITY;

-- Create policy for users to read their own wardrobe items
CREATE POLICY "Users can view own wardrobe" ON public.wardrobe
    FOR SELECT USING (auth.uid() = user_id);

-- Create policy for users to insert their own wardrobe items
CREATE POLICY "Users can add to own wardrobe" ON public.wardrobe
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policy for users to delete their own wardrobe items
CREATE POLICY "Users can delete from own wardrobe" ON public.wardrobe
    FOR DELETE USING (auth.uid() = user_id);

-- Create policy for users to update their own wardrobe items
CREATE POLICY "Users can update own wardrobe" ON public.wardrobe
    FOR UPDATE USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS wardrobe_user_id_idx ON public.wardrobe(user_id);
CREATE INDEX IF NOT EXISTS wardrobe_created_at_idx ON public.wardrobe(created_at DESC);

-- Create tryon_results table (for future use with AI try-on feature)
CREATE TABLE IF NOT EXISTS public.tryon_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_image_url TEXT NOT NULL,
    cloth_image_url TEXT NOT NULL,
    result_image_url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.tryon_results ENABLE ROW LEVEL SECURITY;

-- Create policies for tryon_results
CREATE POLICY "Users can view own tryon results" ON public.tryon_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own tryon results" ON public.tryon_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own tryon results" ON public.tryon_results
    FOR DELETE USING (auth.uid() = user_id);

-- Create index
CREATE INDEX IF NOT EXISTS tryon_results_user_id_idx ON public.tryon_results(user_id);
