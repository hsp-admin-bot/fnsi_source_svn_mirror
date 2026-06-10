package jp.co.nikkiso.ntss.coop_api.vendorLogic;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.DATE_FORMAT_YYYYMMDD;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_END_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_START_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_TMP_COLUMN;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ByteUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 保険情報をチェック・編集するクラス。（パナソニック用）
 *
 * @see PatInsuranceVendorLogic
 */
@Component
public class PatInsurancePanaLogic extends AbstractPatInsuranceVendorLogic {

  @Autowired
  private PatInsuranceDao patInsuranceDao;
  
  @Autowired
  private LogService logService;

  private static final String INS_SET_NO = "INS_SET_NO";
  // PER_FAM_CLASS
  // RELATION
  private static final String INS_NO = "INS_NO";
  private static final String INS_PAT_MARK = "INS_PAT_MARK";
  private static final String INS_PAT_NO = "INS_PAT_NO";
  // INS_EXP_DATE
  private static final String INS_PUB_NO_1 = "INS_PUB_NO_1";
  private static final String INS_PUB_PAT_NO_1 = "INS_PUB_PAT_NO_1";
  // INS_PUB_EXP_DATE_1
  private static final String INS_PUB_NO_2 = "INS_PUB_NO_2";
  private static final String INS_PUB_PAT_NO_2 = "INS_PUB_PAT_NO_2";
  // INS_PUB_EXP_DATE_1
  private static final String INS_PUB_NO_3 = "INS_PUB_NO_3";
  private static final String INS_PUB_PAT_NO_3 = "INS_PUB_PAT_NO_3";
  // INS_PUB_EXP_DATE_1
  private static final String INS_SET_NAME = "INS_SET_NAME";

  // 以下のキーは受信するがDB登録には影響しない。
  // PER_FAM_CLASS、
  // RELATION
  // INS_EXP_DATE
  // INS_PUB_EXP_DATE_1
  // INS_PUB_EXP_DATE_2
  // INS_PUB_EXP_DATE_3

  @Autowired
  private ClockWrapper clockWrapper;

