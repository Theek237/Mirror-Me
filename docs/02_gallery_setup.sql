-- ================================================
-- SUPABASE SETUP FOR GALLERY FEATURE
-- Run this SQL in your Supabase SQL Editor
-- ================================================

-- 1. Create the user_images table
CREATE TABLE IF NOT EXISTS public.user_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    pose_name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable Row Level Security
ALTER TABLE public.user_images ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies for user_images table
DROP POLICY IF EXISTS "Users can view own images" ON public.user_images;
DROP POLICY IF EXISTS "Users can insert own images" ON public.user_images;
DROP POLICY IF EXISTS "Users can update own images" ON public.user_images;
DROP POLICY IF EXISTS "Users can delete own images" ON public.user_images;

CREATE POLICY "Users can view own images" ON public.user_images
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own images" ON public.user_images
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own images" ON public.user_images
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own images" ON public.user_images
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Create indexes
CREATE INDEX IF NOT EXISTS idx_user_images_user_id ON public.user_images(user_id);
CREATE INDEX IF NOT EXISTS idx_user_images_created_at ON public.user_images(created_at DESC);

-- ================================================
-- STORAGE BUCKET SETUP
-- ================================================

-- Create the gallery bucket (run this or create manually in dashboard)
INSERT INTO storage.buckets (id, name, public)
VALUES ('gallery', 'gallery', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- ================================================
-- STORAGE POLICIES - IMPORTANT!
-- First, drop existing policies to avoid conflicts
-- ================================================

DROP POLICY IF EXISTS "Authenticated users can upload to gallery" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view gallery images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own gallery images" ON storage.objects;
DROP POLICY IF EXISTS "Gallery upload policy" ON storage.objects;
DROP POLICY IF EXISTS "Gallery select policy" ON storage.objects;
DROP POLICY IF EXISTS "Gallery delete policy" ON storage.objects;

-- Allow authenticated users to upload to their own folder
CREATE POLICY "Gallery upload policy" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'gallery'
);

-- Allow anyone to view images (since bucket is public)
CREATE POLICY "Gallery select policy" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'gallery');

-- Allow authenticated users to delete their own images
CREATE POLICY "Gallery delete policy" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'gallery');

-- ================================================
-- ALSO UPDATE WARDROBE STORAGE IF NOT DONE
-- ================================================

-- Make sure wardrobe bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('wardrobe', 'wardrobe', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Wardrobe upload policy" ON storage.objects;
DROP POLICY IF EXISTS "Wardrobe select policy" ON storage.objects;
DROP POLICY IF EXISTS "Wardrobe delete policy" ON storage.objects;

CREATE POLICY "Wardrobe upload policy" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'wardrobe');

CREATE POLICY "Wardrobe select policy" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'wardrobe');

CREATE POLICY "Wardrobe delete policy" ON storage.objects
FOR DELETE TO authenticated
USING (bucket_id = 'wardrobe');
