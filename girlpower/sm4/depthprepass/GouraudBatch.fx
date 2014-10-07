float4x4 tV: VIEW;
float4x4 tP: PROJECTION;

float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float4 lAmb  : COLOR <String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff <bool color=true; String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     


float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

StructuredBuffer<float4x4> world;

int burnIterations = 50;

struct VS_IN
{
	uint ii : SV_InstanceID; //Object instance ID
    float4 PosO  : POSITION;
    float3 NormO : NORMAL;
    float4 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
    float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};



vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //inverse light direction in view space
    float3 LightDirV = normalize(-mul(lDir, tV)).xyz;
	
	//Get the current world transform from buffer.
	//So index is instance ID + start index
	float4x4 w = world[input.ii];
	
	//Get world view transform
	float4x4 wv = mul(w,tV);

	//Here is just simple gouraud shading
    float3 NormV = normalize(mul(input.NormO, wv));
    float4 PosV = mul(input.PosO, wv);
    float3 ViewDirV = normalize(-PosV);
    float3 H = normalize(ViewDirV + LightDirV);
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower);
    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;

    Out.PosWVP  = mul(PosV, tP);
    Out.TexCd = input.TexCd;
    Out.Diffuse = diff + lAmb;
    Out.Specular = spec;

    return Out;
}

float4 PS(vs2ps In): SV_Target
{
	float4 col = In.Diffuse + In.Specular;
	for (int i = 0 ; i < burnIterations * 2; i++)
	{
		if(i % 2 == 0) 
		{
			col = col * 0.5f;
		}
		else
		{
			col = col * 2.0f;
		}
	}
    return col;
}

technique10 GouraudDirectional
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

