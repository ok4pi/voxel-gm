// Systems
#region Render Sky

// Setup Shader
shader_set(sh_sky);
gpu_set_tex_filter(true);
gpu_set_zwriteenable(false);

// Setup Matrix
global.world_matrix[12.0] = global.camera_px;
global.world_matrix[13.0] = global.camera_py;
global.world_matrix[14.0] = global.camera_pz;

matrix_set(matrix_world, global.world_matrix);

// Submit Buffer
vertex_submit(global.render_sky_buffer, pr_trianglelist, global.render_sky_texture);

// Reset Matrix
global.world_matrix[14.0] = 0.0;

// Reset Shader
gpu_set_zwriteenable(true);
gpu_set_tex_filter(false);
shader_reset();

#endregion

#region Render World

var size = ds_list_size(global.world_chunk_list);

// Setup Shader
shader_set(sh_chunk);

// Render Chunks
for (var i = 0.0; i < size; i++)
{
	var chunk = global.world_chunk_list[| i];
	
	// Setup Matrix
	global.world_matrix[12.0] = chunk[Chunk.X] * CHUNK_SIZE;
	global.world_matrix[13.0] = chunk[Chunk.Y] * CHUNK_SIZE;
	
	matrix_set(matrix_world, global.world_matrix);
	
	// Submit Buffer
	vertex_submit(chunk[Chunk.Mesh], pr_trianglelist, global.render_texture);
}

// Reset Shader
shader_reset();

#endregion

// Reset Matrix
matrix_set(matrix_world, global.render_matrix_identity);