//
//  FragmentShader.metal
//  Metal3D
//
//  Created by MotionVFX on 01/09/2023.
//
#include "Defines.h"
#include <metal_stdlib>
using namespace metal;

//float differenceOp(float d0, float d1) {
//    return max(d0, -d1);
//}
//
//float distanceToRect( float2 point, float2 center, float2 size ) {
//    point -= center;
//    point = abs(point);
//    point -= size / 2.;
//    return max(point.x, point.y);
//}
//
//float distanceToScene( float2 point ) {
//    float d2r1 = distanceToRect( point, float2(0.), float2(0.45, 0.85) );
//    float2 mod = point - 0.1 * floor(point / 0.1);
//    float d2r2 = distanceToRect( mod, float2( 0.05 ), float2(0.02, 0.04) );
//    float diff = differenceOp(d2r1, d2r2);
//    return diff;
//}
//
//float getShadow(float2 point, float2 lightPos) {
//    float2 lightDir = lightPos - point;
//    float dist2light = length(lightDir);
//    for (float i=0.; i < 300.; i++) {
//        float distAlongRay = dist2light * (i / 300.);
//        float2 currentPoint = point + lightDir * distAlongRay;
//        float d2scene = distanceToScene(currentPoint);
//        if (d2scene <= 0.) { return 0.; }
//    }
//    return 1.;
//}

fragment float4 fragmentMainBlurVerical(VertexOutDoublePass vertexOut [[stage_in]], texture2d<float> texture [[texture((int)DoublePassDefines::FragmentTexture)]]) {
    constexpr sampler samp = sampler(mag_filter::linear, min_filter::linear, mip_filter::linear, coord::normalized,
                                     r_address::repeat, t_address::repeat, s_address::repeat);
    return (texture.sample(samp, vertexOut.uv) +
            texture.sample(samp, vertexOut.uv + float2(0., -2./800.)) +
            texture.sample(samp, vertexOut.uv + float2(0., -1./800.)) +
            texture.sample(samp, vertexOut.uv + float2(0., 1./800.)) +
            texture.sample(samp, vertexOut.uv + float2(0., 2./800.)))/5.;
}

fragment float4 fragmentMainBlurHorizontal(VertexOutDoublePass vertexOut [[stage_in]], texture2d<float> texture [[texture((int)DoublePassDefines::FragmentTexture)]]) {
    constexpr sampler samp = sampler(mag_filter::linear, min_filter::linear, mip_filter::linear, coord::normalized,
                                     r_address::repeat, t_address::repeat, s_address::repeat);
    return (texture.sample(samp, vertexOut.uv) +
            texture.sample(samp, vertexOut.uv + float2(-2./800., 0.)) +
            texture.sample(samp, vertexOut.uv + float2(-1./800., 0.)) +
            texture.sample(samp, vertexOut.uv + float2(1./800., 0.)) +
            texture.sample(samp, vertexOut.uv + float2(2./800., 0.)))/5.;
}

fragment float4 fragmentMainDefault(VertexOutDoublePass vertexOut [[stage_in]], texture2d<float> texture [[texture((int)DoublePassDefines::FragmentTexture)]]) {
    constexpr sampler samp = sampler(mag_filter::linear, min_filter::linear, mip_filter::linear, coord::normalized,
                                     r_address::repeat, t_address::repeat, s_address::repeat);
    return texture.sample(samp, vertexOut.uv);
}





float distToSphere(Ray ray, Sphere s) {
  return length(ray.origin - s.center) - s.radius;
}

float distToPlane(Ray ray, Plane plane) {
  return ray.origin.y - plane.yCoord;
}

float differenceOp(float d0, float d1) {
  return max(d0, -d1);
}

float unionOp(float d0, float d1) {
  return min(d0, d1);
}

float distToScene(Ray r) {
  // 1
  Plane p = Plane{0.0};
  float d2p = distToPlane(r, p);
  // 2
  Sphere s1 = Sphere{float3(2.0), 2.0};
  Sphere s2 = Sphere{float3(0.0, 4.0, 0.0), 4.0};
  Sphere s3 = Sphere{float3(0.0, 4.0, 0.0), 3.9};
  // 3
  Ray repeatRay = r;
  repeatRay.origin = fract(r.origin / 4.0) * 4.0;
  // 4
  float d2s1 = distToSphere(repeatRay, s1);
  float d2s2 = distToSphere(r, s2);
  float d2s3 = distToSphere(r, s3);
  // 5
  float dist = differenceOp(d2s2, d2s3);
  dist = differenceOp(dist, d2s1);
  dist = unionOp(d2p, dist);
  return dist;
}

float3 getNormal(Ray ray) {
  float2 eps = float2(0.001, 0.0);
  float3 n = float3(
    distToScene(Ray{ray.origin + eps.xyy, ray.direction}) -
    distToScene(Ray{ray.origin - eps.xyy, ray.direction}),
    distToScene(Ray{ray.origin + eps.yxy, ray.direction}) -
    distToScene(Ray{ray.origin - eps.yxy, ray.direction}),
    distToScene(Ray{ray.origin + eps.yyx, ray.direction}) -
    distToScene(Ray{ray.origin - eps.yyx, ray.direction}));
  return normalize(n);
}

