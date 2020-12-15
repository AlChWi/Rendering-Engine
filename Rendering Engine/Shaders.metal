

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

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    float3 baseColor = float3(1, 1, 1);
    
    return float4(baseColor, 1);
}

