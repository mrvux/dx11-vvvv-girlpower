Texture2D tex0 <string uiname="Texture";>;

SamplerState s0 <bool visible=false;string uiname="Sampler";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=WRAP;AddressV=WRAP;};

float4x4 tVP:VIEWPROJECTION;
float4x4 tW:WORLD;


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
	Out.PosWVP=float4(In.PosO.xy*2,0,1);
	Out.TexCd=In.TexCd;
	return Out;
}
float2 R:TARGETSIZE;
float Threshold=0.5;

bool thr(float4 c){
	return c.x>Threshold;
}
float4 PS(VS_OUT In):SV_Target{
	float2 uv=In.TexCd.xy;
	float4 c=tex0.SampleLevel(s0,uv,0);
	bool t0=thr(c);
	//return t0;
	bool cut=0;
	for (int i=-1;i<=1;i++){
		for (int j=-1;j<=1;j++){
			float4 cn=tex0.SampleLevel(s0,uv+float2(i,j)/R,0);
			if(thr(cn)!=t0){return float4(t0,t0,0,1);}
		}
	}
	
	return float4(t0,t0*cut,0,1);
}


technique10 Constant{
	pass P0{
		SetVertexShader(CompileShader(vs_5_0,VS()));
		SetPixelShader(CompileShader(ps_5_0,PS()));
	}
}




