package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecordControl;

/**
 * 装置記録マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMachineRecordControlDao {
  @Select
  List<MstMachineRecordControl> selectByFacility(String facilityCd, String machineRecordCd);

  @Insert(sqlFile = true)
  int insert(MstMachineRecordControl mstMachineRecordControl);

  @Update(sqlFile = true)
  int update(MstMachineRecordControl mstMachineRecordControl);

  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- start
  @Select
  String selectDispFlg(String machineRecordCd, String facilityCd);

  @Select
  String selectMachineRecordMessage(String machineRecordCd, String facilityCd);
  //add bug-No78 装置記録マスタ画面を作成して、愁訴処置に表示、愁訴処置＋レポート愁訴処置欄表示対象の装置記録を指定可能とする --趙-- end
}
