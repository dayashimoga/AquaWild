-- AquaWild (HydroFauna) Monetization, Entitlements, Remote Config & Admin Audit Schema
-- Migration ID: 20261122000001_create_monetization_admin_schema.sql

-- ============================================================================
-- 1. USER SUBSCRIPTIONS TABLE (AquaWild Pro Monthly, Annual, Lifetime)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    tier TEXT NOT NULL CHECK (tier IN ('free', 'pro_monthly', 'pro_annual', 'pro_lifetime')),
    status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'grace_period', 'cancelled')),
    store TEXT NOT NULL CHECK (store IN ('apple_app_store', 'google_play', 'stripe', 'sandbox')),
    original_transaction_id TEXT,
    latest_receipt_hash TEXT,
    started_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    expires_at TIMESTAMPTZ,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_user_subscription UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_subscriptions_lookup 
    ON public.user_subscriptions (user_id, status);

-- ============================================================================
-- 2. USER ENTITLEMENTS TABLE (One-time IAP unlocks, packs & passes)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_entitlements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sku TEXT NOT NULL,
    kind TEXT NOT NULL CHECK (kind IN ('animal_pack', 'theme_pack', 'animation_pack', 'seasonal_pass')),
    source TEXT NOT NULL CHECK (source IN ('iap', 'admin_override', 'promo_code', 'reward')),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_user_sku_entitlement UNIQUE (user_id, sku)
);

CREATE INDEX IF NOT EXISTS idx_user_entitlements_lookup 
    ON public.user_entitlements (user_id, sku);

-- ============================================================================
-- 3. REMOTE CONFIG FLAGS TABLE (Runtime feature flags & dynamic config)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.remote_config_flags (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL DEFAULT '{}'::jsonb,
    description TEXT,
    environment TEXT NOT NULL DEFAULT 'all' CHECK (environment IN ('all', 'dev', 'staging', 'prod')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Seed default remote config flags
INSERT INTO public.remote_config_flags (key, value, description, environment, is_active)
VALUES
    ('enable_high_precision_waves', '{"enabled": true, "sub_steps": 8}'::jsonb, 'Controls 64-column wave solver sub-stepping precision', 'all', true),
    ('ai_coach_v2_prompt', '{"model": "gpt-4o-mini", "temperature": 0.7}'::jsonb, 'Default OpenAI-compatible model hyperparameters', 'all', true),
    ('monetization_store_live', '{"allow_purchases": true, "sandbox_mode": false}'::jsonb, 'Monetization storefront purchase switch', 'all', true),
    ('out_of_app_telemetry_interval_mins', '{"interval": 15}'::jsonb, 'Widget and notification background refresh interval', 'all', true)
ON CONFLICT (key) DO NOTHING;

-- ============================================================================
-- 4. ADMIN AUDIT LOGS TABLE (Immutable append-only administrative ledger)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID REFERENCES auth.users(id),
    actor_email TEXT NOT NULL,
    action TEXT NOT NULL,
    target_resource TEXT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    environment TEXT NOT NULL DEFAULT 'prod',
    ip_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_actor_time 
    ON public.admin_audit_logs (actor_email, created_at DESC);

-- ============================================================================
-- 5. ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.remote_config_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

-- Subscriptions RLS: Users can query their own subscription
CREATE POLICY "Users can query own subscription"
    ON public.user_subscriptions
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage all subscriptions"
    ON public.user_subscriptions
    FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- Entitlements RLS: Users can query their own entitlements
CREATE POLICY "Users can query own entitlements"
    ON public.user_entitlements
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage all entitlements"
    ON public.user_entitlements
    FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- Remote Config RLS: Anyone authenticated or anonymous can read active flags
CREATE POLICY "Public read access to active remote config flags"
    ON public.remote_config_flags
    FOR SELECT
    USING (is_active = true);

CREATE POLICY "Admins can manage remote config flags"
    ON public.remote_config_flags
    FOR ALL
    USING (
        auth.jwt() ->> 'role' = 'service_role' OR
        (auth.jwt() ->> 'is_admin')::boolean = true
    );

-- Admin Audit Logs RLS: Strict admin-only access
CREATE POLICY "Only admins and service role can inspect audit logs"
    ON public.admin_audit_logs
    FOR SELECT
    USING (
        auth.jwt() ->> 'role' = 'service_role' OR
        (auth.jwt() ->> 'is_admin')::boolean = true
    );

CREATE POLICY "Admins can append audit log records"
    ON public.admin_audit_logs
    FOR INSERT
    WITH CHECK (
        auth.jwt() ->> 'role' = 'service_role' OR
        (auth.jwt() ->> 'is_admin')::boolean = true
    );
