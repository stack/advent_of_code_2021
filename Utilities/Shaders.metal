//
//  Shaders.metal
//  Utilities
//
//  Created by Stephen H. Gerstacker on 2021-12-01.
//  Copyright © 2021 Stephen H. Gerstacker. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float positionX;
    float positionY;
    float textureX;
    float textureY;
} Vertex;

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} RasterData;

vertex RasterData VertexShader(const device Vertex* vertices [[ buffer(0) ]],
                               constant vector_float2* bufferSize [[ buffer(1) ]],
                               constant vector_float2* screenSize [[ buffer(2) ]],
                               uint vertexID [[ vertex_id ]])
{
    Vertex vertexIn = vertices[vertexID];
    RasterData out;

    float2 position = { vertexIn.positionX, vertexIn.positionY };
    position *= *bufferSize;

    float2 viewPort = *screenSize;
    float2 textureSize = *bufferSize;

    float2 delta = viewPort / textureSize;
    float deltaMin = delta.x < delta.y ? delta.x : delta.y;

    float2 targetSize = textureSize * deltaMin;
    float2 offset = (viewPort - targetSize) / 2;

    position = offset + (position * deltaMin);

    float2 normalized = position / viewPort * float2(2.0, -2.0) - float2(1.0, -1.0);

    out.position = float4(normalized, 0.0, 1.0);
    out.textureCoordinate = { vertexIn.textureX, vertexIn.textureY };

    return out;
}

fragment float4 FragmentShader(RasterData in [[stage_in]],
                               texture2d<half> colorTexture [[texture(0) ]])
{
    constexpr sampler textureSampler(mag_filter::nearest, min_filter::nearest);

    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);

    return float4(colorSample);
}
