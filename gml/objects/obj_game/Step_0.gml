// Systems
#region Update Time

global.time_delta_real = min(delta_time * (60.0 / 1000000.0), 2.0);
global.time_delta_game = global.time_delta_real * global.time_scale;

#endregion

#region Update Input

#endregion

#region Update Window

// Toggle Fullscreen
if (keyboard_check_pressed(vk_f4))
	window_set_fullscreen(!window_get_fullscreen());

// Check Resize
var width  = window_get_width();
var height = window_get_height();

if (width != 0.0 && height != 0.0)
if (width != global.window_width || height != global.window_height)
{
	surface_resize(application_surface, width * SSAA, height * SSAA);
	display_set_gui_maximize();
	
	global.window_width  = width;
	global.window_height = height;
}

#endregion

#region Update Camera

// Update Input
var input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var input_y = keyboard_check(ord("W")) - keyboard_check(ord("S"));
var input_z = keyboard_check(vk_space) - keyboard_check(vk_shift);

// Update Acceleration
global.camera_sx += (lengthdir_x(input_x, global.camera_yaw - 90.0) + lengthdir_x(input_y, global.camera_yaw)) * MOVE_ACCEL * global.time_delta_game;
global.camera_sy += (lengthdir_y(input_x, global.camera_yaw - 90.0) + lengthdir_y(input_y, global.camera_yaw)) * MOVE_ACCEL * global.time_delta_game;
global.camera_sz += (input_z) * MOVE_ACCEL * global.time_delta_game;

// Clamp Speed
var length = sqrt(global.camera_sx * global.camera_sx + global.camera_sy * global.camera_sy);

if (length > MOVE_SPEED)
{
	global.camera_sx = (global.camera_sx / length) * MOVE_SPEED;
	global.camera_sy = (global.camera_sy / length) * MOVE_SPEED;
}

global.camera_sz = clamp(global.camera_sz, -MOVE_SPEED, MOVE_SPEED);

// Update Friction
var frict = power(MOVE_FRICT, global.time_delta_game);

global.camera_sx *= frict;
global.camera_sy *= frict;
global.camera_sz *= frict;

// Update Position
global.camera_px += global.camera_sx * global.time_delta_game;
global.camera_py += global.camera_sy * global.time_delta_game;
global.camera_pz += global.camera_sz * global.time_delta_game;

// Update Look
if (window_has_focus())
{
	var center_x = window_get_x() + global.window_width  / 2.0;
	var center_y = window_get_y() + global.window_height / 2.0;
	
	global.camera_yaw_to   -= (display_mouse_get_x() - center_x) * 0.3;
	global.camera_pitch_to -= (display_mouse_get_y() - center_y) * 0.3;
	
	display_mouse_set(center_x, center_y);
}

// Clamp Pitch
global.camera_pitch_to = clamp(global.camera_pitch_to, -89.5, 89.5);

// Update Smooth
global.camera_yaw   = lerp_delta(global.camera_yaw,   global.camera_yaw_to,   0.7, global.time_delta_game);
global.camera_pitch = lerp_delta(global.camera_pitch, global.camera_pitch_to, 0.7, global.time_delta_game);

// Build View Matrix
var factor;
var v1_x = global.camera_px - (global.camera_px + dcos(global.camera_yaw));
var v1_y = global.camera_py - (global.camera_py - dsin(global.camera_yaw));
var v1_z = global.camera_pz - (global.camera_pz + dtan(global.camera_pitch));

factor = 1.0 / sqrt(v1_x * v1_x + v1_y * v1_y + v1_z * v1_z);
v1_x  *= factor;
v1_y  *= factor;
v1_z  *= factor;

var v2_x = v1_y;
var v2_y = v1_x * -1.0;

factor = 1.0 / sqrt(v2_x * v2_x + v2_y * v2_y);
v2_x  *= factor;
v2_y  *= factor;

var v3_x =   -v2_y * v1_z;
var v3_y = -(-v2_x * v1_z);
var v3_z =    v1_x * v2_y - v2_x * v1_y;

