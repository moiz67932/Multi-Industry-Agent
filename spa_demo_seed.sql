-- ============================================================================
-- spa_demo_seed.sql
-- Seed data for Aura Med Spa demo client
--
-- Run this in your EXISTING Supabase project (same project as dental).
-- Do NOT create a new project.
-- ============================================================================

-- 1. Create organization for the spa
INSERT INTO organizations (id, name, created_at)
VALUES (
    gen_random_uuid(),
    'Aura Med Spa Inc',
    now()
);

-- Store the org ID for subsequent inserts
DO $$
DECLARE
    v_org_id uuid;
    v_clinic_id uuid;
    v_agent_id uuid;
    v_agent_settings_id uuid;
BEGIN

-- Get the org we just created
SELECT id INTO v_org_id FROM organizations WHERE name = 'Aura Med Spa Inc' LIMIT 1;

-- 2. Create clinic
INSERT INTO clinics (id, organization_id, name, address, city, state, zip_code, country, timezone, default_phone_region, phone, created_at)
VALUES (
    gen_random_uuid(),
    v_org_id,
    'Aura Med Spa',
    '456 Blossom Ave',
    'Los Angeles',
    'CA',
    '90210',
    'US',
    'America/Los_Angeles',
    'US',
    '+13104567890',
    now()
)
RETURNING id INTO v_clinic_id;

RAISE NOTICE 'Created clinic_id: %', v_clinic_id;

-- 3. Create agent
INSERT INTO agents (id, organization_id, clinic_id, name, default_language, status, created_at)
VALUES (
    gen_random_uuid(),
    v_org_id,
    v_clinic_id,
    'Ava',
    'en-US',
    'active',
    now()
)
RETURNING id INTO v_agent_id;

RAISE NOTICE 'Created agent_id: %', v_agent_id;

-- 4. Create agent_settings
INSERT INTO agent_settings (id, agent_id, greeting_text, persona_tone, collect_insurance, emergency_triage_enabled, booking_confirmation_enabled, config_json, created_at)
VALUES (
    gen_random_uuid(),
    v_agent_id,
    'Hi, thank you for calling Aura Med Spa! This is Ava speaking. How can I help you today?',
    'warm',
    false,
    false,
    true,
    '{
      "industry_type": "med_spa",
      "working_hours": {
        "mon": [{"start": "09:00", "end": "20:00"}],
        "tue": [{"start": "09:00", "end": "20:00"}],
        "wed": [{"start": "09:00", "end": "20:00"}],
        "thu": [{"start": "09:00", "end": "20:00"}],
        "fri": [{"start": "09:00", "end": "20:00"}],
        "sat": [{"start": "09:00", "end": "18:00"}],
        "sun": [{"start": "10:00", "end": "16:00"}]
      },
      "slot_step_minutes": 30,
      "arrival_buffer_minutes": 15,
      "late_cancel_hours": 24,
      "late_cancel_fee": true,
      "gratuity_percentage": 20,
      "treatment_durations": {
        "Consultation": 30,
        "Botox": 30,
        "Dermal Filler": 45,
        "Lip Filler": 30,
        "HydraFacial": 60,
        "Chemical Peel": 45,
        "Microneedling": 60,
        "Laser Hair Removal": 45,
        "IPL Photofacial": 60,
        "Facial": 60,
        "Swedish Massage": 60,
        "Deep Tissue Massage": 60,
        "Couples Massage": 60,
        "Brazilian Wax": 30,
        "Brow Lamination": 60,
        "Lash Lift": 60,
        "Lash Extensions": 120,
        "Microblading": 120,
        "Dermaplaning": 45,
        "Patch Test": 15,
        "LED Light Therapy": 30,
        "Body Wrap": 75,
        "Hot Stone Massage": 90
      },
      "patch_test_required_services": [
        "Laser Hair Removal", "IPL Photofacial", "Lash Tint", "Brow Tint", "Microblading"
      ],
      "consultation_required_services": [
        "Botox", "Dermal Filler", "Lip Filler", "Sculptra", "Kybella", "PRP Treatment",
        "Laser Resurfacing", "CO2 Laser"
      ],
      "injectable_services": [
        "Botox", "Dysport", "Dermal Filler", "Lip Filler", "Lip Flip",
        "Kybella", "Sculptra", "PRP Treatment"
      ]
    }'::jsonb,
    now()
)
RETURNING id INTO v_agent_settings_id;

