float4x4 tW: WORLD;
float4x4 tWV: WORLDVIEW;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;

float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float4 lAmb  <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff <bool color=true;String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=3.0;> = 25.0;     
float Alpha <float uimin=0.0; float uimax=1.5;> = 1;	
float4x4 tColor <string uiname="Color Transform";>;


Texture2D texture2d <string uiname="Texture"; >; 
SamplerState g_samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

struct VS_IN
{
    float4 PosO  : POSITION;
    float4 NormO : NORMAL;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;

    //inverse light direction in view space
    float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);

    //normal in view space
    float3 NormV = normalize(mul(float4(input.NormO.xyz,0), tWV).xyz).xyz;

    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.PosO, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;

    //position (projected)
    Out.PosWVP  = mul(PosV, tP);
    Out.Diffuse = diff + lAmb;
    Out.Specular = spec;

    return Out;
}

float4 PS(vs2ps In): SV_Target
{

    float4 col = 1;
    col.rgb *= In.Diffuse.xyz + In.Specular.xyz;

    col = mul(col, tColor);
    col.a *= Alpha;
    
    return col;
}

technique10 GouraudDirectional
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
