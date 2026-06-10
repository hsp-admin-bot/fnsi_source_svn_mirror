package jp.co.nikkiso.ntss.device_edge.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.ComsvPatRelatedDao;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatRelated;

@Service
public class ComsvPatRelatedServiceImpl implements ComsvPatRelatedService {

  @Autowired
  ComsvPatRelatedDao comsvPatRelatedDao;

  @Override
  public ComsvPatRelated selectDialCount(Long patId) {
    return comsvPatRelatedDao.selectDialCount(patId);
  }

  @Override
  @Transactional
  public int updateDialStatus(ComsvPatRelated param) {
    return comsvPatRelatedDao.updateDialStatus(param);
  }

  @Override
  @Transactional
  public int updateDialCount(ComsvPatRelated param) {
    return comsvPatRelatedDao.updateDialCount(param);
  }

}
