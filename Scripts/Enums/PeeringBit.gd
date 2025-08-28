## The peering bits that a tile's terrain bitmask can use.
enum PeeringBit {
	TL = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	T = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TR = TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	L = TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	R = TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	BL = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	B = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	BR = TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
}
