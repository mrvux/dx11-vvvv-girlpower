RWStructuredBuffer<float4x4> Out : BACKBUFFER;
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

float4x4 lookat4(float3 dir,float3 up=float3(0,1,0)){float3 z=normalize(dir);float3 x=normalize(cross(up,z));float3 y=normalize(cross(z,x));return float4x4(x,0, y,0, z,0, 0,0,0,1);} 
[numthreads(64, 1, 1)]
void CS( uint3 DTid : SV_DispatchThreadID){
	if(DTid.x>=(uint)TotalCount)return;
	int2 R;tex.GetDimensions(R.x,R.y);
	float2 UV=uv[DTid.x];
	if(!UVSpace)UV=UV*0.5*float2(1,-1)+0.5;
	UV+=0.5/R;
	if(!Filter)UV=(floor(UV*R)+0.5)/R;
	
	float d=tex.SampleLevel(s0,UV,0).x;
	
	float3 w0=UVZtoVIEW(UV,d).xyz;
	float3 w1=UVZtoVIEW(UV-float2(1,0)/R,tex.SampleLevel(s0,UV-float2(1,0)/R,0).x).xyz;
	float3 w2=UVZtoVIEW(UV-float2(0,1)/R,tex.SampleLevel(s0,UV-float2(0,1)/R,0).x).xyz;
	float3 w3=UVZtoVIEW(UV+float2(1,0)/R,tex.SampleLevel(s0,UV+float2(1,0)/R,0).x).xyz;
	float3 w4=UVZtoVIEW(UV+float2(0,1)/R,tex.SampleLevel(s0,UV+float2(0,1)/R,0).x).xyz;
	
	float3 c1=normalize(w1-w0);
	float3 c2=normalize(w2-w0);
	
	float3 NorW=normalize(mul(cross(c1,c2),(float3x3)tVI));
	float4x4 wt={1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};
	
	float4 PosW=mul(float4(w0.xyz,1),tVI);
	wt=lookat4(NorW);
	wt[3].xyz=PosW.xyz;
	wt[3][3]*=(d!=1);
	Out[DTid.x]=wt;
}

technique11 Process{pass P0{SetComputeShader(CompileShader(cs_5_0,CS()));}}







