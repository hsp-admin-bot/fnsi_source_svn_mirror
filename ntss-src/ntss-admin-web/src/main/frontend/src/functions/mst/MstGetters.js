import {ApiHelper} from "@/apis/AxiosHelper.js";

const pendingMstRequests = new Map();
const resolvedMstRequests = new Map();
const RESOLVED_MST_REQUEST_TTL_MS = 1000;

const createMstRequestKey = (uri, alias, facilityCd) =>
  `${uri}|${alias}|${facilityCd == null ? "" : facilityCd}`;

const createFacilityMstRequestKey = (uri, facilityCd) =>
  `${uri}|facilityCd|${facilityCd == null ? "" : facilityCd}`;

const cloneMstData = data => {
  if (data == null || typeof data !== "object") {
    return data;
  }
  return JSON.parse(JSON.stringify(data));
};

/**
 * @description エラーメッセージ
 */
const createErrorMessage = uri => `WebAPI: "${uri}の実行に失敗しました。"`;

/**
 * @description 施設コードで特定するマスタ取得用内部関数
 * @param {String} uri
 * @param {String} facility_cd
 * @returns {Array} マスタの配列
 */
const getMstByFacilityCd = async (uri, facilityCd) => {
  const requestKey = createFacilityMstRequestKey(uri, facilityCd);
  const resolvedRequest = resolvedMstRequests.get(requestKey);
  if (
    resolvedRequest &&
    Date.now() - resolvedRequest.resolvedAt < RESOLVED_MST_REQUEST_TTL_MS
  ) {
    return cloneMstData(resolvedRequest.data);
  }

  if (pendingMstRequests.has(requestKey)) {
    return cloneMstData(await pendingMstRequests.get(requestKey));
  }

  const stackTrace = new Error();
  const request = ApiHelper.get(uri, { facilityCd })
    .then(response => {
      resolvedMstRequests.set(requestKey, {
        data: response.data,
        resolvedAt: Date.now()
      });
      return response.data;
    })
    .catch(error => {
      logError(error);
      stackTrace.message = createErrorMessage(uri);
      throw stackTrace;
    })
    .finally(() => {
      pendingMstRequests.delete(requestKey);
    });
  pendingMstRequests.set(requestKey, request);

  return cloneMstData(await request);
};

/**
 * @description ログ出力用内部関数
 * @param {Error} error
 */
// TODO: ログ出力方式が未定なので暫定的にconsole使用
const logError = error => {
  // console.log(`WebAPIエラー`);
  if (error.response) {
    console.table(error.response.data);
    // console.log(error.response.status);
    // console.log(error.response.statusText);
    console.table(error.response.headers);
  } else if (error.request) {
    console.log(error.request);
  } else {
    console.log(error.message);
  }
};

class MstGetter {
  constructor(uri, facilityCd, alias = "facilityCd") {
    this.uri = uri;
    this.facilityCd = facilityCd;
    this.alias = alias;
  }

  async getMst() {
    const requestKey = createMstRequestKey(this.uri, this.alias, this.facilityCd);
    const resolvedRequest = resolvedMstRequests.get(requestKey);
    if (
      resolvedRequest &&
      Date.now() - resolvedRequest.resolvedAt < RESOLVED_MST_REQUEST_TTL_MS
    ) {
      return cloneMstData(resolvedRequest.data);
    }

    if (!pendingMstRequests.has(requestKey)) {
      const request = ApiHelper.get(this.uri, {
        [this.alias]: this.facilityCd
      })
        .then(({ data }) => {
          resolvedMstRequests.set(requestKey, {
            data,
            resolvedAt: Date.now()
          });
          return data;
        })
        .catch(error => {
          throw new Error(error);
        })
        .finally(() => {
          pendingMstRequests.delete(requestKey);
        });
      pendingMstRequests.set(requestKey, request);
    }

    return cloneMstData(await pendingMstRequests.get(requestKey));
  }

  async getMstSelector() {
    const result = await this.getMst().catch(error => {
      throw new Error(error);
    });
    if (!result) {
      return [];
    } else {
      return result.orderSettings.items;
    }
  }
}

