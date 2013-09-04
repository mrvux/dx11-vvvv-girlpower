//@author: vux
//@help: Uses a different texute on an object is front/back side is rendered
//@tags: color
//@credits: 

Texture2D tfront <string uiname="Texture 1";>;
Texture2D tback <string uiname="Texture 2";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
	float4x4 tColor <string uiname="Color Transform";>;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

struct psIn
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	bool front : SV_IsFrontFace;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}


float4 PS(psIn input): SV_Target
{
    float4 cfront = tfront.Sample(g_samLinear,input.TexCd.xy);
	float4 cback = tback.Sample(g_samLinear,input.TexCd.xy);
	//Use different color depending on face side
    return input.front ? cfront : cback;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}





