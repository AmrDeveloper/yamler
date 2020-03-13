import 'tokens.dart';

class YamlGenerator {

  String generateYamlString(Yaml yaml) {
     var yamlOutput = '';
     var nodeMap = yaml.getNodes();
     for(var node in nodeMap.values){
        var vType = node.value.valueType;
        if(vType == ValueType.comment){
           yamlOutput += node.value.getValue() + '\n';
        }
        else if(vType == ValueType.line){
          yamlOutput += '\n';
        }
        else if(vType == ValueType.object)
        {
           yamlOutput += _generateYamlObject(node);
        }
        else if(vType == ValueType.array)
        {
           yamlOutput += _generateYamlArray(node);
        }
        else
        {
           yamlOutput += _generateYamlConst(node);
        }
     }
     return yamlOutput;
  }

  String _generateYamlObject(Node node){
     var yamlObject = '';
     yamlObject += _addScopeToCode('${node.key.name}:\n', node.scope);
     List nodeList = node.value.val;
     for(Node value in nodeList){
       var vType = value.value.valueType;
        if(vType == ValueType.array){
          yamlObject += _generateYamlArray(value);
        }
        else if(vType == ValueType.object){
           yamlObject += _generateYamlObject(value);
        }
        else if(vType == ValueType.nil){
          yamlObject += _generateObjectKey(value);
        }
        else
        {
           yamlObject += _generateYamlConst(value);
        }
     }
     return yamlObject;
  }

  String _generateYamlArray(Node node){
     var yamlArray = '';
     yamlArray += _addScopeToCode('${node.key.name}:\n', node.scope);
     List nodeList = node.value.val;
     for(Node value in nodeList){
        var vType = value.value.valueType;
        if(vType == ValueType.arrayStr){
           yamlArray += _generateArrayString(value);
        }
        else if(vType == ValueType.arrayKvObj){
           yamlArray += _generateArrayKeyValue(value);
        }
        else if(vType == ValueType.arrayObj){
           yamlArray += _generateYamlObject(value);
        }
        else if(vType == ValueType.arrayArr){
           yamlArray += _generateYamlArray(value);
        }
        else if(vType == ValueType.nil){
           yamlArray += _generateArrayKey(value);
        }
     }
     return yamlArray;
  }

  String _generateObjectKey(Node node){
    return _addScopeToCode('${node.value.val}\n', node.scope);
  }

  String _generateArrayKey(Node node){
    return _addScopeToCode('- ${node.value.val}\n', node.scope);
  }

  String _generateArrayKeyValue(Node node){
    Node valueNode = node.value.getValue();
    return _addScopeToCode('- ${valueNode.key.name}: ${valueNode.value.getValue()}\n', node.scope);
  }

  String _generateArrayString(Node node){
    return _addScopeToCode('- ${node.value.val}\n', node.scope);
  }

  String _generateYamlConst(Node node){
     return _addScopeToCode('${node.key.name}: ${node.value.getValue()}\n', node.scope);
  }

  String _addScopeToCode(String code, int scope){
    return code.padLeft(code.length + scope);
  }
}