// ベッド
export const bed = async facilityCd =>
  new MstGetter("/mstInfo/mstBed", facilityCd).getMst();
export const bedSelector = async facilityCd =>
  new MstGetter("/mstInfo/mst_bed/mstSelector", facilityCd).getMstSelector();
export const bedIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/selectAllByFacilityCd", facilityCd, "facility_cd").getMst();

// 診療科
export const course = async facilityCd =>
  new MstGetter("/mstInfo/mstCourse", facilityCd).getMst();
export const courseSelector = async facilityCd =>
  new MstGetter("/mstInfo/mst_course/mstSelector", facilityCd).getMstSelector();

// 透析困難
export const dialysisDifficulty = async facilityCd =>
  new MstGetter("/mstInfo/mstDialysisDifficulty", facilityCd).getMst();
export const dialysisDifficultySelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_dialysis_difficulty/mstSelector",
    facilityCd
  ).getMstSelector();

// ダイアライザ
export const dialyzer = async facilityCd =>
  new MstGetter("/mstInfo/mstDialyzer", facilityCd).getMst();
export const dialyzerSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_dialyzer/mstSelector",
    facilityCd
  ).getMstSelector();
export const dialyzerTabooAllergy = async patId =>
  new MstGetter(
    `/mstInfo/mstDialyzer/${patId}`).getMst();
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応 Start
export const dialyzerTabooAllergyNoexpire = async (patId, TreatDate) =>
  new MstGetter(
    `/mstInfo/mstDialyzer/${patId}/${TreatDate}`).getMst();
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応 End
/** 削除済み・期限切れも含めたダイアライザ(並び順(mst_selector)の考慮あり) */
export const dialyzerIncludeDeleted = async facilityCd =>
  new MstGetter(
    "/mstInfo/mstDialyzerIncludeDeleted",
    facilityCd
  ).getMst();
//#8484 医療材料選択IFのリスト不正 Start
/** 削除済み・期限切れ、禁忌・アレルギーも含めたダイアライザ(並び順(mst_selector)の考慮あり) */
export const dialyzerTabooAllergyIncludeDeleted = async patId =>
  new MstGetter(
    `/mstInfo/mstDialyzerTabooAllergyIncludeDeleted/${patId}`).getMst();
//#8484 医療材料選択IFのリスト不正 End
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
export const dialyzerTabooAllergyDeleted = async (patId) =>
  new MstGetter(
    `/mstInfo/mstDialyzerIncludeDel/${patId}`).getMst();
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end   
// 病名
export const disease = async facilityCd =>
  new MstGetter("/mstInfo/mstDisease", facilityCd).getMst();
//add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao start
export const diseaseIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstDiseaseIncludeDeleted", facilityCd).getMst();
//add 10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう zhao end
export const diseaseSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_disease/mstSelector",
    facilityCd
  ).getMstSelector();

// 医療材料
export const equipment = async facilityCd =>
  new MstGetter("/mstInfo/mstEquipment", facilityCd).getMst();
export const equipmentSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_equipment/mstSelector",
    facilityCd
  ).getMstSelector();

/** 削除済み・期限切れも含めた医療材料(並び順(mst_selector)の考慮あり) */
export const equipmentIncludeDeleted = async facilityCd =>
  new MstGetter(
    "/mstInfo/mstEquipmentIncludeDeleted",
    facilityCd
).getMst();

export const equipmentTabooAllergy = async patId =>
  new MstGetter(
    `/mstInfo/mstEquipment/${patId}`).getMst();
//#8484 医療材料選択IFのリスト不正 Start
/** 削除済み・期限切れ、禁忌・アレルギーも含めた医療材料(並び順(mst_selector)の考慮あり) */
export const equipmentTabooAllergyIncludeDeleted = async patId =>
  new MstGetter(
    `/mstInfo/mstEquipmentTabooAllergyIncludeDeleted/${patId}`).getMst();
//#8484 医療材料選択IFのリスト不正 End
// mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
export const equipmentAllergy = async (patId, isDelFlg) =>
  new MstGetter(
    `/mstInfo/mstEquipment/${patId}/${isDelFlg}`).getMst();
// mod FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

