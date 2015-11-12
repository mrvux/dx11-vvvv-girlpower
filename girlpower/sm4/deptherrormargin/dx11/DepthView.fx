Texture2D texture2d; 
 

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb : COLOR = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;

};

float4x4 tP;

struct VS_IN
{
	float4 PosO : POSITION;
	float2 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float2 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //position (projected)
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = input.TexCd;// mul(input.TexCd, tTex);
    return Out;
}

float3 cz(float2 positionScreen,
                                float viewSpaceZ)
{
    float2 screenSpaceRay = float2(positionScreen.x / tP._11,
                                   positionScreen.y / tP._22);
    
    float3 positionView;
    positionView.z = viewSpaceZ;
    positionView.xy = screenSpaceRay.xy * positionView.z;
    
    return positionView;
}


float4 PS_Tex(vs2ps In): SV_Target
{
	float2 ss = In.TexCd;
	ss *= 2.0f;
	ss -= 1.0f;
	ss.y *= -1.0f;
    float d = texture2d.Sample( g_samLinear, In.TexCd);
	
	float ld = tP._43 / (d - tP._33);
	if (ld > 200.0f) { return 0; }
	
	float3 p = cz(ss,ld);
    return float4(p,1.0f);
}




technique10 Constant
{
	pass P0
	{
		SetHullShader( 0 );
		SetDomainShader( 0 );
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}



