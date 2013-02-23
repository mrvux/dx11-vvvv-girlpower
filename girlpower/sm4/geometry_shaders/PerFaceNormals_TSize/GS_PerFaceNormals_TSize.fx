float4x4 tW : WORLD;
float4x4 tVP : VIEWPROJECTION;
float4x4 tWVP : WORLDVIEWPROJECTION;
float4x4 tWV : WORLDVIEW;

float minsize = 0.5f;

struct vsin
{
	float4 pos : POSITION;
	float3 norm : NORMAL;
};

struct vs2gs
{
    float4 pos : POSITION;
	float3 norm : NORMAL;
};

struct psIn
{
    float4 pos: SV_POSITION;
    float4 norm : COLOR0;
};

vs2gs VS(vsin input)
{
	//Passtrough in that case, since we will process in gs
	vs2gs output;
	//We want world space in that case, for triangle size
	output.pos = mul(input.pos,tW);
	output.norm = input.norm;
    return output;
}


[maxvertexcount(3)]
void GS(triangle vs2gs input[3], inout TriangleStream<psIn> gsout)
{
	psIn o;
	
	//Get triangle face direction
	float3 f1 = input[1].pos.xyz - input[0].pos.xyz;
    float3 f2 = input[2].pos.xyz - input[0].pos.xyz;
    
	//Compute flat normal
	float3 norm = cross(f1, f2);
	
	//Cross product depends on area
	float v = dot(norm,norm);
	
	norm = normalize(norm);
	
	for (int i = 0; i < 3; i++)
	{
		/*Here we do a hard switch, please note we 
		could also blend between both normals */
		
		float3 n = v > minsize ? norm : input[i].norm;
		
		//Convert into view space
		float3 normv = mul(float4(n,0),tWV).xyz;
		normv = normalize(normv);
		
		o.norm = float4(normalize(normv),1);
		o.pos = mul(input[i].pos,tVP);
		gsout.Append(o);
	}
	
	gsout.RestartStrip();
}

float4 PS(psIn input): SV_Target
{
	/*Set normals range form -1 to 1 to 0 -> 1
	for friendly display */
    return float4(input.norm.xyz*0.5+0.5,1);
}


technique10 Render
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}





