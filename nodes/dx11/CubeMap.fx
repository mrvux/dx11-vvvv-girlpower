//@author: vux
//@help: basic cubemap sampler
//@tags: 
//@credits: 


TextureCube tex <string uiname="Texture Cube"; >;

SamplerState linearSampler : IMMUTABLE
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
};

struct vsInput
{
	float4 PosO : POSITION;
};

struct psInput
{
    float4 PosWVP: SV_POSITION;
    float4 PosO: TEXCOORD0;
};

psInput VS_Cube(vsInput input)
{
	psInput output;
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
    output.PosO = input.PosO;
    return output;
}

float4 PS_Cube(psInput input): SV_Target
{
    float4 col = tex.Sample(linearSampler,float3(input.PosO.xyz)) * cAmb;
	col.a *= Alpha;
    return col;
}

technique10 ConstantCube
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Cube() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Cube() ) );
	}
}




