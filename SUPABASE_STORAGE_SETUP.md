# Supabase Storage Setup for Mirror Me App

## Storage Bucket Configuration

1. Go to your Supabase Dashboard > Storage
2. Click "New bucket"
3. Create a bucket named: `wardrobe`
4. Make it **Public** (so images can be displayed in the app)

## Storage Policies

After creating the bucket, set up these policies:

### 1. Allow authenticated users to upload images

```sql
-- Policy for INSERT (upload)
CREATE POLICY "Users can upload to own folder"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'wardrobe' 
    AND (storage.foldername(name))[1] = 'user_cloths'
    AND (storage.foldername(name))[2] = auth.uid()::text
);
```

### 2. Allow public read access for images

```sql
-- Policy for SELECT (read/view)
CREATE POLICY "Public can view wardrobe images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'wardrobe');
```

### 3. Allow users to delete their own images

```sql
-- Policy for DELETE
CREATE POLICY "Users can delete own images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'wardrobe'
    AND (storage.foldername(name))[1] = 'user_cloths'
    AND (storage.foldername(name))[2] = auth.uid()::text
);
```

## Quick Setup via SQL Editor

You can also run this in the Supabase SQL Editor:

```sql
-- Create the wardrobe bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('wardrobe', 'wardrobe', true)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on storage.objects if not already enabled
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Insert policy
CREATE POLICY "Users can upload to own folder" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'wardrobe' 
    AND (storage.foldername(name))[1] = 'user_cloths'
    AND (storage.foldername(name))[2] = auth.uid()::text
);

-- Select policy (public read)
CREATE POLICY "Public can view wardrobe images" ON storage.objects
FOR SELECT TO public
USING (bucket_id = 'wardrobe');

-- Delete policy
CREATE POLICY "Users can delete own images" ON storage.objects
FOR DELETE TO authenticated
USING (
    bucket_id = 'wardrobe'
    AND (storage.foldername(name))[1] = 'user_cloths'
    AND (storage.foldername(name))[2] = auth.uid()::text
);
```

## Folder Structure

Images will be stored in this structure:
```
wardrobe/
  └── user_cloths/
      └── {user_id}/
          └── {item_id}.{extension}
```
