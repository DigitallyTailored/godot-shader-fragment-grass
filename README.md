# godot-shader-fragment-grass
This is a fragment shader for Godot based on this paper: https://www.cg.tuwien.ac.at/research/publications/2007/Habel_2007_IAG/
The aim is to create a large amount of detailed grass on a terrain with little impact on FPS. This is targeting GLES2 for better mobile and WebGL support.


I initially ported the HLSL shader to GLSL and had a stab at simplifying the implementation, removing the tiled texture map and the animation. I am quite pushed for time to work on this and progress has been very slow, so I thought I'd share my work so far. It would be great if someone is able to carry on from this. There is a very similar shader for Unity which I believe is based on the same paper: https://assetstore.unity.com/packages/tools/particles-effects/volumegrass-436


There are a few things that can be improved with this:
* some deviation between cells of the grid
* depth checking against other objects (though this is quite the challenege with GLSL2 when using more than one object)

![frag5](https://user-images.githubusercontent.com/13086157/119156312-05a65600-ba4c-11eb-8278-b08c9a5d1c62.jpg)

![frag3](https://user-images.githubusercontent.com/13086157/119156316-06d78300-ba4c-11eb-9361-31e793d958d7.jpg)
![frag2](https://user-images.githubusercontent.com/13086157/119156318-06d78300-ba4c-11eb-933f-49fb58adcfbf.jpg)
![frag1](https://user-images.githubusercontent.com/13086157/119156321-07701980-ba4c-11eb-9761-1cd0eba09b7d.jpg)

Depth checking against other objects and other instances of this shader would help avoid drawing grass 'through' other objects
![frag4](https://user-images.githubusercontent.com/13086157/119156315-063eec80-ba4c-11eb-9221-32de61f5a7df.jpg)
