package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import java.util.Map;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;



//@ConfigAutowireablePersonalDb
@ConfigAutowireable
@Dao
public interface DBAppWebAPIDao {
  
  @Select
  Map<String,Object> selectNameDataFromVariousTbl(long ordNo);

  @Select
  OrdMain selectByOrdNoFromOrdMain(long ord_no) ;
  
  @Select
  boolean checkPatStatusNotUnderOperation(Long ord_no,String facility_cd) ;
  
  @Select
  boolean checkOfflineOrNot(Long ord_no) ;

  @Select
  boolean checkDeviceModeIsPureOrNot(Long ord_no) ;

  @Select
  Map<String,Object> selectWardAndCourseName(String facility_cd,Integer ward_cd,Integer course_cd) ;

  @Update(excludeNull = true,sqlFile = true)
  int updateOrdMain(OrdMain ordMain) ;
  
  @Update(excludeNull = true,sqlFile = true)
  int updateMntMachineState(MntMachineState mntMachineState) ;

  @Update(sqlFile = true)
  int updateEndPlanDateOnMntMachineState(
                Long ord_no,
                String facility_cd,
                String machine_type_cd,
                String machine_serial
      ) ;
  
  @Select
  Map<String,Object> selectMedicineInfo(
      String facility_cd,
      Integer medicine_type,
      Integer cd
    );

  @Select
  String selectTimingName(
      String facility_cd,
      Integer timing_cd
    );

  @Select
  String selectProcedureName(
      String facility_cd,
      Integer procedure_cd
    );
  
  @Select
  Map<String,Object> selectEquipmentInfo(
      String facility_cd,
      Integer cd
    );

  @Select
  Map<String,Object> selectDialyzerNames(
      String facility_cd,
      Integer cd
    );

  @Select
  List<Map<String,Object>> selectNameListWithCase(
      String target,
      String facility_cd,
      List<Integer> cdList
    );
  
  
}


