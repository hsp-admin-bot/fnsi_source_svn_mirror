package jp.co.nikkiso.ntss.admin_web.service.reportDesigner;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.core.dao.MstWaterSurveyPointDao;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.beans.BeanUtils;
import org.json.JSONArray;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.MedicineDto;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.PatEventCategoryDto;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.ReceiptDto;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstPatEventSubCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteCategoryDao;
import jp.co.nikkiso.ntss.core.dao.MstMenteDetailDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.custom.Equipment;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryAndDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;
import jp.co.nikkiso.ntss.core.entity.MstMenteCategory;
import jp.co.nikkiso.ntss.core.entity.custom.CategoryDetailResult;
import jp.co.nikkiso.ntss.core.entity.custom.DetailResult;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ReportDesignerServiceImpl implements ReportDesignerService {

  @Autowired
  MstSelectorDao mstSelectorDao;
  @Autowired
  MstPatEventCategoryDao mstPatEventCategoryDao;
  @Autowired
  MstPatEventSubCategoryDao mstPatEventSubCategoryDao;
  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  MstMedicineMixDao mstMedicineMixDao;
  @Autowired
  MstMedicineClassDao mstMedicineClassDao;
  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
  @Autowired
  MstEquipmentDao mstEquipmentDao;
  @Autowired
  MstDialysisDifficultyDao mstDialysisDifficultyDao;
  @Autowired
  MstAdditionDao mstAdditionDao;
  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
  @Autowired
  SysSystemDefineDao sysSystemDefineDao;
  @Autowired
  MstReportDao mstReportDao;
  @Autowired
  ReportS3Service reportS3Service;

  @Autowired
  private LogService logService;

  /* add by yuqinlong  2023-01-31 [Variable]  start */
  /**
   * SysDataSetから帳票出力情報を取得するServiceインタフェース.
   */
  @Autowired
  private SysDataSetService sysDataSetService;
  /* add by yuqinlong  2023-01-31 [Variable]  end */

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Item> getMaster(String facilityCd, String tableName) {
	EventLogMessage eventLogMessage = new EventLogMessage();
    if (tableName == null || tableName.isEmpty()) {
      eventLogMessage.setLogMessage("tableName is error string");
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ArrayList<Item>();
    }

    if (!tableName.startsWith("mst_")) {
      tableName = "mst_" + tableName;
    }

    // mst_selectorの情報を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, tableName);
    if (Objects.isNull(mstSelector)) {
      eventLogMessage.setLogMessage("mst_selector[" + tableName + "] is null");
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ArrayList<Item>();
    }

    List<MstSelector.Item> orderSettingItems = mstSelector.getOrderSettings().getItems();
    if (orderSettingItems.isEmpty()) {
      eventLogMessage.setLogMessage("mst_selector[" + tableName + "] is null");
      logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      return new ArrayList<Item>();
    }
    return orderSettingItems;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatEventCategoryDto> getPatEventCategory(String facilityCd) {
    List<MstPatEventCategory> category = selectPatEventCategory(facilityCd);
    List<MstPatEventSubCategory> subCategory = selectPatEventSubCategory(facilityCd);

    List<PatEventCategoryDto> ret = new ArrayList<>();

    // ソートされた患者イベントカテゴリにサブカテゴリをソート順にセットする
    for (MstPatEventCategory cat : category) {
      // カテゴリコードが一致するサブカテゴリをソート順に追加する
      // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe start
      boolean bHaveSub = false;
      // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe end
      for (MstPatEventSubCategory sub : subCategory) {
        if (Objects.equals(sub.getCategoryCd(), cat.getCategoryCd())) {
          PatEventCategoryDto dto = new PatEventCategoryDto();
          dto.categoryCd = cat.getCategoryCd();
          dto.categoryName = cat.getCategoryName();
          dto.subCategoryCd = sub.getSubCategoryCd();
          dto.subCategoryName = sub.getSubCategoryName();
          ret.add(dto);
          // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe start
          bHaveSub = true;
          // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe end
        }
      }
      // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe start
      if(!bHaveSub){
        PatEventCategoryDto dto = new PatEventCategoryDto();
        dto.categoryCd = cat.getCategoryCd();
        dto.categoryName = cat.getCategoryName();
        dto.subCategoryCd = 0L;
        dto.subCategoryName = "";
        ret.add(dto);
      }
      // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe end
    }
    return ret;
  }

  public List<MstPatEventCategory> selectPatEventCategory(String facilityCd) {
    List<MstPatEventCategory> templates = mstPatEventCategoryDao.selectByFacility(facilityCd);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_pat_event_category");

    if (mstSelector != null) {
      // ソート後データ
      List<MstPatEventCategory> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstPatEventCategory item : templates) {
          if (sortedCode.equals(item.getCategoryCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  public List<MstPatEventSubCategory> selectPatEventSubCategory(String facilityCd) {
    List<MstPatEventSubCategory> templates = mstPatEventSubCategoryDao.selectByFacility(facilityCd);
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_pat_event_sub_category");

    if (mstSelector != null) {
      // ソート後データ
      List<MstPatEventSubCategory> sortedData = new ArrayList<>();

      // ソート用配列作成
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        for (MstPatEventSubCategory item : templates) {
          if (sortedCode.equals(item.getSubCategoryCd())) {
            sortedData.add(item);
          }
        }
      }

      templates = sortedData;
    }
    return templates;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
  //public List<MedicineDto> getMedicine(String facilityCd) {
  public List<MedicineDto> getMedicine(String facilityCd, Integer medflag) {
  // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end

    // 薬剤区分マスタからmst_selector順のデータを取得
    MstMedicineClass classParam = new MstMedicineClass();
    classParam.setFacilityCd(facilityCd);
    List<MstMedicineClass> medicineClasses = mstMedicineClassDao.selectAll(SelectOptions.get(), classParam);
    // add #5601 「投薬・医材でフィルタができない」 鄧シン start
    MstMedicineClass nullItem = new MstMedicineClass();
    nullItem.setClassCd(-1);
    nullItem.setClassName("未分類");
    medicineClasses.add(nullItem);
    // add #5601 「投薬・医材でフィルタができない」 鄧シン end
    // add #5601 2021-11-3  「投薬・医材カテゴリで並べ替え」 鄭 start
    medicineClasses.sort((s1,s2)->s1.getClassCd().compareTo(s2.getClassCd()));
    // add #5601  2021-11-3 「投薬・医材カテゴリで並べ替え」 鄭 end
    // 薬剤マスタからmst_selector順のデータを取得
    MstMedicine param = new MstMedicine();
    param.setFacilityCd(facilityCd);
    List<MstMedicine> medicines = mstMedicineDao.selectAll(SelectOptions.get(), param);

    // 調製薬剤マスタからmst_selector順のデータを取得
    MstMedicineMix mixParam = new MstMedicineMix();
    mixParam.setFacilityCd(facilityCd);
    List<MstMedicineMix> medicineMixes = mstMedicineMixDao.selectAll(SelectOptions.get(), mixParam);

    List<MedicineDto> res = new ArrayList<>();

    for (MstMedicineClass medicineClass : medicineClasses) {
      // 薬剤区分ごとの処理
      Integer classCd = medicineClass.getClassCd();
      String className = medicineClass.getClassName();
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
      if(medflag == 0 || medflag == 1) {
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end
        boolean isNothingMedi = true;
        for (MstMedicine medicine : medicines) {
          if (Objects.equals(medicine.getClassCd(), medicineClass.getClassCd())) {
            // 薬剤区分が同じ薬剤
            MedicineDto dto = new MedicineDto();
            dto.setClassCd(classCd);
            dto.setClassName(className);
            dto.setMedicineCd(medicine.getMedicineCd());
            dto.setMedicineName(medicine.getMedicineName());
            dto.setPreparation(1);
            res.add(dto);
            isNothingMedi = false;
          }
        }
        if (isNothingMedi) {
          // 1件もなかったら区分のみのレコード
          MedicineDto dto = new MedicineDto();
          dto.setClassCd(classCd);
          dto.setClassName(className);
          dto.setMedicineCd(0);
          dto.setMedicineName(null);
          dto.setPreparation(1);
          res.add(dto);
        }
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
      }
      if(medflag == 0 || medflag == 2) {
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end
        boolean isNothingMix = true;
        for (MstMedicineMix medicineMix : medicineMixes) {
          if (Objects.equals(medicineMix.getClassCd(), medicineClass.getClassCd())) {
            // 薬剤区分が同じ調製薬剤
            MedicineDto dto = new MedicineDto();
            dto.setClassCd(classCd);
            dto.setClassName(className);
            dto.setMedicineCd(medicineMix.getMedicineMixCd());
            dto.setMedicineName(medicineMix.getMedicineMixName());
            dto.setPreparation(2);
            res.add(dto);
            isNothingMix = false;
          }
        }
        if (isNothingMix) {
          // 1件もなかったら区分のみのレコード
          MedicineDto dto = new MedicineDto();
          dto.setClassCd(classCd);
          dto.setClassName(className);
          dto.setMedicineCd(0);
          dto.setMedicineName(null);
          dto.setPreparation(2);
          res.add(dto);
        }
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
      }
      // add #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end
    }
    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
    res = res.stream().sorted(Comparator.comparingInt(e -> (e.getPreparation()))).collect(Collectors.toList());
    // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
    return res;
  }

  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
  private enum ReceiptClass {
    RECEIPT_1(0, "血液回路"),
    RECEIPT_2(1, "ダイアライザ"),
    RECEIPT_3(2, "吸着カラム"),
    RECEIPT_4(3, "1次膜"),
    RECEIPT_5(4, "2次膜"),
    RECEIPT_6(5, "シングルニードル"),
    RECEIPT_7(6, "穿刺針(A)"),
    RECEIPT_8(7, "穿刺針(V)"),
    RECEIPT_9(8, "透析液"),
    RECEIPT_10(9, "補液"),
    RECEIPT_11(10, "抗凝固剤"),
    RECEIPT_12(11, "医療材料"),
    RECEIPT_13(12, "投与薬剤"),
    RECEIPT_14(13, "透析困難"),
    RECEIPT_15(14, "加算・管理料")
    ;

    private final int code;
    private final String description;

    ReceiptClass(int code, String description) {
      this.code = code;
      this.description = description;
    }

    public int getCode() {
      return code;
    }

    public String getDescription() {
      return description;
    }
  }

  private enum DialyserSubType {
    DIALYSER_SUB_TYPE_1(1, "型番")
    , DIALYSER_SUB_TYPE_2(2, "メーカ名")
    , DIALYSER_SUB_TYPE_3(3, "面積")
    , DIALYSER_SUB_TYPE_4(4, "機能分類")
    , DIALYSER_SUB_TYPE_5(5, "滅菌")
    ;

    private final int code;
    private final String description;

    DialyserSubType(int code, String description) {
      this.code = code;
      this.description = description;
    }

    public int getCode() {
      return code;
    }

    public String getDescription() {
      return description;
    }
  }

  @Override
  public List<ReceiptDto> getReceipt(String facilityCd) {
    List<ReceiptDto> res = new ArrayList<>();

    for (ReceiptClass recClass : ReceiptClass.values()) {
      boolean isNothing = true;
      if(recClass.getCode() == 1){ //ダイアライザ
        for (DialyserSubType diaType : DialyserSubType.values()) {
          ReceiptDto dto = new ReceiptDto();
          dto.setClassCd(recClass.getCode());
          dto.setClassName(recClass.getDescription());
          dto.setKindCd(diaType.getCode());
          dto.setKindName(diaType.getDescription());
          dto.setReceiptCd(0);
          dto.setReceiptName(null);
          res.add(dto);
          isNothing = false;
        }
      }
      else if(recClass.getCode() == 11){ //医療材料
        // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe start
        //List<Equipment> equipments = mstEquipmentDao.selectByFacilityCd(facilityCd);
        List<Equipment> equipments = mstEquipmentDao.selectAllByFacilityCd(facilityCd, "1", "0");
        // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） limingzhe end
        for (Equipment equipment : equipments) {
          ReceiptDto dto = new ReceiptDto();
          dto.setClassCd(recClass.getCode());
          dto.setClassName(recClass.getDescription());
          dto.setKindCd(equipment.getClassType());
          dto.setKindName(equipment.getClassName());
          dto.setReceiptCd(equipment.getEquipmentCd());
          dto.setReceiptName(equipment.getEquipmentName());
          res.add(dto);
          isNothing = false;
        }
      }
      else if(recClass.getCode() == 12){ //投与薬剤
        // 薬剤区分マスタからmst_selector順のデータを取得
        MstMedicineClass classParam = new MstMedicineClass();
        classParam.setFacilityCd(facilityCd);
        List<MstMedicineClass> medicineClasses = mstMedicineClassDao.selectAll(SelectOptions.get(), classParam);
        MstMedicineClass nullItem = new MstMedicineClass();
        nullItem.setClassCd(-1);
        nullItem.setClassName("未分類");
        medicineClasses.add(nullItem);
        medicineClasses.sort((s1,s2)->s1.getClassCd().compareTo(s2.getClassCd()));
        // 薬剤マスタからmst_selector順のデータを取得
        MstMedicine param = new MstMedicine();
        param.setFacilityCd(facilityCd);
        List<MstMedicine> medicines = mstMedicineDao.selectAll(SelectOptions.get(), param);
        for (MstMedicineClass medicineClass : medicineClasses) {
          // 薬剤区分ごとの処理
          Integer classCd = medicineClass.getClassCd();
          String className = medicineClass.getClassName();
          for (MstMedicine medicine : medicines) {
            if (Objects.equals(medicine.getClassCd(), medicineClass.getClassCd())) {
              ReceiptDto dto = new ReceiptDto();
              dto.setClassCd(recClass.getCode());
              dto.setClassName(recClass.getDescription());
              dto.setKindCd(classCd);
              dto.setKindName(className);
              dto.setReceiptCd(medicine.getMedicineCd());
              dto.setReceiptName(medicine.getMedicineName());
              res.add(dto);
              isNothing = false;
            }
          }
        }
      }
      else if(recClass.getCode() == 13){ //透析困難
        List<MstDialysisDifficulty> dialysisDifficultys = mstDialysisDifficultyDao.selectDisp(facilityCd);
        for (MstDialysisDifficulty dialysisDifficulty : dialysisDifficultys) {
          ReceiptDto dto = new ReceiptDto();
          dto.setClassCd(recClass.getCode());
          dto.setClassName(recClass.getDescription());
          dto.setKindCd(dialysisDifficulty.getDialysisDifficultyCd());
          dto.setKindName(dialysisDifficulty.getDialysisDifficultyName());
          dto.setReceiptCd(0);
          dto.setReceiptName(null);
          res.add(dto);
          isNothing = false;
        }
      }
      else if(recClass.getCode() == 14){ //加算・管理料
        List<MstAddition> additions = mstAdditionDao.selectByFacilityCd(facilityCd);
        for (MstAddition addition : additions) {
          ReceiptDto dto = new ReceiptDto();
          dto.setClassCd(recClass.getCode());
          dto.setClassName(recClass.getDescription());
          dto.setKindCd(Long.valueOf(addition.getAdditionCd()).intValue());
          dto.setKindName(addition.getAdditionName());
          dto.setReceiptCd(0);
          dto.setReceiptName(null);
          res.add(dto);
          isNothing = false;
        }
      }

      if (isNothing) {
        ReceiptDto dto = new ReceiptDto();
        dto.setClassCd(recClass.getCode());
        dto.setClassName(recClass.getDescription());
        dto.setKindCd(0);
        dto.setKindName(null);
        dto.setReceiptCd(0);
        dto.setReceiptName(null);
        res.add(dto);
      }
    }
    return res;
  }
  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  /**
   * 装置マスタDaoインタフェース.
   */
  @Autowired
  MstMachineDao mstMachineDao;

  /**
   * 検査レイアウトDaoインタフェース.
   */
  @Autowired
  MstMenteLayoutDao mstMenteLayoutDao;

  /**
   * 検査カテゴリDaoインタフェース.
   */
  @Autowired
  MstMenteCategoryDao mstMenteCategoryDao;

  /**
   * 検査項目情報Daoインタフェース.
   */
  @Autowired
  MstMenteDetailDao mstMenteDetailDao;

// mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//  /**
//   * {@inheritDoc}
//   */
//  @Override
//  public List<MstMenteDetail> getInspection(String facilityCd, Long mainteLayoutCd, Long mainteRecordType)
//    throws Exception {
//    MstMenteLayout layout = mstMenteLayoutDao.selectLayoutByID(mainteLayoutCd);
//    if(layout == null) return new ArrayList<MstMenteDetail>();
//    String strCategoryIdList = "";
//    if(mainteRecordType.equals(2l)){
//      if(StringUtils.isEmpty(layout.getDetailInfo2()))
//        return new ArrayList<MstMenteDetail>();
//      strCategoryIdList = layout.getDetailInfo2();
//    }
//    else {
//      if(StringUtils.isEmpty(layout.getDetailInfo1()))
//        return new ArrayList<MstMenteDetail>();
//      strCategoryIdList = layout.getDetailInfo1();
//    }
//
//    return getListDetailByCategoryIdList(strCategoryIdList, facilityCd, null);
//  }
//
//  private List<MstMenteDetail> getListDetailByCategoryIdList(String strCategoryIdList, String facilityCd, Long machineNo)
//    throws Exception {
//    String machineTypeCd = null;
//    if (machineNo != null) {
//      MstMachine machine = mstMachineDao.selectByMachineNo(machineNo);
//      if (ObjectUtils.isEmpty(machine)) {
//        throw new IllegalArgumentException();
//      }
//      machineTypeCd = machine.getMachineTypeCd();
//    }
//    ObjectMapper mapper = new ObjectMapper();
//    List<CategoryDetailResult> categoryList = mapper.readValue(strCategoryIdList,
//      new TypeReference<List<CategoryDetailResult>>() {});
//    List<Long> layoutCdList = new ArrayList<Long>();
//    for (CategoryDetailResult category : categoryList) {
//      if (category.getIsDisp()) {
//        layoutCdList.add(category.getCd());
//      }
//    }
//    List<MstMenteDetail> mstMenteDetailList = new ArrayList<MstMenteDetail>();
//    List<MstMenteCategory> listCategorysTmp = mstMenteCategoryDao.selectByIdList(layoutCdList);
//    List<MstMenteCategory> listCategorys = new ArrayList<MstMenteCategory>();
//    for (Long layoutCd : layoutCdList) {
//      for (MstMenteCategory category : listCategorysTmp) {
//        if (layoutCd.equals(category.getMenteCategoryCd()) && hasCategoryMachineType(category, machineTypeCd)) {
//          listCategorys.add(category);
//          break;
//        }
//      }
//    }
//    List<MstMenteDetail> mstMenteDetailTmp = mstMenteDetailDao.selectByFacilityCdList(facilityCd);
//    long indexCategory = 0;
//    for (MstMenteCategory category : listCategorys) {
//      List<DetailResult> detailList = mapper.readValue(category.getDetailList(),
//        new TypeReference<List<DetailResult>>() {});
//      for (DetailResult detail : detailList) {
//        if(detail == null || StringUtils.isEmpty(detail.getCode())) continue;
//        if ("1".equals(detail.getIsDisp())) {
//          for (MstMenteDetail mstMenteDetail : mstMenteDetailTmp) {
//            if (detail.getCode().equals(mstMenteDetail.getMenteDetailCd())) {
//              MstMenteDetail mstMenteDetailNew = new MstMenteDetail();
//              BeanUtils.copyProperties(mstMenteDetail, mstMenteDetailNew);
//              mstMenteDetailNew.setMenteCategoryCd(category.getMenteCategoryCd());
//              mstMenteDetailNew.setMenteContent3(category.getEditionNo().toString()
//                + "," + String.valueOf(indexCategory));
//              mstMenteDetailList.add(mstMenteDetailNew);
//            }
//          }
//        }
//      }
//      indexCategory = indexCategory + 1;
//    }
//    return mstMenteDetailList;
//  }
//
//  /**
//   * 装置型式が検査項目グループマスタの対象型式に含まれているか判定する
//   *
//   * @param category 検査項目グループマスタ
//   * @param machineTypeCd 装置型式
//   * @return 対象型式に含まれている場合は true
//   * （machineTypeCd が null の場合と検査項目グループマスタの対象型式が未選択の場合は常に true とする）
//   * @throws Exception
//   */
//  private Boolean hasCategoryMachineType(MstMenteCategory category, String machineTypeCd) throws Exception {
//    if (category == null) {
//      throw new IllegalArgumentException();
//    }
//    if (machineTypeCd == null) {
//      // machineTypeCd が null の場合は常に true とする
//      return true;
//    }
//
//    JSONArray typeJsonArray = new JSONArray(category.getTypeList());
//    if (typeJsonArray.length() == 0) {
//      // 検査項目グループマスタの対象型式が未選択の場合は常に true とする
//      return true;
//    }
//
//    Boolean existsTypeCd = false;
//    for (int i = 0; i < typeJsonArray.length(); i++) {
//      if (machineTypeCd.equals(typeJsonArray.getString(i))) {
//        existsTypeCd = true;
//        break;
//      }
//    }
//    return existsTypeCd;
//  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMainteCategoryAndDetail> getInspection(String facilityCd, String layoutClass)
    throws Exception {
    List<MstMainteCategoryAndDetail> list = new ArrayList<>();
    if(layoutClass.equals("1")){
      list = mstMenteDetailDao.selectDailyMainteCategoryandDetailList(facilityCd, layoutClass);
    }
    else if(layoutClass.equals("2")){
      list = mstMenteDetailDao.selectPeriodicMainteCategoryandDetailList(facilityCd, layoutClass);
    }
    return list;
  }
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  /**
   * 装置マスタDaoインタフェース.
   */
  @Autowired
  MstMachineTypeDao mstMachineTypeDao;

  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　start
  @Autowired
  MstWaterSurveyPointDao mstWaterSurveyPointDao;
  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachineType> getMachineType(String facilityCd, String layoutClass)
    throws Exception {
    List<MstMachineType> list = new ArrayList<>();
    list = mstMachineTypeDao.selectAll();
    return list;
  }
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　start
  @Override
  public List<Map<String, Object>> getWaterSurveyPoint(String facilityCd, String machineTypeCd) throws Exception {
    List<Map<String, Object>> list = new ArrayList<>();
    list = mstWaterSurveyPointDao.selectByWaterSurveyPoint(facilityCd, machineTypeCd);
    return list;
  }
  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　end

  /* add by yuqinlong  2023-01-31 [CodeOptimization]  start */
  @Override
  public List<Map<String, Object>> getMatrixTest(Long sqlCode, Map<String, Object> dataKey) {
    List<Map<String, Object>> res = sysDataSetService.getDataList(sqlCode, dataKey);

    //
    List<String> rowList = new ArrayList<String>(){
      {
        add("bed_name");
      }
    };
    List<String> colList = new ArrayList<String>(){
      {
        add("treat_date");
        add("ind_treat_start_time");
      }
    };
    List<String> valList = new ArrayList<String>(){
      {
        add("pat_id");
        add("pat_name");
      }
    };
    res = sysDataSetService.getMatrixDataList(res, rowList, colList, valList );

    return res;
  }
  /* add by yuqinlong  2023-01-31 [CodeOptimization]  end */

  // ADD #10637 2024/09/05 Thach Start

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportFile(long reportCd) {
    // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe start
    //MstReport mstReport = mstReportDao.selectReportByReportCd(reportCd);
    MstReport mstReport = mstReportDao.selectByReportCdIsNotDel(reportCd);
    // mod #11501 レイアウトデザイナのユーザビリティ改善 limingzhe end
    if(mstReport != null)
    {
      return reportS3Service.getReportFile(
        mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(),
        mstReport.getUpDate());
    }
    else {
      return new byte[0];
    }
  }

  // ADD #10637 2024/09/05 Thach End
}
