package jp.co.nikkiso.ntss.data_gathering.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import jp.co.nikkiso.ntss.data_gathering.entity.MstMachine;


/**
 * 装置マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstMachineDaoDataGathering
{
	@Select
	List<MstMachine> selectById(String machineTypeCd, String machineSerial, String facilityCd, int deviceEdgeNo);
}
