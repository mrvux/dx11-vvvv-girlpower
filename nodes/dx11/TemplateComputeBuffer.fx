//@author: vux
//@help: template for simple compute shader (buffer write)
//@tags: template
//@credits: 

RWStructuredBuffer<float> OutputBuffer : BACKBUFFER;

cbuffer cbSettings : register(b0)
{
	uint elementCount;
}

[numthreads(64,1,1)]
void CS(uint3 tid : SV_DispatchThreadID)
{
	if (tid.x >= elementCount)
		return;
	
	OutputBuffer[tid.x] = tid.x;
}

technique11 Apply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




