import 'dart:collection';
import 'dart:io';

import 'tokenizer.dart';
import 'tokens.dart';

class YamlParser {

  final Tokenizer _tokenizer;

  final singleKey = RegExp(r'[ ]{0,}[a-zA-Z0-9]+[ ]{0,}:$');
  final singleKV = RegExp(r'[ ]{0,}[a-zA-Z0-9]+[ ]{0,}[:][ ]{0,}[a-zA-Z0-9]+');
  final arrayKvObject = RegExp(r'[ ]{1,}[-][ ]{0,}[a-zA-Z0-9]+[ ]{0,}[:][ ]{0,}[a-zA-Z0-9\b\s]+$');
  final arrayString = RegExp(r'[ ]{1,}[-][ ]{0,}[a-zA-Z0-9\b\s]+[ ]{0,}[ ]{0,}$');

  var _commentCounter = 0;
  var _lineCounter = 0;

  YamlParser(this._tokenizer);

  Yaml parseYamlCode(String path) {
    _initTokenizer(path);

    LinkedHashMap<String, Node> nodesMap = LinkedHashMap();

    while(_tokenizer.hasNextLine()){
       var line = _tokenizer.pointNextLine();

       if(line.isEmpty){
         var key = 'line_${_lineCounter++}';
         nodesMap[key] = Node(Key(key), Value('\n', ValueType.line), 0);
         continue;
       }
       if(_isComment(line)){
         var key = 'comment_${_commentCounter++}';
         nodesMap[key] = Node(Key(key), Value(line, ValueType.comment), 0);
         continue;
       }

       if(_isSingleKey(line))
       {
         if(_tokenizer.isLastLine())
         {
             var node = _parseSingleKeyNode(line);
             var keyName = node.key.name;
             nodesMap[keyName] = node;
         }
         else
         {
            var currentLineScope = _getLineScope(line);
            var currentIndex = _tokenizer.getCurrentIndex();
            while(_isComment(_tokenizer.getNextLine())){}
            var nextLineScope = _getLineScope(_tokenizer.getNextLine());
            _tokenizer.setCurrentIndex(currentIndex);

            if(currentLineScope >= nextLineScope)
            {
               var node = _parseSingleKeyNode(line);
               var keyName = node.key.name;
               nodesMap[keyName] = node;
            }
            else
            {
              while(_isComment(_tokenizer.pointNextLine()) || _tokenizer.getCurrentLine().isEmpty){}
              var nextLine = _tokenizer.getCurrentLine();

              var key = _parseSingleKey(line);

              if(_isArrayObject(nextLine))
              {
                var arrayNode = _parseArrayNode(line);
                nodesMap[key.name] = arrayNode;
              }
              else
              {
                var objectNode = _parseObjectNode(line);
                nodesMap[key.name] = objectNode;
              }
            }
         }
       }
       else if(_isSingleKeyValue(line))
       {
          var node = _parseKeyValNode(line);
          var keyName = node.key.name;
          nodesMap[keyName] = node;
       }
       else
       {
          print('invalid token : ${line}');
          exit(1);
       }
    }

    return Yaml(nodesMap);
  }

  void _initTokenizer(String path) {
    _tokenizer.loadYamlCode(path);
    _commentCounter = 0;
    _lineCounter = 0;
  }

  //FIXME: can replace string line with _tokenizer.getPrevLine();
  Node _parseArrayNode(String line) {
    var nextLine = _tokenizer.getCurrentLine();

    var arrayLength = 0;

    var keyObj = _parseSingleKey(line);
    var keyScope = _getLineScope(line);

    var nodeList = List();

    while (_isArrayObject(nextLine)) {
      var scope = _getLineScope(nextLine);

      var arrayItemType = _getArrayValueType(nextLine);

      Value value;

      if (arrayItemType == ValueType.arrayStr) {
        value = _getArrayStrValue(nextLine);
      } else if (arrayItemType == ValueType.arrayKvObj) {
        value = _getArrayKeyValueObjectValue(nextLine);
      } else if (arrayItemType == ValueType.arrayArr) {
         return _parseArrayNode(nextLine);
      } else if (arrayItemType == ValueType.arrayObj) {
         return _parseObjectNode(nextLine);
      } else if(arrayItemType == ValueType.nil){
        return _parseSingleKeyNode(nextLine);
      }
      else {
        print('Invalid Array Value Type -> ${nextLine} \t type : ${arrayItemType}');
      }

      var arrayIndex = '${keyObj.name}_${arrayLength++}';

      var node = Node(Key(arrayIndex), value, scope);
      nodeList.add(node);

      if (_tokenizer.hasNextLine()) {
        nextLine = _tokenizer.pointNextLine();
      } else {
        break;
      }
    }

    if (_tokenizer.hasNextLine()) {
      _tokenizer.pointPrevLine();
    }

    var arrayValue = Value(nodeList, ValueType.array);
    return Node(keyObj, arrayValue, keyScope);
  }

