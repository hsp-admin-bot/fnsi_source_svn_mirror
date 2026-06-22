package jp.co.nikkiso.ntss.core.entity;
//add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FuncList {

  private Integer class_cd;

  private String list_name;

  private Short func_class;

  private Short item_number;

  @Override
  public String toString() {
    return "FuncList{" +
      "class_cd=" + class_cd +
      ", list_name='" + list_name + '\'' +
      ", func_class=" + func_class +
      ", item_number=" + item_number +
      '}';
  }

  public String makeJsonStr(){
    StringBuffer sb = new StringBuffer();
    sb.append("{").append("\"").append("class_cd\":").append(class_cd).append(",")
      .append("\"").append("list_name\":").append("\"").append(list_name).append("\"").append(",")
      .append("\"").append("func_class\":").append(func_class).append(",")
      .append("\"").append("item_number\":").append(item_number).append(",")
      .append("}");
    return sb.toString();
  }

}
//add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end
