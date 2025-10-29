Shader "Showcase002/InfiniteGrid_1"
{
  Properties
  {
    [Header(Shader Feature)]
    [Toggle(ENABLE_SMOOTHNESS)] _EnableSmoothness ("Enable Smoothness", Float) = 0

    [Header(Grid Settings)]
    [MainColor] _BlackboardColor ("Blackboard Color", Color) = (0,0,0,1)
    _GridSize ("Grid Size", Vector) = (10, 10, 50, 50)

    [Header(MainLine Settings)]
    _MainLineColor ("Main Line Color", Color) = (1,1,1,1)
    _MainLineThickness ("Main Line Thickness", Range(0.001, 0.2)) = 0.01
    _MainLineSmoothness ("Main Line Smoothness", Range(0, 0.1)) = 0.01

    [Header(SubLine Settings)]
    _SubLineColor ("Sub Line Color", Color) = (1,1,1,1)
    _SubLineThickness ("Sub Line Thickness", Range(0.001, 0.2)) = 0.01
    _SubLineSmoothness ("Sub Line Smoothness", Range(0, 0.1)) = 0.01
  }
  SubShader
  {
    Tags
    {
      "RenderType"="Opaque"
    }
    LOD 100

    Pass
    {
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      // 生成两个着色器变体
      #pragma multi_compile __ ENABLE_SMOOTHNESS

      #include "UnityCG.cginc"

      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };

      struct v2f
      {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float2 worldPos : TEXCOORD1;
      };

      // 背景
      float4 _BlackboardColor;
      // 主线
      float4 _MainLineColor;
      float _MainLineThickness;
      float _MainLineSmoothness;
      // 辅线
      float4 _SubLineColor;
      float _SubLineThickness;
      float _SubLineSmoothness;
      // 网格大小
      float4 _GridSize;

      v2f vert(appdata v)
      {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xy;
        return o;
      }

      fixed4 frag(v2f i) : SV_Target
      {
        fixed4 color;

        // 绘制副线

        float2 subGridFraction = frac(i.uv * _GridSize.zw);
        float2 subDistanceToGrid = min(subGridFraction, 1.0 - subGridFraction);

        #ifdef ENABLE_SMOOTHNESS
        float subGridX = 1.0 - smoothstep(_SubLineThickness - _SubLineSmoothness, _SubLineThickness + _SubLineSmoothness, subDistanceToGrid.x);
        float subGridY = 1.0 - smoothstep(_SubLineThickness - _SubLineSmoothness, _SubLineThickness + _SubLineSmoothness, subDistanceToGrid.y);
        float subGridFactor = min(1.0 - subGridX, 1.0 - subGridY);
        #else
        float subGridX = 1.0 - step(_SubLineThickness, subDistanceToGrid.x);
        float subGridY = 1.0 - step(_SubLineThickness, subDistanceToGrid.y);
        float subGridFactor = min(1.0 - subGridX, 1.0 - subGridY);
        #endif

        color = lerp(_SubLineColor, _BlackboardColor, subGridFactor);

        // 绘制主线

        float2 mainGridFraction = frac(i.uv * _GridSize.xy);
        float2 mainDistanceToGrid = min(mainGridFraction, 1.0 - mainGridFraction);

        #ifdef ENABLE_SMOOTHNESS
        float mainGridX = 1.0 - smoothstep(_MainLineThickness - _MainLineSmoothness, _MainLineThickness + _MainLineSmoothness, mainDistanceToGrid.x);
        float mainGridY = 1.0 - smoothstep(_MainLineThickness - _MainLineSmoothness, _MainLineThickness + _MainLineSmoothness, mainDistanceToGrid.y);
        float mainGridFactor = min(1.0 - mainGridX, 1.0 - mainGridY);
        #else
        float mainGridX = 1.0 - step(_MainLineThickness, mainDistanceToGrid.x);
        float mainGridY = 1.0 - step(_MainLineThickness, mainDistanceToGrid.y);
        float mainGridFactor = min(1.0 - mainGridX, 1.0 - mainGridY);
        #endif

        color = lerp(_MainLineColor, color, mainGridFactor);

        return color;
      }
      ENDCG
    }
  }
}