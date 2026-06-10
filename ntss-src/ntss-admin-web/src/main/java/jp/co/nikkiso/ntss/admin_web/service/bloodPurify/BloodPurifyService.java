package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import java.util.List;
import jp.co.nikkiso.ntss.admin_web.response.bloodPurify.BPOrdInfoResponse;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;

public interface BloodPurifyService {
  /**
   * 浄化装置の透析情報を取得する.
   * @param argFacilityCd 施設コード.
   * @param argStartYyyyMmDd YYYYMMDD形式の治療開始日.
   * @return 浄化装置通信アプリ用の透析情報.
   */
  List<BPOrdInfoResponse> getBloodPurifyOrdInfoForBloodPurifyDevice(String argFacilityCd, String argStartYyyyMmDd);

  /**
   * クールマスタの情報を取得する.
   * @param argFacilityCd 施設コード.
   * @return クールマスタの情報.
   */
  List<MstKur> getMstKur(String argFacilityCd);

  /**
   * 日機装透析装置の透析情報を取得する.
   * @param argFacilityCd 施設コード.
   * @param argStartYyyyMmDd YYYYMMDD形式の治療開始日.
   * @return 浄化装置通信アプリ用の透析情報.
   */
  List<BPOrdInfoResponse> getBloodPurifyOrdInfoForNkkDevice(String argFacilityCd, String argStartYyyyMmDd);

  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 start
  /**
   * 装置マスタから必要な装置情報を取得する
   * @param argFacilityCd 施設コード.
   * @return 装置情報.
   */
  List<MstMachine> getDialysisDevice(String argFacilityCd);
  // add 2020-08-03 FNSI-仕様追加 装置マスタから必要な装置情報を取得し、device.csvファイルに更新する 李 end
}
