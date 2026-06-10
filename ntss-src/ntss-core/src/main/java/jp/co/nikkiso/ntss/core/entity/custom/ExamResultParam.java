package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import lombok.Data;

import java.sql.Timestamp;
import java.util.List;

/**
 * 患者情報クラス
 */
@Data
public class ExamResultParam {

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 検査結果ID
   */
  private Long examMainCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 登録時検査日時(String)
   */
  private String targetDt;

  // add #8782 検査計算項目が計算されない ztc 20230607 start
  /**
   * 登録時検査日時(String)
   */
  private Timestamp targetDtTime;
  // add #8782 検査計算項目が計算されない ztc 20230607 end

  /**
   * システム標準計算検査項目
   */
  private String examResultCalcColumnVal;

  /**
   * 透析前後(1:透析前、2:透析後、0:その他)
   */
  private String orderClass;

  /**
   * 登録時検査日時.
   */
  private Timestamp regExamDate;

  /**
   * 登録時検査区分.
   */
  private String regOrderClass;

  /**
   * 性別
   */
  private Integer sex;

  /**
   * 更新日時
   */
  private String strUpDt;

  /**
   * 性別
   */
  private String unKnownSexVal;

  /**
   * システム標準計算ID
   */
  private String systemDefaultCalcFormulaId;

  /**
   * 検査結果コード
   */
  private String examItemCd;

  /**
   * 補正化Ca項目コード
   */
  private String corCaItemCd;

  /**
   * 検査項目マスタList('0'：検査項目)
   */
  private List<MstExamItem> mstExamItems;

  /**
   * 検査項目マスタList('1'：システム標準計算項目)
   */
  private List<MstExamItem> mstExamItemsSys;

  /**
   * 患者検査結果List
   */
  private List<PatExamMain> patExamMains;

}
