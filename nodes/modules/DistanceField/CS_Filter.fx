
int TotalCount=1;
AppendStructuredBuffer<float3> AppendOutput : BACKBUFFER;
Texture2D tex0 <string uiname="Texture";>;

SamplerState s0:IMMUTABLE
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

int2 GridSize={320,240};
[numthreads(32, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >=(uint)TotalCount) { return;}
	uint idx=i.x;
	int2 iuv=int2(idx%GridSize.x,idx/GridSize.x);
	float2 uv=(float2)(iuv+0.5)/GridSize;
	float2 pos=float2(uv.x*2-1,-(uv.y*2-1));
	float4 c=tex0.SampleLevel(s0,uv,0);
	if(c.y==1){
		AppendOutput.Append(float3(pos,1));
	}
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







