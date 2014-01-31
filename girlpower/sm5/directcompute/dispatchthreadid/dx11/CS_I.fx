RWStructuredBuffer<uint> RWValueBuffer : BACKBUFFER;

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	RWValueBuffer[dtid.x] = dtid.x;	
}

[numthreads(8,8,1)]
void CS2(uint3 dtid : SV_DispatchThreadID)
{
	uint idx = dtid.y*8+dtid.x;
	RWValueBuffer[idx] = idx;	
}


technique11 I_64
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

technique11 I_8x8
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS2() ) );
	}
}

