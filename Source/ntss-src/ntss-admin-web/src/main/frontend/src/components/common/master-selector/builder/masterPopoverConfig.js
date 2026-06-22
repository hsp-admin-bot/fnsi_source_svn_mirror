/**
 * 初期値コード（initItem → selectedItem → extraParams.initValue）
 */
function resolveInitCd(context) {
  const { initItem, selectedItem, extraParams } = context || {};
  const v =
    (initItem && initItem.value != null && initItem.value !== ""
      ? initItem.value
      : null) ??
    (selectedItem && selectedItem.value != null && selectedItem.value !== ""
      ? selectedItem.value
      : null) ??
    (extraParams && extraParams.initValue != null && extraParams.initValue !== ""
      ? extraParams.initValue
      : null);
  return v != null && String(v).trim() !== "" ? String(v).trim() : null;
}

/**
 * EQUIPMENT + DIALYZER 併用：初期値がダイアライザ側か判定し、initEquipmentCd / initDialyzerCd を振り分け
 */
function splitEquipmentDialyzerInitCd(context, initCd) {
  if (!initCd) {
    return { initEquipmentCd: null, initDialyzerCd: null };
  }
  const extra = context?.extraParams || {};
  const equipType = extra.equipType ?? extra.equip_type;
  const s = String(initCd);
  if (/^dialyzer/i.test(s)) {
    return { initEquipmentCd: null, initDialyzerCd: s.replace(/^dialyzer/i, "") };
  }
  if (equipType === 1 || equipType === "1") {
    return { initEquipmentCd: null, initDialyzerCd: s };
  }
  return { initEquipmentCd: s, initDialyzerCd: null };
}

