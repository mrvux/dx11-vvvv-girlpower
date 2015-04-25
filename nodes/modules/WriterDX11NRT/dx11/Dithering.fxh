
float _dnoise1(float3 u){
	u=dot(u+.2,float3(1,57,21));
	return (u.x*(.1+sin(u.x)));
}
float4 _dnoise4(float2 x,float RandomSeed){
	RandomSeed+=.00001;
	float4 c={
	_dnoise1(float3((x+RandomSeed*13+41)+11,length(sin((x-59)/151+RandomSeed*float2(11,7))))+.5),
	_dnoise1(float3((x+RandomSeed*7+293)+5,length(sin((x+127)/163+RandomSeed*float2(13,5))))+.5),
	_dnoise1(float3((x+RandomSeed*5+113)+7,length(sin((x+191)/173+RandomSeed*float2(7,17))))+.5),
	_dnoise1(float3((x+RandomSeed*11+97)+13,length(sin((x-37)/181+RandomSeed*float2(5,23))))+.5)
	};
	return frac(c+x.x*2+RandomSeed+dot(c,1));
}
float4 NoiseDither(float4 c,float2 x,float RandomSeed=0,float Grain=0,float Levels=256,float LevelNoise=1,float AddNoise=1){
	
	float4 nois=_dnoise4(x,RandomSeed);
	float4 nois2=frac(nois.wxyz*sqrt(251));
	c*=Levels;
	c*=pow(2,Grain*0.1*normalize(nois2.wxyz-.5)*pow(length(nois2.wxyz-.5),4));
	c=floor(c)+nois*(frac(c)-.5)*2*LevelNoise+0.5+(nois2-.5)*(AddNoise);
	c/=Levels;
	return c;
}
