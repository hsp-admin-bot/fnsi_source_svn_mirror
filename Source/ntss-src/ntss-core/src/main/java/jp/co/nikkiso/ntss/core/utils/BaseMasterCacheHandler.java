package jp.co.nikkiso.ntss.core.utils;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.EquipCodeAndType;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.util.Assert;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * The class is used to temporarily cache masters data to ThreadLocal of the current request thread,
 * to avoid frequent queries of the same xxxMasterCode from the DB, such as in "for each" code.
 *
 * The design idea is: when a masterCode is accessed for the first time, the corresponding master data is loaded from the DB and put into the cache.
 * When it is accessed for the second time, it is directly obtained from the cache.
 *
 * Note:When will the cache be removed?
 * after completion of request processing (Use the SpringMvc HandlerInterceptor), see the class MasterCacheHandlerInterceptor
 *
 * Use example:
 *  MstEquipment mstEquipment = MasterCacheHandler.get().getEquipmentByCd(equipmentCd);
 */
public class BaseMasterCacheHandler {

  private static final InheritableThreadLocal<BaseMasterCacheHandler> masterCache = new InheritableThreadLocal<>();

  public static BaseMasterCacheHandler get(){
    if(masterCache.get() == null){
      BaseMasterCacheHandler masterCacheHandler = new BaseMasterCacheHandler();
      masterCache.set(masterCacheHandler);
    }
    return masterCache.get();
  }

  public static void clearCache(){
    if(masterCache.get() != null){
      masterCache.remove();
    }
  }

  // Map<equipmentCd,MstEquipment>
  private final Map<Integer, MstEquipment>  mstEquipmentMap = new ConcurrentHashMap<>();

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  private final Map<Integer,MstEquipment>  mstEquipmentIncludeDelMap = new ConcurrentHashMap<>();
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  // Map<equipmentClassCd,MstEquipmentClass>
  private final Map<Integer, MstEquipmentClass>  mstEquipmentClassMap = new ConcurrentHashMap<>();

  // Map<medicateTimingCd,MstMedicateTiming>
  private final Map<Integer, MstMedicateTiming>  mstMedicateTimingMap = new ConcurrentHashMap<>();

  // Map<medicineMixCd,MstMedicineMix>
  private final Map<Integer, MstMedicineMix>  mstMedicineMixMap = new ConcurrentHashMap<>();

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  private final Map<Integer, MstMedicineMix>  mstMedicineMixIncludeDelMap = new ConcurrentHashMap<>();
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  // Map<medicineClassCd,MstMedicineClass>
  private final Map<Integer, MstMedicineClass>  mstMedicineClassMap = new ConcurrentHashMap<>();

  // Map<procedureCd,MstProcedure>
  private final Map<Integer, MstProcedure>  mstProcedureMap = new ConcurrentHashMap<>();

  // Map<procedureCd,MstMedicine>
  private final Map<Integer, MstMedicine>  mstMedicineMap = new ConcurrentHashMap<>();

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  private final Map<Integer, MstMedicine>  mstMedicineIncludeDelMap = new ConcurrentHashMap<>();
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  // Map<facilitySettingNo,FacilitySettingInfo>
  private final Map<String, FacilitySettingInfo>  facilitySettingInfoMap = new ConcurrentHashMap<>();

  // Map<userId,MstPersonalUser>
  private final Map<Long, MstPersonalUser>  mstPersonalUserMap = new ConcurrentHashMap<>();

  // Map<facilitySettingNo,List<MstTreatment>>
  private final Map<String, List<MstTreatment>>  mstTreatmentInfoMap = new ConcurrentHashMap<>();

  // Map<facilitySettingNo,List<MstKur>>
  private final Map<String, List<MstKur>>  mstKurInfoMap = new ConcurrentHashMap<>();

  // Map<Long, OrdMain>
  private final Map<Long, OrdMain>  ordMainInfoMap = new ConcurrentHashMap<>();

