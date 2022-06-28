Shader "NatureManufacture Shaders/Water/Water River"
{
    Properties
    {
		_GlobalTiling("Global Tiling", Range( 0.001 , 100)) = 1
		_UVVDirection1UDirection0("UV - V Direction (1) U Direction (0)", Int) = 0
		_WaterMainSpeed("Water Main Speed", Vector) = (0.01,0,0,0)
		_WaterMixSpeed("Water Mix Speed", Vector) = (0.01,0.05,0,0)
		_SmallCascadeMainSpeed("Small Cascade Main Speed", Vector) = (0,0.08,0,0)
		_SmallCascadeMixSpeed("Small Cascade Mix Speed", Vector) = (0.04,0.08,0,0)
		_BigCascadeMainSpeed("Big Cascade Main Speed", Vector) = (0,0.24,0,0)
		_BigCascadeMixSpeed("Big Cascade Mix Speed", Vector) = (0.02,0.28,0,0)
		_WaterDepth("Water Depth", Range( 0 , 1)) = 0
		_ShalowFalloff("Shalow Falloff", Float) = 0
		_ShalowDepth("Shalow Depth", Range( 0 , 10)) = 0.7
		_ShalowColor("Shalow Color", Color) = (1,1,1,0)
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_WaterDeepTranslucencyPower("Water Deep Translucency Power", Range( 0 , 10)) = 1
		_WaterShalowTranslucencyPower("Water Shalow Translucency Power", Range( 0 , 10)) = 1
		_WaterSpecularClose("Water Specular Close", Range( 0 , 1)) = 0
		_WaterSpecularFar("Water Specular Far", Range( 0 , 1)) = 0
		_WaterSpecularThreshold("Water Specular Threshold", Range( 0 , 10)) = 1
		_WaterSmoothness("Water Smoothness", Float) = 0
		_Distortion("Distortion", Float) = 0.5
		_WaterFalloffBorder("Water Falloff Border", Range( 0 , 10)) = 0
		_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_SmallCascadeAngle("Small Cascade Angle", Range( 0.001 , 90)) = 90
		_SmallCascadeAngleFalloff("Small Cascade Angle Falloff", Range( 0 , 80)) = 5
		_SmallCascadeNormal("Small Cascade Normal", 2D) = "bump" {}
		_SmallCascadeNormalScale("Small Cascade Normal Scale", Float) = 0
		_SmallCascade("Small Cascade", 2D) = "white" {}
		_SmallCascadeColor("Small Cascade Color", Vector) = (1,1,1,0)
		_SmallCascadeFoamFalloff("Small Cascade Foam Falloff", Range( 0 , 10)) = 0
		_SmallCascadeSmoothness("Small Cascade Smoothness", Float) = 0
		_SmallCascadeSpecular("Small Cascade Specular", Range( 0 , 1)) = 0
		_BigCascadeAngle("Big Cascade Angle", Range( 0.001 , 90)) = 90
		_BigCascadeAngleFalloff("Big Cascade Angle Falloff", Range( 0 , 80)) = 15
		_BigCascadeNormal("Big Cascade Normal", 2D) = "bump" {}
		_BigCascadeNormalScale("Big Cascade Normal Scale", Float) = 0
		_BigCascade("Big Cascade", 2D) = "white" {}
		_BigCascadeColor("Big Cascade Color", Vector) = (1,1,1,0)
		_BigCascadeFoamFalloff("Big Cascade Foam Falloff", Range( 0 , 10)) = 0
		_BigCascadeTransparency("Big Cascade Transparency", Range( 0 , 1)) = 0
		_BigCascadeSmoothness("Big Cascade Smoothness", Float) = 0
		_BigCascadeSpecular("Big Cascade Specular", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_SmallCascadeNoisePower("Small Cascade Noise Power", Range( 0 , 10)) = 2.71
		_BigCascadeNoisePower("Big Cascade Noise Power", Range( 0 , 10)) = 2.71
		_NoiseSpeed("Noise Speed", Vector) = (-0.2,-0.5,0,0)
		_Foam("Foam", 2D) = "white" {}
		_FoamSpeed("Foam Speed", Vector) = (-0.001,0.018,0,0)
		_FoamColor("Foam Color", Vector) = (1,1,1,0)
		_FoamDepth("Foam Depth", Range( 0 , 10)) = 1
		_FoamFalloff("Foam Falloff", Range( -100 , 0)) = -10.9
		_FoamSpecular("Foam Specular", Range( 0 , 1)) = 0
		_FoamSmoothness("Foam Smoothness", Float) = 0
		_AOPower("AO Power", Range( 0 , 1)) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="LightweightPipeline" "RenderType"="Transparent" "Queue"="Geometry+999" }

		Cull Off
		HLSLINCLUDE
		#pragma target 3.0
		ENDHLSL
		
        Pass
        {
			
        	Tags { "LightMode"="LightweightForward" }

        	Name "Base"
			Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
            
        	HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

        	// -------------------------------------
            // Lightweight Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            
        	// -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
        	#pragma fragment frag

        	#define REQUIRE_OPAQUE_TEXTURE 1
        	#define _NORMALMAP 1
        	#define _SPECULAR_SETUP 1


        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        	#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
        	#include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform float _NormalScale;
			uniform int _UVVDirection1UDirection0;
			uniform float2 _WaterMixSpeed;
			uniform sampler2D _WaterNormal;
			uniform float4 _WaterNormal_ST;
			uniform float _GlobalTiling;
			uniform float2 _WaterMainSpeed;
			uniform float _SmallCascadeNormalScale;
			uniform float2 _SmallCascadeMixSpeed;
			uniform sampler2D _SmallCascadeNormal;
			uniform float4 _SmallCascadeNormal_ST;
			uniform float2 _SmallCascadeMainSpeed;
			uniform half _SmallCascadeAngle;
			uniform float _SmallCascadeAngleFalloff;
			uniform half _BigCascadeAngle;
			uniform float _BigCascadeAngleFalloff;
			uniform float _BigCascadeNormalScale;
			uniform sampler2D _BigCascadeNormal;
			uniform float2 _BigCascadeMixSpeed;
			uniform float4 _BigCascadeNormal_ST;
			uniform float2 _BigCascadeMainSpeed;
			uniform float _Distortion;
			uniform float4 _DeepColor;
			uniform float4 _ShalowColor;
			uniform sampler2D _CameraDepthTexture;
			uniform float _ShalowDepth;
			uniform float _ShalowFalloff;
			uniform float _BigCascadeTransparency;
			uniform float3 _FoamColor;
			uniform float _FoamDepth;
			uniform float _FoamFalloff;
			uniform sampler2D _Foam;
			uniform float2 _FoamSpeed;
			uniform float4 _Foam_ST;
			uniform sampler2D _SmallCascade;
			uniform float2 _NoiseSpeed;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float _SmallCascadeNoisePower;
			uniform float3 _SmallCascadeColor;
			uniform float _SmallCascadeFoamFalloff;
			uniform sampler2D _BigCascade;
			uniform float _BigCascadeNoisePower;
			uniform float3 _BigCascadeColor;
			uniform float _BigCascadeFoamFalloff;
			uniform float _WaterDeepTranslucencyPower;
			uniform float _WaterShalowTranslucencyPower;
			uniform float _WaterSpecularFar;
			uniform float _WaterSpecularClose;
			uniform float _WaterSpecularThreshold;
			uniform float _FoamSpecular;
			uniform float _SmallCascadeSpecular;
			uniform float _BigCascadeSpecular;
			uniform float _WaterSmoothness;
			uniform float _FoamSmoothness;
			uniform float _SmallCascadeSmoothness;
			uniform float _BigCascadeSmoothness;
			uniform half _AOPower;
			uniform float _WaterDepth;
			uniform float _WaterFalloffBorder;
			CBUFFER_END
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
                float4 ase_tangent : TANGENT;
                float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct GraphVertexOutput
            {
                float4 clipPos                : SV_POSITION;
                float4 lightmapUVOrVertexSH	  : TEXCOORD0;
        		half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
            	float4 shadowCoord            : TEXCOORD2;
				float4 tSpace0					: TEXCOORD3;
				float4 tSpace1					: TEXCOORD4;
				float4 tSpace2					: TEXCOORD5;
				float4 ase_texcoord7 : TEXCOORD7;
				float4 ase_texcoord8 : TEXCOORD8;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            	UNITY_VERTEX_OUTPUT_STEREO
            };


            GraphVertexOutput vert (GraphVertexInput v)
        	{
        		GraphVertexOutput o = (GraphVertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
            	UNITY_TRANSFER_INSTANCE_ID(v, o);
        		UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord8.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord8.zw = 0;
				v.vertex.xyz +=  float3( 0, 0, 0 ) ;
				v.ase_normal =  v.ase_normal ;

        		// Vertex shader outputs defined by graph
                float3 lwWNormal = TransformObjectToWorldNormal(v.ase_normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float3 lwWTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				float3 lwWBinormal = normalize(cross(lwWNormal, lwWTangent) * v.ase_tangent.w);
				o.tSpace0 = float4(lwWTangent.x, lwWBinormal.x, lwWNormal.x, lwWorldPos.x);
				o.tSpace1 = float4(lwWTangent.y, lwWBinormal.y, lwWNormal.y, lwWorldPos.y);
				o.tSpace2 = float4(lwWTangent.z, lwWBinormal.z, lwWNormal.z, lwWorldPos.z);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                
         		// We either sample GI from lightmap or SH.
        	    // Lightmap UV and vertex SH coefficients use the same interpolator ("float2 lightmapUV" for lightmap or "half3 vertexSH" for SH)
                // see DECLARE_LIGHTMAP_OR_SH macro.
        	    // The following funcions initialize the correct variable with correct data
        	    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
        	    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

        	    half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
        	    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
        	    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
        	    o.clipPos = vertexInput.positionCS;

        	#ifdef _MAIN_LIGHT_SHADOWS
        		o.shadowCoord = GetShadowCoord(vertexInput);
        	#endif
        		return o;
        	}

        	half4 frag (GraphVertexOutput IN ) : SV_Target
            {
            	UNITY_SETUP_INSTANCE_ID(IN);

        		float3 WorldSpaceNormal = normalize(float3(IN.tSpace0.z,IN.tSpace1.z,IN.tSpace2.z));
				float3 WorldSpaceTangent = float3(IN.tSpace0.x,IN.tSpace1.x,IN.tSpace2.x);
				float3 WorldSpaceBiTangent = float3(IN.tSpace0.y,IN.tSpace1.y,IN.tSpace2.y);
				float3 WorldSpacePosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldSpaceViewDirection = SafeNormalize( _WorldSpaceCameraPos.xyz  - WorldSpacePosition );
    
				float4 screenPos = IN.ase_texcoord7;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
				float2 appendResult163 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
				int Direction723 = _UVVDirection1UDirection0;
				float2 appendResult706 = (float2(_WaterMixSpeed.y , _WaterMixSpeed.x));
				float2 uv_WaterNormal = IN.ase_texcoord8.xy * _WaterNormal_ST.xy + _WaterNormal_ST.zw;
				float Globaltiling771 = ( 1.0 / _GlobalTiling );
				float2 temp_output_773_0 = ( uv_WaterNormal * Globaltiling771 );
				float2 panner612 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _WaterMixSpeed :  appendResult706 ) + temp_output_773_0);
				float2 WaterSpeedValueMix516 = panner612;
				float2 appendResult705 = (float2(_WaterMainSpeed.y , _WaterMainSpeed.x));
				float2 panner611 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _WaterMainSpeed :  appendResult705 ) + temp_output_773_0);
				float2 WaterSpeedValueMain614 = panner611;
				float3 temp_output_24_0 = BlendNormal( UnpackNormalmapRGorAG( tex2D( _WaterNormal, WaterSpeedValueMix516 ), ( _NormalScale * 1.2 ) ) , UnpackNormalmapRGorAG( tex2D( _WaterNormal, WaterSpeedValueMain614 ), _NormalScale ) );
				float2 appendResult709 = (float2(_SmallCascadeMixSpeed.y , _SmallCascadeMixSpeed.x));
				float2 uv_SmallCascadeNormal = IN.ase_texcoord8.xy * _SmallCascadeNormal_ST.xy + _SmallCascadeNormal_ST.zw;
				float2 temp_output_775_0 = ( uv_SmallCascadeNormal * Globaltiling771 );
				float2 panner597 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _SmallCascadeMixSpeed :  appendResult709 ) + temp_output_775_0);
				float2 SmallCascadeSpeedValueMix433 = panner597;
				float2 appendResult710 = (float2(_SmallCascadeMainSpeed.y , _SmallCascadeMainSpeed.x));
				float2 panner598 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _SmallCascadeMainSpeed :  appendResult710 ) + temp_output_775_0);
				float2 SmallCascadeSpeedValueMain600 = panner598;
				float clampResult259 = clamp( WorldSpaceNormal.y , 0.0 , 1.0 );
				float temp_output_258_0 = ( _SmallCascadeAngle / 45.0 );
				float clampResult263 = clamp( ( clampResult259 - ( 1.0 - temp_output_258_0 ) ) , 0.0 , 2.0 );
				float clampResult584 = clamp( ( clampResult263 * ( 1.0 / temp_output_258_0 ) ) , 0.0 , 1.0 );
				float clampResult507 = clamp( WorldSpaceNormal.y , 0.0 , 1.0 );
				float temp_output_504_0 = ( _BigCascadeAngle / 45.0 );
				float clampResult509 = clamp( ( clampResult507 - ( 1.0 - temp_output_504_0 ) ) , 0.0 , 2.0 );
				float clampResult583 = clamp( ( clampResult509 * ( 1.0 / temp_output_504_0 ) ) , 0.0 , 1.0 );
				float clampResult514 = clamp( pow( abs( ( 1.0 - clampResult583 ) ) , _BigCascadeAngleFalloff ) , 0.0 , 1.0 );
				float clampResult285 = clamp( ( pow( abs( ( 1.0 - clampResult584 ) ) , _SmallCascadeAngleFalloff ) - clampResult514 ) , 0.0 , 1.0 );
				float3 lerpResult330 = lerp( temp_output_24_0 , BlendNormal( UnpackNormalmapRGorAG( tex2D( _SmallCascadeNormal, SmallCascadeSpeedValueMix433 ), _SmallCascadeNormalScale ) , UnpackNormalmapRGorAG( tex2D( _SmallCascadeNormal, SmallCascadeSpeedValueMain600 ), _SmallCascadeNormalScale ) ) , clampResult285);
				float2 appendResult712 = (float2(_BigCascadeMixSpeed.y , _BigCascadeMixSpeed.x));
				float2 uv_BigCascadeNormal = IN.ase_texcoord8.xy * _BigCascadeNormal_ST.xy + _BigCascadeNormal_ST.zw;
				float2 temp_output_777_0 = ( uv_BigCascadeNormal * Globaltiling771 );
				float2 panner606 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _BigCascadeMixSpeed :  appendResult712 ) + temp_output_777_0);
				float2 BigCascadeSpeedValueMix608 = panner606;
				float2 appendResult714 = (float2(_BigCascadeMainSpeed.y , _BigCascadeMainSpeed.x));
				float2 panner607 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _BigCascadeMainSpeed :  appendResult714 ) + temp_output_777_0);
				float2 BigCascadeSpeedValueMain432 = panner607;
				float3 lerpResult529 = lerp( lerpResult330 , BlendNormal( UnpackNormalmapRGorAG( tex2D( _BigCascadeNormal, BigCascadeSpeedValueMix608 ), _BigCascadeNormalScale ) , UnpackNormalmapRGorAG( tex2D( _BigCascadeNormal, BigCascadeSpeedValueMain432 ), _BigCascadeNormalScale ) ) , clampResult514);
				float4 fetchOpaqueVal65 = SAMPLE_TEXTURE2D( _CameraOpaqueTexture, sampler_CameraOpaqueTexture, ( float3( ( appendResult163 / ase_grabScreenPosNorm.a ) ,  0.0 ) + ( lerpResult529 * _Distortion ) ).xy);
				float eyeDepth1 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
				float temp_output_89_0 = abs( ( eyeDepth1 - screenPos.w ) );
				float lerpResult761 = lerp( pow( abs( ( temp_output_89_0 + _ShalowDepth ) ) , _ShalowFalloff ) , 100.0 , ( _BigCascadeTransparency * clampResult514 ));
				float temp_output_94_0 = saturate( lerpResult761 );
				float4 lerpResult13 = lerp( _DeepColor , _ShalowColor , temp_output_94_0);
				float temp_output_113_0 = saturate( pow( abs( ( temp_output_89_0 + _FoamDepth ) ) , _FoamFalloff ) );
				float2 appendResult716 = (float2(_FoamSpeed.y , _FoamSpeed.x));
				float2 uv_Foam = IN.ase_texcoord8.xy * _Foam_ST.xy + _Foam_ST.zw;
				float2 panner116 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _FoamSpeed :  appendResult716 ) + ( uv_Foam * Globaltiling771 ));
				float temp_output_114_0 = ( temp_output_113_0 * tex2D( _Foam, panner116 ).a );
				float4 lerpResult117 = lerp( lerpResult13 , float4( _FoamColor , 0.0 ) , temp_output_114_0);
				float4 lerpResult93 = lerp( fetchOpaqueVal65 , lerpResult117 , temp_output_113_0);
				float temp_output_458_0 = ( 1.0 - temp_output_94_0 );
				float4 lerpResult390 = lerp( lerpResult93 , lerpResult13 , temp_output_458_0);
				float4 tex2DNode319 = tex2D( _SmallCascade, SmallCascadeSpeedValueMain600 );
				float2 appendResult718 = (float2(_NoiseSpeed.y , _NoiseSpeed.x));
				float2 temp_output_743_0 = (( (float)Direction723 == 1.0 ) ? _NoiseSpeed :  appendResult718 );
				float2 uv_Noise = IN.ase_texcoord8.xy * _Noise_ST.xy + _Noise_ST.zw;
				float2 temp_output_781_0 = ( uv_Noise * Globaltiling771 );
				float2 panner646 = ( _SinTime.x * ( temp_output_743_0 * float2( -1.2,-0.9 ) ) + temp_output_781_0);
				float4 tex2DNode647 = tex2D( _Noise, panner646 );
				float2 panner321 = ( _SinTime.x * temp_output_743_0 + temp_output_781_0);
				float clampResult488 = clamp( ( pow( abs( min( tex2DNode647.a , tex2D( _Noise, panner321 ).a ) ) , _SmallCascadeNoisePower ) * 20.0 ) , 0.0 , 1.0 );
				float lerpResult480 = lerp( 0.0 , tex2DNode319.a , clampResult488);
				float clampResult322 = clamp( pow( abs( tex2DNode319.a ) , _SmallCascadeFoamFalloff ) , 0.0 , 1.0 );
				float lerpResult580 = lerp( 0.0 , clampResult322 , clampResult285);
				float4 lerpResult324 = lerp( lerpResult390 , float4( ( lerpResult480 * _SmallCascadeColor ) , 0.0 ) , lerpResult580);
				float4 tex2DNode213 = tex2D( _BigCascade, BigCascadeSpeedValueMain432 );
				float clampResult758 = clamp( ( pow( abs( min( tex2DNode647.a , tex2D( _Noise, ( panner321 + float2( -0.47,0.37 ) ) ).a ) ) , _BigCascadeNoisePower ) * 20.0 ) , 0.0 , 1.0 );
				float lerpResult626 = lerp( ( tex2DNode213.a * 0.5 ) , tex2DNode213.a , clampResult758);
				float clampResult299 = clamp( pow( abs( tex2DNode213.a ) , _BigCascadeFoamFalloff ) , 0.0 , 1.0 );
				float lerpResult579 = lerp( 0.0 , clampResult299 , clampResult514);
				float4 lerpResult239 = lerp( lerpResult324 , float4( ( lerpResult626 * _BigCascadeColor ) , 0.0 ) , lerpResult579);
				
				float3 break453 = lerpResult529;
				float clampResult552 = clamp( max( break453.x , break453.y ) , 0.0 , 1.0 );
				float4 lerpResult451 = lerp( float4( 0,0,0,0 ) , _ShalowColor , clampResult552);
				float lerpResult549 = lerp( _WaterDeepTranslucencyPower , _WaterShalowTranslucencyPower , temp_output_94_0);
				float4 lerpResult459 = lerp( float4( 0,0,0,0 ) , ( lerpResult451 * lerpResult549 ) , temp_output_458_0);
				
				float lerpResult766 = lerp( _WaterSpecularFar , _WaterSpecularClose , pow( abs( temp_output_94_0 ) , _WaterSpecularThreshold ));
				float lerpResult130 = lerp( lerpResult766 , _FoamSpecular , temp_output_114_0);
				float lerpResult585 = lerp( lerpResult130 , _SmallCascadeSpecular , ( lerpResult580 * clampResult285 ));
				float lerpResult587 = lerp( lerpResult585 , _BigCascadeSpecular , ( lerpResult579 * clampResult514 ));
				float3 temp_cast_16 = (lerpResult587).xxx;
				
				float lerpResult591 = lerp( _WaterSmoothness , _FoamSmoothness , temp_output_114_0);
				float lerpResult593 = lerp( lerpResult591 , _SmallCascadeSmoothness , ( lerpResult580 * clampResult285 ));
				float lerpResult592 = lerp( lerpResult593 , _BigCascadeSmoothness , ( lerpResult579 * clampResult514 ));
				
				float lerpResult208 = lerp( 0.0 , 1.0 , pow( abs( saturate( pow( abs( temp_output_89_0 ) , _WaterDepth ) ) ) , _WaterFalloffBorder ));
				
				
		        float3 Albedo = lerpResult239.rgb;
				float3 Normal = lerpResult529;
				float3 Emission = lerpResult459.rgb;
				float3 Specular = temp_cast_16;
				float Metallic = 0;
				float Smoothness = lerpResult592;
				float Occlusion = _AOPower;
				float Alpha = lerpResult208;
				float AlphaClipThreshold = 0;

        		InputData inputData;
        		inputData.positionWS = WorldSpacePosition;

        #ifdef _NORMALMAP
        	    inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal)));
        #else
            #if !SHADER_HINT_NICE_QUALITY
                inputData.normalWS = WorldSpaceNormal;
            #else
        	    inputData.normalWS = normalize(WorldSpaceNormal);
            #endif
        #endif

        #if !SHADER_HINT_NICE_QUALITY
        	    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
        	    inputData.viewDirectionWS = WorldSpaceViewDirection;
        #else
        	    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
        #endif

        	    inputData.shadowCoord = IN.shadowCoord;

        	    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
        	    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
        	    inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

        		half4 color = LightweightFragmentPBR(
        			inputData, 
        			Albedo, 
        			Metallic, 
        			Specular, 
        			Smoothness, 
        			Occlusion, 
        			Emission, 
        			Alpha);

			#ifdef TERRAIN_SPLAT_ADDPASS
				color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
			#else
				color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
			#endif

        #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

		#if ASE_LW_FINAL_COLOR_ALPHA_MULTIPLY
				color.rgb *= color.a;
		#endif
        		return color;
            }

        	ENDHLSL
        }

		
        Pass
        {
			
        	Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _CameraDepthTexture;
			uniform float _WaterDepth;
			uniform float _WaterFalloffBorder;
			CBUFFER_END
			
			
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord7 : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
        	};

            // x: global clip space bias, y: normal world space bias
            float4 _ShadowBias;
            float3 _LightDirection;

            VertexOutput ShadowPassVertex(GraphVertexInput v)
        	{
        	    VertexOutput o;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;

        	    float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

                float invNdotL = 1.0 - saturate(dot(_LightDirection, normalWS));
                float scale = invNdotL * _ShadowBias.y;

                // normal bias is negative since we want to apply an inset normal offset
                positionWS = normalWS * scale.xxx + positionWS;
                float4 clipPos = TransformWorldToHClip(positionWS);

                // _ShadowBias.x sign depens on if platform has reversed z buffer
                clipPos.z += _ShadowBias.x;

        	#if UNITY_REVERSED_Z
        	    clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#else
        	    clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
        	#endif
                o.clipPos = clipPos;

        	    return o;
        	}

            half4 ShadowPassFragment(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

               float4 screenPos = IN.ase_texcoord7;
               float eyeDepth1 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
               float temp_output_89_0 = abs( ( eyeDepth1 - screenPos.w ) );
               float lerpResult208 = lerp( 0.0 , 1.0 , pow( abs( saturate( pow( abs( temp_output_89_0 ) , _WaterDepth ) ) ) , _WaterFalloffBorder ));
               

				float Alpha = lerpResult208;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }

            ENDHLSL
        }

		
        Pass
        {
			
        	Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }

            ZWrite On
			ColorMask 0

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform sampler2D _CameraDepthTexture;
			uniform float _WaterDepth;
			uniform float _WaterFalloffBorder;
			CBUFFER_END
			
			
           
            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };


        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;

        	    o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

				float4 screenPos = IN.ase_texcoord;
				float eyeDepth1 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
				float temp_output_89_0 = abs( ( eyeDepth1 - screenPos.w ) );
				float lerpResult208 = lerp( 0.0 , 1.0 , pow( abs( saturate( pow( abs( temp_output_89_0 ) , _WaterDepth ) ) ) , _WaterFalloffBorder ));
				

				float Alpha = lerpResult208;
				float AlphaClipThreshold = AlphaClipThreshold;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif
                return 0;
            }
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
		
        Pass
        {
			
        	Name "Meta"
            Tags { "LightMode"="Meta" }

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            

            #pragma vertex vert
            #pragma fragment frag


            #define REQUIRE_OPAQUE_TEXTURE 1


			uniform float4 _MainTex_ST;

            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.lightweight/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			CBUFFER_START(UnityPerMaterial)
			uniform float _NormalScale;
			uniform int _UVVDirection1UDirection0;
			uniform float2 _WaterMixSpeed;
			uniform sampler2D _WaterNormal;
			uniform float4 _WaterNormal_ST;
			uniform float _GlobalTiling;
			uniform float2 _WaterMainSpeed;
			uniform float _SmallCascadeNormalScale;
			uniform float2 _SmallCascadeMixSpeed;
			uniform sampler2D _SmallCascadeNormal;
			uniform float4 _SmallCascadeNormal_ST;
			uniform float2 _SmallCascadeMainSpeed;
			uniform half _SmallCascadeAngle;
			uniform float _SmallCascadeAngleFalloff;
			uniform half _BigCascadeAngle;
			uniform float _BigCascadeAngleFalloff;
			uniform float _BigCascadeNormalScale;
			uniform sampler2D _BigCascadeNormal;
			uniform float2 _BigCascadeMixSpeed;
			uniform float4 _BigCascadeNormal_ST;
			uniform float2 _BigCascadeMainSpeed;
			uniform float _Distortion;
			uniform float4 _DeepColor;
			uniform float4 _ShalowColor;
			uniform sampler2D _CameraDepthTexture;
			uniform float _ShalowDepth;
			uniform float _ShalowFalloff;
			uniform float _BigCascadeTransparency;
			uniform float3 _FoamColor;
			uniform float _FoamDepth;
			uniform float _FoamFalloff;
			uniform sampler2D _Foam;
			uniform float2 _FoamSpeed;
			uniform float4 _Foam_ST;
			uniform sampler2D _SmallCascade;
			uniform float2 _NoiseSpeed;
			uniform sampler2D _Noise;
			uniform float4 _Noise_ST;
			uniform float _SmallCascadeNoisePower;
			uniform float3 _SmallCascadeColor;
			uniform float _SmallCascadeFoamFalloff;
			uniform sampler2D _BigCascade;
			uniform float _BigCascadeNoisePower;
			uniform float3 _BigCascadeColor;
			uniform float _BigCascadeFoamFalloff;
			uniform float _WaterDeepTranslucencyPower;
			uniform float _WaterShalowTranslucencyPower;
			uniform float _WaterDepth;
			uniform float _WaterFalloffBorder;
			CBUFFER_END
			
			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			

            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature EDITOR_VISUALIZATION


            struct GraphVertexInput
            {
                float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

        	struct VertexOutput
        	{
        	    float4 clipPos      : SV_POSITION;
                float4 ase_texcoord : TEXCOORD0;
                float4 ase_texcoord1 : TEXCOORD1;
                float4 ase_texcoord2 : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
        	};

            VertexOutput vert(GraphVertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
        	    UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;

				v.vertex.xyz +=  float3(0,0,0) ;
				v.ase_normal =  v.ase_normal ;
				
                o.clipPos = MetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST);
        	    return o;
            }

            half4 frag(VertexOutput IN) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);

           		float4 screenPos = IN.ase_texcoord;
           		float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
           		float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
           		float2 appendResult163 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
           		int Direction723 = _UVVDirection1UDirection0;
           		float2 appendResult706 = (float2(_WaterMixSpeed.y , _WaterMixSpeed.x));
           		float2 uv_WaterNormal = IN.ase_texcoord1.xy * _WaterNormal_ST.xy + _WaterNormal_ST.zw;
           		float Globaltiling771 = ( 1.0 / _GlobalTiling );
           		float2 temp_output_773_0 = ( uv_WaterNormal * Globaltiling771 );
           		float2 panner612 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _WaterMixSpeed :  appendResult706 ) + temp_output_773_0);
           		float2 WaterSpeedValueMix516 = panner612;
           		float2 appendResult705 = (float2(_WaterMainSpeed.y , _WaterMainSpeed.x));
           		float2 panner611 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _WaterMainSpeed :  appendResult705 ) + temp_output_773_0);
           		float2 WaterSpeedValueMain614 = panner611;
           		float3 temp_output_24_0 = BlendNormal( UnpackNormalmapRGorAG( tex2D( _WaterNormal, WaterSpeedValueMix516 ), ( _NormalScale * 1.2 ) ) , UnpackNormalmapRGorAG( tex2D( _WaterNormal, WaterSpeedValueMain614 ), _NormalScale ) );
           		float2 appendResult709 = (float2(_SmallCascadeMixSpeed.y , _SmallCascadeMixSpeed.x));
           		float2 uv_SmallCascadeNormal = IN.ase_texcoord1.xy * _SmallCascadeNormal_ST.xy + _SmallCascadeNormal_ST.zw;
           		float2 temp_output_775_0 = ( uv_SmallCascadeNormal * Globaltiling771 );
           		float2 panner597 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _SmallCascadeMixSpeed :  appendResult709 ) + temp_output_775_0);
           		float2 SmallCascadeSpeedValueMix433 = panner597;
           		float2 appendResult710 = (float2(_SmallCascadeMainSpeed.y , _SmallCascadeMainSpeed.x));
           		float2 panner598 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _SmallCascadeMainSpeed :  appendResult710 ) + temp_output_775_0);
           		float2 SmallCascadeSpeedValueMain600 = panner598;
           		float3 ase_worldNormal = IN.ase_texcoord2.xyz;
           		float clampResult259 = clamp( ase_worldNormal.y , 0.0 , 1.0 );
           		float temp_output_258_0 = ( _SmallCascadeAngle / 45.0 );
           		float clampResult263 = clamp( ( clampResult259 - ( 1.0 - temp_output_258_0 ) ) , 0.0 , 2.0 );
           		float clampResult584 = clamp( ( clampResult263 * ( 1.0 / temp_output_258_0 ) ) , 0.0 , 1.0 );
           		float clampResult507 = clamp( ase_worldNormal.y , 0.0 , 1.0 );
           		float temp_output_504_0 = ( _BigCascadeAngle / 45.0 );
           		float clampResult509 = clamp( ( clampResult507 - ( 1.0 - temp_output_504_0 ) ) , 0.0 , 2.0 );
           		float clampResult583 = clamp( ( clampResult509 * ( 1.0 / temp_output_504_0 ) ) , 0.0 , 1.0 );
           		float clampResult514 = clamp( pow( abs( ( 1.0 - clampResult583 ) ) , _BigCascadeAngleFalloff ) , 0.0 , 1.0 );
           		float clampResult285 = clamp( ( pow( abs( ( 1.0 - clampResult584 ) ) , _SmallCascadeAngleFalloff ) - clampResult514 ) , 0.0 , 1.0 );
           		float3 lerpResult330 = lerp( temp_output_24_0 , BlendNormal( UnpackNormalmapRGorAG( tex2D( _SmallCascadeNormal, SmallCascadeSpeedValueMix433 ), _SmallCascadeNormalScale ) , UnpackNormalmapRGorAG( tex2D( _SmallCascadeNormal, SmallCascadeSpeedValueMain600 ), _SmallCascadeNormalScale ) ) , clampResult285);
           		float2 appendResult712 = (float2(_BigCascadeMixSpeed.y , _BigCascadeMixSpeed.x));
           		float2 uv_BigCascadeNormal = IN.ase_texcoord1.xy * _BigCascadeNormal_ST.xy + _BigCascadeNormal_ST.zw;
           		float2 temp_output_777_0 = ( uv_BigCascadeNormal * Globaltiling771 );
           		float2 panner606 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _BigCascadeMixSpeed :  appendResult712 ) + temp_output_777_0);
           		float2 BigCascadeSpeedValueMix608 = panner606;
           		float2 appendResult714 = (float2(_BigCascadeMainSpeed.y , _BigCascadeMainSpeed.x));
           		float2 panner607 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _BigCascadeMainSpeed :  appendResult714 ) + temp_output_777_0);
           		float2 BigCascadeSpeedValueMain432 = panner607;
           		float3 lerpResult529 = lerp( lerpResult330 , BlendNormal( UnpackNormalmapRGorAG( tex2D( _BigCascadeNormal, BigCascadeSpeedValueMix608 ), _BigCascadeNormalScale ) , UnpackNormalmapRGorAG( tex2D( _BigCascadeNormal, BigCascadeSpeedValueMain432 ), _BigCascadeNormalScale ) ) , clampResult514);
           		float4 fetchOpaqueVal65 = SAMPLE_TEXTURE2D( _CameraOpaqueTexture, sampler_CameraOpaqueTexture, ( float3( ( appendResult163 / ase_grabScreenPosNorm.a ) ,  0.0 ) + ( lerpResult529 * _Distortion ) ).xy);
           		float eyeDepth1 = LinearEyeDepth(tex2Dproj( _CameraDepthTexture, screenPos ).r,_ZBufferParams);
           		float temp_output_89_0 = abs( ( eyeDepth1 - screenPos.w ) );
           		float lerpResult761 = lerp( pow( abs( ( temp_output_89_0 + _ShalowDepth ) ) , _ShalowFalloff ) , 100.0 , ( _BigCascadeTransparency * clampResult514 ));
           		float temp_output_94_0 = saturate( lerpResult761 );
           		float4 lerpResult13 = lerp( _DeepColor , _ShalowColor , temp_output_94_0);
           		float temp_output_113_0 = saturate( pow( abs( ( temp_output_89_0 + _FoamDepth ) ) , _FoamFalloff ) );
           		float2 appendResult716 = (float2(_FoamSpeed.y , _FoamSpeed.x));
           		float2 uv_Foam = IN.ase_texcoord1.xy * _Foam_ST.xy + _Foam_ST.zw;
           		float2 panner116 = ( _Time.y * (( (float)Direction723 == 1.0 ) ? _FoamSpeed :  appendResult716 ) + ( uv_Foam * Globaltiling771 ));
           		float temp_output_114_0 = ( temp_output_113_0 * tex2D( _Foam, panner116 ).a );
           		float4 lerpResult117 = lerp( lerpResult13 , float4( _FoamColor , 0.0 ) , temp_output_114_0);
           		float4 lerpResult93 = lerp( fetchOpaqueVal65 , lerpResult117 , temp_output_113_0);
           		float temp_output_458_0 = ( 1.0 - temp_output_94_0 );
           		float4 lerpResult390 = lerp( lerpResult93 , lerpResult13 , temp_output_458_0);
           		float4 tex2DNode319 = tex2D( _SmallCascade, SmallCascadeSpeedValueMain600 );
           		float2 appendResult718 = (float2(_NoiseSpeed.y , _NoiseSpeed.x));
           		float2 temp_output_743_0 = (( (float)Direction723 == 1.0 ) ? _NoiseSpeed :  appendResult718 );
           		float2 uv_Noise = IN.ase_texcoord1.xy * _Noise_ST.xy + _Noise_ST.zw;
           		float2 temp_output_781_0 = ( uv_Noise * Globaltiling771 );
           		float2 panner646 = ( _SinTime.x * ( temp_output_743_0 * float2( -1.2,-0.9 ) ) + temp_output_781_0);
           		float4 tex2DNode647 = tex2D( _Noise, panner646 );
           		float2 panner321 = ( _SinTime.x * temp_output_743_0 + temp_output_781_0);
           		float clampResult488 = clamp( ( pow( abs( min( tex2DNode647.a , tex2D( _Noise, panner321 ).a ) ) , _SmallCascadeNoisePower ) * 20.0 ) , 0.0 , 1.0 );
           		float lerpResult480 = lerp( 0.0 , tex2DNode319.a , clampResult488);
           		float clampResult322 = clamp( pow( abs( tex2DNode319.a ) , _SmallCascadeFoamFalloff ) , 0.0 , 1.0 );
           		float lerpResult580 = lerp( 0.0 , clampResult322 , clampResult285);
           		float4 lerpResult324 = lerp( lerpResult390 , float4( ( lerpResult480 * _SmallCascadeColor ) , 0.0 ) , lerpResult580);
           		float4 tex2DNode213 = tex2D( _BigCascade, BigCascadeSpeedValueMain432 );
           		float clampResult758 = clamp( ( pow( abs( min( tex2DNode647.a , tex2D( _Noise, ( panner321 + float2( -0.47,0.37 ) ) ).a ) ) , _BigCascadeNoisePower ) * 20.0 ) , 0.0 , 1.0 );
           		float lerpResult626 = lerp( ( tex2DNode213.a * 0.5 ) , tex2DNode213.a , clampResult758);
           		float clampResult299 = clamp( pow( abs( tex2DNode213.a ) , _BigCascadeFoamFalloff ) , 0.0 , 1.0 );
           		float lerpResult579 = lerp( 0.0 , clampResult299 , clampResult514);
           		float4 lerpResult239 = lerp( lerpResult324 , float4( ( lerpResult626 * _BigCascadeColor ) , 0.0 ) , lerpResult579);
           		
           		float3 break453 = lerpResult529;
           		float clampResult552 = clamp( max( break453.x , break453.y ) , 0.0 , 1.0 );
           		float4 lerpResult451 = lerp( float4( 0,0,0,0 ) , _ShalowColor , clampResult552);
           		float lerpResult549 = lerp( _WaterDeepTranslucencyPower , _WaterShalowTranslucencyPower , temp_output_94_0);
           		float4 lerpResult459 = lerp( float4( 0,0,0,0 ) , ( lerpResult451 * lerpResult549 ) , temp_output_458_0);
           		
           		float lerpResult208 = lerp( 0.0 , 1.0 , pow( abs( saturate( pow( abs( temp_output_89_0 ) , _WaterDepth ) ) ) , _WaterFalloffBorder ));
           		
				
		        float3 Albedo = lerpResult239.rgb;
				float3 Emission = lerpResult459.rgb;
				float Alpha = lerpResult208;
				float AlphaClipThreshold = 0;

         #if _AlphaClip
        		clip(Alpha - AlphaClipThreshold);
        #endif

                MetaInput metaInput = (MetaInput)0;
                metaInput.Albedo = Albedo;
                metaInput.Emission = Emission;
                
                return MetaFragment(metaInput);
            }
            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/InternalErrorShader"
	
	
}