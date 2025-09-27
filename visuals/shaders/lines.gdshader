shader_type canvas_item;
/* 
line_count needs to be <= 1/4 of output
and >= than sample_width for ideal results
line_count == 1/2 sample_width can also work

High Quality: width = lines ~ 128, output = 512+
Pfp: width = 64, lines = 32, output = 128
*/
uniform float amount: hint_range(0, 1) = 1;
uniform int sample_width = 64;
uniform int line_count = 64;

// in format vec4(r, g, b, a);
uniform vec4 colour_a: source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 colour_b: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float w = float(sample_width);
    vec2 crunched_uv = floor(UV * w) / w;
    vec4 col = texture(TEXTURE, crunched_uv);
    
    float a = col.r + col.g + col.b;
    a = step(1.5, a);
    
    float n = a;
    float l = float(line_count);
    float z = 0.0;
    if (n > 0.0) {
        z = UV.x + UV.y + 0.25 / l;
    } else {
        z = UV.x - UV.y + 0.25 / l;
    }
    z = mod(z, 1.0);
    n = step(0.5, mod(z * l, 1.0));
    
	vec4 result = (colour_a * n) + (colour_b * (1.0 - n));
    COLOR = mix(COLOR, result, amount);
}