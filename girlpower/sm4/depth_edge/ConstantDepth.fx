//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

cbuffer cbPerObj : register( b0 )
{
	float4x4 tWVP : WORLDVIEWPROJECTION;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float d;
};

struct vsInput
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

struct psOutput
{
	float4 c : SV_Target0;
	float d : SV_Depth;
};

vs2ps VS(vsInput input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.PosO,tWVP);
    Out.TexCd = input.TexCd;
    return Out;
}

psOutput PS(vs2ps In)
{
	psOutput output;
    output.c = cAmb;
	output.d = d;
	return output;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}




