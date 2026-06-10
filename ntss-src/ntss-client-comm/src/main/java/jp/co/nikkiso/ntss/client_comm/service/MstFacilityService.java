package jp.co.nikkiso.ntss.client_comm.service;

import jp.co.nikkiso.ntss.core.entity.MstFacility;


/**
 * 施設コード情報取得サービス
 */
public interface MstFacilityService {

  MstFacility findByFacility(String facilityCd);
}