RAISE NOTICE 'Created agent_settings_id: %', v_agent_settings_id;

-- 5. Create phone_numbers entry
INSERT INTO phone_numbers (id, clinic_id, agent_id, phone_e164, label, created_at)
VALUES (
    gen_random_uuid(),
    v_clinic_id,
    v_agent_id,
    '+13104567890',
    'Main Spa Line',
    now()
);

RAISE NOTICE 'Phone number linked to clinic and agent';

-- 6. Insert 20 knowledge articles for the spa

-- Article 1: Services Overview
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Spa Services Overview', 'Services',
    'Aura Med Spa offers a full range of aesthetic and wellness treatments including Botox and dermal fillers, laser treatments (IPL photofacial, laser hair removal), advanced facials (HydraFacial, chemical peels, microneedling, dermaplaning), massage therapy, waxing, brow and lash services (microblading, lash extensions, lash lift), and nail care. We serve clients looking for both relaxation and medical-grade aesthetic results.',
    now());

-- Article 2: Botox Pricing
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Botox & Neurotoxin Pricing', 'Pricing',
    'Botox is priced per unit. Forehead lines: 10-30 units ($12-14/unit). Frown lines (11s): 20-25 units. Crow''s feet: 10-15 units per side. Brow lift: 4-8 units. Bunny lines: 5-10 units. Lip flip: 4-8 units. Dysport and Xeomin are available as alternatives. A complimentary consultation is required for first-time injectable clients.',
    now());

-- Article 3: Filler Pricing
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Dermal Filler Pricing', 'Pricing',
    'Dermal fillers start at $650 per syringe. Lip filler: $650-750 for 0.5ml-1ml. Cheek filler: $750-900 per syringe. Nasolabial folds: $650-750. Jawline definition: $750-850. Tear trough filler: $800-950. Sculptra is priced per vial at $800. Kybella (double chin): $600 per vial, most clients need 2-4 vials.',
    now());

-- Article 4: HydraFacial
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'HydraFacial Treatment', 'Services',
    'Our HydraFacial is a 60-minute multi-step treatment that cleanses, exfoliates, extracts, and hydrates the skin simultaneously. It uses a patented vortex technology to remove dead skin cells and extract impurities while simultaneously bathing skin with cleansing, hydrating and moisturizing serums. No downtime. Suitable for all skin types including sensitive skin. Results are immediately visible. Price: $175 for classic, $225 for deluxe with boosters.',
    now());

-- Article 5: Laser Hair Removal
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Laser Hair Removal', 'Services',
    'Laser hair removal uses concentrated light to destroy hair follicles. Most clients need 6-8 sessions spaced 4-6 weeks apart. A patch test is required 48 hours before the first session. Avoid sun exposure and tanning for 2 weeks before and after. Do not wax, tweeze, or use depilatory creams for 4 weeks before (shaving is okay). Pricing: upper lip $75, underarms $125, bikini $150, Brazilian $175, full legs $350, full arms $250, back $350.',
    now());

-- Article 6: Chemical Peels
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Chemical Peels', 'Services',
    'We offer light, medium, and deep chemical peels. Light peels (glycolic, lactic): $100-150, minimal downtime, great for brightening. Medium peels (TCA): $250-350, 5-7 days downtime, treats sun damage and fine lines. Deep peels: consultation required. Pre-care: stop retinol/tretinoin 1 week before, avoid sun 2 weeks prior. Post-care: gentle cleanser only, SPF every day, no picking. Results last 1-6 months depending on peel depth.',
    now());

