# GHOST OPEN WORLD

A mobile-first third-person 3D urban exploration prototype for Android, targeting the Poco X7 Pro.

## Agreed direction
- Play as a masked operator inspired by the broad look of Ghost, using original/licensed assets rather than copied commercial game files.
- Open city roaming first: no story missions or levels yet. Missions can be added later.
- Visual target: a lightweight, classic-era 3D look in the spirit of GTA: San Andreas, not GTA V-level rendering.
- Third-person camera and basic movement.
- A clothing shop with multiple operator outfit styles that can be unlocked with in-game coins.

## Current prototype features
- Godot 4 project configuration.
- A basic test scene, ground, player collision and third-person camera.
- Keyboard movement for editor testing.
- An initial outfit shop UI with five placeholder color styles and a simple coin balance.

## Important prototype limits
The character is currently a capsule placeholder; outfit choices currently change its material color, not a finished 3D uniform model. The city is not yet a complete open world. Mobile touch controls, proper character models, detailed streets/buildings, saving purchases, and Android export still need implementation and testing in Godot on a device.

GitHub stores the project source; it does not run Godot or automatically create a tested APK.

## Build progress

### Step 1 — Open roaming city
- Added a procedural city generator with a 5-by-5 block layout.
- Added a grid of roads and low-poly building blocks with collision.
- Connected the city generator to the main scene.
- Kept story missions and levels out of the project, as requested.

This is a lightweight blockout made from Godot primitive meshes, not a finished detailed city. It has not yet been launched in the Godot editor or tested on a Poco X7 Pro. Next step: improve player movement and add on-screen mobile controls.

### Character appearance update
- Replaced the single capsule placeholder with a human-proportioned masked operator assembled from separate head, torso, arms, legs, helmet and gear meshes.
- Added a pale skull-style face mask and dark tactical outfit details to evoke the requested Ghost-like look.
- This is still a procedural low-poly placeholder, not a finished realistic scanned/rigged character model; animations, detailed textures and a licensed/original high-quality model remain future work.

### Mobile touch controls
- Added an on-screen virtual joystick on the lower-left and a jump button on the lower-right.
- The controls send the same movement and jump actions used by the player controller. Mouse interaction is also supported for basic desktop input checks.
- The Godot project files are committed to GitHub, but the scene has not yet been launched in Godot or tested on a physical Android device.
