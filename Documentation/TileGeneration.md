# Tile Generation
Should a tile from the standard 47-tile blob tileset be missing from a ZIP file, the importer will attempt to generate it. As long as at least one edge tile (`EDGE_L`, `EDGE_R`, `EDGE_T` or `EDGE_B`) is present in the tileset, the importer can generate all of the other 46 tiles from it.

Typically you will more tiles than just one edge, as the generation algorithm is quite simple.

## Generation Logic
The ways in which each tile is generated is as follows:
- `CENTER`: horizontally-combining the right side of `EDGE_L` and the left side of `EDGE_R`.
- Edges:
  - `EDGE_L`: flipping `EDGE_R` or rotating `EDGE_T`.
  - `EDGE_R`: flipping `EDGE_L`.
  - `EDGE_T`: flipping `EDGE_B` or rotating `EDGE_L`.
  - `EDGE_B`: flipping `EDGE_T`.
- Outer corners:
  - `NOOK_TL`: flipping `NOOK_TR`, `NOOK_BL` or `NOOK_BR`, or diagonally-combining `EDGE_L` and `EDGE_T`.
  - `NOOK_TR`: flipping `NOOK_TL` or diagonally-combining `EDGE_R` and `EDGE_T`.
  - `NOOK_BL`: flipping `NOOK_BR`, flipping `NOOK_TL` or diagonally-combining `EDGE_L` and `EDGE_B`.
  - `NOOK_BR`: flipping `NOOL_BL` or diagonally-combining `EDGE_R` and `EDGE_B`.
- Inner corners:
  - `CORNER_TL`: flipping `CORNER_TR`, `CORNER_BL` or `CORNER_BR` or diagonally-combining `EDGE_T` and `EDGE_L`.
  - `CORNER_TR`: flipping `CORNER_TL` or diagonally-combining `EDGE_T` and `EDGE_R`.
  - `CORNER_BL`: flipping `CORNER_TL`, flipping `CORNER_BR` or diagonally-combining `EDGE_B` and `EDGE_L`.
  - `CORNER_BR`: flipping `CORNER_BL` or diagonally-combining `EDGE_B` and `EDGE_R`.
- Caps:
  - `CAP_L`: flipping `CAP_R` or vertically-combining `NOOK_TL` and `NOOK_BL`.
  - `CAP_R`: flipping `CAP_L` or vertically-combining `NOOK_TR` and `NOOK_BR`.
  - `CAP_T`: flipping `CAP_B` or horizontally-combining `NOOK_TL` and `NOOK_TR`.
  - `CAP_B`: flipping `CAP_T` or horizontally-combining `NOOK_BL` and `NOOK_BR`.
- Thin middle:
  - `MIDDLE_H`: vertically-combining `EDGE_T` and `EDGE_B`.
  - `MIDDLE_V`: horizontally-combining `EDGE_L` and `EDGE_R`.
- `SINGLE`: combining the corners of `NOOK_TL`, `NOOK_TR`, `NOOK_BL` and `NOOK_BR`.
- Double inner corners:
  - `GAP_L`: flipping `GAP_R` or vertically combining `CORNER_TL` and `CORNER_BL`.
  - `GAP_R`: flipping `GAP_L` or vertically combining `CORNER_TR` and `CORNER_BR`.
  - `GAP_T`: flipping `GAP_B` or horizontally combining `CORNER_TL` and `CORNER_TR`.
  - `GAP_B`: flipping `GAP_T` or horizontally combining `CORNER_BL` and `CORNER_BR`.
- Diagonally-opposed double inner corners:
  - `DIAG_U`: vertically-combining `CORNER_TL` and `CORNER_BR`.
  - `DIAG_D`: vertically-combining `CORNER_BL` and `CORNER_TR`.
- Triple inner corners:
  - `HUB_TL`: flipping `GAP_TR`, `GAP_BL` or `GAP_BR` or combining the corners of `CORNER_TL`, `CORNER_TR`, `CENTER` and `CORNER_BL`.
  - `HUB_TR`: flipping `GAP_TL` or combining the corners of `CORNER_TL`, `CORNER_TR`, `CORNER_BR` and `CENTER`.
  - `HUB_BL`: flipping `GAP_BR`, flipping `GAP_TL` or combining the corners of `CORNER_TL`, `CENTER`, `CORNER_BR` and `CORNER_BL`.
  - `HUB_BR`: flipping `GAP_BL` or combining the corners of `CENTER`, `CORNER_TR`, `CORNER_BR` and `CORNER_BL`.
- `CROSS`: combining the corners of `CORNER_TL`, `CORNER_TR`, `CORNER_BR` and `CORNER_BL`.
- Elbow turns:
  - `TURN_TL`: flipping `TURN_TR`, `TURN_BL` or `TURN_BR` or combining `NOOK_TL` with the bottom-right corner of `CORNER_BR`.
  - `TURN_TR`: flipping `TURN_TL` or combining `NOOK_TR` with the bottom-Left corner of `CORNER_BL`.
  - `TURN_BL`: flipping `TURN_BR`, flipping `TURN_TL` combining `NOOK_BL` with the top-right corner of `CORNER_TR`.
  - `TURN_BR`: flipping `TURN_BL` or combining `NOOK_BR` with the top-left corner of `CORNER_TL`.