function EQUIPMENT_SET_RECORD(context) {
  const { facilityCd, patientId } = context;
  const initCd = resolveInitCd(context);
  const sqlParams = {
    facilityCd,
    patId: patientId,
    ...(initCd != null ? { initEquipmentSetCd: initCd } : {})
  };
  return {
    lists: [
      {
        id: "list_main_all",
        name: "mst_equipment_set 一覧",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstEquipmentSetDaoImpl",
          sqlParams
        }
      }
    ]
  };
}

 function EQUIPMENT_TREATMENT_RECORD(context) {

    const { facilityCd, patientId } = context;
    const extraParams = context?.extraParams || {};
    const excludeEquipmentCdList = extraParams.excludeEquipmentCdList;
    const excludeDialyzerCdList = extraParams.excludeDialyzerCdList;

    const { initEquipmentCd, initDialyzerCd } = splitEquipmentDialyzerInitCd(
      context,
      resolveInitCd(context)
    );

    const equipmentSqlParams = {
      facilityCd,
      patId: patientId,
      ...(initEquipmentCd != null ? { initEquipmentCd } : {}),
      ...(excludeEquipmentCdList ? { excludeEquipmentCdList } : {})
    };
    const dialyzerSqlParams = {
      facilityCd,
      patId: patientId,
      ...(initDialyzerCd != null ? { initDialyzerCd } : {}),
      ...(excludeDialyzerCdList ? { excludeDialyzerCdList } : {})
    };

    return {
      lists: [
                {
                    id: "list_class_plus_fixed",
                    name: "mst_equipment_class 集合 + 固定项 -1 + 固定项 -2",
                    displayType: "categorizedList",
                    filterKey:"class",
                    filterLabel:"医療材料分類",
                    sourceType: "MST_COMBINED",
                    mstSourceList: [
                        {
                            mstCode: "mstEquipmentClassDaoImpl",
                            sqlParams: {
                                facilityCd: facilityCd
                            },
                            keyMapping: [
                                {
                                    keyName: "key_class",
                                    valueFrom: "class_cd"
                                }
                            ]
                        }
                    ],
                    fixedItems: [
                        {
                            classCd: "-2",
                            cd: "-2",
                            value: "ダイアライザ",
                            className: "ダイアライザ"
                        },
                        {
                            classCd: "-1",
                            cd: "-1",
                            value: "未分類",
                            className: "未分類"
                        }
                    ]
                },

                {
                    id: "list_union_mst_equipment_mst_dialyzer",
                    name: "mst_equipment 条目 + mst_dialyzer 条目（mst2 的 class 统一为 -2）",
                    sourceType: "MST_COMBINED",
                    filterKey:"master",
                    filterLabel:"医療材料名",
                    mstSourceList: [
                        {
                            mstCode: "mstEquipmentDaoImpl",
                            sqlParams: equipmentSqlParams,
                            keyMapping: [
                                {
                                    keyName: "key_class",
                                    valueFrom: "classCd"
                                },
                                {
                                    keyName: "key_cd",
                                    valueFrom: "equipmentCd"
                                }
                            ]
                        },

                        {
                            mstCode: "mstDialyzerDaoImpl",
                            sourceTag: "-2",
                            sqlParams: dialyzerSqlParams,
                            keyMapping: [
                                {
                                    keyName: "key_class",
                                    valueFrom: "sourceTag"
                                },
                                {
                                    keyName: "key_cd",
                                    valueFrom: "dialyzerCd"
                                }
                            ]
                        }
                    ]
                }
            ]
    };
  }

 function DIALYZER_TREATMENT_RECORD(context) {

    const { facilityCd, patientId } = context;
    const treatDate = context?.extraParams?.treatDate;

    const initDialyzerCd = resolveInitCd(context);
    const dialyzerBaseParams =
      initDialyzerCd != null
        ? { facilityCd: facilityCd, initDialyzerCd, patId: patientId }
        : { facilityCd: facilityCd, patId: patientId };
    if (treatDate) {
      dialyzerBaseParams.treatDate = String(treatDate).replaceAll("-", "");
    }

    return {
      lists: [
        {
          id: "list_make",
          name: "去重：maker（从 mst_dialyzer 取得）",
          displayType: "categorizedList",
          filterKey:"maker",
          filterLabel:"メーカー",
          sourceType: "MAIN_DISTINCT",
          mstSource: {
            mstCode: "mstDialyzerDaoImpl",
            sqlParams: dialyzerBaseParams,
            distinctField: "maker",
            keyMapping: [
              { keyName: "key_make", valueFrom: "maker" },
              { keyName: "cd", valueFrom: "maker" },
              { keyName: "value", valueFrom: "maker" }
            ]
          },
          fixedItems: [
              { key_make: null, value: "メーカー名なし"}
          ],
        },
        {
          id: "list_type",
          name: "固定 type 列表",
          displayType: "categorizedList",
          filterKey:"dialyzerType",
          filterLabel:"ダイアライザ種別",
          sourceType: "FIXED",
          fixedItems: [
            { cd: "0", value: "中空糸" },
            { cd: "1", value: "積層" }
          ],
          keyMapping: [
            { keyName: "key_type", valueFrom: "cd" }
          ]
        },
        {
          id: "list_class",
          name: "去重：class（从 mst_dialyzer 取得）",
          displayType: "categorizedList",
          filterKey:"functionClass",
          filterLabel:"機能分類",
          sourceType: "MAIN_DISTINCT",
          mstSource: {
            mstCode: "mstDialyzerDaoImpl",
            sqlParams: dialyzerBaseParams,
            distinctField: "functionClass",
            keyMapping: [
              { keyName: "key_class", valueFrom: "functionClass" },
              { keyName: "cd", valueFrom: "functionClass" },
              { keyName: "value", valueFrom: "functionClass" }
            ]
          },
          fixedItems: [
              { key_class: null, value: "未分類"}
          ],
        },
        {
          id: "list_main_all",
          name: "主列表 mst_dialyzer 完整数据",
          sourceType: "MST",
          mstSource: {
            mstCode: "mstDialyzerDaoImpl",
            sqlParams: dialyzerBaseParams
          },
          filterKey:"master",
          filterLabel:"医療材料名",
          keyMapping: [
            { keyName: "key_make", valueFrom: "maker" },
            { keyName: "key_type", valueFrom: "dialyzerType" },
            { keyName: "key_class", valueFrom: "functionClass" },
            { keyName: "key_cd", valueFrom: "dialyzerCd" }
          ]
        }
      ]
    };
 }
 function MEDICATION_TREATMENT_RECORD(context) {

    const { facilityCd, patientId, extraParams } = context;

    const initMedicineCd = resolveInitCd(context);
    const medicineType = extraParams?.medicineType;
    const treatDate = extraParams?.treatDate;
    const isType1 = medicineType == 1 || medicineType === "1";
    const isType2 = medicineType == 2 || medicineType === "2";
    // 投与薬剤中止：initMedicineCd 指定時は SQL が1件に絞られるため、白名单選択時は渡さない
    const suspendMedicineSelect = context?.allowedFields?.showMedicineFieldOnly === true;

    const sqlBase = { facilityCd, patId: patientId };
    const medicineSqlParams = { ...sqlBase };
    const mixSqlParams = { ...sqlBase };
    if (treatDate) {
      const ymd = String(treatDate).replaceAll("-", "");
      medicineSqlParams.treatDate = ymd;
      mixSqlParams.treatDate = ymd;
    }
    if (initMedicineCd && !suspendMedicineSelect) {
      if (isType1) {
        medicineSqlParams.initMedicineCd = initMedicineCd;
      } else if (isType2) {
        mixSqlParams.initMedicineCd = initMedicineCd;
      } else {
        medicineSqlParams.initMedicineCd = initMedicineCd;
        mixSqlParams.initMedicineCd = initMedicineCd;
      }
    }

    return {
      lists: [
        {
          id: "list1",
          name: "固定分类",
          sourceType: "FIXED",
          displayType: "categorizedList",
          filterKey:"key_type",
          filterLabel:"薬剤区分",
          fixedItems: [
            { cd: "1", value: "通常薬剤" },
            { cd: "2", value: "調製薬剤" }
          ],
          keyMapping: [
            { keyName: "key_type", valueFrom: "cd" }
          ]
        },
        {
          id: "list2",
          name: "药剂分类MST",
          sourceType: "MST",
          mstSource: {
            mstCode: "mstMedicineClassDaoImpl",
            sqlParams: { facilityCd: facilityCd }
          },
          displayType: "categorizedList",
          filterKey:"class",
          filterLabel:"薬剤分類",
          keyMapping: [
            { keyName: "key_class", valueFrom: "classCd" }
          ]
        },
        {
          id: "list3",
          name: "通常药剂 + 调制药剂 合并",
          sourceType: "MST_COMBINED",
          mstSourceList: [
            {
              mstCode: "mstMedicineDaoImpl",
              sourceTag: "1",
              sqlParams: medicineSqlParams,
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineCd" }
              ]
            },
            {
              mstCode: "mstMedicineMixDaoImpl",
              sourceTag: "2",
              sqlParams: mixSqlParams,
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineMixCd" }
              ]
            }
          ]
        }
      ]
    };
 }

 function EQUIPMENT_TREATMENT_CLASSTYPE_RECORD(context) {

    const { facilityCd, patientId, extraParams } = context;

    const classType = extraParams.classType;
    const treatDate = extraParams?.treatDate;

    // classType 絞り込み時でも初期選択値は必ず含める（分類不一致でも表示できるようにする）
    const initEquipmentCd = resolveInitCd(context);

    const equipmentSqlParams =
      initEquipmentCd != null
        ? { facilityCd: facilityCd, patId: patientId, classType: classType, initEquipmentCd }
        : { facilityCd: facilityCd, patId: patientId, classType: classType };
    if (treatDate) {
      equipmentSqlParams.treatDate = String(treatDate).replaceAll("-", "");
    }

    return {
      lists: [
                {
                    id: "list_class_plus_fixed",
                    name: "mst_equipment_class 集合 + 固定项 -1 + 固定项 -2",
                    displayType: "categorizedList",
                    filterKey:"class",
                    filterLabel:"医療材料分類",
                    sourceType: "MST_COMBINED",
                    mstSourceList: [
                        {
                            mstCode: "mstEquipmentClassDaoImpl",
                            sqlParams: {
                                facilityCd: facilityCd,
                                classType: classType
                            },
                            keyMapping: [
                                {
                                    keyName: "key_class",
                                    valueFrom: "class_cd"
                                }
                            ]
                        }
                    ]
                },

                {
                    id: "list_union_mst_equipment",
                    name: "mst_equipment 条目",
                    sourceType: "MST_COMBINED",
                    filterKey:"master",
                    filterLabel:"医療材料名",
                    mstSourceList: [
                        {
                            mstCode: "mstEquipmentDaoImpl",
                            sqlParams: equipmentSqlParams,
                            keyMapping: [
                                {
                                    keyName: "key_class",
                                    valueFrom: "classCd"
                                },
                                {
                                    keyName: "key_cd",
                                    valueFrom: "equipmentCd"
                                }
                            ]
                        }
                    ]
                }
            ]
    };
  }

 function MEDICATION_TREATMENT_CLASSTYPE_RECORD(context) {

    const { facilityCd, patientId, extraParams} = context;

    const classType = extraParams.classType;

    const medicineType = extraParams.medicineType;
    const treatDate = extraParams?.treatDate;
    const includeMedicineTypeCategory =
      extraParams?.includeMedicineTypeCategory === true;

    const initMedicineCd = resolveInitCd(context);
    const suspendMedicineSelect = context?.allowedFields?.showMedicineFieldOnly === true;

    const sqlBase = { facilityCd, patId: patientId, classType: classType };
    const isType1 = medicineType == 1 || medicineType === "1";
    const isType2 = medicineType == 2 || medicineType === "2";

    const medicineSqlParams = { ...sqlBase };
    const mixSqlParams = { ...sqlBase };
    if (treatDate) {
      const ymd = String(treatDate).replaceAll("-", "");
      medicineSqlParams.treatDate = ymd;
      mixSqlParams.treatDate = ymd;
    }
    if (initMedicineCd && !suspendMedicineSelect) {
      if (isType1) {
        medicineSqlParams.initMedicineCd = initMedicineCd;
      } else if (isType2) {
        mixSqlParams.initMedicineCd = initMedicineCd;
      } else {
        medicineSqlParams.initMedicineCd = initMedicineCd;
        mixSqlParams.initMedicineCd = initMedicineCd;
      }
    }

    return {
      lists: [
        ...(includeMedicineTypeCategory
          ? [
              {
                id: "list_fixed_type",
                name: "固定分类",
                sourceType: "FIXED",
                displayType: "categorizedList",
                filterKey: "key_type",
                filterLabel: "薬剤区分",
                fixedItems: [
                  { cd: "1", value: "通常薬剤" },
                  { cd: "2", value: "調製薬剤" }
                ],
                keyMapping: [{ keyName: "key_type", valueFrom: "cd" }]
              }
            ]
          : []),
        {
          id: "list1",
          name: "药剂分类MST",
          sourceType: "MST",
          mstSource: {
            mstCode: "mstMedicineClassDaoImpl",
            sqlParams: {
              facilityCd: facilityCd,
              classType: classType
            }
          },
          displayType: "categorizedList",
          filterKey:"class",
          filterLabel:"薬剤分類",
          keyMapping: [
            { keyName: "key_class", valueFrom: "classCd" }
          ]
        },
        {
          id: "list2",
          name: "通常药剂 + 调制药剂 合并",
          sourceType: "MST_COMBINED",
          mstSourceList: [
            {
              mstCode: "mstMedicineDaoImpl",
              sourceTag: "1",
              sqlParams: medicineSqlParams,
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineCd" }
              ]
            },
            {
              mstCode: "mstMedicineMixDaoImpl",
              sourceTag: "2",
              sqlParams: mixSqlParams,
              keyMapping: [
                { keyName: "key_type", valueFrom: "sourceTag" },
                { keyName: "key_class", valueFrom: "classCd" },
                { keyName: "key_cd", valueFrom: "medicineMixCd" }
              ]
            }
          ]
        }
      ]
    };
 }

  function VA_TREATMENT_RECORD(context) {

    const { facilityCd } = context;

    const initVaCd = resolveInitCd(context);
    const vaSqlParams =
      initVaCd != null
        ? { facilityCd: facilityCd, initVaCd }
        : { facilityCd: facilityCd };

    return {
      lists: [
        {
          id: "list1",
          name: "VA",
          sourceType: "MAIN_DISTINCT",
          mstSource: {
            mstCode: "mstVaDaoImpl",
            sqlParams: vaSqlParams
          },
          filterKey:"va_direct",
          filterLabel:"VA"
        }
      ]
    };
 }

 function PERSONAL_USER_TREATMENT_RECORD(context) {
   const { facilityCd } = context;
   const initUserId = resolveInitCd(context);
   const userSqlParams =
     initUserId != null
       ? { facilityCd, initUserId }
       : { facilityCd };

   return {
     lists: [
       {
         id: "list_job",
         name: "職種",
         displayType: "categorizedList",
         filterKey: "class",
         filterLabel: "職種",
         sourceType: "MST",
         mstSource: {
           mstCode: "mstJobDaoImpl",
           sqlParams: { facilityCd }
         }
       },
       {
         id: "list_personal_user",
         name: "利用者",
         sourceType: "MST",
         mstSource: {
           mstCode: "mstPersonalUserDaoImpl",
           sqlParams: userSqlParams
         },
         filterKey: "master",
         filterLabel: "利用者名",
         keyMapping: [
           { keyName: "key_class", valueFrom: "jobCd" },
           { keyName: "key_cd", valueFrom: "userId" }
         ]
       }
     ]
   };
 }

