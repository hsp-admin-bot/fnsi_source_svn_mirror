package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatRelated;

public interface ComsvPatRelatedService {
  ComsvPatRelated selectDialCount(Long patId);
  int updateDialStatus(ComsvPatRelated param);
  int updateDialCount(ComsvPatRelated param);
}
