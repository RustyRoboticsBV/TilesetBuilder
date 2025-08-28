# ZIP Tileset Importer
An import plugin for the Godot game engine (version 4.4). It can:
- Create standard 47-tile "blob" tilesets from a ZIP file that contains separate tile images, so you won't have to do this manually.
- Generate missing tiles by combining or transposing other tiles in the tileset, reducing the number of tiles that you need to manage.
- Import ZIP tilesets as either a `Texture2D` atlas or a `TileSet`.

The following image types are supported: BMP, PNG, JPG, TGA, WEBP, SVG, DDS, KTX. The images in the ZIP files must conform to specific filenames (see the image below).

## Install Guide
1. Create a folder called `Addons/ZipTilesetImporter`.
2. Extract the contents of this repository to that folder.
3. Enable the import plugin under `Project Settings` => `Plugins`.

## How to Use
After installing, create a ZIP file and fill it with image files, using the filenames in the image below. You can choose between importing the ZIP file as a texture atlas or tileset under `Import` => `Import As` window.
- When importing as a tileset, its terrain (autotiling) will automatically be set up.
- When importing as a texture, you must create the actual tileset resource yourself, but you get more control over its properties.

### Standard Tiles
This image shows you which tile each filename maps to:
![The tiles of a 47-tile blob tileset, and their identifiers.](TilesetReference.png)

For example, the file `archive.zip/NOOK_TR.png` would be used as the top-right outer corner tile.

As stated before, missing tiles will be automatically generated. See `Documentation/TileGeneration.md` for more details about the generation process.

### User-Defined Tiles
You can add custom tiles by adding images with filenames that are not in the image above. These tiles are placed below the standard tileset area. For example, if you want to add slopes to your tileset you can do so in this way.

## Planned Features
- Adding the option for tile variants.

## Known Issues
Due to what seems to be an internal engine bug, when a tileset is reimported while a scene that uses is open, Godot will start spamming the console with errors that cause a huge slowdown until the scene is closed. Reopening the scene fixes this.
