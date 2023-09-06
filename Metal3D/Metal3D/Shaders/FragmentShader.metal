//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;


struct PointLight {
    float3 position;
    float3 color;
    float  intensity;
    float  constantAttenuation;
    float  linearAttenuation;
    float  quadraticAttenuation;
};

constant PointLight punctualLight = {
    float3(0.0, 2.0, 0.0),
    float3(0.8, 0.8, 0.8),
    20.0,
    10.0,
    0.1,
    0.1
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

constant DirectionalLight defaultDirectionalLight {
    .direction = float3(-1.0, -1.0, -1.0),
    .color = float3(1.0, 1.0, 1.0)
};

constant Material defaultMaterial {
    .ambientColor = float3(0.2, 0.2, 0.2),
    .diffuseColor = float3(0.8, 0.8, 0.8),
    .specularColor = float3(1.0, 1.0, 1.0),
    .shininess = 32.0
};



fragment float4 fragmentMain(VertexOut current [[stage_in]], constant int& lightType[[buffer(FragmentLightType)]])
{
    if(lightType == 1)
    {
        //return float4((current.normals) * 0.5 + 0.5, 1.);
        
        float3 lightVector = punctualLight.position - current.posBef.xyz;
        float distance = length(lightVector);

        lightVector = normalize(lightVector);

        float diffuse = max(dot(normalize(current.normals), lightVector), 0.0);

       // return float4(float3(diffuse), 1.);
        
        float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);
        float3 reflectionDirection = reflect(-lightVector, normalize(current.normals));
        float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), 32.0);

        float attenuation = 1.0 / (punctualLight.constantAttenuation +
                                   punctualLight.linearAttenuation * distance +
                                   punctualLight.quadraticAttenuation * (distance * distance));

        float3 finalColor = (diffuse + specular) * punctualLight.color * punctualLight.intensity * attenuation * current.color.rgb;

        return float4(finalColor, 1.0);
    }
    else if(lightType == 2)
    {
        float3 lightDirection = normalize(defaultDirectionalLight.direction);
        float diffuse = max(dot(normalize(current.normals), -lightDirection), 0.0);

        float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);

        float3 reflectionDirection = reflect(lightDirection, current.normals);

        float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), defaultMaterial.shininess);

        float3 ambient = defaultMaterial.ambientColor;
        float3 diffuseColor = defaultMaterial.diffuseColor * defaultDirectionalLight.color * diffuse;
        float3 specularColor = defaultMaterial.specularColor * defaultDirectionalLight.color * specular;

        float3 finalColor = ambient + diffuseColor + specularColor;

        return float4(finalColor * current.color.rgb, 1.0);
    }
    return current.color;
}

fragment float4 fragment2D(VertexOut current [[stage_in]], texture2d<float> texture [[texture(FragmentTexture)]])
{
    constexpr sampler samp = sampler(address::clamp_to_edge,
                                     filter::linear);
    
    return current.color;
}
