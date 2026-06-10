package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;

/**
 * デバイスエッジマスタサービス
 */
public interface MstDeviceEdgeService {
  
  List<MstDeviceEdge> selectAll();
  
  MstDeviceEdge findByEdgeNoAndFacilityCd(Integer deviceEdgeNo, String facilityCd);  
}
