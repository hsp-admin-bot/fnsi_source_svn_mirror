package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;
/**
 *分類不一致判断
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstEquipmentMstMedicine {
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  private int code;
  //add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
  /**
   * 分類名称
   */
  private String className;
  /**
   * 分類区分
   */
  private int classType;
  /**
   * 薬剤名
   */
  private String medicineName;
  /**
   * 医療材料名
   */
  private String equipmentName;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 表示フラグMix
   */
  private String isDispMix;
  /**
   * 削除フラグMix
   */
  private String isDelMix;
  /**
   * 使用終了日
   */
  private String useEndDate;

}
