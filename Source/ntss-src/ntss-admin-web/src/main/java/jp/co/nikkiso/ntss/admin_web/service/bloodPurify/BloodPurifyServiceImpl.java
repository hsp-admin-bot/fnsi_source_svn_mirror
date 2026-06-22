package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachine;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.common.base.Objects;

import jp.co.nikkiso.ntss.admin_web.response.bloodPurify.BPOrdInfoResponse;
import jp.co.nikkiso.ntss.core.dao.BloodPurifyDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.BPOrdInfo;

/**
 * 浄化装置通信アプリのサービスクラス.
 *
 * @author Shingo Yamazaki
 */
@Service
public class BloodPurifyServiceImpl implements BloodPurifyService {
  @Autowired
  private BloodPurifyDao bpDao;

  @Autowired
  private PatPersonalMainDao ppmDao;

  @Autowired
  private MstKurDao mkDao;

  /**
   * 特殊浄化治療情報を取得する対象が日機装装置かそれ以外の浄化装置かを判定する定数
   */
  private static class IsNkkDevice {
    /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    /**
     * 日機装装置対象
     */
    public static final boolean ON = true;
    /**
     * 浄化装置対象
     */
    public static final boolean OFF = false;
    /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<BPOrdInfoResponse> getBloodPurifyOrdInfoForBloodPurifyDevice(String argFacilityCd,
      String argStartYyyyMmDd) {
    List<BPOrdInfo> oiList = bpDao.selectOrdInfoForBloodPurifyDevice(argFacilityCd, argStartYyyyMmDd, IsNkkDevice.OFF);
    return makeBPOrdInfoJoinedPatPaersonalMain(oiList);
  }

  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachine> getDialysisDevice(String argFacilityCd) {
    return bpDao.selectDialysisDevice(argFacilityCd);
  }
  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstKur> getMstKur(String argFacilityCd) {
    return mkDao.selectByFacilityCd(SelectOptions.get(), argFacilityCd, "0");
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<BPOrdInfoResponse> getBloodPurifyOrdInfoForNkkDevice(String argFacilityCd, String argStartYyyyMmDd) {
    List<BPOrdInfo> oiList = bpDao.selectOrdInfoForBloodPurifyDevice(argFacilityCd, argStartYyyyMmDd, IsNkkDevice.ON);
    return makeBPOrdInfoJoinedPatPaersonalMain(oiList);
  }

  /**
   * 浄化装置通信アプリ用の透析情報エンティティ と PatPersonalMain をJOINしたものを生成.
   */
  private List<BPOrdInfoResponse> makeBPOrdInfoJoinedPatPaersonalMain(List<BPOrdInfo> argListOi) {
    List<BPOrdInfoResponse> ret = new java.util.ArrayList<BPOrdInfoResponse>();

    // 患者名は別のDBインスタンスにいるので別個のSQLで取得
    List<Long> listPatId = new ArrayList<Long>();
    for (BPOrdInfo one : argListOi) {
      listPatId.add(one.getPatId());
    }
    List<PatPersonalMain> sbil = ppmDao.selectByIdList(listPatId);

    // 2つのSQLで得られた結果をくっつける
    for (int pos = 0; pos < argListOi.size(); pos++) {
      BPOrdInfo oiOne = argListOi.get(pos);

      // 患者ID一致するPatPersonalMainのデータを抽出
      PatPersonalMain ppmOne = sbil.stream().filter(one -> Objects.equal(one.getPat_id(), oiOne.getPatId()))
          .findFirst().orElse(new PatPersonalMain());

      String pln = ppmOne.getPat_last_name();
      String pfn = ppmOne.getPat_first_name();
      Integer ioc = ppmOne.getIn_out_class();

      // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
      String hpid = ppmOne.getHosp_pat_id();
      // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end

      ret.add(new BPOrdInfoResponse(
          oiOne.getOrdNo(),
          oiOne.getRstBedName(),
          oiOne.getIsSame(),
          (null == pln ? "" : pln) + " " + (null == pfn ? "" : pfn),
          null == ioc ? -1 : ioc,
          oiOne.getRstDialysisState(),
          oiOne.getKurName(),
          oiOne.getKurStartTime(),
          oiOne.getKurEndTime(),
        // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
          hpid,oiOne.getRst_treatment_name()));
      // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
    }

    return ret;
  }
}
