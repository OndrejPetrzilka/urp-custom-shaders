#ifndef UNIVERSAL_LIT_META_PASS_INCLUDED
#define UNIVERSAL_LIT_META_PASS_INCLUDED

#include "LitInjectInterface.hlsl"

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UniversalMetaPass.hlsl"

half4 UniversalFragmentMetaLit(Varyings input) : SV_Target
{
    PRE_FRAG(input.positionCS, input.uv, (EXTRA_VARYINGS)0);

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    MetaInput metaInput;
    metaInput.Albedo = brdfData.diffuse + brdfData.specular * brdfData.roughness * 0.5;
    metaInput.Emission = surfaceData.emission;
    return UniversalFragmentMeta(input, metaInput);
}
#endif
