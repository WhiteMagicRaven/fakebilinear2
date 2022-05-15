uniform float ThresoldDiffBetweenPixels <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 3.0;
> = 0;
uniform float UpLimit <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 0;
uniform float Downlimit <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1;
uniform float LeftLimit <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 0;
uniform float Rightlimit <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1;
uniform float LenLimit <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1;
uniform float LenLimitSquare <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1;

uniform float ColorTreshold <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1;
> = 1;

uniform float NonSquare <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1;
> = 0.005;
uniform int DiamondSizeV <
	ui_type = "slider";
	ui_min = 0; ui_max = 128;
> = 2;


#include "ReShade.fxh"
texture TargetPS1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16; };
sampler SamplerPS1 { Texture = TargetPS1; }; 
//texture TargetPS2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
//sampler SamplerPS2 { Texture = TargetPS2; }; 
texture TargetMask { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16; };
sampler SamplerMask { Texture = TargetMask; }; 
bool Equal(float4 a, float4 b)
{
    return (abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b)<=(ThresoldDiffBetweenPixels/10));
}
float2 LREdgesExample(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	float2 texcoord2;
	texcoord2.x=texcoord.x;
	texcoord2.y=texcoord.x;
	bool foundL = false;
	bool foundR = false;
    [loop]
    for(float i=(1.0/BUFFER_WIDTH);i<=(1.0/BUFFER_WIDTH)*128;i+=(1.0/BUFFER_WIDTH))
    {
    	if(!foundL)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x-i,texcoord.y)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.x-i>LeftLimit)
				texcoord2.y = texcoord.x-i;//leftedge in y;
				foundL = true;
		    }
        }
    	if(!foundR)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x+i,texcoord.y)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.x+i<Rightlimit)
				texcoord2.x = texcoord.x+i;//rightedge in x;
				foundR = true;
		    }
        }
    }
	return texcoord2;
}

float4 UDLREdges(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel,n1,n2,n3,n4;
	float4 texcoord2;
	texcoord2.r=texcoord.y;
	texcoord2.g=texcoord.y;
	texcoord2.b=texcoord.x;
	texcoord2.a=texcoord.x;
	bool foundU = false;
	bool foundD = false;
	bool foundL = false;
	bool foundR = false;
	bool foundA = false;
	int diamondSize     = 128;
	int diamondSizeTemp = 128;
	int quickstep       = 16;
//	float i=(1.0/BUFFER_HEIGHT),j=(1.0/BUFFER_WIDTH);
   float i=(1.0/BUFFER_HEIGHT),j=(1.0/BUFFER_WIDTH);
//    float i=(1.0/BUFFER_HEIGHT)*diamondSize,j=(1.0/BUFFER_WIDTH)*diamondSize;
    
//    [loop]
//    for(0;j<=(1.0/BUFFER_WIDTH)*diamondSizeTemp;i+=(1.0/BUFFER_HEIGHT)*quickstep,j+=(1.0/BUFFER_WIDTH)*quickstep)
//    {
//	 n1=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x  ,texcoord.y-j, 0, 0)).rgba;    
//     n2=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x-i,texcoord.y  , 0, 0)).rgba;
//     n3=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x+i,texcoord.y  , 0, 0)).rgba;
//     n4=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x  ,texcoord.y+j, 0, 0)).rgba;
//     float4 CurrentPixel1=tex2Dlod(ReShade::BackBuffer,int4(texcoord.x  ,texcoord.y, 0, 0)).rgba;    
    //}
//    tex2Dlod 
//    if(!Equal(CurrentPixel1,n1)||
//       !Equal(CurrentPixel1,n2)||
//       !Equal(CurrentPixel1,n3)||
//       !Equal(CurrentPixel1,n4)
//      )
//      {
//		diamondSize = quickstep*2;
//	  }
//      break;
//      diamondSize = quickstep*2;
//      quickstep;
//    }
//    i=(1.0/BUFFER_HEIGHT),j=(1.0/BUFFER_WIDTH);
//    {
    	//diamondSize = 0;
//	}
//  bool
    int DiamondSizeV2 = 1;
    bool firtsstepin = false; 
    [loop]
    for(0;/*!foundU&&!foundD&&!foundL&&!foundR*/j<=(1.0/BUFFER_WIDTH)*diamondSize;i+=(1.0/BUFFER_HEIGHT)*DiamondSizeV2,j+=(1.0/BUFFER_WIDTH)*DiamondSizeV2)
//	for(0;/*!foundU&&!foundD&&!foundL&&!foundR*/j>=(1.0/BUFFER_WIDTH);i-=(1.0/BUFFER_HEIGHT)*DiamondSizeV2,j-=(1.0/BUFFER_WIDTH)*DiamondSizeV2)    
    //while(!foundU&&!foundD&&!foundL&&!foundR)
    {
    	if(foundU&&foundD&&foundL&&foundR)
//    	if(foundU&&foundL)
    	{
    		//j++;
    		//j=(1.0/BUFFER_WIDTH)*diamondSize;
    		break;
    		//diamondSize = 0;
		}
    	if(!foundU)
        {
	        NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x,texcoord.y-i,0,0)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
// 	       	if(firtsstepin)
// 	       	{
// 	       	    j=j-(1.0/BUFFER_WIDTH )*DiamondSizeV2;
// 	       	    i=i-(1.0/BUFFER_HEIGHT)*DiamondSizeV2;
// 	       	    DiamondSizeV2=1;
//	 	       	firtsstepin = false;
//	 	       	continue;
//                }
        		if(texcoord.y-i>UpLimit)
				texcoord2.r = texcoord.y-i;//upedge in r;
				foundU = true;
		    }
        }
    	if(!foundD)
        {
	        NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x,texcoord.y+i,0,0)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
