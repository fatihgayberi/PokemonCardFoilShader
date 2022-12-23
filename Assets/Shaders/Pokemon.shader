Shader "Wonnasmith/Pokemon"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}

        _RefNumber ("Referance Number", Int) = 1

		_DissolveTexture("Dissolve Texutre", 2D) = "white" {} 
		/*[PerRendererData]*/_Amount("Amount", Range(0,1)) = 0

        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range (.002, 0.1)) = .002
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Stencil
        {
            Ref[_RefNumber]
            Comp equal
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0


        struct Input
        {
            float2 uv_MainTex;
        };

        //Dissolve properties
		sampler2D _DissolveTexture;
		half _Amount;

        //Texture properties
        sampler2D _MainTex;
    	fixed4 _ColorEnd;
    	fixed4 _Color;

        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			fixed4 baseColor = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            // Dissolve function
			half dissolve_value = tex2D(_DissolveTexture, IN.uv_MainTex).r;
			clip(dissolve_value - _Amount);

            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * lerp(baseColor, _ColorEnd, _Amount);
        }
        ENDCG
    }
}
