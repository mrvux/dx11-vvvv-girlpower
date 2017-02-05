//@author: vux
//@help: basic Gouraud Directional Shading
//@tags: color
//@credits: 

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
};

cbuffer cbPerObj : register( b1 )
{
	float4x4 tWV: WORLDLAYERVIEW;
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
	float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
	float4 lAmb  <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
	float4 lDiff <bool color=true;String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
	float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
	float lPower <String uiname="Power"; float uimin=3.0;> = 25.0;     	
};


psInputTextured VS_Textured(vsInputTextured input)
{
    psInputTextured output;

    //inverse light direction in view space
    float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);

    //normal in view space
    float3 NormV = normalize(mul(mul(input.normalObject.xyz, (float3x3)tWIT),(float3x3)tV).xyz);
	
    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.posObject, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    float4 spec = lSpec * shades.z;

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

    //inverse light direction in view space
    float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);

    //normal in view space
    float3 NormV = normalize(mul(mul(input.normalObject.xyz, (float3x3)tWIT),(float3x3)tV).xyz);
	
    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.posObject, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    float4 spec = lSpec * shades.z;

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


technique11 GouraudDirectional <string noTexCdFallback="GouraudDirectionalNotexture"; >
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_Textured() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Textured() ) );
	}
}

technique11 GouraudDirectionalNotexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}
