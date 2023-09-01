//
//  Defines.h
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//

#ifndef Defines_h
#define Defines_h


struct VertexIn
{
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut
{
    float4 position [[position]];
    float4 color;
};

typedef enum ShaderDefines
{
    MainBuffer,
    RotationAngles,
    ScaleFactors,
    TranslationFactors,
} ShaderDefines;

#endif /* Defines_h */
