#include "random.hpp"
#include "simplex.hpp"

#define NOMINMAX
#include <stdint.h>
#include <math.h>
#include <windows.h>

// Define API
#ifdef _MSC_VER
	#define GML_EXPORT extern "C" __declspec(dllexport)
#else
	#define GML_EXPORT extern "C" __attribute__ ((visibility ("default")))
#endif

// Define Macros
#define EVENT_OTHER_SOCIAL   70
#define CHUNK_MAX_QUEUE      4096
#define CHUNK_SIZE           32
#define CHUNK_TALL           256
#define CHUNK_INDEX(X, Y, Z) ((Z) + (CHUNK_TALL + 2) * ((Y) + (CHUNK_SIZE + 2) * (X)))
#define U8(X)                static_cast<uint8_t>(X)

// Define Constants
enum
{
	normal_top,
	normal_bottom,
	normal_front,
	normal_back,
	normal_right,
	normal_left,
};

enum
{
	uv_u1 = 0,
	uv_v1 = 0,
	uv_u2 = (1 << 0),
	uv_v2 = (1 << 1),
};

enum
{
	chunk_state_none,
	chunk_state_data,
	chunk_state_mesh,
	chunk_state_done,
};

// Define Structures
struct Chunk
{
	int      state;
	int      x;
	int      y;
	int      size;
	uint8_t *buffer;
};

struct Vertex
{
	uint8_t x, y, z, n;
	uint8_t u, v, b, a;
};

struct VertexFace
{
	Vertex v1, v2, v3;
	Vertex v4, v5, v6;
};

struct Block
{
	uint8_t top_uv[2];
	uint8_t bot_uv[2];
	uint8_t sid_uv[2];
	uint8_t ______[2];
};

// Define Blocks
static const Block blocks[]
{
	{ { 0, 0 }, { 0, 0 }, { 0, 0 } },
	{ { 0, 0 }, { 2, 0 }, { 1, 0 } },
	{ { 2, 0 }, { 2, 0 }, { 2, 0 } },
};

// Define AO
static const uint8_t ao_table[]
{
	0xFF - 80,
	0xFF - 40,
	0xFF - 10,
	0xFF - 0,
};

// Define Callbacks
static void (*event_perform)     (int, int);
static int  (*ds_map_create)     (int, ...);
static bool (*ds_map_add_double) (int index, const char *key, double       value);
static bool (*ds_map_add_string) (int index, const char *key, const char  *value);

// Chunk Data
static Chunk chunk_array[CHUNK_MAX_QUEUE];

// Thread Data
static int    mesh_thread_waiting;
static double camera_x;
static double camera_y;

// Mesh Building
static VertexFace *mesh_buffer;
static VertexFace *mesh_pointer;

// Math Functions
template <typename T> static inline T min(T a, T b) { return a < b ? a : b; }
template <typename T> static inline T max(T a, T b) { return a > b ? a : b; }

template <> static inline int min(int a, int b) { return b + ((a - b) & (a - b) >> 31); }
template <> static inline int max(int a, int b) { return a - ((a - b) & (a - b) >> 31); }

