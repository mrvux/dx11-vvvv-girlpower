//transforms
float4x4 tW: WORLD ;
float4x4 tV: VIEW ;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW ;
float4x4 tP: PROJECTION ;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

float4x4 tTex <string uiname="Texture Transform";>;

struct PS_IN
{
    float4 PosWVP: SV_POSITION ;
	float3 PosV: TEXCOORD0 ;	
};

struct VS_IN
{
	//uint ii : SV_InstanceID;
    float4 PosO  : POSITION ;
    float3 NormO : NORMAL ;
    float4 TexCd : TEXCOORD0 ;
};


// -----------------------------------------------------------------------------
// VERTEXSHADERS
// -----------------------------------------------------------------------------

PS_IN VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    PS_IN output = (PS_IN)0;

    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.PosO,tWV);

    //position (projected)
	output.PosV = PosV.xyz;
    output.PosWVP  = mul(PosV, tP);
    return output;
}

// -----------------------------------------------------------------------------
// PIXELSHADERS:
// -----------------------------------------------------------------------------

float4 PS(PS_IN input) : SV_Target
{
    return float4(input.PosV,1.0);
}

float PSD(PS_IN input) : SV_Target
{
    return input.PosV.z;
}

// -----------------------------------------------------------------------------
// TECHNIQUES:
// -----------------------------------------------------------------------------

technique10 front
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}


technique10 depth
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSD() ) );
	}
}




