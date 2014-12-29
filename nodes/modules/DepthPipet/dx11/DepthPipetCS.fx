RWStructuredBuffer<float4> Out : BACKBUFFER;
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
Texture2D tex <string uiname="Depth Buffer";>;
SamplerState s0 <string uiname="Sampler State";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};
int TotalCount=1;
bool UVSpace=0;
bool Filter=0;

float4x4 tV;
float4x4 tVI;
float4x4 tP;
float4x4 tPI;
#include "ReconstructFunctions.fxh"

[numthreads(64, 1, 1)]
void CS( uint3 DTid : SV_DispatchThreadID){
	if(DTid.x>=(uint)TotalCount)return;
	int2 R;tex.GetDimensions(R.x,R.y);
	float2 UV=uv[DTid.x];
	if(!UVSpace)UV=UV*0.5*float2(1,-1)+0.5;
	UV+=0.5/R;
	if(!Filter)UV=(floor(UV*R)+0.5)/R;
	float d=tex.SampleLevel(s0,UV,0).x;
	float4 PosW=UVZtoWORLD(UV,d);
	PosW.w=(d!=1);
	Out[DTid.x] = PosW;
}

technique11 Process{pass P0{SetComputeShader(CompileShader(cs_5_0,CS()));}}

