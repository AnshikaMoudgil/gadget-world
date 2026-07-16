-- =========================================================================
-- Seed: Brands, Products, Variants & Specs
-- =========================================================================
-- NOTE: Images are referenced as Supabase Storage public URLs.
--       You must upload the actual image files to the 'products' and 'brands'
--       storage buckets via the Supabase Dashboard or API before these URLs
--       will resolve. The path convention is:
--         products bucket → <category-slug>/<product-slug>/<filename>.png
--         brands   bucket → <brand-slug>/logo.png
-- =========================================================================

-- -------------------------------------------------------------------------
-- Helper: Supabase storage base URL (change if your project ref differs)
-- -------------------------------------------------------------------------
DO $$
DECLARE
  base_url TEXT := 'https://ndfrbagekmgsunvtkxjh.supabase.co/storage/v1/object/public';

  -- Brand IDs
  brand_sony       UUID;
  brand_jbl        UUID;
  brand_boat       UUID;
  brand_apple      UUID;
  brand_samsung    UUID;
  brand_hp         UUID;
  brand_logitech   UUID;
  brand_sandisk    UUID;
  brand_anker      UUID;
  brand_dji        UUID;
  brand_mi         UUID;
  brand_noise      UUID;

  -- Category IDs (fetched from existing seed)
  cat_cameras          UUID;
  cat_speakers         UUID;
  cat_laptop_bags      UUID;
  cat_earphones        UUID;
  cat_smart_watches    UUID;
  cat_laptop_acc       UUID;
  cat_selfie_sticks    UUID;
  cat_memory_drives    UUID;
  cat_cables           UUID;
  cat_mobile_acc       UUID;
  cat_gift_items       UUID;
  cat_software         UUID;

  -- Product IDs
  p1  UUID; p2  UUID; p3  UUID; p4  UUID;
  p5  UUID; p6  UUID; p7  UUID; p8  UUID;
  p9  UUID; p10 UUID; p11 UUID; p12 UUID;
  p13 UUID; p14 UUID; p15 UUID; p16 UUID;
  p17 UUID; p18 UUID; p19 UUID; p20 UUID;
  p21 UUID; p22 UUID; p23 UUID; p24 UUID;

  -- Variant Group IDs
  vg1 UUID; vg2 UUID; vg3 UUID; vg4 UUID;
  vg5 UUID; vg6 UUID; vg7 UUID; vg8 UUID;

  -- Variant Option IDs
  vo1 UUID; vo2 UUID; vo3 UUID; vo4 UUID;
  vo5 UUID; vo6 UUID; vo7 UUID; vo8 UUID;
  vo9 UUID; vo10 UUID; vo11 UUID; vo12 UUID;
  vo13 UUID; vo14 UUID; vo15 UUID; vo16 UUID;

  -- Product Variant IDs
  pv1 UUID; pv2 UUID; pv3 UUID; pv4 UUID;
  pv5 UUID; pv6 UUID; pv7 UUID; pv8 UUID;
  pv9 UUID; pv10 UUID; pv11 UUID; pv12 UUID;
  pv13 UUID; pv14 UUID; pv15 UUID; pv16 UUID;

BEGIN

-- =========================================================================
-- 1. BRANDS
-- =========================================================================
INSERT INTO public.brands (name, slug, logo_url) VALUES
  ('Sony',     'sony',     base_url || '/brands/sony/logo.png'),
  ('JBL',      'jbl',      base_url || '/brands/jbl/logo.png'),
  ('boAt',     'boat',     base_url || '/brands/boat/logo.png'),
  ('Apple',    'apple',    base_url || '/brands/apple/logo.png'),
  ('Samsung',  'samsung',  base_url || '/brands/samsung/logo.png'),
  ('HP',       'hp',       base_url || '/brands/hp/logo.png'),
  ('Logitech', 'logitech', base_url || '/brands/logitech/logo.png'),
  ('SanDisk',  'sandisk',  base_url || '/brands/sandisk/logo.png'),
  ('Anker',    'anker',    base_url || '/brands/anker/logo.png'),
  ('DJI',      'dji',      base_url || '/brands/dji/logo.png'),
  ('Mi',       'mi',       base_url || '/brands/mi/logo.png'),
  ('Noise',    'noise',    base_url || '/brands/noise/logo.png')
ON CONFLICT (slug) DO NOTHING;

