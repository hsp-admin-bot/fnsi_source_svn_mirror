package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstArea;

/**
 * 地域マスタService.
 */
public interface MstAreaService {

  List<MstArea> selectAll();
  
  MstArea findByCd(String areaCd);
  
  MstArea create(MstArea mstArea);
  
  MstArea update(MstArea mstArea);
  
  void delete(String areaCd);
  
}
