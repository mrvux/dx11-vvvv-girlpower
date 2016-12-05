Texture2D tex0 <string uiname="Texture";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

float4x4 tVP:VIEWPROJECTION;
float4x4 tW:WORLD;

float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
float4x4 tTex <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;


struct VS_IN{
	float4 PosO:POSITION;
	float4 TexCd:TEXCOORD0;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 TexCd:TEXCOORD0;
};

VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	float4 PosW=In.PosO;
	PosW=mul(PosW,tW);
	Out.PosWVP=mul(PosW,tVP);
	Out.TexCd=mul(In.TexCd,tTex);
	return Out;
}


float2 R:TARGETSIZE;

float RandomSeed=0;
int Levels <bool visible=false;float uimin=1.0;> = 256;
float Gamma <float uimin=0.0;> = 1;
float Grain <float uimin=0.0;> = 1;
bool DoDither=1;

#include "dithering.fxh"

float4 _dither(float4 c,float2 x,float RandomSeed=0,float Levels=255,float AddNoise=1,float Grain=0){
	float4 nois=_dnoise4(x,RandomSeed);
	float4 nois2=_dnoise4(x,RandomSeed+.7);
	c*=Levels;
	c+=(nois-.5)*AddNoise;
	c*=pow(2,Grain*0.1*normalize(nois2.wxyz-.5)*pow(length(nois2.wxyz-.5),4));
	c/=Levels;
	return c;
}
bool Uniform=0;
float4 PS(VS_OUT In):SV_Target{
	float4 c=tex0.Sample(s0,In.TexCd.xy)*Color;
	c=mul(c,tColor);
	c=pow(max(0,c),Gamma);
    //if(DoDither)c=NoiseDither(c,In.TexCd.xy*R,RandomSeed,Grain,Levels);
	if(DoDither)if(!Uniform){c=NoiseDither(c,In.TexCd.xy*R,RandomSeed,Grain,Levels);}
	else{c=_dither(c,In.TexCd.xy*R,RandomSeed,Levels,1,Grain);}
	return c;
}


technique10 Constant{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}