-- Fetch brand IDs
SELECT id INTO brand_sony     FROM public.brands WHERE slug = 'sony';
SELECT id INTO brand_jbl      FROM public.brands WHERE slug = 'jbl';
SELECT id INTO brand_boat     FROM public.brands WHERE slug = 'boat';
SELECT id INTO brand_apple    FROM public.brands WHERE slug = 'apple';
SELECT id INTO brand_samsung  FROM public.brands WHERE slug = 'samsung';
SELECT id INTO brand_hp       FROM public.brands WHERE slug = 'hp';
SELECT id INTO brand_logitech FROM public.brands WHERE slug = 'logitech';
SELECT id INTO brand_sandisk  FROM public.brands WHERE slug = 'sandisk';
SELECT id INTO brand_anker    FROM public.brands WHERE slug = 'anker';
SELECT id INTO brand_dji      FROM public.brands WHERE slug = 'dji';
SELECT id INTO brand_mi       FROM public.brands WHERE slug = 'mi';
SELECT id INTO brand_noise    FROM public.brands WHERE slug = 'noise';

-- Fetch category IDs
SELECT id INTO cat_cameras       FROM public.categories WHERE slug = 'cameras';
SELECT id INTO cat_speakers      FROM public.categories WHERE slug = 'speakers-woofers';
SELECT id INTO cat_laptop_bags   FROM public.categories WHERE slug = 'laptop-bags';
SELECT id INTO cat_earphones     FROM public.categories WHERE slug = 'earphones-buds';
SELECT id INTO cat_smart_watches FROM public.categories WHERE slug = 'smart-watches';
SELECT id INTO cat_laptop_acc    FROM public.categories WHERE slug = 'laptop-accessories';
SELECT id INTO cat_selfie_sticks FROM public.categories WHERE slug = 'selfie-sticks-gimbles';
SELECT id INTO cat_memory_drives FROM public.categories WHERE slug = 'memory-pen-drives';
SELECT id INTO cat_cables        FROM public.categories WHERE slug = 'cables-connectors';
SELECT id INTO cat_mobile_acc    FROM public.categories WHERE slug = 'mobile-accessories';
SELECT id INTO cat_gift_items    FROM public.categories WHERE slug = 'gift-items';
SELECT id INTO cat_software      FROM public.categories WHERE slug = 'computer-softwares';

-- =========================================================================
-- 2. PRODUCTS  (2 per category = 24 products)
-- =========================================================================

-- ---- CAMERAS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'sony-alpha-a6400',
  'Sony Alpha A6400 Mirrorless Camera',
  brand_sony, cat_cameras,
  'Compact mirrorless camera with world''s fastest autofocus, 24.2MP APS-C sensor, and 4K video recording. Perfect for vlogging and travel photography.',
  '["24.2MP APS-C Exmor CMOS sensor", "Real-time Eye AF & tracking", "4K HDR movie recording", "180° tiltable LCD touchscreen", "Up to 11fps continuous shooting", "425-point phase-detection AF"]'::jsonb,
  ('["' || base_url || '/products/cameras/sony-alpha-a6400/main.png"]')::jsonb,
  74990.00, 84990.00, 15, true, true
) RETURNING id INTO p1;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'samsung-galaxy-cam-2',
  'Samsung Galaxy Camera 2',
  brand_samsung, cat_cameras,
  'Smart camera with 16.3MP BSI CMOS sensor, 21x optical zoom, built-in Wi-Fi and Android OS for seamless sharing.',
  '["16.3MP BSI CMOS sensor", "21x Super Zoom", "Built-in Wi-Fi & NFC", "Android 4.3 Jelly Bean OS", "4.8\" HD touchscreen", "Full HD 1080p video"]'::jsonb,
  ('["' || base_url || '/products/cameras/samsung-galaxy-cam-2/main.png"]')::jsonb,
  24990.00, 32990.00, 8, true, false
) RETURNING id INTO p2;

