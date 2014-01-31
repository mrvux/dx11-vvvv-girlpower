RWStructuredBuffer<uint> RWValueBuffer : BACKBUFFER;

[numthreads(64,1,1)]
void CS64(uint3 dtid : SV_DispatchThreadID)
{
	RWValueBuffer[dtid.x] = dtid.x % 8;	
}

[numthreads(8,8,1)]
void CS8(uint3 dtid : SV_DispatchThreadID)
{
	uint idx = dtid.y*8+dtid.x;
	RWValueBuffer[idx] = dtid.x;	
}

technique11 Repeat64
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS64() ) );
	}
}

technique11 Repeat_8x8
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS8() ) );
	}
}

