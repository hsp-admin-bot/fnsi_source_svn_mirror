package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;

/**
 * 型式マスタService.
 */
@Service
public class MstMachineTypeServiceImpl implements MstMachineTypeService {

  @Autowired
  private MstMachineTypeDao mstMachineTypeDao;
  
  @Override
  public List<MstMachineType> selectAll() {
    List<MstMachineType> mstMachineTypeList = mstMachineTypeDao.selectAll();
    return mstMachineTypeList;
  }
  
  @Override
  public MstMachineType findByTypeCd(String machineTypeCd) {
    return mstMachineTypeDao.selectByTypeCd(machineTypeCd);
  }
  
  @Override
  @Transactional
  public MstMachineType create(MstMachineType mstMachineType) {
    mstMachineTypeDao.insert(mstMachineType);
    return mstMachineType;
  }
  
  @Override
  @Transactional
  public MstMachineType update(MstMachineType mstMachineType) {
    mstMachineTypeDao.update(mstMachineType);
    return mstMachineType;
  }
  
  @Override
  @Transactional
  public void delete(String machineTypeCd) {
    MstMachineType mstMachineType = mstMachineTypeDao.selectByTypeCd(machineTypeCd);
    if(mstMachineType != null) {
      mstMachineTypeDao.delete(mstMachineType);
    }
  }
  
}
