package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;;

/**
 * 装置動作記録Service.
 */
public interface MntMotionRecordService {
  
  List<MntMotionRecord> selectAll();
  
  MntMotionRecord findByManageNo(Long motionRecordNo);
  
  MntMotionRecord create(MntMotionRecord motionRecordNo);
  
  MntMotionRecord update(MntMotionRecord motionRecordNo);
  
  void delete(Long motionRecordNo);

  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 start
  String buildMachineRecordMessage(String machineRecordMessage, String machineRecordCd, String machineRecordAuxData);
  //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 end
}
