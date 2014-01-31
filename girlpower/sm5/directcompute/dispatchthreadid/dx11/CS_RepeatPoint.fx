RWStructuredBuffer<uint> RWValueBuffer : BACKBUFFER;

[numthreads(8,8,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	uint idx = dtid.y*8+dtid.x;
	RWValueBuffer[idx] = dtid.y;	
}

technique11 CS_8x8
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

