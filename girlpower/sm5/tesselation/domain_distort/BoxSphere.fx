#include "rotation3d.fxh"

float4x4 tW: WORLD ;        //the models world matrix
float4x4 tV: VIEW ;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW ;
float4x4 tWVP: WORLDVIEWPROJECTION ;
float4x4 tP: PROJECTION ;   //projection matrix as set via Renderer (EX9)
float4x4 tVP : VIEWPROJECTION;
float4 edges;
float2 inside;

Texture2D tex;

SamplerState sam : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

float lrp = 0;
float ymin;
float ymax;

struct VS_IN
{
	float3 cpoint : POSITION;
	float3 norm : NORMAL;
	float2 uv : TEXCOORD0;
	uint iv : SV_VertexID;
};

struct VS_OUTPUT
{
	float3 cpoint : CPOINT;
	float3 norm : NORMAL;
	float2 uv : TEXCOORD0;
};

struct PS_OUT
{
	float4 color : SV_Target0;
	float4 ns : SV_Target1;
};

// -----------------------------------------------------------------------------
// VERTEX SHADER:
// -----------------------------------------------------------------------------


VS_OUTPUT VS(VS_IN input)
{
    VS_OUTPUT output;
	//float4 posV = mul(float4(input.cpoint,1), tWV);
	
    output.cpoint = input.cpoint;
	
	//float3 normw = texnorm.SampleLevel(sam,input.uv,0);
	
	output.norm = input.norm;// + (normw *ns);
	output.uv = input.uv;
    return output;
}

// -----------------------------------------------------------------------------
// HULL SHADER:
// -----------------------------------------------------------------------------

//The patch constant function (HSConst below) is executed once per patch (a cubic curve in our case). Recall that the patch constant function must at least output tessellation factors. The control point function (HS below) is executed once per output control point. In our case, we just pass the control points through unmodified.

struct HS_CONSTANT_OUTPUT
{
    float edges[3]        : SV_TessFactor;
    float inside[1]       : SV_InsideTessFactor;
};

struct HS_OUTPUT
{
    float3 cpoint : CPOINT;
	float3 norm : NORMAL;
	float2 uv : TEXCOORD0;	
};

HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> patch)
{
    HS_CONSTANT_OUTPUT output;
	

    output.edges[0] = edges.x;
    output.edges[1] =edges.y;
	output.edges[2] = edges.z;
	output.inside[0] =inside.x;
	
    return output;
}

[domain("tri")]
[partitioning("fractional_even")]
[outputtopology("triangle_cw")]
[outputcontrolpoints(3)]
[patchconstantfunc("HSConst")]
HS_OUTPUT HS_I(InputPatch<VS_OUTPUT, 3> ip, uint id : SV_OutputControlPointID)
{
    HS_OUTPUT output;
    output.cpoint = ip[id].cpoint;
	output.norm = ip[id].norm;
	output.uv = ip[id].uv;
    return output;
}

// -----------------------------------------------------------------------------
// DOMAIN SHADER:
// -----------------------------------------------------------------------------


//Note that up until now, we have not used the cubic Bézier curve parametric function. The domain shader is where we use this function to compute the final position of the tessellated vertices.

struct DS_OUTPUT
{
    float4 position : SV_Position;
	float2 uv : TEXCOORD0;
	float3 normV : TEXCOORD1;
};

float sl = 1.0f;

[domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> op, float3 uv : SV_DomainLocation)
{
    DS_OUTPUT output;
	
	float3 p = uv.x * op[0].cpoint 
        + uv.y * op[1].cpoint 
        + uv.z * op[2].cpoint;
	
	float3 n= uv.x * op[0].norm
        + uv.y * op[1].norm
        + uv.z * op[2].norm;
	
	float3 pc = p + 0.5f;
	
	float2 uvt = op[0].uv * uv.x + 
	op[1].uv * uv.y + op[2].uv * uv.z;
	
	p = rCZ(p,p.y* lrp,float3(0,0,0));
	p.xz = lerp(pc.xz * pc.y, pc.xz, sl);
	n = rCZ(n,p.y* lrp,float3(0,0,0));

	output.normV = mul(float4(n,0.0f),tWV).xyz;
	
    output.position =  mul(float4(p.xyz,1), tWVP);
	output.uv = p.xy;
	
    return output;
}

[domain("tri")]
DS_OUTPUT DSW(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> op, float3 uv : SV_DomainLocation)
{
    DS_OUTPUT output;
	
	float3 p = uv.x * op[0].cpoint 
        + uv.y * op[1].cpoint 
        + uv.z * op[2].cpoint;
	
	float3 n= uv.x * op[0].norm
        + uv.y * op[1].norm
        + uv.z * op[2].norm;
	
	float2 uvt = op[0].uv * uv.x + 
	op[1].uv * uv.z + op[2].uv * uv.y;

	p = mul(float4(p,1.0f),tW).xyz;
	n = mul(float4(n,1.0f),tW).xyz;
	
	float y= p.y;
	float factor = (y - ymin) / (ymax - ymin);
	
	

	p = rCZ(p,y* lrp*factor,float3(0,0,0));
	n = rCZ(n,y* lrp*factor,float3(0,0,0));

	output.normV = mul(float4(n,0.0f),tV).xyz;
	
    output.position =  mul(float4(p.xyz,1), tVP);
	output.uv = p.xy;
	
    return output;
}

float time;

[domain("tri")]
DS_OUTPUT DSV(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> op, float3 uv : SV_DomainLocation)
{
    DS_OUTPUT output;
	
	float3 p = uv.x * op[0].cpoint 
        + uv.y * op[1].cpoint 
        + uv.z * op[2].cpoint;
	
	float3 n= uv.x * op[0].norm
        + uv.y * op[1].norm
        + uv.z * op[2].norm;
	
	float2 uvt = op[0].uv * uv.x + 
	op[1].uv * uv.z + op[2].uv * uv.y;

	p = mul(float4(p,1.0f),tWV).xyz;
	n = mul(float4(n,0.0f),tWV).xyz;
	
	float y= abs(p.y);
	//float y=-abs(p.z);
	float factor = (y - ymin) / (ymax - ymin);
	factor = factor;

	p = rCZ(p,y* lrp*factor,float3(0,0,0));
	n = rCZ(n,y* lrp*factor,float3(0,0,0));

	output.normV = n;//mul(float4(n,0.0f),tP).xyz;
	
    output.position =  mul(float4(p.xyz,1), tP);
	output.uv = p.xy;
	
    return output;
}


float4 PS(DS_OUTPUT input) : SV_Target
{
    return float4(normalize(input.normV) * 0.5f +0.5f,1.0f);
}

technique11 Tess
{
	pass P0
	{
		SetHullShader( CompileShader( hs_5_0, HS_I() ) );
		SetDomainShader( CompileShader( ds_5_0, DS() ) );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}


technique11 TessWorld
{
	pass P0
	{
		SetHullShader( CompileShader( hs_5_0, HS_I() ) );
		SetDomainShader( CompileShader( ds_5_0, DSW() ) );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}


technique11 TessView
{
	pass P0
	{
		SetHullShader( CompileShader( hs_5_0, HS_I() ) );
		SetDomainShader( CompileShader( ds_5_0, DSV() ) );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}







