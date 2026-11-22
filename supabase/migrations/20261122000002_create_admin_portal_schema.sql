-- AquaWild (HydroFauna) Admin Portal, RBAC Roles, Content Catalogs, Broadcasts & Chained Audit Logs Schema
-- Migration ID: 20261122000002_create_admin_portal_schema.sql

-- ============================================================================
-- 1. ADMIN USER ROLES & PERMISSIONS TABLE (RBAC)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_user_roles (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'standard' CHECK (role IN ('standard', 'pro', 'moderator', 'admin', 'super_admin')),
    account_status TEXT NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'pending_verification')),
    freeze_tokens INTEGER NOT NULL DEFAULT 2 CHECK (freeze_tokens >= 0),
    custom_xp INTEGER NOT NULL DEFAULT 0 CHECK (custom_xp >= 0),
    updated_by TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_user_roles_lookup 
    ON public.admin_user_roles (role, account_status);

-- ============================================================================
-- 2. ADMIN CATALOG BEVERAGES TABLE (Runtime beverage overrides & custom entries)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_catalog_beverages (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    hydration_index NUMERIC(4, 2) NOT NULL DEFAULT 1.0 CHECK (hydration_index >= 0),
    caffeine_mg NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (caffeine_mg >= 0),
    electrolytes_mg NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (electrolytes_mg >= 0),
    sugar_grams NUMERIC(6, 2) NOT NULL DEFAULT 0 CHECK (sugar_grams >= 0),
    density NUMERIC(4, 3) NOT NULL DEFAULT 1.0 CHECK (density > 0),
    viscosity NUMERIC(4, 3) NOT NULL DEFAULT 1.0 CHECK (viscosity > 0),
    color_hex TEXT NOT NULL DEFAULT '#00B4D8',
    is_custom BOOLEAN NOT NULL DEFAULT FALSE,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_catalog_beverages_enabled 
    ON public.admin_catalog_beverages (is_enabled, category);

-- ============================================================================
-- 3. ADMIN CATALOG ANIMALS TABLE (Runtime companion parameters & unlock tiers)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_catalog_animals (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    unlock_xp INTEGER NOT NULL DEFAULT 0 CHECK (unlock_xp >= 0),
    biome_id TEXT NOT NULL,
    tier TEXT NOT NULL DEFAULT 'Starter',
    is_premium_only BOOLEAN NOT NULL DEFAULT FALSE,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_catalog_animals_enabled 
    ON public.admin_catalog_animals (is_enabled, biome_id);

-- ============================================================================
-- 4. ADMIN BROADCAST MESSAGES TABLE (Campaigns, push announcements & targeting)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_broadcast_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('announcement', 'challenge', 'community', 'urgent', 'promotion')),
    target_audience TEXT NOT NULL CHECK (target_audience IN ('all_users', 'free_users_only', 'pro_users_only', 'dormant_users', 'high_streak_users')),
    action_route TEXT NOT NULL DEFAULT '/home',
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    is_sent BOOLEAN NOT NULL DEFAULT FALSE,
    total_recipients INTEGER NOT NULL DEFAULT 0 CHECK (total_recipients >= 0),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_broadcast_messages_status 
    ON public.admin_broadcast_messages (is_sent, scheduled_at);

-- ============================================================================
-- 5. ADMIN AUDIT ENTRIES TABLE (Append-only tamper-evident SHA-256 hash chain)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.admin_audit_entries (
    id TEXT PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    operator_id TEXT NOT NULL,
    operator_email TEXT NOT NULL,
    action_type TEXT NOT NULL,
    target_entity_id TEXT NOT NULL,
    description TEXT NOT NULL,
    previous_value TEXT,
    new_value TEXT,
    client_ip TEXT NOT NULL DEFAULT '127.0.0.1 (Local Session)',
    platform_info TEXT NOT NULL DEFAULT 'AquaWild Admin Desktop/Web',
    previous_entry_hash TEXT NOT NULL,
    entry_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_entries_time 
    ON public.admin_audit_entries (timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_admin_audit_entries_operator 
    ON public.admin_audit_entries (operator_email, action_type);

-- ============================================================================
-- 6. SECURITY HELPER FUNCTION FOR RBAC
-- ============================================================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        auth.jwt() ->> 'role' = 'service_role' OR
        EXISTS (
            SELECT 1 FROM public.admin_user_roles
            WHERE user_id = auth.uid() AND role IN ('admin', 'super_admin')
        ) OR
        (auth.jwt() ->> 'is_admin')::boolean = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_moderator()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.admin_user_roles
            WHERE user_id = auth.uid() AND role IN ('moderator', 'admin', 'super_admin')
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7. ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.admin_user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_catalog_beverages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_catalog_animals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_broadcast_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_entries ENABLE ROW LEVEL SECURITY;

-- 7.1 Admin User Roles Policies
CREATE POLICY "Users can view own role"
    ON public.admin_user_roles
    FOR SELECT
    USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Admins can manage user roles"
    ON public.admin_user_roles
    FOR ALL
    USING (public.is_admin());

-- 7.2 Beverage Catalog Policies
CREATE POLICY "Public read active beverages"
    ON public.admin_catalog_beverages
    FOR SELECT
    USING (is_enabled = TRUE OR public.is_moderator());

CREATE POLICY "Moderators and admins can manage beverages"
    ON public.admin_catalog_beverages
    FOR ALL
    USING (public.is_moderator());

-- 7.3 Animal Catalog Policies
CREATE POLICY "Public read active animals"
    ON public.admin_catalog_animals
    FOR SELECT
    USING (is_enabled = TRUE OR public.is_moderator());

CREATE POLICY "Moderators and admins can manage animals"
    ON public.admin_catalog_animals
    FOR ALL
    USING (public.is_moderator());

-- 7.4 Broadcast Messages Policies
CREATE POLICY "Admins can view and manage all broadcasts"
    ON public.admin_broadcast_messages
    FOR ALL
    USING (public.is_admin());

CREATE POLICY "Users can view delivered broadcasts intended for them"
    ON public.admin_broadcast_messages
    FOR SELECT
    USING (
        is_sent = TRUE AND (
            target_audience = 'all_users' OR
            (target_audience = 'pro_users_only' AND EXISTS (
                SELECT 1 FROM public.user_subscriptions
                WHERE user_id = auth.uid() AND status = 'active' AND tier != 'free'
            )) OR
            (target_audience = 'free_users_only' AND NOT EXISTS (
                SELECT 1 FROM public.user_subscriptions
                WHERE user_id = auth.uid() AND status = 'active' AND tier != 'free'
            ))
        )
    );

-- 7.5 Chained Audit Entries Policies
-- Immutable append-only: strictly NO updates or deletes allowed under any circumstances!
CREATE POLICY "Admins can view immutable audit log entries"
    ON public.admin_audit_entries
    FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins and service role can append audit entries"
    ON public.admin_audit_entries
    FOR INSERT
    WITH CHECK (public.is_admin());