export const facilitySort = async () => {
  const response = await ApiHelper.get("/mstInfo/mstFacility/kanaSort").catch(error => {
    throw new Error(error);
  });
  return response.data;
};

export const facilityByCd = async facilityCd => {
  const response = await ApiHelper.get(
    `/mstInfo/mstFacility/${facilityCd}`
  ).catch(error => {
    throw new Error(error);
  });
  return response.data;
};

// インプラント
export const implant = async facilityCd =>
  new MstGetter("/mstInfo/mstImplant", facilityCd).getMst();
/*add FNSI-改修内容5237 任 start*/
export const implantDel = async facilityCd =>
  new MstGetter("/mstInfo/mstImplantDel", facilityCd).getMst();
/*add FNSI-改修内容5237 任 end*/
export const implantIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstImplantIncludeDel", facilityCd).getMst();
export const implantSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_implant/mstSelector",
    facilityCd
  ).getMstSelector();

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
// 加算・管理科
export const addition = async facilityCd =>
  new MstGetter("/mstInfo/mstAddition", facilityCd).getMst();
export const additionSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_addition/mstSelector",
    facilityCd
  ).getMstSelector();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end

// 感染症
export const infection = async facilityCd =>
  new MstGetter("/mstInfo/mstInfection", facilityCd).getMst();
export const infectionIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstInfectionIncludeDel", facilityCd).getMst();
export const infectionSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_infection/mstSelector",
    facilityCd
  ).getMstSelector();

// クール
export const kur = async facilityCd =>
  new MstGetter("/mstInfo/mstKur", facilityCd, "facility_cd").getMst();
export const kurSelector = async facilityCd =>
  new MstGetter("/mstInfo/mst_kur/mstSelector", facilityCd).getMstSelector();

// 薬剤
export const medicine = async facilityCd =>
  new MstGetter("/mstInfo/mstMedicine", facilityCd).getMst();
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
export const medicineIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstMedicineIncludeDeleted", facilityCd).getMst();
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export const medicineSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_medicine/mstSelector",
    facilityCd
  ).getMstSelector();
export const medicineTabooAllergy = async patId =>
  new MstGetter(`/mstInfo/mstMedicine/${patId}`).getMst();
/* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --start */
export const medicineTabooAllergyByCd = async (patId, medicine_cd) =>
    new MstGetter(`/mstInfo/mstMedicineByCd/${patId}/${medicine_cd}`).getMst();
/* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --end */
// mod FNSI-期限切れ削除済みと表示するの修正 李 start
export const medicineAllergy = async (patId, is_Del_Flg) =>
  new MstGetter(`/mstInfo/mstMedicine/${patId}/${is_Del_Flg}`).getMst();
// mod FNSI-期限切れ削除済みと表示するの修正 李 end

// マルチ患者レイアウト
export const patListLayout = async facilityCd =>
  new MstGetter("/mstInfo/getPatListLayout", facilityCd).getMst();
export const patListLayoutSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_pat_list_layout/mstSelector",
    facilityCd
  ).getMstSelector();

// 重症度
export const severity = async facilityCd =>
  new MstGetter("/mstInfo/mstSeverity", facilityCd).getMst();
export const severitySelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_severity/mstSelector",
    facilityCd
  ).getMstSelector();

// 搬送区分
export const transport = async facilityCd =>
  new MstGetter("/mstInfo/mstTransport", facilityCd).getMst();
export const transportSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_transport/mstSelector",
    facilityCd
  ).getMstSelector();

// 治療方法
export const treatment = async facilityCd =>
  new MstGetter("/mstInfo/mstTreatment", facilityCd).getMst();
export const treatmentSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_treatment/mstSelector",
    facilityCd
  ).getMstSelector();

// mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
// 治療方法削除済のデータ
export const treatmentDel = async facilityCd =>
new MstGetter("/mstInfo/mstTreatmentDel", facilityCd).getMst();
// mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
export const treatmentIncludeDeleted = async facilityCd =>
new MstGetter("/mstInfo/mstTreatmentIncludeDeleted", facilityCd).getMst();

// ユーザ
export const user = async facilityCd =>
  new MstGetter("/mstInfo/mstPersonalUser", facilityCd, "facility_cd").getMst();