global.render_matrix_view[0x0] =  v2_x;
global.render_matrix_view[0x1] =  v3_x;
global.render_matrix_view[0x2] =  v1_x;
global.render_matrix_view[0x3] =  0.0;
global.render_matrix_view[0x4] =  v2_y;
global.render_matrix_view[0x5] =  v3_y;
global.render_matrix_view[0x6] =  v1_y;
global.render_matrix_view[0x7] =  0.0;
global.render_matrix_view[0x8] =  0.0;
global.render_matrix_view[0x9] =  v3_z;
global.render_matrix_view[0xA] =  v1_z;
global.render_matrix_view[0xB] =  0.0;
global.render_matrix_view[0xC] = -vector_dot(v2_x, v2_y, 0.0,  global.camera_px, global.camera_py, global.camera_pz);
global.render_matrix_view[0xD] = -vector_dot(v3_x, v3_y, v3_z, global.camera_px, global.camera_py, global.camera_pz);
global.render_matrix_view[0xE] = -vector_dot(v1_x, v1_y, v1_z, global.camera_px, global.camera_py, global.camera_pz);
global.render_matrix_view[0xF] =  1.0;

// Build Projection Matrix
var fov  = 90.0;
var near = 0.1;
var far  = 4000.0;

factor = 1.0 / dtan(fov * 0.5);

global.render_matrix_proj[0x0] =  factor / (global.window_width / global.window_height);
global.render_matrix_proj[0x1] =  0.0;
global.render_matrix_proj[0x2] =  0.0;
global.render_matrix_proj[0x3] =  0.0;
global.render_matrix_proj[0x4] =  0.0;
global.render_matrix_proj[0x5] =  factor;
global.render_matrix_proj[0x6] =  0.0;
global.render_matrix_proj[0x7] =  0.0;
global.render_matrix_proj[0x8] =  0.0;
global.render_matrix_proj[0x9] =  0.0;
global.render_matrix_proj[0xA] =  far / (near - far);
global.render_matrix_proj[0xB] = -1.0;
global.render_matrix_proj[0xC] =  0.0;
global.render_matrix_proj[0xD] =  0.0;
global.render_matrix_proj[0xE] =  (near * far) / (near - far);
global.render_matrix_proj[0xF] =  0.0;

// Update Camera Matrices
camera_set_view_mat(view_camera, global.render_matrix_view);
camera_set_proj_mat(view_camera, global.render_matrix_proj);

#endregion

#region Update World

var chunk_x = (global.camera_px & -CHUNK_SIZE) / CHUNK_SIZE;
var chunk_y = (global.camera_py & -CHUNK_SIZE) / CHUNK_SIZE;

if (chunk_x != global.world_last_x || chunk_y != global.world_last_y)
{
	for (var xx = chunk_x - 8.0; xx <= chunk_x + 8.0; xx++)
	for (var yy = chunk_y - 8.0; yy <= chunk_y + 8.0; yy++)
	{
		// var key = string(xx) + "," + string(yy);
		
		var key = (int64(xx) + 0x7FFFFFFF) | ((int64(yy) + 0x7FFFFFFF) << 32);
		
		if (global.world_chunk_map[? key] == undefined)
		{
			// if (voxel_can_spawn())
			{
				var chunk = chunk_create(xx, yy);
				
				// Add Chunk
				ds_map_set(global.world_chunk_map, key, chunk);
				
				// Spawn Chunk
				voxel_spawn(buffer_get_address(chunk[Chunk.Data]), xx, yy);
			}
		}
	}
	
	global.world_last_x = chunk_x;
	global.world_last_y = chunk_y;
}

// TODO
voxel_step(global.camera_px, global.camera_py);

#endregion

#region Update Debug

if (DEBUG_MODE)
{
	// Toggle Console
	if (keyboard_check_pressed(vk_f1))
		global.debug_show_console = !global.debug_show_console;
	
	// Toggle Overlay
	if (keyboard_check_pressed(vk_f2))
	{
		global.debug_show_overlay = !global.debug_show_overlay;
		
		// Show Audio Overlay
		audio_debug(global.debug_show_overlay);
		
		// Show Video Overlay
		show_debug_overlay(global.debug_show_overlay);
	}
	
	// Exit Game
	if (keyboard_check(vk_escape))
		game_end();
}

#endregion

// States
// ...