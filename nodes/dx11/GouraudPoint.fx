//@author: vux
//@help: basic vertex based lightning with point light
//@tags: shading, blinn
//@credits: vvvv group

struct vsInput
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
};

struct psInput
{
    float4 posScreen : SV_Position;
	float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

struct vsInputTextured
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
	float4 uv: TEXCOORD0;
};

struct psInputTextured
{
    float4 posScreen : SV_Position;
    float4 uv: TEXCOORD0;
	float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
};

Texture2D inputTexture <string uiname="Texture";>;

SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register(b0)
{
	float4x4 tV: VIEW;
	float4x4 tP: PROJECTION;
	float4x4 tVP: VIEWPROJECTION;
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLDLAYER;
	float4x4 tWLV: WORLDLAYERVIEW;
	float4x4 tWIT: WORLDLAYERINVERSETRANSPOSE;
	
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tColor <string uiname="Color Transform";>;
};

cbuffer cbTextureData : register(b2)
{
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

cbuffer cbLightData : register(b3)
{
	float3 lPos <string uiname="Light Position";> = {0, 5, -2};       //light position in world space
	float lAtt0 <String uiname="Light Attenuation 0"; float uimin=0.0;> = 0;
	float lAtt1 <String uiname="Light Attenuation 1"; float uimin=0.0;> = 0.3;
	float lAtt2 <String uiname="Light Attenuation 2"; float uimin=0.0;> = 0;
	float4 lAmb <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
	float4 lDiff <bool color=true; String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
	float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
	float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;     //shininess of specular highlight
	float lRange <String uiname="Light Range"; float uimin=0.0;> = 10.0;    	
};


psInputTextured VS_Textured(vsInputTextured input)
{
    psInputTextured output;

    //distance from light to vertex
    float4 PosW = mul(input.posObject, tW);
    float d = distance(PosW.xyz, lPos);

    float atten = 0;
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
    float3 NormV = normalize(mul(mul(input.normalObject.xyz, (float3x3)tWIT),(float3x3)tV).xyz);

    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.posObject, tWLV);
    float3 ViewDirV = normalize(-PosV.xyz);
    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float4 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower);

    float4 diff = lDiff * shades.y * atten;
    float4 spec = lSpec * shades.z * atten;

    //position (projected)
    output.posScreen  = mul(PosV, tP);
    output.uv = mul(input.uv, tTex);
    output.Diffuse = diff + lAmb;
    output.Specular = spec;

    return output;
}

float4 PS_Textured(psInputTextured input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler, input.uv.xy);
    col.rgb *= input.Diffuse.xyz + input.Specular.xyz;

    col = mul(col, tColor);
    col.a *= Alpha;  
    return col;
}

psInput VS(vsInput input)
{
    psInput output;

    //distance from light to vertex
    float4 PosW = mul(input.posObject, tW);
    float d = distance(PosW.xyz, lPos);

    float atten = 0;
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
    float3 NormV = normalize(mul(mul(input.normalObject.xyz, (float3x3)tWIT),(float3x3)tV).xyz);

    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.posObject, tWLV);
    float3 ViewDirV = normalize(-PosV.xyz);
    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float4 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower);

    float4 diff = lDiff * shades.y * atten;
    float4 spec = lSpec * shades.z * atten;

    //position (projected)
    output.posScreen  = mul(PosV, tP);
    output.Diffuse = diff + lAmb;
    output.Specular = spec;

    return output;
}

float4 PS(psInput input): SV_Target
{
    float4 col = 1;
    col.rgb *= input.Diffuse.xyz + input.Specular.xyz;

    col = mul(col, tColor);
    col.a *= Alpha;  
    return col;
}


technique11 GouraudPoint <string noTexCdFallback="GouraudPointNotexture"; >
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}

technique11 GouraudPointNotexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}



