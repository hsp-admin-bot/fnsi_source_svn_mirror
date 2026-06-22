package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import org.springframework.beans.BeanUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serial;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * 計算材料保持テーブルクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_material_save")
@Getter
@Setter
public class OrdMaterialSave extends BaseBlankEntity implements Serializable {
  @Serial
  private static final long serialVersionUID = -844028651342882094L;
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "ntss.ord_material_save_seq")
  /**
   * 管理番号
   */
  private Long ordMaterialSaveNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * データ基準日
   */
  private String suppliesBaseDate;

  /**
   * データ基準番号
   */
  private Long suppliesBaseNo;

  /**
   * データ発生元区分
   */
  private String suppliesSourceClass;

  /**
   * 物品区分
   */
  private String suppliesClass;

  /**
   * 物品コード
   */
  private String suppliesCd;

  /**
   * 調整薬剤コード
   */
  private String medicineMixCd;

  /**
   * 分類コード
   */
  private String classCd;

  /**
   * 指示・実績区分
   */
  private String indRstClass;

  /**
   * 指示・実績値
   */
  private String indRstValue;

  /**
   * レセ値
   */
  private String receiptValue;

  /**
   * 確定フラグ
   */
  private String isConfirm;

  // add 11613 by shiyw 20250303 start
  /**
   * 投与済みフラグ：１済み、0未投与
   */
  private String effectFlg;
  // add 11613 by shiyw 20250303 end

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
  // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
  /**
   * 薬剤識別番号
   */
  private String medicineNo;
  /**
   * 手技コード
   */
  private String procedureCd;
  /**
   * 投与タイミングコード
   */
  private String timingCd;

  /**
   * レセ换算
   */
  private String receiptConversion;

  /* ================== 2024/06/11 処方情報対応追加 Start ================== */
  /** 処方薬剤単位 */
  private String prescriptionUnit;

  /** 処方調剤単位 */
  private String frequencyFlg;

  /** 処方調剤量 */
  private String frequencyNum;
  /* ================== 2024/06/11 処方情報対応追加 END ================== */

  // add 11491 by kangjie 20250208 start
  // レセ単位
  private String receiptUnit;
  private String indUnit;
  // add 11491 by kangjie 20250208 end

  public OrdMaterialSave() {
  }

  public OrdMaterialSave(String suppliesClass, String suppliesCd, String indRstClass
    , String classCd, String indRstValue, String receiptValue) {
    this.suppliesClass = suppliesClass;
    this.suppliesCd = suppliesCd;
    this.classCd = classCd;
    this.indRstValue = indRstValue;
    this.receiptValue = receiptValue;
    this.indRstClass = indRstClass;
  }

  /**
   * deepCopy this DTO
   *
   * @param source
   * @return
   */
  public static OrdMaterialSave deepCopy(OrdMaterialSave source) {
    if (source != null) {

      OrdMaterialSave dest = new OrdMaterialSave();

      ObjectOutputStream obs = null;
      ObjectInputStream os = null;
      try {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        obs = new ObjectOutputStream(out);
        obs.writeObject(source);

        ByteArrayInputStream is = new ByteArrayInputStream(out.toByteArray());
        os = new ObjectInputStream(is);
        OrdMaterialSave s = (OrdMaterialSave) os.readObject();
        BeanUtils.copyProperties(s, dest);

        return dest;
      } catch (IOException | ClassNotFoundException e) {
        throw new RuntimeException(e);
      } finally {
        try {
          if (obs != null) obs.close();
          if (os != null) os.close();
        } catch (IOException e) {
          throw new RuntimeException(e);
        }

      }
    }

    return null;
  }
  // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
}
