-- =========================================================================
-- Seed: Extended Data (Specs, Features, Variants for remaining products)
-- =========================================================================

DO $$
DECLARE
  base_url TEXT := 'https://ndfrbagekmgsunvtkxjh.supabase.co/storage/v1/object/public';

  -- Product IDs
  p_sam_cam UUID;
  p_boat_stone UUID;
  p_hp_bag UUID;
  p_mi_bag UUID;
  p_noise_watch UUID;
  p_hp_dock UUID;
  p_dji_om6 UUID;
  p_mi_tripod UUID;
  p_sam_sd UUID;
  p_anker_cable UUID;
  p_anker_hub UUID;
  p_magsafe UUID;
  p_sam_adapter UUID;
  p_mi_gift UUID;
  p_boat_combo UUID;
  p_norton UUID;
  p_ms365 UUID;

  -- Variant Group IDs
  vg_color_boat_stone UUID;
  vg_color_noise UUID;
  vg_cap_sam_sd UUID;
  vg_color_cable UUID;

  -- Variant Option IDs
  vo_boat_black UUID; vo_boat_blue UUID;
  vo_noise_black UUID; vo_noise_grey UUID; vo_noise_blue UUID;
  vo_sd_64 UUID; vo_sd_128 UUID; vo_sd_256 UUID;
  vo_cable_black UUID; vo_cable_white UUID;

  -- Variant IDs
  pv_boat1 UUID; pv_boat2 UUID;
  pv_noise1 UUID; pv_noise2 UUID; pv_noise3 UUID;
  pv_sd1 UUID; pv_sd2 UUID; pv_sd3 UUID;
  pv_cable1 UUID; pv_cable2 UUID;

