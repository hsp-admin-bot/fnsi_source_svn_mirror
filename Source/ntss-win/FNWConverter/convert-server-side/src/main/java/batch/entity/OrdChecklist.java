package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * チェックリスト実績情報クラス
 */
@Table(name = "ord_checklist")
@Getter
@Setter
public class OrdChecklist extends BaseEntity {
  /**
   * チェックリスト管理番号
   */
  @Id
  private Long checklistCtlNo;
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;
  /**
   * 実施状態
   */
  private String isCheck;
  /**
   * 実績区分
   */
  private Short rstClass;
  /**
   * リストコード
   */
  private Short listCd;
  /**
   * 機能フラグ
   */
  private Short funcClass;
  /**
   * チェックリスト情報
   */
  private JSONObject rstChecklistInfo;
  /**
   * 実施者情報
   */
  private JSONObject regStaffInfo;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 発生日時
   */
  private Timestamp occurDate;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 施設コード
   */
  private String facilityCd;


  /**
   * csvを変換し、csvを書き込むためのtoStringメソッドの書き換え
   *
   * @return
   */
  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(regDate==null ? "" : regDate).append(",")
            .append(facilityCd==null ? "" : facilityCd).append(",")
            .append(ordNo==null ? "" : ordNo).append(",")
            .append(listCd==null ? "" : listCd).append(",")
            .append(occurDate==null ? "" : occurDate).append(",")
            .append(upDate==null ? "" : upDate).append(",")
            .append(isCheck==null ? "" : isCheck).append(",")
            .append(funcClass==null ? "" : funcClass).append(",")
            .append(rstClass==null ? "" : rstClass).append(",")
            .append(rstChecklistInfo==null ? "" : rstChecklistInfo.toString().replace(",", "|")).append(",")
            .append(regStaffInfo==null ? "" : regStaffInfo.toString().replace(",", "|"));
    return sb.toString();
  }
}
