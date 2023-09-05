//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;

struct Light {
    float3 position;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float shininess;
};


constant Light light = {
    float3(2.0, 2.0, 2.0),
    float3(0.2, 0.2, 0.2),
    float3(.5, .5, 0.5),
    float3(1.0, 1.0, 1.0),
    32.0
};

constant float3 materialColor = float3(1.0, 0.0, 0.0); // Material color (RGB)


fragment float4 fragmentMain(VertexOut current [[stage_in]])
{
//    float3 normal = normalize(current.normals);
//
//    // Calculate the vector from the fragment to the light source
//    float3 lightDirection = normalize(light.position - current.position.xyz);
//
//    // Calculate the reflection vector (for specular)
//    float3 viewDirection = normalize(-current.position.xyz);
//    float3 reflectionDirection = reflect(-lightDirection, normal);
//
//    // Calculate the ambient component
//    float3 ambient = light.ambientColor * current.color.rgb;
//
//    // Calculate the diffuse component
//    float diffuseIntensity = max(dot(normal, lightDirection), 0.0);
//    float3 diffuse = light.diffuseColor * current.color.rgb * diffuseIntensity;
//
//    // Calculate the specular component
//    float specularIntensity = pow(max(dot(reflectionDirection, viewDirection), 0.0), light.shininess);
//    float3 specular = light.specularColor * specularIntensity;
//
//    // Combine all components
//    float3 finalColor = ambient + diffuse + specular;
//
//    return float4(finalColor, current.color.a);
    
//    float scalarValue = max(dot(normalize(current.normals), normalize(float3(1.,1.,1.))), 0.);
    return current.color;
//    *scalarValue;
}

fragment float4 fragment2D(VertexOut current [[stage_in]], texture2d<float> texture [[texture(FragmentTexture)]])
{
    constexpr sampler samp = sampler(address::clamp_to_edge,
                                     filter::linear);
    
    return current.color;
}
