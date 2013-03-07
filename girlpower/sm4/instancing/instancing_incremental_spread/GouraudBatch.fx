float4x4 tW : WORLD;
float4x4 tV : VIEW;
float4x4 tP : PROJECTION;


float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float4 lAmb  : COLOR <String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff : COLOR <String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec : COLOR <String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     

float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

int IntanceStartIndex = 0;
StructuredBuffer<float4x4> world;

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
    float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

struct VS_IN
{
	uint ii : SV_InstanceID;
    float4 PosO  : POSITION;
    float3 NormO : NORMAL;
    float4 TexCd : TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;

	/*Here we look up for local world transform using
	the object instance id and start offset*/
	float4x4 wo = world[input.ii + IntanceStartIndex];
	
	/* the WORLD transform applies to the 
	whole batch in case of instancing, so we can transform 
	all the batch at once using it */
	wo = mul(wo,tW);
	
	float4x4 wv = mul(wo,tV);

	//Simple gouraud shading
	float3 LightDirV = normalize(-mul(lDir, tV));
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