function PRACTITIONER_CHECK_LIST(context) {
  const { facilityCd } = context;
  const initUserId = resolveInitCd(context);
  const userSqlParams =
    initUserId != null
      ? { facilityCd, initUserId }
      : { facilityCd };

  return {
    lists: [
      {
        id: "list_job",
        name: "職種",
        displayType: "categorizedList",
        filterKey: "class",
        filterLabel: "職種",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstJobDaoImpl",
          sqlParams: { facilityCd }
        }
      },
      {
        id: "list_personal_user",
        name: "実施者",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstPersonalUserDaoImpl",
          sqlParams: userSqlParams
        },
        filterKey: "master",
        filterLabel: "実施者名",
        keyMapping: [
          { keyName: "key_class", valueFrom: "jobCd" },
          { keyName: "key_cd", valueFrom: "userId" }
        ]
      }
    ]
  };
}

function MEDICINE_SET_INDICATION_RECORD(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams = initCd != null ? { facilityCd, initMedicineSetCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_medicine_set",
        name: "薬剤セット",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstMedicineSetDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "薬剤セット名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "medicineSetCd" }]
      }
    ]
  };
}

function WHEEL_CHAIR_OWNER_PATIENT_MASTER(context) {
  const { facilityCd } = context;
  return {
    lists: [
      {
        id: "list_owner_patient",
        name: "所有患者",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstPatPersonalSimpleDaoImpl",
          sqlParams: { facilityCd }
        },
        filterKey: "master",
        filterLabel: "患者名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "patId" }]
      }
    ]
  };
}

