import 'dart:io';

/**
 * Read the yaml file and return result as list of string lines
 */
List<String> readFileLines(String path){
  return File(path).readAsLinesSync();
}

/**
 * Write string content in yaml file
 */
void writeFileContent(String path, String content){
  File(path).openWrite().write(content);
}