// 	       	if(firtsstepin)
// 	       	{
// 	       	    j=j-(1.0/BUFFER_WIDTH )*DiamondSizeV2;
// 	       	    i=i-(1.0/BUFFER_HEIGHT)*DiamondSizeV2;
// 	       	    DiamondSizeV2=1;
//	 	       	firtsstepin = false;
//	 	       	continue;
//                }
        		if(texcoord.y+i<Downlimit)
				texcoord2.g = texcoord.y+i;//downedge in g;
				foundD = true;
		    }
        }
    	if(!foundL)
        {
	        NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x-j,texcoord.y,0,0)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
// 	       	if(firtsstepin)
// 	       	{
// 	       	    j=j-(1.0/BUFFER_WIDTH )*DiamondSizeV2;
// 	       	    i=i-(1.0/BUFFER_HEIGHT)*DiamondSizeV2;
// 	       	    DiamondSizeV2=1;
//	 	       	firtsstepin = false;
//	 	       	continue;
//                }
        		if(texcoord.x-j>LeftLimit)
				texcoord2.b = texcoord.x-j;//leftedge in b;
				foundL = true;
		    }
        }
    	if(!foundR)
        {
	        NextPixel=tex2Dlod(ReShade::BackBuffer,float4(texcoord.x+j,texcoord.y,0,0)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
// 	       	if(firtsstepin)
// 	       	{
// 	       	    j=j-(1.0/BUFFER_WIDTH )*DiamondSizeV2;
// 	       	    i=i-(1.0/BUFFER_HEIGHT)*DiamondSizeV2;
// 	       	    DiamondSizeV2=1;
//	 	       	firtsstepin = false;
//	 	       	continue;
//                }
        		if(texcoord.x+j<Rightlimit)
				texcoord2.a = texcoord.x+j;//rightedge in a;
				foundR = true;
		    }
        }
//        i+=(1.0/BUFFER_HEIGHT),j+=(1.0/BUFFER_WIDTH);
    }
//    }
	return texcoord2;
}

float2 UDEdges(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	float2 texcoord2;
	texcoord2.x=texcoord.y;
	texcoord2.y=texcoord.y;
	bool foundU = false;
	bool foundD = false;
    [loop]
    for(float i=(1.0/BUFFER_HEIGHT);i<=(1.0/BUFFER_HEIGHT)*128;i+=(1.0/BUFFER_HEIGHT))
    {
    	if(!foundU)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x,texcoord.y-i)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.y-i>UpLimit)
				texcoord2.y = texcoord.y-i;//upedge in y;
				foundU = true;
		    }
        }
    	if(!foundD)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x,texcoord.y+i)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.y+i<Downlimit)
				texcoord2.x = texcoord.y+i;//downedge in x;
				foundD = true;
		    }
        }
    }
	return texcoord2;
}
float2 UpEdge(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	bool found = false;
    [loop]
    for(float i=(1.0/BUFFER_HEIGHT);i<=(1.0/BUFFER_HEIGHT)*128;i+=(1.0/BUFFER_HEIGHT))
    {
       	if(!found)
        {
        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x,texcoord.y-i)).rgba;
        if(!Equal(CurrentPixel,NextPixel))
        {
        		if(texcoord.y-i>UpLimit)
				texcoord = float2(texcoord.x,texcoord.y-i);
				found = true;
				//i=((1.0/BUFFER_HEIGHT)*127);
				//i=i+0.1;
                //return texcoord;
	    }
        }
    }
	return texcoord;
}
float2 DownEdge(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	bool found = false;
    [loop]
    for(float i=(1.0/BUFFER_HEIGHT);i<=(1.0/BUFFER_HEIGHT)*128;i+=(1.0/BUFFER_HEIGHT))
    {
       	if(!found)
        {
        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x,texcoord.y+i)).rgba;
        if(!Equal(CurrentPixel,NextPixel))
        {
        		if(texcoord.y+i<Downlimit)
				texcoord = float2(texcoord.x,texcoord.y+i);
				found = true;
                //return texcoord;
	    }
        }
    }
	return texcoord;
}

