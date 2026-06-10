package jp.co.nikkiso.ntss.admin_web.service.master.graphSetting;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.custom.GraphSettingInfo;

public interface MstGraphSettingService {

  /**
   * 施設設定データの取得.
   * 
   * @param facilityCd 施設コード.
   * @return 利用者データ情報.
   */
  MasterDataResponse getMasterData(String facilityCd);

  /**
   * 施設データの取得.
   * 
   * @return 施設データ情報.
   */
  List<MstFacility> selectMstFacility();
  
  /**
   * 施設設定情報の登録・更新処理
   * @param payload
   * @throws Exception
   */
  void saveMstGraphSetting(Map<String, List<String>> payload) throws Exception;
  
  /**
   * P-Ca9分割グラフ設定情報の取得
   * @return P-Ca9分割グラフ設定情報.
   */
  public List<GraphSettingInfo> getListSysGraphSetting();
}