// VA
export const va = async facilityCd =>
  new MstGetter("/mstInfo/mstVa", facilityCd).getMst();
export const vaSelector = async facilityCd =>
  new MstGetter("/mstInfo/mst_va/mstSelector", facilityCd).getMstSelector();
export const vaIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstVaIncludeDel", facilityCd).getMst();

// 病棟
export const ward = async facilityCd =>
  new MstGetter("/mstInfo/mstWard", facilityCd).getMst();
export const wardSelector = async facilityCd =>
  new MstGetter("/mstInfo/mst_ward/mstSelector", facilityCd).getMstSelector();

// 患者カレンダーレイアウト
export const patCalendarLayout = async facilityCd =>
  new MstGetter("/mstInfo/getPatCalendarLayout", facilityCd).getMst();
// 施設カレンダーレイアウト
export const facilityCalendarLayout = async facilityCd =>
  new MstGetter("/mstInfo/getFacilityCalendarLayout", facilityCd).getMst();

/**
 * @description 医療材料分類マスタ
 * @returns {Array} マスタの配列
 */
export const equipmentClass = async facilityCd => {
  const uri = "/mstInfo/mstEquipmentClass";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 医療材料セットマスタ
 * @returns {Array} マスタの配列
 */
export const equipmentSet = async facilityCd => {
  const uri = "/mstInfo/mstEquipmentSet";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};
export const equipmentSetTabooAllergy = async patId => {
  const uri = "/mstInfo/mstEquipmentSet/" + patId;
  const result = await ApiHelper.get(uri).catch(error => {
    throw error;
  });
  return result.data;
};

// FNSI-修正 マスタ削除の対応 wangchen add start
export const equipmentSetWithDeleted = async patId => {
  const uri = "/mstInfo/mstEquipmentSetWithDeleted/" + patId;
  const result = await ApiHelper.get(uri).catch(error => {
    throw error;
});
  return result.data;
};
// FNSI-修正 マスタ削除の対応 wangchen add end
// add #11603 検査予定のラベル出力とフィルタ機能 高 start
/**
 * @description 医療材料分類マスタ
 * @returns {Array} マスタの配列
 */
export const examSetClass = async facilityCd => {
  const uri = "/mstInfo/mstExamSet";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};
// add #11603 検査予定のラベル出力とフィルタ機能 高 end
/**
 * @description 薬剤分類マスタ
 * @returns {Array} マスタの配列
 */
export const medicineClass = async facilityCd => {
  const uri = "/mstInfo/mstMedicineClass";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 薬剤セットマスタ
 * @returns {Array} マスタの配列
 */
export const medicineSet = async facilityCd => {
  const uri = "/mstInfo/mstMedicineSet";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};
export const medicineSetTabooAllergy = async patId => {
  const uri = "/mstInfo/mstMedicineSet/" + patId;
  const result = await await ApiHelper.get(uri).catch(error => {
    throw error;
  });
  return result.data;
};

// FNSI-修正 マスタ削除の対応 wangchen add start
export const medicineSetWithDeleted= async patId => {
  const uri = "/mstInfo/mstMedicineSetWithDeleted/" + patId;
  const result = await await ApiHelper.get(uri).catch(error => {
    throw error;
});
  return result.data;
};
// FNSI-修正 マスタ削除の対応 wangchen add end

/**
 * @description 患者メモマスタ
 * @returns {Array} マスタの配列
 */
export const patMemo = async facilityCd => {
  const uri = "/mstInfo/mstPatMemo";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 手技マスタ
 * @returns {Array} マスタの配列
 */
export const procedure = async facilityCd => {
  const uri = "/mstInfo/mstProcedure";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description ベッドグループ・透析室マスタ
 * @returns {Array} マスタの配列 ※bed_list(ベッド一覧)はデシリアライズして返す
 */
export const roomBedGroup = async facilityCd => {
  const uri = "/mstInfo/mstRoomBedGroup";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result.map(mst => {
    return { ...mst, bedList: JSON.parse(mst.bedList) };
  });
};

/**
 * @description 禁忌・アレルギーマスタ
 * @returns {Array} マスタの配列 detail_info(詳細)はデシリアライズして返す
 */
export const tabooAllergy = async facilityCd => {
  const uri = "/mstInfo/mstTabooAllergy";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result.map(mst => {
    return { ...mst, detailInfo: JSON.parse(mst.detailInfo) };
  });
};
export const tabooAllergySelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_taboo_allergy/mstSelector",
    facilityCd
  ).getMstSelector();

/**
 * @description 治療方法セットマスタ
 * @returns {Array} マスタの配列
 */
export const treatmentSet = async facilityCd => {
  const uri = "/mstInfo/mstTreatmentSet";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 投与タイミングマスタ
 * @returns {Array} マスタの配列
 */
export const medicateTiming = async facilityCd => {
  const uri = "/mstInfo/mstMedicateTiming";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 患者経過総合ビューアレイアウトマスタ
 * @returns {Array} マスタの配列
 */
export const mstPatViewerLayout = async facilityCd => {
  const uri = "/mstInfo/mstPatViewerLayout";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description 共通定型文マスタ
 * @returns {Array} マスタの配列
 */
export const mstComFixedPhrase = async facilityCd => {
  const uri = "/mstInfo/mstComFixedPhrase";
  const result = await getMstByFacilityCd(uri, facilityCd).catch(error => {
    throw error;
  });
  return result;
};

/**
 * @description プリンターマスタ
 * @returns {Array} マスタの配列
 */
export const mstPrinterSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_printer/mstSelector",
    facilityCd
  ).getMstSelector();

// 調製薬剤
export const medicineMix = async facilityCd =>
  new MstGetter("/mstInfo/mstMedicineMix", facilityCd).getMst();
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
export const medicineMixIncludeDeleted = async facilityCd =>
  new MstGetter("/mstInfo/mstMedicineMixIncludeDeleted", facilityCd).getMst();
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export const medicineMixSelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_medicine_mix/mstSelector",
    facilityCd
  ).getMstSelector();

// 患者イベント
export const patEventCategory = async facilityCd =>
  new MstGetter("/mstInfo/mstPatEventCategory", facilityCd).getMst();
export const patEventCategorySelector = async facilityCd =>
  new MstGetter(
    "/mstInfo/mst_pat_event_category/mstSelector",
    facilityCd
  ).getMstSelector();
  
// 患者イベントサブカテゴリ
export const patEventSubCategoryIncludeDeleted = async facilityCd =>
new MstGetter("/mstInfo/mstPatEventSubCategoryIncludeDeleted", facilityCd).getMst();

export const medicineMixTabooAllergy = async patId =>
  new MstGetter(`/mstInfo/mstMedicineMix/${patId}`).getMst();
/* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --start */
export const medicineMixTabooAllergyByCd = async (patId, medicine_cd) =>
    new MstGetter(`/mstInfo/mstMedicineMixByCd/${patId}/${medicine_cd}`).getMst();
/* add by chamaojia 2024-02-28 [10196] Add an interface for querying "medicine_cd" --end */

// add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 start
export const medicineMixAllergy = async (patId, isDelFlg) =>
  new MstGetter(`/mstInfo/mstMedicineMix/${patId}/${isDelFlg}`).getMst();
// add FNSI-障害票一覧_患者経過総合ビューアNo.46-47 李 end

// 外部リンク登録マスタを取得する
export const getMstUrlLinkRegister = facilityCd =>
  new MstGetter("/mstInfo/mstUrlLinkRegister", facilityCd).getMst();
  
// メニューグループマスタを取得する
export const getMstMenuGroup = facilityCd =>
  new MstGetter("/mstInfo/mstMenuGroup", facilityCd).getMst();

// 職種マスタを取得する
export const getMstJob = facilityCd =>
  new MstGetter("/mstInfo/mstJob", facilityCd).getMst();

export const getMstCoopFacility = facilityCd =>
  new MstGetter("/mstInfo/mstCoopFacility", facilityCd).getMst();

// 掲示板種別マスタ
export const bbsKindIncludeDeleted = async facilityCd =>
new MstGetter("/mstInfo/mstBbsKindIncludeDeleted", facilityCd).getMst();
