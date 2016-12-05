Texture2D tex0 <string uiname="Texture";>;
SamplerState s0 <string uiname="Sampler State";>
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

float4x4 tWVP:WORLDVIEWPROJECTION;
float4x4 tWV:WORLDVIEW;
float4x4 tW:WORLD;

float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
float4x4 tTex <string uiname="Texture Transform";>;
float4x4 tColor <string uiname="Color Transform";>;

struct VS_IN{
	float4 PosO:POSITION;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 TexCd:TEXCOORD0;
};

VS_OUT vsOBJECT(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	Out.PosWVP=mul(In.PosO,tWVP);
	Out.TexCd=mul(In.PosO,tTex);
	return Out;
}
VS_OUT vsWORLD(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	Out.PosWVP=mul(In.PosO,tWVP);
	Out.TexCd=mul(In.PosO,mul(tW,tTex));
	return Out;
}
VS_OUT vsVIEW(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	Out.PosWVP=mul(In.PosO,tWVP);
	Out.TexCd=mul(In.PosO,mul(tWV,tTex));
	return Out;
}
VS_OUT vsPROJ(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	Out.PosWVP=mul(In.PosO,tWVP);
	Out.TexCd=mul(In.PosO,mul(tWVP,tTex));
	return Out;
}

bool DoubleScale=0;
float4 psPROJ(VS_OUT In):SV_Target{
	
	if(DoubleScale)In.TexCd.xy*=0.5;
	In.TexCd.xy=In.TexCd.xy/In.TexCd.w*float2(1,-1)+0.5;
	
	float4 c=tex0.Sample(s0,In.TexCd.xy);
	c=c*Color;
	c=mul(c,tColor);
	c.a*=Alpha;
	return c;
}

technique10 Object{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,vsOBJECT()));
		SetPixelShader(CompileShader(ps_4_0,psPROJ()));
	}
}
technique10 World{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,vsWORLD()));
		SetPixelShader(CompileShader(ps_4_0,psPROJ()));
	}
}
technique10 View{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,vsVIEW()));
		SetPixelShader(CompileShader(ps_4_0,psPROJ()));
	}
}
technique10 Projection{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,vsPROJ()));
		SetPixelShader(CompileShader(ps_4_0,psPROJ()));
	}
}

