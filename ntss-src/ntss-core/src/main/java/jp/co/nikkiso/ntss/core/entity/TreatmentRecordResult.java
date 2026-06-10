package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.ZoneId;
import java.util.TimeZone;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import lombok.EqualsAndHashCode;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 治療情報のEntity（治療記録用）.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_main")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class TreatmentRecordResult extends BaseEntity {

  /**
   * ユーザ情報（穿刺者情報/返血者情報/担当者情報）.
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  @EqualsAndHashCode
  public static class RstUserInfo {

    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 担当者コード1.
     */
    @JsonProperty("user_id_1")
    private Long userId1;

    /**
     * 担当者名_姓1
     */
    @JsonProperty("user_last_name_1")
    private String userLastName1;

    /**
     * 担当者名_名1
     */
    @JsonProperty("user_first_name_1")
    private String userFirstName1;

    /**
     * 担当者コード2
     */
    @JsonProperty("user_id_2")
    private Long userId2;

    /**
     * 担当者名_姓2
     */
    @JsonProperty("user_last_name_2")
    private String userLastName2;

    /**
     * 担当者名_名2
     */
    @JsonProperty("user_first_name_2")
    private String userFirstName2;

    /**
     * 日時.
     */
    @JsonProperty("date")
    // del #11352 by kangjie 20241211 start 時間はページ処理が完了したら、直接DBに格納する
//    @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
    // del #11352 by kangjie 20241211 end
    @JsonInclude(Include.NON_NULL)
    // modify #11352 by kangjie 20241211 start 時間はページ処理が完了したら、直接DBに格納する
//    private Timestamp date;
    private String date;
    // modify #11352 by kangjie 20241211 end

    /**
     * 担当者１登録日時.
     */
    @JsonProperty("date_1")
    @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
    private Timestamp date1;


    /**
     * 担当者２登録日時.
     */
    @JsonProperty("date_2")
    @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
    private Timestamp date2;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public RstUserInfo(String value) {
      try {
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.setTimeZone(TimeZone.getTimeZone(ZoneId.systemDefault()));
        TreatmentRecordResult.RstUserInfo obj = objectMapper.readValue(value, TreatmentRecordResult.RstUserInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
      }
    }

    /**
     * 基本型の値を返す.
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * システムで管理する一意なオーダ番号.
   */
  @Id
  @JsonIgnore
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID.
   */
  @JsonIgnore
  private Long patId;

  /**
   * FNW+で管理する施設内の一意な患者ID.
   */
  @JsonIgnore
  private String fnPatId;

  /**
   * 治療日.
   */
  private String treatDate;

  /**
   * 治療曜日.
   */
  @JsonIgnore
  private Short treatWeek;

  /**
   * 施設コード.
   */
  @JsonIgnore
  private String facilityCd;

  /**
   * 施設名.
   */
  @JsonIgnore
  private String facilityName;

  /**
   * 実績：治療状況.
   */
  private String rstDialysisState;

  /**
   * 実績：クールコード.
   */
  private Long rstKurCd;

  /**
   * 実績：クール名.
   */
  private String rstKurName;

  /**
   * 実績：ベッドコード.
   */
  private Long rstBedCd;

  /**
   * 実績：ベッド名.
   */
  private String rstBedName;

  /**
   * 実績：治療開始日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstStartDate;

  /**
   * 実績：治療終了日時.
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstEndDate;

  /**
   * 実績：入外区分.
   */
  private Short rstInOutClass;

  /**
   * 実績：透析回数.
   */
  private Integer rstDialysisCnt;

  /**
   * 実績：病棟コード.
   */
  private Integer rstWardCd;

  /**
   * 実績：病棟名.
   */
  private String rstWardName;

  /**
   * 実績：診療科コード.
   */
  private Integer rstCourseCd;

  /**
   * 実績：診療科名.
   */
  private String rstCourseName;

  /**
   * 実績：穿刺者情報.
   */
  private RstUserInfo rstPunctureUserInfo;
  /**
   * 実績：返血者情報.
   */
  private RstUserInfo rstReturnUserInfo;
  /**
   * 実績：担当者情報.
   */
  private RstUserInfo rstChargeUserInfo;

  // TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可
  @Override
  @JsonIgnore
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  @Override
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  public void setUpDate(Timestamp value) {
    super.setUpDate(value);
  }

  /**
   * 確定フラグ
   */
  private String isConfirm;

  /**
   * 実績：治療方法コード.
   */
  @NotNull
  private Integer rstTreatmentCd;

  /**
   * 実績：治療方法名.
   */
  @NotBlank
  private String rstTreatmentName;

  /**
   * 実績：特殊浄化回数.
   */
  private Integer rstPurificationCnt;

  //add FNSI修正 No.305 start
  /**
   * 実績：登録区分
   */
  private Integer rstInputClass;
  //add FNSI修正 No.305 end

  // add FNSI-redmine6122 fang start
  private Long upUserId;
  // add FNSI-redmine6122 fang end
  //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
  private int graphTimeScale ;
  //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end

  /**
   * 実績：初版確定日時
   */
  @JsonFormat(pattern = CoreConstant.DateTimeFormat.ZONED_DATE_TIME_ISO8601, timezone = CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO)
  private Timestamp rstEditionDate;

  /**
   * 実績：治療条件情報
   */
  private String rstCondInfo;

  /* add by chamaojia 2025-03-23 [11471] attribute addition --start */
  /**
   * 実績：装置モード
   */
  private Integer rstDeviceMode;
  /* add by chamaojia 2025-03-23 [11471] attribute addition --end */
}
