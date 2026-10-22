# Godot-ready processed assets

The generator-provided alpha channel is preserved. `sheets/*_transparent.png` are complete RGBA sheets, and `sprites/<sheet_name>/*.png` are separate connected-component crops with 4px padding.

The earlier background flood-fill output was discarded because it removed dark interior pixels from buildings and props. These files keep the original artwork intact; review touching objects and glow effects before production use.

Godot import: Texture Filter **Nearest**, Repeat **Disabled**, Mipmaps **Disabled**, Lossless compression.
