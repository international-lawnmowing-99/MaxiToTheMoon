shader_type canvas_item;

uniform vec4 colour : hint_color;

void fragment(){
	COLOR.rgb = colour.rgb;
	COLOR.a = texture(TEXTURE, UV).a;
	}