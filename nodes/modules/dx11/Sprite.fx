
StructuredBuffer<float3> sbPos;
StructuredBuffer<float> sbSize;
StructuredBuffer<float4> sbColor;
StructuredBuffer<float4x4> sbTexTransform;
int sbSizeCount=1;
int sbColorCount=1;
int sbTexTransformCount=1;

Texture2D tex0 <string uiname="Texture";>;

SamplerState s0 <string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

cbuffer cbControls:register(b0){
	float4x4 tVP:VIEWPROJECTION;
	float4x4 tV:VIEW;
	float4x4 tVI:VIEWINVERSE;
	float4x4 tP:PROJECTION;
	float4x4 tW:WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
	float4x4 tTex <string uiname="Texture Transform";>;
	float Size <float uimin=0.0;> =1;
	float3 UpVector={0,1,0};
	float4x4 tSprite;
};



struct VS_IN{
	uint iv:SV_VertexID;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float2 TexCd:TEXCOORD0;
	float4 PosW:TEXCOORD1;
	float Size:TEXCOORD2;
	uint iv:TEXCOORD3;
	float4 Color:COLOR0;
	
};

VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	
	float3 p=sbPos[In.iv];
	
	float4 PosW=mul(float4(p,1),tW);
	Out.PosW=PosW;
	Out.PosWVP=mul(PosW,tVP);
	Out.TexCd=0;
	Out.Size=Size*sbSize[In.iv%sbSizeCount];
	Out.Color=Color*sbColor[In.iv%sbColorCount];
	Out.iv=In.iv;
	return Out;
}
float3 g_positions[4]:IMMUTABLE ={{-1,1,0},{1,1,0},{-1,-1,0},{1,-1,0}};
float2 g_texcoords[4]:IMMUTABLE ={{0,0},{1,0},{0,1},{1,1}};
[maxvertexcount(4)]
void gsSPRITE(point VS_OUT In[1], inout TriangleStream<VS_OUT> SpriteStream)
{
    VS_OUT Out=In[0];
	float4x4 tTex=sbTexTransform[In[0].iv%sbTexTransformCount];
	for(int i=0;i<4;i++){
		//Out.TexCd=g_texcoords[i];
		Out.TexCd=mul(float4((g_texcoords[i].xy*2-1)*float2(1,-1),0,1),tTex).xy*float2(1,-1)*.5+.5;

		Out.PosWVP=mul(float4(In[0].PosW.xyz+In[0].Size*mul(mul(float4(g_positions[i].xyz,1),tSprite).xyz,(float3x3)tVI),1),tVP);
		SpriteStream.Append(Out);
	}

}

float3x3 lookat(float3 dir,float3 up=float3(0,1,0)){float3 z=normalize(dir);float3 x=normalize(cross(up,z));float3 y=normalize(cross(z,x));return float3x3(x,y,z);} 

[maxvertexcount(4)]
void gsBILLBOARD(point VS_OUT In[1], inout TriangleStream<VS_OUT> SpriteStream,uniform bool axis=0)
{
    VS_OUT Out=In[0];
	float3 vUp=normalize(float3(1,0,1));
	vUp=UpVector;

	float3 View=normalize((In[0].PosW.xyz-tVI[3].xyz));
	
	if(axis){
		float3x3 lktup=lookat(vUp+.000001);
		View=mul(View,transpose(lktup));
		View.z=0;
		View=mul(View,(lktup));
	}
	
	float3x3 lkt=lookat(View,vUp);
	float4x4 tTex=sbTexTransform[In[0].iv%sbTexTransformCount];
	for(int i=0;i<4;i++){
		//Out.TexCd=g_texcoords[i];
		Out.TexCd=mul(float4((g_texcoords[i].xy*2-1)*float2(1,-1),0,1),tTex).xy*float2(1,-1)*.5+.5;

		Out.PosWVP=mul(float4(In[0].PosW.xyz+In[0].Size*mul(mul(float4(g_positions[i].xyz,1),tSprite).xyz,lkt),1),tVP);
		SpriteStream.Append(Out);
	}

}

[maxvertexcount(1)]
void gsPOINT(point VS_OUT In[1], inout PointStream<VS_OUT>GSOut)
{
	VS_OUT Out;	
	Out=In[0];
	//Out.TexCd=mul(float4(0.5,0.5,0,1),tTex).xy;
	float4x4 tTex=sbTexTransform[In[0].iv%sbTexTransformCount];
	Out.TexCd=mul(float4(0.5,0.5,0,1),tTex).xy*float2(1,-1)*.5+.5;

	GSOut.Append(Out);
}
float4 PS(VS_OUT In):SV_Target{
	float4 c=tex0.SampleLevel(s0,In.TexCd.xy,0);
	c=c*In.Color;
	c.a*=Alpha;
	return c;
}

technique10 Sprite{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetGeometryShader(CompileShader(gs_4_0,gsSPRITE()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}
technique10 Billboard{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetGeometryShader(CompileShader(gs_4_0,gsBILLBOARD()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}
technique10 BillboardAxis{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetGeometryShader(CompileShader(gs_4_0,gsBILLBOARD(1)));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}
technique10 Point{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetGeometryShader(CompileShader(gs_4_0,gsPOINT()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}