function COMPLAINT_TREATMENT_RECORD(context) {
  const { facilityCd } = context;
  const initComplaintCd = resolveInitCd(context);
  const sqlParams =
    initComplaintCd != null ? { facilityCd, initComplaintCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_complaint",
        name: "愁訴",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstComplaintDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "愁訴名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "complaintCd" }]
      }
    ]
  };
}

function COMP_TREATMENT_RECORD(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initCompTreatmentCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_comp_treatment",
        name: "処置",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstCompTreatmentDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "処置名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "compTreatmentCd" }]
      }
    ]
  };
}

function PROCEDURE_TREATMENT_RECORD(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initProcedureCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_procedure",
        name: "手技",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstProcedureDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "手技名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "procedureCd" }]
      }
    ]
  };
}

function WHEEL_CHAIR_TREATMENT_RECORD(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initWheelChairCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_wheel_chair",
        name: "車いす",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstWheelChairDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "車いす名称",
        keyMapping: [{ keyName: "key_cd", valueFrom: "wheelChairCd" }]
      }
    ]
  };
}

function SEVERITY_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initSeverityCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_severity",
        name: "重症度",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstSeverityDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "重症度",
        keyMapping: [{ keyName: "key_cd", valueFrom: "severityCd" }]
      }
    ]
  };
}

