//
//  VertexShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;

vertex VertexOut vertex2D(const device VertexIn* vertexArray [[buffer(MainBuffer)]],
                          unsigned int vertexID [[vertex_id]])
{
    VertexOut ver;
    ver.position = float4(vertexArray[vertexID].position, 1.);
    ver.normals = vertexArray[vertexID].normals;
    ver.color = vertexArray[vertexID].color;
    return ver;
}

vertex VertexOut vertexMain(const device VertexIn* vertexArray [[buffer(MainBuffer)]],
                            unsigned int vertexID [[vertex_id]],
                            constant float3& angles [[buffer(RotationAngles)]],
                            constant float3& scale [[buffer(ScaleFactors)]],
                            constant float3& translation [[buffer(TranslationFactors)]],
                            constant float4& directions [[buffer(ProjectionDirections)]],
                            constant float2& nearFar [[buffer(NearFar)]],
                            constant bool& isPlot [[buffer(PlotOnOff)]])
{
    VertexOut vertexOut;
    
    float4 posMain = float4(vertexArray[vertexID].position, 1.);
    
    float4x4 matTr = float4x4(float4(1., 0., 0., translation.x),
                            float4(0., 1., 0., translation.y),
                            float4(0., 0., 1., translation.z),
                            float4(0., 0., 0., 1.));

    float4x4 matSc = float4x4(float4(scale.x, 0., 0., 0.),
                              float4(0., scale.y, 0., 0.),
                              float4(0., 0., scale.z, 0.),
                              float4(0., 0., 0., 1.));
    
    float sinZ = sin(angles.z);
    float cosZ = cos(angles.z);
    
    float4x4 matRotZ = float4x4(float4(sinZ, cosZ, 0., 0.),
                                float4(-cosZ, sinZ, 0., 0.),
                                float4(0.,      0., 1., 0.),
                                float4(0.,      0., 0., 1.));
    
    float sinX = sin(angles.x);
    float cosX = cos(angles.x);
    float4x4 matRotX = float4x4(float4(1., 0., 0., 0.),
                              float4(0., sinX, cosX, 0.),
                              float4(0., -cosX, sinX, 0.),
                              float4(0., 0., 0., 1.));
    
    float sinY = sin(angles.y);
    float cosY = cos(angles.y);
    float4x4 matRotY = float4x4(float4(sinY, 0.,  cosY, 0.),
                                float4(0., 1,     0., 0.),
                                float4(-cosY, 0., sinY, 0.),
                                float4(0., 0.,    0., 1.));
    
    float4x4 matProj = float4x4(float4(2.*nearFar.x/(directions.y-directions.x), 0., (directions.y+directions.x)/(directions.y-directions.x), 0.),
                                float4(0., 2.*nearFar.x/(directions.w-directions.z), (directions.w+directions.z)/(directions.w-directions.z), 0.),
                                float4(0., 0., (nearFar.y+nearFar.x)/(nearFar.x-nearFar.y), -2.*nearFar.y*nearFar.x/(nearFar.y-nearFar.x)),
                                float4(0., 0., -1., 0.));

    
   
    float4x4 mat;
    if(!isPlot)
        mat = matRotZ * matRotY * matRotX * matTr * matSc * matProj;
    else
        mat = float4x4(float4(10., 0., 0., 0.),
                       float4(0., 10., 0., 0.),
                       float4(0., 0., 10., 0.),
                       float4(0., 0., 0., 1.)) * matRotZ * matRotY * matRotX;
    
    
    vertexOut.position = posMain * mat;
//    mat * posMain;
    
    //float4(pos1, pos2, pos3, w);
    vertexOut.color = vertexArray[vertexID].color;
    vertexOut.normals = float3(float4(vertexArray[vertexID].normals, 1.)*matRotZ * matRotY * matRotX * matTr * matSc * matProj);
    return vertexOut;
}
