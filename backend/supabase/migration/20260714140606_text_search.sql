-- =========================================================================
-- SECTION 6: Full Text Search
-- =========================================================================

-- Add full-text search vector to products
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS fts TSVECTOR GENERATED ALWAYS AS (
    to_tsvector('english', COALESCE(name, '') || ' ' || COALESCE(description, ''))
  ) STORED;

-- Create GIN index for fast search queries
CREATE INDEX IF NOT EXISTS idx_products_fts ON public.products USING GIN (fts);