float lighting(VertexOut ray, float3 normal, Light light) {
  float3 lightRay = normalize(light.position - float3(0., 4., -12.));
  float diffuse = max(0.0, dot(normal, lightRay));
  float3 reflectedRay = reflect(normalize(float3(ray.posBef.xy, 1.)), normal);
  float specular = max(0.0, dot(reflectedRay, lightRay));
  specular = pow(specular, 200.0);
  return diffuse + specular;
}


float shadow(VertexOut ray, Light light) {
    float3 lightDir = light.position - float3(0., 4., -12.);
    float lightDist = length(lightDir);
    lightDir = normalize(lightDir);
    float distAlongRay = 0.01;
    for (int i=0; i<100; i++) {
        Ray lightRay = {float3(0., 4., -12.) + lightDir * distAlongRay, lightDir};
        float dist = distToScene(lightRay);
        if (dist < 0.001) {
            return 0.0;
            break;
        }
        distAlongRay += dist;
        if (distAlongRay > lightDist) { break; }
    }
    return 1.0;
}





fragment float4 fragmentMain(VertexOut current [[stage_in]],
                             constant int& lightType[[buffer(FragmentLightType)]],
                             constant struct PointLight& punctualLight [[buffer(PointLight)]],
                             constant struct DirectionalLight& directionalLight [[buffer(DirectionalLight)]],
                             constant struct Material& material [[buffer(Material)]],
                             texture2d<float> texture [[texture(FragmentTexture)]],
                             texture2d<float> normalMap [[texture(NormalMap)]],
                             texture2d<float> roughnessMap [[texture(RoughnessMap)]],
                             texture2d<float> displacementMap [[texture(DisplacementMap)]],
                             texture2d<float> aoMap [[texture(aoMap)]],
                             constant bool2& useTexture [[buffer(UseTexture)]],
                             constant float& time [[buffer(Time)]])
{
    constexpr sampler samp = sampler(mag_filter::linear, min_filter::linear, mip_filter::linear, coord::normalized,
                                     r_address::repeat, t_address::repeat, s_address::repeat);
    float4 color;
    
    float3 normalFromMap = 2.0 * normalMap.sample(samp, current.texCoors).xyz - 1.0;

    // Convert normals from tangent space to object space
    float3x3 tbn = float3x3(normalize(current.tangent), normalize(current.bitangent), normalize(normalFromMap));
    float3 normal = normalize(tbn * normalFromMap);
    
//    return float4(normal, 1.);
    
    float roughness;
    float ao;
//    return float4(normal, 0.5*0.5*1);
//     return float4(current.position.z);
 if (useTexture[0]) {
     color = texture.sample(samp, current.texCoors);
     roughness = roughnessMap.sample(samp, current.texCoors).r;
     ao = aoMap.sample(samp, current.texCoors).r;
 }
 else {
     color = current.color;
     normal = normalize(current.normals);
     roughness = 1.;
 }
   
   float displacement = displacementMap.sample(samp, current.texCoors).r;

   current.posBef.xyz += normal * displacement;
 
 
 if (lightType == 1) {
     float3 lightVector = punctualLight.position - current.posBef.xyz;
     float distance = length(lightVector);

     lightVector = normalize(lightVector);

     float diffuse = max(dot(normal, lightVector), 0.0);

     float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);
     float3 reflectionDirection = reflect(-lightVector, normal);
     
     // Modify specular calculation based on roughness
     float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), 32.0 - roughness * 32.0);

     // Modify ambient lighting based on AO
     float ambient = 9.0 - ao; // Invert AO for better results (adjust as needed)

     float attenuation = 1.0 / (punctualLight.constantAttenuation +
                                punctualLight.linearAttenuation * distance +
                                punctualLight.quadraticAttenuation * (distance * distance));

     float3 finalColor = ((diffuse + specular) * punctualLight.color * punctualLight.intensity + ambient) * attenuation * color.rgb;

     return float4(finalColor, 1.0);
 }
 else if (lightType == 2) {

     float3 lightDirection = normalize(directionalLight.direction);
     float diffuse = max(dot(normal, -lightDirection), 0.0);

     float3 viewDirection = normalize(float3(0.0, 0.0, 1.0) - current.posBef.xyz);

     float3 reflectionDirection = reflect(lightDirection, normal);

     // Modify specular calculation based on roughness
     float specular = pow(max(dot(viewDirection, reflectionDirection), 0.0), material.shininess - roughness * material.shininess);

     // Modify ambient lighting based on AO
     float ambient = 1.0 - ao; // Invert AO for better results (adjust as needed)

     float3 ambientColor = material.ambientColor * ambient;
     float3 diffuseColor = material.diffuseColor * directionalLight.color * diffuse;
     float3 specularColor = material.specularColor * directionalLight.color * specular;

     float3 finalColor = ambientColor + diffuseColor + specularColor;

     return float4(finalColor * color.rgb, 1.0);
 }
 return color;
}
