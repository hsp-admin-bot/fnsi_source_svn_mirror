package jp.co.nikkiso.ntss.data_gathering.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import jp.co.nikkiso.ntss.data_gathering.entity.MntGatheringManage;


/**
 * データ収集管理Dao
 *
 */
@ConfigAutowireable
@Dao
public interface MntGatheringManageDaoDataGathering
{
	@Select
	MntGatheringManage selectMaxNo();
	
	@Select
	List<MntGatheringManage> selectById(long gatheringManageNo);
	
	@Insert(sqlFile = true)
	int insert(MntGatheringManage gatheringManage);
	
	@Update(sqlFile = true)
	int update(MntGatheringManage gatheringManage);
}
