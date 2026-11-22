## AquaWild (HydroFauna) — Pull Request Verification & Governance Gate

### 1. Description & Context
<!-- Provide a concise summary of the change, related subphase, and user requirements addressed. -->

### 2. Multi-Agent Role Ownership
- [ ] `solution-architect`: Architectural integrity, clean boundaries, ADR alignment
- [ ] `ux-ui-agent`: Responsive breakpoints (320px to 4K), theme consistency, typography
- [ ] `animation-agent`: 60/120 FPS raster budget, shader compilation, wave physics
- [ ] `backend-agent`: Supabase SQL schema, RLS policies, Edge Functions
- [ ] `mobile-agent`: Android/iOS platform configurations & bridges
- [ ] `desktop-web-agent`: Windows/macOS/Linux/Web Wasm compatibility & shortcuts
- [ ] `qa-agent`: Automated tests, 100% pass rate, zero analyzer warnings
- [ ] `security-agent`: Zero hardcoded secrets, sanitized inputs, secure storage
- [ ] `release-devops-agent`: CI/CD workflows and artifact packaging

### 3. Mandatory 12-Step Governance Checklist
- [ ] Step 1: Requirements Validation against master spec
- [ ] Step 2: Competitive Gap Analysis vs. Waterllama/Brownie
- [ ] Step 3: Architecture Review & ADR compliance
- [ ] Step 4: Implementation with ZERO stubs, ZERO placeholders, ZERO TODOs
- [ ] Step 5: Unit Tests passing
- [ ] Step 6: Integration Tests passing
- [ ] Step 7: Performance Validation (<8.3ms frame raster time)
- [ ] Step 8: Security Audit (Zero hardcoded keys, RLS verified)
- [ ] Step 9: Accessibility Audit (WCAG 2.2 AA+, Semantics, FocusTraversal, Reduced Motion)
- [ ] Step 10: Documentation updated (EXECUTION_PLAN, DECISION_LOG, CHANGELOG)
- [ ] Step 11: Completion Report generated
- [ ] Step 12: Approval Gate signed off

### 4. Verification Evidence
```bash
flutter analyze --fatal-infos --fatal-warnings # 0 issues found
flutter test --coverage                        # 100% passing
```
