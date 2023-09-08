//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;







fragment float4 fragmentMain(VertexOut current [[stage_in]],
                             constant int& lightType[[buffer(FragmentLightType)]],
                             constant struct PointLight& punctualLight [[buffer(PointLight)]],
                             constant struct DirectionalLight& directionalLight [[buffer(DirectionalLight)]],
                             constant struct Material& material [[buffer(Material)]],
                             texture2d<float> texture [[texture(FragmentTexture)]],
                             constant bool& useTexture [[buffer(UseTexture)]])
{
    constexpr sampler samp = sampler(mag_filter::linear, min_filter::linear, mip_filter::linear, coord::normalized,
                                     r_address::repeat, t_address::repeat, s_address::repeat);
    float4 color;
    if(useTexture)
        color = texture.sample(samp, current.texCoors);
    else
        color = current.color;
    
    if(lightType == 1)
    {
        float3 lightVector = punctualLight.position - current.posBef.xyz;
        float distance = length(lightVector);

        lightVector = normalize(lightVector);

        float diffuse = max(dot(normalize(current.normals), lightVector), 0.0);

        float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);
        float3 reflectionDirection = reflect(-lightVector, normalize(current.normals));
        float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), 32.0);

        float attenuation = 1.0 / (punctualLight.constantAttenuation +
                                   punctualLight.linearAttenuation * distance +
                                   punctualLight.quadraticAttenuation * (distance * distance));

        float3 finalColor = (diffuse + specular) * punctualLight.color * punctualLight.intensity * attenuation * color.rgb;

        return float4(finalColor, 1.0);
    }
    else if(lightType == 2)
    {

        float3 lightDirection = normalize(directionalLight.direction);
        float diffuse = max(dot(normalize(current.normals), -lightDirection), 0.0);

        float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);

        float3 reflectionDirection = reflect(lightDirection, current.normals);

        float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), material.shininess);

        float3 ambient = material.ambientColor;
        float3 diffuseColor = material.diffuseColor * directionalLight.color * diffuse;
        float3 specularColor = material.specularColor * directionalLight.color * specular;

        float3 finalColor = ambient + diffuseColor + specularColor;

        return float4(finalColor * color.rgb, 1.0);
    }
    return color;
}

fragment float4 fragment2D(VertexOut current [[stage_in]], texture2d<float> texture [[texture(FragmentTexture)]])
{
//    constexpr sampler samp = sampler(address::clamp_to_edge,
//                                     filter::linear);
    
    return current.color;
}
