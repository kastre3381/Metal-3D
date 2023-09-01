//
//  VertexShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;


vertex VertexOut vertexMain(const device VertexIn* vertexArray [[buffer(MainBuffer)]],
                            unsigned int vertexID [[vertex_id]],
                            constant float* angles [[buffer(RotationAngles)]],
                            constant float* scale [[buffer(ScaleFactors)]],
                            constant float* translation [[buffer(TranslationFactors)]])
{
    VertexOut vertexOut;
    
    auto posMain = vertexArray[vertexID].position;
    
    float pos1 = cos(angles[1])*cos(angles[2])*posMain[0] +
                (sin(angles[0])*sin(angles[1])*cos(angles[2]) - cos(angles[0])*sin(angles[2]))*posMain[1] +
                (cos(angles[0])*sin(angles[1])*cos(angles[2]) + sin(angles[0])*sin(angles[2]))*posMain[2];
    
    float pos2 = cos(angles[1])*sin(angles[2])*posMain[0] +
                (sin(angles[0])*sin(angles[1])*sin(angles[2]) + cos(angles[0])*cos(angles[2]))*posMain[1] +
                (cos(angles[0])*sin(angles[1])*sin(angles[2]) - sin(angles[0])*cos(angles[2]))*posMain[2];
    
    float pos3 = -sin(angles[1])*posMain[0] + sin(angles[0])*cos(angles[1])*posMain[1] + cos(angles[0])*cos(angles[1])*posMain[2];
    
    pos1*=scale[0];
    pos2*=scale[1];
    pos3*=scale[2];
    
    float w = translation[0]*pos1 + translation[1]*pos2 + translation[2]*pos3 +1.;
    
    vertexOut.position = float4(pos1, pos2, pos3, w);
    vertexOut.color = vertexArray[vertexID].color;
    return vertexOut;
}

