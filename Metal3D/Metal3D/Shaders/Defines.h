//
//  Defines.h
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//

#ifndef Defines_h
#define Defines_h

struct VertexInDoublePass
{
    float2 position [[attribute(0)]];
    float2 textureCoord [[attribute(1)]];
    float4 color [[attribute(2)]];
};

struct VertexOutDoublePass
{
    float4 position [[position]];
    float2 uv;
    float4 color;
};


struct VertexIn
{
    float3 position [[attribute(0)]];
    float3 normals [[attribute(1)]];
    float4 color [[attribute(2)]];
};

typedef struct {
    float3 tangent;
    float3 bitangent;
} TBN;

struct VertexOut
{
    float4 position [[position]];
    float4 posBef;
    float2 texCoors;
    float3 normals;
    float4 color;
    float3 tangent;
    float3 bitangent;
};

typedef enum ShaderDefines
{
    MainBuffer,
    TanAndBitan,
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
    Time,
    NormalMap,
    RoughnessMap,
    DisplacementMap,
    aoMap,
} ShaderDefines;


enum class DoublePassDefines
{
    MainBuffer = 28,
    FragmentTexture,
};

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

struct Ray {
  float3 origin;
  float3 direction;
};

struct Sphere {
  float3 center;
  float radius;
};

struct Plane {
  float yCoord;
};

struct Light {
  float3 position;
};

#endif /* Defines_h */