  //FIXME: can replace string line with _tokenizer.getPrevLine();
  Node _parseObjectNode(String line) {
    var nextLine = _tokenizer.getCurrentLine();

    var keyObj = _parseSingleKey(line);
    var keyScope = _getLineScope(line);

    var nodeList = List();

    var nextLineScope = _getLineScope(nextLine);

    while (nextLineScope > keyScope) {
      if (_isSingleKeyValue(nextLine)) {
        nodeList.add(_parseKeyValNode(nextLine));
      } else if (_isSingleKey(nextLine)) {
        if (_tokenizer.isLastLine()) {
          nodeList.add(_parseSingleKeyNode(line));
        } else {
          var currentLineScope = _getLineScope(line);
          var currentIndex = _tokenizer.getCurrentIndex();
          while (_isComment(_tokenizer.getNextLine())) {}
          var nextLineScope = _getLineScope(_tokenizer.getNextLine());
          _tokenizer.setCurrentIndex(currentIndex);

          if (currentLineScope >= nextLineScope) {
            nodeList.add(_parseSingleKeyNode(line));
          } else {
            while (_isComment(_tokenizer.pointNextLine()) ||
                _tokenizer.getCurrentLine().isEmpty) {}
            var nextLine = _tokenizer.getCurrentLine();
            var key = _tokenizer.getPrevLine();
            if (_isArrayObject(nextLine)) {
              nodeList.add(_parseArrayNode(key));
            } else {
              nodeList.add(_parseObjectNode(key));
            }
          }
        }
      } else {
        print('Invalid Object Value Type -> ${nextLine}');
      }

      if (_tokenizer.hasNextLine()) {
        nextLine = _tokenizer.pointNextLine();
        nextLineScope = _getLineScope(nextLine);
      } else {
        break;
      }
    }

    if (_tokenizer.hasNextLine()) {
      _tokenizer.pointPrevLine();
    }

    var objectValue = Value(nodeList, ValueType.object);
    return Node(keyObj, objectValue, keyScope);
  }

  Node _parseKeyValNode(String line){
    var args = line.split(':');

    var key = args[0].trim();
    var keyObj = Key(key);

    var value = args.sublist(1, args.length).join().trim();
    var valueType = _getValueType(value);
    var valueObj = Value(value, valueType);

    var scope = _getLineScope(line);

    return Node(keyObj, valueObj, scope);
  }

  Node _parseSingleKeyNode(String line){
    var keyObj = _parseSingleKey(line);

    var valueObj = Value(null, ValueType.nil);
    var scope = _getLineScope(line);

    return Node(keyObj, valueObj, scope);
  }

  Key _parseSingleKey(String line){
    var args = line.split(':');
    var key = args[0].trim();
    return Key(key);
  }

  ValueType _getValueType(String value){
    if(_isNumeric(value)) {
      return ValueType.integer;
    } else if(_isBoolean(value)) {
      return ValueType.boolean;
    } else if(_isArrayObject(value)){
      return ValueType.arrayObj;
    }
    return ValueType.string;
  }

  ValueType _getArrayValueType(String line){
     if(_isArrayStringValue(line))
     {
       return ValueType.arrayStr;
     }
     else if(_isArraySingleKeyValue(line))
     {
       return ValueType.arrayKvObj;
     }
     return ValueType.nil;
  }

  Value _getArrayStrValue(String line){
     line = line.replaceFirst('-', '');
     line = line.trim();
     return Value(line, ValueType.arrayStr);
  }

  Value _getArrayKeyValueObjectValue(String line){
      line = line.replaceFirst('-', '');
      line = line.trim();

      var node = _parseKeyValNode(line);

      return Value(node, ValueType.arrayKvObj);
  }

  bool _isComment(String s){
     return s.startsWith('#');
  }

  bool _isBoolean(String s) {
    return s == 'true' || s == 'false';
  }

  bool _isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool _isArrayObject(String s) {
    return s.trim().startsWith('-');
  }

  bool _isSingleKey(String s) {
    return singleKey.hasMatch(s);
  }

  bool _isSingleKeyValue(String s) {
    return singleKV.hasMatch(s);
  }

  bool _isArrayStringValue(String s){
    return arrayString.hasMatch(s);
  }

  bool _isArraySingleKeyValue(String s){
    return arrayKvObject.hasMatch(s);
  }

  int _getLineScope(String line){
    return line.length - line.trimLeft().length;
  }
}