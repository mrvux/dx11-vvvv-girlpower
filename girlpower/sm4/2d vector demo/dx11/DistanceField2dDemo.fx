//@author: gregsn
//@help: 2d distance field demo
//@tags: distanceField
//@credits: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
 
#include "DistanceField2d.fxh" 

Texture2D IndexRangeForCell;
SamplerState g_samPoint
{
	Filter = MIN_MAG_MIP_POINT;
};

StructuredBuffer<int> LineIndices;
StructuredBuffer<float2> As;
StructuredBuffer<float2> Bs;

float LineWidth = 0.02;
float OutlineWidth = 0.005;

float4 cAmb <String uiname="Color"; bool color=true;> = { 1.0f,1.0f,1.0f,1.0f };

struct vs2ps
{
    float4 Pos : SV_POSITION;
    float2 TexCd : TEXCOORD0;
};

vs2ps VS(
    float4 Pos : POSITION,
    float2 TexCd : TEXCOORD0)
{
    vs2ps Out = (vs2ps)0;
	Pos.xy *= 2;
    Out.Pos = Pos;
    Out.TexCd = TexCd;
    return Out;
}

float4 PS(vs2ps In): SV_Target
{
	float2 samplePos = In.TexCd;

	int2 cellRange = IndexRangeForCell.Sample(g_samPoint, samplePos).rg;
	float shape = 999;		
		
	int lineIndex = 0;
	for (int i = cellRange.x; i < cellRange.y; i++)
	{
		lineIndex = LineIndices[i];
		float l = Line(As[lineIndex], Bs[lineIndex], LineWidth, samplePos);		
		shape = Union(shape, l);	
	}
			
	float a = ToAlpha(Outline(shape, OutlineWidth)) + ToAlpha(shape)*0.5;
	
	//return float4(0, 0, lineIndex/400.0, 1); 	
	return cAmb * a;
}


technique10 TShape1 
{
    pass P0
    {
        VertexShader = compile vs_4_0 VS();
        PixelShader = compile ps_4_0 PS();
    }
}