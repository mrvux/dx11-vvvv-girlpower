//@author: gregsn
//@help: standard line shader
//@tags: 
//@credits: 

Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tWVP : WORLDVIEWPROJECTION;
	float4x4 tP : PROJECTION;
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float3 Point1 = {-0.5, 0, 0};
	float3 Point2 = { 0.5, 0, 0};
	float Width = 0.01;
};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    float w = Width * 0.003;

    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    
    float u= input.PosO.x+0.5;
    //Out.uv = float2(u, Pos.y*2);
    
    // get point on curve
    float4 p;
    //p = float4(lerp(Point1, Point2, u), 1);

    // get position in projection space
    //p = mul(p, tWVP);

    // get tangent in projection space
    float4 p1 = mul(float4(Point1, 1), tWVP);
    float4 p2 = mul(float4(Point2, 1), tWVP);

    p = lerp(p1, p2, u);

    p1 /= p1.w;
    p2 /= p2.w;
    float4 tangent = p2 - p1;

    //p = lerp(p1, p2, u);

    // get normal in projection space
    float2 normal = normalize(float2(tangent.y, -tangent.x));

    // translate point to get a thick curve
    float2 off = input.PosO.y * normal * w * p.w;

    // correct aspect ratio
    off *= mul(float4(1, 1, 0, 0), tP);

    p+= float4(off, 0, 0);

    //tangent = normalize(tangent);
    //float3 normal = cross(tangent, float3(0,0,1));
    //p += Pos.y * float4(normal, 0) * w * p.w;

    // output pos p
    Out.PosP = p; input.PosO;

    input.TexCd.x *= .1 * length(tangent) / w;

    //ouput texturecoordinates
    Out.TexCd = mul(input.TexCd, tTex);

    return Out;
}


// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear, In.TexCd.xy) * cAmb;
    //col.a *= 1 - pow(abs(In.uv.y), 4);
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique10 TLine
{
    pass P0
    {
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}
