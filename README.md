# Rusty.TilesetMaker
An import plugin for the Godot game engine that imports tilesets from a ZIP file. The importer can generate missing tiles by recombining other tiles in the tileset, reducing the number of tiles that you need to manage.

## Install Guide
1. Create a folder called `Addons/RustyTilesetImporter`.
2. Extract the contents of this repository to that folder.
3. Enable the import plugin under `Project Settings` => `Plugins`.

## How to Use
You can import ZIP tilesets as either a `Texture2D` or a `TileSet`. In the case of the latter, terrains will be automatically set up. In the case of the former, you will have to do this yourself.

The importer expects the tile images inside the ZIP file to have specific names. See the image below for reference:
[TODO: IMAGE]

## Recombination
If a tile is missing from the ZIP file, the importer will attempt to generate them by transposing or combining other tiles from the tileset. The way in which it does this is relatively simplistic: if the default generation is not enough for a tile, you must instead supply an image yourself. See *Recombination.md* for a specification of how tiles are generated.

## Planned Features
- Adding additional, non-standard tiles.
- Adding tile variants.