function TRANSPORT_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initTransportCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_transport",
        name: "搬送",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstTransportDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "搬送",
        keyMapping: [{ keyName: "key_cd", valueFrom: "transportCd" }]
      }
    ]
  };
}

function WHEEL_CHAIR_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initWheelChairCd: initCd } : { facilityCd };
  return WHEEL_CHAIR_TREATMENT_RECORD({ ...context, extraParams: { ...(context.extraParams || {}), initValue: initCd }, facilityCd });
}

function FACILITY_PAT_INFO(context) {
  // facility master is global; initValue may be used to include selected item
  // 都道府県はフロント固定（facilityPatInfoPrefectures.js）。compose は施設一覧のみ。
  const initCd = resolveInitCd(context);
  const sqlParams = initCd != null ? { initFacilityCd: initCd } : {};
  return {
    lists: [
      {
        id: "list_facility",
        name: "施設",
        sourceType: "MST",
        mstSource: {
          mstCode: "sysFacilityDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "施設名",
        keyMapping: [
          { keyName: "key_cd", valueFrom: "medicalInstitutionCd" },
          { keyName: "key_class", valueFrom: "prefecturesCd" }
        ]
      }
    ]
  };
}

function COURSE_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initCourseCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_course",
        name: "診療科",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstCourseDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "診療科名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "courseCd" }]
      }
    ]
  };
}

