uniform float ThresoldDiffBetweenPixels<
	ui_type="slider";
	ui_min=0;ui_max=3;
> =0,
			NonSquare<
	ui_type="slider";
	ui_min=0;ui_max=1;
> =0.005;
uniform int DiamondSizeV<
	ui_type="slider";
	ui_min=1;ui_max=128;
> =1,
			CyCles<
	ui_type="slider";
	ui_min=1;ui_max=512;
> =128;
#include "ReShade.fxh"
texture TargetMask{Width=BUFFER_WIDTH;Height=BUFFER_HEIGHT;Format=RGBA16;},
		TargetPS1 {Width=BUFFER_WIDTH;Height=BUFFER_HEIGHT;Format=RGBA16;};
sampler SamplerMask{Texture=TargetMask;},
		SamplerPS1 {Texture=TargetPS1 ;};
bool Equal(float3 a,float3 b)
{
	return (abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b)<=(ThresoldDiffBetweenPixels/10));
}
float4 UDLREdges(float2 texcoord)
{
	float3 CurrentPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord,0,0)).rgb,
		   NextPixel;
	float4 texcoord2;
	bool foundU = false, 
		 foundD = false,
		 foundL = false,
		 foundR = false;
	[loop]
	for(float i=(1.0/BUFFER_HEIGHT),j=(1.0/BUFFER_WIDTH);j<=(1.0/BUFFER_WIDTH)*CyCles;i+=(1.0/BUFFER_HEIGHT)*DiamondSizeV,j+=(1.0/BUFFER_WIDTH)*DiamondSizeV)
	{
		if(foundU&&foundD&&foundL&&foundR)
			break;
		if(!foundU)
		{
			NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x  ,texcoord.y-i,0,0)).rgb;
			texcoord2.r=texcoord.y-i;
			foundU=!Equal(CurrentPixel,NextPixel);
		}
		if(!foundD)
		{
			NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x  ,texcoord.y+i,0,0)).rgb;
			texcoord2.g=texcoord.y+i;
			foundD=!Equal(CurrentPixel,NextPixel);
		}
		if(!foundL)
		{
			NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x-j,texcoord.y  ,0,0)).rgb;
			texcoord2.b=texcoord.x-j;
			foundL=!Equal(CurrentPixel,NextPixel);
		}
		if(!foundR)
		{
			NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x+j,texcoord.y  ,0,0)).rgb;
			texcoord2.a=texcoord.x+j;
			foundR=!Equal(CurrentPixel,NextPixel);
		}
	}
	return texcoord2;
}
float4 Mask(float4 vois:SV_Position,float2 texcoord:TexCoord):SV_Target
{
    return UDLREdges(texcoord);
}
float3 DePixel(float4 vois:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float3 ColorEdge     ,
	       Blended50Color,
           col     =tex2Dlod(ReShade::BackBuffer,float4(texcoord,0,0)).rgb ;
    float4 UDEdges2=tex2Dlod(SamplerMask        ,float4(texcoord,0,0)).rgba;
    float2 upedge  ,
           downedge;
      upedge.x=texcoord.x;
      upedge.y=UDEdges2.r;
    downedge.x=texcoord.x;
    downedge.y=UDEdges2.g;
    float2 centery =lerp(upedge,downedge,0.5),
           centeryD=centery;
	float lerpstep,
          lenght      =abs(downedge.y-upedge.y),
          lenghtUpper =abs(upedge.y-tex2Dlod(SamplerMask,float4(upedge,0,0)).r),
          lenghtDowner=abs(tex2Dlod(SamplerMask,float4(downedge,0,0)).g-downedge.y);
    if( lenghtUpper+NonSquare<lenght)
    	 centery.y=(  upedge.y+lenghtUpper /2);
    if(lenghtDowner+NonSquare<lenght)
    	centeryD.y=(downedge.y-lenghtDowner/2);
    if(texcoord.y<centery.y)
    {
		lerpstep=1/(centery.y-upedge.y);
		lerpstep=lerpstep*(texcoord.y-upedge.y);
		ColorEdge=tex2Dlod(ReShade::BackBuffer,float4(upedge,0,0)).rgb;
		Blended50Color=lerp(ColorEdge,col,0.5);
		col=lerp(Blended50Color,col,lerpstep);
	}
    if(texcoord.y>centeryD.y)
	{
		lerpstep=1/(downedge.y-centeryD.y);
		lerpstep=lerpstep*(downedge.y-texcoord.y);
		ColorEdge=tex2Dlod(ReShade::BackBuffer,float4(downedge,0,0)).rgb;
		Blended50Color=lerp(ColorEdge,col,0.5);
		col=lerp(Blended50Color,col,lerpstep);	
	}
    return col;
}
float3 DePixelH(float4 vois:SV_Position,float2 texcoord:TexCoord):SV_Target
{
	float3 ColorEdge     ,
	       Blended50Color,
	       colPS1  =tex2Dlod(SamplerPS1 ,float4(texcoord,0,0)).rgb ;
	float4 LREdges2=tex2Dlod(SamplerMask,float4(texcoord,0,0)).rgba;
	float2 leftedge ,
	       rightedge;
	 leftedge.y=texcoord.y;
	 leftedge.x=LREdges2.b;
	rightedge.y=texcoord.y;
	rightedge.x=LREdges2.a;
	float2 centerx =lerp(leftedge,rightedge,0.5),
	       centerxR=centerx;
	float lerpstep,
          lenght       =abs(rightedge.x-leftedge.x),
          lenghtLefter =abs(leftedge.x-tex2Dlod(SamplerMask,float4(leftedge,0,0)).b),
          lenghtRighter=abs(tex2Dlod(SamplerMask,float4(rightedge,0,0)).a-rightedge.x);
    if( lenghtLefter+NonSquare<lenght)
    	 centerx.x=( leftedge.x+lenghtLefter /2);
    if(lenghtRighter+NonSquare<lenght)
    	centerxR.x=(rightedge.x-lenghtRighter/2);
    if(texcoord.x<centerx.x)
    {
		lerpstep=1/(centerx.x-leftedge.x);
		lerpstep=lerpstep*(texcoord.x-leftedge.x);
		ColorEdge=tex2Dlod(SamplerPS1,float4(leftedge,0,0)).rgb;
		Blended50Color=lerp(ColorEdge,colPS1,0.5);
		colPS1=lerp(Blended50Color,colPS1,lerpstep);
	}
    if(texcoord.x>centerxR.x)
	{
		lerpstep=1/(rightedge.x-centerxR.x);
		lerpstep=lerpstep*(rightedge.x-texcoord.x);
		ColorEdge=tex2Dlod(SamplerPS1,float4(rightedge,0,0)).rgb;
		Blended50Color=lerp(ColorEdge,colPS1,0.5);
		colPS1=lerp(Blended50Color,colPS1,lerpstep);
	}
	return colPS1;
}
technique DePixel8
{
	pass
    {
		VertexShader=PostProcessVS;
		PixelShader =Mask         ;
		RenderTarget=TargetMask   ;
	}
	pass
	{
		VertexShader=PostProcessVS;
		PixelShader =DePixel      ;
		RenderTarget=TargetPS1    ;
	}
	pass
	{
		VertexShader=PostProcessVS;
		PixelShader =DePixelH     ;
	}
}