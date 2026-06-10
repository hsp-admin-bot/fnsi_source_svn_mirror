package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.SalSubscriptionManage;
import jp.co.nikkiso.ntss.core.entity.custom.SalSubscriptionManageCustom;

@ConfigAutowireable
@Dao
public interface SalSubscriptionManageDao {

	@Select
	List<SalSubscriptionManage> selectAll(SelectOptions options);

	@Select
	List<SalSubscriptionManage> selectByFacilityCd(SelectOptions options, String facilityCd);

	@Select
	SalSubscriptionManage selectBySubscriptionNo(Long subscriptionNo);

	@Select
	Long selectNextSeqSubscriptionNo();

	@Insert(sqlFile = true)
	int insert(SalSubscriptionManage salSub);

	@Update(include = { "subscriptionStatus", "upDate", "receptionist", "receptionDate" })
	int updateReception(SalSubscriptionManage salSub);

	@Update(include = { "subscriptionStatus", "upDate", "completer", "completeDate" })
	int updateCompletion(SalSubscriptionManage salSub);

	@Update(include = { "subscriptionStatus", "upDate", "canceller", "cancelDate" })
	int updateCancel(SalSubscriptionManage salSub);

	@Select
  List<SalSubscriptionManageCustom> selectBySearchCondition(String startDate, String endate, String prefecturesCd, String departmentCd, String freeWord, List<String> subscriptionStatusList, SelectOptions options);
}
