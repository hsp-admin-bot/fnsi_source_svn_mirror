package jp.co.nikkiso.ntss.coop_api.vendorLogic;

import static java.util.Collections.emptyMap;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.DATE_FORMAT_YYYYMMDD;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_END_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_START_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_TMP_COLUMN;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ByteUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 保険情報をチェック・編集するクラス。（富士通用）
 *
 * @see PatInsuranceVendorLogic
 */
@Component
public class PatInsuranceFujitsuLogic extends AbstractPatInsuranceVendorLogic {

  /**
   * 保険情報キー: 保険パターン
   */
  private static final String INS_KEY_PATTERN = "PATTERN";

  /**
   * 保険情報キー: 主保険保険者番号
   */
  private static final String INS_KEY_INS_NO = "INS_NO";

  /**
   * 保険情報キー: 公費負担者番号1
   */
  private static final String INS_KEY_KOHI_1 = "KOHI_1";

  /**
   * 保険情報キー: 保険名称
   */
  private static final String INS_KEY_INS_NAME = "INS_NAME";

  private static final Pattern ALL_ZERO = Pattern.compile("^0+$");

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  /**
   * 保険情報をチェック・編集する。
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param paramMap 電文から抽出した項目のマップ
   * @param patInsurance 既存の保険情報
   * @see jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic#check(String, Long, Map, PatInsuInfo)
   */
  @Override
  public void check(String facilityCd, Long patId, Map<String, Object> paramMap, PatInsuInfo patInsurance) {
    Object obj = paramMap.get(PAT_INSURANCE_TMP_COLUMN);
    if (obj == null) {
      return;
    }

    List<Map<String, String>> insuInfoList = ObjectMapperUtil.castToStringStringMapList(obj);
    if (CollectionUtils.isEmpty(insuInfoList)) {
      return;
    }

    try {
      // 表示順として登録する値
      Long ctlNo = 1L;
      EventLogMessage eventLogMessage = new EventLogMessage();
      for (Map<String, String> insuInfo : insuInfoList) {
        String pattern = insuInfo.get(INS_KEY_PATTERN);
        String insNo = insuInfo.get(INS_KEY_INS_NO);
        String kohi1 = insuInfo.get(INS_KEY_KOHI_1);
        String insName = insuInfo.get(INS_KEY_INS_NAME);

        // FIXME 以下の項目はテーブル別編集仕様で記載されていない。
        // FIXME そのため、電文からは抽出するが連携時には使用していない。
        // ・保険パターンSEQ (PATTERNSEQ)
        // ・保険開始日 (STDATE)
        // ・保険終了日 (EDDATE)
        // ・公費負担者番号2 (KOHI_2)
        // ・公費負担者番号3 (KOHI_3)
        // ・公費負担者番号4 (KOHI_4)
        // ・本人家族区分 (PER_FAM_CLASS)
        // ・外来負担率 (BURDEN_RATIO GAIRAI)
        // ・入院負担率 (BURDEN_RATIO NYUIN)

        // ## 処理概要
        // 1. 保険パターンによる分岐
        //   1.1. 主保険保険者番号`INS_NO`が`空`もしくはall`0`の場合は処理なし
        if (isBlankOrAllZero(insNo)) {
          // 生保の場合、INS_NOもKOHI_1も空であり、このケースに該当する。（現状では処理なし）
          eventLogMessage.setLogMessage("主保険保険者番号が空の電文を処理しました。施設コード:[" + facilityCd + "], 患者ID:[" + patId + "]");
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          continue;
        }

        //   1.2. 主保険保険者番号`INS_NO`がある場合
        //      1.2.1. 公費負担者番号１`KOHI_1`が`空`もしくはall`0`の場合は保険リスト情報`insu_class`=`0`(保険)の処理を行うため`insu_class`情報を付加する
        int insuClass;

        if (isBlankOrAllZero(kohi1)) {
          insuClass = INSU_CLASS_INSU;
        } else {
          //    1.2.2. 上記以外は`insu_class`=`1`(公費)の処理を行うため`insu_class`情報を付加する
          insuClass = INSU_CLASS_KOHI;
        }

        //   1.3. `insu_class`のない場合、エラー<br/>→ではない(生保)
        // ⇒上記1.で判定している。現状では処理なし。

        switch (insuClass) {
          case INSU_CLASS_INSU:
            registerInsuRecords(patId, facilityCd, insNo, insName, pattern, ctlNo);
            break;
          case INSU_CLASS_KOHI:
            registerKohiRecords(patId, facilityCd, kohi1, insName, pattern, ctlNo, insNo);
            break;
          default:
            break;
        }

        ctlNo += 2;
      }

    } catch (IOException e) {
      throw new NtssException("保険情報の変換でエラーが発生しました", e);
    }
  }