-- ---- SPEAKERS/ WOOFERS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'jbl-charge-5',
  'JBL Charge 5 Portable Bluetooth Speaker',
  brand_jbl, cat_speakers,
  'Powerful portable speaker with deep bass, IP67 waterproof & dustproof rating, and 20 hours of playtime. Built-in powerbank charges your devices.',
  '["20 hours playtime", "IP67 waterproof & dustproof", "JBL PartyBoost for pairing", "Built-in powerbank", "Dual passive bass radiators", "40W output power"]'::jsonb,
  ('["' || base_url || '/products/speakers-woofers/jbl-charge-5/main.png"]')::jsonb,
  14999.00, 17999.00, 30, true, true
) RETURNING id INTO p3;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'boat-stone-1500',
  'boAt Stone 1500 40W Bluetooth Speaker',
  brand_boat, cat_speakers,
  'Premium 40W sound with deep bass, RGB LED lights, and up to 14 hours of playtime. IPX5 splash resistant for outdoor parties.',
  '["40W immersive sound", "Up to 14 hours playtime", "IPX5 splash resistant", "RGB LED lights", "TWS pairing support", "Built-in mic for calls"]'::jsonb,
  ('["' || base_url || '/products/speakers-woofers/boat-stone-1500/main.png"]')::jsonb,
  4499.00, 7990.00, 50, true, false
) RETURNING id INTO p4;

-- ---- LAPTOP BAGS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'hp-premium-backpack-156',
  'HP Premium 15.6 Inch Laptop Backpack',
  brand_hp, cat_laptop_bags,
  'Water-resistant laptop backpack with padded compartments, anti-theft pocket, and ergonomic design. Fits up to 15.6" laptops.',
  '["Fits up to 15.6\" laptops", "Water-resistant fabric", "Anti-theft back pocket", "Padded shoulder straps", "Multiple compartments", "Luggage strap"]'::jsonb,
  ('["' || base_url || '/products/laptop-bags/hp-premium-backpack-156/main.png"]')::jsonb,
  1499.00, 2499.00, 100, true, false
) RETURNING id INTO p5;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'mi-urban-backpack',
  'Mi City Urban Backpack',
  brand_mi, cat_laptop_bags,
  'Minimalist backpack with 4-layer protection, water-resistant 600D polyester, and holds up to 14\" laptops comfortably.',
  '["Fits up to 14\" laptops", "4-layer protection", "Water-resistant 600D polyester", "Hidden anti-theft pocket", "Ergonomic S-curved straps", "26L capacity"]'::jsonb,
  ('["' || base_url || '/products/laptop-bags/mi-urban-backpack/main.png"]')::jsonb,
  999.00, 1499.00, 75, true, false
) RETURNING id INTO p6;

-- ---- EARPHONES BUDS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'apple-airpods-pro-2',
  'Apple AirPods Pro 2nd Gen (USB-C)',
  brand_apple, cat_earphones,
  'Premium true wireless earbuds with Active Noise Cancellation, Adaptive Transparency, and Personalised Spatial Audio with dynamic head tracking.',
  '["Active Noise Cancellation", "Adaptive Transparency mode", "Personalised Spatial Audio", "Up to 6 hours listening time", "MagSafe charging case", "IP54 dust & water resistant"]'::jsonb,
  ('["' || base_url || '/products/earphones-buds/apple-airpods-pro-2/main.png"]')::jsonb,
  20990.00, 24900.00, 40, true, true
) RETURNING id INTO p7;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'boat-airdopes-141',
  'boAt Airdopes 141 TWS Earbuds',
  brand_boat, cat_earphones,
  'Lightweight TWS earbuds with 8mm drivers, ENx noise cancellation for calls, and 42 hours total playtime. Perfect everyday earbuds.',
  '["42 hours total playtime", "8mm audio drivers", "ENx noise cancellation for calls", "Low latency mode for gaming", "IPX4 water resistant", "Type-C fast charging"]'::jsonb,
  ('["' || base_url || '/products/earphones-buds/boat-airdopes-141/main.png"]')::jsonb,
  899.00, 2990.00, 200, true, false
) RETURNING id INTO p8;

