//Sprite size and color
float spritesize <string uiname="Sprite Size";> = 0.01f;
float4 spritecolor <string uiname="Sprite Color"; bool color=true;>;

Texture2D tex <string uiname="Texture";>;

//Camera transforms
float4x4 tVP : VIEWPROJECTION;
float4x4 tIV : VIEWINVERSE;

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
    float4 pos : SV_Position;
    float2 uv : TEXCOORD0;
};

//Quad position/uvs
float3 g_positions[4]: IMMUTABLE =
{
float3( -1, 1, 0 ),
float3( 1, 1, 0 ),
float3( -1, -1, 0 ),
float3( 1, -1, 0 ),
};

float2 g_texcoords[4]: IMMUTABLE = 
{ 
float2(0,1), 
float2(1,1),
float2(0,0),
float2(1,0),
};

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

gsIn VS(vsIn input)
{
	//Here we just pass trough, gs, with expand the point
    gsIn output;
	output.pos = input.pos;
    return output;
}

[maxvertexcount(4)]
void GS(point gsIn input[1], inout TriangleStream<psIn> SpriteStream)
{
    psIn output;
    for(int i=0; i<4; i++)
    {
    	//Get position from quad array
        float3 position = g_positions[i]*spritesize;
    	
    	//Make sure quad will face camera
        position = mul( position, (float3x3)tIV ).xyz + input[0].pos;
    	
    	//Project vertex
        output.pos = mul( float4(position,1.0), tVP );
        output.uv = g_texcoords[i];
        SpriteStream.Append(output);
    }
    SpriteStream.RestartStrip();
}

float4 PS(psIn input) : SV_Target
{   
    return tex.Sample( g_samLinear, input.uv ) * spritecolor;
}


technique10 RenderParticles
{
    pass p0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( CompileShader( gs_4_0, GS() ) );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );     
    }  
}


