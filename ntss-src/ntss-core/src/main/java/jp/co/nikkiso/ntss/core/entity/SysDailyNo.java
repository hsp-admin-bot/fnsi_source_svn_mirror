package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 受付番号採番情報Entity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_daily_no")
@Getter
@Setter
public class SysDailyNo extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 採番種別 */
  private String numberingCd;

  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
  /** 採番値 */
  private Integer currentNo;

  /** 基準日 */
  private String baseDate;
  //add #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
//  /** 採番値 */
//  private CurrentNo currentNo;
//
//  /**
//   * 現在の採番値
//   *
//   */
//  @Domain(valueType = String.class)
//  @Setter
//  @Getter
//  @NoArgsConstructor
//  public static class CurrentNo {
//    /** ObjectMapper */
//    private static ObjectMapper objectMapper = new ObjectMapper();
//    /** ModelMapper */
//    private static ModelMapper modelMapper = new ModelMapper();
//
//    @JsonProperty("current_no")
//    private List<InnerCurrentNo> currentNo ;
//
//    /**
//     * コンストラクタ.
//     * @param value JSON文字列
//     */
//    public CurrentNo(String value) {
//      try {
//        CurrentNo obj = objectMapper.readValue(value, CurrentNo.class);
//        modelMapper.map(obj, this);
//      } catch (IOException e) {
//        throw new NtssException("現在の採番値の設定が不正です");
//      }
//    }
//
//    /**
//     * 基本型の値を返す.
//     * @return 基本型の値
//     */
//    @JsonIgnore
//    public String getValue() {
//      try {
//        return objectMapper.writeValueAsString(this);
//      } catch (JacksonException e) {
//        return null;
//      }
//    }
//  }
//
//  /**
//   * 採番値（１日分）を表すクラス
//   */
//  @Setter
//  @Getter
//  public static class InnerCurrentNo {
//      /** 日付 */
//      @JsonProperty("date")
//      private String date;
//      /** 採番番号 */
//      @JsonProperty("current_no")
//      private String currentNo;
//      /** 更新日付 */
//      @JsonProperty("up_date")
//      private String upDate;
//  }
  //del #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end

  /** 表示フラグ */
  private String isDisp;

  /** 削除フラグ */
  private String isDel;

}
