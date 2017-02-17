//@author: vvvv group
//@help: basic pixel based lightning with point light
//@tags: shading, blinn
//@credits:

struct vsInput
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
};

struct psInput
{
    float4 posScreen : SV_Position;
    float3 LightDirV: TEXCOORD0;
    float3 NormV: TEXCOORD1;
    float3 ViewDirV: TEXCOORD2;
    float3 PosW: TEXCOORD3;
};

struct vsInputTextured
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
	float4 uv: TEXCOORD0;
};

struct psInputTextured
{
    float4 posScreen : SV_Position;
    float4 uv: TEXCOORD0;
    float3 LightDirV: TEXCOORD1;
    float3 NormV: TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
	float3 PosW: TEXCOORD4;
};

Texture2D inputTexture <string uiname="Texture";>;

SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
}; 

cbuffer cbPerDraw : register(b0)
{
	float4x4 tV: VIEW;
	float4x4 tP: PROJECTION;
	float4x4 tLVP: LAYERVIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tWL : WORLDLAYER;
	float4x4 tWV: WORLDVIEW;
	float4x4 tWIT: WORLDLAYERINVERSETRANSPOSE;
	
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tColor <string uiname="Color Transform";>;
};

cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

#include "PhongPoint.fxh"

psInputTextured VS_Textured
(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 TexCd : TEXCOORD0)
{
    psInputTextured output;

    output.PosW = mul(PosO, tWL).xyz;

    //inverse light direction in view space
    float3 LightDirW = normalize(lPos - output.PosW);
    output.LightDirV = mul(float4(LightDirW,0.0f), tV).xyz;
    
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);

    //position (projected)
    output.posScreen  = mul(PosO, mul(tW,tLVP));
    output.uv = mul(TexCd, tTex);
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
    return output;
}

psInput VS
(
    float4 PosO: POSITION,
    float3 NormO: NORMAL)
{
    psInput output;

    output.PosW = mul(PosO, tWL).xyz;

    //inverse light direction in view space
    float3 LightDirW = normalize(lPos - output.PosW);
    output.LightDirV = mul(float4(LightDirW,0.0f), tV).xyz;
    
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);

    //position (projected)
    output.posScreen  = mul(PosO, mul(tW,tLVP));
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
    return output;
}


float4 PS_Textured(psInputTextured input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler, input.uv.xy);
    col.rgb *= PhongPoint(input.PosW, input.NormV, input.ViewDirV, input.LightDirV).rgb;
    col.a *= Alpha;
    return mul(col, tColor);
}

float4 PS(psInput input): SV_Target
{
    float4 col = 1;
    col.rgb *= PhongPoint(input.PosW, input.NormV, input.ViewDirV, input.LightDirV).rgb;
    col.a *= Alpha;
    return mul(col, tColor);
}


technique10 TPhongPoint <string noTexCdFallback="TPhongPointNotexture"; >
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}

technique10 TPhongPointNotexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}


