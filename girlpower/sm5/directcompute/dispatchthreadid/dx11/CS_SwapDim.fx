RWStructuredBuffer<uint> RWValueBuffer : BACKBUFFER;

[numthreads(64,1,1)]
void CS_1(uint3 dtid : SV_DispatchThreadID)
{
	uint i = dtid.x;
	RWValueBuffer[dtid.x] = (i%8)*8+i/8;
}

[numthreads(8,8,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	uint result = dtid.x*8+dtid.y;
	uint idx = dtid.y*8+dtid.x;
	RWValueBuffer[idx] = result;	
}


technique11 SwapDim_64
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_1() ) );
	}
}


technique11 SwapDim_8x8
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