static double point_distance(double x1, double y1, double x2, double y2)
{
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

// Voxel Functions
static inline int vertex_ao(bool a, bool b, bool c)
{
	if (a && b)
		return 0;

	return 3 - (a + b + c);
}

static void voxel_data(Chunk *chunk, int cx, int cy)
{
	for (int x = 0; x < CHUNK_SIZE + 2; x++)
	for (int y = 0; y < CHUNK_SIZE + 2; y++)
	{
		float n1 = simplex_fbm(cx + x, cy + y, 0.004f,  5.0f, 5.0f, 0.1f, 4) * 6.0f;
		float n2 = simplex_fbm(cx + x, cy + y, 0.0008f, 5.5f, 5.0f, 0.2f, 8) * 1.0f;

		int height = max(min(fast_floor(n1 * n2) + 100, CHUNK_TALL - 3), 1);

		// Grass
		chunk->buffer[CHUNK_INDEX(x, y, height)] = 1;

		// Dirt
		for (int z = height - 1; z >= 0; z--)
			chunk->buffer[CHUNK_INDEX(x, y, z)] = 2;

		// Stone
		// ...
	}
}

static int voxel_mesh(Chunk *chunk)
{
	int      ao[4];
	uint8_t  u;
	uint8_t  v;
	uint8_t *data = chunk->buffer;

	// Reset Pointer
	mesh_pointer = mesh_buffer;

	// Build Mesh
	for (int x = 1; x < CHUNK_SIZE + 1; x++)
	for (int y = 1; y < CHUNK_SIZE + 1; y++)
	for (int z = 1; z < CHUNK_TALL + 1; z++)
	{
		uint8_t block = data[CHUNK_INDEX(x, y, z)];

		if (block)
		{
			// Top Face
			if (data[CHUNK_INDEX(x, y, z + 1)] == 0)
			{
				ao[0] = vertex_ao(data[CHUNK_INDEX(x - 1, y, z + 1)], data[CHUNK_INDEX(x, y - 1, z + 1)], data[CHUNK_INDEX(x - 1, y - 1, z + 1)]);
				ao[1] = vertex_ao(data[CHUNK_INDEX(x + 1, y, z + 1)], data[CHUNK_INDEX(x, y + 1, z + 1)], data[CHUNK_INDEX(x + 1, y + 1, z + 1)]);
				ao[2] = vertex_ao(data[CHUNK_INDEX(x + 1, y, z + 1)], data[CHUNK_INDEX(x, y - 1, z + 1)], data[CHUNK_INDEX(x + 1, y - 1, z + 1)]);
				ao[3] = vertex_ao(data[CHUNK_INDEX(x - 1, y, z + 1)], data[CHUNK_INDEX(x, y + 1, z + 1)], data[CHUNK_INDEX(x - 1, y + 1, z + 1)]);

				u = blocks[block].top_uv[0];
				v = blocks[block].top_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x),     U8(y),     U8(z + 1), normal_top, u, v, uv_u1 | uv_v1, ao_table[ao[0]] },
					{ U8(x + 1), U8(y),     U8(z + 1), normal_top, u, v, uv_u2 | uv_v1, ao_table[ao[2]] },
					{ U8(x + 1), U8(y + 1), U8(z + 1), normal_top, u, v, uv_u2 | uv_v2, ao_table[ao[1]] },

					{ U8(x + 1), U8(y + 1), U8(z + 1), normal_top, u, v, uv_u2 | uv_v2, ao_table[ao[1]] },
					{ U8(x),     U8(y + 1), U8(z + 1), normal_top, u, v, uv_u1 | uv_v2, ao_table[ao[3]] },
					{ U8(x),     U8(y),     U8(z + 1), normal_top, u, v, uv_u1 | uv_v1, ao_table[ao[0]] },
				};
			}

			// Bottom Face
			if (data[CHUNK_INDEX(x, y, z - 1)] == 0)
			{
				u = blocks[block].bot_uv[0];
				v = blocks[block].bot_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x),     U8(y + 1), U8(z), normal_bottom, u, v, uv_u1 | uv_v2, 0xFF },
					{ U8(x + 1), U8(y),     U8(z), normal_bottom, u, v, uv_u2 | uv_v1, 0xFF },
					{ U8(x),     U8(y),     U8(z), normal_bottom, u, v, uv_u1 | uv_v1, 0xFF },

					{ U8(x),     U8(y + 1), U8(z), normal_bottom, u, v, uv_u1 | uv_v2, 0xFF },
					{ U8(x + 1), U8(y + 1), U8(z), normal_bottom, u, v, uv_u2 | uv_v2, 0xFF },
					{ U8(x + 1), U8(y),     U8(z), normal_bottom, u, v, uv_u2 | uv_v1, 0xFF },
				};
			}

			// Front Face
			if (data[CHUNK_INDEX(x, y + 1, z)] == 0)
			{
				ao[0] = vertex_ao(data[CHUNK_INDEX(x - 1, y + 1, z)], data[CHUNK_INDEX(x, y + 1, z - 1)], data[CHUNK_INDEX(x - 1, y + 1, z - 1)]);
				ao[1] = vertex_ao(data[CHUNK_INDEX(x + 1, y + 1, z)], data[CHUNK_INDEX(x, y + 1, z + 1)], data[CHUNK_INDEX(x + 1, y + 1, z + 1)]);
				ao[2] = vertex_ao(data[CHUNK_INDEX(x + 1, y + 1, z)], data[CHUNK_INDEX(x, y + 1, z - 1)], data[CHUNK_INDEX(x + 1, y + 1, z - 1)]);
				ao[3] = vertex_ao(data[CHUNK_INDEX(x - 1, y + 1, z)], data[CHUNK_INDEX(x, y + 1, z + 1)], data[CHUNK_INDEX(x - 1, y + 1, z + 1)]);

				u = blocks[block].sid_uv[0];
				v = blocks[block].sid_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x),     U8(y + 1), U8(z),     normal_front, u, v, uv_u1 | uv_v2, ao_table[ao[0]] },
					{ U8(x),     U8(y + 1), U8(z + 1), normal_front, u, v, uv_u1 | uv_v1, ao_table[ao[3]] },
					{ U8(x + 1), U8(y + 1), U8(z),     normal_front, u, v, uv_u2 | uv_v2, ao_table[ao[2]] },

					{ U8(x),     U8(y + 1), U8(z + 1), normal_front, u, v, uv_u1 | uv_v1, ao_table[ao[3]] },
					{ U8(x + 1), U8(y + 1), U8(z + 1), normal_front, u, v, uv_u2 | uv_v1, ao_table[ao[1]] },
					{ U8(x + 1), U8(y + 1), U8(z),     normal_front, u, v, uv_u2 | uv_v2, ao_table[ao[2]] },
				};
			}

			// Back Face
			if (data[CHUNK_INDEX(x, y - 1, z)] == 0)
			{
				ao[0] = vertex_ao(data[CHUNK_INDEX(x - 1, y - 1, z)], data[CHUNK_INDEX(x, y - 1, z - 1)], data[CHUNK_INDEX(x - 1, y - 1, z - 1)]);
				ao[1] = vertex_ao(data[CHUNK_INDEX(x + 1, y - 1, z)], data[CHUNK_INDEX(x, y - 1, z + 1)], data[CHUNK_INDEX(x + 1, y - 1, z + 1)]);
				ao[2] = vertex_ao(data[CHUNK_INDEX(x + 1, y - 1, z)], data[CHUNK_INDEX(x, y - 1, z - 1)], data[CHUNK_INDEX(x + 1, y - 1, z - 1)]);
				ao[3] = vertex_ao(data[CHUNK_INDEX(x - 1, y - 1, z)], data[CHUNK_INDEX(x, y - 1, z + 1)], data[CHUNK_INDEX(x - 1, y - 1, z + 1)]);

				u = blocks[block].sid_uv[0];
				v = blocks[block].sid_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x + 1), U8(y), U8(z),     normal_back, u, v, uv_u1 | uv_v2, ao_table[ao[2]] },
					{ U8(x),     U8(y), U8(z + 1), normal_back, u, v, uv_u2 | uv_v1, ao_table[ao[3]] },
					{ U8(x),     U8(y), U8(z),     normal_back, u, v, uv_u2 | uv_v2, ao_table[ao[0]] },

					{ U8(x + 1), U8(y), U8(z),     normal_back, u, v, uv_u1 | uv_v2, ao_table[ao[2]] },
					{ U8(x + 1), U8(y), U8(z + 1), normal_back, u, v, uv_u1 | uv_v1, ao_table[ao[1]] },
					{ U8(x),     U8(y), U8(z + 1), normal_back, u, v, uv_u2 | uv_v1, ao_table[ao[3]] },
				};
			}

			// Right Face
			if (data[CHUNK_INDEX(x + 1, y, z)] == 0)
			{
				ao[0] = vertex_ao(data[CHUNK_INDEX(x + 1, y - 1, z)], data[CHUNK_INDEX(x + 1, y, z - 1)], data[CHUNK_INDEX(x + 1, y - 1, z - 1)]);
				ao[1] = vertex_ao(data[CHUNK_INDEX(x + 1, y + 1, z)], data[CHUNK_INDEX(x + 1, y, z + 1)], data[CHUNK_INDEX(x + 1, y + 1, z + 1)]);
				ao[2] = vertex_ao(data[CHUNK_INDEX(x + 1, y + 1, z)], data[CHUNK_INDEX(x + 1, y, z - 1)], data[CHUNK_INDEX(x + 1, y + 1, z - 1)]);
				ao[3] = vertex_ao(data[CHUNK_INDEX(x + 1, y - 1, z)], data[CHUNK_INDEX(x + 1, y, z + 1)], data[CHUNK_INDEX(x + 1, y - 1, z + 1)]);

				u = blocks[block].sid_uv[0];
				v = blocks[block].sid_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x + 1), U8(y + 1), U8(z),     normal_right, u, v, uv_u1 | uv_v2, ao_table[ao[2]] },
					{ U8(x + 1), U8(y),     U8(z + 1), normal_right, u, v, uv_u2 | uv_v1, ao_table[ao[3]] },
					{ U8(x + 1), U8(y),     U8(z),     normal_right, u, v, uv_u2 | uv_v2, ao_table[ao[0]] },

					{ U8(x + 1), U8(y + 1), U8(z),     normal_right, u, v, uv_u1 | uv_v2, ao_table[ao[2]] },
					{ U8(x + 1), U8(y + 1), U8(z + 1), normal_right, u, v, uv_u1 | uv_v1, ao_table[ao[1]] },
					{ U8(x + 1), U8(y),     U8(z + 1), normal_right, u, v, uv_u2 | uv_v1, ao_table[ao[3]] },
				};
			}

			// Left Face
			if (data[CHUNK_INDEX(x - 1, y, z)] == 0)
			{
				ao[0] = vertex_ao(data[CHUNK_INDEX(x - 1, y - 1, z)], data[CHUNK_INDEX(x - 1, y, z - 1)], data[CHUNK_INDEX(x - 1, y - 1, z - 1)]);
				ao[1] = vertex_ao(data[CHUNK_INDEX(x - 1, y + 1, z)], data[CHUNK_INDEX(x - 1, y, z + 1)], data[CHUNK_INDEX(x - 1, y + 1, z + 1)]);
				ao[2] = vertex_ao(data[CHUNK_INDEX(x - 1, y + 1, z)], data[CHUNK_INDEX(x - 1, y, z - 1)], data[CHUNK_INDEX(x - 1, y + 1, z - 1)]);
				ao[3] = vertex_ao(data[CHUNK_INDEX(x - 1, y - 1, z)], data[CHUNK_INDEX(x - 1, y, z + 1)], data[CHUNK_INDEX(x - 1, y - 1, z + 1)]);

				u = blocks[block].sid_uv[0];
				v = blocks[block].sid_uv[1];

				*mesh_pointer++ =
				{
					{ U8(x), U8(y),     U8(z),     normal_left, u, v, uv_u1 | uv_v2, ao_table[ao[0]] },
					{ U8(x), U8(y),     U8(z + 1), normal_left, u, v, uv_u1 | uv_v1, ao_table[ao[3]] },
					{ U8(x), U8(y + 1), U8(z),     normal_left, u, v, uv_u2 | uv_v2, ao_table[ao[2]] },

					{ U8(x), U8(y),     U8(z + 1), normal_left, u, v, uv_u1 | uv_v1, ao_table[ao[3]] },
					{ U8(x), U8(y + 1), U8(z + 1), normal_left, u, v, uv_u2 | uv_v1, ao_table[ao[1]] },
					{ U8(x), U8(y + 1), U8(z),     normal_left, u, v, uv_u2 | uv_v2, ao_table[ao[2]] },
				};
			}
		}
	}

	// Success
	return (mesh_pointer - mesh_buffer) * 6;
}

