//@author: vux
//@help: basic pixel based lightning with directional light
//@tags: shading, blinn
//@credits: vvvv group

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
	float4x4 tVP: VIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tWV: WORLDVIEW;
	float4x4 tWIT: WORLDINVERSETRANSPOSE;
	
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tColor <string uiname="Color Transform";>;
};

cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

#include "PhongDirectional.fxh"

psInputTextured VS_Textured(float4 PosO: POSITION,float3 NormO: NORMAL, float4 TexCd : TEXCOORD0)
{
    psInputTextured output;
  
    //inverse light direction in view space
    output.LightDirV = normalize(-mul(float4(lDir,0.0f), mul(tW,tV)).xyz);
    
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);

    //position (projected)
    output.posScreen  = mul(PosO, mul(tW, tVP));
    output.uv = mul(TexCd, tTex);
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
    return output;
}

psInput VS(float4 PosO: POSITION,float3 NormO: NORMAL)
{
    psInput output;

    //inverse light direction in view space
    output.LightDirV = normalize(-mul(float4(lDir,0.0f), mul(tW,tV)).xyz);
    
    //normal in view space
    output.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);

    //position (projected)
    output.posScreen  = mul(PosO, mul(tW, tVP));
    output.ViewDirV = -normalize(mul(PosO, tWV).xyz);
    return output;
}

float4 PS_Textured(psInputTextured input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler, input.uv.xy);
    col.rgb *= PhongDirectional(input.NormV, input.ViewDirV, input.LightDirV).xyz;
    col.a *= Alpha;
    return mul(col, tColor);
}

float4 PS(psInput input): SV_Target
{
    float4 col = 1;
    col.rgb *= PhongDirectional(input.NormV, input.ViewDirV, input.LightDirV).xyz;
    col.a *= Alpha;
    return mul(col, tColor);
}



technique10 GouraudDirectional <string noTexCdFallback="GouraudDirectionalNotexture"; >
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}

technique11 GouraudDirectionalNotexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

