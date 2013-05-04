float4x4 tWVP : WORLDVIEWPROJECTION;
float4x4 tWV : WORLDVIEW;

float4 Color <bool color=true;> = 1.0f;

struct vsInput
{
    float4 pos : POSITION;     
};

struct psInput
{
    float4 pos   : SV_Position;
};


psInput VS(vsInput input)
{
    psInput output;
	
	output.pos = mul(input.pos,tWVP);

    return output;    
}

float4 PS(psInput input) : SV_Target
{
	return Color;
}

technique10 RenderSimple
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}