- T-Junctions:
  - `JUNCTION_L`: flipping `JUNCTION_R` or horizontally-combining `EDGE_L` and `GAP_R`.
  - `JUNCTION_R`: flipping `JUNCTION_L` or horizontally-combining `EDGE_R` and `GAP_L`.
  - `JUNCTION_T`: flipping `JUNCTION_B` or vertically-combining `EDGE_T` and `GAP_B`.
  - `JUNCTION_B`: flipping `JUNCTION_T` or vertically-combining `EDGE_B` and `GAP_T`.
- Edge + inner corner:
  - Horizontal edges:
	- `EXIT_H_TL`: flipping `EXIT_H_TR`, `EXIT_H_BL`, `EXIT_H_BR` or vertically-combining `EDGE_T` and `CORNER_BL`.
	- `EXIT_H_TR`: vertically-combining `EDGE_T` and `CORNER_BR`.
	- `EXIT_H_BL`: flipping `EXIT_H_BR`, flipping `EXIT_H_TL` or vertically-combining `EDGE_B` and `CORNER_TL`.
	- `EXIT_H_BR`: vertically-combining `EDGE_B` and `CORNER_TR`.
  - Vertical edges:
	- `EXIT_V_TL`: flipping `EXIT_V_TR`, `EXIT_V_BL`, `EXIT_V_BR` or horizontally-combining `EDGE_L` and `CORNER_TR`.
	- `EXIT_V_TR`: flipping `TURN_TL` or horizontally-combining `EDGE_R` and `CORNER_TL`.
	- `EXIT_V_BL`: flipping `EXIT_V_BR`, flipping `EXIT_V_TL` or horizontally-combining `EDGE_L` and `CORNER_BR`.
	- `EXIT_V_BR`: flipping `EXIT_V_BL` or horizontally-combining `EDGE_R` and `CORNER_BL`.

## Slopes
Slope tiles can also be generated. At very least, you will need:
- One the four slope surface tiles: `SLOPE_TL`, `SLOPE_TR`, `SLOPE_BL` or `SLOPE_BR`.
- One of the four slope-to-slope corner connections: `SLOPE_CORNER_TL`, `SLOPE_CORNER_TR`, `SLOPE_CORNER_BL` or `SLOPE_CORNER_BR`.

## Slope Generation Logic
- Slope surfaces:
  - `SLOPE_TL`: flipping `SLOPE_TR` or `Slope_BL`.
  - `SLOPE_TR`: flipping `SLOPE_TL`.
  - `SLOPE_BL`: flipping `SLOPE_BR` or `SLOPE_TL`.
  - `SLOPE_BR`: flipping `SLOPE_BL`.
- Slope-to-slope corner connectors:
  - `SLOPE_CORNER_TL`: flipping `SLOPE_CORNER_TR` or `SLOPE_CORNER_BL`.
  - `SLOPE_CORNER_TR`: flipping `SLOPE_CORNER_TL`.
  - `SLOPE_CORNER_BL`: flipping `SLOPE_CORNER_BR` or `SLOPE_CORNER_TL`.
  - `SLOPE_CORNER_BR`: flipping `SLOPE_CORNER_BL`.
- Bottom slope-to-ground corner connectors:
  - `SLOPE_BASE_TL`: flipping `SLOPE_BASE_TR` or `SLOPE_BASE_BL`, or diagonally-combining `CORNER_TL` with `SLOPE_CORNER_TL`.
  - `SLOPE_BASE_TR`: flipping `SLOPE_BASE_TL` or `SLOPE_BASE_BL`, or diagonally-combining `CORNER_TR` with `SLOPE_CORNER_TR`.
  - `SLOPE_BASE_BL`: flipping `SLOPE_BASE_BR` or `SLOPE_BASE_TL`, or diagonally-combining `CORNER_BL` with `SLOPE_CORNER_BL`.
  - `SLOPE_BASE_BR`: flipping `SLOPE_BASE_BL`, or diagonally-combining `CORNER_BR` with `SLOPE_CORNER_BR`.
- Top slope-to-ground corner connectors:
  - `SLOPE_PEAK_TL`: flipping `SLOPE_PEAK_TR` or `SLOPE_PEAK_BL`, or diagonally-combining `EDGE_T` with `SLOPE_CORNER_TL`.
  - `SLOPE_PEAK_TR`: flipping `SLOPE_PEAK_TL` or `SLOPE_PEAK_BL`, or diagonally-combining `EDGE_T` with `SLOPE_CORNER_TR`.
  - `SLOPE_PEAK_BL`: flipping `SLOPE_PEAK_BR` or `SLOPE_PEAK_TL`, or diagonally-combining `EDGE_B` with `SLOPE_CORNER_BL`.
  - `SLOPE_PEAK_BR`: flipping `SLOPE_PEAK_BL`, or diagonally-combining `EDGE_B` with `SLOPE_CORNER_BR`.
