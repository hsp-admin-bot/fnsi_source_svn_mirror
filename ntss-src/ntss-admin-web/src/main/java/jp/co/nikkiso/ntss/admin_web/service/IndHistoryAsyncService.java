package jp.co.nikkiso.ntss.admin_web.service;


import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IndHistoryAsyncService {
  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Async("doSomethingExecutor")
  public void createDeleteAsyncHistory(
    ApiEntityOrdMain.ValiDeleteTreatPlan bodyData,
    List<OrdMain> ordMainList,
    List<Integer> weeksArray) {

    indHistoryMakeService.createDeleteHistory(bodyData, ordMainList, weeksArray);
  }
}
