shader_type canvas_item;
render_mode blend_mix;

uniform float radius = 0.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest_mipmap;

void fragment() {
	COLOR = vec4(textureLod(SCREEN_TEXTURE, SCREEN_UV, radius).rgb, 1.0);
}