static DWORD WINAPI data_thread(LPVOID param)
{
	for (;;)
	{
		if (!mesh_thread_waiting)
		{
			double distance = 99999999.0;
			int    closest  = -1;

			for (int i = 0; i < CHUNK_MAX_QUEUE; i++)
			{
				if (chunk_array[i].state == chunk_state_data)
				{
					double check = point_distance(chunk_array[i].x * CHUNK_SIZE, chunk_array[i].y * CHUNK_SIZE, camera_x, camera_y);

					if (check < distance)
					{
						distance = check;
						closest  = i;
					}
				}
			}

			if (closest != -1)
			{
				voxel_data(&chunk_array[closest], chunk_array[closest].x * CHUNK_SIZE, chunk_array[closest].y * CHUNK_SIZE);
				// chunk_array[i].state = chunk_state_mesh;

				mesh_thread_waiting = true;

				chunk_array[closest].size  = voxel_mesh(&chunk_array[closest]);
				chunk_array[closest].state = chunk_state_done;
			}
		}

		Sleep(1);
	}

	// Success
	return 0;
}

static DWORD WINAPI mesh_thread(LPVOID param)
{
	for (;;)
	{
		if (!mesh_thread_waiting)
		{
			for (int i = 0; i < CHUNK_MAX_QUEUE; i++)
			{
				if (chunk_array[i].state == chunk_state_mesh)
				{
					mesh_thread_waiting  = true;

					chunk_array[i].size  = voxel_mesh(&chunk_array[i]);
					chunk_array[i].state = chunk_state_done;

					break;
				}
			}
		}

		// Sleep(1);
	}

	// Success
	return 0;
}

