//@author: vux
//@help: debugs texture size using getdimensions
//@tags: template
//@credits: 

Texture2D InputTexture;

RWStructuredBuffer<float> OutputBuffer : BACKBUFFER;

cbuffer cbTextureData : register(b0)
{
	float2 textureSize : SIZEOF <string ref="InputTexture";> ;	
	float2 invTextureSize : INVSIZEOF <string ref="InputTexture";> ;
}

[numthreads(1,1,1)]
void CS(uint3 tid : SV_DispatchThreadID)
{
	
	uint x = 10,y = 10;

	OutputBuffer[0] = textureSize.x;
	OutputBuffer[1] = textureSize.y;
	
	OutputBuffer[2] = invTextureSize.x;
	OutputBuffer[3] = invTextureSize.y;
}

technique11 Apply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




