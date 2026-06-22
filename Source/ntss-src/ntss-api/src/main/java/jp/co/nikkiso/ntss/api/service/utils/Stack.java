// add 2020-09-16 FNSI-仕様追加 フリー計算機能 夏 start
package jp.co.nikkiso.ntss.api.service.utils;
import java.util.ArrayList;

public class Stack {
  private ArrayList<String> stack = new ArrayList<>();

  public boolean isEmpty(){
    return stack.size() == 0;
  }
  public int getSize(){
    return stack.size();
  }
  public String peek(){
    if(!isEmpty()) {
      return stack.get(stack.size() -1 );
    }
    else {
      return "false";
    }
  }
  public String pop(){
    if(!isEmpty()){
      String top = stack.get(stack.size() - 1);
      stack.remove(stack.size() - 1);
      return top;
    }
    else{
      return "false";
    }
  }
  public void push(String o){
    stack.add(o);
  }
  @Override
  public String toString(){
    return "Stack:" + stack.toString();
  }
}
// add 2020-09-16 FNSI-仕様追加 フリー計算機能 夏 end
