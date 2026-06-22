package jp.co.nikkiso.ntss.admin_web.service.mente;

import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroupByMachineType;

import java.util.List;
import java.util.Map;

/**
 * スケールベッドマスタ設定のServiceインタフェース.
 */
public interface MstWeightScaleBedService {

  void SyncScaleBedStateWithMaster(String facilityCd);
}
