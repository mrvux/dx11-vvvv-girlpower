//@author: vux
//@help: simple shader that fetchs face data from structuredbuffers instead of geometry
//@tags: color
//@credits: 

struct vsInputTextured
{
    float4 posObject : POSITION;
	float4 uv: TEXCOORD0;
};

struct psInputTextured
{
    float4 posScreen : SV_Position;
    float2 uv: TEXCOORD0;
};

StructuredBuffer<float3> positionBuffer;
StructuredBuffer<float2> uvBuffer;

Texture2D inputTexture <string uiname="Texture";>;

SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register(b0)
{
	float4x4 tVP : LAYERVIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
};

psInputTextured VS_Textured(uint iv : SV_VertexID)
{
	psInputTextured output;
	
	float4 position = float4(positionBuffer[iv], 1.0f);

	output.posScreen = mul(position,mul(tW,tVP));
	output.uv = uvBuffer[iv];
	return output;
}


float4 PS_Textured(psInputTextured input): SV_Target
{
	return 1;
    /*float4 col = inputTexture.Sample(linearSampler,input.uv.xy) * cAmb;
	col = mul(col, tColor);
	col.a *= Alpha;
    return col;*/
}

technique11 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}



