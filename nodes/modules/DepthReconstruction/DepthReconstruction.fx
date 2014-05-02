Texture2D texDEPTH <string uiname="Depth Buffer";>;
 
SamplerState s0:IMMUTABLE{Filter=MIN_MAG_MIP_POINT;AddressU=WRAP;AddressV=WRAP;};

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	//float4x4 tP : PROJECTION;
	//float4x4 tPI : PROJECTIONINVERSE;
	//float4x4 tVI : VIEWINVERSE;
	//float4x4 tV : VIEW;
	float4x4 tP;
	float4x4 tPI;
	float4x4 tVI;
	float4x4 tV;
	float4x4 tW:WORLD;
};


struct VS_IN
{
	float4 PosO : POSITION;
	float2 UV : TEXCOORD0;
};

struct VS_OUT
{
    float4 PosWVP: SV_POSITION;
    float2 UV: TEXCOORD0;
};

VS_OUT VS(VS_IN In)
{
    VS_OUT Out = (VS_OUT)0;

    //position (projected)
	//Out.PosWVP = In.PosO;//mul(In.PosO,mul(tW,tVP));
	Out.PosWVP = mul(In.PosO,tW);
    Out.UV = In.UV;
	
    return Out;
}
float4x4 tTex <string uiname="Texture Transform";>;

float2 R:TARGETSIZE;
SamplerState sPointClamp:IMMUTABLE {Filter=MIN_MAG_MIP_POINT;AddressU=CLAMP;AddressV=CLAMP;};
#include "ReconstructFunctions.fxh"
#include "ReconstructPasses.fxh"

technique10 PositionWorld
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, pPOSW() ) );
	}
}

technique10 PositionView
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, pPOSV() ) );
	}
}
technique10 NormalWorld
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, pNORMAL() ) );
	}
}
technique10 NormalWorld_fix
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, pNORMALFIX() ) );
	}
}
technique10 NormalView
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, pNORMALVIEW() ) );
	}
}

