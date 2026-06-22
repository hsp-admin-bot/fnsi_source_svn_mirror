package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;

/**
 * 緊急発報管理マスタService.
 */
public interface MntMNoticeManageService {
  
  List<MntMNoticeManage> selectAll();
  
  MntMNoticeManage findByManageNo(Long mNoticeManageNo);
  
  MntMNoticeManage create(MntMNoticeManage mntMNoticeManage);
  
  MntMNoticeManage update(MntMNoticeManage mntMNoticeManage);
  
  void delete(Long mNoticeManageNo);
  
}
