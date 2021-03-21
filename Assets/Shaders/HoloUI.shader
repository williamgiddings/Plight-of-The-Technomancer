shader "UI/HoloUI"
{
Properties
{
    [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
    _Color("Tint", Color) = (1,1,1,1)

    _StencilComp("Stencil Comparison", Float) = 8
    _Stencil("Stencil ID", Float) = 0
    _StencilOp("Stencil Operation", Float) = 0
    _StencilWriteMask("Stencil Write Mask", Float) = 255
    _StencilReadMask("Stencil Read Mask", Float) = 255

    _ColorMask("Color Mask", Float) = 15

        // General
    _Brightness("Brightness", Range(0.1, 6.0)) = 3.0
    _Alpha("Alpha", Range(0.0, 1.0)) = 1.0
    _Direction("Direction", Vector) = (0,1,0,0)
    // Rim/Fresnel
    _RimColor("Rim Color", Color) = (1,1,1,1)
    _RimPower("Rim Power", Range(0.1, 10)) = 5.0
    // Scanline
    _ScanTiling("Scan Tiling", Range(0.01, 10.0)) = 0.05
    _ScanSpeed("Scan Speed", Range(-2.0, 2.0)) = 1.0
    // Glow
    _GlowTiling("Glow Tiling", Range(0.01, 1.0)) = 0.05
    _GlowSpeed("Glow Speed", Range(-10.0, 10.0)) = 1.0
    // Glitch
    _GlitchSpeed("Glitch Speed", Range(0, 50)) = 1.0
    _GlitchIntensity("Glitch Intensity", Float) = 0
    // Alpha Flicker
    _FlickerTex("Flicker Control Texture", 2D) = "white" {}
    _FlickerSpeed("Flicker Speed", Range(0.01, 100)) = 1.0

                // Settings
        [HideInInspector] _Fold("__fld", Float) = 1.0


    [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
}

SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }

        Stencil
        {
            Ref[_Stencil]
            Comp[_StencilComp]
            Pass[_StencilOp]
            ReadMask[_StencilReadMask]
            WriteMask[_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest[unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask[_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma shader_feature _SCAN_ON
            #pragma shader_feature _GLOW_ON
            #pragma shader_feature _GLITCH_ON

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 worldNormal : NORMAL;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            sampler2D _FlickerTex;
            float4 _Direction;
            float4 _RimColor;
            float _RimPower;
            float _GlitchSpeed;
            float _GlitchIntensity;
            float _Brightness;
            float _Alpha;
            float _ScanTiling;
            float _ScanSpeed;
            float _GlowTiling;
            float _GlowSpeed;
            float _FlickerSpeed;


            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.viewDir = normalize(UnityWorldSpaceViewDir(OUT.worldPosition.xyz));
                OUT.worldNormal = UnityObjectToWorldNormal(v.normal);

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                half dirVertex = (dot(IN.worldPosition, normalize(float4(_Direction.xyz, 1.0))) + 1) / 2;

                // Scanlines
                float scan = step(frac(dirVertex * _ScanTiling + _Time.w * _ScanSpeed), 0.5) * 0.65;
                // Glow
                float glow = frac(dirVertex * _GlowTiling - _Time.x * _GlowSpeed);
                

                // Flicker
                fixed4 flicker = tex2D(_FlickerTex, _Time * _FlickerSpeed);

                half rim = 1.0 - saturate(dot(IN.viewDir, IN.worldNormal));
                fixed4 rimColor = (color/2) * pow(rim, _RimPower);

                fixed4 col = color + (glow * 0.35 * color) + rimColor;
                col.a = color.a * _Alpha * (scan + rim + glow) * flicker;


                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
                
                #ifdef UNITY_UI_ALPHACLIP
                clip(color.a - 0.001);
                #endif


                return col * _Brightness;
            }
        ENDCG
        }
    }
}