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
    float2 pos;
    float2 uv;
};

struct VSOut {
    float4 position [[position]];
    float2 uv;
    float4 color;
};

struct Uniforms {
    float2   viewSize;
    float    isEmitting;
    float    _padU;
    float4x4 mvp;
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
    float  minRadius;
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
    uint  particleCount;
};

vertex VSOut particle_vertex(
    const device QuadVertex* quad [[buffer(0)]],
    const device Particle* particles [[buffer(1)]],
    constant Uniforms& uni [[buffer(2)]],
    uint vid [[vertex_id]],
    uint iid [[instance_id]]
) {
    VSOut out;
    QuadVertex v = quad[vid];
    Particle p   = particles[iid];

    float2 sizePx = float2(p.size, p.size);
    float2 posPx  = p.position + v.pos * sizePx;

    float4 pos    = float4(posPx, 0.0, 1.0);
    float4 ndcPos = uni.mvp * pos;

    out.position = ndcPos;
    out.uv       = v.uv;
    out.color    = p.color;
    return out;
}

fragment float4 particle_fragment(VSOut in [[stage_in]]) {
    float2 c = in.uv - float2(0.5, 0.5);
    float d2 = dot(c, c);
    float soft = smoothstep(0.30, 0.25, d2);
    float baseA = clamp(in.color.a, 0.0, 1.0);
    float alpha = clamp(max(baseA, 0.85) * soft, 0.0, 1.0);
    return float4(in.color.rgb, alpha);
}

inline float hash21(float2 p) {
    p = fract(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

inline float valueNoise2(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float v00 = hash21(i);
    float v10 = hash21(i + float2(1.0, 0.0));
    float v01 = hash21(i + float2(0.0, 1.0));
    float v11 = hash21(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float a = mix(v00, v10, u.x);
    float b = mix(v01, v11, u.x);
    return mix(a, b, u.y);
}

inline float influence(float dist, float radius, float falloff, float minRadius) {
    float unbounded = step(radius, 0.0);
    float safeR  = max(radius, 1e-6);
    float safeMin = clamp(minRadius, 0.0, safeR - 1e-6);

    float d = max(max(dist, 1e-6), safeMin);
    float t = clamp((safeR - d) / safeR, 0.0, 1.0);

    float usePow = step(1e-6, falloff);
    float powT = pow(t, max(falloff, 1e-6));
    float shaped = mix(t, powT, usePow);

    return mix(shaped, 1.0, unbounded);
}

constant float TAU = 6.28318530718;

kernel void particle_update(
    device Particle* particles [[buffer(0)]],
    const device GPUField* fields [[buffer(1)]],
    constant SimParams& sp [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= sp.particleCount) { return; }
    Particle p = particles[id];
    float2 force = float2(0.0);
    bool anyForceApplied = false;

    for (uint i = 0; i < sp.fieldCount; ++i) {
        GPUField f = fields[i];
        if (f.enabled == 0) { continue; }

        if (f.kind == FieldKindRadial || f.kind == FieldKindElectric || f.kind == FieldKindMagnetic) {
            float2 dir = f.position - p.position;
            float r2 = dot(dir, dir);
            float invR = rsqrt(max(r2, 1e-12));
            float r = r2 * invR;
            float infl = influence(r, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float2 dirN = dir * invR;
                force += dirN * (f.strength * infl);
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindLinear || f.kind == FieldKindVelocity || f.kind == FieldKindLinearGravity) {
            float2 v = f.vector;
            float v2 = dot(v, v);
            if (f.strength != 0.0 && v2 > 1e-12) {
                float invLen = rsqrt(v2);
                force += (v * invLen) * f.strength;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindTurbulence) {
            float2 d = f.position - p.position;
            float r2 = dot(d, d);
            float invR = rsqrt(max(r2, 1e-12));
            float r = r2 * invR;
            float infl = influence(r, f.radius, max(1.0, f.falloff), f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float n = valueNoise2(float2((float)id * 0.01 + sp.time * 0.2, (float)i * 0.31));
                float a = n * TAU;
                float s = sin(a);
                float c = cos(a);
                force += float2(c, s) * (f.strength * infl);
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindVortex) {
            float2 dir = f.position - p.position;
            float r2 = dot(dir, dir);
            float invR = rsqrt(max(r2, 1e-12));
            float r = r2 * invR;
            float infl = influence(r, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float2 tang = float2(-dir.y, dir.x) * invR;
                force += tang * (f.strength * infl);
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindDrag) {
            float s = max(f.strength, 0.0);
            if (s > 0.0) {
                force += (-p.velocity) * s;
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindNoise) {
            float2 d = f.position - p.position;
            float r2 = dot(d, d);
            float invR = rsqrt(max(r2, 1e-12));
            float r = r2 * invR;
            float infl = influence(r, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0 && f.strength != 0.0) {
                float speed = max(0.0, f.vector.x);
                float t = sp.time * (0.5 + speed);
                float scale = (1.0 + clamp(f.falloff, 0.0, 1.0) * 2.0) * 0.01;
                float2 np = p.position * scale + float2(t, t * 1.37);
                float n1 = hash21(np);
                float n2 = hash21(np.yx + 17.17);
                float a = (n1 - n2) * TAU;
                float s = sin(a);
                float c = cos(a);
                float2 dirN = float2(c, s);
                force += dirN * (f.strength * infl);
                anyForceApplied = true;
            }
        } else if (f.kind == FieldKindSpring) {
            float2 dir = f.position - p.position;
            float r2 = dot(dir, dir);
            float invR = rsqrt(max(r2, 1e-12));
            float r = r2 * invR;
            float infl = influence(r, f.radius, f.falloff, f.minRadius);
            if (infl > 0.0) {
                float2 springF = dir * (f.strength * infl);
                float damp = max(0.0, f.falloff);
                float2 dampF = -p.velocity * damp;
                force += springF + dampF;
                anyForceApplied = true;
            }
        }
    }

    if (sp.homingEnabled == 1 && (sp.homingOnlyWhenNoFields == 0 || !anyForceApplied)) {
        float2 homeDir = p.homePosition - p.position;
        float2 homeF = homeDir * sp.homingStrength + (-p.velocity) * sp.homingDamping;
        force += homeF;
    }

    float dt = max(sp.deltaTime, 1e-6);
    float2 accel = force;
    p.velocity += accel * dt;
    p.position += p.velocity * dt;

    particles[id] = p;
}

