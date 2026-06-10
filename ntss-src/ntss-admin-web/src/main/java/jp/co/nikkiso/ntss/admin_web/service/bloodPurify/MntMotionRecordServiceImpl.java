package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

@Service
public class MntMotionRecordServiceImpl implements MntMotionRecordService {

  /**
   * {@inheritDoc}
   */
  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int insertMntMotion(MntMotionRecord param) {
    return mntMotionRecordDao.insertMntMotion(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int insertDarMotion(MntMotionRecord param) {
    return mntMotionRecordDao.insertDarMotion(param);
  }

  /**
   * {@inheritDoc}
   */
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

  /**
   * {@inheritDoc}
   */
  @Override
  public int insertLogMotionMessage(MntMotionRecord param) {
    return mntMotionRecordDao.insertLogMotionMessage(param);
  }

  /**
   * {@inheritDoc}
   */
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

  /**
   * {@inheritDoc}
   */
  @Override
  public int insertLogMotionMessageAndOrdNo(MntMotionRecord param) {
    return mntMotionRecordDao.insertLogMotionMessageAndOrdNo(param);
  }
}
