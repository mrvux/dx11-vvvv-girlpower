Texture2D tex <string uiname="Texture";>;

struct VS_IN
{
    float4 p  : POSITION;
};

struct vs2ps
{
    float4 p: SV_POSITION;
};



vs2ps VS(VS_IN input)
{
    vs2ps output;
	output.p = input.p;
	return output;
}

float4 PS(vs2ps input): SV_Target
{
	float4 color = tex.Load(int3(input.p.xy,0));
	color.rgb = 1 -color.rgb;
	return color;
}

technique10 Invert
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