  //Map<String, List<MstMachine>>
  private final Map<String, List<MstMachine>>  machinesInfoMap = new ConcurrentHashMap<>();

  //Map<String, ComsvMntMachineState>
  private final Map<String, ComsvMntMachineState>  comsvMntMachineStateInfoMap = new ConcurrentHashMap<>();

  //Map<Long, List<MntMachineState>>
  private final Map<Long, List<MntMachineState>>  mntMachineStateInfoMap = new ConcurrentHashMap<>();

  //Map<String, List<MstBed>>
  private final Map<String, List<MstBed>>  mntBedInfoMap = new ConcurrentHashMap<>();
  // ------ MstEquipment info cache ----- start
// ADD 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
  private final Map<Integer, MstDialyzer>  mstDialyzerMap = new ConcurrentHashMap<>();
// ADD 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou END
  /**
   * get MstPersonalUser info
   * @param userId
   * @return
   */
  public MstPersonalUser getMstPersonalUser(Long userId){
    MstPersonalUserDao mstPersonalUserDao = AppContextUtils.getBean(MstPersonalUserDao.class);
    if(!mstPersonalUserMap.containsKey(userId)){
      MstPersonalUser mstPersonalUser = mstPersonalUserDao.selectById(userId);
      if(mstPersonalUser !=null){
        mstPersonalUserMap.put(userId,mstPersonalUser);
      }else{
        return null;
      }
    }
    return mstPersonalUserMap.get(userId);
  }

