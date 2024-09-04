shader_type canvas_item;

uniform float rotation_amount;
uniform vec2 pivot_offset;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x 
	) + pivot;
}
void fragment() {
	COLOR = texture(TEXTURE, rotateUV(UV, TEXTURE_PIXEL_SIZE / 0.5, rotation_amount));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
