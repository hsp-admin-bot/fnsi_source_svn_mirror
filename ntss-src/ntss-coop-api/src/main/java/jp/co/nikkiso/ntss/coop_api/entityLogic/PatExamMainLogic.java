package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.CheckNecessaryParamUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.DateUtil;
import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 電文から抽出した項目に基づき、{@link PatExamMain}エンティティを作成するクラス。
 */
@Component
public class PatExamMainLogic implements EntityLogic {

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(PatExamMain.class, paramMap);
  }

  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {
    checkCommon(facilityCd, paramMap);

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    paramMap.put("reg_date", now);
  }

  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    checkCommon(facilityCd, paramMap);

    // 既存のpat_exam_mainレコードがあれば、内容をコピーする。
    PatExamMain pem = (PatExamMain) entity;

    paramMap.put("exam_main_cd", pem.getExamMainCd());
  }

  /**
   * insert/updateの共通チェック処理。
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void checkCommon(String facilityCd, Map<String, Object> paramMap) {

    // pat_idの必須チェック
    Long patId = (Long) paramMap.get("pat_id");
    CheckNecessaryParamUtil.checkRequired("pat_id", patId);

    // facility_cd
    CheckNecessaryParamUtil.checkRequired("facility_cd", facilityCd);

    // cop_order_no1 （連携オーダー番号1）
    String copOrderNo1 = (String) paramMap.get("cop_order_no1");
    CheckNecessaryParamUtil.checkRequired("cop_order_no1", copOrderNo1);
    paramMap.put("facility_cd", facilityCd);

    // 以下のフィールドはすべて連携対象外。
    // （特に除外していないため、レイアウトでマッピングを指定すればpat_exam_mainに登録される。）
    // ord_no
    // fn_pat_id

    // exam_status
    // order_comment
    // order_exam_set_info
    // exam_order_info
    // order_label_info

    // reg_exam_date（登録時検査日時）
    // 編集仕様には記載されていないが、pat_exam_mainテーブルの設計書では必須である。
    String regExamDateStr = (String) paramMap.get("reg_exam_date");
    CheckNecessaryParamUtil.checkRequired("reg_exam_date", regExamDateStr);
    Timestamp regExamDate = Timestamp.valueOf(DateUtil.convertDateStr(regExamDateStr));
    paramMap.put("reg_exam_date", regExamDate);

    // reg_order_class（登録時検査区分）
    // 編集仕様には記載されていないが、pat_exam_mainテーブルの設計書では必須である。
    String regOrderClass = (String) paramMap.get("reg_order_class");
    CheckNecessaryParamUtil.checkRequired("reg_order_class", regOrderClass);
    paramMap.put("reg_order_class", regOrderClass);

    // exam_result_info（検査結果情報）
    List<Map<String, Object>> eriList =
        ObjectMapperUtil.castToStringObjectMapList(paramMap.get("exam_result_info"));

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    setExamResultDate(eriList);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("電文から抽出した検査結果情報: " + eriList);
    eventLogMessage.setFacilityCd(facilityCd);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    paramMap.put("exam_result_info", eriList);

    // ### is_del, up_date, reg_date
    paramMap.putIfAbsent("is_del", JournalConvertConstants.LOGICAL_DELETE_FLAG_OFF);
    paramMap.put("up_date", now);
  }

  /**
   * 検査結果情報（リスト要素）の結果受信日時にシステム日付を設定する。
   *
   * @param l 電文から抽出した検査結果情報リスト
   */
  private void setExamResultDate(List<Map<String, Object>> l) {
    if (CollectionUtils.isEmpty(l)) {
      return;
    }

    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    for (Map<String, Object> param : l) {
      param.put("exam_result_date", now);
    }
  }

}
