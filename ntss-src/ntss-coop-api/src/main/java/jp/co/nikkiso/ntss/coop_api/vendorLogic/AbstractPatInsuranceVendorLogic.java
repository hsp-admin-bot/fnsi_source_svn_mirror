package jp.co.nikkiso.ntss.coop_api.vendorLogic;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;

import tools.jackson.databind.JavaType;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * ベンダに依存しない保険情報（pat_insurance）共通処理の実装クラス。
 *
 * @see jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic
 */
public abstract class AbstractPatInsuranceVendorLogic implements PatInsuranceVendorLogic {

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  /**
   * DB登録処理。
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param insNo 保険番号（insu_class=0）
   * @param insuInfoList 保険情報のリスト（insu_class=0～2）
   * @see jp.co.nikkiso.ntss.coop_api.vendorLogic.PatInsuranceVendorLogic#register(java.lang.String, java.lang.Long, java.lang.String, java.util.List)
   */
  @Override
  public void register(String facilityCd, Long patId, String insNo, List<PatInsuInfo> insuInfoList) {
    if (CollectionUtils.isEmpty(insuInfoList)) {
      return;
    }

    try {
      String coopCodeTele = insNo != null ? insNo : null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      for (PatInsuInfo pii : insuInfoList) {
        coopCodeTele = coopCodeTele == null ? pii.getCoop_code() : coopCodeTele;
        PatInsurance patInsuranceDb = patInsuranceDao.selectForCoop(patId, facilityCd, pii.getInsu_class(),
            coopCodeTele);

        eventLogMessage.setLogMessage(facilityCd + ":selectPatInsurance:pat_id=" + patId + ",insu_class=" + pii.getInsu_class() + ",coop_code=" + coopCodeTele + ",");
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        if (patInsuranceDb == null) {
          patInsuranceDao.insert(pii);
        } else {
          PatInsuInfo piiForUpdate = createInsuInfoFromInsurance(patInsuranceDb);
          copyField(piiForUpdate, pii);

          patInsuranceDao.insert(piiForUpdate);
        }
      }
    } catch (IOException e) {
      String errMsg = String.format("保険情報の登録でエラーが発生しました。施設コード:[%s]、患者ID:[%l]",
          facilityCd, patId);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * PatInsuInfoのフィールドをコピーする。
   * @param dst コピー先
   * @param src コピー元
   */
  private void copyField(PatInsuInfo dst, PatInsuInfo src) {
    // 更新日時はinsu_classに依存せず更新する。
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    dst.setUp_date(now.toString());

    dst.setInsurance_cd(src.getInsurance_cd());

    // insu_classの値により分岐
    switch (src.getInsu_class()) {
      case INSU_CLASS_KOHI:
        // insu_class=1（公費）
        // プライマリキーinsurance_cdはDBから取得した値のまま変更しない。

        dst.setCtl_no(src.getCtl_no());
        dst.setFn_pat_id(src.getFn_pat_id());

        // is_main_insu, insu_name, insu_name_shortは変更しない。
        // insu_classもDBから取得したままで変更しない。

        dst.setStart_date(src.getStart_date());
        dst.setEnd_date(src.getEnd_date());

        dst.setInsu_info(src.getInsu_info());
        dst.setInsu_pub_info(src.getInsu_pub_info());
        dst.setInsu_set_info(src.getInsu_set_info());
        dst.setInsu_self_info(src.getInsu_self_info());

        dst.setCoop_code(src.getCoop_code());
        dst.setIs_coop(src.getIs_coop());

        dst.setIs_disp(src.getIs_disp());
        dst.setIs_del(src.getIs_del());

        // 登録日時は変更しない。

        break;

      case INSU_CLASS_SET:
        // insu_class=2（セット情報）
        // insu_set_infoのみコピーする。
        dst.setInsu_set_info(src.getInsu_set_info());
        break;

      default:
        break;
    }
  }

  /**
   * PatInsuranceエンティティからPatInsuInfoエンティティを作成する。
   *
   * @param patInsurance PatInsuranceエンティティ
   * @return PatInsuInfoエンティティ
   * @throws IOException
   */
  private PatInsuInfo createInsuInfoFromInsurance(PatInsurance patInsurance) throws IOException {
    PatInsuInfo patInsuInfo = new PatInsuInfo();

    // jsonb型以外のカラム
    // copyPropertiesでコピーする。
    // （ここで使用するBeanUtilsはSpringのものである。
    //   Apache Commonsの同名クラスは、String→Map<String, String>用の変換カスタマイズを実装する必要があり、
    //   手間が大きい。）
    BeanUtils.copyProperties(patInsurance, patInsuInfo);

    // jsonb型のカラム
    // PatInsuranceではStringとなっている。Map<String, String>に変換する。
    JavaType jt = ObjectMapperUtil.constructMapType(String.class, String.class);
    patInsuInfo.setInsu_info(ObjectMapperUtil.read(patInsurance.getInsu_info(), jt));
    patInsuInfo.setInsu_pub_info(ObjectMapperUtil.read(patInsurance.getInsu_pub_info(), jt));
    patInsuInfo.setInsu_set_info(ObjectMapperUtil.read(patInsurance.getInsu_set_info(), jt));
    patInsuInfo.setInsu_self_info(ObjectMapperUtil.read(patInsurance.getInsu_self_info(), jt));

    return patInsuInfo;
  }
}
