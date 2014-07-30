StructuredBuffer<float3> sbPos;

float4x4 tVP:VIEWPROJECTION;
float4x4 tV:VIEW;
float4x4 tVI:VIEWINVERSE;
float4x4 tP:PROJECTION;
float4x4 tW:WORLD;
float Size <float uimin=0.0;> =1;

struct VS_IN{
	uint iv:SV_VertexID;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 TexCd:TEXCOORD0;
	uint iv:TEXCOORD1;
};
int Count=1;
int IndexOffset=0;
VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	uint idx=In.iv+IndexOffset*Count;
	float4 PosW=mul(float4(sbPos[idx].xyz,1),tW);
	Out.PosWVP=PosW;
	Out.TexCd=0;
	Out.iv=idx;
	return Out;
}
float3 g_positions[4]:IMMUTABLE ={float3( -1, 1, 0 ),float3( 1, 1, 0 ),float3( -1, -1, 0 ),float3( 1, -1, 0 )};
float2 g_texcoords[4]:IMMUTABLE ={float2(0,1), float2(1,1),float2(0,0),float2(1,0)};
float2 aspect=1;
[maxvertexcount(4)]
void GS(point VS_OUT In[1], inout TriangleStream<VS_OUT> GSOut){
	if(In[0].PosWVP.z==0)return;
	VS_OUT Out=In[0];
	float3 p=float3(In[0].PosWVP.xy,0);
	for(int i=0;i<4;i++){
		float3 sp=g_positions[i]*Size*0.5;
		//sp.xy/=aspect;
		Out.TexCd=float4(sp.xy,g_texcoords[i]);
		Out.PosWVP = mul(float4(sp/float3(aspect,1)+p,1.0),tVP);  
		GSOut.Append(Out);
	}
	GSOut.RestartStrip();
}

float4 PS(VS_OUT In):SV_Target{
	if(length(In.TexCd.zw-.5)>.5)discard;
	return length(In.TexCd.xy)*2;
}

technique10 Sprite{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetGeometryShader(CompileShader(gs_4_0,GS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}


