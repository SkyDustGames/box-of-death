shader_type canvas_item;

// Inspector params:
uniform float effect = -1.1; // -1.0 is BARREL, 0.1 is PINCUSHION. For planets, ideally -1.1 to -4.
uniform float effect_scale = 1.1; // Play with this to slightly vary the results.
uniform bool dynamic_crop = false; // Guesses the crop amount with an admittedly badly inaccurate formula.
uniform bool manual_crop = false; // Cut out the junk outside the sphere.
uniform float manual_amount = 0.95; // Higher value = more crop.

vec2 distort(vec2 p) {
	float d = length(p);
	float z = sqrt(1.0 + d * d * effect);
	float r = atan(d, z) / 3.14159;
	r *= effect_scale;
	float phi = atan(p.y, p.x);
	return vec2(r*cos(phi)+.5,r*sin(phi)+.5);
}

void fragment(){
	vec2 xy = (2.0 * UV);
	xy.x = xy.x - 1.0;
	xy.y = xy.y - 1.0;

	// Dynamic crop adjustment. -0.5 is equavalent to 'none'.
	float d_adjust = -0.5;
	if (dynamic_crop) {
		d_adjust = (effect/4.0) * -0.6;
	}

	// Perform distortion if needed.
	vec4 tex;
	float d = length(xy);
	if (d < 1.0 - d_adjust) {
		xy = distort(xy);
		tex = texture(TEXTURE, xy);
		COLOR = tex;
	}
	else {
		COLOR.a = 0.0;
	}

	// Apply manual crop.
	if (manual_crop && d > manual_amount) {
		COLOR.a = 0.0;
	}
}