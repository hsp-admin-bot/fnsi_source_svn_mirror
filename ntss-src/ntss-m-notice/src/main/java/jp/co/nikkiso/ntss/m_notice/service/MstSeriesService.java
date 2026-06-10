package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstSeries;

/**
 * 系列施設マスタService.
 */
public interface MstSeriesService {
  
  List<MstSeries> selectAll();
  
  MstSeries findByCd(String seriesCd);
  
  MstSeries create(MstSeries mstSeries);
  
  MstSeries update(MstSeries mstSeries);
  
  void delete(String seriesCd);

}
