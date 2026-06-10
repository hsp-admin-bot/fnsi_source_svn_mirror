package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstSeriesDao;
import jp.co.nikkiso.ntss.core.entity.MstSeries;

/**
 * 系列施設マスタService.
 */
@Service
public class MstSeriesServiceImpl implements MstSeriesService {

  @Autowired
  private MstSeriesDao mstSeriesDao;
  
  @Override
  public List<MstSeries> selectAll() {
    List<MstSeries> mstSeriesList = mstSeriesDao.selectAll();
    return mstSeriesList;
  }
  
  @Override
  @Transactional
  public MstSeries create(MstSeries mstSeries) {
    mstSeriesDao.insert(mstSeries);
    return mstSeries;
  }
  
  @Override
  public MstSeries findByCd(String seriesCd) {
    return mstSeriesDao.selectByCd(seriesCd);
  }
  
  @Override
  @Transactional
  public void delete(String seriesCd) {
    MstSeries mstSeries = mstSeriesDao.selectByCd(seriesCd);
    if (mstSeries != null) {
      mstSeriesDao.delete(mstSeries);
    }
  }
  
  @Override
  @Transactional
  public MstSeries update(MstSeries mstSeries) {
    mstSeriesDao.update(mstSeries);
    return mstSeries;
  }
  
}
