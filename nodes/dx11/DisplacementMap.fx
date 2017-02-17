//@author: tmp
//@help: texture-controlled displacement map
//@tags: displacement
//@credits: 

Texture2D texture2d <string uiname="Input";>;
Texture2D texture2dctrl <string uiname="Control";>;

SamplerState Samp : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = MIRROR;
    AddressV = MIRROR;
};
 
cbuffer cbControls : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tVP : LAYERVIEWPROJECTION;
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float2 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps output;
    output.PosWVP  = mul(input.PosO,mul(tW,tVP));
    output.TexCd = mul(input.TexCd, tTex).xy;
    return output;
}

float4 PS(vs2ps In): SV_Target
{
	float2 dir = texture2dctrl.Sample(Samp, In.TexCd).rg  ;	
	float4 col = texture2d.Sample(Samp, In.TexCd + dir );
    return col;
}

float4 PS_Absolute(vs2ps In): SV_Target
{
	float2 dir = texture2dctrl.Sample(Samp, In.TexCd).rg  ;	
	float4 col = texture2d.Sample(Samp, dir );
    return col;
}

technique10 TDisplacementMap
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

technique10 TDisplacementMapAbsolute
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Absolute() ) );
	}
}