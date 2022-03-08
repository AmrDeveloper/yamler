import 'package:test/test.dart';
import 'package:yamler/yamler.dart';

void main() {
    group("modify", () {
        test('Replace object->key->value to object->key->HelloWorld', () {
            final input = '''
json:
  - rigid
  - better for data interchange
yaml:
  - slim and flexible
  - better for configuration
object:
  key: value
  array:
    - boolean: true
    - integer: 1
            ''';
            var yamlTokenizer = Tokenizer();
            var yamlWriter = YamlGenerator();
            var yamlParser = YamlParser(yamlTokenizer);
            var yamlAST = yamlParser.parseYamlCode(input, false);
            List objectValList = yamlAST.getNodeValue('object').value.getValue();
            objectValList[0].value.setValue('HelloWorld');
            var outputYaml = yamlWriter.generateYamlString(yamlAST);
            final output = '''
json:
  - rigid
  - better for data interchange
yaml:
  - slim and flexible
  - better for configuration
object:
  key: HelloWorld
  array:
    - boolean: true
    - integer: 1
''';
            expect(output, outputYaml);
        });
    });
}