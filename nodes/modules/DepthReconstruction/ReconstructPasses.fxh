float4 pLINEARDEPTH(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0):SV_Target{
	float d= texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	return UVZtoWORLD(UV,d);
}
float4 pPOSW(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0): SV_Target{
	float d = texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	float4 p=UVZtoWORLD(UV,d);
	return p;
}
float4 pPOSV(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0): SV_Target{
	float d = texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	float4 p=UVZtoVIEW(UV,d);
	return p;
}
float4 pNORMAL(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0): SV_Target{
	float d = texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	float3 w0=UVZtoVIEW(UV,d).xyz;
	float3 w1=UVZtoVIEW(UV-float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(1,0)/R,0).x).xyz;
	float3 w2=UVZtoVIEW(UV-float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(0,1)/R,0).x).xyz;
	float3 w3=UVZtoVIEW(UV+float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(1,0)/R,0).x).xyz;
	float3 w4=UVZtoVIEW(UV+float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(0,1)/R,0).x).xyz;
	
	float3 c1=normalize(w1-w0);
	float3 c2=normalize(w2-w0);
	
	float3 Eye=UVtoEYE(UV);
	
	float3 NorV=normalize(cross(c1,c2));
	float3 NorW=normalize(mul(NorV,(float3x3)tVI));
	float4 c=float4(NorW,1);
	if(d==1)c.rgb=Eye;
	return c;
}
float4 pNORMALFIX(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0): SV_Target{
	float d = texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	float3 w0=UVZtoVIEW(UV,d).xyz;
	float3 w1=UVZtoVIEW(UV-float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(1,0)/R,0).x).xyz;
	float3 w2=UVZtoVIEW(UV-float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(0,1)/R,0).x).xyz;
	float3 w3=UVZtoVIEW(UV+float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(1,0)/R,0).x).xyz;
	float3 w4=UVZtoVIEW(UV+float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(0,1)/R,0).x).xyz;
	
	float3 c1=normalize(w1-w0);
	float3 c2=normalize(w2-w0);
	
	c1=lerp(normalize(w1-w0),normalize(w0-w3),length(w1-w0)>length(w3-w0));
	c2=lerp(normalize(w2-w0),normalize(w0-w4),length(w2-w0)>length(w4-w0));

	float3 Eye=UVtoEYE(UV);
	float3 NorV=normalize(cross(c1,c2));
	float3 NorW=normalize(mul(NorV,(float3x3)tVI));
	float4 c=float4(NorW,1);
	if(d==1)c.rgb=Eye;
	return c;
}
float4 pNORMALVIEW(float4 PosWVP:SV_POSITION,float2 UV:TEXCOORD0): SV_Target{
	float d = texDEPTH.SampleLevel(sPointClamp,UV,0).x;
	float3 w0=UVZtoVIEW(UV,d).xyz;
	float3 w1=UVZtoVIEW(UV-float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(1,0)/R,0).x).xyz;
	float3 w2=UVZtoVIEW(UV-float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV-float2(0,1)/R,0).x).xyz;
	float3 w3=UVZtoVIEW(UV+float2(1,0)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(1,0)/R,0).x).xyz;
	float3 w4=UVZtoVIEW(UV+float2(0,1)/R,texDEPTH.SampleLevel(sPointClamp,UV+float2(0,1)/R,0).x).xyz;
	
	float3 c1=normalize(w1-w0);
	float3 c2=normalize(w2-w0);
	
	float3 Eye=UVtoEYE(UV);
	
	float3 NorV=normalize(cross(c1,c2));
	float3 NorW=normalize(mul(NorV,(float3x3)tVI));
	float4 c=float4(NorV,1);
	if(d==1)c.rgb=Eye;
	return c;
}