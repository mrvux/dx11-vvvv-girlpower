//@author: vux
//@help: textured shader that allows alpha clipping
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
    float4 uv: TEXCOORD0;
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
	float4x4 tVP : LAYERVIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tColor <string uiname="Color Transform";>;
	float AlphaRef <string uiname="Alpha Reference Value"; float uimin=0.0; float uimax=1.0;> = 0.5f;
};

cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

psInputTextured VS_Textured(vsInputTextured input)
{
	//float4x4 wvp = tW * tVP;
	float4x4 wvp = mul(tW,tVP);
	psInputTextured output;
	output.posScreen = mul(input.posObject,wvp);
	output.uv = mul(input.uv, tTex);
	return output;
}

float4 PS_Textured(psInputTextured input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler,input.uv.xy) * cAmb;
	col = mul(col, tColor);
	col.a *= Alpha;
	clip(col.a - AlphaRef);
    return col;
}

technique11 Render
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}





