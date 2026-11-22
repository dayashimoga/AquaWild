---
name: accessibility-and-quality-audit
description: >-
  Executes comprehensive WCAG 2.2 AA+ accessibility checks, multi-platform responsive breakpoint audits,
  security secret scans, and Flutter static analysis across Android, iOS, Web, Windows, macOS, and Linux.
---

# Accessibility, Security & Multi-Platform Quality Audit Skill

Run this audit before closing any subphase:

1. **Static Analysis**:
   - Run `flutter analyze --fatal-infos --fatal-warnings` (must return 0 issues).
2. **Automated Tests**:
   - Run `flutter test --coverage` (all unit, widget, and accessibility semantics tests must pass).
3. **Accessibility Matrix**:
   - Screen Reader: Verify explicit `Semantics` nodes on all custom canvases, fluid containers, animal cards, and beverage buttons.
   - Keyboard Navigation: Verify `FocusTraversalGroup`, visible focus rings, and keyboard shortcuts (`1`-`9` for quick drinks, `Space`/`Enter` to log, `R` for Red Panda pool view, `A` for AI coach).
   - Visual Modes: Verify Light, Dark, Bioluminescent Hydro-Glass, and High-Contrast themes, plus text scaling up to `2.0x`.
4. **Security Hygiene**:
   - Confirm zero hardcoded API keys or tokens in source code; verify environment variable injection (`--dart-define`) and Supabase RLS policies.
