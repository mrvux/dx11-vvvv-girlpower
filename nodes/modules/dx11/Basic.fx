//@author: vux, gregsn
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float2 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float2 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
	
    Out.PosWVP  = mul(input.PosO, mul(tW,tVP));
    Out.TexCd = input.TexCd;
    return Out;
}

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear, In.TexCd) * cAmb;
    return col;
}

technique10 Basic
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




