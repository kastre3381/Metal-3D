//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;

fragment float4 fragmentMain(VertexOut current [[stage_in]], texture2d<float> texture)
{
//    float near = 10.;
//    float far  = 100.0;
//
//    float z = current.position.z * 2.0 - 1.0; // back to NDC
//    return float4(float3((2.0 * near * far) / (far + near - z * (far - near)) / far), 1.);
    
    constexpr sampler samp = sampler(address::clamp_to_edge);
    
//    return texture.sample(samp, current.position.xy);
    
    return current.color;
}
