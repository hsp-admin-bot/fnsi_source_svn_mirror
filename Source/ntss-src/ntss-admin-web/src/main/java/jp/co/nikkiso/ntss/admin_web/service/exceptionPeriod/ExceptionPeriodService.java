package jp.co.nikkiso.ntss.admin_web.service.exceptionPeriod;
import jp.co.nikkiso.ntss.admin_web.response.exceptionPeriod.ExceptionPeriodResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;

import java.util.List;

public interface ExceptionPeriodService {

  List<ExceptionPeriodResponse> selectOrdExceptionPeriod (String facilityCd, Long patId);

  int updateOrdExceptionPeriod (List<ExceptionPeriodResponse> exceptionPeriodList, NtssUser ntssUser);

}
