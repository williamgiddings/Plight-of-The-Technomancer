Shader "VAT_Soft_SG"
{
    Properties
    {
        _color( "Color", Color ) = ( 1, 1, 1, 0 )
        _PositionMap( "Position Map", 2D ) = "grey" {}
        _NormalMap( "Normal Map", 2D ) = "grey" {}
        _ColorMap( "Color Map", 2D ) = "grey" {}
        Texture2D_042ea5f01b094db2a7c7eeadbdf86838( "Normal Map(Geometry)", 2D ) = "white" {}
        Vector1_31d060fcf784414c9fe62cb1a0b32aed( "Metallic", Float ) = 0
        Texture2D_aafefde336df4819ad8ca1e591cef3f8( "Roughness", 2D ) = "white" {}
        _speed( "Speed", Float ) = 0
        _numOfFrames( "Number Of Frames", Float ) = 0
        _posMin( "Position Min", Float ) = 0
        _posMax( "Position Max", Float ) = 0
        _paddedX( "Padded Ratio X", Float ) = 1
        _paddedY( "Padded Ratio Y", Float ) = 1
        _packNormal( "Pack Normals", Float ) = 1
        _frameStart( "FrameStartOffset", Float ) = 0
        _AlbedoBoost( "AlbedoBoost", Float ) = 1
        unity_Lightmaps( "unity_Lightmaps", 2DArray ) = "" {}
        unity_LightmapsInd( "unity_LightmapsInd", 2DArray ) = "" {}
        unity_ShadowMasks( "unity_ShadowMasks", 2DArray ) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    UnityTexture2D _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
    float4 _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0 = SAMPLE_TEXTURE2D( _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.tex, _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_R_4 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.r;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_G_5 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.g;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_B_6 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.b;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_A_7 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.a;
    float _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0 = Vector1_31d060fcf784414c9fe62cb1a0b32aed;
    UnityTexture2D _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
    float4 _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 = SAMPLE_TEXTURE2D( _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.tex, _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_R_4 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.r;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_G_5 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.g;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_B_6 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.b;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_A_7 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.a;
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.NormalTS = ( _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.xyz );
    surface.Emission = float3( 0, 0, 0 );
    surface.Metallic = _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0;
    surface.Smoothness = ( _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 ).x;
    surface.Occlusion = 1;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );



    output.TangentSpaceNormal = float3( 0.0f, 0.0f, 1.0f );


    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
    #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    UnityTexture2D _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
    float4 _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0 = SAMPLE_TEXTURE2D( _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.tex, _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_R_4 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.r;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_G_5 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.g;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_B_6 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.b;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_A_7 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.a;
    float _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0 = Vector1_31d060fcf784414c9fe62cb1a0b32aed;
    UnityTexture2D _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
    float4 _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 = SAMPLE_TEXTURE2D( _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.tex, _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_R_4 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.r;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_G_5 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.g;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_B_6 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.b;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_A_7 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.a;
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.NormalTS = ( _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.xyz );
    surface.Emission = float3( 0, 0, 0 );
    surface.Metallic = _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0;
    surface.Smoothness = ( _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 ).x;
    surface.Occlusion = 1;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );



    output.TangentSpaceNormal = float3( 0.0f, 0.0f, 1.0f );


    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.normalWS;
        output.interp1.xyzw = input.tangentWS;
        output.interp2.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.normalWS = input.interp0.xyz;
        output.tangentWS = input.interp1.xyzw;
        output.texCoord0 = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    UnityTexture2D _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
    float4 _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0 = SAMPLE_TEXTURE2D( _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.tex, _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_R_4 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.r;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_G_5 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.g;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_B_6 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.b;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_A_7 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.a;
    surface.NormalTS = ( _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.xyz );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );



    output.TangentSpaceNormal = float3( 0.0f, 0.0f, 1.0f );


    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.Emission = float3( 0, 0, 0 );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    UnityTexture2D _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
    float4 _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0 = SAMPLE_TEXTURE2D( _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.tex, _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_R_4 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.r;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_G_5 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.g;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_B_6 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.b;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_A_7 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.a;
    float _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0 = Vector1_31d060fcf784414c9fe62cb1a0b32aed;
    UnityTexture2D _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
    float4 _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 = SAMPLE_TEXTURE2D( _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.tex, _Property_a2e45ea3a1b842edae773cbe79ba35d8_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_R_4 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.r;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_G_5 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.g;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_B_6 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.b;
    float _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_A_7 = _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0.a;
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.NormalTS = ( _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.xyz );
    surface.Emission = float3( 0, 0, 0 );
    surface.Metallic = _Property_ea1e171b5b284d79ad7bba45e9a0a30b_Out_0;
    surface.Smoothness = ( _SampleTexture2D_ee2d14ae4376456e9b8a8f9064033cb1_RGBA_0 ).x;
    surface.Occlusion = 1;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );



    output.TangentSpaceNormal = float3( 0.0f, 0.0f, 1.0f );


    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.normalWS;
        output.interp1.xyzw = input.tangentWS;
        output.interp2.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.normalWS = input.interp0.xyz;
        output.tangentWS = input.interp1.xyzw;
        output.texCoord0 = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    UnityTexture2D _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0 = UnityBuildTexture2DStructNoScale( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
    float4 _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0 = SAMPLE_TEXTURE2D( _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.tex, _Property_bf1db9fe827b4cbe8208fa7030828cbb_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_R_4 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.r;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_G_5 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.g;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_B_6 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.b;
    float _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_A_7 = _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.a;
    surface.NormalTS = ( _SampleTexture2D_246fbbdba2ba4b398add838d645fb35e_RGBA_0.xyz );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );



    output.TangentSpaceNormal = float3( 0.0f, 0.0f, 1.0f );


    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.Emission = float3( 0, 0, 0 );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend One Zero
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _AlphaClip 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD3
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv3 : TEXCOORD3;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
        float4 uv3;
        float3 TimeParameters;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float4 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings( Varyings input )
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings( PackedVaryings input )
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START( UnityPerMaterial )
float4 _color;
float4 _PositionMap_TexelSize;
float4 _NormalMap_TexelSize;
float4 _ColorMap_TexelSize;
float4 Texture2D_042ea5f01b094db2a7c7eeadbdf86838_TexelSize;
float Vector1_31d060fcf784414c9fe62cb1a0b32aed;
float4 Texture2D_aafefde336df4819ad8ca1e591cef3f8_TexelSize;
float _speed;
float _numOfFrames;
float _posMin;
float _posMax;
float _paddedX;
float _paddedY;
float _packNormal;
float _frameStart;
float _AlbedoBoost;
CBUFFER_END

// Object and Global properties
TEXTURE2D( _PositionMap );
SAMPLER( sampler_PositionMap );
TEXTURE2D( _NormalMap );
SAMPLER( sampler_NormalMap );
TEXTURE2D( _ColorMap );
SAMPLER( sampler_ColorMap );
TEXTURE2D( Texture2D_042ea5f01b094db2a7c7eeadbdf86838 );
SAMPLER( samplerTexture2D_042ea5f01b094db2a7c7eeadbdf86838 );
TEXTURE2D( Texture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( samplerTexture2D_aafefde336df4819ad8ca1e591cef3f8 );
SAMPLER( SamplerState_Point_Repeat );
SAMPLER( SamplerState_Linear_Repeat );

// Graph Functions

// 525930d0be09fc620044473ce231d9ab
#include "Assets/Resources/Shaders/VAT/VAT_Utilies.hlsl"

struct Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621
{
    float3 ObjectSpacePosition;
    half4 uv3;
};

void SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( UnityTexture2D Texture2D_1143A1DC, UnityTexture2D Texture2D_F5CBEA25, UnityTexture2D Texture2D_B5072043, float2 Vector2_E3700737, float Vector1_552FEE5D, float Vector1_19166AAE, float Vector1_2DE7B84B, float2 Vector2_553205BE, float Boolean_AC06C132, float Vector1_2bdad9e464fb481b9c259d6c112a3c10, Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 IN, out float3 OutPosition_1, out float3 OutNormal_2 )
{
    float4 _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0 = IN.uv3;
    UnityTexture2D _Property_c890a436e0999e8b92ff25ef918961ca_Out_0 = Texture2D_1143A1DC;
    UnityTexture2D _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0 = Texture2D_F5CBEA25;
    UnityTexture2D _Property_e89a8d49897c818f9ff41b94435181b0_Out_0 = Texture2D_B5072043;
    float2 _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0 = Vector2_E3700737;
    float _Property_a3da3a99f5893e878545771dcb078117_Out_0 = Vector1_552FEE5D;
    float _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0 = Vector1_19166AAE;
    float _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0 = Vector1_2DE7B84B;
    float2 _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0 = Vector2_553205BE;
    float _Property_038e857a0ae3678c8ba31915759be03d_Out_0 = Boolean_AC06C132;
    float _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0 = Vector1_2bdad9e464fb481b9c259d6c112a3c10;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    float3 _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
    VAT_Soft_float( IN.ObjectSpacePosition, ( _UV_fbc532da35c4f2889b8dc8ac240088b1_Out_0.xy ), UnityBuildSamplerStateStruct( SamplerState_Point_Repeat ).samplerstate, _Property_c890a436e0999e8b92ff25ef918961ca_Out_0.tex, _Property_25f9529b368d2a8695ae98a14a437a1f_Out_0.tex, _Property_e89a8d49897c818f9ff41b94435181b0_Out_0.tex, _Property_53bc1789012ded8b8921cbec4b0926b8_Out_0, _Property_a3da3a99f5893e878545771dcb078117_Out_0, _Property_04ca0a15900f568a8c4a3d894f6fdabb_Out_0, _Property_fca5fd53d6b17387b02619753cd29bf7_Out_0, _Property_f1ded7c5962c7787b9471fa0b1034a7b_Out_0, _Property_038e857a0ae3678c8ba31915759be03d_Out_0, _Property_4e168a262f7d47d98c7c080d4afa7eb8_Out_0, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13, _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14 );
    OutPosition_1 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outPosition_13;
    OutNormal_2 = _VATSoftCustomFunction_682697516834c28485f8160ee2bcd1e7_outNormal_14;
}

void Unity_Multiply_float( float4 A, float4 B, out float4 Out )
{
    Out = A * B;
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction( VertexDescriptionInputs IN )
{
    VertexDescription description = ( VertexDescription )0;
    UnityTexture2D _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0 = UnityBuildTexture2DStructNoScale( _PositionMap );
    UnityTexture2D _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0 = UnityBuildTexture2DStructNoScale( _NormalMap );
    UnityTexture2D _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0 = _posMin;
    float _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 = _posMax;
    float2 _Vector2_55a06afafa025488bef334b16b45bd40_Out_0 = float2( _Property_6452e9616bed7b89843fa5eb13b40a70_Out_0, _Property_2a6c5bbb5d711486b6111850dcffdf8d_Out_0 );
    float _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0 = _speed;
    float _Property_cbb9c534c410898da797be3af31bc1c7_Out_0 = _numOfFrames;
    float _Property_628b451a3763458b96195d2a187ea6f9_Out_0 = _paddedX;
    float _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 = _paddedY;
    float2 _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0 = float2( _Property_628b451a3763458b96195d2a187ea6f9_Out_0, _Property_1fc24e69b21f4b848d1996fe49539965_Out_0 );
    float _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0 = _packNormal;
    float _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0 = _frameStart;
    Bindings_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.ObjectSpacePosition = IN.ObjectSpacePosition;
    _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e.uv3 = IN.uv3;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    float3 _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    SG_VATSoftSubGraph_d0dcfe85b46057a459a0aa20680d5621( _Property_f72ce1a87e6f4c889fb07eb97a8140e1_Out_0, _Property_ba89238e5c325d87bb208fb45214cb5d_Out_0, _Property_c1e63576cbbb62878459e82ee50e7f45_Out_0, _Vector2_55a06afafa025488bef334b16b45bd40_Out_0, IN.TimeParameters.x, _Property_9b5e294b6cc9aa8cbe2eee01a4b59ba9_Out_0, _Property_cbb9c534c410898da797be3af31bc1c7_Out_0, _Vector2_6f5b077ec7a0458b97a2140a696da6ea_Out_0, _Property_67887bfacb80f18487cb6cb7aab5a003_Out_0, _Property_dbf4bfd11bfe4f92af23e578f8c4aa6c_Out_0, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1, _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2 );
    description.Position = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutPosition_1;
    description.Normal = _VATSoftSubGraph_34143905b0e040e8ae53de5fb350008e_OutNormal_2;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
    float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction( SurfaceDescriptionInputs IN )
{
    SurfaceDescription surface = ( SurfaceDescription )0;
    float _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0 = _AlbedoBoost;
    UnityTexture2D _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0 = UnityBuildTexture2DStructNoScale( _ColorMap );
    float4 _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0 = SAMPLE_TEXTURE2D( _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.tex, _Property_d0772936d2f9488d91c0a0f2c1d8e508_Out_0.samplerstate, IN.uv0.xy );
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_R_4 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.r;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_G_5 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.g;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_B_6 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.b;
    float _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_A_7 = _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0.a;
    float4 _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0 = _color;
    float4 _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2;
    Unity_Multiply_float( _SampleTexture2D_e3ece4ab39af4d3eaa5e135dbcd8cacf_RGBA_0, _Property_64903b36ecea4e68b5ffe8f035f6c792_Out_0, _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2 );
    float4 _Multiply_3d53278506d2476faea1814523cd956b_Out_2;
    Unity_Multiply_float( ( _Property_50fd07bb1c0249fd9f7229d8f2eb3981_Out_0.xxxx ), _Multiply_263e78c7409c459b8abca3f3a825ba42_Out_2, _Multiply_3d53278506d2476faea1814523cd956b_Out_2 );
    surface.BaseColor = ( _Multiply_3d53278506d2476faea1814523cd956b_Out_2.xyz );
    surface.Alpha = 1;
    surface.AlphaClipThreshold = 0.5;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs( Attributes input )
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE( VertexDescriptionInputs, output );

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;
    output.uv3 = input.uv3;
    output.TimeParameters = _TimeParameters.xyz;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs( Varyings input )
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE( SurfaceDescriptionInputs, output );





    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        CustomEditor "ShaderGraph.PBRMasterGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
}