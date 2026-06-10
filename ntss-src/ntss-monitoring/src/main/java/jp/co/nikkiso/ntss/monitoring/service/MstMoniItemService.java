package jp.co.nikkiso.ntss.monitoring.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMoniItem;

public interface MstMoniItemService {
  List<MstMoniItem> Select(String facility_cd, String model, String moni_no);
}
