package jp.co.nikkiso.ntss.core.entity;
//add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChecklistSettings {

  private short list_cd;

  private String funclist;

  private String list_name;

  private Integer operation;

  private short dialysis_prog_cd;

  private String dialysis_prog_name;


  @Override
  public String toString() {
    return "ChecklistSettings{" +
      "list_cd=" + list_cd +
      ", funclist=" + funclist +
      ", list_name='" + list_name + '\'' +
      ", operation=" + operation +
      ", dialysis_prog_cd=" + dialysis_prog_cd +
      ", dialysis_prog_name='" + dialysis_prog_name + '\'' +
      '}';
  }

  public String makeJsonStr(){
    StringBuffer sb = new StringBuffer();
    sb.append("{").append("\"").append("list_cd\":").append(list_cd).append(",")
      .append("\"").append("funclist\":").append(funclist).append(",")
      .append("\"").append("list_name\":").append("\"").append(list_name).append("\"").append(",")
      .append("\"").append("operation\":").append(operation).append(",")
      .append("\"").append("dialysis_prog_cd\":").append(dialysis_prog_cd).append(",")
      .append("\"").append("dialysis_prog_name\":").append("\"").append(dialysis_prog_name).append("\"").append("}");
    return sb.toString();
  }

}
// add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end
