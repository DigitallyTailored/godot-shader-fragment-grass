shader_type spatial;
uniform vec4 color_grass: hint_color;
uniform sampler2D texture_grass;
uniform sampler2D texture_ground;


void fragment() {

    vec3 view_dir = normalize(normalize(-VERTEX) * mat3(TANGENT, -BINORMAL, NORMAL));
    vec2 uvs = UV * 20.0;
    float uv_x_floor = floor(uvs.x);
    float uv_y_floor = floor(uvs.y);
    float depth_calc_x = (-1.0 + ((uvs.x - uv_x_floor) * 2.0));
    float depth_calc_y = (-1.0 + ((uvs.y - uv_y_floor) * 2.0));
    depth_calc_x = -uvs.x;
    depth_calc_y = -uvs.y;

    vec4 AVERAGE_COLOR = color_grass;

    const int MAX_RAYDEPTH = 5;

    float PLANE_NUM = 1.0;
    float PLANE_NUM_INV = 1.0;
    float PLANE_NUM_INV_DIV2 = 0.5;

    float GRASS_SLICE_NUM_INV_DIV2 = 1.0;

    float depth_grass = 1.0;

    //Initialize increments/decrements and per fragment constants
    vec4 color;
    vec2 plane_offset = vec2(0.0, 0.0);
    vec3 rayEntry = vec3(depth_calc_x, depth_calc_y, 0.0);
    float zOffset = 0.0;
    bool zFlag = true;



    //The signvecs of view_dir determines if we increment or decrement along the tangent space axis
    //plane_correct, planemod and pre_dir_correct are used to avoid unneccessary if-conditions. 

    vec2 signvec = vec2(sign(view_dir.x), sign(view_dir.y));

    //one of 4 directions from camera position
    vec2 plane_correct = vec2((signvec.x + 1.0) * GRASS_SLICE_NUM_INV_DIV2, (signvec.y + 1.0) * GRASS_SLICE_NUM_INV_DIV2);

    //seems to be constant?
    vec2 planemod = vec2(floor(rayEntry.x * PLANE_NUM) / PLANE_NUM, floor(rayEntry.y * PLANE_NUM) / PLANE_NUM);

    vec2 pre_dir_correct = vec2((signvec.x + 1.0) * PLANE_NUM_INV_DIV2, (signvec.y + 1.0) * PLANE_NUM_INV_DIV2);



    //int hitcount;
    for (int hitcount = 0; hitcount < MAX_RAYDEPTH % (MAX_RAYDEPTH + 1); hitcount++) // %([MAX_RAYDEPTH]+1) speeds up compilation.
    // It may proof to be faster to early exit this loop
    // depending on the hardware used.
    {
        //Calculate positions of the intersections with the next grid planes on the u,v tangent space axis independently.
        vec2 dir_correct = vec2(signvec.x * plane_offset.x + pre_dir_correct.x, signvec.y * plane_offset.y + pre_dir_correct.y);
        vec2 distance = vec2((planemod.x + dir_correct.x - rayEntry.x) / (view_dir.x), (planemod.y + dir_correct.y - rayEntry.y) / (view_dir.y));

        vec3 rayHitpointX = rayEntry + view_dir * distance.x;
        vec3 rayHitpointY = rayEntry + view_dir * distance.y;

        //Check if we hit the ground. If so, calculate the intersection and look up the ground texture and blend colors.
        if ((rayHitpointX.z >= depth_grass) && (rayHitpointY.z >= depth_grass)) {
            //hit ground
            float distanceZ = (-depth_grass) / view_dir.z; // rayEntry.z is 0.0 anyway 

            vec3 rayHitpointZ = rayEntry + view_dir * distanceZ;
            vec2 orthoLookupZ = vec2(rayHitpointZ.x, rayHitpointZ.y);

            if (zFlag) {
                zOffset = distanceZ; // write the distance from rayEntry to intersection
            }
            zFlag = false;
            //Early exit here if faster.
            //hitcount = MAX_RAYDEPTH; //need to comment this line out for WebGL
        } else {
            //did not hit ground
            vec2 orthoLookup; //Will contain texture lookup coordinates for grassblades texture.

            //check if we hit a u or v plane, calculate lookup accordingly with wind shear displacement.
            if (distance.x <= distance.y) {
                float lookupX = -(rayHitpointX.z + (planemod.x + signvec.x * plane_offset.x) * 1.0) - plane_correct.x;
                orthoLookup = vec2(rayHitpointX.y * (depth_grass), lookupX);
                plane_offset.x += PLANE_NUM_INV; // increment/decrement to next grid plane on u axis
                if (zFlag) {
                    zOffset = distance.x;
                }
            } else {
                float lookupY = -(rayHitpointY.z + (planemod.y + signvec.y * plane_offset.y) * 1.0) - plane_correct.y;
                orthoLookup = vec2(rayHitpointY.x, lookupY);
                plane_offset.y += PLANE_NUM_INV; // increment/decrement to next grid plane on v axis
                if (zFlag) {
                    zOffset = distance.y;
                }
            }
            vec4 texture_grass_ortho = texture(texture_grass, -vec2(orthoLookup.x + 0.5, orthoLookup.y));
            color = (color.a * color) + (1.0 - color.a) * ((texture_grass_ortho.a) * texture_grass_ortho);

            if (color.a >= 0.49) {
                zFlag = false;
            }
        }
    }

    if (color.a < 0.5) {
        discard;
    }

    ALBEDO = color.rgb * color_grass.rgb;

    METALLIC = 0.5;
    ROUGHNESS = 0.7;

}