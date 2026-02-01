shader_type canvas_item;
render_mode blend_add;

uniform float glow_strength : hint_range(0.0, 5.0) = 1.5;
uniform float softness : hint_range(0.01, 1.0) = 0.25;

void fragment() {
    // расстояние от центра линии (Y = 0.5)
    float d = abs(UV.y - 0.5) * 2.0;

    // мягкое затухание к краям
    float glow = smoothstep(1.0, softness, d);

    vec4 col = COLOR;
    col.rgb *= glow * glow_strength;

    COLOR = col;
}