  /**
   * 保険のレコードを登録する。
   *
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param insNo 主保険保険者番号
   * @param insName 保険名称
   * @param pattern 保険パターン
   * @param ctlNo 登録番号
   * @throws IOException
   */
  private void registerInsuRecords(Long patId, String facilityCd, String insNo, String insName, String pattern,
      Long ctlNo)
      throws IOException {
    PatInsuInfo entityInsu = new PatInsuInfo();
    Long insuranceCd = patInsuranceDao.selectNextSeqInsuCd();

    setCommon(entityInsu, insuranceCd, patId, facilityCd, ctlNo);
    setInsuClass0(entityInsu, insNo);

    PatInsuInfo entitySet = new PatInsuInfo();
    Long insuranceCdSet = patInsuranceDao.selectNextSeqInsuCd();

    setCommon(entitySet, insuranceCdSet, patId, facilityCd, ctlNo + 1);
    setInsuClass0SetInfo(entitySet, insName, pattern, insuranceCd);

    List<PatInsuInfo> patInsuInfoList = Arrays.asList(entityInsu, entitySet);
    register(facilityCd, patId, entityInsu.getCoop_code(), patInsuInfoList);
  }

  /**
   * 公費のレコードを登録する。
   *
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @param kohi1 公費負担者番号1
   * @param insName 保険名称
   * @param pattern 保険パターン
   * @param ctlNo 登録番号
   * @param insNo 主保険保険者番号
   * @throws IOException
   */
  private void registerKohiRecords(Long patId, String facilityCd, String kohi1, String insName, String pattern,
      Long ctlNo, String insNo)
      throws IOException {
    PatInsuInfo entityInsu = new PatInsuInfo();
    Long insuranceCd = patInsuranceDao.selectNextSeqInsuCd();

    setCommon(entityInsu, insuranceCd, patId, facilityCd, ctlNo);
    setInsuClass1(entityInsu, kohi1);

    PatInsuInfo entitySet = new PatInsuInfo();
    Long insuranceCdSet = patInsuranceDao.selectNextSeqInsuCd();

    setCommon(entitySet, insuranceCdSet, patId, facilityCd, ctlNo + 1);
    setInsuClass1SetInfo(entitySet, insName, pattern, insuranceCd);

    List<PatInsuInfo> patInsuInfoList = Arrays.asList(entityInsu, entitySet);
    register(facilityCd, patId, entityInsu.getCoop_code(), patInsuInfoList);
  }

  /**
   * insu_classおよびセット情報に共通な情報を設定する。
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

    // ctl_no = 1電文中の保険情報内の通し番号
    entity.setCtl_no(ctlNo);

    // fn_pat_id = null
    entity.setFn_pat_id(null);

    // start_date = 1001-01-01
    entity.setStart_date(PAT_INSURANCE_DEFAULT_START_DATE);

    // end_date = 2099-12-31
    entity.setEnd_date(PAT_INSURANCE_DEFAULT_END_DATE);

    // check_date = current
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_YYYYMMDD);
    String yyyymmddStr = sdf.format(now);
    entity.setCheck_date(yyyymmddStr);

    // insu_self_info
    entity.setInsu_self_info(emptyMap());

    //  is_coop = '1'
    entity.setIs_coop("1");

    // is_main_insu = '0'
    entity.setIs_selected("1");
    // FIXME 設計とDB構造が不一致。確認中。

    // is_disp = '1'
    entity.setIs_disp("1");

    // is_del = 0
    entity.setIs_del("0");

    // reg_date = current
    String nowStr = now.toString();
    entity.setReg_date(nowStr);

    // up_date = current
    entity.setUp_date(nowStr);
  }

  /**
   * insu_class=0（保険）に対応する情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insNo 主保険保険者番号
   * @throws IOException
   */
  private void setInsuClass0(PatInsuInfo entity, String insNo) throws IOException {
    // insu_class = 0(保険)
    entity.setInsu_class(INSU_CLASS_INSU);

    // insu_name = INS_NO
    entity.setInsu_name(insNo);

    // insu_name_short = INS_NOの上位２バイト
    entity.setInsu_name_short(ByteUtil.getUpper2Bytes(insNo));

    // insu_info = {
    //    insu_name: INS_NOを文字で
    //    insu_no:INS_NOを数値で
    //    insu_kbn:0
    //    insu_pat_mark:null
    //    insu_pat_no:null
    //    cki_class:0
    //    kki_class:0
    //    und_six:0
    //    futan_g:null
    //    futan_n:null}
    Map<String, String> m = new HashMap<>();
    m.put("insu_name", insNo);
    m.put("insu_no", insNo);
    // PatInsuInfoの定義により、insu_noも文字列型である。
    m.put("insu_kbn", "0");
    m.put("insu_pat_mark", null);
    m.put("insu_pat_no", null);
    m.put("cki_class", "0");
    m.put("kki_class", "0");
    m.put("und_six", "0");
    m.put("futan_g", null);
    m.put("futan_n", null);

    entity.setInsu_info(m);

    // insu_pub_info = {}
    entity.setInsu_pub_info(emptyMap());

    // insu_set_info = {}
    entity.setInsu_set_info(emptyMap());

    // coop_code = INS_NO
    entity.setCoop_code(insNo);
  }

