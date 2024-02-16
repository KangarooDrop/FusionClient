shader_type canvas_item;

uniform vec2 size = vec2(40.0, 40.0);
uniform float radius = 10.0;

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
	
	//OUTTER RECT
	if(scaledUV.x < radius)
	{
		if(scaledUV.y < radius)
			a = 1.0 - length(vec2(scaledUV.x - radius, scaledUV.y - radius))/radius;
		else if(scaledUV.y > size.y - radius)
			a = 1.0 - length(vec2(scaledUV.x - radius, size.y - scaledUV.y - radius))/radius;
		else
			a = scaledUV.x/radius;
	}
	else if(scaledUV.x < size.x - radius)
	{
		if(scaledUV.y < radius)
			a = scaledUV.y/radius;
		else if(scaledUV.y < size.y-radius)
			if(filled)
				a = 1.0;
			else
			{
				if(false)
				{
					a = max(a, 2.0 - scaledUV.x/radius);
					a = max(a, 2.0 - scaledUV.y/radius);
				}
				else
				{
					//INNER RECT
					if(scaledUV.x < radius * 2.0)
					{
						if(scaledUV.y < radius * 2.0)
							a = max(a, length(vec2(scaledUV.x - radius*2.0, scaledUV.y - radius*2.0))/radius);
						else if(scaledUV.y < size.y - radius*2.0)
							a = max(a, 2.0 - scaledUV.x/radius);
						else
							a = max(a, length(vec2(scaledUV.x - radius*2.0, size.y - scaledUV.y - radius*2.0))/radius);
					}
					else if(scaledUV.x < size.x - radius * 2.0)
						if(scaledUV.y < radius * 2.0)
							a = max(a, 2.0 - scaledUV.y/radius);
						else if(scaledUV.y < size.y - radius*2.0)
							a = max(a, 0.0);
						else
							a = max(a, 2.0 - (size.y-scaledUV.y)/radius);
					else
						if(scaledUV.y < radius * 2.0)
							a = max(a, length(vec2(size.x - scaledUV.x - radius*2.0, scaledUV.y - radius*2.0))/radius);
						else if(scaledUV.y < size.y - radius*2.0)
							a = max(a, 2.0 - (size.x - scaledUV.x)/radius);
						else
							a = max(a, length(vec2(size.x - scaledUV.x - radius*2.0, size.y - scaledUV.y - radius*2.0))/radius);
				}
			}
		else
			a = (size.y-scaledUV.y)/radius;
	} 
	else
	{
		if(scaledUV.y < radius)
			a = 1.0 - length(vec2(size.x - scaledUV.x - radius, scaledUV.y - radius))/radius;
		else if(scaledUV.y < size.y-radius)
			a = (size.x-scaledUV.x)/radius;
		else
			a = 1.0 - length(vec2(size.x - scaledUV.x - radius, size.y - scaledUV.y - radius))/radius;
	}
	
	
	a = max(0.0, min(1.0, a));
	COLOR = vec4(color.rgb, color.a*a);
}