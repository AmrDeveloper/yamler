YAML modification program Beta Version

that can parse yaml code to Yaml Abstract syntax tree (AST) data structure

modify ast so you can change value, object, array values and can change comment text

generate yaml code from yaml Abstract syntax tree (AST) data structure

Example one Input :



    json:
      - rigid
      - better for data interchange
    yaml:
      - slim and flexible
      - better for configuration
    object:
	  key: value      <- The goal value to HelloWorld
      array:
        - boolean: true
        - integer: 1


The goal is to change value of key with name key to HelloWorld

    //First parse code and generate Abstract syntax tree
    var yamlAST = yamlParser.parseYamlCode(inputPath);
    
    //Get list of value of object with key = object
    List objectValList = yamlAST.getNodeValue('object').value.getValue();
    
    //Node with key = 'key' is first value in object list
    Node node = objectValList[0];
    
    //After get the target node change the value of it
    node.value.setValue('HelloWorld');
    
    //Genrate yaml text code for the new Yaml ASt after change
    var outputYaml = yamlWriter.generateYamlString(yamlAST);
    
    //write new code in output file
    writeFileContent(outputPath, outputYaml);
    
Example one Output :

    json:
      - rigid
      - better for data interchange
    yaml:
      - slim and flexible
      - better for configuration
    object:
      key: HelloWorld   <- value is changed ^_^
      array: 
        - boolean: true
        - integer: 1
        
You can change the comment text too every comment key is equal comment_ + number of comment
for example first comment key = comment_0
