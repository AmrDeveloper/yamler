import 'package:test/test.dart';
import 'package:yamler/yamler.dart';

void main() {
  group("modify", () {
    test('Change comment message value', () {
      final input = '''
json:
  - rigid
  - better for data interchange
# Comment number 1
''';
      var yamlTokenizer = Tokenizer();
      var yamlWriter = YamlGenerator();
      var yamlParser = YamlParser(yamlTokenizer);
      var yamlAST = yamlParser.parseYamlCode(input, false);
      var commentNode = yamlAST.getNodeValue("comment_0");
      commentNode.value.setValue("# Comment number 2");
      var outputYaml = yamlWriter.generateYamlString(yamlAST);
      final output = '''
json:
  - rigid
  - better for data interchange
# Comment number 2
''';
      expect(output, outputYaml);
    });
  });
}