package jp.co.nikkiso.ntss.device_edge.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstMachine;

/**
 * 装置マスタサービス
 */
public interface MstMachineService {

  List<MstMachine> selectAll();

  MstMachine findByCd(String machine_type_cd, String machine_serial, String facility_cd);

  List<MstMachine> findByFacility(String facility_cd);

  List<String> findByDeviceEdge(String facility_cd, int device_edge_no);

  MstMachine create(MstMachine mstMachine);

  MstMachine update(MstMachine mstMachine);

  int updateMachineOption(MstMachine param);

  void delete(String machine_type_cd, String machine_serial, String facility_cd);
}
