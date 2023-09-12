//
//  IndexEnum.h
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//

#ifndef IndexEnum_h
#define IndexEnum_h

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


enum class DoublePassDefines
{
    MainBuffer = 20,
    FragmentTexture,
};


struct PointLight {
    vector_float3 position;
    vector_float3 color;
    float  intensity;
    float  constantAttenuation;
    float  linearAttenuation;
    float  quadraticAttenuation;
};

struct DirectionalLight {
    vector_float3 direction;
    vector_float3 color;
};

struct Material {
    vector_float3 ambientColor;
    vector_float3 diffuseColor;
    vector_float3 specularColor;
    float shininess;
};

#endif /* IndexEnum_h */
