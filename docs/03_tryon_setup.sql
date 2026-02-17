-- ================================================
-- SUPABASE SETUP FOR TRY-ON FEATURE
-- Run this SQL in your Supabase SQL Editor
-- ================================================

-- 1. Create the tryon_results table
CREATE TABLE IF NOT EXISTS public.tryon_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_image_url TEXT NOT NULL,
    cloth_image_url TEXT NOT NULL,
    result_image_url TEXT NOT NULL,
    prompt TEXT,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable Row Level Security
ALTER TABLE public.tryon_results ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies for tryon_results table
DROP POLICY IF EXISTS "Users can view own tryon results" ON public.tryon_results;
DROP POLICY IF EXISTS "Users can insert own tryon results" ON public.tryon_results;
DROP POLICY IF EXISTS "Users can update own tryon results" ON public.tryon_results;
DROP POLICY IF EXISTS "Users can delete own tryon results" ON public.tryon_results;

CREATE POLICY "Users can view own tryon results" ON public.tryon_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tryon results" ON public.tryon_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tryon results" ON public.tryon_results
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tryon results" ON public.tryon_results
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_tryon_results_user_id ON public.tryon_results(user_id);
CREATE INDEX IF NOT EXISTS idx_tryon_results_created_at ON public.tryon_results(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tryon_results_is_favorite ON public.tryon_results(is_favorite);

-- ================================================
-- STORAGE BUCKET SETUP FOR TRY-ON
-- ================================================

-- Create the tryon bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('tryon', 'tryon', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- ================================================
-- STORAGE POLICIES FOR TRY-ON BUCKET
-- ================================================

DROP POLICY IF EXISTS "TryOn upload policy" ON storage.objects;
DROP POLICY IF EXISTS "TryOn select policy" ON storage.objects;
DROP POLICY IF EXISTS "TryOn delete policy" ON storage.objects;

-- Allow authenticated users to upload to tryon bucket
CREATE POLICY "TryOn upload policy" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'tryon');

-- Allow anyone to view images (since bucket is public)
CREATE POLICY "TryOn select policy" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'tryon');

-- Allow authenticated users to delete their own images
CREATE POLICY "TryOn delete policy" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'tryon');
