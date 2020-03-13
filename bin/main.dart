import 'parser.dart';
import 'tokenizer.dart';
import 'generator.dart';
import 'tokens.dart';
import 'utils.dart';

void main(List<String> arguments) {
  var inputPath = 'example\\input1.yaml';
  var outputPath = 'example\\output1.yaml';

  var yamlTokenizer = Tokenizer();
  var yamlWriter = YamlGenerator();
  var yamlParser = YamlParser(yamlTokenizer);

  var yamlAST = yamlParser.parseYamlCode(inputPath);

  //Change nested Object Value
  List objectValList = yamlAST.getNodeValue('object').value.getValue();
  Node node = objectValList[0];
  node.value.setValue('HelloWorld');

  var outputYaml = yamlWriter.generateYamlString(yamlAST);
  writeFileContent(outputPath, outputYaml);
}
