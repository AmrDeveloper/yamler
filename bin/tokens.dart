import 'dart:collection';

class Token {
  final TokenType tokenType;

  Token(this.tokenType);
}

enum TokenType { key, value }

enum ValueType {
  nil,
  line,
  comment,
  integer,
  string,
  boolean,
  array,
  object,
  arrayStr,
  arrayObj,
  arrayKvObj,
  arrayArr
}

class Key extends Token {
  final String name;

  Key(this.name) : super(TokenType.key);

  @override
  String toString() => name;
}

class Value<T> extends Token {
  T val;
  ValueType valueType;

  Value(this.val, this.valueType) : super(TokenType.value);

  void setValue(T nVal){
    val = nVal;
  }

  T getValue(){
     return val;
  }

  @override
  String toString() => 'type: ${valueType.toString()}\t value: ${val}';
}

class Node {
  final Key key;
  Value value;
  final int scope;

  Node(this.key, this.value, this.scope);

  @override
  String toString() => 'key : ${key}\t val type : ${value}\t scope: ${scope}\n';
}

class Yaml {
  final LinkedHashMap<String, Node> _nodesList;

  Yaml(this._nodesList);

  LinkedHashMap<String, Node> getNodes(){
    return _nodesList;
  }

  void setNodeValue(String key, Node node) {
    _nodesList[key] = node;
  }

  Node getNodeValue(String key) {
    return _nodesList[key];
  }

  void setStringValue(String key, String value) {
    if (_nodesList.containsKey(key)) {
      var node = _nodesList[key];
      node.value = Value(value, ValueType.string);
      _nodesList[key] = node;
      return;
    }
    var valueObj = Value(value, ValueType.string);
    var nodeObj = Node(Key(key), valueObj, 0);
    _nodesList[key] = nodeObj;
  }

  @override
  String toString() => _nodesList.toString();
}