  /**
   * 保険情報をチェック・編集する。（Panasonic）
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param paramMap 電文から抽出した項目のマップ
   * @param patInsurance 既存の保険情報
   * @see jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic#check(String, Long, Map, PatInsurance)
   */
  @Override
  public void check(String facilityCd, Long patId, Map<String, Object> paramMap, PatInsuInfo patInsuInfo) {
    Object obj = paramMap.get(PAT_INSURANCE_TMP_COLUMN);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> patInsuInfoList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(patInsuInfoList)) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    for (Map<String, Object> insuInfo : patInsuInfoList) {
      String insSetNo = (String) insuInfo.get(INS_SET_NO);
      String insNo = (String) insuInfo.get(INS_NO);
      String insPatMark = (String) insuInfo.get(INS_PAT_MARK);
      String insPatNo = (String) insuInfo.get(INS_PAT_NO);

      String insPubNo1 = (String) insuInfo.get(INS_PUB_NO_1);
      String insPubPatNo1 = (String) insuInfo.get(INS_PUB_PAT_NO_1);

      String insPubNo2 = (String) insuInfo.get(INS_PUB_NO_2);
      String insPubPatNo2 = (String) insuInfo.get(INS_PUB_PAT_NO_2);

      String insPubNo3 = (String) insuInfo.get(INS_PUB_NO_3);
      String insPubPatNo3 = (String) insuInfo.get(INS_PUB_PAT_NO_3);

      String insSetName = (String) insuInfo.get(INS_SET_NAME);

      // 登録番号
      Long ctlNo = 0L;

      Long insInsuranceCd = null;
      Long kohi1InsuranceCd = null;
      Long kohi2InsuranceCd = null;
      Long kohi3InsuranceCd = null;

      List<PatInsuInfo> insuInfoList = new ArrayList<>();

      // 保険情報の登録
      PatInsuInfo insEntity = createInsuEntity(facilityCd, patId, ++ctlNo);
      setIns(insEntity, insNo, insPatMark, insPatNo);

      insInsuranceCd = insEntity.getInsurance_cd();

      insuInfoList.add(insEntity);

      // 公費負担を利用していない場合、公費情報1～3は存在しない。
      // 負担者番号と受給者番号が指定されている場合のみ、公費情報を登録する。
      // （対して、保険情報とセット情報は必須の想定。）

      // 公費情報1の登録
      if (isKohiSpecified(insPubNo1, insPubPatNo1)) {
        PatInsuInfo kohi1Entity = createInsuEntity(facilityCd, patId, ++ctlNo);
        setKohi(kohi1Entity, insPubNo1, insPubPatNo1);

        kohi1InsuranceCd = kohi1Entity.getInsurance_cd();

        insuInfoList.add(kohi1Entity);
      }

      // 公費情報2の登録
      if (isKohiSpecified(insPubNo2, insPubPatNo2)) {
        PatInsuInfo kohi2Entity = createInsuEntity(facilityCd, patId, ++ctlNo);
        setKohi(kohi2Entity, insPubNo2, insPubPatNo2);

        kohi2InsuranceCd = kohi2Entity.getInsurance_cd();
        insuInfoList.add(kohi2Entity);
      }

      // 公費情報3の登録
      if (isKohiSpecified(insPubNo3, insPubPatNo3)) {
        PatInsuInfo kohi3Entity = createInsuEntity(facilityCd, patId, ++ctlNo);
        setKohi(kohi3Entity, insPubNo3, insPubPatNo3);

        kohi3InsuranceCd = kohi3Entity.getInsurance_cd();
        insuInfoList.add(kohi3Entity);
      }

      // セット情報の登録
      PatInsuInfo setEntity = createInsuEntity(facilityCd, patId, ++ctlNo);
      setSetInfo(setEntity, insSetNo, insSetName, insInsuranceCd,
          kohi1InsuranceCd, kohi2InsuranceCd, kohi3InsuranceCd);

      insuInfoList.add(setEntity);

      // DB登録
      register(facilityCd, patId, insNo, insuInfoList);

      eventLogMessage.setLogMessage(facilityCd + ":PatInsurancePanaLogic:check paramMap=" + paramMap);
      eventLogMessage.setFacilityCd(facilityCd);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * PatInsuInfoエンティティを作成し、共通項目を設定する。
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param ctlNo 登録
   * @return
   */
  private PatInsuInfo createInsuEntity(String facilityCd, Long patId, Long ctlNo) {
    Long insuranceCd = patInsuranceDao.selectNextSeqInsuCd();

    PatInsuInfo entity = new PatInsuInfo();
    setCommon(entity, insuranceCd, patId, facilityCd, ctlNo);

    return entity;
  }

  /**
   * 共通処理。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insuranceCd 保険情報コード（pat_insuranceの主キー）
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param ctlNo 登録番号
   */
  private void setCommon(PatInsuInfo entity, Long insuranceCd, Long patId, String facilityCd, Long ctlNo) {
    // insurance_cd = serial
    entity.setInsurance_cd(insuranceCd);

    // pat_id = pat_personal_main.pat_id
    entity.setPat_id(patId);

    // facility_cd = sys_coop_journal.facility_cd
    entity.setFacility_cd(facilityCd);

    // ctl_no
    entity.setCtl_no(ctlNo);

    // fn_pat_id = null
    entity.setFn_pat_id(null);

    // start_date
    entity.setStart_date(PAT_INSURANCE_DEFAULT_START_DATE);

    // end_date
    entity.setEnd_date(PAT_INSURANCE_DEFAULT_END_DATE);

    // check_date = current
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_YYYYMMDD);
    String yyyymmddStr = sdf.format(now);
    entity.setCheck_date(yyyymmddStr);

    // is_coop = 1
    entity.setIs_coop("1");

    // is_disp = 1
    entity.setIs_disp("1");

    // is_del = 0
    entity.setIs_del("0");

    // reg_date = current
    String nowStr = now.toString();
    entity.setReg_date(nowStr);

    // up_date = current
    entity.setUp_date(nowStr);

    // insu_self_info
    entity.setInsu_self_info(Collections.emptyMap());
  }

  /**
   * 保険情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insNo 保険者番号
   * @param insPatMark 被保険者証・記号
   * @param insPatNo 被保険者証・番号
   */
  private void setIns(PatInsuInfo entity, String insNo, String insPatMark, String insPatNo) {
    // insu_class
    entity.setInsu_class(INSU_CLASS_INSU);

    // insu_name
    entity.setInsu_name(insNo);

    // insu_name_short
    String insuNameShort = insNo.trim();
    entity.setInsu_name_short(insuNameShort);

    // insu_info: {
    //    insu_name:trim(INS_NO)
    //    insu_no:INS_NOを数値化
    //    insu_kbn:0
    //    insu_pat_mark: INS_PAT_MARK
    //    insu_pat_no: INS_PAT_NO
    //    cki_class:0
    //    kki_class:0
    //    und_six:0
    //    futan_g:null
    //    futan_n:null
    // }
    Map<String, String> insuInfoMap = new HashMap<>();
    insuInfoMap.put("insu_name", insuNameShort);
    insuInfoMap.put("insu_no", insNo); // Long.parseLong(insNo)
    insuInfoMap.put("insu_kbn", "0");
    insuInfoMap.put("insu_pat_mark", insPatMark);
    insuInfoMap.put("insu_pat_no", insPatNo);
    insuInfoMap.put("cki_class", "0");
    insuInfoMap.put("kki_class", "0");
    insuInfoMap.put("und_six", "0");
    insuInfoMap.put("futan_g", null);
    insuInfoMap.put("futan_n", null);
    entity.setInsu_info(insuInfoMap);

    // insu_pub_info
    entity.setInsu_pub_info(Collections.emptyMap());

    // insu_set_info
    entity.setInsu_set_info(Collections.emptyMap());

    // coop_code
    entity.setCoop_code(insNo);
  }

