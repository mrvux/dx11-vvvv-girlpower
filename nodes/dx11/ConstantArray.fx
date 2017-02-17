//@author: vux
//@help: Samples from a texture Array
//@tags: color
//@credits: 

Texture2DArray tex <string uiname="Texture";>;

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : LAYERVIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	int slice;
};

struct vsInput
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct psInput
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

psInput VS(vsInput input)
{
    psInput output;
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
    output.TexCd = input.TexCd;
    return output;
}

float4 PS(psInput input): SV_Target
{
    float4 col = tex.Sample(linearSampler,float3(input.TexCd.xy,slice)) * cAmb;
	col.a *= Alpha;
    return col;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