float2 LeftEdge(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	bool found = false;
    [loop]
    for(float i=(1.0/BUFFER_WIDTH);i<=(1.0/BUFFER_WIDTH)*128;i+=(1.0/BUFFER_WIDTH))
    {
       	if(!found)
        {
        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x-i,texcoord.y)).rgba;
        if(!Equal(CurrentPixel,NextPixel))
        {
        		if(texcoord.x-i>LeftLimit)
				texcoord = float2(texcoord.x-i,texcoord.y);
				found = true;
				//[unroll]
				//i=1;
                //return texcoord;
	    }
        }
    }
	return texcoord;
}
float2 LREdges(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	float2 texcoord2;
	texcoord2.x=texcoord.x;
	texcoord2.y=texcoord.x;
	bool foundL = false;
	bool foundR = false;
    [loop]
    for(float i=(1.0/BUFFER_WIDTH);i<=(1.0/BUFFER_WIDTH)*128;i+=(1.0/BUFFER_WIDTH))
    {
    	if(!foundL)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x-i,texcoord.y)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.x-i>LeftLimit)
				texcoord2.y = texcoord.x-i;//leftedge in y;
				foundL = true;
		    }
        }
    	if(!foundR)
        {
	        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x+i,texcoord.y)).rgba;
 	       if(!Equal(CurrentPixel,NextPixel))
 	       {
        		if(texcoord.x+i<Rightlimit)
				texcoord2.x = texcoord.x+i;//rightedge in x;
				foundR = true;
		    }
        }
    }
	return texcoord2;
}

