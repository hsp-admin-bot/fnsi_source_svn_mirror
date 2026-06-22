const ConditionContrastObj = {
  "mst_addition": ["name", "additionName", "additionShortName"],
  "mst_device_edge": ["name", "facilityCd", "facilityName", "serialNo"],
  "mst_self_measure_result": ["dispMachineName"],
  "mst_mainte_detail": ["mainteContent1","mainteContent2","mainteContent3","iniText"],
  "mst_mainte_layout": ["layoutName"],
  "mst_mainte_layout_group": ["groupName"],
  "mst_holiday": ["year"],
  "sys_medicine": ["name"],
  "mst_machine": ["name", "machineSerial", "comFormatCd", "ipAddress", "port", "version"],
  "mst_pat_memo": ["code", "name", "content"],
  "mst_disease": ["name", "diseaseShortName", "standardDiseaseCd", 'pDiseaseBiopsyNoneCd', 'pDiseaseBiopsyExistCd', "dieConfirmedDiagnosisNoneCd", "dieConfirmedDiagnosisExistCd", "inHospitalCd1"],
  "mst_insurance": ["name", "insuName"],
  "mst_medicine": ["name", "medicineShortName"],
  "mst_medicine_mix": ["name", "medicineMixShortName"],
  "mst_medicine_set": ["name", 'medicineSetShortName'],
  "mst_dialyzer": ["name", 'maker', 'functionClass'],
  "mst_equipment": ["name", 'equipmentShortName'],
  "mst_equipment_set": ["name", 'equipmentSetShortName'],
  "mst_exam_set": ["name", 'shortname'],
  "mst_rad_set": ["name", "radSetAbbName"],
  "mst_bbs_kind": ["name", 'defaultTitle', 'defaultContents'],
  // TODO: 筛选的内容需要到下拉的values里面获取
  "mst_function_report": ["functionCd", "reportCd"], // 機能帳票マスタ
  "mst_comsv_setting": ["deviceEdgeNo"], // 装置通信・仮想端末マスタ
}
export default ConditionContrastObj;