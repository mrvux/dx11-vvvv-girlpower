//Texture2D tex0 <string uiname="Texture";>;
//TextureCube texENVI <string uiname="Cubemap Texture";>;
Texture2D texSPHERE <string uiname="SphereMap Texture";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};


float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
float4x4 tTex <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

float2 r2d(float2 x,float a){a*=acos(-1)*2;return float2(cos(a)*x.x+sin(a)*x.y,cos(a)*x.y-sin(a)*x.x);}

float SphereFactor <float uimin=0.0;float uimax=1.0;> =1.0;
bool ClipBorder=0;

float2 XYZtoUV(float3 p){p=normalize(p);
	return float2(atan2(p.x,-p.z)/acos(-1)*.5+.5,asin(-p.y)/acos(-1)+.5);
}

float4 PS(float2 UV:TEXCOORD0,float4 PosWVP:SV_POSITION):SV_Target{

	float3 p=float3(0,0,-1);
	p.xz=r2d(p.xz,saturate(length(UV.xy-.5)*2)*.5*SphereFactor);
	p.xy=r2d(p.xy,-atan2(UV.y-.5,-(UV.x-.5))/acos(-1)/2);
	p=mul(float4(p,1),tTex).xyz;
	
	
	
	//float2 uv=normalize(p.xy)*(acos(p.z)/acos(-1))*0.5+0.5;
	float2 uv=XYZtoUV(p);
	float4 c=texSPHERE.SampleLevel(s0,uv.xy,0);

	c=mul(c*Color,tColor);
	if(ClipBorder&&length(UV.xy-.5)>.51)c=0;
	return c;
}


void VS(in float4 PosO:POSITION,inout float4 TexCd:TEXCOORD0,out float4 PosWVP:SV_POSITION){PosWVP=float4((PosO.xy)*2,0,1);/*TexCd=mul(TexCd,tTex);*/}

technique10 _PanoToSphere{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,PS()));
	}
}




