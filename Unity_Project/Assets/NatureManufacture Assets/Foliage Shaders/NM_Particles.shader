Shader "NatureManufacture/URP/NM_Particles"
{
    Properties
    {
        _AlphaClipThreshold("Alpha Clip Threshold", Range(0, 1)) = 1
        [ToggleUI]_ReadAlbedo("Read Albedo", Float) = 1
        [NoScaleOffset]_ParticleMask("Particle (RGB) Mask (A)", 2D) = "white" {}
        _TilingandOffset("Tiling and Offset", Vector) = (1, 1, 0, 0)
        _ParticleColor("Particle Color (RGB) Alpha (A)", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_ParticleNormal("Particle Normal", 2D) = "white" {}
        _ParticleNormalScale("Particle Normal Scale", Float) = 1
        _AO("_AO", Range(0, 1)) = 1
        Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 1
        _CullFarStart("Cull Far Start", Float) = 40
        _CullFarDistance("Cull Far Distance", Float) = 80
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
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
             float4 color;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float2 interp7 : INTERP7;
             float3 interp8 : INTERP8;
             float4 interp9 : INTERP9;
             float4 interp10 : INTERP10;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            output.interp5.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp7.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp8.xyz =  input.sh;
            #endif
            output.interp9.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp10.xyzw =  input.shadowCoord;
            #endif
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp6.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp7.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp8.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp9.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp10.xyzw;
            #endif
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0 = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2);
            float _Property_be59c3635ef71989b75c052aecf52145_Out_0 = Metallic;
            float _Property_548711527280108ba78da51c84df9cdd_Out_0 = _Smoothness;
            float _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0 = _AO;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Property_be59c3635ef71989b75c052aecf52145_Out_0;
            surface.Smoothness = _Property_548711527280108ba78da51c84df9cdd_Out_0;
            surface.Occlusion = _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ _RENDER_PASS_ENABLED
        #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
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
             float4 color;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float2 interp7 : INTERP7;
             float3 interp8 : INTERP8;
             float4 interp9 : INTERP9;
             float4 interp10 : INTERP10;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            output.interp5.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp7.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp8.xyz =  input.sh;
            #endif
            output.interp9.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp10.xyzw =  input.shadowCoord;
            #endif
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp6.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp7.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp8.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp9.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp10.xyzw;
            #endif
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0 = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2);
            float _Property_be59c3635ef71989b75c052aecf52145_Out_0 = Metallic;
            float _Property_548711527280108ba78da51c84df9cdd_Out_0 = _Smoothness;
            float _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0 = _AO;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Property_be59c3635ef71989b75c052aecf52145_Out_0;
            surface.Smoothness = _Property_548711527280108ba78da51c84df9cdd_Out_0;
            surface.Occlusion = _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
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
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0 = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2);
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            output.interp4.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
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
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
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
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile _ _LIGHT_LAYERS
        #pragma multi_compile _ DEBUG_DISPLAY
        #pragma multi_compile _ _LIGHT_COOKIES
        #pragma multi_compile _ _CLUSTERED_RENDERING
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
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
             float4 color;
             float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
             float3 interp5 : INTERP5;
             float2 interp6 : INTERP6;
             float2 interp7 : INTERP7;
             float3 interp8 : INTERP8;
             float4 interp9 : INTERP9;
             float4 interp10 : INTERP10;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
            output.interp5.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy =  input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.interp7.xy =  input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp8.xyz =  input.sh;
            #endif
            output.interp9.xyzw =  input.fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.interp10.xyzw =  input.shadowCoord;
            #endif
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.interp6.xy;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.interp7.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp8.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp9.xyzw;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.interp10.xyzw;
            #endif
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
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
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0 = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2);
            float _Property_be59c3635ef71989b75c052aecf52145_Out_0 = Metallic;
            float _Property_548711527280108ba78da51c84df9cdd_Out_0 = _Smoothness;
            float _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0 = _AO;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = _Property_be59c3635ef71989b75c052aecf52145_Out_0;
            surface.Smoothness = _Property_548711527280108ba78da51c84df9cdd_Out_0;
            surface.Occlusion = _Property_68e6b5b8cb4009839a4e9ab06935bddb_Out_0;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 color : COLOR;
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
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleNormal);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0 = SAMPLE_TEXTURE2D(_Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.tex, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.samplerstate, _Property_cb615fde5f2b1a8a9b50b5883068ce4e_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0);
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_R_4 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.r;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_G_5 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.g;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_B_6 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.b;
            float _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_A_7 = _SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.a;
            float _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0 = _ParticleNormalScale;
            float3 _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_66ff0728c4c081869d8d0572905fdc78_RGBA_0.xyz), _Property_4bd339f3ffc5228c9432f9e4e283a729_Out_0, _NormalStrength_d97258b37529438aab592806c892e47e_Out_2);
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.NormalTS = _NormalStrength_d97258b37529438aab592806c892e47e_Out_2;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float4 interp3 : INTERP3;
             float4 interp4 : INTERP4;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.texCoord1;
            output.interp3.xyzw =  input.texCoord2;
            output.interp4.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.texCoord1 = input.interp2.xyzw;
            output.texCoord2 = input.interp3.xyzw;
            output.color = input.interp4.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
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
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 color;
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
             float3 AbsoluteWorldSpacePosition;
             float4 uv0;
             float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
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
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
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
        CBUFFER_START(UnityPerMaterial)
        float _AlphaClipThreshold;
        float _ReadAlbedo;
        float4 _ParticleMask_TexelSize;
        float4 _TilingandOffset;
        float4 _ParticleColor;
        float4 _ParticleNormal_TexelSize;
        float _ParticleNormalScale;
        float _AO;
        float Metallic;
        float _Smoothness;
        float _CullFarStart;
        float _CullFarDistance;
        CBUFFER_END
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_ParticleMask);
        SAMPLER(sampler_ParticleMask);
        TEXTURE2D(_ParticleNormal);
        SAMPLER(sampler_ParticleNormal);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0 = _ReadAlbedo;
            float4 _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0 = _ParticleColor;
            UnityTexture2D _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0 = UnityBuildTexture2DStructNoScale(_ParticleMask);
            float4 _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0 = _TilingandOffset;
            float _Split_0f89628531900280a6fdfeed464d7db0_R_1 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[0];
            float _Split_0f89628531900280a6fdfeed464d7db0_G_2 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[1];
            float _Split_0f89628531900280a6fdfeed464d7db0_B_3 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[2];
            float _Split_0f89628531900280a6fdfeed464d7db0_A_4 = _Property_9a06a82b5234ca8da64b8863e3198f47_Out_0[3];
            float4 _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4;
            float3 _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5;
            float2 _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_B_3, _Split_0f89628531900280a6fdfeed464d7db0_A_4, 0, 0, _Combine_b5e51e12d953b181b56901d50c50cd23_RGBA_4, _Combine_b5e51e12d953b181b56901d50c50cd23_RGB_5, _Combine_b5e51e12d953b181b56901d50c50cd23_RG_6);
            float4 _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4;
            float3 _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5;
            float2 _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6;
            Unity_Combine_float(_Split_0f89628531900280a6fdfeed464d7db0_R_1, _Split_0f89628531900280a6fdfeed464d7db0_G_2, 0, 0, _Combine_a4549e90842d0d89a5980eed4127a17b_RGBA_4, _Combine_a4549e90842d0d89a5980eed4127a17b_RGB_5, _Combine_a4549e90842d0d89a5980eed4127a17b_RG_6);
            float4 _UV_426d4b83acf75988818b968670a6c706_Out_0 = IN.uv0;
            float2 _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2;
            Unity_Multiply_float2_float2(_Combine_a4549e90842d0d89a5980eed4127a17b_RG_6, (_UV_426d4b83acf75988818b968670a6c706_Out_0.xy), _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2);
            float2 _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2;
            Unity_Add_float2(_Combine_b5e51e12d953b181b56901d50c50cd23_RG_6, _Multiply_09e3239284e58a819e5c73b96fb31e2a_Out_2, _Add_e53a48f9915b4e889dac945a4bc07c54_Out_2);
            float4 _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.tex, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.samplerstate, _Property_050570b6d15f5a89a50c5b64557e83c9_Out_0.GetTransformedUV(_Add_e53a48f9915b4e889dac945a4bc07c54_Out_2));
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_R_4 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.r;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_G_5 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.g;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_B_6 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.b;
            float _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7 = _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0.a;
            float4 _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2;
            Unity_Multiply_float4_float4(_Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_RGBA_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2);
            float4 _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3;
            Unity_Branch_float4(_Property_9b33c3a3dd587d81bcaadf5c3e8e2139_Out_0, _Multiply_f22b0e82bf38858f9627ec75be736488_Out_2, _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0, _Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3);
            float4 _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2;
            Unity_Multiply_float4_float4(_Branch_7e6e999b3c067c8183b3c2ccd4c96025_Out_3, IN.VertexColor, _Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2);
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_R_1 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[0];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_G_2 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[1];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_B_3 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[2];
            float _Split_b3351ea0323f53819c49f9ebc3297dfd_A_4 = _Property_a6ebfd9e9e390a84adc9a5ac2878ed22_Out_0[3];
            float _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2;
            Unity_Multiply_float_float(_Split_b3351ea0323f53819c49f9ebc3297dfd_A_4, _SampleTexture2D_356ddb977af9e783a0ae5de93a2eaadd_A_7, _Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2);
            float _Split_23be1e5860e84d8aa9ab147605cf804c_R_1 = IN.VertexColor[0];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_G_2 = IN.VertexColor[1];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_B_3 = IN.VertexColor[2];
            float _Split_23be1e5860e84d8aa9ab147605cf804c_A_4 = IN.VertexColor[3];
            float _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2;
            Unity_Multiply_float_float(_Multiply_e61e9448f82c2e859496c6b0602d12ec_Out_2, _Split_23be1e5860e84d8aa9ab147605cf804c_A_4, _Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2);
            float _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2;
            Unity_Distance_float3(IN.AbsoluteWorldSpacePosition, _WorldSpaceCameraPos, _Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2);
            float _Property_560bbe7f2d950d86813d2af8016de375_Out_0 = _CullFarStart;
            float _Subtract_5373207144af5c888442613c746c85a5_Out_2;
            Unity_Subtract_float(_Distance_c31266dd3c1cbc8da0fbb0c82374c4c4_Out_2, _Property_560bbe7f2d950d86813d2af8016de375_Out_0, _Subtract_5373207144af5c888442613c746c85a5_Out_2);
            float _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0 = _CullFarDistance;
            float _Divide_009a8503c50859889678476fb7b96335_Out_2;
            Unity_Divide_float(_Subtract_5373207144af5c888442613c746c85a5_Out_2, _Property_5c2be4447f31f183a95cf310d59a8e92_Out_0, _Divide_009a8503c50859889678476fb7b96335_Out_2);
            float _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1;
            Unity_Saturate_float(_Divide_009a8503c50859889678476fb7b96335_Out_2, _Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1);
            float _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3;
            Unity_Clamp_float(_Saturate_51a6a57f8077718dba6d20c7b805b7c9_Out_1, 0, 1, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3);
            float _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            Unity_Multiply_float_float(_Multiply_77f9032f668542839b3eef41d33b1d9e_Out_2, _Clamp_48c9114a974fb6818f9ae0b331b23260_Out_3, _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2);
            float _Property_e8300f3c175a8584b8b8045b9854d400_Out_0 = _AlphaClipThreshold;
            surface.BaseColor = (_Multiply_c8d68b77f252d48e9b1ae2fb14982d91_Out_2.xyz);
            surface.Alpha = _Multiply_1a7b1dba7c0456889c0fb47e3af3fe36_Out_2;
            surface.AlphaClipThreshold = _Property_e8300f3c175a8584b8b8045b9854d400_Out_0;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
            output.uv0 = input.texCoord0;
            output.VertexColor = input.color;
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
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}