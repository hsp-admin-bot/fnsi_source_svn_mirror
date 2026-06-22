package jp.co.nikkiso.ntss.m_notice.service;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.AliveMoniDeviceEdgeAlarmCode;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.AliveMoniSendMailStatus;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MntDeviceEdgeStateServiceImpl implements MntDeviceEdgeStateService {

  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntDeviceEdgeState> selectByKey(String facilityCd, Integer deviceEdgeNo) {
    return mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, deviceEdgeNo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateSendMailStatus(MntDeviceEdgeState mntDeviceEdgeState) {
    return mntDeviceEdgeStateDao.updateSendMailStatus(mntDeviceEdgeState);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateSendMailFinish(MntMotionRecord mntMotionRecord) {
    if (AliveMoniDeviceEdgeAlarmCode.CONNECT_ERROR.equals(mntMotionRecord.getMachineRecordCd()) ||
      AliveMoniDeviceEdgeAlarmCode.DEVICE_ERROR.equals(mntMotionRecord.getMachineRecordCd()) ||
      AliveMoniDeviceEdgeAlarmCode.RECONNECT.equals(mntMotionRecord.getMachineRecordCd())) {
      // G000,G001,G005のいずれかであるならば、状態の更新をする
      List<MntDeviceEdgeState> state = selectByKey(mntMotionRecord.getFacilityCd(), mntMotionRecord.getDeviceEdgeNo());
      if (state == null || state.size() == 0) {
        // 対象デバイスエッジなしなので処理を終了する
        return 0;
      }
      // メール送信済みと更新して処理を終了する
      MntDeviceEdgeState newState = state.get(0);
      newState.setSendMailStatus(AliveMoniSendMailStatus.NO_SEND);

      return updateSendMailStatus(newState);
    }
    return 0;
  }
}
