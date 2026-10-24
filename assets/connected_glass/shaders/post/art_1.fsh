#version 330
#extension GL_ARB_separate_shader_objects : require
layout(location=0) in vec2 texCoord;
layout(location=0) out vec4 fragColor;
uniform sampler2D PreviousSampler;
uniform sampler2D Art10Sampler;
uniform sampler2D Art11Sampler;
uniform sampler2D Art12Sampler;
uniform sampler2D Art13Sampler;
uniform sampler2D Art14Sampler;
uniform sampler2D Art15Sampler;
uniform sampler2D Art16Sampler;
uniform sampler2D Art17Sampler;
uniform sampler2D Art18Sampler;
void main(){
 int row=int(gl_FragCoord.y)/16;
 vec2 uv=vec2(gl_FragCoord.x/16.0,fract(gl_FragCoord.y/16.0));
 if(row==9) {fragColor=texture(Art10Sampler,uv);return;}
 if(row==10) {fragColor=texture(Art11Sampler,uv);return;}
 if(row==11) {fragColor=texture(Art12Sampler,uv);return;}
 if(row==12) {fragColor=texture(Art13Sampler,uv);return;}
 if(row==13) {fragColor=texture(Art14Sampler,uv);return;}
 if(row==14) {fragColor=texture(Art15Sampler,uv);return;}
 if(row==15) {fragColor=texture(Art16Sampler,uv);return;}
 if(row==16) {fragColor=texture(Art17Sampler,uv);return;}
 if(row==17) {fragColor=texture(Art18Sampler,uv);return;}
 fragColor=texture(PreviousSampler,texCoord);
}
