#ifndef UNIVERSAL_PARTICLES_LIT_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_PARTICLES_LIT_DEPTH_ONLY_PASS_INCLUDED

#include "ParticleInjectInterface.hlsl"

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#if defined(_ALPHATEST_ON)
    #define INPUT_TEX_VS input.texcoords.xy
    #define INPUT_TEX_PS input.texcoord.xy
    #define INPUT_COLOR input.color
#else
    float2 tmpTex = float2(0,0);
    #define INPUT_TEX_VS tmpTex
    #define INPUT_TEX_PS tmpTex
    #define INPUT_COLOR half4(0,0,0,0)
#endif

VaryingsDepthOnlyParticle DepthOnlyVertex(AttributesDepthOnlyParticle input)
{
    VaryingsDepthOnlyParticle output = (VaryingsDepthOnlyParticle)0;
    UNITY_SETUP_INSTANCE_ID(input);
    float2 tmpTex = float2(0,0);
    PRE_VERTEX(input.vertex, float3(0,0,0), float3(0,0,0), INPUT_TEX_VS, INPUT_COLOR);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
    POST_VERTEX_TRANSFORM(vertexInput, INPUT_TEX_VS);
    output.clipPos = vertexInput.positionCS;

    #if defined(_ALPHATEST_ON)
        output.color = GetParticleColor(input.color);

        #if defined(_FLIPBOOKBLENDING_ON)
            #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                GetParticleTexcoords(output.texcoord, output.texcoord2AndBlend, input.texcoords.xyxy, 0.0);
            #else
                GetParticleTexcoords(output.texcoord, output.texcoord2AndBlend, input.texcoords, input.texcoordBlend);
            #endif
        #else
            GetParticleTexcoords(output.texcoord, input.texcoords.xy);
        #endif
    #endif

    return output;
}

half DepthOnlyFragment(VaryingsDepthOnlyParticle input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float2 tmpTex = float2(0,0);
    PRE_FRAG(input.clipPos, INPUT_TEX_PS, INPUT_COLOR);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Check if we need to discard...
    #if defined(_ALPHATEST_ON)
        float2 uv = input.texcoord;
        half4 vertexColor = input.color;
        half4 baseColor = _BaseColor;

        #if defined(_FLIPBOOKBLENDING_ON)
            float3 blendUv = input.texcoord2AndBlend;
        #else
            float3 blendUv = float3(0,0,0);
        #endif

        half4 albedo = BlendTexture(TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap), uv, blendUv) * baseColor;
        half4 colorAddSubDiff = half4(0, 0, 0, 0);
        #if defined (_COLORADDSUBDIFF_ON)
            colorAddSubDiff = _BaseColorAddSubDiff;
        #endif

        albedo = MixParticleColor(albedo, vertexColor, colorAddSubDiff);
        AlphaDiscard(albedo.a, _Cutoff);
    #endif

    return input.clipPos.z;
}

#endif // UNIVERSAL_PARTICLES_LIT_DEPTH_ONLY_PASS_INCLUDED
