package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

// import jp.co.nikkiso.ntss.core.entity.custom.IndHistory;
// import jp.co.nikkiso.ntss.core.entity.custom.IndHistoryOptions;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryOptions;

public interface IndHistoryServiceDynamo {
  Page<IndHistory> findAll(Pageable pageable, IndHistory params, IndHistoryOptions options);
  IndHistory create(IndHistory params);
}
