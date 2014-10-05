
#define IS_ORTHO(P) (round(P._34)==0&&round(P._44)==1)

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
	return tVI[3].xyz;
}
float4 UVZtoVIEW(float2 UV,float z){
	if(IS_ORTHO(tP))return mul(float4(UV.x*2-1,1-2*UV.y,z,1.0),tPI);
	float4 p=mul(float4(UV.x*2-1,1-2*UV.y,0,1.0),tPI);
	float ld = tP._43 / (z - tP._33);
	p=float4(p.xy*ld,ld,1.0);
	return p; 
}
float4 UVZtoWORLD(float2 UV,float z){
	return mul(UVZtoVIEW(UV,z),tVI); 
}

float LinearDepth(float z){
	return tP._43 / (z - tP._33);
}
float2 WORLDtoUV(float3 PosW,float4x4 tV,float4x4 tP){
	float4 p=mul(float4(mul(float4(PosW.xyz,1),tV).xyz,1),tP);
	return (p.xy/p.w)*float2(1,-1)*.5+.5;
}

float3 RayOrigin(float2 UV){
	if(!IS_ORTHO(tP))return tVI[3].xyz;
	return mul(mul(float4(UV.x*2-1,1-2*UV.y,0,1.0),tPI),tVI).xyz;
}
float3 RayDirection(float2 UV){
	if(IS_ORTHO(tP))return mul(float3(0,0,1),(float3x3)tVI);
	return normalize(mul(float4(mul(float4((UV.xy*2-1)*float2(1,-1),0,1),tPI).xy,1,0),tVI).xyz);
}
float RayLength(float2 UV,float z){
	return length(UVZtoWORLD(UV,z).xyz-RayOrigin(UV));
}