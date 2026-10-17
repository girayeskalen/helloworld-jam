class_name AssetRegistry
extends RefCounted
## Hand-crafted sprite auto-loader. Drop PNGs into res://assets/sprites/ and they
## replace the procedural art on the next run; missing files keep the procedural look.
##   player.png      -> player (feet at the bottom centre, faces right)
##   boss_storm.png  -> left storm boss
##   boss_quake.png  -> right seismic golem
##   tileset.png     -> tiled back-wall texture of every room (tinted per room)

const DIRECTORY: String = "res://assets/sprites/"
const FILES: Dictionary = {
	"player": "player.png",
	"boss_storm": "boss_storm.png",
	"boss_quake": "boss_quake.png",
	"tileset": "tileset.png",
}

static func load_textures(directory: String = DIRECTORY) -> Dictionary:
	var found: Dictionary = {}
	for key: String in FILES:
		var texture: Texture2D = load_texture(directory.path_join(String(FILES[key])))
		if texture != null:
			found[key] = texture
	return found

static func load_texture(path: String) -> Texture2D:
	# Imported (editor/export) files load as resources; a PNG dropped in while the
	# editor is closed, or a user:// file, is read directly as an image.
	if ResourceLoader.exists(path):
		var resource: Resource = load(path)
		if resource is Texture2D:
			return resource as Texture2D
	if FileAccess.file_exists(path):
		var image: Image = Image.load_from_file(path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)
	return null

## Hand-made files win over VisualAssets.tres slots, which win over procedural art.
static func apply(game: MainGame, textures: Dictionary) -> Dictionary:
	if textures.has("player"):
		game.player.custom_sprite = textures["player"]
	if textures.has("boss_storm"):
		game.storm.boss_sprite = textures["boss_storm"]
	if textures.has("boss_quake"):
		game.earthquake.boss_sprite = textures["boss_quake"]
	if textures.has("tileset"):
		for room: RoomDiorama in game.building.rooms:
			room.wall_texture = textures["tileset"]
	return textures
