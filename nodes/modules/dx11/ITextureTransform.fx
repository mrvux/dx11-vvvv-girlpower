//@author: vux, gregsn
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

StructuredBuffer<float4x4> sbWorld <string uiname="Transform";>;
StructuredBuffer<float4> sbColor <string uiname="Color";>;
StructuredBuffer<float4x4> sbTexTransform <string uiname="Texture Transform";>;

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	int colorcount <string uiname="Color Count";> = 1;
	int ttexcount <string uiname="Texture Transform Count";> = 1;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
	uint ii : SV_InstanceID;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;	
	float4 Color: TEXCOORD0;
    float4 TexCd: TEXCOORD1;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
	
	float4x4 w = sbWorld[input.ii];
    Out.PosWVP  = mul(input.PosO, mul(w,tVP));
	Out.Color = sbColor[input.ii % colorcount];
    Out.TexCd = mul(input.TexCd, sbTexTransform[input.ii % ttexcount]);
    return Out;
}

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear, In.TexCd.xy) * In.Color;
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