package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstExamMatome;

@ConfigAutowireable
@Dao
public interface MstExamMatomeDao {
	@Select
	List<MstExamMatome> selectAll();
}
