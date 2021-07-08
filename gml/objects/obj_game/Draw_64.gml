// Application Surface
gpu_set_tex_filter(true);
draw_surface_stretched(application_surface, 0.0, 0.0, global.window_width, global.window_height);
gpu_set_tex_filter(false);

// States
// ...

// Systems
#region Render Fade

#endregion

#region Render Debug

if (DEBUG_MODE)
{
	// Render Overlay
	if (global.debug_show_overlay)
	{
		draw_set_font(global.debug_font);
		
		draw_text(4.0, global.window_height - 37.0, "FPS: "       + string(fps));
		draw_text(4.0, global.window_height - 25.0, "Instances: " + string(instance_count));
		draw_text(4.0, global.window_height - 13.0, "Chunks: "    + string(ds_list_size(global.world_chunk_list)));
	}
}

#endregion