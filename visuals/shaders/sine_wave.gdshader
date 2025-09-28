shader_type canvas_item;

uniform float frequency = 2.0;
uniform float height = 0.5;
uniform float thickness: hint_range(0, 1) = 0.25;
uniform float border_thickness: hint_range(0, 0.25) = 0.04;
uniform float velocity = 1.0;
uniform float offset = 0.5;

vec2 get_slice(float top_base, float bottom_base, float w) {
	return vec2(top_base + w / 2.0, bottom_base - w / 2.0);
}

float step_slice(float t, vec2 slice) {
	return step(t, slice.x) * step(slice.y, t);
}

void fragment() {
	float x = UV.x + TIME * velocity + offset;
	float wave_sample = sin(x * frequency * TAU);
	float wave_centre = 0.5 + wave_sample * height / 2.0;
	
	vec2 wave_slice = get_slice(wave_centre, wave_centre, thickness);
	float t = step_slice(UV.y, wave_slice);
	
	vec2 border_slice = get_slice(wave_slice.x, wave_slice.y, border_thickness);
	float border_t = step_slice(UV.y, border_slice);
	
	COLOR *= vec4(vec3(t), (t + border_t));
}