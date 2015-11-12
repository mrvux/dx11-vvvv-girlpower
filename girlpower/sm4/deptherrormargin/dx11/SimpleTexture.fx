//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

//float4x4 tWVP: WORLDVIEWPROJECTION;

  

//float4x4 tVP : VIEWPROJECTION;
//float4x4 tW : WORLD;

Texture2D texture2d; 
 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb : COLOR = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
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
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //position (projected)
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = input.TexCd;// mul(input.TexCd, tTex);
    return Out;
}




float4 PS_Tex(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample( g_samLinear, In.TexCd) * cAmb;
	//float4 col = texture1.Sample( g_samLinear, In.TexCd.x) * cAmb;
	col = mul(col,tColor);
	col.a *= Alpha;
    return  col;
}

technique10 Constant
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}





