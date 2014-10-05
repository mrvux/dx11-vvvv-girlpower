//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

float2 Resolution;
float2 InvResolution;
Texture2D ColorTexture;
Texture2D DisplaceTexture; 

SamplerState linearSampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
struct vsInput
{
	uint iv : SV_VertexID;
};

struct gsInput
{
    float4 PosWVP: POSITION;
	float4 col : COLOR;
	float2 dir : TEXCOORD;
};

struct psInput
{
    float4 PosWVP: SV_POSITION;
	float4 col : COLOR;
};

gsInput VS(vsInput input)
{
    gsInput output;
	
	//Set our grid in 2d from Vertex ID
	float2 uv = float2(input.iv % Resolution.y / Resolution.y , (input.iv / Resolution.x) / Resolution.y);
	uv.y-=uv.x/Resolution.x;
	
	float2 p = uv;
	p.xy *= 2.0;
	p.xy -= 1.0;
	p.y *= -1;


	//Sample color and Displacement fromt textures
    output.PosWVP  = float4(p,0,1);
	output.col = ColorTexture.SampleLevel(linearSampler,uv,0);
	output.dir = DisplaceTexture.SampleLevel(linearSampler,uv,0).xy;
    
	return output;
} 

[maxvertexcount(2)]
void GS(point gsInput input[1], inout LineStream<psInput> lines)
{
    psInput output;
	
	//Extrude point to line using our data fetched in GS
	
	output.PosWVP = input[0].PosWVP;
	output.col = input[0].col;
	lines.Append(output);
	output.PosWVP = input[0].PosWVP + float4(input[0].dir,0,0);
	lines.Append(output);
	lines.RestartStrip();
}


float4 PS_Tex(psInput In): SV_Target
{
    return  In.col;
}

technique10 Constant
{
	pass P0
	{
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}




