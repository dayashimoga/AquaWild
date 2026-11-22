# Multi-Agent Subphase Review Workflow (`run_workflow` compatible)
# Orchestrates parallel specialist agent reviews across Architecture, UX/UI, Animation, QA, and Security.

phase("Parallel Multi-Agent Subphase Audit")

review_angles = [
    ("solution-architect", "Architecture & ADR Compliance", "Verify Clean Architecture boundaries, Riverpod state immutability, offline-first sync readiness, and ADR alignment."),
    ("ux-ui-agent", "UX/UI & WCAG 2.2 AA+ Accessibility", "Verify modern-futuristic Hydro-Glass aesthetics, responsive breakpoints (mobile/tablet/desktop/web), high-contrast mode, keyboard navigation, and screen reader Semantics."),
    ("animation-agent", "60/120 FPS Fluid Physics & Shaders", "Verify fluid wave simulation, multi-drink stratification, SVG Red Panda floating pool physics, particle splashes, and reduced-motion fallbacks."),
    ("qa-agent", "Unit, Widget & Integration Test Coverage", "Verify test completeness, edge-case coverage, and zero analyzer warnings."),
    ("security-agent", "Application & Backend Security", "Verify zero hardcoded secrets, input sanitization, OWASP compliance, and Supabase RLS policies.")
]

results = await parallel(
    review_angles,
    lambda item: agent(
        prompt=f"Perform a rigorous {item[1]} audit of the current workspace h:/water for the active subphase. {item[2]} Return a concise structured assessment with PASS/FAIL and findings.",
        schema={
            "type": "object",
            "properties": {
                "domain": {"type": "string"},
                "status": {"type": "string", "enum": ["PASS", "WARN", "FAIL"]},
                "findings": {"type": "array", "items": {"type": "string"}},
                "recommendations": {"type": "array", "items": {"type": "string"}}
            },
            "required": ["domain", "status", "findings", "recommendations"]
        },
        role=item[1],
        type_name=item[0]
    )
)

for r in results:
    log(f"[{r['status']}] {r['domain']}: {', '.join(r['findings'])}")
