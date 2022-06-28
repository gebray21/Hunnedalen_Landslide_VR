Shader "Breach/FlowSurface"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Culling", Float) = 2

        // TODO: compress heightmap + normalmap into one texture?
        _TessellationHeightmap ("Tessellation Heightmap", 2D) = "black" {}
        _TessellationNormalmap ("Tessellation Normalmap", 2D) = "bump" {}
        _TessellationRate ("Tessellation Rate", Range(1, 50)) = 10
        _TessellationDistance ("Tessellation Distance", Range(10, 100)) = 50
        _TessellationTextureScale ("Tessellation Texture Scale", Range(0, 2)) = 0.1
        _TessellationHeightmapStrength ("Tessellation Displacement Strength", Range(0, 2)) = 0.5
        _TessellationAnimationSpeed ("Tessellation Animation Speed", Range(0, 2)) = 1
        _TessellationFlowSpeed ("Tessellation Flow Speed", Range(0, 5)) = 1

        _ColorBase("Base Color", Color) = (0.0752581, 0.1239587, 0.1320755, 1)
        _SurfaceTexture("Surface Texture", 2D) = "white" {}
        _SurfaceTextureNM ("Surface Texture NM", 2D) = "bump" {}
        _SurfaceTextureScale ("Surface Texture Scale", Range(0, 2)) = 1
        _SurfaceTextureCoeff("Surface Albedo Texture Coefficient", Range(0, 1)) = 3
        _SurfaceAnimationSpeed ("Surface Animation Speed", Range(0, 2)) = 1
        _SurfaceFlowSpeed ("Surface Flow Speed", Range(0, 5)) = 1
        _SurfaceSmoothness("Surface Smoothness", Range(0, 1)) = 1
        _SurfaceSpecular("Surface Specular", Range(0, 1)) = 0.005
        _SurfaceOcclusion("Surface Occlusion", Range(0, 1)) = 0.5
        _SurfaceAlpha("Surface Alpha", Range(0, 1)) = 0.98
        _SurfaceAlphaBackside("Surface Alpha Underwater", Range(0, 1)) = 0.5
        _SurfaceAlphaFadeDistance("Surface Alpha Fade Distance", Range(0.01, 10)) = 0.5
        _SurfaceFogFadeDistance("Surface Fog Fade Distance", Range(0, 10)) = 5
        _SurfaceRefraction("Surface Refraction Index", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+1" "IngoreProjector"="True" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull [_Culling]

        Pass
        {
            HLSLPROGRAM
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            #pragma multi_compile_fog
            #pragma multi_compile_instancing


            #pragma require geometry
            #pragma require tessellation
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            // app -> vertex
            struct appdata {
                float4 vertexOS : POSITION;
                float3 normalOS : NORMAL;
                float2 heightDelta : TEXCOORD0;
                float2 flowDir0 : TEXCOORD1;
                float2 flowDir1 : TEXCOORD2;
                float3 nextNormalOS : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // vertex -> tesselation
            struct v2t {
            	float3 positionVS : INTERNALTESSPOS;
                float4 positionWSAndFogFactor : TEXCOORD0;
                float2 flowDir : TEXCOORD1;
                float3 baseNormalWS : NORMAL;
                half3 tangentWS : TEXCOORD2;
                half3 bitangentWS : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            // tesselation -> fragment
            struct t2f {
                float4 vertex : POSITION;
                float4 positionWSAndFogFactor : TEXCOORD0;
                float3 positionVS : TEXCOORD1;
                float2 flowDir : TEXCOORD2;
                float3 baseNormalWS : NORMAL0;
                float3 normalWS : NORMAL1;
                half3 tangentWS : TEXCOORD3;
                half3 bitangentWS : TEXCOORD4;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            struct tesFactors {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
            };


            float _AnimTime;

            TEXTURE2D(_TessellationHeightmap);
            SAMPLER(sampler_TessellationHeightmap);
            TEXTURE2D(_TessellationNormalmap);
            SAMPLER(sampler_TessellationNormalmap);
            float _TessellationRate, _TessellationDistance;
            float _TessellationTextureScale, _AnimationSpeed, _TessellationHeightmapStrength;
            float _TessellationAnimationSpeed, _TessellationFlowSpeed;

            float _SurfaceTextureCoeff;
            TEXTURE2D(_SurfaceTexture);
            SAMPLER(sampler_SurfaceTexture);
            TEXTURE2D(_SurfaceTextureNM);
            SAMPLER(sampler_SurfaceTextureNM);
            float _SurfaceTextureScale;
            float3 _ColorBase;
            float _SurfaceAnimationSpeed, _SurfaceFlowSpeed;
            float _SurfaceSmoothness, _SurfaceSpecular, _SurfaceOcclusion;
            float _SurfaceAlpha, _SurfaceAlphaBackside, _SurfaceAlphaFadeDistance;
            float _SurfaceFogFadeDistance;
            float _SurfaceRefraction;


            float Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(Normal, ViewDir))), Power);
            }


            v2t vert(appdata v) {
                v2t o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                float3 pos = float3(v.vertexOS.x, v.vertexOS.y, v.vertexOS.z + _AnimTime * v.heightDelta.x);
                o.flowDir = lerp(v.flowDir0, v.flowDir1, _AnimTime);

                float3 normalOS = lerp(v.normalOS, v.nextNormalOS, _AnimTime);
                float4 tangentOS = float4(cross(normalOS, float3(0, 0, -1)), 1); // Surface normal is never gonna point straing down

                VertexPositionInputs vertexInput = GetVertexPositionInputs(pos);

                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(normalOS, tangentOS);

                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                o.positionWSAndFogFactor = float4(vertexInput.positionWS.xyz, fogFactor);
                o.positionVS = vertexInput.positionVS;
                o.baseNormalWS = vertexNormalInput.normalWS;
                o.tangentWS = vertexNormalInput.tangentWS;
                o.bitangentWS = vertexNormalInput.bitangentWS;

                return o;
            }

            [domain("tri")]
            [outputcontrolpoints(3)]
            [outputtopology("triangle_cw")]
            [partitioning("fractional_odd")]
            [patchconstantfunc("computeTesFactors")]
            v2t hull(InputPatch<v2t, 3> patch, uint id : SV_OutputControlPointID)
            {
                return patch[id];
            }

            float tessFactor(v2t a, v2t b)
            {
                float dist = (length(a.positionVS) + length(b.positionVS)) * 0.5;
                return (_TessellationRate+1) - _TessellationRate*smoothstep(5, _TessellationDistance, dist);
            }

            tesFactors computeTesFactors(InputPatch<v2t, 3> patch)
            {
            	tesFactors f;
                f.edge[0] = tessFactor(patch[1], patch[2]);
                f.edge[1] = f.edge[0];//tessFactor(patch[2], patch[0]);
                f.edge[2] = f.edge[0];//tessFactor(patch[0], patch[1]);
            	f.inside = (f.edge[0] + f.edge[1] + f.edge[2]) / 3;
            	return f;
            }


            // https://catlikecoding.com/unity/tutorials/flow/texture-distortion/
            float3 flowUVW (float2 uv, float2 flowVector, float time)
            {
	            float progress = frac(time);
	            float3 uvw;
	            uvw.xy = uv - flowVector * progress;
	            uvw.z = 1 - abs(1 - 2 * progress);
	            return uvw;
            }

            float4 sampleTessTextures(float distMult, float2 pos, float2 flowDir, float time, float phase)
            {
                float3 tessUV = flowUVW(pos + sin(0.1*_TessellationAnimationSpeed*_TessellationFlowSpeed*time)*(float2(flowDir.y, -flowDir.x)), _TessellationFlowSpeed * flowDir, _TessellationAnimationSpeed*time + phase);
                tessUV.xy *= _TessellationTextureScale;

                // We stretch a lot ourside of tesselation range to prevent flickering caused by normals changing too fast
                tessUV.xy *= saturate(0.1 + smoothstep(0.05, 0.1, distMult));

                float height = SAMPLE_TEXTURE2D_LOD(_TessellationHeightmap, sampler_TessellationHeightmap, tessUV, 0).r;
                float3 normal = UnpackNormal(SAMPLE_TEXTURE2D_LOD(_TessellationNormalmap, sampler_TessellationNormalmap, tessUV, 0));
                return tessUV.z*float4(normal, height);
            }

            [domain("tri")]
            t2f domain(tesFactors factors, OutputPatch<v2t, 3> patch, float3 barycentricCoordinates : SV_DomainLocation)
            {
                t2f data;
                UNITY_SETUP_INSTANCE_ID(patch[0]);
                UNITY_TRANSFER_INSTANCE_ID(patch[0], data);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(data);

                #define DOMAIN_PROGRAM_INTERPOLATE(fieldName) data.fieldName = \
                    patch[0].fieldName * barycentricCoordinates.x + \
                    patch[1].fieldName * barycentricCoordinates.y + \
                    patch[2].fieldName * barycentricCoordinates.z;

                DOMAIN_PROGRAM_INTERPOLATE(positionWSAndFogFactor);
                DOMAIN_PROGRAM_INTERPOLATE(flowDir);
                DOMAIN_PROGRAM_INTERPOLATE(positionVS);
                DOMAIN_PROGRAM_INTERPOLATE(baseNormalWS);
                DOMAIN_PROGRAM_INTERPOLATE(tangentWS);
                DOMAIN_PROGRAM_INTERPOLATE(bitangentWS);

                // Falls off from 1 to 0 quadratically
                float distMult = saturate(length(data.positionVS) / _TessellationDistance);
                distMult = -(distMult*distMult)+1;

                float4 normalAndHeight1 = sampleTessTextures(distMult, data.positionWSAndFogFactor.xz, data.flowDir, _Time.y + 0.05*data.positionWSAndFogFactor.y, 0);
                float4 normalAndHeight2 = sampleTessTextures(distMult, data.positionWSAndFogFactor.xz, data.flowDir, _Time.y + 0.05*data.positionWSAndFogFactor.y, 0.5);
                float4 normalAndHeight = normalAndHeight1 + normalAndHeight2;
                float3 normalWS = TransformTangentToWorld(normalAndHeight.xyz, half3x3(data.tangentWS, data.bitangentWS, data.baseNormalWS));

                float3 newPos = data.positionWSAndFogFactor.xyz;
                newPos.y += _TessellationHeightmapStrength * distMult * length(data.flowDir) * normalAndHeight.w;
                data.positionWSAndFogFactor.xyz = newPos;
                data.vertex = TransformWorldToHClip(newPos);
                data.positionVS = TransformWorldToView(newPos);
                data.normalWS = normalWS;
                data.tangentWS = normalize(cross(normalWS, float3(0,-1,0))); // Water surface is never gonna point straight downwards
                data.bitangentWS = normalize(cross(normalWS, data.tangentWS));

                return data;
            }


            float sampleSurfaceTextures(float2 pos, float2 flowDir, float time, float phase, out float3 color, out float3 normal)
            {
                float3 uv = flowUVW(pos + sin(0.1*_SurfaceAnimationSpeed*_SurfaceFlowSpeed*time + phase)*(float2(flowDir.y, -flowDir.x)), _SurfaceFlowSpeed * flowDir, _SurfaceAnimationSpeed*time + phase);
                uv.xy *= _SurfaceTextureScale;
                color = SAMPLE_TEXTURE2D(_SurfaceTexture, sampler_SurfaceTexture, uv.xy);
                normal = UnpackNormal(SAMPLE_TEXTURE2D(_SurfaceTextureNM, sampler_SurfaceTextureNM, uv.xy));
                return uv.z;
            }

            float4 frag(t2f i) : SV_Target
            {
                float3 surfaceColor0, surfaceNormal0, surfaceNormal1, surfaceColor1;
                float blend = sampleSurfaceTextures(i.positionWSAndFogFactor.xz, i.flowDir, _Time.y + 0.05*i.positionWSAndFogFactor.y, 0, surfaceColor0, surfaceNormal0);
                sampleSurfaceTextures(i.positionWSAndFogFactor.xz, i.flowDir, _Time.y + 0.05*i.positionWSAndFogFactor.y, 0.5, surfaceColor1, surfaceNormal1);
                float3 surfaceColor = lerp(surfaceColor1, surfaceColor0, blend);
                float3 surfaceNormal = lerp(surfaceNormal1, surfaceNormal0, blend);

                float3 normalWS = normalize(TransformTangentToWorld(surfaceNormal, half3x3(i.tangentWS, i.bitangentWS, i.normalWS)));

                //return float4(normalWS, 1);

                // Water Depth
                float2 screenUV = i.vertex.xy / _ScaledScreenParams.xy;
                float sceneZ = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                float surfaceZ = abs(i.positionVS.z);
                float depth = (sceneZ - surfaceZ);

                // Water Refraction
                float2 refractUV = screenUV + _SurfaceRefraction*saturate(depth)*surfaceNormal.xy;
                float3 background = SampleSceneColor(refractUV);

                // basically using tesselation normalmap as noise texture that gets stronger the steeper the slope
                float surfaceCoeff =  smoothstep(0, 1-_SurfaceTextureCoeff, saturate(1-dot(i.normalWS, float3(0, 1, 0))));

                // Onto the lighting
                SurfaceData surfaceData;
                surfaceData.albedo = _ColorBase + surfaceCoeff * surfaceColor;
                surfaceData.specular = _SurfaceSpecular;
                surfaceData.metallic = 0;
                surfaceData.smoothness = _SurfaceSmoothness;
                surfaceData.normalTS = surfaceNormal;
                surfaceData.emission = lerp(background, _ColorBase, saturate(rcp(_SurfaceFogFadeDistance) * depth)); // underwater fog
                surfaceData.occlusion = _SurfaceOcclusion;
                surfaceData.alpha = 1;
                surfaceData.clearCoatMask = 0;
                surfaceData.clearCoatSmoothness = 1;

                InputData inputData;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = normalize(GetCameraPositionWS() - i.positionWSAndFogFactor.xyz);
                inputData.positionWS = i.positionWSAndFogFactor.xyz;
                inputData.positionCS = i.vertex;
                inputData.normalizedScreenSpaceUV = screenUV;
                inputData.fogCoord = i.positionWSAndFogFactor.w;
                inputData.vertexLighting = half3(0, 0, 0);
                inputData.tangentToWorld = half3x3(i.tangentWS, i.bitangentWS, i.normalWS);

                LightingData lightingData = CreateLightingData(inputData, surfaceData);

                BRDFData brdfData;
                InitializeBRDFData(surfaceData, brdfData);

                half3 bakedGI = SampleSH(normalWS);

                lightingData.giColor = GlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, inputData.viewDirectionWS);
                lightingData.mainLightColor = LightingPhysicallyBased(brdfData, GetMainLight(), normalWS, inputData.viewDirectionWS);

                half4 litColor = CalculateFinalColor(lightingData, surfaceData.alpha);
                float surfaceAlpha = lerp(_SurfaceAlphaBackside, _SurfaceAlpha, saturate(1+sign(dot(i.baseNormalWS, inputData.viewDirectionWS))));
                litColor.rgb = lerp(background, litColor, surfaceAlpha * saturate(rcp(_SurfaceAlphaFadeDistance) * depth));
                litColor.rgb = MixFog(litColor.rgb, inputData.fogCoord);
                return half4(litColor.rgb, 1);
            }
            ENDHLSL
        }
    }
}
