extends Object;

const TileID = preload("../Enums/TileID.gd").TileID;
const BlockID = preload("../Enums/BlockID.gd").BlockID;
const Bit = preload("../Enums/PeeringBit.gd").PeeringBit;

## The info of a tile.
class TileInfo:
	var id : TileID;
	var block : BlockID = BlockID.Standard;
	var coords : Vector2i = Vector2i(-1, -1);
	var peering_bits : Array = [];
	var gen_rules : Dictionary = {};
	
	func _init(_block : BlockID, _coords : Vector2i, _peering_bits : Array, _gen_rules : Dictionary) -> void:
		self.block = _block;
		self.coords = _coords;
		self.peering_bits = _peering_bits;
		self.gen_rules = _gen_rules;
