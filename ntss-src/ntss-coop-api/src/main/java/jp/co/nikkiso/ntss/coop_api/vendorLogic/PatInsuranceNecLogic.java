package jp.co.nikkiso.ntss.coop_api.vendorLogic;

import static java.util.Collections.emptyMap;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.DATE_FORMAT_YYYYMMDD;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_END_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_DEFAULT_START_DATE;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.PAT_INSURANCE_TMP_COLUMN;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 保険情報をチェック・編集するクラス。（NEC用）
 *
 * @see PatInsuranceVendorLogic
 */
@Component
public class PatInsuranceNecLogic extends AbstractPatInsuranceVendorLogic {

  private static final String INS_CD_01 = "INS_CD_01";
  private static final String INS_CD_02 = "INS_CD_02";
  private static final String INS_CD_03 = "INS_CD_03";
  private static final String INS_CD_04 = "INS_CD_04";
  private static final String INS_CD_05 = "INS_CD_05";

  private static final String[] INS_CD_KEYS = { INS_CD_01, INS_CD_02, INS_CD_03, INS_CD_04, INS_CD_05 };

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private ClockWrapper clockWrapper;

  /**
   * 保険情報をチェック・編集する。（NEC）
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param paramMap 電文から抽出した項目のマップ
   * @param patInsurance 既存の保険情報
   * @see jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic#check(String, Long, Map, PatInsurance)
   */
  @Override
  public void check(String facilityCd, Long patId, Map<String, Object> paramMap, PatInsuInfo patInsurance) {
    Object obj = paramMap.get(PAT_INSURANCE_TMP_COLUMN);
    if (obj == null) {
      return;
    }

    List<Map<String, Object>> insuInfoList = ObjectMapperUtil.castToStringObjectMapList(obj);
    if (CollectionUtils.isEmpty(insuInfoList)) {
      return;
    }

    try {
      for (Map<String, Object> insuInfo : insuInfoList) {
        List<PatInsuInfo> regInsuInfoList = new ArrayList<>();

        for (String insuInfoKey : INS_CD_KEYS) {
          Object value = insuInfo.get(insuInfoKey);
          if (value == null) {
            continue;
          }

          String insCd = (String) value;

          // 他のテーブルと異なり、pat_insuranceは1電文に対してレコードが複数作成される。
          Long insuranceCd = patInsuranceDao.selectNextSeqInsuCd();
          PatInsuInfo entity = new PatInsuInfo();

          setCommon(entity, insuranceCd, patId, facilityCd);

          switch (insuInfoKey) {
            case INS_CD_01:
              setInsCd01(entity, insCd);
              break;
            case INS_CD_02:
              setInsCd02(entity, insCd);
              break;
            case INS_CD_03:
              setInsCd03(entity, insCd);
              break;
            case INS_CD_04:
              setInsCd04(entity, insCd);
              break;
            case INS_CD_05:
              setInsCd05(entity, insCd);
              break;
            default:
              break;
          }

          regInsuInfoList.add(entity);
        }

        // DB登録
        register(facilityCd, patId, regInsuInfoList.get(0).getCoop_code(), regInsuInfoList);
      }

    } catch (IOException e) {
      throw new NtssException("保険情報の変換でエラーが発生しました", e);
    }
  }

  /**
   * INS_CD_01～INS_CD_05に依存しない共通処理。
   *
   * @param entity PatInsuInfoエンティティ
   * @param insuranceCd 保険情報コード（pat_insuranceの主キー）
   * @param patId 患者ID
   * @param facilityCd 施設コード
   */
  private void setCommon(PatInsuInfo entity, Long insuranceCd, Long patId, String facilityCd) {
    // insurance_cd = serial
    entity.setInsurance_cd(insuranceCd);

    // pat_id = pat_personal_main.pat_id
    entity.setPat_id(patId);

    // facility_cd = sys_coop_journal.facility_cd
    entity.setFacility_cd(facilityCd);

    // fn_pat_id = null
    entity.setFn_pat_id(null);

    // start_date = 00010101
    entity.setStart_date(PAT_INSURANCE_DEFAULT_START_DATE);

    // end_date = 99991231
    entity.setEnd_date(PAT_INSURANCE_DEFAULT_END_DATE);

    // check_date = current
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_YYYYMMDD);
    String yyyymmddStr = sdf.format(now);
    entity.setCheck_date(yyyymmddStr);

    // insu_set_info = {}
    entity.setInsu_set_info(emptyMap());

