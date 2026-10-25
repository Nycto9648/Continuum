#version 330
#extension GL_ARB_separate_shader_objects : require
layout(location=0) in vec2 texCoord;
layout(location=0) out vec4 fragColor;
uniform sampler2D Art1Sampler;
uniform sampler2D Art2Sampler;
uniform sampler2D Art3Sampler;
uniform sampler2D Art4Sampler;
uniform sampler2D Art5Sampler;
uniform sampler2D Art6Sampler;
uniform sampler2D Art7Sampler;
uniform sampler2D Art8Sampler;
uniform sampler2D Art9Sampler;
void main(){
 int row=int(gl_FragCoord.y)/16;
 vec2 uv=vec2(gl_FragCoord.x/16.0,fract(gl_FragCoord.y/16.0));
 if(row==0) {fragColor=texture(Art1Sampler,uv);return;}
 if(row==1) {fragColor=texture(Art2Sampler,uv);return;}
 if(row==2) {fragColor=texture(Art3Sampler,uv);return;}
 if(row==3) {fragColor=texture(Art4Sampler,uv);return;}
 if(row==4) {fragColor=texture(Art5Sampler,uv);return;}
 if(row==5) {fragColor=texture(Art6Sampler,uv);return;}
 if(row==6) {fragColor=texture(Art7Sampler,uv);return;}
 if(row==7) {fragColor=texture(Art8Sampler,uv);return;}
 if(row==8) {fragColor=texture(Art9Sampler,uv);return;}
 fragColor=vec4(0.0);
}
