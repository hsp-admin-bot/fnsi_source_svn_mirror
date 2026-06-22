package jp.co.nikkiso.ntss.admin_web.service.master.weight;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.MstWeightExamResponse;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;

public interface MstWeightService {

  List<MstWeightExamResponse> fetchMstExamItemList(String facilityCd);

  List<MstWeight> mstWeightSelectByFacilityCd(String facilityCd);

  MstWeight mstWeightSelectByScaleCd(Long weightCd);

  MstWeight mstWeightSelectByFacilityCdWeightNo(String facilityCd, int weightNo);

  int mstWeightInsert(MstWeight param);

  int mstWeightUpdate(MstWeight param);

  int mstWeightUpdateCheckContent(Long weightCd, String checkContent);

  int mstWeightUpdatePrintSetting(Long weightCd, String printSetting);

  int mstWeightUpdateColorSetting(Long weightCd, String colorSetting);

  int mstWeightUpdateAudioSetting(Long weightCd, String audioSetting);

  MstWeightScale mstWeightScaleSelectByFacility(String facilityCd);

  int mstWeightScaleInsert(MstWeightScale param);

  int mstWeightScaleUpdate(MstWeightScale param);

  /**
   * 体重測定マスタのマスタメンテナンス用取得関数
   * @param masterName
   * @param facilityCd
   * @return
   */
  public MasterDataResponse getMasterData(String masterName, String facilityCd);
  /**
   * 体重測定マスタのマスタメンテナンス用更新関数
   * @param masterPhysicalName
   * @param facilityCd
   * @param updateData
   * @return
   */
  public MasterUpdateResponse updateMasterData(String masterPhysicalName, String facilityCd,
      List<Map<String, Object>> updateData);

  // #11987 2025.12.10 add スケールベッド対応 ベッドマスター取得 TDC渡辺 start
  List<MstSelector.Item> fetchMstBedList(String facilityCd);
  // #11987 2025.12.10 add スケールベッド対応 ベッドマスター取得 TDC渡辺 end
}
