#include <metal_stdlib>
using namespace metal;

struct Particle {
    float2 position;
    float2 velocity;
    float4 color;
    float  size;
    float  lifetime;
    float2 homePosition;
};

struct QuadVertex {
    float2 pos; // -0.5..0.5
    float2 uv;  // 0..1
};

struct VSOut {
    float4 position [[position]];
    float2 uv;
    float4 color;
};

struct Uniforms {
    float2 viewSize;  // pixels
    float  isEmitting; // 1 or 0
};

enum FieldKind {
    FieldKindRadial = 0,
    FieldKindLinear = 1,
    FieldKindTurbulence = 2,
    FieldKindVortex = 3,
    FieldKindDrag = 4,
    FieldKindVelocity = 5,
    FieldKindLinearGravity = 6,
    FieldKindNoise = 7,
    FieldKindElectric = 8,
    FieldKindMagnetic = 9,
    FieldKindSpring = 10
};

struct GPUField {
    float2 position;
    float2 vector;
    float  strength;
    float  radius;
    float  falloff;
    float  minRadius; // for some fields used as smoothness
    uint   kind;
    uint   enabled;
};

struct SimParams {
    float deltaTime;
    float time;
    uint  fieldCount;
    uint  homingEnabled;
    uint  homingOnlyWhenNoFields;
    float homingStrength;
    float homingDamping;
};

vertex VSOut particle_vertex(
    const device QuadVertex* quad [[buffer(0)]],
    const device Particle* particles [[buffer(1)]],
    constant Uniforms& uni [[buffer(2)]],
    uint vid [[vertex_id]], uint iid [[instance_id]]
) {
    VSOut out;
    QuadVertex v = quad[vid];
    Particle p = particles[iid];

    float2 sizePx = float2(p.size, p.size);
    float2 posPx = p.position + v.pos * sizePx;

    float2 ndc = float2(
        posPx.x / (uni.viewSize.x * 0.5),
        posPx.y / (uni.viewSize.y * 0.5)
    );

    out.position = float4(ndc, 0.0, 1.0);
    out.uv       = v.uv;
    out.color    = p.color * uni.isEmitting;
    return out;
}

fragment float4 particle_fragment(VSOut in [[stage_in]]) {
    float2 c = in.uv - float2(0.5, 0.5);
    float  d = length(c) * 2.0;
    float  alpha = smoothstep(1.0, 0.7, 1.0 - d);
    return float4(in.color.rgb, in.color.a * alpha);
}

inline float hash21(float2 p) {
    p = fract(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

// NOTE: patched to handle minRadius >= radius gracefully and avoid zeroing influence.
// Previous logic clamped dist to max(minRadius, 1e-6) unconditionally, which
// produced zero influence when minRadius == radius (as CPU side was setting minRadius=radius).
inline float influence(float dist, float radius, float falloff, float minRadius) {
    if (radius <= 0.0) {
        // Unbounded field: treat as full influence within the simulation (legacy behavior).
        return 1.0;
    }

    // Ensure physically valid ordering: minRadius must be < radius to have any effect.
    float safeRadius = max(radius, 1e-6);
    float safeMin = max(minRadius, 0.0);
    if (safeMin >= safeRadius) {
        // Ignore pathological minRadius to prevent zeroing the field.
        safeMin = max(0.0, safeRadius - 1e-6);
    }

    float d = max(dist, 1e-6);
    d = max(d, safeMin);

    if (d >= safeRadius) return 0.0;

    float t = 1.0 - clamp(d / safeRadius, 0.0, 1.0);
    if (falloff <= 0.0) return t;
    return pow(t, falloff);
}

kernel void particle_update(
    device Particle* particles [[buffer(0)]],
    const device GPUField* fields [[buffer(1)]],
    constant SimParams& sp [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    Particle p = particles[id];
    float2 force = float2(0.0);
    bool anyForceApplied = false;

    // Accumulate forces from all enabled fields
    for (uint i = 0; i < sp.fieldCount; ++i) {
        GPUField f = fields[i];
        if (f.enabled == 0) continue;

        if (f.kind == FieldKindRadial || f.kind == FieldKindElectric || f.kind == FieldKindMagnetic) {
            float2 dir = f.position - p.position;
            float dist = length(dir);
            float infl = influence(dist, f.radius, f.falloff, f.minRadius);
            if (dist > 1e-6 && infl > 0.0 && f.strength != 0.0) {
                force += normalize(dir) * f.strength * infl;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindLinear || f.kind == FieldKindVelocity || f.kind == FieldKindLinearGravity) {
            float2 v = f.vector;
            float len = length(v);
            if (f.strength != 0.0 && len > 1e-6) {
                force += (v / len) * f.strength;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindTurbulence) {
            float2 d = f.position - p.position;
            float dist = length(d);
            float infl = influence(dist, f.radius, max(1.0, f.falloff), f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float n = hash21(float2((float)id, sp.time + (float)i * 13.37));
                float a = n * 6.2831853;
                force += float2(cos(a), sin(a)) * f.strength * infl;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindVortex) {
            float2 dir = f.position - p.position;
            float dist = length(dir);
            float infl = influence(dist, f.radius, f.falloff, f.minRadius);
            if (dist > 1e-6 && infl > 0.0 && f.strength != 0.0) {
                float2 tang = float2(-dir.y, dir.x) / dist;
                force += tang * f.strength * infl;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindDrag) {
            if (f.strength > 0.0) {
                force += -p.velocity * f.strength;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindNoise) {
            float2 d = f.position - p.position;
            float dist = length(d);
            float infl = influence(dist, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float speed = max(0.0, f.vector.x);         // vector.x used as "animation speed"
                float t = sp.time * (0.5 + speed);
                float scale = (1.0 + clamp(f.falloff, 0.0, 1.0) * 2.0) * 0.01; // falloff as smoothness
                float2 np = p.position * scale + float2(t, t * 1.37);
                float n1 = hash21(np);
                float n2 = hash21(np.yx + 17.17);
                float a = (n1 - n2) * 6.2831853;
                float2 dir = float2(cos(a), sin(a));
                force += dir * f.strength * infl;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindSpring) {
            float2 dir = f.position - p.position;
            float dist = length(dir);
            float infl = influence(dist, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0) {
                // Hooke + damping (falloff is used as damping factor for spring)
                float2 springF = dir * f.strength * infl; // towards anchor
                float damp = max(0.0, f.falloff);
                float2 dampF = -p.velocity * damp;
                force += springF + dampF;
                anyForceApplied = true;
            }
        }
    }

    // Homing: gently return particles when no other forces are active OR if configured to always home
    if (sp.homingEnabled == 1 && (sp.homingOnlyWhenNoFields == 0 || !anyForceApplied)) {
        float2 homeDir = p.homePosition - p.position;
        float2 homeF = homeDir * sp.homingStrength + (-p.velocity) * sp.homingDamping;
        force += homeF;
    }

    // Integrate
    float dt = max(sp.deltaTime, 1e-6);
    float2 accel = force;
    p.velocity += accel * dt;
    p.position += p.velocity * dt;

    particles[id] = p;
}
