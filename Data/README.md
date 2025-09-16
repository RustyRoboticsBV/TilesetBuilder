The tile database JSON file contains all of the built-in tile data.

Each tile follows the format:
```
"key": {
	"block": "block name",
	"coords": [x, y],
	"derive": { ... },
	"layer": "terrain type name",
	"peering_bits": { ... }
}
```

Where:
- The `block` represents the tile texture area of the tile, and must be one of the following values: `main`, `slope`, `long_slope`, `tall_slope` or `slope_mix`.
- The `coords` represent the (x, y) coordinate on its block.
- The `derive` block represents the derivation rules for tile generation.
- The `layer` represents the terrain type of the tile, and must be one of the following values: `solid`, `slope_tl`, `slope_tr`, `slope_bl`, `slope_br`, `long_slope_tl`, `long_slope_tr`, `long_slope_bl`, `long_slope_br`, `tall_slope_tl`, `tall_slope_tr`, `tall_slope_bl` or `tall_slope_br`.
- The `peering_bits` block represent the possible terrain peering bits.

Since many tile definitions are just flipped or rotated versions of other tiles, we can also use the "inherit block", such as:
```
		"inherit": {
			"op": "rotate_clock",
			"from": "NOOK_TL"
		}
```
