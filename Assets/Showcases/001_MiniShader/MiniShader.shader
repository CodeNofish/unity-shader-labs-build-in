// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader路径
Shader "Showcase001/MiniShader"
{
  // Shader属性
  Properties
  {
    // 
    _FloatValue ("Float Value", Float) = 0.0
    _RangeFloatValue ("Range Float Value", Range(0.0, 2.0)) = 0.0
    _VectorValue ("Vector Value", Vector) = (1, 1, 1, 1)
    _ColorValue ("Color Value", Color) = (0, 0, 0, 1)
    _TextureValue ("Texture Value", 2D) = "white" {}
    //
    [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 2
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
      // 面片剔除设置
      Cull [_CullMode]
      
      // unityCG语言代码段
      CGPROGRAM
      // 指定 顶点shader的函数
      #pragma vertex vert
      // 指定 片元shader的函数
      #pragma fragment frag

      #include "UnityCG.cginc"

      // 应用阶段 需要传给 顶点shader的数据
      struct appdata
      {
        // 顶点坐标
        float4 vertex : POSITION;
        // 顶点uv坐标
        float2 uv : TEXCOORD0;
        // 第二三四套UV
        float2 uv2 : TEXCOORD1;
        float2 uv3 : TEXCOORD2;
        float2 uv4 : TEXCOORD3;
        // 顶点法线
        float3 normal : NORMAL;
        // 顶点色
        float4 color : COLOR;
      };

      // 顶点着色器的输出，经过插值后传递给片元着色器
      struct v2f
      {
        // 
        float4 pos : SV_POSITION;
        // 这里的TEXCOORD0是通用存储器，由插值器插值
        float2 uv : TEXCOORD0;
      };

      float _FloatValue;
      float _RangeFloatValue;
      float4 _VectorValue;
      float4 _ColorValue;
      sampler2D _TextureValue;
      float4 _TextureValue_ST;

      v2f vert(appdata v)
      {
        v2f o;

        // 模型空间 => 世界空间
        float4 pos_world = mul(UNITY_MATRIX_M, v.vertex);
        // 世界空间 => 相机空间
        float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
        // 相机空间 => 裁剪空间
        float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
        // 直接MVP矩阵变换
        // o.pos = UnityObjectToClipPos(v.vertex);

        o.pos = pos_clip;
        // 用纹理的 Tilling Offset 对uv缩放和偏移
        o.uv = v.uv * _TextureValue_ST.xy + _TextureValue_ST.zw;

        return o;
      }

      // 片元shader 输出颜色
      fixed4 frag(v2f i) : SV_Target
      {
        // 贴图采样
        fixed4 col = tex2D(_TextureValue, i.uv);
        // fixed4 col = _ColorValue;
        
        return col;
      }

      // fixed 8位, 颜色
      // half 16位, UV 大部分向量
      // color 32位, 位置坐标点用
      
      ENDCG
    }
  }
}