float4x4 tVP: VIEWPROJECTION;
float4x4 tV : VIEW;

struct vsIn
{
	float4 pos : POSITION;
};

struct gsIn
{
	float4 pos : POSITION;
};

struct psIn
{
    float4 pos : SV_POSITION;
	float3 nv : TEXCOORD0;
}; 


gsIn VS(vsIn input)
{
    gsIn res = (gsIn)0;
    res.pos = input.pos;
    return res;
}

//Tube extrusion, we could use sin/cos and have dynamic
float3 g_positions[7] : IMMUTABLE =
{
	float3( 1.0f, 0.0f,    0 ),
    float3( 0.5f, 0.866f,  0 ),
    float3( -0.5f, 0.866f, 0 ),
    float3( -1.0f, 0.0f,   0 ),
    float3( -0.5, -0.866f, 0 ),
    float3( 0.5, -0.866f,  0 ),
    float3( 1.0f, 0.0f,    0 ),
};

float Radius = 0.5f;
float mindist = 0;
float maxdist = 5;

void AppendPoint( float3x3 m, float3 inpos, int i, inout TriangleStream<psIn> gsout )
{
    psIn output;

    float fRad = Radius;
    float3 pos = g_positions[i].xyz * fRad;
    float3 norm = normalize(pos);
    pos += inpos;
    output.pos = mul(float4(pos,1),tVP);
	output.nv = mul(float4(norm,0),tV).xyz;
    gsout.Append(output);
}

void AppendLine(float3 p1,float3 p2,inout TriangleStream<psIn> gsout)
{
	float3 n = float3(0,0,-1);
	float3 n2 = -n;
	float3 d1 = p2 -p1;
	float3 d2 = p1 -p2;
	
	float3 left0 = cross( d1, n);
    float3x3 m0 = float3x3( -left0, n, d1);
    float3 left1 = cross( d2, n2 );
    float3x3 m1 = float3x3( -left1, n2, d2 );

    for(int i=0; i<7; i++)
    {
    	AppendPoint( m0, p1, i,gsout );
        AppendPoint( m1, p2, i,gsout );
    }
    gsout.RestartStrip();
}

[maxvertexcount(30)]
void GS(triangle gsIn input[3], inout TriangleStream<psIn> gsout)
{
	float3 p1 = input[0].pos.xyz;
	float3 p2 = input[1].pos.xyz;
	float3 p3 = input[2].pos.xyz;
	
	//Calculate distance for each edge, and extrude to mim cylinder if applicable
	float d = distance(p1,p2);	
	if (d > mindist && d < maxdist)
	{
		AppendLine(p1,p2,gsout);
	}
	
	d = distance(p2,p3);	
	if (d > mindist && d < maxdist)
	{
		AppendLine(p2,p3,gsout);
	}
	
	d = distance(p3,p1);	
	if (d > mindist && d < maxdist)
	{
		AppendLine(p3,p1,gsout);
	}
	
}

float4 PS(psIn input): SV_Target
{
	//Friendly Normals visualize
   return float4(normalize(input.nv)*0.5f+0.5f,1.0f);
}



technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetGeometryShader( CompileShader( gs_4_0, GS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}



