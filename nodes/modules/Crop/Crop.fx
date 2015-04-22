Texture2D tex0 <string uiname="Texture";>;

SamplerState s0 <string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=WRAP;AddressV=WRAP;};


float4x4 tVP:VIEWPROJECTION;
float4x4 tW:WORLD;
float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
float4x4 tTex <string uiname="Texture Transform";>;

struct VS_IN{
	float4 PosO:POSITION;
	float4 TexCd:TEXCOORD0;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 TexCd:TEXCOORD0;
};
float2 R:TARGETSIZE;
float2 Offset <float uimin=-1.0; float uimax=1.0;> =0;
VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	float4 PosW=In.PosO;
	PosW=mul(PosW,tW);
	Out.PosWVP=mul(PosW,tVP);
	//Out.TexCd=mul(In.TexCd,tTex);
	Out.TexCd=In.TexCd;
	//Out.TexCd.xy=mul(float4((In.TexCd.xy*2-1)*float2(1,-1),0,1),tTex).xy*float2(1,-1)*.5+.5;
	int2 SourceSize;
	tex0.GetDimensions(SourceSize.x,SourceSize.y);
	float2 Center=floor(0.5*SourceSize)/SourceSize;
	float2 off=1-R/SourceSize;
	off*=(Offset*0.5*float2(1,-1)+0.5);
	off=floor(off*SourceSize)/SourceSize;
	Out.TexCd.xy=(Out.TexCd.xy)*R/SourceSize+off;
	//(x-off)*k+off;
	//x*k+off-off*k
	//x*k+off*(1-k);
	return Out;
}

float4 PS(VS_OUT In):SV_Target{
	float4 c=tex0.Sample(s0,In.TexCd.xy);
	c=c*Color;
	c.a*=Alpha;
	return c;
}


technique10 Constant{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}




