TextureCube tex0 <string uiname="Texture Cube";>;

SamplerState s0:IMMUTABLE
{Filter=MIN_MAG_MIP_LINEAR;AddressU=CLAMP;AddressV=CLAMP;};

cbuffer cbControls:register(b0){
	float4x4 tW:WORLD;
	float4x4 tV:VIEW;
	float4x4 tP:PROJECTION;
	float4x4 tVI:VIEWINVERSE;
	float4x4 tPI:PROJECTIONINVERSE;
	float4x4 tWIT:WORLDINVERSETRANSPOSE;
	
	//float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 Color <bool color=true;> = {1.0,1.0,1.0,1.0};
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
};

struct VS_IN{
	float4 PosO:POSITION;
	float3 Norm:NORMAL0;
};

struct VS_OUT{
	float4 PosWVP:SV_POSITION;
	float4 PosW:TEXCOORD1;
	float3 Norm:NORMAL0;
};

VS_OUT VS(VS_IN In){
	VS_OUT Out=(VS_OUT)0;
	float4 PosW=In.PosO;
	PosW=mul(PosW,tW);
	Out.PosW=PosW;
	Out.Norm=mul(In.Norm,(float3x3)tWIT);
	Out.PosWVP=mul(PosW,mul(tV,tP));
	return Out;
}


float4 psREFLECTION(VS_OUT In):SV_Target{
	float3 View=normalize(In.PosW.xyz-tVI[3].xyz);
	float3 uvw=normalize(reflect(View,normalize(In.Norm)));
	uvw=mul(float4(uvw,1),tTex).xyz;
	float4 c=tex0.Sample(s0,uvw);
	c=mul(c*Color,tColor);
	return c;
}
float4 psNORMAL(VS_OUT In):SV_Target{
	float3 uvw=In.Norm;
	uvw=mul(float4(uvw,1),tTex).xyz;
	float4 c=tex0.Sample(s0,uvw);
	c=mul(c*Color,tColor);
	return c;
}
float4 psSKY(VS_OUT In):SV_Target{
	float3 View=normalize(In.PosW.xyz-tVI[3].xyz);
	float3 uvw=View;
	uvw=mul(float4(uvw,1),tTex).xyz;
	float4 c=tex0.Sample(s0,uvw);
	c=mul(c*Color,tColor);
	return c;
}


technique10 _Reflection{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,psREFLECTION()));
	}
}
technique10 _Normal{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,psNORMAL()));
	}
}
technique10 _Sky{
	pass P0{
		SetVertexShader(CompileShader(vs_4_0,VS()));
		SetPixelShader(CompileShader(ps_4_0,psSKY()));
	}
}