-- Article 7: Microneedling
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Microneedling Treatment', 'Services',
    'Microneedling creates controlled micro-injuries to stimulate collagen production. Treats fine lines, acne scars, enlarged pores, and uneven texture. 60-minute treatment, $350 per session. Series of 3: $900 ($300/session). Series of 6: $1,800 ($300/session). PRP add-on available for $150 (combined vampire facial). Expect 24-48 hours of redness and sensitivity. Avoid sun, heat, and active skincare for 48 hours after.',
    now());

-- Article 8: Massage Services
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Massage Therapy', 'Services',
    'We offer Swedish massage (relaxation, 60 min $95, 90 min $135), deep tissue (therapeutic, 60 min $110, 90 min $150), hot stone massage (90 min $165), and prenatal massage for expecting mothers (60 min $100). Couples massage is available in our double suite — two therapists work simultaneously on you and your partner (60 min $200/couple, 90 min $280/couple). Add-ons available: aromatherapy $15, CBD oil $20, hot stone add-on to any massage $25.',
    now());

-- Article 9: Memberships
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Spa Memberships & Packages', 'Memberships',
    'Our Glow Membership is $149/month and includes one 60-minute HydraFacial or facial per month, 10% off all additional services and retail, and complimentary aromatherapy add-on. Our Radiance Membership is $249/month and includes one facial + one massage per month, 15% off all additional services, and priority booking. Single service packages (series) are available for laser hair removal (6-pack saves 15%) and microneedling (3-pack or 6-pack). Gift cards available in any amount.',
    now());

-- Article 10: Lash Extensions
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Lash Extensions', 'Services',
    'We offer classic lashes (one extension per natural lash, $175, 2 hours), hybrid lashes (mix of classic and volume, $200, 2 hours), and volume lashes (multiple extensions per natural lash, $225, 2.5 hours). Fills are required every 2-3 weeks: classic fill $75 (1 hour), volume fill $95 (75 min). First-time clients require a patch test 24 hours before the appointment. Remove contacts before your appointment. Do not use oil-based products around eyes for 48 hours after.',
    now());

-- Article 11: Microblading
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Microblading & Brow Services', 'Services',
    'Microblading creates natural-looking hair strokes for fuller brows. Price: $450 for the initial session including a touch-up at 6-8 weeks. Results last 1-3 years. A patch test is required 48 hours before. Avoid sun, sweating, and water on the area for 10 days after. Avoid Botox around the brow area 2 weeks before. Brow lamination ($85, 60 min) lifts and sets brow hairs for a fuller appearance, lasts 6-8 weeks. Brow tint ($35, 30 min) adds color to brows. Brow shaping/waxing ($25, 30 min).',
    now());

-- Article 12: Waxing Services
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Waxing Services', 'Services',
    'We use hard wax for sensitive areas. Services: brows $25, upper lip $15, chin $15, full face $55, underarms $30, half arms $40, full arms $55, bikini $45, Brazilian $65, half legs $60, full legs $100. Hair must be at least 1/4 inch (about 2-3 weeks of growth). Avoid retinol/tretinoin on the area for 1 week before. Cannot wax if taking Accutane. Avoid sun 24 hours after. No exercise or hot baths for 24 hours after.',
    now());

-- Article 13: Hours and Location
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Hours & Location', 'Hours',
    'Aura Med Spa is located at 456 Blossom Ave, Los Angeles, CA 90210. We are open Monday through Friday 9am to 8pm, Saturday 9am to 6pm, and Sunday 10am to 4pm. Street parking is available on Blossom Ave and in the parking structure on Main St (validated for spa clients). We are located next to the Canyon Coffee shop. You can also find us on the third floor of the Blossom Building — take the elevator and we are Suite 305.',
    now());

-- Article 14: Cancellation Policy
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Cancellation & No-Show Policy', 'Policy',
    'We require 24 hours notice to cancel or reschedule your appointment. Appointments cancelled with less than 24 hours notice will be charged 50% of the service fee. No-shows will be charged 100% of the service fee. A credit card is required to hold appointments for all injectable services and treatments over $200. We understand emergencies happen — please call us as soon as possible and we will do our best to accommodate you.',
    now());

