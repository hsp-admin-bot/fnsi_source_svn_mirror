package jp.co.nikkiso.ntss.device_edge.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

@Service
public class MntMotionRecordServiceImpl implements MntMotionRecordService {

  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  @Override
  @Transactional
  public int insertMntMotion(MntMotionRecord param) {
    return mntMotionRecordDao.insertMntMotion(param);
  }

  @Override
  @Transactional
  public int insertDarMotion(MntMotionRecord param) {
    return mntMotionRecordDao.insertDarMotion(param);
  }

  @Override
  public int insertLogMotion(MntMotionRecord param,
      String aux_data_array_0,
      String aux_data_array_1,
      String aux_data_array_2,
      String aux_data_array_3) {
    return mntMotionRecordDao.insertLogMotion(param,
        aux_data_array_0,
        aux_data_array_1,
        aux_data_array_2,
        aux_data_array_3);
  }

  //add #269:強制オフライン 劉 start
  @Override
  public int insertLogMotionAndOrdNo(MntMotionRecord param,
     String aux_data_array_0,
     String aux_data_array_1,
     String aux_data_array_2,
     String aux_data_array_3) {
    return mntMotionRecordDao.insertLogMotionAndOrdNo(param,
      aux_data_array_0,
      aux_data_array_1,
      aux_data_array_2,
      aux_data_array_3);
  }
  //add #269:強制オフライン 劉 end

  @Override
  public int insertLogMotionMessage(MntMotionRecord param) {
    return mntMotionRecordDao.insertLogMotionMessage(param);
  }

  //add #269:強制オフライン 劉 start
  @Override
  public int insertLogMotionMessageAndOrdNo(MntMotionRecord param) {
    return mntMotionRecordDao.insertLogMotionMessageAndOrdNo(param);
  }
  //add #269:強制オフライン 劉 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  @Override
  public int insertLogMotionMessageCommFail(MntMotionRecord param) {
    return mntMotionRecordDao.insertLogMotionMessageCommFail(param);
  }

  @Override
  public int insertLogMotionCommFail(MntMotionRecord param,
                             String aux_data_array_0,
                             String aux_data_array_1,
                             String aux_data_array_2,
                             String aux_data_array_3) {
    return mntMotionRecordDao.insertLogMotionCommFail(param,
      aux_data_array_0,
      aux_data_array_1,
      aux_data_array_2,
      aux_data_array_3);
  }
  // add AWSとDEの通信断からの復旧 --趙-- start

}