-- ---- SMART WATCHES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'apple-watch-series-9',
  'Apple Watch Series 9 (GPS, 45mm)',
  brand_apple, cat_smart_watches,
  'The most powerful Apple Watch with S9 chip, brighter Always-On display, and the magical Double Tap gesture. Blood oxygen, ECG, and temperature sensing.',
  '["S9 SiP chip with 4-core Neural Engine", "Always-On Retina display (2000 nits)", "Double Tap gesture", "Blood Oxygen & ECG app", "Temperature sensing", "WR50 water resistance"]'::jsonb,
  ('["' || base_url || '/products/smart-watches/apple-watch-series-9/main.png"]')::jsonb,
  41900.00, 46900.00, 20, true, true
) RETURNING id INTO p9;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'noise-colorfit-pro-5',
  'Noise ColorFit Pro 5 Smartwatch',
  brand_noise, cat_smart_watches,
  'Affordable smartwatch with 1.85" AMOLED display, Bluetooth calling, 100+ sports modes, and 7-day battery life.',
  '["1.85\" AMOLED display", "Bluetooth calling", "100+ sports modes", "SpO2 & heart rate monitor", "7-day battery life", "IP68 water resistant"]'::jsonb,
  ('["' || base_url || '/products/smart-watches/noise-colorfit-pro-5/main.png"]')::jsonb,
  2999.00, 5999.00, 60, true, false
) RETURNING id INTO p10;

-- ---- LAPTOP ACCESSORIES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'logitech-mx-master-3s',
  'Logitech MX Master 3S Wireless Mouse',
  brand_logitech, cat_laptop_acc,
  'Premium ergonomic wireless mouse with MagSpeed electromagnetic scroll, 8K DPI sensor, and quiet clicks. Works on any surface including glass.',
  '["8000 DPI any-surface tracking", "MagSpeed electromagnetic scroll", "Quiet clicks", "USB-C quick charging", "Works on glass", "Connect up to 3 devices"]'::jsonb,
  ('["' || base_url || '/products/laptop-accessories/logitech-mx-master-3s/main.png"]')::jsonb,
  8995.00, 10995.00, 25, true, true
) RETURNING id INTO p11;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'hp-usb-c-docking-station',
  'HP USB-C Universal Docking Station',
  brand_hp, cat_laptop_acc,
  'Turn your USB-C laptop into a full workstation. Supports dual 4K displays, ethernet, and charges your laptop simultaneously.',
  '["Dual 4K display support", "100W Power Delivery", "Gigabit Ethernet port", "4x USB-A & 2x USB-C ports", "3.5mm audio combo jack", "Plug and play setup"]'::jsonb,
  ('["' || base_url || '/products/laptop-accessories/hp-usb-c-docking-station/main.png"]')::jsonb,
  8990.00, 12990.00, 12, true, false
) RETURNING id INTO p12;

-- ---- SELFIE STICKS/ GIMBLES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'dji-om-6',
  'DJI OM 6 Smartphone Gimbal Stabilizer',
  brand_dji, cat_selfie_sticks,
  '3-axis smartphone gimbal with ActiveTrack 6.0, built-in extension rod, and magnetic clamp design for buttery-smooth video.',
  '["3-axis stabilization", "ActiveTrack 6.0 subject tracking", "Built-in extension rod (215mm)", "Magnetic phone clamp", "Gesture control", "6.4 hours battery life"]'::jsonb,
  ('["' || base_url || '/products/selfie-sticks-gimbles/dji-om-6/main.png"]')::jsonb,
  10999.00, 13999.00, 18, true, true
) RETURNING id INTO p13;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'mi-selfie-stick-tripod',
  'Mi Selfie Stick Tripod with Bluetooth Remote',
  brand_mi, cat_selfie_sticks,
  'Versatile aluminium selfie stick that doubles as a tripod. Detachable Bluetooth remote and 360° rotation.',
  '["Aluminium alloy body", "Extends up to 56cm", "Doubles as tripod", "Detachable Bluetooth remote", "360° rotation head", "Lightweight 155g"]'::jsonb,
  ('["' || base_url || '/products/selfie-sticks-gimbles/mi-selfie-stick-tripod/main.png"]')::jsonb,
  1099.00, 1499.00, 90, true, false
) RETURNING id INTO p14;

