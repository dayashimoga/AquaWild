-- AquaWild (HydroFauna) PostgreSQL Schema & Row-Level Security Migration
-- Migration ID: 20261122000000_create_aquawild_schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. PROFILES TABLE (User metadata, active companion, biome, and daily target)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    daily_base_goal_ml INTEGER NOT NULL DEFAULT 2500 CHECK (daily_base_goal_ml BETWEEN 1000 AND 8000),
    preferred_unit TEXT NOT NULL DEFAULT 'ml' CHECK (preferred_unit IN ('ml', 'oz')),
    active_companion_id TEXT NOT NULL DEFAULT 'red_panda',
    active_biome_id TEXT NOT NULL DEFAULT 'bamboo_misty_springs',
    total_xp INTEGER NOT NULL DEFAULT 0 CHECK (total_xp >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ============================================================================
-- 2. HYDRATION ENTRIES TABLE (Granular beverage logs with bioavailability)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.hydration_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    beverage_id TEXT NOT NULL,
    volume_ml NUMERIC(8, 2) NOT NULL CHECK (volume_ml > 0),
    net_hydration_ml NUMERIC(8, 2) NOT NULL CHECK (net_hydration_ml >= 0),
    caffeine_mg NUMERIC(8, 2) NOT NULL DEFAULT 0,
    electrolytes_mg NUMERIC(8, 2) NOT NULL DEFAULT 0,
    logged_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    notes TEXT,
    is_synced BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Indexes for lightning-fast chronological and range queries
CREATE INDEX IF NOT EXISTS idx_hydration_entries_user_date 
    ON public.hydration_entries (user_id, logged_at DESC);

-- ============================================================================
-- 3. USER STREAKS TABLE (Habit streaks, records, and streak freezes)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_streaks (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    current_streak_days INTEGER NOT NULL DEFAULT 0 CHECK (current_streak_days >= 0),
    longest_streak_days INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak_days >= 0),
    streak_freezes_available INTEGER NOT NULL DEFAULT 2 CHECK (streak_freezes_available >= 0),
    last_completed_date DATE,
    last_freeze_used_date DATE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- ============================================================================
-- 4. USER ACHIEVEMENTS TABLE (Tiered unlocked badges and quest milestones)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    badge_id TEXT NOT NULL,
    progress_fraction NUMERIC(4, 3) NOT NULL DEFAULT 0.0 CHECK (progress_fraction BETWEEN 0.0 AND 1.0),
    is_unlocked BOOLEAN NOT NULL DEFAULT FALSE,
    unlocked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    CONSTRAINT uq_user_badge UNIQUE (user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user_badge 
    ON public.user_achievements (user_id, badge_id);

-- ============================================================================
-- 5. ACTIVITY SESSIONS TABLE (Logged workouts, sweat loss, and energy metrics)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.activity_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    intensity TEXT NOT NULL CHECK (intensity IN ('light', 'moderate', 'high', 'extreme')),
    calories_burned INTEGER NOT NULL DEFAULT 0,
    estimated_sweat_loss_ml INTEGER NOT NULL DEFAULT 0,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX IF NOT EXISTS idx_activity_sessions_user_date 
    ON public.activity_sessions (user_id, performed_at DESC);

-- ============================================================================
-- 6. STRICT ROW-LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- Enable RLS on every table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hydration_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_sessions ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view own profile" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
    ON public.profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Hydration Entries Policies
CREATE POLICY "Users can view own hydration entries" 
    ON public.hydration_entries FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own hydration entries" 
    ON public.hydration_entries FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own hydration entries" 
    ON public.hydration_entries FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own hydration entries" 
    ON public.hydration_entries FOR DELETE 
    USING (auth.uid() = user_id);

-- User Streaks Policies
CREATE POLICY "Users can view own streak" 
    ON public.user_streaks FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own streak" 
    ON public.user_streaks FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streak" 
    ON public.user_streaks FOR UPDATE 
    USING (auth.uid() = user_id);

-- User Achievements Policies
CREATE POLICY "Users can view own achievements" 
    ON public.user_achievements FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" 
    ON public.user_achievements FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements" 
    ON public.user_achievements FOR UPDATE 
    USING (auth.uid() = user_id);

-- Activity Sessions Policies
CREATE POLICY "Users can view own activities" 
    ON public.activity_sessions FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities" 
    ON public.activity_sessions FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own activities" 
    ON public.activity_sessions FOR UPDATE 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own activities" 
    ON public.activity_sessions FOR DELETE 
    USING (auth.uid() = user_id);

-- ============================================================================
-- 7. DATABASE TRIGGERS & AUTOMATION
-- ============================================================================

-- Generic update timestamp trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_user_streaks_updated_at
    BEFORE UPDATE ON public.user_streaks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Automatic user provisioning upon auth sign-up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Provision Profile
    INSERT INTO public.profiles (id, display_name, daily_base_goal_ml, active_companion_id, active_biome_id)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Hydro Traveler'),
        2500,
        'red_panda',
        'bamboo_misty_springs'
    );

    -- Provision Initial Streak Record
    INSERT INTO public.user_streaks (user_id, current_streak_days, longest_streak_days, streak_freezes_available)
    VALUES (NEW.id, 0, 0, 2);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
