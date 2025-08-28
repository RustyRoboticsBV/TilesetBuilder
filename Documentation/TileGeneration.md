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
  - `NOOK_TL`: diagonally-combining `EDGE_L` and `EDGE_T`.
  - `NOOK_TR`: diagonally-combining `EDGE_R` and `EDGE_T`.
  - `NOOK_BL`: diagonally-combining `EDGE_L` and `EDGE_B`.
  - `NOOK_BR`: diagonally-combining `EDGE_R` and `EDGE_B`.
- Inner corners:
  - `CORNER_TL`: diagonally-combining `EDGE_T` and `EDGE_L`.
  - `CORNER_TR`: diagonally-combining `EDGE_T` and `EDGE_R`.
  - `CORNER_BL`: diagonally-combining `EDGE_B` and `EDGE_L`.
  - `CORNER_BR`: diagonally-combining `EDGE_B` and `EDGE_R`.
- Caps:
  - `CAP_L`: vertically-combining `NOOK_TL` and `NOOK_BL`.
  - `CAP_R`: vertically-combining `NOOK_TR` and `NOOK_BR`.
  - `CAP_T`: horizontally-combining `NOOK_TL` and `NOOK_TR`.
  - `CAP_B`: horizontally-combining `NOOK_BL` and `NOOK_BR`.
- Thin middle:
  - `MIDDLE_H`: vertically-combining `EDGE_T` and `EDGE_B`.
  - `MIDDLE_V`: horizontally-combining `EDGE_L` and `EDGE_R`.
- `SINGLE`: combining the corners of `NOOK_TL`, `NOOK_TR`, `NOOK_BL` and `NOOK_BR`.
- Double inner corners:
  - `GAP_L`: vertically-combining `CORNER_TL` and `CORNER_BL`.
  - `GAP_R`: vertically-combining `CORNER_TR` and `CORNER_BR`.
  - `GAP_T`: horizontally-combining `CORNER_TL` and `CORNER_TR`.
  - `GAP_B`: horizontally-combining `CORNER_BL` and `CORNER_BR`.
- Diagonally-opposed double inner corners:
  - `DIAG_U`: diagonally-combining `CORNER_TL` and `CORNER_BR`.
  - `DIAG_D`: diagonally-combining `CORNER_BL` and `CORNER_TR`.
- Triple inner corners:
  - `HUB_TL`: combining the corners of `CORNER_TL`, `CORNER_TR`, `CENTER` and `CORNER_BL`.
  - `HUB_TR`: combining the corners of `CORNER_TL`, `CORNER_TR`, `CORNER_BR` and `CENTER`.
  - `HUB_BL`: combining the corners of `CORNER_TL`, `CENTER`, `CORNER_BR` and `CORNER_BL`.
  - `HUB_BR`: combining the corners of `CENTER`, `CORNER_TR`, `CORNER_BR` and `CORNER_BL`.
- `CROSS`: combining the corners of `CORNER_TL`, `CORNER_TR`, `CORNER_BR` and `CORNER_BL`.
- Elbow turns:
  - `TURN_TL`: combining `NOOK_TL` with the bottom-right corner of `CORNER_BR`.
  - `TURN_TR`: combining `NOOK_TR` with the bottom-Left corner of `CORNER_BL`.
  - `TURN_BL`: combining `NOOK_BL` with the top-right corner of `CORNER_TR`.
  - `TURN_BR`: combining `NOOK_BR` with the top-left corner of `CORNER_TL`.
- T-Junctions:
  - `JUNCTION_L`: horizontally-combining `EDGE_L` and `GAP_R`.
  - `JUNCTION_R`: horizontally-combining `EDGE_R` and `GAP_L`.
  - `JUNCTION_T`: vertically-combining `EDGE_T` and `GAP_B`.
  - `JUNCTION_B`: vertically-combining `EDGE_B` and `GAP_T`.
- Edge + inner corner:
  - Horizontal edges:
	- `EXIT_H_TL`: vertically-combining `EDGE_T` and `CORNER_BL`.
	- `EXIT_H_TR`: vertically-combining `EDGE_T` and `CORNER_BR`.
	- `EXIT_H_BL`: vertically-combining `EDGE_B` and `CORNER_TL`.
	- `EXIT_H_BR`: vertically-combining `EDGE_B` and `CORNER_TR`.
  - Vertical edges:
	- `EXIT_V_TL`: horizontally-combining `EDGE_L` and `CORNER_TR`.
	- `EXIT_V_BL`: horizontally-combining `EDGE_L` and `CORNER_BR`.
	- `EXIT_V_TR`: horizontally-combining `EDGE_R` and `CORNER_TL`.
	- `EXIT_V_BR`: horizontally-combining `EDGE_R` and `CORNER_BL`.