-- ---- MEMORY/ PEN DRIVES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'sandisk-extreme-pro-256gb',
  'SanDisk Extreme Pro 256GB USB 3.2 Flash Drive',
  brand_sandisk, cat_memory_drives,
  'High-performance USB 3.2 flash drive with read speeds up to 420MB/s. Solid-state performance in a compact design.',
  '["256GB capacity", "Read speed up to 420MB/s", "Write speed up to 380MB/s", "USB 3.2 Gen 1", "128-bit AES encryption", "Retractable USB-A connector"]'::jsonb,
  ('["' || base_url || '/products/memory-pen-drives/sandisk-extreme-pro-256gb/main.png"]')::jsonb,
  3299.00, 5199.00, 70, true, false
) RETURNING id INTO p15;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'samsung-evo-plus-128gb-sdcard',
  'Samsung EVO Plus 128GB microSD Card',
  brand_samsung, cat_memory_drives,
  'Fast and reliable microSD card with up to 160MB/s transfer speed. Perfect for smartphones, tablets, and action cameras.',
  '["128GB capacity", "Up to 160MB/s read", "Up to 120MB/s write", "UHS-I U3, V30, A2 rated", "4K UHD video recording ready", "Water, temperature, X-ray, magnet proof"]'::jsonb,
  ('["' || base_url || '/products/memory-pen-drives/samsung-evo-plus-128gb-sdcard/main.png"]')::jsonb,
  1099.00, 1999.00, 150, true, false
) RETURNING id INTO p16;

-- ---- CABLES/ CONNECTORS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'anker-usb-c-to-lightning-cable',
  'Anker PowerLine III USB-C to Lightning Cable (1.8m)',
  brand_anker, cat_cables,
  'MFi certified braided nylon cable for fast charging iPhones. Supports Power Delivery for up to 3x faster charging.',
  '["MFi certified", "Braided nylon for durability", "Supports Power Delivery", "1.8m length", "35,000+ bend lifespan", "Universal compatibility"]'::jsonb,
  ('["' || base_url || '/products/cables-connectors/anker-usb-c-to-lightning-cable/main.png"]')::jsonb,
  1299.00, 1799.00, 120, true, false
) RETURNING id INTO p17;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'anker-7in1-usb-c-hub',
  'Anker 7-in-1 USB-C Hub Adapter',
  brand_anker, cat_cables,
  'Compact hub with HDMI 4K, 100W PD pass-through, 2x USB-A 3.0, SD/microSD readers, and USB-C data port.',
  '["4K HDMI output", "100W Power Delivery pass-through", "2x USB-A 3.0 ports", "SD & microSD card readers", "USB-C data port", "Ultra-slim aluminium body"]'::jsonb,
  ('["' || base_url || '/products/cables-connectors/anker-7in1-usb-c-hub/main.png"]')::jsonb,
  3499.00, 4999.00, 45, true, false
) RETURNING id INTO p18;

-- ---- MOBILE ACCESSORIES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'apple-magsafe-charger',
  'Apple MagSafe Charger (15W)',
  brand_apple, cat_mobile_acc,
  'Perfectly aligned wireless charging for iPhone 12 and later. Snaps magnetically for effortless charging at up to 15W.',
  '["15W wireless charging", "Magnetic alignment", "Compatible with iPhone 12+", "USB-C cable included", "Works through MagSafe cases", "Qi compatible"]'::jsonb,
  ('["' || base_url || '/products/mobile-accessories/apple-magsafe-charger/main.png"]')::jsonb,
  4500.00, 4900.00, 55, true, false
) RETURNING id INTO p19;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'samsung-25w-travel-adapter',
  'Samsung 25W USB-C Travel Adapter',
  brand_samsung, cat_mobile_acc,
  'Compact Super Fast Charger that powers up compatible Samsung Galaxy devices quickly. USB PD 3.0 & PPS support.',
  '["25W Super Fast Charging", "USB PD 3.0 & PPS", "Compact travel-friendly design", "USB-C port", "Over-voltage protection", "Compatible with Galaxy S/Note/A series"]'::jsonb,
  ('["' || base_url || '/products/mobile-accessories/samsung-25w-travel-adapter/main.png"]')::jsonb,
  1199.00, 1999.00, 180, true, false
) RETURNING id INTO p20;

-- ---- GIFT ITEMS ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'mi-3-in-1-gift-set',
  'Mi 3-in-1 Gadget Gift Set',
  brand_mi, cat_gift_items,
  'Perfect tech gift box containing Mi Band, Mi In-Ear earphones, and 10000mAh power bank. Beautifully boxed for gifting.',
  '["Mi Band smart fitness tracker", "Mi In-Ear Headphones Basic", "10000mAh Mi Power Bank", "Premium gift packaging", "One year warranty on all items", "Ideal for tech enthusiasts"]'::jsonb,
  ('["' || base_url || '/products/gift-items/mi-3-in-1-gift-set/main.png"]')::jsonb,
  3499.00, 4999.00, 35, true, false
) RETURNING id INTO p21;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'boat-smartwatch-earbuds-combo',
  'boAt Smartwatch + Earbuds Gift Combo',
  brand_boat, cat_gift_items,
  'Trendy combo pack featuring boAt Wave Call smartwatch and boAt Airdopes earbuds. Perfect birthday or festival gift.',
  '["boAt Wave Call smartwatch", "boAt Airdopes 131 earbuds", "Premium combo packaging", "Bluetooth calling on watch", "Total 42 hours earbud playtime", "1 year brand warranty"]'::jsonb,
  ('["' || base_url || '/products/gift-items/boat-smartwatch-earbuds-combo/main.png"]')::jsonb,
  2999.00, 5990.00, 40, true, false
) RETURNING id INTO p22;

