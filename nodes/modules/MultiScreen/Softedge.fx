// this shader draws an alpha gradient

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;


int ViewIndex: VIEWPORTINDEX;
int ViewCount: VIEWPORTCOUNT;
int ViewCountx = 1;
int ViewCounty = 1;
float Gamma;
int LeftTopRightBottom;


struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos : SV_POSITION;
    float1 TexCd : TEXCOORD0;
    bool dosoft: TEXCOORD1;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = mul(input.PosO, tWVP);
    
    Out.TexCd.x = 0.5 + input.PosO.x;

    int viewx = (ViewIndex+0.01) % ViewCountx;
    int viewy = ceil(ViewIndex / ViewCountx);

    Out.dosoft = (((viewx > 0) && (LeftTopRightBottom==0)) ||
        ((viewy > 0) && (LeftTopRightBottom==1)) ||
        ((viewx < ViewCountx-1) && (LeftTopRightBottom==2)) ||
        ((viewy < ViewCounty-1) && (LeftTopRightBottom==3)));
        
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{

    if (In.dosoft.x==1)
    {
    float4 col = float4(0, 0, 0, 1);
      col.a = clamp(In.TexCd.x, 0, 1);
      col.a = pow(col.a, Gamma);
      col.a = 1 - col.a;
      return col;
    }
    else
    return 0;

}
/*
DepthStencilState DisableDepth
{
    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
	DepthFunc=ALWAYS;
}; */
// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique10 TSoftEdge
{
	pass P0
	{  
		//Wrap0 = U;  // useful when mesh is round like a sphere
	    // SetDepthStencilState( DisableDepth, 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}