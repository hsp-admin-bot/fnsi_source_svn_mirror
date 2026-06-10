package jp.co.nikkiso.ntss.admin_web.service.master.facilitySetting;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.core.entity.MstFacility;


public interface MstFacilitySettingService {

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
  void saveMstFacilitySetting(Map<String, List<String>> payload) throws Exception;

  String getValueSignInByFacilityCd(String facilityCd);
}
