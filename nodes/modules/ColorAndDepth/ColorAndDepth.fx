Texture2D texDEPTH <string uiname="Depth Buffer";>;
Texture2D texCOLOR <string uiname="Color Buffer";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";> 
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};
SamplerState s1:IMMUTABLE
{Filter=MIN_MAG_MIP_POINT;AddressU=WRAP;AddressV=WRAP;};

cbuffer cbControls : register( b0 )
{
    float4x4 tVP : VIEWPROJECTION;
	float4x4 tP : PROJECTION;
    float4x4 tW : WORLD;
	
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
    Out.PosWVP=mul(In.PosO,tW);
    //Out.TexCd=mul(In.TexCd,tTex);
	Out.TexCd.xy=mul(float4((In.TexCd.xy-0.5)*float2(1,-1),0,1),tTex).xy*float2(1,-1)+.5;

    return Out;
}


struct PS_OUT{
	float4 Color:SV_TARGET;
	float Depth:SV_DEPTH;
};

#define IS_ORTHO(P) (round(P._34)==0&&round(P._44)==1)
float DepthBias=0;

PS_OUT PS(VS_OUT In)
{
	PS_OUT Out=(PS_OUT)0;
	float4 c=texCOLOR.Sample(s0,In.TexCd.xy);
	c=c*Color;
	c=mul(c,tColor);
	
	
	float d=texDEPTH.Sample(s0,In.TexCd.xy).x;
	
	if(!IS_ORTHO(tP)){
		float ld=tP._43/(d-tP._33);
		d=tP._43/(ld+DepthBias)+tP._33;
	}else{
		d=d+DepthBias*tP._33;
	}
	
	Out.Color=c;
	Out.Depth=d;
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