-- Article 15: Arrival & Check-In
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Arrival & What to Expect', 'Policy',
    'Please arrive 15-20 minutes before your appointment to complete intake forms, change into a robe if needed, and enjoy a complimentary beverage before your service. Late arrivals may result in a shortened service time. We ask that you silence your phone during treatments. Our waiting area has complimentary tea, water, and light refreshments. For injectable services, arrive with a clean face — no makeup. For laser treatments, avoid perfume or lotion on the treatment area.',
    now());

-- Article 16: Gratuity Policy
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Gratuity & Payment', 'Payment',
    'Gratuity is always appreciated but never required. Industry standard is 18-20% for spa services. We accept all major credit cards, cash, Apple Pay, Google Pay, and Zelle. Gift cards can be purchased in any amount at the spa or through our website. Packages and memberships can be purchased during your visit. We do not accept checks.',
    now());

-- Article 17: Before & After Injectables
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Botox & Filler Pre and Post Care', 'Pre/Post Care',
    'Before Botox or fillers: avoid blood thinners (aspirin, ibuprofen, fish oil, vitamin E) for 1 week. Avoid alcohol 24 hours before. Avoid vigorous exercise day of. Arrive with a clean face. After Botox: do not rub or massage the area for 4 hours, avoid lying down for 4 hours, avoid intense exercise for 24 hours. Results appear in 3-14 days. After fillers: some bruising, swelling, and tenderness is normal for 3-5 days. Avoid heat, sun, and exercise for 24 hours. Sleep elevated the first night.',
    now());

-- Article 18: Facial Pre/Post Care
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'Facial Treatment Pre and Post Care', 'Pre/Post Care',
    'Before your facial: avoid exfoliating or using retinol/AHA/BHA for 24 hours. Arrive with clean skin if possible, though we will cleanse. After your facial: your skin may be sensitive for 24-48 hours. Use gentle cleanser and moisturizer only. Apply SPF 30+ daily. Avoid direct sun, sauna, steam, or exercise for 24 hours. Do not use retinol, vitamin C, or active ingredients for 48 hours after a chemical peel or microdermabrasion. Your esthetician will give you a personalized post-care guide.',
    now());

-- Article 19: First Visit / New Client Info
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'New Client Information', 'New Clients',
    'Welcome to Aura Med Spa! For your first visit, please arrive 15-20 minutes early to complete your intake form. For injectable services, a complimentary consultation is required before your first treatment — this is a 30-minute appointment where our injector will assess your goals and create a personalized treatment plan. For laser or chemical peel first-timers, a patch test may be required 48 hours before. If you have any medical conditions, allergies, or are taking medications, please disclose these on your intake form.',
    now());

-- Article 20: Results & Expectations
INSERT INTO knowledge_articles (id, clinic_id, title, category, body, created_at)
VALUES (gen_random_uuid(), v_clinic_id,
    'What Results Can I Expect?', 'Services',
    'Results vary by treatment: Botox takes effect in 3-14 days and lasts 3-4 months. Dermal fillers provide immediate results lasting 6-18 months depending on the product and area. HydraFacial results are immediately visible with continued improvement over days. Laser hair removal requires 6-8 sessions for 80-90% permanent reduction. Chemical peels show results after peeling (3-7 days post-treatment) and improve over weeks. Microneedling requires 3+ sessions for optimal collagen remodeling, with results building over 3-6 months. Your esthetician will set realistic expectations at your consultation.',
    now());

RAISE NOTICE '========================================';
RAISE NOTICE 'Aura Med Spa seed data created!';
RAISE NOTICE 'organization_id: %', v_org_id;
RAISE NOTICE 'clinic_id:       %', v_clinic_id;
RAISE NOTICE 'agent_id:        %', v_agent_id;
RAISE NOTICE 'agent_settings_id: %', v_agent_settings_id;
RAISE NOTICE '========================================';

END $$;
