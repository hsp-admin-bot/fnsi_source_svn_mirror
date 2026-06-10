package jp.co.nikkiso.ntss.alive_moni_auto.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.alive_moni_auto.entity.MstFacilityCustom;


@ConfigAutowireable
@Dao
public interface MstFacilityCustomDao
{
	@Select
	List<MstFacilityCustom> selectAll();
}
