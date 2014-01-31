float3 rCX(float3 p, float a,float3 ce) {
	float c,s;float3 q=p-ce;
	c = cos(a); s = sin(a);
	p.y = c * q.y - s * q.z;
	p.z = s * q.y + c * q.z;
	return p+ce;
}

float3 rCY(float3 p, float a,float3 ce) {
	float c,s;float3 q=p-ce;
	c = cos(a); s = sin(a);
	p.x = c * q.x + s * q.z;
	p.z = -s * q.x + c * q.z;
	return p+ce;
}

float3 rCZ(float3 p, float a,float3 ce) {
	float c,s;float3 q=p-ce;
	c = cos(a); s = sin(a);
	p.x = c * q.x - s * q.y;
	p.y = s * q.x + c * q.y;
	return p+ce;
}

float3 rX(float3 p, float a) {
	float c,s;float3 q=p;
	c = cos(a); s = sin(a);
	p.y = c * q.y - s * q.z;
	p.z = s * q.y + c * q.z;
	return p;
}

float3 rY(float3 p, float a) {
	float c,s;float3 q=p;
	c = cos(a); s = sin(a);
	p.x = c * q.x + s * q.z;
	p.z = -s * q.x + c * q.z;
	return p;
}

float3 rZ(float3 p, float a) {
	float c,s;float3 q=p;
	c = cos(a); s = sin(a);
	p.x = c * q.x - s * q.y;
	p.y = s * q.x + c * q.y;
	return p;
}