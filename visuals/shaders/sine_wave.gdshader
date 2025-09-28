shader_type canvas_item;

uniform float frequency = 2.0;
uniform float height = 0.5;
uniform float thickness: hint_range(0, 1) = 0.25;
uniform float velocity = 1.0;
uniform float offset = 0.5;

void fragment() {
	float x = UV.x + TIME * velocity + offset;
	float wave_sample = sin(x * frequency * TAU);
	float wave_centre = 0.5 + wave_sample * height / 2.0;
	float wave_top = wave_centre + thickness / 2.0;
	float wave_bottom = wave_centre - thickness / 2.0;
	
	float t = step(UV.y, wave_top);
	t *= step(wave_bottom, UV.y);
	
	COLOR.a *= t;
}