  /**
   * 公費情報（1～3）が指定されているか判定する。
   *
   * @param insPubNo 公費負担者番号
   * @param insPubPatNo 公費受給者番号
   * @return 指定されていればtrue
   */
  private boolean isKohiSpecified(String insPubNo, String insPubPatNo) {
    return !StringUtils.isEmpty(insPubNo) && !StringUtils.isEmpty(insPubPatNo);
  }

  /**
   * 公費情報（1～3）を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insPubNo 公費負担者番号
   * @param insPubPatNo 公費受給者番号
   */
  private void setKohi(PatInsuInfo entity, String insPubNo, String insPubPatNo) {
    // insu_class
    entity.setInsu_class(INSU_CLASS_KOHI);

    // insu_name
    entity.setInsu_name(insPubNo);

    // insu_name_short
    String insuNameShort = ByteUtil.getUpper2Bytes(insPubNo);
    entity.setInsu_name_short(insuNameShort);

    // insu_info
    entity.setInsu_info(Collections.emptyMap());

    // insu_pub_info: {
    //  insu_pub_name: INS_PUB_NO_nnを文字で
    //  insu_pub_no:INS_PUB_NO_nnを数値で
    //  insu_pub_pat_no:INS_PUB_PAT_NO_nn
    // }
    Map<String, String> insuPubInfoMap = new HashMap<>();
    insuPubInfoMap.put("insu_pub_name", insPubNo);
    insuPubInfoMap.put("insu_pub_no", insPubNo);
    insuPubInfoMap.put("insu_pub_name", insPubPatNo);
    entity.setInsu_pub_info(insuPubInfoMap);

    // insu_set_info
    entity.setInsu_set_info(Collections.emptyMap());

    // coop_code
    entity.setCoop_code(insPubNo);
  }

  /**
   * セット情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insSetNo 保険組No
   * @param insSetName 保険名称
   * @param insuranceCd0 insu_class=0のinsurance_cd
   * @param insuranceCd1 insu_class=1のinsurance_cd(nn=1)
   * @param insuranceCd2 insu_class=1のinsurance_cd(nn=2)
   * @param insuranceCd3 insu_class=1のinsurance_cd(nn=3)
   */
  private void setSetInfo(PatInsuInfo entity, String insSetNo, String insSetName,
      Long insuranceCd0, Long insuranceCd1, Long insuranceCd2, Long insuranceCd3) {
    // insu_class
    entity.setInsu_class(INSU_CLASS_SET);

    // insu_name
    entity.setInsu_name(insSetName);

    // insu_name_short
    entity.setInsu_name_short(insSetName);

    // insu_info
    entity.setInsu_info(Collections.emptyMap());

    // insu_pub_info
    entity.setInsu_pub_info(Collections.emptyMap());

    // insu_set_info: {
    //   insu_cd:insu_class=0のinsurance_cd
    //   insu_pub1_cd:insu_class=1のinsurance_cd(nn=1)
    //   insu_pub2_cd:insu_class=1のinsurance_cd(nn=2)
    //   insu_pub3_cd:insu_class=1のinsurance_cd(nn=3)
    //   insu_pub4_cd:null
    // }
    Map<String, String> insuSetInfoMap = new HashMap<>();
    insuSetInfoMap.put("insu_cd", toString(insuranceCd0));
    insuSetInfoMap.put("insu_pub1_cd", toString(insuranceCd1));
    insuSetInfoMap.put("insu_pub2_cd", toString(insuranceCd2));
    insuSetInfoMap.put("insu_pub3_cd", toString(insuranceCd3));
    insuSetInfoMap.put("insu_pub4_cd", null);

    entity.setInsu_set_info(insuSetInfoMap);

    // coop_code
    entity.setCoop_code(insSetNo);
  }

  /**
   * Longを文字列に変換する。
   * @param l Longの値
   * @return 引数の文字列表現
   */
  private String toString(Long l) {
    // オブジェクトobjがnullである時、String.valueOf(obj)は"null"という文字列である。
    // これを回避する。
    if (l == null) {
      return null;
    }

    return String.valueOf(l);
  }
}
