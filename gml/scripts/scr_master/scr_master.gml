// Constants
#macro CHUNK_SIZE 32
#macro CHUNK_TALL 256

// Classes
#region Class - Chunk

enum Chunk
{
	X,
	Y,
	Data,
	Mesh,
}

function chunk_create(x, y)
{
	return
	[
		x,
		y,
		buffer_create((CHUNK_SIZE + 2.0) * (CHUNK_SIZE + 2.0) * (CHUNK_TALL + 2.0), buffer_fast, 1.0),
		-1.0,
	];
}

#endregion

// Systems
// ...

// Utilities
#region Utilities - Math

function vector_dot(x1, y1, z1, x2, y2, z2)
{
	return x1 * x2 + y1 * y2 + z1 * z2;
}

function lerp_delta(a, b, t, d)
{
	return lerp(a, b, 1.0 - exp(-t * d));
}

#endregion

#region Utilities - Mesh

function mesh_build_dome(x1, y1, z1, x2, y2, z2, steps)
{
	var xx = (x1 + x2) / 2.0;
	var yy = (y1 + y2) / 2.0;
	var zz = (z1 + z2) / 2.0;
	var xl = (x2 - xx);
	var yl = (y2 - yy);
	var zl = (z2 - zz);
	var a  = (2.0 * pi) / steps;
	var vb = vertex_create_buffer();
	
	// Begin Buffer
	vertex_begin(vb, global.vertex_format_sky);
	
	// Build Buffer
	for (var i = 0.0; i < pi * 2.0; i += a)
	for (var j = 0.0; j < pi;       j += a)
	{
		var b, c;
		var t1 = (j)     / pi;
		var t2 = (j + a) / pi;
		
		if (j < pi / 2.0)
		{
			b = t1;
			c = t2;
		}
		else
		{
			b = 1.0 - (j)     / pi;
			c = 1.0 - (j + a) / pi;
		}
		
		vertex_float4(vb, xx + xl * cos(i)     * sin(j),     yy - yl * sin(i)     * sin(j),     zz + zl * cos(j),     t1);
		vertex_float4(vb, xx + xl * cos(i)     * sin(j + a), yy - yl * sin(i)     * sin(j + a), zz + zl * cos(j + a), t2);
		vertex_float4(vb, xx + xl * cos(i + a) * sin(j),     yy - yl * sin(i + a) * sin(j),     zz + zl * cos(j),     t1);
		
		vertex_float4(vb, xx + xl * cos(i)     * sin(j + a), yy - yl * sin(i)     * sin(j + a), zz + zl * cos(j + a), t2);
		vertex_float4(vb, xx + xl * cos(i + a) * sin(j + a), yy - yl * sin(i + a) * sin(j + a), zz + zl * cos(j + a), t2);
		vertex_float4(vb, xx + xl * cos(i + a) * sin(j),     yy - yl * sin(i + a) * sin(j),     zz + zl * cos(j),     t1);
	}
	
	// Finish Buffer
	vertex_end(vb);
	vertex_freeze(vb);
	
	// Success
	return vb;
}

#endregion