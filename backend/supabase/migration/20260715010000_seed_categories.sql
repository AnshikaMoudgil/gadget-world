INSERT INTO public.categories (name, slug)
VALUES
  ('Cameras', 'cameras'),
  ('Speakers/ Woofers', 'speakers-woofers'),
  ('Laptop Bags', 'laptop-bags'),
  ('Earphones Buds', 'earphones-buds'),
  ('Smart Watches', 'smart-watches'),
  ('Laptop Accessories', 'laptop-accessories'),
  ('Selfie Sticks/ Gimbles', 'selfie-sticks-gimbles'),
  ('Memory/ Pen Drives', 'memory-pen-drives'),
  ('Cables/ Connectors', 'cables-connectors'),
  ('Mobile Accessories', 'mobile-accessories'),
  ('Gift Items', 'gift-items'),
  ('Computer Softwares', 'computer-softwares')
ON CONFLICT (slug) DO NOTHING;
