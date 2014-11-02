// this shader is used by the multiscreen modules

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

//texture
Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


int ViewIndex: VIEWPORTINDEX;
int ViewCount: VIEWPORTCOUNT;
int ViewCountx = 1;
int ViewCounty = 1;
float4 backcolor <bool color=true;String uiname="Back Color";> = { .1f, .1f, .1f, 0.7f };
float4 fontcolor <bool color=true;String uiname="Font Color";> = { .8f, .8f, .8f, 0.8f };
 


struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};


struct vs2ps
{
    float4 Pos : SV_POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(VS_IN input)

{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = mul(input.PosO,tWVP);
    
    Out.TexCd.x = 0.5 + input.PosO.x;
    Out.TexCd.y = 0.5 - input.PosO.y;

    Out.TexCd.x = (Out.TexCd.x + ((ViewIndex+0.01) % ViewCountx)) / ViewCountx ;
    Out.TexCd.y = (Out.TexCd.y + ceil(ViewIndex / ViewCountx)) / ViewCounty ;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear,In.TexCd.xy);
    return float4(fontcolor * col.rgb, col.r * fontcolor.a) + backcolor;
    //return (viewindex > float(1));
}

DepthStencilState DisableDepth
{
    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
	DepthFunc=ALWAYS;
};
// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique10 ScreenNumber
{
	pass P0
	{   SetDepthStencilState( DisableDepth, 0 );
		//EnableDepth
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}