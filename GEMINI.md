# GEMINI.md — Antigravity Workspace Rules for AquaWild (HydroFauna)

All agents operating in `h:/water` must strictly adhere to [AGENTS.md](./AGENTS.md).

## Mandatory Execution Constraints
- **One Active Subphase Only**: Never execute two subphases in a single turn. Complete the active subphase through Step 11 (Completion Report) and pause at Step 12 (Approval Gate) for user approval.
- **Zero Warnings Policy**: Every Dart file must pass `flutter analyze --fatal-infos --fatal-warnings` with 0 issues.
- **Universal Platform Compatibility**: Never import `dart:io` directly in shared UI, domain, or shader layers without conditional imports so Flutter Web and all 6 platforms (Android, iOS, Web, Windows, macOS, Linux) compile cleanly.
- **Accessibility First**: Every custom-painted canvas (`CustomPaint` / `FragmentShader`) must wrap or provide an explicit `Semantics` node announcing creature name, hydration percentage, volume consumed, and interactive actions, plus respect `MediaQuery.disableAnimationsOf(context)`.
- **Multi-Agent Workflow**: Utilize `.agents/skills/` and `.agents/workflows/` to coordinate multi-agent reviews across Solution Architect, Product, UX/UI, Animation, Backend, Mobile, Desktop/Web, QA, Security, and Release/DevOps.
