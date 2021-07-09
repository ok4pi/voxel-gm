// Engine
#region Initialize Macros

// gml_pragma("PNGCrush");
// gml_pragma("UnityBuild", "true");

// Define Configuration
#macro DEBUG_MODE true
#macro DEBUG_CALL if (DEBUG_MODE)

// Define Platform
// ...

#endregion

#region Initialize Engine

// Enable Release Mode
gml_release_mode(!DEBUG_MODE);

// Disable Garbage Collector
// gc_enable(false);

// Setup Extension
global.ext_mesh_buffer = buffer_create(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE * 6.0 * 8.0, buffer_fixed, 1.0);

voxel_init(buffer_get_address(global.ext_mesh_buffer));
voxel_seed(randomize());

#endregion

// Systems
#region Initialize Time

// Setup Variables
global.time_scale      = 1.0;
global.time_delta_real = 0.0;
global.time_delta_game = 0.0;

// Unlock Framerate
game_set_speed(0.0, gamespeed_fps);

#endregion

#region Initialize Input

#endregion

#region Initialize Window

global.window_width  = window_get_width();
global.window_height = window_get_height();

#endregion

#region Initialize Render

// TODO
#macro SSAA 2

// Setup Resources
#region Initialize Vertex Formats

// Chunk
vertex_format_begin();
vertex_format_add_custom(vertex_type_ubyte4, vertex_usage_position);
vertex_format_add_custom(vertex_type_ubyte4, vertex_usage_color);

global.vertex_format_chunk = vertex_format_end();

// Sky
vertex_format_begin();
vertex_format_add_custom(vertex_type_float4, vertex_usage_position);

global.vertex_format_sky = vertex_format_end();

#endregion

#region Initialize Shader Uniforms

#endregion

// Setup Variables
global.render_matrix_identity = matrix_build_identity();
global.render_matrix_view     = matrix_build_identity();
global.render_matrix_proj     = matrix_build_identity();
global.render_texture         = sprite_get_texture(spr_texture, 0.0);

global.render_sky_buffer      = mesh_build_dome(-1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 32.0);
global.render_sky_texture     = sprite_get_texture(spr_sky, 0.0);

// Setup Rasterizer State
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_counterclockwise);

// Setup Sampler State
// ...

// Setup Application Surface
application_surface_draw_enable(false);

// SSAA
if (SSAA != 1)
{
	surface_resize(application_surface, global.window_width * SSAA, global.window_height * SSAA);
	display_set_gui_maximize();
}

#endregion

#region Initialize Camera

// TODO
#macro MOVE_SPEED (25.0)
#macro MOVE_ACCEL (MOVE_SPEED / 4.0)
#macro MOVE_FRICT (0.8)

// Position
global.camera_px       = 0.0;
global.camera_py       = 0.0;
global.camera_pz       = 80.0;

// Speed
global.camera_sx       = 0.0;
global.camera_sy       = 0.0;
global.camera_sz       = 0.0;

// Rotation
global.camera_yaw      = 0.0;
global.camera_yaw_to   = 0.0;
global.camera_pitch    = 0.0;
global.camera_pitch_to = 0.0;

#endregion

#region Initialize World

global.world_matrix     = matrix_build_identity();
global.world_chunk_map  = ds_map_create();
global.world_chunk_list = ds_list_create();

global.world_last_x     = -1.0;
global.world_last_y     = -1.0;

#endregion

#region Initialize Debug

if (DEBUG_MODE)
{
	// Setup Variables
	global.debug_show_console = false;
	global.debug_show_overlay = false;
	
	// Setup Font
	global.debug_font = font_add_sprite(spr_debug_font, ord(" "), true, -1.0);
}

#endregion