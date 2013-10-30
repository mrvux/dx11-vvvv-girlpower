
float4x4 tW : WORLD;
float4x4 tVP: VIEWPROJECTION;
float4x4 tV:  VIEW;

float4 cAmb <bool color=true;>;

int oid : DRAWINDEX;

struct VS_IN
{
	float4 PosO : POSITION;
	float3 NormO : NORMAL;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
	uint id : TEXCOORD0;
};

struct PS_OUT
{
	float4 color :SV_Target0;
	uint id : SV_Target1;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
	
	float4x4 wvp = mul(tW,tVP);
	float4x4 wv = mul(tW,tV);

    //position (projected)
    Out.PosWVP  = mul(input.PosO,wvp);
	Out.id = oid + 1;
    return Out;
}


PS_OUT PS_MRT(vs2ps In)
{
	PS_OUT res;
	
    res.color = cAmb;
	res.id = In.id;

    return  res;
}

technique10 RenderMRT
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_MRT() ) );
	}
}






