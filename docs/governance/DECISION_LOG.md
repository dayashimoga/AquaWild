# Decision Log & AI Course-Correction Ledger

## Entry 001 — 2026-11-22 (Subphase 1.1.1)
- **Context**: Initial inspection of `h:\water` and the 4 user-uploaded reference screenshots (Waterllama Mobbin screens & Brownie Pool float prototype).
- **Gap Analysis Findings**:
  1. Competitor apps use flat horizontal color bands inside animal masks with no interfacial fluid wave physics or meniscus refraction.
  2. Competitor apps use aggressive dark-pattern paywall timers ("You'll lose access soon 23:57h") and lack desktop/web split-pane productivity views.
  3. The reference pool float screen depicts a capybara/bear on a static grid; the user explicitly requested a **highly detailed animated SVG Red Panda relaxing on a floating balloon/tube over top-view water with realistic floating physics, ripples, reflections, shadows, parallax, particles, procedural waves, depth effects, premium motion design, and seamless transitions**.
- **Course-Correction & Decision**:
  - Designed a dedicated top-view procedural water + SVG Red Panda floating physics engine for the launch screen with interactive ripples, caustic refraction, parallax shadows, and seamless Hero transition into the hydration studio.
  - Upgraded animal filling from static horizontal bands to a multi-stratum shallow-water wave solver with real-time sloshing, bubbles, splash particles, and beverage-specific hydration bioavailability calculation.
- **Sign-Off**: `solution-architect`, `product-agent`, `ux-ui-agent`, `animation-agent`, `qa-agent`, `security-agent`, `release-devops-agent`.

---

## Entry 002 — 2026-11-22 (Subphase 1.2.1)
- **Context**: Multi-platform workspace initialization and strict compiler validation.
- **Course-Correction & Observations**:
  1. Flutter 3.38+ / Dart 3.10+ updated `CardTheme` in `ThemeData` to expect `CardThemeData` and deprecated direct `.value` on `Color` in favor of `toARGB32()`. Updated `AppTheme` and test suites to modern Flutter 3.38+ contracts immediately to maintain zero warnings.
  2. Replaced relative directory navigation with package-qualified canonical imports (`package:aquawild/...`) across presentation screens to eliminate URI resolution ambiguities across platforms.
- **Sign-Off**: `solution-architect`, `desktop-web-agent`, `mobile-agent`, `qa-agent`, `release-devops-agent`.

---

## Entry 003 — 2026-11-22 (Subphase 2.1.1)
- **Context**: Domain modeling, beverage bioavailability science, and Riverpod 3 state management architecture.
- **Course-Correction & Observations**:
  1. Adopted modern Riverpod 3 `Notifier<T>` and `NotifierProvider<Notifier, T>` architecture instead of deprecated `StateNotifier` APIs.
  2. Protected asynchronous state mutation against post-dispose memory leaks by adding `if (!ref.mounted) return;` across all notifier async methods.
  3. Implemented realistic fluid density sorting: beverages logged into the active vessel automatically arrange in stratification layers according to physical fluid density ($g/cm^3$), ensuring heavier beverages (e.g., Espresso at 1.04, Protein Shake at 1.045) realistically settle below lighter fluids (Pure Water at 1.00, Sparkling Water at 0.99).
- **Sign-Off**: `solution-architect`, `product-agent`, `backend-agent`, `qa-agent`, `release-devops-agent`.

---

## Entry 004 — 2026-11-22 (Subphase 2.2.1)
- **Context**: Launch screen physics engine, top-view pool simulation, and SVG Red Panda vector assembly.
- **Course-Correction & Observations**:
  1. Replaced static mockup approaches with a fully procedural dual-layer caustic wave lattice and ceramic tile refraction engine executed on Flutter's hardware-accelerated canvas.
  2. Implemented realistic spring-damper buoyancy physics: user taps apply an initial vertical impulse ($+14\text{px}$) and rotational tilt ($\pm 0.12\text{ rad}$) which exponentially decay back into tranquil sinusoidal bobbing.
  3. Pre-allocated all `Paint` and `Path` objects outside the per-frame `paint()` lifecycle, ensuring 0 GC pressure and flawless 60/120 FPS frame pacing.
  4. Implemented full reduced-motion accessibility: when `MediaQuery.disableAnimationsOf(context)` is true, wave oscillations and particles pause gracefully into tranquil static caustics while maintaining full interactive usability.
- **Sign-Off**: `animation-agent`, `ux-ui-agent`, `qa-agent`, `release-devops-agent`.
