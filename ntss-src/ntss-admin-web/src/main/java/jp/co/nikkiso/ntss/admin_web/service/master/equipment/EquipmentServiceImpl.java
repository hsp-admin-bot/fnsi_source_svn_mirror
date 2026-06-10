package jp.co.nikkiso.ntss.admin_web.service.master.equipment;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.entity.custom.Equipment;

/**
 * 医材フィルターに表示する医療材料を取得するクラス.
 *
 * @author Masahiro Ito
 */
@Service
public class EquipmentServiceImpl implements EquipmentService {

  @Autowired
  MstEquipmentDao mstDao;

  /* (非 Javadoc)
   * @see jp.co.nikkiso.ntss.admin_web.service.master.equipment.EquipmentService#selectByCd(java.lang.String)
   */
  @Override
  public List<Equipment> selectByCd(String cd) {
    return mstDao.selectByFacilityCd(cd);
  }

  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe start
  @Override
  public List<Equipment> selectAllByFacilityCd(String facilityCd, String is_disp, String is_del) {
    return mstDao.selectAllByFacilityCd(facilityCd, is_disp, is_del);
  }
  // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe end
}
