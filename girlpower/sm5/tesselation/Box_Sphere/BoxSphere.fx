float4x4 tWV: WORLDVIEW ;
float4x4 tWVP: WORLDVIEWPROJECTION ;

float tessfactor <string uiname="Tesselation Factor";> = 1.0f;

float lrp <string uiname="Morph"; float uimin=0.0f;float uimax = 1.0f;> = 0.0f;

struct VS_IN
{
	float3 cpoint : POSITION;
	float3 norm : NORMAL;
};

struct VS_OUTPUT
{
	float3 cpoint : CPOINT;
	float3 norm : NORMAL;
};

VS_OUTPUT VS(VS_IN input)
{
	//Here we simply passtrough the vertex data
    VS_OUTPUT output;
    output.cpoint = input.cpoint;
	output.norm = input.norm;
    return output;
}

struct HS_CONSTANT_OUTPUT
{
    float edges[3]        : SV_TessFactor;
    float inside[1]       : SV_InsideTessFactor;
};

struct HS_OUTPUT
{
    float3 cpoint : CPOINT;
	float3 norm : NORMAL;
};

struct DS_OUTPUT
{
    float4 position : SV_Position;
	float3 normV : TEXCOORD0;
};

HS_CONSTANT_OUTPUT HSConst(InputPatch<VS_OUTPUT, 3> patch)
{
	/*The hull constant function decides how much we want 
	To tesselate the patch. In this case we use static values,
	but it's also possible to compute this factor from other data*/
	
    HS_CONSTANT_OUTPUT output;
    output.edges[0] = tessfactor;
    output.edges[1] = tessfactor;
	output.edges[2] = tessfactor;
	output.inside[0] = tessfactor;
    return output;
}

[domain("tri")] //Indicates we tesselate triangles
[partitioning("fractional_even")]
[outputtopology("triangle_cw")] 
/*Triangles will be generated as clockwise, 
and we use 3 control points */
[outputcontrolpoints(3)]
[patchconstantfunc("HSConst")] /*This is the name of the function 
that will calculate tesselation factors*/
HS_OUTPUT HS(InputPatch<VS_OUTPUT, 3> ip, uint id : SV_OutputControlPointID)
{
	//Here we just pass trough the input patch control points,
	//We could modify it here, but it is not needed in our case
    HS_OUTPUT output;
    output.cpoint = ip[id].cpoint;
	output.norm = ip[id].norm;
    return output;
}

[domain("tri")]
DS_OUTPUT DS(HS_CONSTANT_OUTPUT input, OutputPatch<HS_OUTPUT, 3> op, float3 uv : SV_DomainLocation)
{
	/*Here we receive tesselated vertices, we receive float3 uv : SV_DomainLocation ,
	which are barycentric coordinates, and OutputPatch<HS_OUTPUT, 3> op, which is the original triangle*/
	
    DS_OUTPUT output;
	
	//Compute position from barycentric coordinates
	float3 p = uv.x * op[0].cpoint 
        + uv.y * op[1].cpoint 
        + uv.z * op[2].cpoint;
	
	float3 n= uv.x * op[0].norm
        + uv.y * op[1].norm
        + uv.z * op[2].norm;
	
	//to morph our object to sphere, we simply need to normalize position
	n = normalize(n);
	float3 p2 = normalize(p);
	
	//Add a progressive morphing between box and sphere
	p = lerp(p,p2,lrp);

	//Transform normals in view space, and position in screen space
	output.normV = mul(float4(lerp(n,p2,lrp),0.0f),tWV);	
    output.position =  mul(float4(p.xyz,1), tWVP);
    return output;
}

float4 PS(DS_OUTPUT input) : SV_Target0
{
	//Output normals in friendly display mode
    return float4(normalize(input.normV)*0.5f+0.5f,1.0f);
}

technique11 Tess
{
	pass P0
	{
		SetHullShader( CompileShader( hs_5_0, HS() ) );
		SetDomainShader( CompileShader( ds_5_0, DS() ) );
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}