BEGIN
  -- 1. Fetch Product IDs
  SELECT id INTO p_sam_cam FROM public.products WHERE slug = 'samsung-galaxy-cam-2';
  SELECT id INTO p_boat_stone FROM public.products WHERE slug = 'boat-stone-1500';
  SELECT id INTO p_hp_bag FROM public.products WHERE slug = 'hp-premium-backpack-156';
  SELECT id INTO p_mi_bag FROM public.products WHERE slug = 'mi-urban-backpack';
  SELECT id INTO p_noise_watch FROM public.products WHERE slug = 'noise-colorfit-pro-5';
  SELECT id INTO p_hp_dock FROM public.products WHERE slug = 'hp-usb-c-docking-station';
  SELECT id INTO p_dji_om6 FROM public.products WHERE slug = 'dji-om-6';
  SELECT id INTO p_mi_tripod FROM public.products WHERE slug = 'mi-selfie-stick-tripod';
  SELECT id INTO p_sam_sd FROM public.products WHERE slug = 'samsung-evo-plus-128gb-sdcard';
  SELECT id INTO p_anker_cable FROM public.products WHERE slug = 'anker-usb-c-to-lightning-cable';
  SELECT id INTO p_anker_hub FROM public.products WHERE slug = 'anker-7in1-usb-c-hub';
  SELECT id INTO p_magsafe FROM public.products WHERE slug = 'apple-magsafe-charger';
  SELECT id INTO p_sam_adapter FROM public.products WHERE slug = 'samsung-25w-travel-adapter';
  SELECT id INTO p_mi_gift FROM public.products WHERE slug = 'mi-3-in-1-gift-set';
  SELECT id INTO p_boat_combo FROM public.products WHERE slug = 'boat-smartwatch-earbuds-combo';
  SELECT id INTO p_norton FROM public.products WHERE slug = 'norton-360-deluxe-1yr';
  SELECT id INTO p_ms365 FROM public.products WHERE slug = 'microsoft-365-personal-1yr';

  -- =========================================================================
  -- 2. PRODUCT SPECS
  -- =========================================================================

  -- Samsung Galaxy Camera 2
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_sam_cam, 'Sensor', '16.3MP BSI CMOS', 1),
    (p_sam_cam, 'Zoom', '21x Optical Zoom', 2),
    (p_sam_cam, 'Display', '4.8" HD Super Clear Touch LCD', 3),
    (p_sam_cam, 'OS', 'Android 4.3 (Jelly Bean)', 4),
    (p_sam_cam, 'Connectivity', 'Wi-Fi, NFC, Bluetooth 4.0', 5);

  -- boAt Stone 1500
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_boat_stone, 'Output Power', '40W RMS', 1),
    (p_boat_stone, 'Battery Capacity', '4000 mAh', 2),
    (p_boat_stone, 'Playback Time', 'Up to 14 Hours', 3),
    (p_boat_stone, 'Water Resistance', 'IPX5 Splash Proof', 4),
    (p_boat_stone, 'Bluetooth Version', 'V5.0', 5);

  -- HP Premium Backpack
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_hp_bag, 'Compatibility', 'Up to 15.6 inch laptops', 1),
    (p_hp_bag, 'Material', 'Water-resistant fabric', 2),
    (p_hp_bag, 'Compartments', 'Multiple (Laptop, Tablet, Accessories)', 3),
    (p_hp_bag, 'Weight', '0.68 kg', 4);

  -- Noise ColorFit Pro 5
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_noise_watch, 'Display', '1.85" AMOLED Touch Screen', 1),
    (p_noise_watch, 'Battery Life', 'Up to 7 Days', 2),
    (p_noise_watch, 'Water Resistance', 'IP68', 3),
    (p_noise_watch, 'Health Features', 'Heart Rate, SpO2, Sleep Monitor', 4),
    (p_noise_watch, 'Sports Modes', '100+ Modes', 5);

  -- HP Docking Station
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_hp_dock, 'Ports', '2x DisplayPort, 1x RJ45, 4x USB 3.0, 1x USB-C', 1),
    (p_hp_dock, 'Power Delivery', 'Up to 60W', 2),
    (p_hp_dock, 'Resolution Support', 'Up to Dual 4K displays', 3),
    (p_hp_dock, 'Compatibility', 'Universal (Windows, macOS)', 4);

  -- DJI OM 6 Gimbal
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_dji_om6, 'Stabilization', '3-Axis Motorized', 1),
    (p_dji_om6, 'Extension Rod', 'Built-in 215mm', 2),
    (p_dji_om6, 'Battery Life', 'Approx. 6.4 Hours', 3),
    (p_dji_om6, 'Weight', '309g', 4),
    (p_dji_om6, 'App', 'DJI Mimo', 5);

  -- Anker 7-in-1 Hub
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_anker_hub, 'HDMI', '4K @ 30Hz', 1),
    (p_anker_hub, 'USB Ports', '2x USB-A 3.0 (5 Gbps)', 2),
    (p_anker_hub, 'Card Readers', 'SD and microSD card slots', 3),
    (p_anker_hub, 'Power Delivery', '100W Pass-through charging', 4);

  -- Apple MagSafe
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_magsafe, 'Max Output', '15W', 1),
    (p_magsafe, 'Connector', 'USB-C', 2),
    (p_magsafe, 'Cable Length', '1 Meter', 3),
    (p_magsafe, 'Compatibility', 'iPhone 12 and later, AirPods', 4);

  -- Samsung 25W Adapter
  INSERT INTO public.product_specs (product_id, spec_key, spec_value, display_order) VALUES
    (p_sam_adapter, 'Max Output', '25W (Super Fast Charging)', 1),
    (p_sam_adapter, 'Interface', 'USB Type-C', 2),
    (p_sam_adapter, 'Input Voltage', '100-240 V', 3),
    (p_sam_adapter, 'Weight', '50g', 4);


  -- =========================================================================
  -- 3. PRODUCT FEATURES (Highlights)
  -- =========================================================================

  -- DJI OM 6
  INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
    (p_dji_om6, 'highlight', 'ActiveTrack 6.0', 'Upgraded tracking keeps subjects centered even when moving fast.', 'Focus', 1),
    (p_dji_om6, 'highlight', 'Quick Launch', 'Automatically powers on when unfolded and magnetically attached.', 'Zap', 2);

  -- Anker 7-in-1 Hub
  INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
    (p_anker_hub, 'highlight', 'Massive Expansion', 'Get way more out of your laptop''s USB-C port with 4K HDMI, SD readers, and data ports.', 'Monitor', 1),
    (p_anker_hub, 'highlight', 'Pass-Through Charging', 'Supports up to 100W (minus 15W for operation) power delivery.', 'BatteryCharging', 2);

  -- Norton 360
  INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
    (p_norton, 'highlight', 'Real-Time Protection', 'Advanced security helps protect against existing and emerging malware threats.', 'Shield', 1),
    (p_norton, 'highlight', 'Secure VPN', 'Browse anonymously and securely with a no-log VPN.', 'Globe', 2);

  -- Microsoft 365
  INSERT INTO public.product_features (product_id, type, title, description, icon, display_order) VALUES
    (p_ms365, 'highlight', 'Premium Apps', 'Includes Word, Excel, PowerPoint, and Outlook.', 'Grid', 1),
    (p_ms365, 'highlight', '1TB Cloud Storage', 'Generous OneDrive storage to back up your photos and files.', 'Cloud', 2);


  -- =========================================================================
  -- 4. VARIANTS
  -- =========================================================================

  -- --- boAt Stone 1500: Colour ---
  INSERT INTO public.variant_groups (product_id, group_name, display_order) VALUES (p_boat_stone, 'Colour', 1) RETURNING id INTO vg_color_boat_stone;
  
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_boat_stone, 'Active Black', 1) RETURNING id INTO vo_boat_black;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_boat_stone, 'Midnight Blue', 2) RETURNING id INTO vo_boat_blue;

  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_boat_stone, 'STONE1500-BLK', 'Stone 1500 Black', 4499.00, ('["' || base_url || '/products/speakers-woofers/boat-stone-1500/main.png"]')::jsonb, 25, 1) RETURNING id INTO pv_boat1;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_boat_stone, 'STONE1500-BLU', 'Stone 1500 Blue', 4499.00, ('["' || base_url || '/products/speakers-woofers/boat-stone-1500/main.png"]')::jsonb, 25, 2) RETURNING id INTO pv_boat2;

  INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES (pv_boat1, vo_boat_black), (pv_boat2, vo_boat_blue);

  -- --- Noise ColorFit Pro 5: Colour ---
  INSERT INTO public.variant_groups (product_id, group_name, display_order) VALUES (p_noise_watch, 'Colour', 1) RETURNING id INTO vg_color_noise;

  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_noise, 'Jet Black', 1) RETURNING id INTO vo_noise_black;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_noise, 'Space Grey', 2) RETURNING id INTO vo_noise_grey;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_noise, 'Midnight Blue', 3) RETURNING id INTO vo_noise_blue;

  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_noise_watch, 'NOISE-PRO5-BLK', 'Pro 5 Jet Black', 2999.00, ('["' || base_url || '/products/smart-watches/noise-colorfit-pro-5/main.png"]')::jsonb, 20, 1) RETURNING id INTO pv_noise1;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_noise_watch, 'NOISE-PRO5-GRY', 'Pro 5 Space Grey', 2999.00, ('["' || base_url || '/products/smart-watches/noise-colorfit-pro-5/main.png"]')::jsonb, 20, 2) RETURNING id INTO pv_noise2;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_noise_watch, 'NOISE-PRO5-BLU', 'Pro 5 Midnight Blue', 2999.00, ('["' || base_url || '/products/smart-watches/noise-colorfit-pro-5/main.png"]')::jsonb, 20, 3) RETURNING id INTO pv_noise3;

  INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES (pv_noise1, vo_noise_black), (pv_noise2, vo_noise_grey), (pv_noise3, vo_noise_blue);

  -- --- Samsung EVO Plus microSD: Capacity ---
  INSERT INTO public.variant_groups (product_id, group_name, display_order) VALUES (p_sam_sd, 'Capacity', 1) RETURNING id INTO vg_cap_sam_sd;

  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_cap_sam_sd, '64GB', 1) RETURNING id INTO vo_sd_64;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_cap_sam_sd, '128GB', 2) RETURNING id INTO vo_sd_128;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_cap_sam_sd, '256GB', 3) RETURNING id INTO vo_sd_256;

  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_sam_sd, 'SAM-SD-64', 'EVO Plus 64GB', 599.00, ('["' || base_url || '/products/memory-pen-drives/samsung-evo-plus-128gb-sdcard/main.png"]')::jsonb, 50, 1) RETURNING id INTO pv_sd1;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_sam_sd, 'SAM-SD-128', 'EVO Plus 128GB', 1099.00, ('["' || base_url || '/products/memory-pen-drives/samsung-evo-plus-128gb-sdcard/main.png"]')::jsonb, 50, 2) RETURNING id INTO pv_sd2;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_sam_sd, 'SAM-SD-256', 'EVO Plus 256GB', 2199.00, ('["' || base_url || '/products/memory-pen-drives/samsung-evo-plus-128gb-sdcard/main.png"]')::jsonb, 50, 3) RETURNING id INTO pv_sd3;

  INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES (pv_sd1, vo_sd_64), (pv_sd2, vo_sd_128), (pv_sd3, vo_sd_256);

  -- --- Anker Lightning Cable: Colour ---
  INSERT INTO public.variant_groups (product_id, group_name, display_order) VALUES (p_anker_cable, 'Colour', 1) RETURNING id INTO vg_color_cable;

  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_cable, 'Black', 1) RETURNING id INTO vo_cable_black;
  INSERT INTO public.variant_options (group_id, value, display_order) VALUES (vg_color_cable, 'White', 2) RETURNING id INTO vo_cable_white;

  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_anker_cable, 'ANK-CBL-BLK', 'Cable Black', 1299.00, ('["' || base_url || '/products/cables-connectors/anker-usb-c-to-lightning-cable/main.png"]')::jsonb, 60, 1) RETURNING id INTO pv_cable1;
  INSERT INTO public.product_variants (product_id, sku, variant_name, price, images, stock_quantity, display_order) VALUES
    (p_anker_cable, 'ANK-CBL-WHT', 'Cable White', 1299.00, ('["' || base_url || '/products/cables-connectors/anker-usb-c-to-lightning-cable/main.png"]')::jsonb, 60, 2) RETURNING id INTO pv_cable2;

  INSERT INTO public.variant_combination_options (variant_id, option_id) VALUES (pv_cable1, vo_cable_black), (pv_cable2, vo_cable_white);


  RAISE NOTICE 'Seeded extended data (specs, features, variants) for remaining products successfully.';
END $$;
