Texture2D texDEPTH <string uiname="Depth Buffer";>;
Texture2D texCOLOR <string uiname="Color Buffer";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";> 
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};
SamplerState s1:IMMUTABLE
{Filter=MIN_MAG_MIP_POINT;AddressU=WRAP;AddressV=WRAP;};

cbuffer cbControls : register( b0 )
{
    float4x4 tVP : VIEWPROJECTION;
    float4x4 tW : WORLD;
	
    float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
    float4 Color <bool color=true;> = { 1.0f,1.0f,1.0f,1.0f };
    float4x4 tTex <string uiname="Texture Transform";>;
    float4x4 tColor <string uiname="Color Transform";>;
	
};

struct VS_IN
{
    float4 PosO : POSITION;
    float4 TexCd : TEXCOORD0;
};

struct VS_OUT
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

VS_OUT VS(VS_IN In)
{
    VS_OUT Out=(VS_OUT)0;
    Out.PosWVP=mul(In.PosO,mul(tW,tVP));
    Out.TexCd=mul(In.TexCd,tTex);
    return Out;
}


struct PS_OUT{
	float4 Color:SV_TARGET;
	float Depth:SV_DEPTH;
};

PS_OUT PS(VS_OUT In)
{
	PS_OUT Out=(PS_OUT)0;
	float4 c=texCOLOR.Sample(s0,In.TexCd.xy);
	c=mul(c,tColor);
	c=c*Color;
	Out.Color=c;
	Out.Depth=texDEPTH.Sample(s0,In.TexCd.xy).x;
    return Out;
}



technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




