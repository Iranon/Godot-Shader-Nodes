# Godot-Shader-Nodes
### Custom nodes for the Godot Visual Shader editor ([*Asset Library page*](https://godotengine.org/asset-library/asset/959))

Inside the custom folder there are two directories: nodes and shaders. The first one contains .gd files that define custom nodes for the Visual Shader, while the second one contains materials (.tres) that are made inside the Visual Shader with GlobalExpression and Expression nodes.

I put both version because the code contained inside the GlobalExpression nodes (in which are defined functions called in the Expression nodes) is the same as the one written inside \_the get_global_code() function (in the .gd files). This way it is possible to modify and test the code inside the .tres file and then change it in the .gd one. Open the Example_Scene.tscn file to take a look at how it works.

<sub>
The main purpose of this project is providing nodes similar to Blender's ones (and more) for the Godot Visual Shader. I used also functions by The Book of Shaders, Patricio Gonzalez Vivo and others (credits inside files). Please feel free to contribute.
</sub>
