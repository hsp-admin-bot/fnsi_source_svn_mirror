package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * 装置記録マスタService.
 */
@Service
public class MstMachineRecordServiceImpl implements MstMachineRecordService {
  
  @Autowired
  private MstMachineRecordDao mstMachineRecordDao;
  
  @Override
  public List<MstMachineRecord> selectAll(){
    List<MstMachineRecord> mstMachineRecordList = mstMachineRecordDao.selectAll();
    return mstMachineRecordList;
  }
  
  @Override
  @Transactional
  public MstMachineRecord create(MstMachineRecord machineRecord) {
    mstMachineRecordDao.insert(machineRecord);
    return machineRecord;
  }
  
  @Override
  public MstMachineRecord findByCd(String machineRecordCd) {
    return mstMachineRecordDao.selectByCd(machineRecordCd);
  }
  
  @Override
  public String selectMachineMessage(String machineRecordCd) {
    return mstMachineRecordDao.selectMachineRecordMessage(machineRecordCd);
  }
  
  @Override
  @Transactional
  public void delete(String machineRecordCd) {
    MstMachineRecord machineRecord = mstMachineRecordDao.selectByCd(machineRecordCd);
    if(machineRecord != null) {
      mstMachineRecordDao.delete(machineRecord);
    }
  }
  
  @Override
  @Transactional
  public MstMachineRecord update(MstMachineRecord machineRecord) {
    mstMachineRecordDao.update(machineRecord);
    return machineRecord;
  }
  
}
