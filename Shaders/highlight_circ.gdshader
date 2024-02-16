shader_type canvas_item;

uniform vec2 size = vec2(40.0, 40.0);
uniform vec4 color : source_color = vec4(1.0, 1.0, 0.0, 0.4);
uniform bool filled = false;

float stepifyFloat(float val, float stepper)
{
	return float(int(val / stepper)) * stepper;
}

void fragment()
{
	vec2 pixelUV = vec2(stepifyFloat(UV.x, 1.0/size.x), stepifyFloat(UV.y, 1.0/size.y));
	vec2 scaledUV = pixelUV * size;
	float a = 0.0;
	
	float radius = min(size.x, size.y)/2.0;
	float dist = length(scaledUV - size/2.0);
	if(filled)
		a = 1.0-dist/radius;
	else
		a = 1.0 - abs(dist/radius - 0.5) * 2.0;
	
	a = max(0.0, min(1.0, a));
	COLOR = vec4(color.rgb, color.a*a);
}