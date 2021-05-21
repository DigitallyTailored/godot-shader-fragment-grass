shader_type spatial;
uniform bool terrain;
void vertex(){
    VERTEX.y = (sin(VERTEX.x*10.0)*0.1)+sin(VERTEX.z*10.0)*0.1;
   }