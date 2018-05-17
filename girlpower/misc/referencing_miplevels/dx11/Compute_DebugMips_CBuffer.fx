//@author: vux
//@help: debugs texture size using getdimensions
//@tags: template
//@credits: 

Texture2D InputTexture;

RWStructuredBuffer<float> OutputBuffer : BACKBUFFER;

cbuffer cbTextureData : register(b0)
{
	float textureMips : MIPLEVELSOF <string ref="InputTexture";> ;	
	float invTextureMips : INVMIPLEVELSOF <string ref="InputTexture";> ;
}

[numthreads(1,1,1)]
void CS(uint3 tid : SV_DispatchThreadID)
{
	OutputBuffer[0] = textureMips;
	OutputBuffer[1] = invTextureMips;
	
}

technique11 Apply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




