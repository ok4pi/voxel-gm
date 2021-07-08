// Define Constants
#define TEXEL (1.0f / 256.0f)
#define EDGE  (TEXEL * 16.0f)

// Vertex Input
struct VertexInput
{
	uint4 Position : POSITION;
	uint4 Color    : COLOR;
};

// Vertex Output
struct VertexOutput
{
	float4 Position : SV_POSITION;
	float3 Color    : COLOR;
};

// Normal Table
static const float3 NormalTable[] =
{
	float3( 0.0f,  0.0f,  1.0f),
	float3( 0.0f,  0.0f, -1.0f),
	float3( 0.0f,  1.0f,  0.0f),
	float3( 0.0f, -1.0f,  0.0f),
	float3( 1.0f,  0.0f,  0.0f),
	float3(-1.0f,  0.0f,  0.0f),
};

// Vertex Shader
void main(in VertexInput In, out VertexOutput Out)
{
	float Light = dot(normalize(NormalTable[In.Position.w]), normalize(float3(0.6f, 0.1f, 1.0f))) * 0.5f + 0.5f;
	float U     = In.Color.r * TEXEL * 18.0f + TEXEL;
	float V     = In.Color.g * TEXEL * 18.0f + TEXEL;
	
	U += EDGE * ((In.Color.b & (1 << 0)) != 0);
	V += EDGE * ((In.Color.b & (1 << 1)) != 0);
	
	Out.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(In.Position.xyz, 1.0f));
	Out.Color    = float3(U, V, (In.Color.a / 255.0f) * max(Light, 0.5f));
}