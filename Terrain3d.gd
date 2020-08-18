tool
extends MeshInstance
class_name Terrain3d

export (int) var side_size = 100 setget _set_side_size
export (int) var resolution = 10 setget _set_resolution
export (float) var height_factor = 1 setget _set_height_factor

var material = load("res://Terrain.tres")

func _set_side_size(value):
	side_size = value
	build_mesh()
	
func _set_resolution(value):
	resolution = value
	build_mesh()

func _set_height_factor(value):
	height_factor = value
	build_mesh()

func cell_side_size():
	return side_size / resolution
	
func max_height():
	return height_factor * cell_side_size() / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	build_mesh()
	
func build_mesh():
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var noise = OpenSimplexNoise.new()
	noise.seed = 0
	noise.octaves = 1
	noise.period = 10
	noise.persistence = 1.0 # Not respected for single octave, Godot bug?

	var verts = PoolVector3Array()
	verts.resize(resolution * resolution)
	var colors = PoolColorArray()
	colors.resize(verts.size())
	var indices = PoolIntArray()
	
	var cell_side_size = cell_side_size()
	for i in range(0, resolution):
		for j in range(0, resolution):
			var idx = i * resolution + j
			var x = i * cell_side_size
			var z = j * cell_side_size
			var y = noise.get_noise_2d(x, z) * max_height()
			var vert = Vector3(x, y, z)
			verts.set(idx, vert)

			colors.set(idx, get_color(y))
			
			if i != 0 and j != 0:
				var north = idx - resolution
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
	mesh.surface_set_material(0, material)
	
	
func get_color(height):
	#TODO calculate ranges once, not for every vertex
	var max_height = max_height()
	print(height, " ", max_height())
	if height < (max_height * 0.1):
		return Color.blue
	elif height < (max_height * 0.15):
		return Color.yellow
	elif height < (max_height * 0.3):
		return Color.green
	elif height < (max_height * 0.6):
		return Color.brown
	else:
		return Color.white
		
