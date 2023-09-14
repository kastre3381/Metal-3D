//
//  VertexShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;





vertex VertexOutDoublePass vertexMainDoublePass(const device VertexInDoublePass* vertex_array [[buffer((int)DoublePassDefines::MainBuffer)]], unsigned int vid [[vertex_id]])
{
    VertexOutDoublePass out;
    out.position = float4(vertex_array[vid].position.x,-1.*vertex_array[vid].position.y , 0.0, 1.0);
    out.uv = 0.5*vertex_array[vid].textureCoord + float2(0.5,0.5);
    out.color = vertex_array[vid].color;
    return out;
}

TBN computeTBN(float3 v0, float3 v1, float3 v2,   // vertex positions
               float2 uv0, float2 uv1, float2 uv2) // texture coordinates
{
    TBN tbn;

    float3 edge1 = v1 - v0;
    float3 edge2 = v2 - v0;

    float2 deltaUV1 = uv1 - uv0;
    float2 deltaUV2 = uv2 - uv0;

    float f = 1.0 / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);

    tbn.tangent.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
    tbn.tangent.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
    tbn.tangent.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);

    tbn.bitangent.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
    tbn.bitangent.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
    tbn.bitangent.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);

    return tbn;
}

vertex VertexOut vertexMain(const device VertexIn* vertexArray [[buffer(MainBuffer)]],
                            unsigned int vertexID [[vertex_id]],
                            constant float3& angles [[buffer(RotationAngles)]],
                            constant float3& scale [[buffer(ScaleFactors)]],
                            constant float3& translation [[buffer(TranslationFactors)]],
                            constant float4& directions [[buffer(ProjectionDirections)]],
                            constant float2& nearFar [[buffer(NearFar)]],
                            constant float2* textCoord [[buffer(TextureCoords)]],
                            constant bool2& isPlot [[buffer(PlotOnOff)]],
                            constant uint* indexes [[buffer(IndexesBuffer)]],
                            constant uint* normalsIndexes [[buffer(NormalsIndexBuffer)]],
                            constant uint* colorIndexes [[buffer(ColorIndexBuffer)]],
                            constant bool& drawWithIndexes [[buffer(DrawWithIndexes)]])
{
    VertexOut vertexOut;
    
    uint newVertexID = vertexID, newColorID = vertexID, newNormalID = vertexID;
    
    vertexOut.texCoors = textCoord[vertexID];
    
    if(drawWithIndexes)
    {
        newVertexID = indexes[vertexID];
        newColorID = colorIndexes[vertexID];
        newNormalID = normalsIndexes[vertexID];
    }
    
    int i = floor(vertexID/3.)*3;
    
    if(i==3 || i>=27) i=0;
    //(newVertexID/3 + newVertexID%3)*3;
    
    uint v0 = indexes[i];
    uint v1 = indexes[i + 1];
    uint v2 = indexes[i + 2];
    
    vector_float2 uv0 = textCoord[v0];
    vector_float2 uv1 = textCoord[v1];
    vector_float2 uv2 = textCoord[v2];
    
    float3 posV0 = vertexArray[v0].position;
    float3 posV1 = vertexArray[v1].position;
    float3 posV2 = vertexArray[v2].position;
    
    TBN tbnMat = computeTBN(posV0, posV1, posV2, uv0, uv1, uv2);
    
    // Note: Storing the tangent and bitangent in the VertexOut structure for the current vertex.
    // You might want to adjust this logic if you want to average the tangents/bitangents for shared vertices.
    if (vertexID == v0) {
        vertexOut.tangent = tbnMat.tangent;
        vertexOut.bitangent = tbnMat.bitangent;
    } else if (vertexID == v1) {
        vertexOut.tangent = tbnMat.tangent;
        vertexOut.bitangent = tbnMat.bitangent;
    } else if (vertexID == v2) {
        vertexOut.tangent = tbnMat.tangent;
        vertexOut.bitangent = tbnMat.bitangent;
    }
    
    float4 posMain = float4(vertexArray[newVertexID].position, 1.);
    
    float4x4 matTr = float4x4(float4(1., 0., 0., translation.x),
                                float4(0., 1., 0., translation.y),
                                float4(0., 0., 1., translation.z),
                                float4(0., 0., 0., 1.));
    
    float4x4 matSc = float4x4(float4(scale.x, 0., 0., 0.),
                                float4(0., scale.y, 0., 0.),
                                float4(0., 0., scale.z, 0.),
                                float4(0., 0., 0., 1.));
    
    float sinZ = sin(angles.y);
    float cosZ = cos(angles.y);
    
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
    if(!isPlot[0])
        mat = matRotZ * matRotY * matRotX * matTr * matSc * matProj;
    else
        mat = float4x4(float4(10., 0., 0., 0.),
                        float4(0., 10., 0., 0.),
                        float4(0., 0., 10., 0.),
                        float4(0., 0., 0., 1.)) * matRotZ * matRotY * matRotX;
    
    vertexOut.position = posMain * mat;
    //    mat * posMain;
    vertexOut.posBef = posMain * matRotZ * matRotY * matRotX * matTr * matSc;
    //float4(pos1, pos2, pos3, w);
    vertexOut.color = vertexArray[newColorID].color;
    vertexOut.normals =// vertexArray[vertexID].normals;
    float3(float4(vertexArray[newNormalID].normals, 0.)*matRotZ * matRotY * matRotX * matTr * matSc);
    
    vertexOut.tangent = float3(float4(vertexOut.tangent, 0.)*matRotZ * matRotY * matRotX * matTr * matSc);
    vertexOut.bitangent = float3(float4(vertexOut.bitangent, 0.)*matRotZ * matRotY * matRotX * matTr * matSc);
    
    if(isPlot[1])
        vertexOut.color = float4(2.*posMain.x, 2.*posMain.y, 2.*posMain.z, 1.);
    
    vertexOut.texCoors = textCoord[vertexID];

    return vertexOut;
    
}
