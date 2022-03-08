import 'utils.dart';

class Tokenizer{

  int _currentIndex;
  List<String> _codeLines;

  Tokenizer();

  void loadYamlCode(String path){
    _codeLines = readFileLines(path);
    _currentIndex = -1;
  }

  void loadYamlContent(String path) {
    _codeLines = path.split('\n');
    _currentIndex = -1;
  }

  String getCurrentLine(){
    return _codeLines[_currentIndex];
  }

  String getNextLine(){
    if(_currentIndex > _codeLines.length){
      return '';
    }
    return _codeLines[_currentIndex + 1];
  }

  String getPrevLine(){
    if(_currentIndex - 1 < 0){
      return '';
    }
    return _codeLines[_currentIndex - 1];
  }

  String pointNextLine(){
    if(_currentIndex > _codeLines.length){
      return '';
    }
    _currentIndex = _currentIndex + 1;
    return _codeLines[_currentIndex];
  }

  String pointPrevLine(){
    if(_currentIndex - 1 < 0){
      return '';
    }
    _currentIndex = _currentIndex - 1;
    return _codeLines[_currentIndex];
  }

  bool hasNextLine(){
    return _currentIndex < _codeLines.length - 1;
  }

  bool isLastLine(){
    return _currentIndex == _codeLines.length - 1;
  }

  void setCurrentIndex(int index){
    _currentIndex = index;
  }

  int getCurrentIndex(){
    return _currentIndex;
  }
}