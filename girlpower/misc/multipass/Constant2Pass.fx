struct vsInput
{
    float4 posObject : POSITION;
	float2 uv : TEXCOORD0;
};

struct psInput
{
    float4 posScreen : SV_Position;
	float2 uv : TEXCOORD0;
};

cbuffer cbPerDraw : register(b0)
{
	float4x4 tVP : VIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
};

psInput VS(vsInput input)
{
	psInput output;
	output.posScreen = mul(input.posObject,mul(tW,tVP));
	output.uv = input.uv;
	return output;
}

float4 PS1(psInput input): SV_Target
{
    float4 col = cAmb;
    return col;
}


float4 PS2(psInput input): SV_Target
{
    float4 col = sin(input.uv.x*30.0f);	
    return col;
}

technique11 Render
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS1() ) );
	}
	pass P1
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS2() ) );
	}
}





