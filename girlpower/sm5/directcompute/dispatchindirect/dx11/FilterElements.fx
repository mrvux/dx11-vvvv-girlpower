StructuredBuffer<int> DataBuffer;

//Output buffer
AppendStructuredBuffer<int> AppendOutputBuffer : BACKBUFFER; 

[numthreads(64,1,1)]
void CS(uint3 i : SV_DispatchThreadID)
{
	//Structure count at 0 address
	uint idx = DataBuffer[i.x];
	if (idx < 10) 
	{
		AppendOutputBuffer.Append(idx);
	}
}

technique10 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




