StructuredBuffer<int> InputBuffer; //Append buffer

//Contains structure count
ByteAddressBuffer InputCountBuffer;

//Output buffer
RWStructuredBuffer<int> RWOutputBuffer : BACKBUFFER; 

[numthreads(64,1,1)]
void CS(uint3 i : SV_DispatchThreadID)
{
	//Structure count at 0 address
	uint cnt = InputCountBuffer.Load(0);
	
	//Important since we mght have override
	if (i.x >= cnt) { return; }
	
	//Now can just do cooking
	RWOutputBuffer[i.x] = InputBuffer[i.x]*2+1;
}

technique10 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




