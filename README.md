# A tiny gltf model loader for gltf encoded in json.

`TinyGLTF` is a D glTF 2.0 https://github.com/KhronosGroup/glTF library for loading embedded json gltf models. This only supports pure ``JSON`` encoded (embedded) models so you can load them up into your cool game.

I'm still working on this so the readme is going to look a bit bad.

For now, you can kind of follow this to use it in D maybe (It's C++):
[A Link To A Minetest Project Thing](https://github.com/jordan4ibanez/irrlicht/blob/feat/gltf-loader/source/Irrlicht/CGLTFMeshFileLoader.cpp#L715)

Keep in mind that you just create a ``Model`` object with a file location, then load it using ``loadFile()`` which will return a success boolean. See the unit test at the bottom of the source file.

## Change Log:

v1.0.3: Removed bloat, updated DDOC.

v1.0.2: Fixed it not being a module. (Thanks Adam!)

v1.0.1: Became it's own repo instead of a fork.

v1.0.0: It actually runs, woo. Translated from C to D.


See the original repo [here.](https://github.com/syoyo/tinygltf)

This was created by syoyo. But I basically gutted it and D-ified it.