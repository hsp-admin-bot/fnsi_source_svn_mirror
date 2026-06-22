package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import jp.co.nikkiso.ntss.core.entity.OrdVital;

public interface OrdVitalService {

  Page<OrdVital> findAll(Pageable pageable);

  List<OrdVital> findByCd(String pat_id, Long ord_no, Integer edition, Short ctl_no, String dialysis_date_from, String dialysis_date_to);

  OrdVital create(OrdVital ordVital);

  OrdVital update(OrdVital ordVital);

  void delete(Long ord_no, Short ctl_no);
}
