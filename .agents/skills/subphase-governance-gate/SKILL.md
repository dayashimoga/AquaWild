---
name: subphase-governance-gate
description: >-
  Enforces the mandatory 12-step subphase execution protocol, AI course-correction checks,
  subphase governance thresholds, and multi-agent sign-off before advancing to any approval gate.
  Use at the start and end of every subphase.
---

# Subphase Governance Gate & 12-Step Verification Skill

Every subphase in the AquaWild (HydroFauna) master implementation plan MUST pass through all 12 steps below in strict sequential order:

## 12-Step Mandatory Execution Checklist
1. **Requirements Validation**: Confirm 100% alignment with `<USER_REQUEST>` and reference image inspirations (surpassing Waterllama & Brownie Pool prototype).
2. **Gap Analysis**: Compare planned increment against competitor benchmarks and identify missing micro-interactions, edge cases, or platform nuances.
3. **Architecture Review**: Validate Clean Architecture boundaries (`core`, `domain`, `data`, `presentation`, `shaders`), Riverpod provider scoping, and ADR compliance.
4. **Implementation**: Deliver production-grade code with zero `TODO`s, zero placeholders, and full cross-platform compatibility.
5. **Unit Testing**: Execute `flutter test` on domain models, math solvers, state notifiers, and repositories.
6. **Integration Testing**: Execute widget and end-to-end flow tests verifying UI interactions, animations, and state persistence.
7. **Performance Validation**: Verify 60/120 FPS budget (< 8.3ms frame time), zero ticker leaks, and O(1) per-pixel/per-column fluid solver execution.
8. **Security Validation**: Audit for hardcoded secrets, SQL/RLS vulnerabilities, and unsafe input handling.
9. **Accessibility Validation**: Verify `Semantics` tree labels, WCAG 2.2 AA+ contrast, full keyboard traversal, large-text scaling, and reduced-motion physics mode.
10. **Documentation Update**: Update `docs/governance/EXECUTION_PLAN.md`, `docs/governance/DECISION_LOG.md`, `docs/adr/`, and `CHANGELOG.md`.
11. **Completion Report**: Present empirical verification evidence (command outputs, test counts, coverage metrics, file links).
12. **Approval Gate**: **STOP** immediately and ask the user for approval to proceed to the next subphase.