  /**
   * insu_class=1（公費）に対応する情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param kohi1 公費負担者番号1
   * @throws IOException
   */
  private void setInsuClass1(PatInsuInfo entity, String kohi1) throws IOException {
    // insu_class = 1
    entity.setInsu_class(INSU_CLASS_KOHI);

    // insu_name = KOHI_1
    entity.setInsu_name(kohi1);

    // insu_name_short = KOHI_1の上位２バイト
    entity.setInsu_name_short(ByteUtil.getUpper2Bytes(kohi1));

    // insu_info = {}
    entity.setInsu_info(emptyMap());

    // insu_pub_info = {
    //    insu_pub_name:KOHI_1を文字列で
    //    insu_pub_no:KOHI_1を数値で
    //    insu_pub_pat_no:null}
    Map<String, String> m = new HashMap<>();
    m.put("insu_pub_name", kohi1);
    m.put("insu_pub_no", kohi1);
    // PatInsuInfoの定義により、insu_pub_noも文字列型である。
    m.put("insu_pub_pat_no", null);

    entity.setInsu_pub_info(m);

    // insu_set_info = {}
    entity.setInsu_set_info(emptyMap());

    // coop_code = KOHI_1
    entity.setCoop_code(kohi1);
  }

  /**
   * insu_class=0（保険）に対応するセット情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insName 保険名称
   * @param pattern 保険パターン
   * @param insuClass0Seq insu_class=0に対する保険情報のinsurance_cd
   * @throws IOException
   */
  private void setInsuClass0SetInfo(PatInsuInfo entity, String insName, String pattern, Long insuClass0Seq)
      throws IOException {
    // insu_class = 2（セット）
    entity.setInsu_class(INSU_CLASS_SET);

    // insu_name = INS_NAME
    entity.setInsu_name(insName);

    // insu_name_short = PATTERN
    entity.setInsu_name_short(pattern);

    // insu_info = {}
    entity.setInsu_info(emptyMap());

    // insu_pub_info = {}
    entity.setInsu_pub_info(emptyMap());

    // insu_set_info = {
    //    insu_cd:`insu_class=1`のシーケンス
    //    insu_pub1_cd:null
    //    insu_pub2_cd:null
    //    insu_pub3_cd:null
    //    insu_pub4_cd:null<br>}
    Map<String, String> m = new HashMap<>();
    m.put("insu_cd", String.valueOf(insuClass0Seq));
    m.put("insu_pub1_cd", null);
    m.put("insu_pub2_cd", null);
    m.put("insu_pub2_cd", null);
    m.put("insu_pub2_cd", null);

    entity.setInsu_set_info(m);

    //  | coop_code | INS_NO | KOHI_1 | PATTERN | PATTERN |
    entity.setCoop_code(pattern);
  }

  /**
   * insu_class=1（公費）に対応するセット情報を設定する。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insName 保険名称
   * @param pattern 保険パターン
   * @param insuClass1Seq insu_class=1に対する保険情報のinsurance_cd
   * @throws IOException
   */
  private void setInsuClass1SetInfo(PatInsuInfo entity, String insName, String pattern, Long insuClass1Seq)
      throws IOException {
    // insu_class = 2（セット）
    entity.setInsu_class(INSU_CLASS_SET);

    // insu_name = INS_NAME
    entity.setInsu_name(insName);

    // insu_name_short = PATTERN
    entity.setInsu_name_short(pattern);

    // insu_info = {}
    entity.setInsu_info(emptyMap());

    // insu_pub_info = {}
    entity.setInsu_pub_info(emptyMap());

    // insu_set_info = {
    //    insu_cd:`insu_class=2`のシーケンス
    //    insu_pub1_cd:null
    //    insu_pub2_cd:null
    //    insu_pub3_cd:null
    //    insu_pub4_cd:null}
    Map<String, String> m = new HashMap<>();
    m.put("insu_cd", String.valueOf(insuClass1Seq));
    m.put("insu_pub1_cd", null);
    m.put("insu_pub2_cd", null);
    m.put("insu_pub2_cd", null);
    m.put("insu_pub2_cd", null);

    entity.setInsu_set_info(m);

    // coop_code = PATTERN
    entity.setCoop_code(pattern);
  }

  /**
   * 文字列が空、ないしすべて0か否かを判定する。
   *
   * @param s 文字列
   * @return 条件を満たす場合true
   */
  private boolean isBlankOrAllZero(String s) {
    return StringUtils.isEmpty(s) || ALL_ZERO.matcher(s).matches();
  }

}
