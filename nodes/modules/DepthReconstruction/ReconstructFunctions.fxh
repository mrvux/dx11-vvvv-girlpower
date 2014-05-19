float4 UVtoSCREEN(float2 UV){
	return float4((UV.xy*2-1)*float2(1,-1),0,1);
}

float3 UVtoEYE(float2 UV){
	return normalize(mul(float4(mul(float4((UV.xy*2-1)*float2(1,-1),0,1),tPI).xy,1,0),tVI).xyz);
}
float2 EYEtoUV(float3 Eye){
	float4 p=mul(float4(mul(Eye,(float3x3)tV),0),tP);
	return (p.xy/p.w)*float2(1,-1)*.5+.5;
}
float3 CAMPOS(){
	return mul(float4(0,0,0,1),tVI).xyz;
}
float4 UVZtoWORLD(float2 UV,float z){
	float4 p=mul(float4(UV.x*2-1,1-2*UV.y,0,1.0),tPI);
	float ld = tP._43 / (z - tP._33);
	p=float4(p.xy*ld,ld,1.0);
	p=mul(p,tVI);
	return p; 
}
float4 UVZtoVIEW(float2 UV,float z){
	float4 p=mul(float4(UV.x*2-1,1-2*UV.y,0,1.0),tPI);
	float ld = tP._43 / (z - tP._33);
	p=float4(p.xy*ld,ld,1.0);
	return p; 
}
float LinearDepth(float z){
	return tP._43 / (z - tP._33);
}
float2 WORLDtoUV(float3 PosW,float4x4 tV,float4x4 tP){
	float4 p=mul(float4(mul(float4(PosW.xyz,1),tV).xyz,1),tP);
	return (p.xy/p.w)*float2(1,-1)*.5+.5;
}