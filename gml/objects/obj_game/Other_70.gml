var xx    = async_load[? "x"];
var yy    = async_load[? "y"];
var size  = async_load[? "size"];
var key   = (int64(xx) + 0x7FFFFFFF) | ((int64(yy) + 0x7FFFFFFF) << 32);
var chunk = global.world_chunk_map[? key];

// Create Vertex Buffer
var mesh = vertex_create_buffer_from_buffer_ext(global.ext_mesh_buffer, global.vertex_format_chunk, 0.0, size);

// Freeze Vertex Buffer
vertex_freeze(mesh);

chunk[@ Chunk.Mesh] = mesh;

// Add Chunk
ds_list_add(global.world_chunk_list, chunk);