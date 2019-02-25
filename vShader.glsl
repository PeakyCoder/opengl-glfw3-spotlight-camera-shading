#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;

// declare an interface block; see 'Advanced GLSL' for what these are.
out VS_OUT {
    vec3 FragPos;
    vec3 Normal;
    vec2 TexCoords;
	vec4 color;
} vs_out;

struct Material {
    sampler2D diffuse;
    sampler2D specular;    
    float shininess;
}; 

struct Light {
    vec3 position;  
    vec3 direction;
    float cutOff;
    float outerCutOff;
  
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
	
    float constant;
    float linear;
    float quadratic;
};


uniform vec3 viewPos;
uniform Material material;
uniform Light light;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 scale;
uniform mat4 rotate;
uniform mat4 translate;

void main()
{
    vs_out.FragPos = vec3(translate * rotate * scale * vec4(aPos, 1.0));
    vs_out.Normal = mat3(transpose(inverse(translate * rotate * scale))) * aNormal;  
    vs_out.TexCoords = aTexCoords;
    gl_Position = projection * view * translate * rotate * scale * vec4(aPos, 1.0);

	//Per Vertex Shader
	// Ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, aTexCoords));
    
    // Diffuse
    vec3 norm = normalize(vs_out.Normal);
    vec3 lightDir = normalize(light.position - vs_out.FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, aTexCoords));
    
    // Specular
    vec3 specular = light.specular * vec3(texture(material.specular, aTexCoords));
    
    // Spotlight (soft edges)
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = (light.cutOff - light.outerCutOff);
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
    diffuse  *= intensity;
    specular *= intensity;
    
    // Attenuation
    float distance    = length(light.position - vs_out.FragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;
        
    vec3 result = ambient + diffuse + specular;
	
	vs_out.color = vec4(result, 1.0);

}