  /**
   * batch load MstEquipments to cache mstEquipmentMap
   * @param equipmentCds
   */
  // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
  public void loadEquipmentMap(List<EquipCodeAndType> equipmentCds, boolean isLoadEquipClassInfo){
    //public void loadEquipmentMap(List<Integer> equipmentCds,boolean isLoadEquipClassInfo){
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    List<Integer> equipCodeList = new ArrayList<>(); // 医療材料
    List<Integer> dialyzerCodeList = new ArrayList<>(); // タイアライザ
    for (EquipCodeAndType equipCodeAndType : equipmentCds) {
      if ("0".equals(equipCodeAndType.getEquipType())) {
        equipCodeList.add(equipCodeAndType.getEquipmentCd());
      } else if ("1".equals(equipCodeAndType.getEquipType())){
        dialyzerCodeList.add(equipCodeAndType.getEquipmentCd());
      }
    }
    // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    MstEquipmentDao mstEquipDao = AppContextUtils.getBean(MstEquipmentDao.class);
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    //List<MstEquipment> equipmentList = mstEquipDao.selectByCdList(SelectOptions.get(),equipmentCds);
    List<MstEquipment> equipmentList = mstEquipDao.selectByCdList(SelectOptions.get(),equipCodeList);
    // mod 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
    List<Integer> classCds = new ArrayList<>();
    for (MstEquipment equipment: equipmentList) {
      if(isLoadEquipClassInfo && equipment.getClassCd() != null){
        classCds.add(equipment.getClassCd());
      }
      mstEquipmentMap.put(equipment.getEquipmentCd(),equipment);
    }
    if(isLoadEquipClassInfo){
      loadEquipmentClassMap(classCds);
    }
    // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start
    MstDialyzerDao dialyzerDao = AppContextUtils.getBean(MstDialyzerDao.class);
    List<MstDialyzer> dialyzerList = dialyzerDao.selectAllByCdList(SelectOptions.get(),dialyzerCodeList);
    for (MstDialyzer dialyzer: dialyzerList) {
      mstDialyzerMap.put(dialyzer.getDialyzerCd(),dialyzer);
    }
    // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
  }
  /**
   * get Equipment info
   * @param equipmentCd
   * @return
   */
  public MstEquipment getEquipmentByCd(Integer equipmentCd){
    MstEquipmentDao mstEquipDao = AppContextUtils.getBean(MstEquipmentDao.class);
    if(!mstEquipmentMap.containsKey(equipmentCd)){
      MstEquipment equipment = mstEquipDao.selectByEquipmentCd(equipmentCd);
      //mod equipmentCd存在しない場合のnullpointerexceptionの解決(#8186の検証にて発見)  ljx start
      if(equipment !=null){
        mstEquipmentMap.put(equipment.getEquipmentCd(),equipment);
      }else{
        return null;
      }
      //mod equipmentCd存在しない場合のnullpointerexceptionの解決(#8186の検証にて発見) ljx end
    }
    return mstEquipmentMap.get(equipmentCd);
  }
  // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou start

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  /**
   * get Equipment info include del
   * @param equipmentCd
   * @return
   */
  public MstEquipment getEquipmentIncludeDelByCd(Integer equipmentCd){
    MstEquipmentDao mstEquipDao = AppContextUtils.getBean(MstEquipmentDao.class);
    if(!mstEquipmentIncludeDelMap.containsKey(equipmentCd)){
      MstEquipment equipment = mstEquipDao.selectByEquipmentIncludeDelByCd(equipmentCd);
      if(equipment !=null){
        mstEquipmentIncludeDelMap.put(equipment.getEquipmentCd(),equipment);
      }else{
        return null;
      }
    }
    return mstEquipmentIncludeDelMap.get(equipmentCd);
  }
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  /**
   * get MstDialyzer info
   * @param dialyzerCd
   * @return
   */
  public MstDialyzer getDialyzerCd(Integer dialyzerCd){
    MstDialyzerDao dialyzerDao = AppContextUtils.getBean(MstDialyzerDao.class);
    if(!mstDialyzerMap.containsKey(dialyzerCd)){
      MstDialyzer mstDialyzer = dialyzerDao.selectByDialyzerCd(SelectOptions.get(), dialyzerCd);
      if(mstDialyzer !=null){
        mstDialyzerMap.put(mstDialyzer.getDialyzerCd(),mstDialyzer);
      }else{
        return null;
      }
    }
    return mstDialyzerMap.get(dialyzerCd);
  }
  // add 8520 患者経過総合ビューアで、医療材料にタイアライザを追加後、500エラーが現れ、共通ローダーが解除されない。zhou end
  /**
   * batch load MstEquipmentClass to cache mstEquipmentClassMap
   * @param classCds
   */
  public void loadEquipmentClassMap(List<Integer> classCds){
    MstEquipmentClassDao mstEquipClassDao = AppContextUtils.getBean(MstEquipmentClassDao.class);
    List<MstEquipmentClass> equipmentClassList = mstEquipClassDao.selectByCdList(classCds);
    for (MstEquipmentClass equipmentClass: equipmentClassList) {
      mstEquipmentClassMap.put(equipmentClass.getClassCd(),equipmentClass);
    }
  }

  /**
   * get EquipmentClass info
   * @param classCd
   * @return
   */
  public MstEquipmentClass getEquipmentClassByCd(Integer classCd){
    /* modify by chamaojia 2023-04-12 [8564] NULL処理の追加 -- start */
    if (classCd == null || classCd == -1) {
      return null;
    }
    MstEquipmentClassDao mstEquipClassDao = AppContextUtils.getBean(MstEquipmentClassDao.class);
    if(!mstEquipmentClassMap.containsKey(classCd)){
      MstEquipmentClass equipmentClass = mstEquipClassDao.selectByCd(classCd);
      if (equipmentClass == null) {
        return null;
      }
      mstEquipmentClassMap.put(equipmentClass.getClassCd(),equipmentClass);
    }
    /* modify by chamaojia 2023-04-12 [8564] NULL処理の追加 -- end */
    return mstEquipmentClassMap.get(classCd);
  }
  // ------ MstEquipment info cache ----- end


