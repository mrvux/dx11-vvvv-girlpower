RWStructuredBuffer<float4> Out : BACKBUFFER;
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
Texture2D tex <string uiname="Texture";>;
SamplerState s0 <string uiname="Sampler State";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};
int TotalCount=1;
bool UVSpace=0;
[numthreads(64, 1, 1)]
void CS( uint3 DTid : SV_DispatchThreadID){
	if(DTid.x>=(uint)TotalCount)return;
	float2 TexCd=uv[DTid.x];
	if(!UVSpace)TexCd=TexCd*0.5*float2(1,-1)+0.5;
	int2 R;tex.GetDimensions(R.x,R.y);
	TexCd.xy+=0.5/R;
	Out[DTid.x] = tex.SampleLevel(s0,TexCd,0);
}

technique11 Process{pass P0{SetComputeShader(CompileShader(cs_5_0,CS()));}}







