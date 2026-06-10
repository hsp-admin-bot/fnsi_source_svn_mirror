package jp.co.nikkiso.ntss.m_notice.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.trigger.MntMotionTrigger;
import jp.co.nikkiso.ntss.core.trigger.OperateType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;

/**
 * 装置動作記録ServiceImpl.
 */
@Service
public class MntMotionRecordServiceImpl implements MntMotionRecordService {
  
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  @Autowired
  private MntMotionTrigger mntMotionTrigger;// add by shiyw for Trigger 20230306
  
  @Override
  public List<MntMotionRecord> selectAll() {
    List<MntMotionRecord> mntMNoticeManage = mntMotionRecordDao.selectAll();
    return mntMNoticeManage;
  }
  
  @Override
  @Transactional
  public MntMotionRecord create(MntMotionRecord mntMotionRecord) {
    mntMotionRecordDao.insert(mntMotionRecord);
    return mntMotionRecord;
  }
  
  @Override
  public MntMotionRecord findByManageNo(Long motionRecordNo) {
    return mntMotionRecordDao.selectByMotionRecordNo(motionRecordNo);
  }
  
  @Override
  @Transactional
  public void delete(Long motionRecordNo) {
    MntMotionRecord mntMotionRecord = mntMotionRecordDao.selectByMotionRecordNo(motionRecordNo);
    if(mntMotionRecord != null) {
      mntMotionRecordDao.delete(mntMotionRecord);
    }
  }
  
  @Override
  @Transactional
  public MntMotionRecord update(MntMotionRecord mntMotionRecord) {
    mntMotionRecordDao.update(mntMotionRecord);
    mntMotionTrigger.triggerMntMotionRecord(mntMotionRecord, OperateType.UPDATE); // add by shiyw for Trigger:sync_mnt_motion_record 20230228
    return mntMotionRecord;
  }

  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 start
  @Override
  public String buildMachineRecordMessage(String machineRecordMessage, String machineRecordCd, String machineRecordAuxData) {
    List<String> auxDataArray;
    auxDataArray = new ArrayList<>(Arrays.asList("", "", "", ""));
    if (!Strings.isNullOrEmpty(machineRecordAuxData)) {
      int pos = 0;
      for (int i = 0; i < auxDataArray.size(); i++) {
        int index = machineRecordAuxData.indexOf(",", pos);
        if (-1 != index) {
          auxDataArray.set(i, machineRecordAuxData.substring(pos, index));
          pos = index + 1;
        } else {
          auxDataArray.set(i, machineRecordAuxData.substring(pos));
          break;
        }
      }
    }

    String message = mntMotionRecordDao.buildMachineRecordMessage(
      machineRecordMessage,
      machineRecordCd,
      auxDataArray.get(0),
      auxDataArray.get(1),
      auxDataArray.get(2),
      auxDataArray.get(3));
    return message;
  }
  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 end
}
