Texture2D tex0 <string uiname="Texture";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

cbuffer cbControls:register(b0){
	float4x4 tVP:VIEWPROJECTION;
	float4x4 tW:WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
};

struct VS_IN{
	float4 PosO:POSITION;
	float4 TexCd:TEXCOORD0;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 TexCd:TEXCOORD0;
	float4 PosW:TEXCOORD1;
};

VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	float4 PosW=In.PosO;
	PosW=mul(PosW,tW);
	Out.PosW=PosW;
	Out.PosWVP=mul(PosW,tVP);
	Out.TexCd=mul(In.TexCd,tTex);
	return Out;
}

float2 XYZtoUV(float3 p){p=normalize(p);
	return float2(atan2(p.x,-p.z)/acos(-1)*.5+.5,asin(-p.y)/acos(-1)+.5);
}

float4 PS(VS_OUT In):SV_Target{
	float2 uv=XYZtoUV(mul(In.PosW,tTex).xyz);
	float4 c=tex0.SampleLevel(s0,uv,0);
	c=mul(c*Color,tColor);
	//c.a=Alpha;
	return c;
}


technique10 Constant{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}




