//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;

fragment float4 fragmentMain(VertexOut current [[stage_in]])
{
    return current.color;
}
