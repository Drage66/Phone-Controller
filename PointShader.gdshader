shader_type spatial;
render_mode unshaded;
instance uniform vec4 color = vec4(1.0);

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float fre = fresnel(0.08,NORMAL,VIEW);
	fre = smoothstep(0.95,0.95,fre);
	ALBEDO = color.rgb;
	ALPHA = 0.9;
	// Called for every pixel the material is visible on.
	
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
