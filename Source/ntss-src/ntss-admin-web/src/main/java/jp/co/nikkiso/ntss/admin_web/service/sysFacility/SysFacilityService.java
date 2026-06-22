package jp.co.nikkiso.ntss.admin_web.service.sysFacility;

import jp.co.nikkiso.ntss.core.entity.SysFacility;

import java.util.List;

/**
 * @ClassName： SysFacilityService
 * @Decscript: #11871 iPhone側のメモリが大きいためにシステムが登録されている問題を処理する、新しいインタフェース
 * @Author: chamaojia
 * @Date: 2025/05/21
 */
public interface SysFacilityService {

  // cdによるすべてのデータの取得
  SysFacility getSysFacilityByCd(String cd);

  List<SysFacility> getSysFacilityByCdList(List<String> cdList);

  SysFacility getSysFacilityByFacilityCd(String facilityCd);
}
