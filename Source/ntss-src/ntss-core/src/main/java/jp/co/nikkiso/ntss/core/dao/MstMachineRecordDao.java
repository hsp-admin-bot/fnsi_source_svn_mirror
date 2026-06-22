package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Result;

import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * 装置記録マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstMachineRecordDao {

  @Select
  List<MstMachineRecord> selectByFacilityCd(String facilityCd);

  @Select
  MstMachineRecord selectByFacilityCdAndCd(String facilityCd, String machineRecordCd);

  @Select
  List<MstMachineRecord> selectAll();

  @Select
  MstMachineRecord selectByCd(String machineRecordCd);

  @Select
  String selectMachineRecordMessage(String machineRecordCd);

  @Insert
  Result<MstMachineRecord> insert(MstMachineRecord mstMachineRecord);

  @Delete
  Result<MstMachineRecord> delete(MstMachineRecord mstMachineRecord);

  @Update
  Result<MstMachineRecord> update(MstMachineRecord mstMachineRecord);
}
