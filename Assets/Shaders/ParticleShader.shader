Shader "Wonnasmith/ParticleShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [HDR]_FoilColor ("Foil Color", Color) = (1, 1, 1, 1)
		_Hue("Hue", Range(0, 1.0)) = 0
		_Saturation("Saturation", Range(0, 1.0)) = 0.5
		_Brightness("Brightness", Range(0, 1.0)) = 0.5
		_Contrast("Contrast", Range(0, 1.0)) = 0.5

        _MainTex ("Texture", 2D) = "white" {}
        _RandomDirection ("Random Direction", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _ViewDirectionDisplacement ("View Direction Displacement ", float) = 1
        _FoilMask ("Foil Mask", 2D) = "white" {}
        _GradientMap ("Gradient Map", 2D) = "white" {}
        _ParallaxOffset ("Parallax Offset", float) = 1
        _MaskThreshold ("Mask Threshold", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 viewDirTangent : TEXCOORD2;
                float3 normal : NORMAL;
                fixed4 hsbc : COLOR;
            };

            fixed4 _Color;
            fixed4 _FoilColor;
            fixed _Hue, _Saturation, _Brightness, _Contrast;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _GradientMap;
            sampler2D _Noise;
            sampler2D _FoilMask;
            sampler2D _RandomDirection;
            float _ViewDirectionDisplacement;
            float _ParallaxOffset;
            float _MaskThreshold;

            // Function
			inline float3 applyHue(float3 aColor, float aHue)
			{
				float angle = radians(aHue);
				float3 k = float3(0.57735, 0.57735, 0.57735);
				float cosAngle = cos(angle);
				//Rodrigues' rotation formula
				return aColor * cosAngle + cross(k, aColor) * sin(angle) + k * dot(k, aColor) * (1 - cosAngle);
			}

            inline float4 applyHSBEffect(float4 startColor, fixed4 hsbc)
			{
				float hue = 360 * hsbc.r;
				float saturation = hsbc.g * 2;
				float brightness = hsbc.b * 2 - 1;
				float contrast = hsbc.a * 2;

				float4 outputColor = startColor;
				outputColor.rgb = applyHue(outputColor.rgb, hue);
				outputColor.rgb = (outputColor.rgb - 0.5f) * contrast + 0.5f + brightness;
				outputColor.rgb = lerp(Luminance(outputColor.rgb), outputColor.rgb, saturation);
				
				return outputColor;
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
				o.hsbc = fixed4(_Hue, _Saturation, _Brightness, _Contrast);

                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;

                o.viewDirTangent = float3(
                    dot(viewDir, v.tangent.xyz),
                    dot(viewDir, bitangent.xyz),
                    dot(viewDir, v.normal.xyz)
                );

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;

                float noise = tex2D(_Noise, i.uv).x;
                i.uv += i.viewDirTangent * noise * _ParallaxOffset;
                float displ = (tex2D(_Noise, i.uv) * 2.0 - 1.0) * _ViewDirectionDisplacement;
                float3 randomDirs = normalize(tex2D(_RandomDirection, i.uv).xyz);
                float dotProduct = sin(saturate(dot(i.normal + randomDirs, normalize(i.viewDir + displ))));
                float fresnel = pow(1.0 - dotProduct, 2);
                float samplingVal = (sin((i.viewDir.x + i.viewDir.y) * 1.0 * UNITY_TWO_PI) * 0.5 + 0.5) * fresnel;
                float mask = tex2D(_FoilMask, i.uv).x;

                return lerp(col, tex2D(_GradientMap, dotProduct) * applyHSBEffect(_FoilColor, i.hsbc), step(_MaskThreshold, mask) * clamp(sin(_Time.y * 0.5 + 0.5) * 4, 1.0, 3));
            }
            ENDCG
        }
    }
}
