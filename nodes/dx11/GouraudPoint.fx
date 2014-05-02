//@author: vux
//@help: basic vertex based lightning with point light
//@tags: shading, blinn
//@credits:vvvv group

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (DX9)
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (DX9)
float4x4 tWIT: WORLDINVERSETRANSPOSE;

//light properties
float3 lPos <string uiname="Light Position";> = {0, 5, -2};       //light position in world space
float lAtt0 <String uiname="Light Attenuation 0"; float uimin=0.0;> = 0;
float lAtt1 <String uiname="Light Attenuation 1"; float uimin=0.0;> = 0.3;
float lAtt2 <String uiname="Light Attenuation 2"; float uimin=0.0;> = 0;
float4 lAmb <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
float4 lDiff <bool color=true; String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     //shininess of specular highlight
float lRange <String uiname="Light Range"; float uimin=0.0;> = 10.0;

float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

Texture2D texture2d <string uiname="Texture"; >; 
SamplerState g_samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};
float4x4 tTex <bool uvspace=true; string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd : TEXCOORD0;
    float4 Diffuse : COLOR0;
    float4 Specular : COLOR1;
};

vs2ps VS(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //distance from light to vertex
    float4 PosW = mul(PosO, tW);
    float d = distance(PosW.xyz, lPos);

    float atten = 0;

    //compute attenuation only if vertex within lightrange
    if (d<lRange)
    {
       atten = 1/(saturate(lAtt0) + saturate(lAtt1) * d + saturate(lAtt2) * pow(d, 2));
    }
    float4 amb = atten * lAmb;
    amb.a = 1;
    
    //inverse light direction in view space
    float3 LightDirW = normalize(lPos - PosW.xyz);
    float3 LightDirV = mul(float4(LightDirW,0.0f), tV).xyz;
    
    //normal in view space
    float3 NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);

    //view direction = inverse vertexposition in viewspace
    float3 PosV = mul(PosW, tV).xyz;
    float3 ViewDirV = normalize(-PosV);
    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float4 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower);

    float4 diff = lDiff * shades.y * atten;
    diff.a = 1;
    float4 spec = lSpec * shades.z * atten;
    spec.a = 1;

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
    Out.Diffuse = amb + diff;
    Out.Specular = spec;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear, In.TexCd.xy);
    col.rgb *= In.Diffuse.rgb + In.Specular.rgb;
    col = mul(col, tColor);
    col.a *= Alpha;

    return col;
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------
technique10 GouraudPoint
{
	pass P0
	{
		SetGeometryShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}


