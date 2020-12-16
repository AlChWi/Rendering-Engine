

#include <metal_stdlib>
using namespace metal;
#import "Common.h"

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float3 normal;
};

float3x3 upperLeft(float4x4 matrix) {
    float3 x = matrix.columns[0].xyz;
    float3 y = matrix.columns[1].xyz;
    float3 z = matrix.columns[2].xyz;
    return float3x3(x, y, z);
}

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexIn.position,
        .worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz,
        .worldNormal = uniforms.normalMatrix * vertexIn.normal,
        .normal = upperLeft(uniforms.projectionMatrix) * upperLeft(uniforms.viewMatrix) * upperLeft(uniforms.modelMatrix) * vertexIn.normal,
    };
    return out;
}

fragment float4 fragment_main(VertexOut in  [[stage_in]],
                              constant Light *lights [[ buffer(2) ]],
                              constant FragmentUniforms &fragmentUniforms [[ buffer(3) ]]) {
    float3 baseColor = float3(1, 1, 1);
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);
    
    float3 normalDirection = normalize(in.worldNormal);
    for (uint i = 0; i < fragmentUniforms.lightCouunt; i++) {
        Light light = lights[i];
        if (light.type == Sunlight) {
            float3 lightDirection = normalize(-light.position);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            diffuseColor += light.color * baseColor * diffuseIntensity;
            if (diffuseIntensity > 0) {
                float3 reflection = reflect(lightDirection, normalDirection);
                float3 cameraDirection = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
                float specularIntensity = pow(saturate(-dot(reflection, cameraDirection)), materialShininess);
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
            }
        }
        else if (light.type == Ambientlight) {
            ambientColor += light.color * light.intensity;
        }
        else if (light.type == Pointlight) {
            float distanceToLight = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(in.worldPosition - light.position);
            float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * distanceToLight + light.attenuation.z * distanceToLight * distanceToLight);
            float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
            float3 color = light.color * baseColor * diffuseIntensity;
            color *= attenuation;
            diffuseColor += color;
        }
        else if (light.type == Spotlight) {
            float distanceToLight = distance(light.position, in.worldPosition);
            float3 lightDirection = normalize(in.worldPosition - light.position);
            float3 coneDirection = normalize(light.coneDirection);
            float spotResult = dot(lightDirection, coneDirection);
            if (spotResult > cos(light.coneAngle)) {
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * distanceToLight + light.attenuation.z * distanceToLight * distanceToLight);
                attenuation *= pow(spotResult, light.coneAttenuation);
                float diffuseIntensity = saturate(-dot(lightDirection, normalDirection));
                float3 color = light.color * baseColor * diffuseIntensity;
                color *= attenuation;
                diffuseColor += color;
            }
        }
    }
    float3 color = diffuseColor + ambientColor + specularColor;
    
    return float4(color, 1);
}

