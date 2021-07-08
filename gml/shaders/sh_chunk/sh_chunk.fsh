// Pixel Input
struct PixelInput
{
	float4 Position : SV_POSITION;
	float3 Color    : COLOR;
};

// Pixel Shader
float4 main(in PixelInput In) : SV_TARGET
{
	return float4(gm_BaseTextureObject.Sample(gm_BaseTexture, In.Color.rg).rgb * In.Color.b, 1.0f);
}