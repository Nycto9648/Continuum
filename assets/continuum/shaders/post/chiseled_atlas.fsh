#version 330
#extension GL_ARB_separate_shader_objects : require
layout(location=0) in vec2 texCoord;
layout(location=0) out vec4 fragColor;
uniform sampler2D Image0Sampler;
uniform sampler2D Image1Sampler;
uniform sampler2D Image2Sampler;
uniform sampler2D Image3Sampler;
uniform sampler2D Image4Sampler;
uniform sampler2D Image5Sampler;
uniform sampler2D Image6Sampler;
uniform sampler2D Image7Sampler;
void main(){
 int row=int(gl_FragCoord.y)/16;
 vec2 uv=vec2(gl_FragCoord.x/16.0,fract(gl_FragCoord.y/16.0));
 if(row==0) {fragColor=texture(Image0Sampler,uv);return;}
 if(row==1) {fragColor=texture(Image1Sampler,uv);return;}
 if(row==2) {fragColor=texture(Image2Sampler,uv);return;}
 if(row==3) {fragColor=texture(Image3Sampler,uv);return;}
 if(row==4) {fragColor=texture(Image4Sampler,uv);return;}
 if(row==5) {fragColor=texture(Image5Sampler,uv);return;}
 if(row==6) {fragColor=texture(Image6Sampler,uv);return;}
 if(row==7) {fragColor=texture(Image7Sampler,uv);return;}
 fragColor=vec4(0.0);
}
