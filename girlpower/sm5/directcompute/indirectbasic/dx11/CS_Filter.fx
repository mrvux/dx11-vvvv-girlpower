
StructuredBuffer<float3> sbPosition;
int elementcount;

float miny = 0.0f;

/*This is the buffer from the renderer
Renderer automatically assigns BACKBUFFER semantic
Please note we mark the buffer as append here */
AppendStructuredBuffer<float3> AppendPositionBuffer : BACKBUFFER;


[numthreads(32, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	//Safeguard if we don't use a multiple
	if (i.x >=  elementcount) { return;}
	
	float3 p = sbPosition[i.x];
	
	//Add our element to the buffer only if it's over minimum height
	if(p.y > miny)
	{
		//Append will push the element into the buffer and
		//Increment internal counter by 1
		AppendPositionBuffer.Append(p);
	}
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







