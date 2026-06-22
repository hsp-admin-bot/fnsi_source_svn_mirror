package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;


//@ConfigAutowireablePersonalDb
@ConfigAutowireable
@Dao
public interface WebAPICheckConditionSendDao {

  @Select
  List<String> selectMachineOptionsFromMstMachine(long ordNo);

  @Select
  List<Map<String,Object>> selectDataFromOrdMain(long ordNo);

  @Select
  List<Map<String,Object>> selectMachineTypeFromMstMachine(long ordNo);

  @Select
  List<Map<String,Object>> selectDataFromMstMachine(long ordNo);
 //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　start
  @Select
  List<Map<String,Object>> selectDataFromMstMachineByBed(String facilityCd, long indBedCd);
 //add 7579 【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧　end

  @Select
  List<Map<String,Object>> selectDataFromPatUnique(long ordNo);

  @Select
  List<Map<String,Object>> selectMachineSetting(long ordNo);

  @Select
  List<String> selectDeviceModeFromMstTreatment(long ordNo);

  @Select
  List<Map<String,Object>> selectDialyzerInfoFromMstDialyzer(int dialyzerCd);

//  @ConfigAutowireablePersonalDb
  @Select
  Map<String,Object> selectDataFromPatPersonalMain(long patId);

  @Update(sqlFile = true)
  int updateInsertSendCondData(long ordNo,String jsonCondData);

  @Update(sqlFile = true)
  int updateInsertSendCondDataByPramKey(String facilityCd, String machineTypeCd, String machineSerial,String jsonCondData);
}

