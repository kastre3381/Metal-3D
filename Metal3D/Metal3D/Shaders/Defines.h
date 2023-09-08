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
    float3 normals [[attribute(1)]];
    float4 color [[attribute(2)]];
};

struct VertexOut
{
    float4 position [[position]];
    float4 posBef;
    float2 texCoors;
    float3 normals;
    float4 color;
};

typedef enum ShaderDefines
{
    MainBuffer,
    IndexesBuffer,
    ColorIndexBuffer,
    NormalsIndexBuffer,
    Sampler,
    RotationAngles,
    ScaleFactors,
    TranslationFactors,
    ProjectionDirections,
    NearFar,
    PlotOnOff,
    FragmentTexture,
    FragmentLightType,
    PointLight,
    DirectionalLight,
    Material,
    DrawWithIndexes,
    TextureCoords,
    UseTexture,
} ShaderDefines;



struct DirectionalLight {
    float3 direction;
    float3 color;
};

struct Material {
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float shininess;
};

struct PointLight {
    float3 position;
    float3 color;
    float  intensity;
    float  constantAttenuation;
    float  linearAttenuation;
    float  quadraticAttenuation;
};

#endif /* Defines_h */