float2 RightEdge(float2 texcoord)
{
	float4 CurrentPixel = tex2D(ReShade::BackBuffer, texcoord).rgba;
	float4 NextPixel;
	bool found = false;
    [loop]
    for(float i=(1.0/BUFFER_WIDTH);i<=(1.0/BUFFER_WIDTH)*128;i+=(1.0/BUFFER_WIDTH))
    {
       	if(!found)
        {
        NextPixel=tex2D(ReShade::BackBuffer,float2(texcoord.x+i,texcoord.y)).rgba;
        if(!Equal(CurrentPixel,NextPixel))
        {
        		if(texcoord.x+i<Rightlimit)
				texcoord = float2(texcoord.x+i,texcoord.y);
				found = true;
                //return texcoord;
	    }
        }
    }
	return texcoord;
}
float4 Mask(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	
//    float4 msk = tex2D(ReShade::BackBuffer, texcoord).rgba;
//    float4 UDLREdges2 = UDLREdges(texcoord);
//    msk.r= UDLREdges2.r;
//    msk.g= UDLREdges2.g;
//    msk.b= UDLREdges2.b;
//    msk.a= UDLREdges2.a;
//    return msk;
   
    return UDLREdges(texcoord);
}
float3 DePixel(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
    float3 col = tex2D(ReShade::BackBuffer, texcoord).rgb;
    //float2 current  = texcoord;
    //float2 upedge   = UpEdge  (texcoord);    
//    float4 UDEdges2 = UDLREdges(texcoord);
    float4 UDEdges2 = tex2D(SamplerMask,texcoord).rgba;
    float2 upedge;
    upedge.x=texcoord.x;
    upedge.y=UDEdges2.r;//upedge in r
   // float3 ColorUpEdge=tex2D(ReShade::BackBuffer, upedge).rgb;    
//    upedge.y=(tex2D(SamplerMask,upedge).rgba).r;
//    upedge.y=UpEdge  (texcoord).y;

    //float2 downedge = DownEdge(texcoord);
    float2 downedge;
    downedge.x = texcoord.x;
    downedge.y = UDEdges2.g;//downedge in g
   // downedge.y = DownEdge(texcoord).y;
    float2 centery  = (upedge+downedge)/2;//up
    float2 centeryD = (upedge+downedge)/2;//down
//	if(texcoord.y!=centery.y)
    float lenght       = abs(downedge.y-upedge.y);
    float lenghtUpper  = abs(upedge.y-(tex2D(SamplerMask,upedge).rgba).r);
    float lenghtDowner = abs((tex2D(SamplerMask,downedge).rgba).g-downedge.y);
    if(lenghtUpper+NonSquare<lenght)
    {
    	centery.y = (upedge.y+lenghtUpper/2);//up
	}

    if(lenghtDowner+NonSquare<lenght)
    {
    	centeryD.y = (downedge.y-lenghtDowner/2);//up
	}
    //near square pixel test
	float2 leftedge;
	leftedge.y=texcoord.y;
	leftedge.x=UDEdges2.b;//leftedge in b
	float2 rightedge;
	rightedge.y=texcoord.y;
	rightedge.x=UDEdges2.a;//rightedge in a
    
    float lenght2= abs(rightedge.x-leftedge.x);
    //near square pixel test
    
    //if(lenght
    if(abs(lenght-lenght2)<=LenLimitSquare)    //near square pixel test
    if(centery.y-upedge.y!=0&&downedge.y-centery.y!=0)
    if(texcoord.y<=centery.y)
    {
    	//float realcentery
    	float lenghtu=abs(tex2D(SamplerMask,upedge).g-tex2D(SamplerMask,upedge).r);
    	if((lenght-lenghtu)<=LenLimit)
//    	{
//    		centery.y-=abs(lenght-lenghtu);
//		}
    	{
	    float lerpstep=1/(centery.y-upedge.y);
	    	  lerpstep=lerpstep*(texcoord.y-upedge.y);
	    	  float3 ColorUpEdge=tex2D(ReShade::BackBuffer, upedge).rgb;
	    	  float3 Blended50Color=(ColorUpEdge+col)/2;
	    	  if(abs(ColorUpEdge.r-col.r)<=ColorTreshold&&
                 abs(ColorUpEdge.g-col.g)<=ColorTreshold&&
                 abs(ColorUpEdge.b-col.b)<=ColorTreshold)
                 {
//	    	  	col=lerp(Blended50Color,col,lerpstep);
	    	  	col=lerp(Blended50Color,col,lerpstep);

	    	  	//.r=lerp(Blended50Color.r,col.r,lerpstep);
	    	  	//col.g=lerp(Blended50Color.g,col.g,lerpstep);
	    	  	//col.b=lerp(Blended50Color.b,col.b,lerpstep);
	    	     }
	    }
	    	  //col=Blended50Color;
	}
//	if(1)
//	{
//    }
//	else
    if(centeryD.y-upedge.y!=0&&downedge.y-centeryD.y!=0)
    if(texcoord.y>=centeryD.y)
	{
    	float lenghtd=abs(tex2D(SamplerMask,downedge).g-tex2D(SamplerMask,downedge).r);
    	if((lenght-lenghtd)<=LenLimit)
    	{
	    float lerpstep=1/(downedge.y-centeryD.y);
	    	  lerpstep=lerpstep*(downedge.y-texcoord.y);
	    	  float3 ColorDownEdge=tex2D(ReShade::BackBuffer, downedge).rgb;
	    	  float3 Blended50Color=(ColorDownEdge+col)/2;
	    	  if(abs(ColorDownEdge.r-col.r)<=ColorTreshold&&
                 abs(ColorDownEdge.g-col.g)<=ColorTreshold&&
                 abs(ColorDownEdge.b-col.b)<=ColorTreshold)
                 {
		    	  col=lerp(Blended50Color,col,lerpstep);	

	    	  	//col.r=lerp(Blended50Color.r,col.r,lerpstep);
	    	  //	col.g=lerp(Blended50Color.g,col.g,lerpstep);
	    	//  	col.b=lerp(Blended50Color.b,col.b,lerpstep);
		    	 }
	    }
	}
    return col;
}
float3 DePixelH(float4 vois : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
   // float3 col      = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float3 colPS1   = tex2D(SamplerPS1         , texcoord).rgb;
//	float2 leftedge = LeftEdge ( texcoord);
//	float2 rightedge= RightEdge (texcoord);

//	float4 LREdges2 = UDLREdges(texcoord);
	float4 LREdges2 = tex2D(SamplerMask,texcoord).rgba;
	float2 leftedge;
	leftedge.y=texcoord.y;
	leftedge.x=LREdges2.b;//leftedge in b
	float2 rightedge;
	rightedge.y=texcoord.y;
	rightedge.x=LREdges2.a;//rightedge in a
	
	float2 centerx   = (leftedge+rightedge)/2;
	float2 centerxR  = (leftedge+rightedge)/2;
    //float2 upedge   = UpEdge  (texcoord);    
    //float2 downedge = DownEdge(texcoord);
    //float2 centery  = (upedge+downedge)/2;

    //(centery-centerx);
	//if(abs(rightedge.x-leftedge.x-downedge.y-upedge.y)<=0.2)
//	if(texcoord.x!=centerx.x)
    //near square pixel test
    float2 upedge;
    upedge.x=texcoord.x;
    upedge.y=LREdges2.r;//upedge in r
//    upedge.y=UpEdge  (texcoord).y;

    //float2 downedge = DownEdge(texcoord);
    float2 downedge;
    downedge.x = texcoord.x;
    downedge.y = LREdges2.g;//downedge in g
    float lenght2= abs(downedge.y-upedge.y);
    
    //near square pixel test

    float lenght        = abs(rightedge.x-leftedge.x);
    float lenghtLefter  = abs(leftedge.x-(tex2D(SamplerMask,leftedge).rgba).b);
    float lenghtRighter = abs((tex2D(SamplerMask,rightedge).rgba).a-rightedge.x);
    if(lenghtLefter+NonSquare<lenght)
    {
    	centerx.x = (leftedge.x+lenghtLefter/2);//up
	}

    if(lenghtRighter+NonSquare<lenght)
    {
    	centerxR.x = (rightedge.x-lenghtRighter/2);//up
	}

    if(abs(lenght-lenght2)<=LenLimitSquare)    //near square pixel test
	if(centerx.x-leftedge.x!=0&&rightedge.x-centerx.x!=0)
    if(texcoord.x<=centerx.x)
    {
    	float lenghtl=abs(tex2D(SamplerMask,leftedge).a-tex2D(SamplerMask,leftedge).b);
    	if((lenght-lenghtl)<=LenLimit)
    	{
	    float lerpstep=1/(centerx.x-leftedge.x);
	    	  lerpstep=lerpstep*(texcoord.x-leftedge.x);
	    	  float3 ColorLeftEdge=tex2D(SamplerPS1, leftedge).rgb;
	    	  float3 Blended50Color=(ColorLeftEdge+colPS1)/2;
	    	  if(abs(ColorLeftEdge.r-colPS1.r)<=ColorTreshold&&
                 abs(ColorLeftEdge.g-colPS1.g)<=ColorTreshold&&
                 abs(ColorLeftEdge.b-colPS1.b)<=ColorTreshold)
                 {
    	    	  colPS1=lerp(Blended50Color,colPS1,lerpstep);

	    	  	//col.r=lerp(Blended50Color.r,colPS1.r,lerpstep);
	    	  	//col.g=lerp(Blended50Color.g,colPS1.g,lerpstep);
	    	  	//col.b=lerp(Blended50Color.b,colPS1.b,lerpstep);
    	    	 }
	    }
	}
//	else
//    if(centerxD.x-upedge.y!=0&&downedge.y-centeryD.y!=0)
//    if(0)
	if(centerxR.x-leftedge.x!=0&&rightedge.x-centerxR.x!=0)
    if(texcoord.x>=centerxR.x)
	{
    	float lenghtr=abs(tex2D(SamplerMask,rightedge).a-tex2D(SamplerMask,rightedge).b);
    	if((lenght-lenghtr)<=LenLimit)
    	{
	    float lerpstep=1/(rightedge.x-centerxR.x);
	    	  lerpstep=lerpstep*(rightedge.x-texcoord.x);
	    	  float3 ColorRightEdge=tex2D(SamplerPS1, rightedge).rgb;
	    	  float3 Blended50Color=(ColorRightEdge+colPS1)/2;
	    	  if(abs(ColorRightEdge.r-colPS1.r)<=ColorTreshold&&
                 abs(ColorRightEdge.g-colPS1.g)<=ColorTreshold&&
                 abs(ColorRightEdge.b-colPS1.b)<=ColorTreshold)
                 {
		    	  colPS1=lerp(Blended50Color,colPS1,lerpstep);

	    	  	//col.r=lerp(Blended50Color.r,colPS1.r,lerpstep);
	    	  	//col.g=lerp(Blended50Color.g,colPS1.g,lerpstep);
	    	  	//col.b=lerp(Blended50Color.b,colPS1.b,lerpstep);
		    	 }
		}	
	}
    return colPS1;
}

technique DePixel6
{
    pass
    {
		VertexShader = PostProcessVS;
		PixelShader = Mask;
		RenderTarget = TargetMask;
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DePixel;
		RenderTarget = TargetPS1;
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = DePixelH;
		//RenderTarget = TargetPS2;
	}
}