GML_EXPORT double RegisterCallbacks(void *f1, void *f2, void *f3, void *f4)
{
	event_perform     = reinterpret_cast<void (*)(int, int)                       >(f1);
	ds_map_create     = reinterpret_cast<int  (*)(int, ...)                       >(f2);
	ds_map_add_double = reinterpret_cast<bool (*)(int, const char *, double)      >(f3);
	ds_map_add_string = reinterpret_cast<bool (*)(int, const char *, const char *)>(f4);

	// Success
	return 0.0;
}

GML_EXPORT double voxel_init(VertexFace *buffer)
{
	// Setup Pointers
	mesh_buffer  = buffer;
	mesh_pointer = buffer;

	// Setup Threads
	CreateThread(nullptr, 0, data_thread, nullptr, 0, nullptr);
	// CreateThread(nullptr, 0, mesh_thread, nullptr, 0, nullptr);

	// Success
	return 0.0;
}

GML_EXPORT double voxel_step(double x, double y)
{
	camera_x = x;
	camera_y = y;

	for (int i = 0; i < CHUNK_MAX_QUEUE; i++)
	{
		if (chunk_array[i].state == chunk_state_done)
		{
			// Async Callback
			int map = ds_map_create(0);

			ds_map_add_double(map, "x",    static_cast<double>(chunk_array[i].x));
			ds_map_add_double(map, "y",    static_cast<double>(chunk_array[i].y));
			ds_map_add_double(map, "size", static_cast<double>(chunk_array[i].size));

			event_perform(map, EVENT_OTHER_SOCIAL);

			// Reset State
			chunk_array[i].state = chunk_state_none;
			mesh_thread_waiting  = false;

			// Only submit a single chunk per-frame.
			break;
		}
	}

	// Success
	return 0.0;
}

GML_EXPORT double voxel_seed(double seed)
{
	random_seed  (static_cast<int>(seed));
	simplex_seed (static_cast<int>(seed));

	// Success
	return 0.0;
}

GML_EXPORT double voxel_spawn(uint8_t *data, double x, double y)
{
	for (int i = 0; i < CHUNK_MAX_QUEUE; i++)
	{
		if (chunk_array[i].state == chunk_state_none)
		{
			chunk_array[i].x      = static_cast<int>(x);
			chunk_array[i].y      = static_cast<int>(y);
			chunk_array[i].size   = 0;
			chunk_array[i].buffer = data;
			chunk_array[i].state  = chunk_state_data;

			break;
		}
	}

	return 0.0;
}

GML_EXPORT double voxel_can_spawn()
{
	for (int i = 0; i < CHUNK_MAX_QUEUE; i++)
	{
		if (chunk_array[i].state == chunk_state_none)
		{
			// Success
			return 1.0;
		}
	}

	// Failure
	return 0.0;
}