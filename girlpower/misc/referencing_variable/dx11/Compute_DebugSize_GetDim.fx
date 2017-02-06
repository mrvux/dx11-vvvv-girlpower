//@author: vux
//@help: debugs texture size using getdimensions
//@tags: template
//@credits: 

Texture2D InputTexture;

RWStructuredBuffer<float> OutputBuffer : BACKBUFFER;

[numthreads(1,1,1)]
void CS(uint3 tid : SV_DispatchThreadID)
{
	
	uint x,y,m;
	InputTexture.GetDimensions(x,y);

	OutputBuffer[0] = x;
	OutputBuffer[1] = y;
	
	OutputBuffer[2] = 1.0f / (float)x;
	OutputBuffer[3] = 1.0f / (float)y;
}

technique11 Apply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




