# Godot-ready processed assets

- `sheets/*_transparent.png`: full-size source sheets with border backgrounds removed.
- `sprites/<sheet_name>/*.png`: automatically isolated sprite candidates, padded by 4 pixels and saved as RGBA PNG.

The source art remains unchanged under `assets/generated/vertical_slice/`. The isolation pass uses border flood-fill and connected components; review candidates with glow, soft shadows, or touching objects before production use.

Recommended Godot import settings:

- Texture Filter: **Nearest** for pixel art.
- Repeat: **Disabled**.
- Mipmaps: **Disabled** for 2D pixel assets.
- Compression: Lossless or VRAM Compressed when the target platform is confirmed.
- Keep the sprite's bottom-center as its scene origin for world objects and characters.