function DOCTOR_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initUserId: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_job",
        name: "職種",
        displayType: "categorizedList",
        filterKey: "class",
        filterLabel: "職種",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstJobDaoImpl",
          sqlParams: { facilityCd }
        }
      },
      {
        id: "list_personal_user",
        name: "担当医",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstPersonalUserDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "担当医名",
        keyMapping: [
          { keyName: "key_class", valueFrom: "jobCd" },
          { keyName: "key_cd", valueFrom: "userId" }
        ]
      }
    ]
  };
}

function STAFF_PAT_INFO(context) {
  const result = DOCTOR_PAT_INFO(context);
  result.lists[1].name = "担当者";
  result.lists[1].filterLabel = "担当者名";
  return result;
}

function STAFF_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initUserId: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_personal_user",
        name: "担当者",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstPersonalUserDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "担当者名",
        keyMapping: [
          { keyName: "key_class", valueFrom: "jobCd" },
          { keyName: "key_cd", valueFrom: "userId" }
        ]
      }
    ]
  };
}

function IMPLANT_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initImplantCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_implant",
        name: "インプラント",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstImplantDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "内容",
        keyMapping: [{ keyName: "key_cd", valueFrom: "implantCd" }]
      }
    ]
  };
}

function RELATIONSHIP_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null
      ? { facilityCd, initRelationshipCd: initCd }
      : { facilityCd };
  return {
    lists: [
      {
        id: "list_relationship",
        name: "続柄",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstRelationshipDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "続柄名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "relationshipCd" }]
      }
    ]
  };
}

function NATIONALITY_PAT_INFO() {
  return {
    lists: [
      {
        id: "list_sys_country",
        name: "国籍",
        sourceType: "MST",
        mstSource: {
          mstCode: "sysCountryDaoImpl",
          sqlParams: {}
        },
        filterKey: "master",
        filterLabel: "国名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "countryCdAlpha3" }]
      }
    ]
  };
}

function DIALYSIS_COURSE_PAT_INFO(context) {
  return COURSE_PAT_INFO(context);
}

function WARD_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initWardCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_ward",
        name: "病棟",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstWardDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "病棟名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "wardCd" }]
      }
    ]
  };
}

function TABOO_ALLERGY_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null
      ? { facilityCd, initTabooAllergyCd: initCd }
      : { facilityCd };
  return {
    lists: [
      {
        id: "list_taboo_allergy",
        name: "禁忌・アレルギー",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstTabooAllergyDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "禁忌・アレルギー名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "tabooAllergyCd" }]
      }
    ]
  };
}

function DISEASE_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initDiseaseCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_disease",
        name: "病名",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstDiseaseDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "病名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "diseaseCd" }]
      }
    ]
  };
}