-- ---- COMPUTER SOFTWARES ----
INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'norton-360-deluxe-1yr',
  'Norton 360 Deluxe - 1 Year (3 Devices)',
  NULL, cat_software,
  'Complete antivirus and online privacy protection for up to 3 devices. Includes VPN, Dark Web Monitoring, and 50GB cloud backup.',
  '["Real-time threat protection", "Secure VPN included", "Dark Web Monitoring", "50GB PC Cloud Backup", "SafeCam for PC webcam", "Password Manager"]'::jsonb,
  ('["' || base_url || '/products/computer-softwares/norton-360-deluxe-1yr/main.png"]')::jsonb,
  2799.00, 4999.00, 500, true, false
) RETURNING id INTO p23;

INSERT INTO public.products (slug, name, brand_id, category_id, description, about_points, images, price, mrp, stock_quantity, is_active, is_featured)
VALUES (
  'microsoft-365-personal-1yr',
  'Microsoft 365 Personal - 1 Year Subscription',
  NULL, cat_software,
  'Premium Office apps (Word, Excel, PowerPoint, Outlook) plus 1TB OneDrive storage and advanced security for 1 person.',
  '["Word, Excel, PowerPoint, Outlook", "1TB OneDrive cloud storage", "Advanced security features", "Works on PC, Mac, tablet & phone", "Always up to date", "Microsoft Editor AI writing assistance"]'::jsonb,
  ('["' || base_url || '/products/computer-softwares/microsoft-365-personal-1yr/main.png"]')::jsonb,
  4199.00, 4899.00, 999, true, false
) RETURNING id INTO p24;


-- =========================================================================
-- 3. PRODUCT SPECS  (select products)
-- =========================================================================

-- Sony Alpha A6400 specs
INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
  (p1, 'Sensor', '24.2MP APS-C Exmor CMOS', 1),
  (p1, 'ISO Range', '100–32000 (expandable to 102400)', 2),
  (p1, 'Video', '4K (3840x2160) at 30fps', 3),
  (p1, 'AF Points', '425 phase-detection', 4),
  (p1, 'Display', '3.0" tilting LCD touchscreen', 5),
  (p1, 'Weight', '403g (with battery & card)', 6),
  (p1, 'Connectivity', 'Wi-Fi, Bluetooth 4.1, NFC, USB, HDMI', 7);

-- JBL Charge 5 specs
INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
  (p3, 'Output Power', '40W (1x woofer + 1x tweeter)', 1),
  (p3, 'Frequency Response', '65Hz - 20kHz', 2),
  (p3, 'Battery', '7500mAh, 20 hours playtime', 3),
  (p3, 'Waterproof', 'IP67 (dust & water)', 4),
  (p3, 'Bluetooth', '5.1', 5),
  (p3, 'Weight', '960g', 6);

-- Apple AirPods Pro 2 specs
INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
  (p7, 'Chip', 'Apple H2', 1),
  (p7, 'Driver', 'Custom high-excursion Apple driver', 2),
  (p7, 'ANC', 'Active Noise Cancellation, 2x better', 3),
  (p7, 'Battery (Buds)', 'Up to 6 hours', 4),
  (p7, 'Battery (Case)', 'Up to 30 hours total', 5),
  (p7, 'Dust/Water', 'IP54 (buds), IPX4 (case)', 6),
  (p7, 'Connectivity', 'Bluetooth 5.3', 7);

