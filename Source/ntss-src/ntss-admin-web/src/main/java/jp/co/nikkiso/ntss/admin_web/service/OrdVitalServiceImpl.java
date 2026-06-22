package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jp.co.nikkiso.ntss.core.dao.OrdVitalDao;
import jp.co.nikkiso.ntss.core.entity.OrdVital;


@Service
public class OrdVitalServiceImpl implements OrdVitalService {
  @Autowired
  private OrdVitalDao ordVitalDao;

  @Override
  public Page<OrdVital> findAll(Pageable pageable){
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<OrdVital> ordVitalList = ordVitalDao.selectAll(selectOptions);
    return new PageImpl<>(ordVitalList, pageable, selectOptions.getCount());
  }

  @Override
  public List<OrdVital> findByCd(String pat_id, Long ord_no, Integer edition, Short ctl_no, String dialysis_date_from, String dialysis_date_to) {
    return ordVitalDao.selectByCd(pat_id, ord_no, edition, ctl_no, dialysis_date_from, dialysis_date_to);
  }

  @Override
  @Transactional
  public OrdVital create(OrdVital m) {
    ordVitalDao.insert(m);
    return m;
  }

  @Override
  @Transactional
  public OrdVital update(OrdVital m) {
    ordVitalDao.update(m);
    return m;
  }

  @Override
  @Transactional
  public void delete(Long ord_no, Short ctl_no) {
    List<OrdVital> m = ordVitalDao.selectByCd(null, ord_no, null, ctl_no, null, null);
    if(m != null) {
      for (int i = 0; i < m.size(); i++) {
        ordVitalDao.delete(m.get(i));
      }
    }
  }
}
