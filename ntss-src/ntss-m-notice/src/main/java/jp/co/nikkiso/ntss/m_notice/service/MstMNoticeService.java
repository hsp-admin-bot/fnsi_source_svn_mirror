package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMNotice;

/**
 * 緊急発報マスタService.
 */
public interface MstMNoticeService {
  
  List<MstMNotice> selectAll();
  
  MstMNotice findByCd(String facilityCd, String machineRecordCd);
  
  MstMNotice create(MstMNotice mstMNotice);
  
  MstMNotice update(MstMNotice mstMNotice);
  
  void delete(String facilityCd, String machineRecordCd);
  
}
