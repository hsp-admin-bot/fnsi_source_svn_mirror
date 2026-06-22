package jp.co.nikkiso.ntss.admin_web.service.master.favoriteFacility;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityDataT;
import jp.co.nikkiso.ntss.core.entity.custom.SysFacilityData;


public interface MstFavoriteFacilityService {

  //add by ztc 2023-03-01 [Optimize runtime No.8372] --start /
  /**
   * 全施設マスタ一覧の取得 改ページの追加
   *
   * @return 全施設マスタ一覧データ情報.
   */
  List<SysFacilityData> getSysFacilityByLimitAndOffset(Integer limit, Integer offsetIer, String prefCd, String freeWord, String selectedInsCd);
  //add by ztc 2023-03-01 [Optimize runtime No.8372] --end /

  // add FNSI-よく使う施設の変更 関 start
  List<MstFavoriteFacilityDataT> getFacilityFavoriteFacility(String facilityCd);
  // add FNSI-よく使う施設の変更 関 end
}
