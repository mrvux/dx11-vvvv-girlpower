float sdSphere( float3 p, float s )
{
  return length(p)-s;
}

float sdBox( float3 p, float3 b )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

float3 InvVolumeSize : INVTARGETSIZE;

float3 sphere1;
float3 sphere2;
float3 box1;


[numthreads(16, 16, 4)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	float3 p = i;
	p *= InvVolumeSize;
	p -= 0.5f;
	
	//Do a simple distance field
	float d = sdSphere(p+sphere1,0.2f);
	float d2 = sdSphere(p+sphere2,0.25f);
	float db = sdBox(p+box1,0.1f);
	
	RWDistanceVolume[i] = min(min(d,db),d2);
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







