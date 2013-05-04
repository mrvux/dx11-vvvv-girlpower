float4x4 tVP: VIEWPROJECTION;
float4x4 tV : VIEW;

ByteAddressBuffer sobuffer;

struct vsIn
{
	float4 pos : POSITION;
	float3 norm : NORMAL;
	uint ii : SV_InstanceID;
};

struct psIn
{
    float4 pos : SV_POSITION;
	float3 nv : TEXCOORD0;
}; 

psIn VS(vsIn input)
{
	psIn output;
	
	//Stride is 24, as 12 for position and 12 for normals, we can't use StreamOut as structured bufffer,
	//So we use byteaddress
	float x = asfloat(sobuffer.Load(input.ii * 24));
	float y = asfloat(sobuffer.Load(input.ii * 24 + 4));
	float z = asfloat(sobuffer.Load(input.ii * 24 + 8));
	
	float3 center = float3(x,y,z);
	
	//Move Box
	center += input.pos.xyz;
	
    output.pos  = mul(float4(center,1.0f),tVP);
	output.nv = mul(float4(input.norm,0.0f),tV).xyz;
    return output;
}

float4 PS(psIn input): SV_Target
{
   return float4(normalize(input.nv)*0.5f+0.5f,1.0f);
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}



 