-- Apple Watch Series 9 specs
INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
  (p9, 'Chip', 'Apple S9 SiP', 1),
  (p9, 'Display', '1.9" Always-On Retina LTPO OLED, 2000 nits', 2),
  (p9, 'Storage', '64GB', 3),
  (p9, 'Water Resistance', 'WR50 (50m)', 4),
  (p9, 'Sensors', 'Blood O2, ECG, Temperature, Accelerometer, Gyro', 5),
  (p9, 'Battery', 'Up to 18 hours', 6),
  (p9, 'Connectivity', 'Wi-Fi, Bluetooth 5.3, NFC, UWB', 7);

-- Logitech MX Master 3S specs
INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
  (p11, 'Sensor', '8000 DPI Darkfield', 1),
  (p11, 'Buttons', '7 programmable', 2),
  (p11, 'Battery', 'Up to 70 days, USB-C rechargeable', 3),
  (p11, 'Connectivity', 'Bluetooth LE, Logi Bolt USB', 4),
  (p11, 'Multi-Device', 'Up to 3 (Easy-Switch)', 5),
  (p11, 'Weight', '141g', 6);


-- =========================================================================
-- 4. PRODUCT FEATURES  (select products)
-- =========================================================================

-- JBL Charge 5 highlights
INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
  (p3, 'highlight', 'Powerful Sound', 'Optimised long excursion driver and dual JBL bass radiators deliver bold, detailed sound.', 'Speaker', 1),
  (p3, 'highlight', 'Party Proof', 'IP67 waterproof and dustproof — take it anywhere, rain or shine.', 'Shield', 2),
  (p3, 'highlight', 'Powerbank', 'Built-in powerbank lets you charge your devices on the go.', 'BatteryCharging', 3);

-- Apple AirPods Pro 2 highlights
INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
  (p7, 'highlight', 'Intelligent ANC', 'H2 chip processes sound 48,000 times per second for superior noise cancellation.', 'Headphones', 1),
  (p7, 'highlight', 'Spatial Audio', 'Personalised spatial audio with dynamic head tracking for immersive 3D sound.', 'Surround', 2),
  (p7, 'compatibility', 'iPhone', 'Works with iPhone 8 or later running iOS 16.1+', 'Phone', 1),
  (p7, 'compatibility', 'iPad', 'Compatible with iPad Pro, Air, and Mini with iPadOS 16.1+', 'Tablet', 2);


-- =========================================================================
-- 5. VARIANTS  (select products with size/colour options)
-- =========================================================================

-- --- JBL Charge 5: Colour variants ---
INSERT INTO public.variant_groups (product_id, group_name, display_order)
VALUES (p3, 'Colour', 1) RETURNING id INTO vg1;

INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg1, 'Black', 1) RETURNING id INTO vo1;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg1, 'Blue', 2) RETURNING id INTO vo2;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg1, 'Red', 3) RETURNING id INTO vo3;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg1, 'Teal', 4) RETURNING id INTO vo4;

INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p3, 'JBL-CHG5-BLK', 'Charge 5 - Black', 14999.00,
   ('["' || base_url || '/products/speakers-woofers/jbl-charge-5/main.png"]')::jsonb, 10, 1) RETURNING id INTO pv1;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p3, 'JBL-CHG5-BLU', 'Charge 5 - Blue', 14999.00,
   ('["' || base_url || '/products/speakers-woofers/jbl-charge-5/main.png"]')::jsonb, 8, 2) RETURNING id INTO pv2;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p3, 'JBL-CHG5-RED', 'Charge 5 - Red', 15499.00,
   ('["' || base_url || '/products/speakers-woofers/jbl-charge-5/main.png"]')::jsonb, 6, 3) RETURNING id INTO pv3;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p3, 'JBL-CHG5-TEL', 'Charge 5 - Teal', 14999.00,
   ('["' || base_url || '/products/speakers-woofers/jbl-charge-5/main.png"]')::jsonb, 6, 4) RETURNING id INTO pv4;

-- Link variant ↔ option
INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES
  (pv1, vo1), (pv2, vo2), (pv3, vo3), (pv4, vo4);


-- --- Apple Watch Series 9: Size + Colour variants ---
INSERT INTO public.variant_groups (product_id, group_name, display_order)
VALUES (p9, 'Case Size', 1) RETURNING id INTO vg2;
INSERT INTO public.variant_groups (product_id, group_name, display_order)
VALUES (p9, 'Colour', 2) RETURNING id INTO vg3;

INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg2, '41mm', 1) RETURNING id INTO vo5;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg2, '45mm', 2) RETURNING id INTO vo6;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg3, 'Midnight', 1) RETURNING id INTO vo7;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg3, 'Starlight', 2) RETURNING id INTO vo8;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg3, 'Silver', 3) RETURNING id INTO vo9;

INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p9, 'AW9-41-MID', 'Series 9 41mm Midnight', 39900.00,
   ('["' || base_url || '/products/smart-watches/apple-watch-series-9/main.png"]')::jsonb, 5, 1) RETURNING id INTO pv5;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p9, 'AW9-41-STAR', 'Series 9 41mm Starlight', 39900.00,
   ('["' || base_url || '/products/smart-watches/apple-watch-series-9/main.png"]')::jsonb, 4, 2) RETURNING id INTO pv6;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p9, 'AW9-45-MID', 'Series 9 45mm Midnight', 41900.00,
   ('["' || base_url || '/products/smart-watches/apple-watch-series-9/main.png"]')::jsonb, 5, 3) RETURNING id INTO pv7;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p9, 'AW9-45-SIL', 'Series 9 45mm Silver', 41900.00,
   ('["' || base_url || '/products/smart-watches/apple-watch-series-9/main.png"]')::jsonb, 6, 4) RETURNING id INTO pv8;

INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES
  (pv5, vo5), (pv5, vo7),  -- 41mm + Midnight
  (pv6, vo5), (pv6, vo8),  -- 41mm + Starlight
  (pv7, vo6), (pv7, vo7),  -- 45mm + Midnight
  (pv8, vo6), (pv8, vo9);  -- 45mm + Silver


-- --- SanDisk Extreme Pro: Capacity variants ---
INSERT INTO public.variant_groups (product_id, group_name, display_order)
VALUES (p15, 'Capacity', 1) RETURNING id INTO vg4;

INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg4, '128GB', 1) RETURNING id INTO vo10;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg4, '256GB', 2) RETURNING id INTO vo11;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg4, '512GB', 3) RETURNING id INTO vo12;

INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p15, 'SD-EXP-128', 'Extreme Pro 128GB', 1899.00,
   ('["' || base_url || '/products/memory-pen-drives/sandisk-extreme-pro-256gb/main.png"]')::jsonb, 30, 1) RETURNING id INTO pv9;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p15, 'SD-EXP-256', 'Extreme Pro 256GB', 3299.00,
   ('["' || base_url || '/products/memory-pen-drives/sandisk-extreme-pro-256gb/main.png"]')::jsonb, 25, 2) RETURNING id INTO pv10;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p15, 'SD-EXP-512', 'Extreme Pro 512GB', 5999.00,
   ('["' || base_url || '/products/memory-pen-drives/sandisk-extreme-pro-256gb/main.png"]')::jsonb, 15, 3) RETURNING id INTO pv11;

INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES
  (pv9, vo10), (pv10, vo11), (pv11, vo12);


-- --- boAt Airdopes 141: Colour variants ---
INSERT INTO public.variant_groups (product_id, group_name, display_order)
VALUES (p8, 'Colour', 1) RETURNING id INTO vg5;

INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg5, 'Bold Black', 1) RETURNING id INTO vo13;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg5, 'Cherry Blossom', 2) RETURNING id INTO vo14;
INSERT INTO public.variant_options (group_id, value, display_order) VALUES
  (vg5, 'Cyan Cider', 3) RETURNING id INTO vo15;

INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p8, 'BOAT-AD141-BLK', 'Airdopes 141 Bold Black', 899.00,
   ('["' || base_url || '/products/earphones-buds/boat-airdopes-141/main.png"]')::jsonb, 80, 1) RETURNING id INTO pv12;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p8, 'BOAT-AD141-PINK', 'Airdopes 141 Cherry Blossom', 899.00,
   ('["' || base_url || '/products/earphones-buds/boat-airdopes-141/main.png"]')::jsonb, 60, 2) RETURNING id INTO pv13;
INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
  (p8, 'BOAT-AD141-CYAN', 'Airdopes 141 Cyan Cider', 899.00,
   ('["' || base_url || '/products/earphones-buds/boat-airdopes-141/main.png"]')::jsonb, 60, 3) RETURNING id INTO pv14;

INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES
  (pv12, vo13), (pv13, vo14), (pv14, vo15);


RAISE NOTICE 'Seeded: 12 brands, 24 products, specs, features, and variants successfully.';
END $$;
