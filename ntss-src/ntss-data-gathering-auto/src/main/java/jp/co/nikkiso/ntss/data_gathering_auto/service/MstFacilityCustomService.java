package jp.co.nikkiso.ntss.data_gathering_auto.service;

import java.util.List;

import jp.co.nikkiso.ntss.data_gathering_auto.entity.MstFacilityCustom;

/**
 * 施設マスタのServiceインターフェース.
 *
 */
public interface MstFacilityCustomService {
  List<MstFacilityCustom> findAll();
}
