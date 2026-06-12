package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * チェックリスト実績情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_checklist")
@Getter
@Setter
public class OrdChecklist extends BaseEntity  implements Cloneable{
  /**
   * チェックリスト管理番号
   */
  @Id
  //mod FNSI修正 401対応 房 start
//  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "ord_checklist_checklist_ctl_no_seq")
  //mod FNSI修正 401対応 房 end
  //データ更新
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
  private OrdChecklistRegCheckInfo rstChecklistInfo;

  /**
   * 実施者情報
   */
  private OrdChecklistRegStaffInfo regStaffInfo;

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
   * 施設コード
   */
  private String facilityCd;

  /**
   * チェックリスト実績情報のチェックリスト情報クラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegCheckInfo  implements Cloneable{
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * チェックリストマスタ.チェックリストコード
     */
    @JsonProperty("checklist_cd")
    private Long checklistCd;

    /**
     * チェックリストマスタ.チェックリスト設定.機能リスト.項目番号
     */
    @JsonProperty("item_number")
    private Short itemNumber;

    /**
     * チェックリストマスタ.チェックリスト設定.機能リスト.分類コード
     */
    @JsonProperty("class_cd")
    private Integer classCd;

    /**
     * 医療材料マスタ.医療材料コード
     */
    @JsonProperty("code")
    private Integer code;

    /**
     * 医療材料マスタ.医療材料コード更新日時
     */
    @JsonProperty("code_update")
    private String codeUpdate;

    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
    /**
     * 治療情報.指示：投与薬剤情報.薬剤区分(1: 通常薬剤、2: 調製薬剤「投与薬剤、調製薬剤の場合」)
     */
    @JsonProperty("medicine_type")
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //private Short medicineType;
    private Integer medicineType;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

    /**
     * 項目名称
     */
    @JsonProperty("name")
    private String name;
// del 10310 needle _ typeの使用を削除するには gjn start
    /**
     * 穿刺針区分(0: 未指定、1: A針、2: V針、3: SN)
     */
//    @JsonProperty("needle_type")
//    private Short needleType;
// del 10310 needle _ typeの使用を削除するには gjn end
    /**
     * 数量
     */
    @JsonProperty("amount")
    private String amount;

    /**
     * 単位
     */
    @JsonProperty("unit")
    private String unit;

// add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    /**
     * 医療材料区分
     */
    @JsonProperty("equip_type")
    private Integer equipType;

    /**
     * 薬剤識別番号
     */
    @JsonProperty("medicine_no")
    private String medicineNo;
    // add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end


    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public OrdChecklistRegCheckInfo(String value) {
      try {
        OrdChecklistRegCheckInfo obj = objectMapper.readValue(value, OrdChecklistRegCheckInfo.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (logServiceCore != null) {
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
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
      } catch (JacksonException e) {
        return null;
      }
    }

    @Override
    public OrdChecklistRegCheckInfo clone() { //基本的にはpublic修飾子を付け、自分自身の型を返り値とする
      OrdChecklistRegCheckInfo b=null;

        /*ObjectクラスのcloneメソッドはCloneNotSupportedExceptionを投げる可能性があるので、try-catch文で記述(呼び出し元に投げても良い)*/
        try {
            b=(OrdChecklistRegCheckInfo)super.clone(); //親クラスのcloneメソッドを呼び出す(親クラスの型で返ってくるので、自分自身の型でのキャストを忘れないようにする)
        }catch (Exception e){
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
          LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (logServiceCore != null) {
            logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
        }
        return b;
    }

  }

  /**
   * チェックリスト実績情報の実施者情報クラス
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegStaffInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 実施者スタッフコード
     */
    @JsonProperty("reg_staff_cd")
    private Long regStaffCd;

    // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
    /**
     * 実施者スタッフ名
     */
    @JsonProperty("reg_staff_name")
    private String regStaffName;
    // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end

    /**
     * 実施者更新日時
     */
    @JsonProperty("reg_staff_update")
    private String regStaffUpdate;

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public OrdChecklistRegStaffInfo(String value) {
      try {
        OrdChecklistRegStaffInfo obj = objectMapper.readValue(value, OrdChecklistRegStaffInfo.class);
        modelMapper.map(obj, this);
      } catch (JacksonException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (logServiceCore != null) {
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
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
      } catch (JacksonException e) {
        return null;
      }
    }
  }


  @Override
  public OrdChecklist clone() { //基本的にはpublic修飾子を付け、自分自身の型を返り値とする
    OrdChecklist b=null;

      /*ObjectクラスのcloneメソッドはCloneNotSupportedExceptionを投げる可能性があるので、try-catch文で記述(呼び出し元に投げても良い)*/
      try {
          b=(OrdChecklist)super.clone(); //親クラスのcloneメソッドを呼び出す(親クラスの型で返ってくるので、自分自身の型でのキャストを忘れないようにする)
      }catch (Exception e){
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
        LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (logServiceCore != null) {
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      }
      return b;
  }

}
