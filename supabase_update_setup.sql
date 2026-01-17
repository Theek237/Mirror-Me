-- =============================================
-- Mirror Me - Supabase Setup SQL
-- Run this in your Supabase SQL Editor
-- =============================================

-- 1. Update tryon_results table to add is_favorite column
-- (Run only if tryon_results table already exists)
ALTER TABLE tryon_results ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN DEFAULT false;

-- 2. Create recommendations table
CREATE TABLE IF NOT EXISTS recommendations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    recommendation_text TEXT NOT NULL,
    image_source TEXT, -- 'gallery', 'wardrobe', 'tryon', 'upload'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Enable RLS on recommendations table
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;

-- 4. Create RLS policies for recommendations
CREATE POLICY "Users can view their own recommendations"
ON recommendations FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own recommendations"
ON recommendations FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recommendations"
ON recommendations FOR DELETE
USING (auth.uid() = user_id);

-- 5. Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_tryon_results_is_favorite ON tryon_results(is_favorite);

-- =============================================
-- If you haven't created tryon_results table yet, run this:
-- =============================================
/*
CREATE TABLE IF NOT EXISTS tryon_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    pose_image_url TEXT NOT NULL,
    clothing_image_url TEXT NOT NULL,
    result_image_url TEXT NOT NULL,
    prompt TEXT,
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE tryon_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own tryon results"
ON tryon_results FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tryon results"
ON tryon_results FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tryon results"
ON tryon_results FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tryon results"
ON tryon_results FOR DELETE
USING (auth.uid() = user_id);
*/

-- =============================================
-- Storage bucket (run only if not already created)
-- =============================================
-- Go to Storage in Supabase Dashboard and create:
-- 1. Bucket name: 'tryon' (public)
-- 2. Set storage policies to allow authenticated users to upload/read
