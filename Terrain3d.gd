tool
extends MeshInstance
class_name Terrain3d

const VERTICES_PER_SIDE = 10
const CELL_SIDE_SIZE = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	
	var noise = OpenSimplexNoise.new()
	noise.seed = 0
	noise.octaves = 1
	noise.period = 10
	noise.persistence = 1.0 # Not respected for single octave, Godot bug?

	var verts = PoolVector3Array()
	verts.resize(VERTICES_PER_SIDE * VERTICES_PER_SIDE)
	var colors = PoolColorArray()
	colors.resize(verts.size())
	var indices = PoolIntArray()
	
	for i in range(0, VERTICES_PER_SIDE):
		for j in range(0, VERTICES_PER_SIDE):
			var idx = i * VERTICES_PER_SIDE + j
			var x = i * CELL_SIDE_SIZE
			var z = j * CELL_SIDE_SIZE
			var y = noise.get_noise_2d(x, z) * CELL_SIDE_SIZE
			var vert = Vector3(x, y, z)
			print(vert)
			verts.set(idx, vert)

			colors.set(idx, Color.white)
			
			if i != 0 and j != 0:
				var north = idx - VERTICES_PER_SIDE
				var north_west = north - 1
				var west = idx - 1
				indices.push_back(idx)
				indices.push_back(north)
				indices.push_back(north_west)
				indices.push_back(idx)
				indices.push_back(north_west)
				indices.push_back(west)
	

	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_COLOR] = colors
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
