extends Node3D

# Export variables for the star mesh and JSON file path
@export var star_mesh: Mesh
@export var json_file_path: String

# Maximum number of stars to create
const MAX_STARS = 100

# Called when the node enters the scene tree
func _ready():
	load_stars_from_json()

# Load star data from JSON file and create star instances
func load_stars_from_json():
	# Open and read the JSON file
	var json_file = FileAccess.open(json_file_path, FileAccess.READ)
	if not json_file:
		print("Error loading JSON file: %s" % json_file_path)
		return

	var json_text = json_file.get_as_text()
	json_file.close()

	# Parse JSON data
	var json_data = JSON.parse_string(json_text)
	if not "stars" in json_data:
		print("Error: 'stars' key not found in JSON file.")
		return

	# Create star instances from the parsed data
	create_stars(json_data["stars"])

# Create star instances from the provided star data
func create_stars(stars_data):
	for star_data in stars_data:
		var star_instance = create_star_instance(star_data)
		add_child(star_instance)

		# Stop creating stars if we've reached the maximum
		if get_child_count() >= MAX_STARS:
			break

# Create a single star instance from the provided star data
func create_star_instance(star_data):
	var star_instance = MeshInstance3D.new()
	star_instance.mesh = star_mesh

	# Calculate and set the star's position
	var position = convert_position(
		float(star_data["GLAT"]),
		float(star_data["GLON"]),
		float(star_data["dist"])
	)
	star_instance.position = position

	# Create and apply the star's material
	var material = create_star_material(star_data)
	star_instance.material_override = material

	return star_instance

# Create a material for the star based on its color data
func create_star_material(star_data):
	var material = StandardMaterial3D.new()
	var color = Color(
		float(star_data["kR"]),
		float(star_data["kG"]),
		float(star_data["kB"])
	)
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 1.0
	return material

# Convert galactic coordinates to Cartesian coordinates
func convert_position(g_lat: float, g_long: float, dist: float) -> Vector3:
	# Convert angles from degrees to radians
	var g_long_rad = deg_to_rad(g_long)
	var g_lat_rad = deg_to_rad(g_lat)

	# Calculate Cartesian coordinates
	var x = dist * cos(g_lat_rad) * cos(g_long_rad)
	var y = dist * cos(g_lat_rad) * sin(g_long_rad)
	var z = dist * sin(g_lat_rad)

	return Vector3(x, y, z)
