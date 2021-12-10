Shader "Custom/Recolourable" {
Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
    _BlackColor ("Black Color", Color) = (0,0,0,1)
    _WhiteColor ("White Color", Color) = (1,1,1,1)
}
SubShader {
    Tags { "RenderType"="Opaque" }
    LOD 150
    Cull Off

CGPROGRAM
#pragma surface surf Lambert noforwardadd

sampler2D _MainTex;
fixed4 _BlackColor;
fixed4 _WhiteColor;

struct Input {
    float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
    o.Albedo = lerp(_BlackColor, _WhiteColor, c.r);
    o.Alpha = c.a;
}
ENDCG
}

Fallback "Mobile/VertexLit"
}