    // insu_self_info
    entity.setInsu_self_info(emptyMap());

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
  }

  /**
   * INS_CD_01の設定処理。
   *
   * @param entity PatInsuranceエンティティ
   * @param insCd col="pat_insurance.INS_CD_01"に対応する値
   * @throws IOException
   */
  private void setInsCd01(PatInsuInfo entity, String insCd) throws IOException {
    // ctl_no = 1
    entity.setCtl_no(1L);

    // insu_class = 0
    entity.setInsu_class(INSU_CLASS_INSU);

    // insu_name = INS_CD_01
    entity.setInsu_name(insCd);

    // insu_name_short = INS_CD_01
    entity.setInsu_name_short(insCd);

    // insu_info = {
    //   insu_name:INS_CD_01
    //   insu_no:null
    //   insu_kbn:0
    //   insu_pat_mark:null
    //   insu_pat_no:null
    //   cki_class:0
    //   kki_class:0
    //   und_six:0
    //   futan_g:null
    //   futan_n:null}
    Map<String, String> m = new HashMap<>();
    m.put("insu_name", insCd);
    m.put("insu_no", null);
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

    // coop_code = INS_CD_01
    entity.setCoop_code(insCd);

    // is_main_insu = 1
    entity.setIs_selected("1");
    // FIXME 設計とDB構造が不一致。確認中。
  }

  /**
   * INS_CD_02の設定処理。
   *
   * @param entity PatInsuranceエンティティ
   * @param insCd col="pat_insurance.INS_CD_02"に対応する値
   * @throws IOException
   */
  private void setInsCd02(PatInsuInfo entity, String insCd) throws IOException {
    //  設定項目はcheckInsCd01と同様。設定値はpat_insurance編集仕様を参照。
    entity.setCtl_no(2L);
    entity.setInsu_class(INSU_CLASS_KOHI);
    entity.setInsu_name(insCd);
    entity.setInsu_name_short(insCd);

    entity.setInsu_info(emptyMap());
    entity.setInsu_pub_info(createEmptyInsuPubInfoMap());
    entity.setCoop_code(insCd);
    entity.setIs_selected("0");
    // FIXME 設計とDB構造が不一致。確認中。
  }

  /**
   * INS_CD_03の設定処理。
   *
   * @param entity PatInsuranceエンティティ
   * @param insCd col="pat_insurance.INS_CD_03"に対応する値
   * @throws IOException
   */
  private void setInsCd03(PatInsuInfo entity, String insCd) throws IOException {
    entity.setCtl_no(3L);
    entity.setInsu_class(INSU_CLASS_KOHI);
    entity.setInsu_name(insCd);
    entity.setInsu_name_short(insCd);

    entity.setInsu_info(emptyMap());
    entity.setInsu_pub_info(createEmptyInsuPubInfoMap());
    entity.setCoop_code(insCd);
    entity.setIs_selected("0");
    // FIXME 設計とDB構造が不一致。確認中。
  }

  /**
   * INS_CD_04の設定処理。
   *
   * @param entity PatInsuranceエンティティ
   * @param insCd col="pat_insurance.INS_CD_04"に対応する値
   * @throws IOException
   */
  private void setInsCd04(PatInsuInfo entity, String insCd) throws IOException {
    entity.setCtl_no(4L);
    entity.setInsu_class(INSU_CLASS_KOHI);
    entity.setInsu_name(insCd);
    entity.setInsu_name_short(insCd);

    entity.setInsu_info(emptyMap());
    entity.setInsu_pub_info(createEmptyInsuPubInfoMap());
    entity.setCoop_code(insCd);
    entity.setIs_selected("0");
    // FIXME 設計とDB構造が不一致。確認中。
  }

  /**
   * INS_CD_05の設定処理。
   *
   * @param entity PatInsuranceエンティティ
   * @param insCd col="pat_insurance.INS_CD_04"に対応する値
   * @throws IOException
   */
  private void setInsCd05(PatInsuInfo entity, String insCd) throws IOException {
    entity.setCtl_no(5L);
    entity.setInsu_class(INSU_CLASS_KOHI);
    entity.setInsu_name(insCd);
    entity.setInsu_name_short(insCd);

    entity.setInsu_info(emptyMap());
    entity.setInsu_pub_info(createEmptyInsuPubInfoMap());
    entity.setCoop_code(insCd);
    entity.setIs_selected("0");
    // FIXME 設計とDB構造が不一致。確認中。
  }

  /**
   * INS_CD_02～INS_CD_05の場合にinsu_pub_infoに設定するマップを作成する。
   *
   * @return マップの文字列表現
   * @throws IOException
   */
  private Map<String, String> createEmptyInsuPubInfoMap() throws IOException {
    Map<String, String> m = new HashMap<>();
    m.put("insu_pub_name", null);
    m.put("insu_pub_no", null);
    m.put("insu_pub_pat_no", null);

    return m;
  }

}
