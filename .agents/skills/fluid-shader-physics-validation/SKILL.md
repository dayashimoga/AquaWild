---
name: fluid-shader-physics-validation
description: >-
  Validates custom GLSL/Impeller fragment shaders, 1D/2D shallow-water wave solvers,
  multi-beverage density stratification, particle splashes, and SVG creature clipping masks
  for 60/120 FPS performance and reduced-motion accessibility.
---

# Fluid Shader & Physics Validation Skill

Use this skill whenever designing, implementing, or reviewing fluid simulation, animal silhouettes, or launch-screen pool physics:

## Physics & Rendering Requirements
1. **Multi-Beverage Stratification & Wave Solver**:
   - Each logged beverage layer maintains its authentic color palette, viscosity damping factor, hydration coefficient, and smooth meniscus wave boundary.
   - Surface wave columns solve Hooke's law + neighbor velocity coupling:
     $$\frac{d^2 y_i}{dt^2} = -k (y_i - y_0) - c \frac{dy_i}{dt} + s (y_{i-1} + y_{i+1} - 2y_i)$$
2. **Launch Screen SVG Red Panda Pool Simulation**:
   - Top-down procedural water tile/caustic grid with dynamic ripple distortion rings, specular sunlight reflections, floating shadow parallax, and buoyant bobbing + rotational torque on the detailed SVG Red Panda relaxing on its floating tube.
3. **Accessibility Fallback**:
   - When `MediaQuery.disableAnimationsOf(context)` or the app's `reducedMotion` setting is active, bypass continuous wave oscillations and transition fill levels smoothly with zero motion sickness triggers.
