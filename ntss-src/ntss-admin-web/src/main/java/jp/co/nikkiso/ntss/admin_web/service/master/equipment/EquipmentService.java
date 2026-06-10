package jp.co.nikkiso.ntss.admin_web.service.master.equipment;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.Equipment;

public interface EquipmentService {

  /**
   * 医材リストを取得する
   * @param cd 施設コード
   * @return 医材リスト
   */
  List<Equipment> selectByCd(String cd);

  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe start
  List<Equipment> selectAllByFacilityCd(String facilityCd, String is_disp, String is_del);
  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe end
}
