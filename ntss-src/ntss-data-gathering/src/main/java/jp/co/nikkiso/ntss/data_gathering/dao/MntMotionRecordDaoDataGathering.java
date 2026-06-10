package jp.co.nikkiso.ntss.data_gathering.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.data_gathering.entity.MntMotionRecord;


@ConfigAutowireable
@Dao
public interface MntMotionRecordDaoDataGathering
{
	@Select
	MntMotionRecord selectMaxNo();
	
	@Insert(sqlFile = true)
	int insert(MntMotionRecord motionRecord);
}
