#version 330 core
out vec4 FragColor;

in VS_OUT {
    vec3 FragPos;
    vec3 Normal;
    vec2 TexCoords;
	vec4 color;
} fs_in;

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
uniform int spotKey;
uniform int whichPer;
uniform int reflectOn;
uniform samplerCube skybox;

void main()
{           
	// Ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, fs_in.TexCoords));
    
    // Diffuse
    vec3 norm = normalize(fs_in.Normal);
    vec3 lightDir = normalize(light.position - fs_in.FragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, fs_in.TexCoords));
    
    // Specular
    vec3 specular = light.specular * vec3(texture(material.specular, fs_in.TexCoords));
    
    // Spotlight (soft edges)
    float theta = dot(lightDir, normalize(-light.direction));
    float epsilon = (light.cutOff - light.outerCutOff);
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
    diffuse  *= intensity;
    specular *= intensity;
    
    // Attenuation
    float distance    = length(light.position - fs_in.FragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;

    vec3 result = (ambient + diffuse + specular) ;

	if(whichPer == 1){
		if(spotKey == 1){
			FragColor = vec4(result, 1.0);
		}
		else if(spotKey == -1){
			FragColor = texture(material.specular, fs_in.TexCoords);
		}
	}
	else if(whichPer == -1){
		if(spotKey == 1){
			FragColor = fs_in.color;
		}
		else if(spotKey == -1){
			FragColor = texture(material.specular, fs_in.TexCoords);
		}
	}
	

 
}