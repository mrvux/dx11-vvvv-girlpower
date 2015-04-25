Texture2D texIN <string uiname="Initial Texture";>;
Texture2D texPREV <string uiname="Texture";>;
SamplerState s0 <bool visible=false;string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=WRAP;AddressV=WRAP;};

float4x4 tWVP:WORLDVIEWPROJECTION;

float4x4 tTex <string uiname="Texture Transform";>;

struct VS_IN{
	float4 PosO:POSITION;
	float2 TexCd:TEXCOORD0;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float2 TexCd:TEXCOORD0;
};


VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	Out.PosWVP=mul(float4(In.PosO.xy,0,1),tWVP);
	Out.TexCd.xy=In.TexCd.xy;
	return Out;
}

float2 R:TARGETSIZE;
int Width <float uimin=0.0;> =10;
float Threshold <float uimin=0.0;float uimax=1.0;> =0.5;

float4 PS(float4 PosWVP:SV_POSITION,float2 x:TEXCOORD0):SV_Target{
	int2 ip=PosWVP.xy;
	float4 c=texIN.Load(int3(ip,0));
	return c;
}
float CalcC(float H, float V, bool inv=0){
	if(inv)V=-V;
	V=max(0,V);
    return (sqrt(H*H+V*V));
}
float4 pVERT(float4 PosWVP:SV_POSITION,float2 x:TEXCOORD0):SV_Target{
	int2 ip=PosWVP.xy;
	bool inside=texIN.Load(int3(ip.xy,0)).x>Threshold;
	float dist=1;
	for(int i=1;i<=Width;i++){
		if((texIN.Load(int3(ip.x,clamp(ip.y+i,0,R.y-1),0)).x>Threshold)^inside)dist=min(dist,(float)i/Width);
		if((texIN.Load(int3(ip.x,clamp(ip.y-i,0,R.y-1),0)).x>Threshold)^inside)dist=min(dist,(float)i/Width);
		
	}
	if(inside)dist*=-1;
	//dist=inside;
	return dist;
}
float Scale=1;
float Bias=0;
float4 pHORZ(float4 PosWVP:SV_POSITION,float2 x:TEXCOORD0):SV_Target{
	int2 ip=PosWVP.xy;
	bool inside=texIN.Load(int3(ip.xy,0)).x>Threshold;
	float dist = CalcC(0.0, texPREV.Load(int3(ip.xy,0)).x,inside);
	for (int i=1;i<=Width;i++){
		float H = (float)i/Width;
		dist = min(dist, CalcC(H, texPREV.Load(int3(clamp(ip.x+i,0,R.x-1),ip.y,0)).x,inside));
		dist = min(dist, CalcC(H, texPREV.Load(int3(clamp(ip.x-i,0,R.x-1),ip.y,0)).x,inside));
	}
	if(inside)dist=-dist+1./Width;
	dist=dist*Scale+Bias;
	return dist;
}

technique10 Vertical{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,pVERT()));
	}
}
technique10 Horizontal{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,pHORZ()));
	}
}



