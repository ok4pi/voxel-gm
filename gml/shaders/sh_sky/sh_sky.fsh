// Pixel Input
struct PixelInput
{
	float4 Position : SV_POSITION;
	float  TexCoord : TEXCOORD;
};

// Pixel Shader
float4 main(in PixelInput In) : SV_TARGET
{
	return gm_BaseTextureObject.Sample(gm_BaseTexture, float2(0.0f, In.TexCoord));
}