  /**
   * batch load MstMedicateTiming to cache mstMedicateTimingMap
   * @param medicineCds
   */
  public void loadMstMedicateMap(List<Integer> medicineCds){
    MstMedicineDao mstMedicineDao = AppContextUtils.getBean(MstMedicineDao.class);
    List<MstMedicine> dataList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), medicineCds);
    for (MstMedicine obj: dataList) {
      mstMedicineMap.put(obj.getMedicineCd(),obj);
    }
  }

  /* add by chamaojia 2024-01-23 [10196]  Query of newly added concocting agents --start */
  /**
   * batch load MstMedicineMix to cache mstMedicineMixMap
   * @param medicineMixCds
   */
  public void loadMstMedicineMixMap(List<Integer> medicineMixCds) {
    MstMedicineMixDao mstMedicineMixDao = AppContextUtils.getBean(MstMedicineMixDao.class);
    List<MstMedicineMix> dataList = mstMedicineMixDao.selectByMedicineMixCdList2(medicineMixCds);
    for (MstMedicineMix obj: dataList) {
      mstMedicineMixMap.put(obj.getMedicineMixCd(), obj);
    }
  }
  /* add by chamaojia 2024-01-23 [10196]  Query of newly added concocting agents --end */

  /**
   * get EquipmentClass info
   * @param medicateTimingCd
   * @return
   */
  public MstMedicateTiming getMstMedicateTimingByCd(Integer medicateTimingCd){
    MstMedicateTimingDao mstMedicateTimingDao = AppContextUtils.getBean(MstMedicateTimingDao.class);
    if(!mstMedicateTimingMap.containsKey(medicateTimingCd)){
      MstMedicateTiming obj = mstMedicateTimingDao.selectByMedicateTimingCd(medicateTimingCd);
      mstMedicateTimingMap.put(medicateTimingCd,obj);
    }
    return mstMedicateTimingMap.get(medicateTimingCd);
  }


  /**
   * get MstMedicineMix info
   * @param medicineMixCd
   * @return
   */
  public MstMedicineMix getMstMedicineMixByCd(Integer medicineMixCd){
    MstMedicineMixDao mstMedicineMixDao = AppContextUtils.getBean(MstMedicineMixDao.class);
    if(!mstMedicineMixMap.containsKey(medicineMixCd)){
      MstMedicineMix obj = mstMedicineMixDao.selectByMedicineMixCd(medicineMixCd);
      mstMedicineMixMap.put(medicineMixCd,obj);
    }
    return mstMedicineMixMap.get(medicineMixCd);
  }

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  /**
   * get MstMedicineMix info include del
   * @param medicineMixCd
   * @return
   */
  public MstMedicineMix getMstMedicineMixIncludeDelByCd(Integer medicineMixCd){
    MstMedicineMixDao mstMedicineMixDao = AppContextUtils.getBean(MstMedicineMixDao.class);
    if(!mstMedicineMixIncludeDelMap.containsKey(medicineMixCd)){
      MstMedicineMix obj = mstMedicineMixDao.selectByMedicineMixIncludeDelByCd(medicineMixCd);
      mstMedicineMixIncludeDelMap.put(medicineMixCd,obj);
    }
    return mstMedicineMixIncludeDelMap.get(medicineMixCd);
  }
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  /**
   * get MstMedicineClass info
   * @param medicineClassCd
   * @return
   */
  public MstMedicineClass getMstMedicineClassByCd(Integer medicineClassCd){
    /* modify by chamaojia 2023-04-12 [8564] NULL処理の追加 -- start */
    if (medicineClassCd == null || medicineClassCd == -1) {
      return null;
    }
    MstMedicineClassDao mstMedicineClassDao = AppContextUtils.getBean(MstMedicineClassDao.class);
    if(!mstMedicineClassMap.containsKey(medicineClassCd)){
      MstMedicineClass obj = mstMedicineClassDao.selectByCd(medicineClassCd);
      if (obj == null) {
        return null;
      }
      mstMedicineClassMap.put(medicineClassCd,obj);
    }
    /* modify by chamaojia 2023-04-12 [8564] NULL処理の追加 -- end */
    return mstMedicineClassMap.get(medicineClassCd);
  }


  /**
   * get MstProcedure info
   * @param procedureCd
   * @return
   */
  public MstProcedure getMstProcedureByCd(Integer procedureCd){
    MstProcedureDao mstProcedureDao = AppContextUtils.getBean(MstProcedureDao.class);
    if(!mstProcedureMap.containsKey(procedureCd)){
      MstProcedure obj = mstProcedureDao.selectByProcedureCd(procedureCd);
      mstProcedureMap.put(procedureCd,obj);
    }
    return mstProcedureMap.get(procedureCd);
  }

  /**
   * get MstMedicine info
   * @param medicineCd
   * @return
   */
  public MstMedicine getMstMedicineByCd(Integer medicineCd){
    MstMedicineDao mstMedicineDao = AppContextUtils.getBean(MstMedicineDao.class);
    if(!mstMedicineMap.containsKey(medicineCd)){
      MstMedicine obj = mstMedicineDao.selectByMediCd(medicineCd);
      mstMedicineMap.put(medicineCd,obj);
    }
    return mstMedicineMap.get(medicineCd);
  }

  //add #10196 Ord_Material_Save operation 20240126 ztc start
  /**
   * get MstMedicine info include del
   * @param medicineCd
   * @return
   */
  public MstMedicine getMstMedicineIncludeDelByCd(Integer medicineCd){
    MstMedicineDao mstMedicineDao = AppContextUtils.getBean(MstMedicineDao.class);
    if(!mstMedicineIncludeDelMap.containsKey(medicineCd)){
      MstMedicine obj = mstMedicineDao.selectIncludeDelByMediCd(medicineCd);
      mstMedicineIncludeDelMap.put(medicineCd,obj);
    }
    return mstMedicineIncludeDelMap.get(medicineCd);
  }
  //add #10196 Ord_Material_Save operation 20240126 ztc end

  /**
   * get FacilitySettingInfo info
   * @param facilitySettingNo
   * @return
   */
  public FacilitySettingInfo getFacilitySettingInfo(String facilityCd,String facilitySettingNo){
    MstFacilitySettingDao mstFacilitySettingDao = AppContextUtils.getBean(MstFacilitySettingDao.class);
    String key = facilityCd + ":" + facilitySettingNo;
    if(!facilitySettingInfoMap.containsKey(key)){
      List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(facilityCd, facilitySettingNo);
      if (facilitySettingInfos != null) {
        facilitySettingInfoMap.put(key,facilitySettingInfos.get(0));
      }
    }
    return facilitySettingInfoMap.get(key);
  }

  /**
   * get MstTreatmentInfo info
   * @param facilityCd
   * @return
   */
  public List<MstTreatment> getMstTreatmentInfo(String facilityCd){
    MstTreatmentDao mstTreatmentDao = AppContextUtils.getBean(MstTreatmentDao.class);
    if(facilityCd == null){
      Assert.isNull(facilityCd,"facilityCd can not be null");
    }
    if(!mstTreatmentInfoMap.containsKey(facilityCd)){
      //マスタ取得用パラメータに施設コードを設定
      MstTreatment mstTreatment = new MstTreatment();
      mstTreatment.setFacilityCd(facilityCd);
      //マスタ取得処理
      SelectOptions selectOptions = SelectOptions.get();
      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions, mstTreatment);
      if (mstTreatmentList.size() > 0) {
        mstTreatmentInfoMap.put(facilityCd,mstTreatmentList);
      }
    }
    return mstTreatmentInfoMap.get(facilityCd);
  }

  /**
   * get MstTreatmentInfo info
   * @param facilityCd
   * @return
   */
  public List<MstKur> getMstKurInfo(String facilityCd){
    MstKurDao mstKurDao = AppContextUtils.getBean(MstKurDao.class);
    if(facilityCd == null){
      Assert.isNull(facilityCd,"facilityCd can not be null");
    }
    if(!mstKurInfoMap.containsKey(facilityCd)){
      SelectOptions selectOptions = SelectOptions.get();
      List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(selectOptions, facilityCd, "0");
      if (mstKurList.size() > 0) {
        mstKurInfoMap.put(facilityCd,mstKurList);
      }
    }
    return mstKurInfoMap.get(facilityCd);
  }


  /**
   * get ordMainInfo info
   * @param ordNo
   * @return
   */
  public OrdMain getOrdMainInfo(Long ordNo){
    OrdMainDao ordMainDao = AppContextUtils.getBean(OrdMainDao.class);
    if(!ordMainInfoMap.containsKey(ordNo)){
      if(ordNo != null){
        OrdMain ordMain =  ordMainDao.selectByOrdNo(ordNo);
        if (ordMain != null) {
          ordMainInfoMap.put(ordNo,ordMain);
        }
      }
    }
    return ordMainInfoMap.get(ordNo);
  }

  /**
   * set ordMainInfo info
   * @param ordMainMap
   * @return
   */
  public void setOrdMainInfo(Map<Long, OrdMain>  ordMainMap){
    for(Long key : ordMainMap.keySet()){
      ordMainInfoMap.put(key,ordMainMap.get(key));
    }
  }

  /**
   * get machinesInfoInfo info
   * @param facilityCd
   * @return
   */
  public List<MstMachine> getMachinesInfo(String facilityCd, Long bedCd){
    MstMachineDao mstMachineDao = AppContextUtils.getBean(MstMachineDao.class);
    if(facilityCd == null){
      Assert.isNull(facilityCd,"facilityCd can not be null");
    }
    if(!machinesInfoMap.containsKey(facilityCd+"-"+bedCd)){
      List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
      if (machines.size() > 0) {
        machinesInfoMap.put(facilityCd+"-"+bedCd,machines);
      }
    }
    return machinesInfoMap.get(facilityCd+"-"+bedCd);
  }

  /**
   * get ComsvMntMachineState info
   * @param facilityCd
   * @return
   */
  public ComsvMntMachineState getComsvMntMachineStateInfo(String facilityCd, String machineTypeCd, String machineSerial){
    MntMachineStateDao mntMachineStateDao = AppContextUtils.getBean(MntMachineStateDao.class);
    if(facilityCd == null){
      Assert.isNull(facilityCd,"facilityCd can not be null");
    }
    if(!comsvMntMachineStateInfoMap.containsKey(facilityCd+"-"+machineTypeCd+"-"+machineSerial)){
      ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd, machineTypeCd, machineSerial);
      if (machineState != null) {
        comsvMntMachineStateInfoMap.put(facilityCd+"-"+machineTypeCd+"-"+machineSerial,machineState);
      }
    }
    return comsvMntMachineStateInfoMap.get(facilityCd+"-"+machineTypeCd+"-"+machineSerial);
  }

  /**
   * get MntMachineStateInfo info
   * @param bedCd
   * @return
   */
  public List<MntMachineState> getMntMachineStateInfo(Long bedCd){
    MntMachineStateDao mntMachineStateDao = AppContextUtils.getBean(MntMachineStateDao.class);
    if(!mntMachineStateInfoMap.containsKey(bedCd)){
      List<MntMachineState> machineStateList = mntMachineStateDao.selectByBedCd(bedCd);
      if (machineStateList.size() > 0) {
        mntMachineStateInfoMap.put(bedCd,machineStateList);
      }
    }
    return mntMachineStateInfoMap.get(bedCd);
  }

  /**
   * get mntBedInfoInfo info
   * @param facilityCd
   * @return
   */
  public List<MstBed> getMstBedInfo(String facilityCd){
    MstBedDao mstBedDao = AppContextUtils.getBean(MstBedDao.class);
    if(facilityCd == null){
      Assert.isNull(facilityCd,"facilityCd can not be null");
    }
    if(!mntBedInfoMap.containsKey(facilityCd)){
      SelectOptions selectOptions = SelectOptions.get();
      List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(selectOptions, facilityCd, "1", "0");
      if (mstBedList.size() > 0) {
        mntBedInfoMap.put(facilityCd,mstBedList);
      }
    }
    return mntBedInfoMap.get(facilityCd);
  }

}
