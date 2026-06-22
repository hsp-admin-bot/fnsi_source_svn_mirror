package jp.co.nikkiso.ntss.admin_web.service.master.machineRecord;

// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
import jp.co.nikkiso.ntss.core.entity.MstDisease;
// add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end

import java.util.List;
import java.util.Map;

/**
 * 装置記録マスタのServiceインタフェース.
 */
public interface MasterMachineRecordService {

void updateMasterData(Map<String, List<String>> payload) throws Exception;

  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 start
  /**
   * 病名マスタを件数取得する
   */
  String getTotal(String facilityCd);

  /**
   * 病名マスタを全件取得する.分頁
   */
  List<MstDisease> getMstDiseaseByLimitAndOffset(Integer limit, String facilityCd, Integer offset);
  // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 徐博 end

}
