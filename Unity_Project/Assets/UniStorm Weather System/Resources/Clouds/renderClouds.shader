Shader "UniStorm/Clouds/Cloud Computing"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
        Tags{ "Queue" = "Transparent-400" "RenderType" = "Transparent" "IgnoreProjector" = "True" }
		LOD 100
        Blend One OneMinusSrcAlpha
        ZWrite Off

		Pass
		{
			HLSLPROGRAM
			#pragma enable_d3d11_debug_symbols
			#pragma multi_compile_instancing
			#pragma vertex vert
			#pragma fragment frag

			//#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 vert : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
				UNITY_VERTEX_OUTPUT_STEREO //Insert
			};

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;

				UNITY_SETUP_INSTANCE_ID(v); //Insert
				UNITY_TRANSFER_INSTANCE_ID(v, o); //Insert
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

                float s = _ProjectionParams.z;

                float4x4 mvNoTranslation =
                    float4x4(
                        float4(UNITY_MATRIX_MV[0].xyz, 0.0f),
                        float4(UNITY_MATRIX_MV[1].xyz, 0.0f),
                        float4(UNITY_MATRIX_MV[2].xyz, 0.0f),
                        float4(0, 0, 0, 1.1)
                    );


                o.vertex = mul(UNITY_MATRIX_P, mul(mvNoTranslation, float4(s*v.vertex.xyz, 1)));// * float4(s, s, s, 1));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vert = v.vertex;
				return o;
			}

			half4 frag (v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i); //Insert

				// sample the texture
				half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv); //tex2D
				//return i.vert;
				//return half4(1, 0, 0, 1);
				return col;
			}
			ENDHLSL
		}
	}
}
