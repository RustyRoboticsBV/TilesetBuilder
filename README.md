# Rusty.TilesetMaker
An import plugin for the Godot game engine. It can:
- Create standard 47-tile "blob" tilesets from a ZIP file that contains separate tile images, so you won't have to do this manually.
- Generate missing tiles by combining or transposing other tiles in the tileset, reducing the number of tiles that you need to manage.

See *Documentation/TileGeneration.md* for more details about how missing tiles are generated.

## Install Guide
1. Create a folder called `Addons/TilesetImporter`.
2. Extract the contents of this repository to that folder.
3. Enable the import plugin under `Project Settings` => `Plugins`.

## How to Use
You can import ZIP tilesets as either a `Texture2D` or a `TileSet`. In the case of the latter, terrains will be automatically set up. In the case of the former, you will have to do this yourself.
The tool supports ZIP files that contain BMP and PNG files.

The importer expects the tile images inside the ZIP file to have specific names. See the image below for reference:
![The tiles of a 47-tile blob tileset, and their identifiers.](TilesetReference.png)

## Planned Features
- Adding the option for user-defined, non-standard tiles.
- Adding the option for tile variants.

## Known Issues
For the tileset importer, there seem to be internal engine bugs that cause Godot to spam the console with large amounts of errors:
- Whenever the tileset importer assigns terrain bitmasks to its generated tileset, hundreds of errors get spammed to the console.
- When a tileset is reimported while a scene that uses it is opened, Godot will start spamming the console with errors that cause huge slowdown until the scene is closed. Reopening the scene fixes this.

Despite this, the importing process seems to finish succesfully. The texture import doesn't have these problems.
