// Vertex Input
struct VertexInput
{
	float4 Position : POSITION;
};

// Vertex Output
struct VertexOutput
{
	float4 Position : SV_POSITION;
	float  TexCoord : TEXCOORD;
};

// Vertex Shader
void main(in VertexInput In, out VertexOutput Out)
{
	Out.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(In.Position.xyz, 1.0f));
	Out.TexCoord = In.Position.w;
}