function INSURANCE_PAT_INFO(context) {
  const { facilityCd, extraParams } = context;
  const insuType =
    extraParams != null && extraParams.insuType != null
      ? String(extraParams.insuType)
      : "0";
  const initCd = resolveInitCd(context);
  const sqlParams = {
    facilityCd,
    insuType,
    ...(initCd != null ? { initInsuCd: initCd } : {})
  };
  return {
    lists: [
      {
        id: "list_insurance",
        name: "保険",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstInsuranceDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "保険名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "insuCd" }]
      }
    ]
  };
}

function OTHER_CONTACT_PAT_PAT_INFO(context) {
  const { facilityCd, extraParams } = context;
  const ep = extraParams || {};
  const sqlParams = {
    facilityCd,
    ...(ep.excludePatId != null && ep.excludePatId !== ""
      ? { excludePatId: String(ep.excludePatId) }
      : {}),
    ...(ep.initHospPatId != null && ep.initHospPatId !== ""
      ? { initHospPatId: String(ep.initHospPatId) }
      : {})
  };
  return {
    lists: [
      {
        id: "list_other_contact_pat",
        name: "患者",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstPatPersonalSimpleDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "患者名",
        keyMapping: [{ keyName: "key_cd", valueFrom: "patId" }]
      }
    ]
  };
}

function ADDITION_PAT_INFO(context) {
  const { facilityCd } = context;
  const initCd = resolveInitCd(context);
  const sqlParams =
    initCd != null ? { facilityCd, initAdditionCd: initCd } : { facilityCd };
  return {
    lists: [
      {
        id: "list_addition",
        name: "加算・管理料",
        sourceType: "MST",
        mstSource: {
          mstCode: "mstAdditionDaoImpl",
          sqlParams
        },
        filterKey: "master",
        filterLabel: "加算・管理料",
        keyMapping: [{ keyName: "key_cd", valueFrom: "additionCd" }]
      }
    ]
  };
}

 const configMap = {
  EQUIPMENT_SET_RECORD,
  EQUIPMENT_TREATMENT_RECORD,
  DIALYZER_TREATMENT_RECORD,
  MEDICATION_TREATMENT_RECORD,
  EQUIPMENT_TREATMENT_CLASSTYPE_RECORD,
  MEDICATION_TREATMENT_CLASSTYPE_RECORD,
  VA_TREATMENT_RECORD,
  PERSONAL_USER_TREATMENT_RECORD,
  PRACTITIONER_CHECK_LIST,
  MEDICINE_SET_INDICATION_RECORD,
  WHEEL_CHAIR_OWNER_PATIENT_MASTER,
  COMPLAINT_TREATMENT_RECORD,
  COMP_TREATMENT_RECORD,
  PROCEDURE_TREATMENT_RECORD,
  WHEEL_CHAIR_TREATMENT_RECORD,
  SEVERITY_PAT_INFO,
  TRANSPORT_PAT_INFO,
  WHEEL_CHAIR_PAT_INFO,
  FACILITY_PAT_INFO,
  COURSE_PAT_INFO,
  DOCTOR_PAT_INFO,
  STAFF_PAT_INFO,
  STAFF_INFO,
  IMPLANT_PAT_INFO,
  RELATIONSHIP_PAT_INFO,
  NATIONALITY_PAT_INFO,
  DIALYSIS_COURSE_PAT_INFO,
  WARD_PAT_INFO,
  TABOO_ALLERGY_PAT_INFO,
  DISEASE_PAT_INFO,
  INSURANCE_PAT_INFO,
  OTHER_CONTACT_PAT_PAT_INFO,
  ADDITION_PAT_INFO
};

export function getMasterConfig(masterType, context = {}) {
  const key = masterType?.toUpperCase?.();

  if (!(key in configMap)) {
    console.warn(`[masterPopover] unknown masterType: ${masterType}`);
    return null;
  }

  const builder = configMap[key];

  if (builder === null) {
    console.warn(`[masterPopover] not implemented: ${masterType}`);
    return null;
  }

  if (typeof builder !== "function") {
    console.warn(`[masterPopover] invalid builder: ${masterType}`);
    return null;
  }

  try {
    return builder(context);
  } catch (e) {
    console.error(`[masterPopover] build failed: ${masterType}`, e);
    return null;
  }
}
