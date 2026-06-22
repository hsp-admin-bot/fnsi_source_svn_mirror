import dayjs from "@/compat/date/dayjs";
import Indication from "@/apis/indication";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { sendRequestGetMstFacilitySettingData as getMstFacitilySettingData } from "@/apis/mst-facility-setting-maintenance";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestUserAccountInfo as getUserAccountInfo } from "@/apis/User";
import { sendRequestGetDoctorsAtFacility } from "@/apis/facility";
import {
  INDICATION_RECEIVE_1,
  INDICATION_RECEIVE_2,
  INDICATION_APPROVE_1,
  INDICATION_APPROVE_2,
  INSTRUCTION_APPROVAL_SETTING,
  DEFAULT_SEL_DOCTOR
} from "@/constants/facilitySetting";
/* modify by chamaojia 2025-03-26 [10739] change the referenced JS file --start */
// import { mstPatViewerLayoutDefine } from "@/constants/mstPatViewerLayoutDefine";
import { mstPatViewerLayoutToIndicationDefine } from "@/constants/mstPatViewerLayoutToIndicationDefine";
/* modify by chamaojia 2025-03-26 [10739] change the referenced JS file --end */
import {
  va as getMstVA,
  dialyzer as getMstDialyzer,
  equipment as getMstEquipment,
  medicine as getMstMedicine,
  medicineMix as getMstMedicineMix
} from "@/functions/mst/MstGetters.js";
import BigNumber from "@/compat/number/bignumber";
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
// FNSI-修正 マスタ削除の対応 chen add start
import {CODES, MASTER_DELETE_DISPLAY} from "@/constants/TreatmentRecord";
import {fitTermCheck} from "@/functions/common/DateTimeUtils";
import {DEVICEMODE} from "@/constants/mstTreatmentDefine";
// FNSI-修正 マスタ削除の対応 chen add end
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
import { addPatNameSortToList } from "@/functions/SortFunctions";

export const FACILITY_TYPES = {
  TREATMENT_UNIT: 1,
  INDICATION_UNIT: 2
};

export const FACILITY_SETTING_NO = {
  FACILITY_TYPE: 1023
};

export const LAYOUT_CATE_NO = 1;
export const LAYOUT_SUB_CATE_NO = [2, 3, 4, 5, 6, 7];

const sortByPatName = (list) => {
  return [...list].sort((a, b) => {
    return a.patNameSort.localeCompare(b.patNameSort);
  });
};

export default {
  namespaced: true,
  strict: !import.meta.env.PROD,
  state: {
    // del #10150 piao Start
    // // 姜
    // treatmentSetDayDisplayFlg: true,
    // del #10150 piao end
    // 姜
    isTreatmentUnit: true,
    // add bug #4630 修正 chen start
    isAllApproverUnit: true,
    // add bug #4630 修正 chen end
    userId: 0,
    isDoctor: false,
    indications: [],
    mstTreatment: [],
    mstKur: [],
    mstPersonalUser: [],
    mstRoomBedGroup: [],
    patPersonal: null,
    selectedIndIndex: 0,
    treatmentSearchCondition: null,
    indicationSearchCondition: null,
    mstBed: [],
// FNSI-修正 マスタ削除の対応 chen add start
    mstTreatmentDel: [],
    mstKurDel: [],
    mstBedDel: [],
    mstEquipmentDel: [],
    mstDialyzerDel: [],
    mstVADel: [],
// FNSI-修正 マスタ削除の対応 chen add end
    sortedIndicationsList: [],
    treatmentIndications: [],
    treatmentIndicationSortStatus: {
      id: 1,
      name: 1,
      treatment: 1,
      kur: 1,
      bed: 1,
      check1: 1,
      check2: 1,
      approve1: 1,
      approve2: 1
    },
    indicationsUnchecked: {
      receiver1: false,
      receiver2: false,
      approver1: false,
      approver2: false
    },
    doctorsAtFacility: [],
    columnStatus: {
      isShowChecker1: true,
      isShowChecker2: true,
      isShowApprover1: true,
      isShowApprover2: true,
    },
    indContentList: [],
    indContent: [],
    defaultDoctor: null,
    facilityInsApp: null
  },
  getters: {
    // del #10150 piao Start
    // // 姜
    // treatmentSetDayDisplayFlg: state => state.treatmentSetDayDisplayFlg,
    // del #10150 piao end
    // 姜
    isTreatmentUnit({ isTreatmentUnit }) {
      return isTreatmentUnit;
    },
    // add bug #4630 修正 chen start
    isAllApproverUnit({ isAllApproverUnit }) {
      return isAllApproverUnit;
    },
    // add bug #4630 修正 chen end
    userId({ userId }) {
      return userId;
    },
    isDoctor({ isDoctor }) {
      return isDoctor;
    },
    mstTreatment({ mstTreatment }) {
      return mstTreatment;
    },
    mstKur({ mstKur }) {
      return mstKur;
    },
    mstPersonalUser({ mstPersonalUser }) {
      return mstPersonalUser;
    },
    mstRoomBedGroup({ mstRoomBedGroup }) {
      return mstRoomBedGroup;
    },
    treatmentIndications({ treatmentIndications }) {
      return treatmentIndications;
    },
    sortedIndications({ indications }) {
      return [...indications].sort((a, b) => {
        // 指示受けの有無（未チェックが上位）
        if (!a.checker && b.checker) {
          return -1;
        }

        if (a.checker && !b.checker) {
          return 1;
        }

        // 指示承認の有無（未チェックが上位）
        if (!a.approver && b.approver) {
          return -1;
        }

        if (a.approver && !b.approver) {
          return -1;
        }

        // 指示受け時刻(降順)
        if (a.received_at !== b.received_at) {
          return b.received_at - a.received_at;
        }

        // 指示承認時刻(降順)
        if (a.approved_at !== b.approved_at) {
          return b.approved_at - a.approved_at;
        }

        // 透析開始時刻(昇順)
        return a.dialysis_start_at - b.dialysis_start_at;
      });
    },
    patPersonal({ patPersonal }) {
      return patPersonal;
    },
    selectedIndIndex({ selectedIndIndex }) {
      return selectedIndIndex;
    },
    treatmentSearchCondition({ treatmentSearchCondition }) {
      return treatmentSearchCondition;
    },
    indicationSearchCondition({ indicationSearchCondition }) {
      return indicationSearchCondition;
    },
    columnStatus({ columnStatus }) {
      return columnStatus;
    },
    mstBed({ mstBed }) {
      return mstBed;
    },
// FNSI-修正 マスタ削除の対応 chen add start
    mstTreatmentDel({ mstTreatmentDel }) {
      return mstTreatmentDel;
    },
    mstKurDel({ mstKurDel }) {
      return mstKurDel;
    },
    mstBedDel({ mstBedDel }) {
      return mstBedDel;
    },
    mstEquipmentDel({ mstEquipmentDel }) {
      return mstEquipmentDel;
    },
    mstDialyzerDel({ mstDialyzerDel }) {
      return mstDialyzerDel;
    },
    mstVADel({ mstVADel }) {
      return mstVADel;
    },
// FNSI-修正 マスタ削除の対応 chen add end
    sortedIndicationsList({ sortedIndicationsList }) {
      return sortedIndicationsList;
    },
    initSortedIndicationList({ indications }) {
      // システム共通患者名ソート仕様 昇順でソート
      return sortByPatName(indications);
    },
    selectedAll({ indications }) {
      const selectedAll = {
        totalCheck1: 0,
        totalCheck2: 0,
        totalApprover1: 0,
        totalApprover2: 0,
        summary: 0
      };

      [...indications].forEach(indication => {
        selectedAll.totalCheck1 = selectedAll.totalCheck1 + indication.check1;
        selectedAll.totalCheck2 = selectedAll.totalCheck2 + indication.check2;
        selectedAll.totalApprover1 =
          selectedAll.totalApprover1 + indication.approver1;
        selectedAll.totalApprover2 =
          selectedAll.totalApprover2 + indication.approver2;
        selectedAll.summary = selectedAll.summary + indication.total;
      });
      return selectedAll;
    },
    indicationsUnchecked({ indicationsUnchecked }) {
      return indicationsUnchecked;
    },
    doctorsAtFacility({ doctorsAtFacility }) {
      return doctorsAtFacility;
    },
    getTreatmentIndicationSortStatus: state => field => {
      return state.treatmentIndicationSortStatus[field];
    },
    treatmentIndicationSortingField({ treatmentIndicationSortStatus }) {
      let tmp = null;

      Object.keys(treatmentIndicationSortStatus).forEach(field => {
        if (treatmentIndicationSortStatus[field] !== 1) {
          tmp = field;
        }
      });

      return tmp;
    },
    indContentList({indContentList}) {
      return indContentList;
    },
    indContent({indContent}) {
      return indContent;
    },
    defaultDoctor({ defaultDoctor} ) {
      return defaultDoctor;
    },
    facilityInsApp({ facilityInsApp }) {
      return facilityInsApp;
    }
  },
  actions: {
    async checkFacilitySetting({ commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      const facilityTypeRes = await getMstFacilitySettingValue(
        facilityCd,
        FACILITY_SETTING_NO.FACILITY_TYPE
      );
      const facilityType = facilityTypeRes.data;
      const facilityDataRes = await getMstFacitilySettingData(facilityCd);
      const facilityData = facilityDataRes.data.localDataSource.data;
      const columnData = {
        isShowChecker1 : !!+facilityData.find(e => e.facilitySettingNo === INDICATION_RECEIVE_1).value,
        isShowChecker2 : !!+facilityData.find(e => e.facilitySettingNo === INDICATION_RECEIVE_2).value,
        isShowApprover1 : !!+facilityData.find(e => e.facilitySettingNo === INDICATION_APPROVE_1).value,
        isShowApprover2 : !!+facilityData.find(e => e.facilitySettingNo === INDICATION_APPROVE_2).value,
      };

      const facilityTypeDoc = await getMstFacilitySettingValue(
        facilityCd,
        DEFAULT_SEL_DOCTOR
      );
      const defaultDoctor = facilityTypeDoc.data;
      const facilityInsApp = facilityData.find(e => e.facilitySettingNo === INSTRUCTION_APPROVAL_SETTING).value;

      // add bug #4630 修正 chen start
      const facilityAllTypeRes = await getMstFacilitySettingValue(
        facilityCd,
        "1024"
      );
      const facilityAllType = facilityAllTypeRes.data;
      commit(
        "setIsAllApproverUnit",
        facilityAllType === 1
      );
      // add bug #4630 修正 chen end

      commit(
        "setIsTreatmentUnit",
        facilityType === FACILITY_TYPES.TREATMENT_UNIT
      );
      commit("setColumnStatus", columnData);
      commit("setDefaultDoctor", defaultDoctor)
      commit("setFacilityInsApp", facilityInsApp)
    },
    async getUserInfo({ commit }) {
      const userInfoRes = await getUserAccountInfo();
      commit("setUserId", userInfoRes.data.userAccountInfo.userId);
    },
    async checkIsDoctor({ commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      const [userInfo, jobs] = await Promise.all([
        getUserAccountInfo(),
        ApiHelper.get(`/master_maintenance/mst_user/mst_job/${facilityCd}`)
      ]);

      const job = jobs.data.find(
        job => +job.jobCd === +userInfo.data.userAccountInfo.jobCd
      );

      commit("setUserId", userInfo.data.userAccountInfo.userId);
      commit("setIsDoctor", job ? !!+job.isDoctor : false);
    },
    async getMst({ commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      await Promise.all([
        getMstTreatment(commit, facilityCd),
        getMstKur(commit, facilityCd),
        getMstPersonalUser(commit, facilityCd),
        getMstRoomBedGroup(commit, facilityCd),
        getMstBed(commit, facilityCd),
        getDoctorsAtFacility(commit, facilityCd),
// FNSI-修正 マスタ削除の対応 chen add start
        getMstTreatmentDel(commit, facilityCd),
        getMstKurDel(commit, facilityCd),
        getMstBedDel(commit, facilityCd),
        getMstEquipmentDel(commit, facilityCd),
        getMstDialyzerDel(commit, facilityCd),
        getMstVADel(commit, facilityCd)
// FNSI-修正 マスタ削除の対応 chen add end
      ]);
    },
    async getIndications({ state, commit, rootGetters }) {
      const facilityCd = rootGetters["user/getFacilityCd"];

      let condition = state.isTreatmentUnit
        ? makeTreatmentConditionParams(state)
        : makeIndicationConditionParams(state);

      condition = { ...condition, facilityCd }

      let indications = state.isTreatmentUnit
        ? await Indication.list(condition)
        : await Indication.searchList(condition);
      // add 入外区分が入院の場合、患者名は紫色にする chen start
      // 患者リストを再検索する
      const uriPersonalMain = "/patInfo/getPatPersonalMainByList";
      const searchedPatIdList = state.isTreatmentUnit
        ? indications.map(pat => pat.pat_id) : indications.map(pat => pat.patId);
      const resPersonalMain = await ApiHelper.post(uriPersonalMain, searchedPatIdList).catch(() => {
        throw new Error("検索失敗");
      });

      // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm start
      let indicationsTmp = [];
      // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm end
      indications.forEach(indication => {
        indication.is_same = "";
        indication.in_out_class = "";
        const resPersonal =  resPersonalMain.data.find(item => item.pat_id === indication.pat_id || item.pat_id == indication.patId);
        if (resPersonal) {
          indication.in_out_class = resPersonal.in_out_class;
          indication.is_same = resPersonal.is_same;
          indication.pat_last_name_kana = resPersonal.pat_last_name_kana;
          indication.pat_last_name = resPersonal.pat_last_name;
          indication.pat_first_name_kana = resPersonal.pat_first_name_kana;
          indication.pat_first_name = resPersonal.pat_first_name;
          // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm start
          indicationsTmp.push(indication);
          // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm end
        }
      });

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      indicationsTmp = addPatNameSortToList(indicationsTmp);

      // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm start
      indications = indicationsTmp;
      // add 11763 指示受け・指示承認画面（指示単位）の動作不正② zkm end

      // add 入外区分が入院の場合、患者名は紫色にする chen end
      if (state.isTreatmentUnit) {
        indications.forEach(indication => {
          // mod 9485 nullを空文字列判定に変換します 張博 start
          indication.pat_full_name = `${indication.pat_last_name === null ? "" : indication.pat_last_name} ${indication.pat_first_name === null ? "" : indication.pat_first_name}`;
          // mod 9485 nullを空文字列判定に変換します 張博 end
        });
        // 治療単位 画面起動時に患者名でソート ※指示単位はinitSortedIndicationListで同様にソート実施
        state.treatmentIndications = sortByPatName(indications);
      }

      //6299 test
      let tmpStr = "6299_getIndications: ";
      indications.forEach(indication => {
        tmpStr = tmpStr + indication.pat_id + ", ";
      });
      console.log(`${tmpStr}`);

      commit("setIndications", indications);
    },
    async getPatPersonal({ commit }, patId) {
      const res = await ApiHelper.get(
        `/patPersonalMain/getPatPersonalMain/${patId}`
      );
      const patPersonal = JSON.parse(res.data.pat_personal_main);
      commit("setPatPersonal", patPersonal);
    },
    setTreatmentSearchCondition({ commit }, condition) {
      commit("setTreatmentSearchCondition", condition);
    },
    setTreatmentSearchConditionNULL({ commit }, condition) {
      commit("setTreatmentSearchConditionNULL", condition);
    },
    setIndicationSearchCondition({ commit }, condition) {
      commit("setIndicationSearchCondition", condition);
    },
    setIndicationSearchConditionNULL({ commit }, condition) {
      commit("setIndicationSearchConditionNULL", condition);
    },
    setSelectedIndIndex({ commit }, selectedIndIndex) {
      commit("setSelectedIndIndex", selectedIndIndex);
    },
    clearState({ commit }) {
      commit("clearState");
    },
    clearToggleColumns({ commit }) {
      commit("clearToggleColumns");
    },
    setColumnStatus({ commit }, columnStatus) {
      commit("setColumnStatus", columnStatus);
    },
    setSortedIndicationsList({ commit }, sortedIndicationsList) {
      commit("setSortedIndicationsList", sortedIndicationsList);
    },
    setIndicationsUnchecked({ commit }, indicationsUnchecked) {
      commit("setIndicationsUnchecked", indicationsUnchecked);
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    async setIndContentList({ state, commit, rootGetters }, indInfo) {
      const {ordNoList, selectedPatList} = indInfo;
      if(ordNoList.length > 0) {
        const facilityCd = rootGetters["user/getFacilityCd"];
        const [
          mstVA,
          mstDialyzer,
          mstEquipment,
          mstMedicine,
          mstMedicineMix,
          mstMedicineIncludeDeleted,
          mstMedicineMixIncludeDeleted,
        ] = await Promise.all([
          getMstVA(facilityCd),
          getMstDialyzer(facilityCd),
          getMstEquipment(facilityCd),
          getMstMedicine(facilityCd),
          getMstMedicineMix(facilityCd),
          ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", {
            facilityCd: facilityCd
          }),
          ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", {
            facilityCd: facilityCd
          }),
        ]);
        const indContentList = await indicationContentList(
          ordNoList,
          state.mstBed,
          mstVA,
          mstDialyzer,
          mstEquipment,
          mstMedicine,
          mstMedicineMix,
          state.mstKur,
          state.mstPersonalUser,
          state.mstTreatment,
          selectedPatList,
          facilityCd,
          mstMedicineIncludeDeleted,
          mstMedicineMixIncludeDeleted,
          state);
        commit("setIndContentList", indContentList);
      }
    },
    async setIndContent({ state, commit, rootGetters }, {ordDetail, selectedPat}) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      const selectedPatInfo = selectedPat ? selectedPat : rootGetters["pat-info/selectedPat"];
      let patId = ordDetail.patId;
      const [
        mstVA,
        mstDialyzer,
        mstEquipment,
        mstMedicine,
        mstMedicineMix,
        mstMedicineIncludeDeleted,
        mstMedicineMixIncludeDeleted,
        mstDialyzerIncludeDel,
        mstEquipmentIncludeDel,
        mstMedicineIncludeDel,
        mstMedicineMixIncludeDel,
      ] = await Promise.all([
        getMstVA(facilityCd),
        getMstDialyzer(facilityCd),
        getMstEquipment(facilityCd),
        getMstMedicine(facilityCd),
        getMstMedicineMix(facilityCd),
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", {
          facilityCd: facilityCd
        }),
        ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", {
          facilityCd: facilityCd
        }),
        ApiHelper.get(`/mstInfo/mstDialyzerIncludeDel/${patId}`),
        ApiHelper.get(`/mstInfo/mstEquipment/${patId}/true`),
        ApiHelper.get(`/mstInfo/mstMedicine/${patId}/true`),
        ApiHelper.get(`/mstInfo/mstMedicineMix/${patId}/true`)
      ]);

      const content = getIndDetailLayout(
        ordDetail,
        mstMedicine,
        state.mstPersonalUser,
        mstMedicineMix,
        mstEquipment,
        state.mstKur,
        state.mstBed,
        mstVA,
        mstDialyzer,
        state.mstTreatment,
        selectedPatInfo,
        facilityCd,
        mstMedicineIncludeDeleted,
        mstMedicineMixIncludeDeleted,
        mstDialyzerIncludeDel,
        mstEquipmentIncludeDel,
        mstMedicineIncludeDel,
        mstMedicineMixIncludeDel,
        state)
      commit("setIndContent", content);
    },
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

    setDefaultDoctor({ commit }, defaultDoctor) {
      commit("setDefaultDoctor", defaultDoctor);
    },
    setFacilityInsApp({ commit }, facilityInsApp) {
      commit("setFacilityInsApp", facilityInsApp);
    },

  },
  mutations: {
    // del #10150 piao start
    // // 姜
    // setTreatmentSetDayDisplayFlg: (state, b) => {
    //   state.treatmentSetDayDisplayFlg = b;
    // },
    // del #10150 piao end

    // 姜
    setIsTreatmentUnit(state, isTreatmentUnit) {
      state.isTreatmentUnit = isTreatmentUnit;
    },
    // add bug #4630 修正 chen start
    setIsAllApproverUnit(state, isAllApproverUnit) {
      state.isAllApproverUnit = isAllApproverUnit;
    },
    // add bug #4630 修正 chen end
    setUserId(state, userId) {
      state.userId = userId;
    },
    setIsDoctor(state, isDoctor) {
      state.isDoctor = isDoctor;
    },
    setMstTreatment(state, mstTreatment) {
      state.mstTreatment = mstTreatment;
    },
    setMstKur(state, mstKur) {
      state.mstKur = mstKur;
    },
    setMstPersonalUser(state, mstPersonalUser) {
      state.mstPersonalUser = mstPersonalUser;
    },
    setMstRoomBedGroup(state, roomBedGroup) {
      state.mstRoomBedGroup = roomBedGroup;
    },
    setIndications(state, indications) {
      state.indications = indications;
    },
    setPatPersonal(state, patPersonal) {
      state.patPersonal = patPersonal;
    },
    setTreatmentSearchCondition(state, condition) {
      // 治療方法存在チェック
      if (!state.mstTreatment.some(t => +t.treatmentCd === +condition.treatmentCd)) {
        condition.treatmentCd = "0";
      }
      // クール存在チェック
      const validMstKurCd = state.mstKur.map(k => k.kurCd);
      condition.kurCds = condition.kurCds.filter(value => validMstKurCd.includes(value));
      // 指示者存在チェック
      if (!state.mstPersonalUser.some(t => +t.userId === +condition.instructorId)) {
        condition.instructorId = "0";
      }
      // ベッドグループ存在チェック
      if(!state.mstRoomBedGroup.some(rbr => +rbr.roomBedGroupCd === +condition.bedGroupCd))
      {
        condition.bedGroupCd = "0";
      }

      state.treatmentSearchCondition = {
        ...condition,
        kurCds: [...condition.kurCds]
      };
    },
    setTreatmentSearchConditionNULL(state, condition) {
      state.treatmentSearchCondition = condition;
    },
    setIndicationSearchCondition(state, condition) {
      // クール存在チェック
      const validMstKurCd = state.mstKur.map(k => k.kurCd);
      condition.kurCds = condition.kurCds.filter(value => validMstKurCd.includes(value));
      // 指示者存在チェック
      if (!state.mstPersonalUser.some(t => +t.userId === +condition.userId)) {
        condition.userId = "0";
      }
      // ベッドグループ存在チェック
      if(!state.mstRoomBedGroup.some(rbr => +rbr.roomBedGroupCd === +condition.bedGroupCd))
      {
        condition.bedGroupCd = "0";
      }
      state.indicationSearchCondition = {
        ...condition,
        kurCds: [...condition.kurCds]
      };
    },
    setIndicationSearchConditionNULL(state, condition) {
      state.indicationSearchCondition = condition;
    },
    setSelectedIndIndex(state, selectedIndIndex) {
      state.selectedIndIndex = selectedIndIndex;
    },
    clearState(state) {
      state.isTreatmentUnit = null;
      // add bug #4630 修正 chen start
      state.isAllApproverUnit = null;
      // add bug #4630 修正 chen end
      state.isDoctor = false;
      state.indications = [];
      state.mstTreatment = [];
      state.mstKur = [];
      state.mstPersonalUser = [];
      state.mstRoomBedGroup = [];
    },
    setMstBed(state, mstBed) {
      state.mstBed = mstBed;
    },
// FNSI-修正 マスタ削除の対応 chen add start
    setMstTreatmentDel(state, mstTreatmentDel) {
      state.mstTreatmentDel = mstTreatmentDel;
    },
    setMstKurDel(state, mstKurDel) {
      state.mstKurDel = mstKurDel;
    },
    setMstBedDel(state, mstBedDel) {
      state.mstBedDel = mstBedDel;
    },
    setMstEquipmentDel(state, mstEquipmentDel) {
      state.mstEquipmentDel = mstEquipmentDel;
    },
    setMstDialyzerDel(state, mstDialyzerDel) {
      state.mstDialyzerDel = mstDialyzerDel;
    },
    setMstVADel(state, mstVADel) {
      state.mstVADel = mstVADel;
    },
// FNSI-修正 マスタ削除の対応 chen add end
    setColumnStatus(state, columnStatus) {
      state.columnStatus = columnStatus;
    },
    setSortedIndicationsList(state, sortedIndicationsList) {
      state.sortedIndicationsList = sortedIndicationsList;
    },
    setIndicationsUnchecked(state, indicationsUnchecked) {
      state.indicationsUnchecked = indicationsUnchecked;
    },
    setDoctorsAtFacility(state, doctorsAtFacility) {
      state.doctorsAtFacility = doctorsAtFacility;
    },
    setTreatmentIndications(state, list) {
      state.treatmentIndications = list;
    },
    setTreatmentIndicationSortStatus(state, sort) {
      state.treatmentIndicationSortStatus[sort.field] = sort.type;
    },
    resetTreatmentIndications(state) {
      const sorted = sortByPatName(state.indications);
      if (state.isTreatmentUnit) {
        state.treatmentIndications = sorted;
      } else {
        state.sortedIndicationsList = sorted;
      }
    },
    resetTreatmentIndicationSortStatus(state) {
      state.treatmentIndicationSortStatus = {
        id: 1,
        name: 1,
        treatment: 1,
        kur: 1,
        bed: 1,
        check1: 1,
        check2: 1,
        approve1: 1,
        approve2: 1
      };
    },
    updateTreatmentIndicationItem(state, item) {
      state.treatmentIndications.forEach((index, indication) => {
        if (indication.ord_no === item.ord_no) {
          state.treatmentIndications[index] = item;
        }
      })
    },
    setIndContentList(state, indContentList) {
      state.indContentList = indContentList;
    },
    setIndContent(state, indContent) {
      state.indContent = indContent;
    },
    setDefaultDoctor(state, defaultDoctor) {
      state.defaultDoctor = defaultDoctor;
    },
    setFacilityInsApp(state, facilityInsApp) {
      state.facilityInsApp = facilityInsApp;
    }
  }
};

async function getMstTreatment(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstTreatment", {
    facilityCd
  });
  res.data.unshift({ treatmentName: "全て", treatmentCd: "0" });
  commit("setMstTreatment", res.data);
}

async function getMstKur(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstKur", {
    facility_cd: facilityCd,
    is_del: "0"
  });
  res.data.unshift({ kurName: "未登録", kurCd: "0" });
  commit("setMstKur", res.data);
}

async function getMstPersonalUser(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstPersonalUser", {
    facility_cd: facilityCd
  });
  res.data.forEach(user => {
    user.userFullName = `${user.userLastName} ${user.userFirstName}`;
  });
  res.data.unshift({ userFullName: "未登録", userId: "0" });
  commit("setMstPersonalUser", res.data);
}

async function getMstRoomBedGroup(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstRoomBedGroup", {
    facilityCd
  });
  res.data.unshift({ roomBedGroupName: "すべて", roomBedGroupCd: "0" });
  commit("setMstRoomBedGroup", res.data);
}

async function getMstBed(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstBed", {
    facility_cd: facilityCd,
    is_disp: 1,
    is_del: 0
  });
  commit("setMstBed", res.data);
}

// FNSI-修正 マスタ削除の対応 chen add start
async function getMstTreatmentDel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstTreatmentDel", {
    facilityCd: facilityCd
  });
  res.data.unshift({ treatmentName: "全て", treatmentCd: "0" });
  commit("setMstTreatmentDel", res.data);
}

async function getMstKurDel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstKurDel", {
    facility_cd: facilityCd
  });
  res.data.unshift({ kurName: "未登録", kurCd: "0" });
  commit("setMstKurDel", res.data);
}

async function getMstBedDel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstBedDel", {
    facility_cd: facilityCd
  });
  commit("setMstBedDel", res.data);
}

async function getMstEquipmentDel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstEquipmentDel", {
    facilityCd: facilityCd
  });
  commit("setMstEquipmentDel", res.data);
}

async function getMstDialyzerDel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstDialyzerDel", {
    facilityCd: facilityCd
  });
  commit("setMstDialyzerDel", res.data);
}

async function getMstVADel(commit, facilityCd) {
  const res = await ApiHelper.get("/mstInfo/mstVaDel", {
    facilityCd: facilityCd
  });
  commit("setMstVADel", res.data);
}
// FNSI-修正 マスタ削除の対応 chen add end

function makeTreatmentConditionParams({ treatmentSearchCondition, columnStatus }) {
  const {
    treatmentDate,
    treatmentCd,
    kurCds,
    bedGroupCd,
    checker1HasNotReceived,
    checker2HasNotReceived,
    approver1HasNotApproved,
    approver2HasNotApproved,
    instructorId
  } = treatmentSearchCondition;

  return {
    checker1: columnStatus.isShowChecker1 && checker1HasNotReceived,
    checker2: columnStatus.isShowChecker2 && checker2HasNotReceived,
    approver1: columnStatus.isShowApprover1 && approver1HasNotApproved,
    approver2: columnStatus.isShowApprover2 && approver2HasNotApproved,
    instructorId: +instructorId === 0 ? null : +instructorId,
    ordSearchTreatmentCondition: {
      treatDate: dayjs(treatmentDate, "YYYY-MM-DD").format("YYYYMMDD"),
      treatmentCode: +treatmentCd === 0 ? null : +treatmentCd,
      kurCode: kurCds,
      bedGroup: +bedGroupCd === 0 ? null : +bedGroupCd
    }
  };
}

function makeIndicationConditionParams(state) {
  const condition = state.indicationSearchCondition;
  const {
    isShowChecker1,
    isShowChecker2,
    isShowApprover1,
    isShowApprover2
  } = state.columnStatus;

  condition.createdBy =
    +condition.userId === 0
      ? null
      : state.mstPersonalUser.find(user => +user.userId === +condition.userId)
        .userFullName;

  return {
    treatmentDateOpt: parseInt(condition.treatmentDateOpt),
    treatmentStartDate: dayjs(
      condition.treatmentStartDate,
      "YYYY-MM-DD"
    ).format("YYYYMMDD"),
    treatmentScheduledDate: condition.treatmentScheduledDate
      ? dayjs(condition.treatmentScheduledDate, "YYYY-MM-DD").format(
        "YYYYMMDD"
      )
      : null,
    kurCode: condition.kurCds,
    bedGroup: +condition.bedGroupCd === 0 ? null : +condition.bedGroupCd,
    check1: isShowChecker1 ? parseInt(condition.check1) : 1,
    check2: isShowChecker2 ? parseInt(condition.check2) : 1,
    approver1: isShowApprover1 ? parseInt(condition.approver1) : 1,
    approver2: isShowApprover2 ? parseInt(condition.approver2) : 1,
    createdBy: condition.createdBy,
    indicationTarget: {
      indication: condition.indication,
      indicationList: condition.indicationList
    }
  };
}

async function getDoctorsAtFacility(commit, facilityCd) {
  const res = await sendRequestGetDoctorsAtFacility(facilityCd);
  res.data.forEach(user => {
    user.userFullName = `${user.user_last_name} ${user.user_first_name}`;
    user.userId = user.user_id;
  });
  res.data.unshift({ userFullName: "未登録", userId: "0" });
  commit("setDoctorsAtFacility", res.data);
}

//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
async function indicationContentList(
  ordNoList,
  mstBed,
  mstVA,
  mstDialyzer,
  mstEquipment,
  mstMedicine,
  mstMedicineMix,
  mstKur,
  mstPersonalUser,
  mstTreatment,
  selectedPatList,
  facilityCd,
  mstMedicineIncludeDeleted,
  mstMedicineMixIncludeDeleted,
  state) {
    const indContentList = [];
    for (let i = 0; i < ordNoList.length; i++) {
      await Indication.getIndicationDetail(ordNoList[i]).then( async (res) => {
        if(res && res[0]) {
          const ordDetail = res[0];
          let patId = ordDetail.patId;
          const mstDialyzerIncludeDel = await ApiHelper.get(`/mstInfo/mstDialyzerIncludeDel/${patId}`);
          const mstEquipmentIncludeDel =await ApiHelper.get(`/mstInfo/mstEquipment/${patId}/true`);
          const mstMedicineIncludeDel = await ApiHelper.get(`/mstInfo/mstMedicine/${patId}/true`);
          const mstMedicineMixIncludeDel = await ApiHelper.get(`/mstInfo/mstMedicineMix/${patId}/true`);
          ordDetail.indCondInfo = JSON.parse(ordDetail.indCondInfo);
          /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
          // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
          // ordDetail.indMediInfo = JSON.parse(ordDetail.indMediInfo ? ordDetail.indMediInfo : []);
          // ordDetail.indEquipInfo = JSON.parse(ordDetail.indEquipInfo ? ordDetail.indEquipInfo : []);
          // ordDetail.indIndCommentInfo = JSON.parse(ordDetail.indIndCommentInfo ? ordDetail.indIndCommentInfo : []);
          ordDetail.indMediInfo = JSON.parse(ordDetail.indMediInfo ? ordDetail.indMediInfo : "[]");
          ordDetail.indEquipInfo = JSON.parse(ordDetail.indEquipInfo ? ordDetail.indEquipInfo : "[]");
          ordDetail.indIndCommentInfo = JSON.parse(ordDetail.indIndCommentInfo ? ordDetail.indIndCommentInfo : "[]");
          // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
          /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
          ordDetail.indScheduleUserInfo = JSON.parse(ordDetail.indScheduleUserInfo);
          const content = {
            ordNo: ordNoList[i],
            layout: getIndDetailLayout(
              ordDetail,
              mstMedicine,
              mstPersonalUser,
              mstMedicineMix,
              mstEquipment,
              mstKur,
              mstBed,
              mstVA,
              mstDialyzer,
              mstTreatment,
              selectedPatList[i],
              facilityCd,
              mstMedicineIncludeDeleted,
              mstMedicineMixIncludeDeleted,
              mstDialyzerIncludeDel,
              mstEquipmentIncludeDel,
              mstMedicineIncludeDel,
              mstMedicineMixIncludeDel,
              state),
            // add 10739 コンバート施設で指示受け(治療単位)が表示されない zkm start
            rstDialysisState: ordDetail.rstDialysisState,
            // add 10739 コンバート施設で指示受け(治療単位)が表示されない zkm end
          }
          indContentList.push(content);
        }
      });
    }
    return indContentList;
}

function indicationdData(
  subCategoryNo,
  itemNo,
  ordDetail,
  mstKur,
  mstBed,
  mstVA,
  mstDialyzer,
  mstMedicine,
  mstMedicineMix,
  mstTreatment,
  mstPersonalUser,
  mstEquipment,
  selectedPat,
  mstMedicineIncludeDeleted,
  mstMedicineMixIncludeDeleted,
  mstDialyzerIncludeDel,
  mstEquipmentIncludeDel,
  mstMedicineIncludeDel,
  mstMedicineMixIncludeDel,
  state) {
  const key = `${subCategoryNo}${itemNo}`;

// key map
  const treatCondKeys = new Set([
    "41", "42", "43", "44", "45", "46", "47", "48", "49", "410", "411", "412",
    "413", "414", "415", "416", "417", "418", "419", "420", "421", "422", "423",
    "424", "425", "426", "427", "428", "429", "430", "431", "432", "433", "434",
    "435", "436", "437", "438"
  ]);

  if (treatCondKeys.has(key)) {
    return convertTreatCondValue(
      itemNo, ordDetail, mstMedicine, mstMedicineMix, mstPersonalUser, mstVA,
      mstDialyzer, mstEquipment, mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted,
      state, mstDialyzerIncludeDel, mstEquipmentIncludeDel, mstMedicineIncludeDel,
      mstMedicineMixIncludeDel, mstTreatment, state.mstTreatmentDel
    );
  }

  const conversionFunctions = {
    "20": () => convertTreatmentName(ordDetail, mstTreatment, mstPersonalUser, state.mstTreatmentDel),
    "31": () => convertKurName(ordDetail, mstKur, mstPersonalUser, state.mstKurDel),
    "32": () => convertTreatStartTime(ordDetail, mstPersonalUser),
    "33": () => convertBedName(ordDetail, mstBed, mstPersonalUser, state.mstBedDel),
    "4-1": () => convertDw(ordDetail, selectedPat, mstPersonalUser)
  };

  return conversionFunctions[key]?.() || {value: getValue(null, "未登録", null), instructor: "", updater: ""};
}
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

function convertTreatmentName(ordDetail, mstTreatment, mstPersonalUser, mstTreatmentDel) {
  const indValue = ordDetail.indTreatmentCd;
  if (indValue === null || indValue === undefined) {
    return {
      itemName: null,
      itemNo: 1,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, "未登録", null),
        instructor: "",
        updater: ""
      }
    };
  }
  let prefix = null;
  let remainingValue = "未登録";
  /* modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 --start */
  if (ordDetail.rstDialysisState == "0") {
    const treatment = mstTreatment.find(treatment => treatment.treatmentCd === indValue);
    if (!treatment) {
      let treatmentTmp = mstTreatmentDel.find(
          treatment => treatment.treatmentCd === indValue
      );
      if (treatmentTmp) {
        remainingValue = treatmentTmp.treatmentName;
        prefix = MASTER_DELETE_DISPLAY.DELETED;
      }
    } else {
      remainingValue = treatment.treatmentName;
    }
  } else {
    remainingValue = ordDetail.indTreatmentName;
    let treatmentTmp = mstTreatmentDel.find(
        treatment => treatment.treatmentCd === indValue
    );
    if (treatmentTmp) {
      prefix = MASTER_DELETE_DISPLAY.DELETED;
    }
  }
  /* modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 --end */

  return {
    itemName: null,
    itemNo: 1,
    itemCd: ordDetail.indTreatmentCd,
    itemType: null,
    data: {
      value: getValue(prefix, remainingValue, null),
      instructor: findUserFullName(ordDetail.indScheduleUserInfo.ind_user_id, mstPersonalUser),
      updater: findUserFullName(ordDetail.indScheduleUserInfo.upd_user_id, mstPersonalUser)
    }
  };
}

//add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
function getValue(prefix, remainingValue, unit) {
  return {
    prefix: prefix !== "" ? prefix : null,
    dispVal: remainingValue !== "" ? remainingValue : null,
    unit: unit !== "" ? unit : null
  };
}
//add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
function convertTreatCondValue(itemNo, ordDetail, mstMedicine, mstMedicineMix, mstPersonalUser, mstVA, mstDialyzer, mstEquipment,
                                     mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, state, mstDialyzerIncludeDel,
                               mstEquipmentIncludeDel, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel) {
    const itemNames = {
    1: "治療時間",
    2: "VA",
    3: "目標体重",
    4: "除水量制限",
    5: "ダイアライザ",
    6: "吸着カラム",
    7: "1次膜",
    8: "2次膜",
    9: "穿刺針(A針)",
    10: "穿刺針(V針)",
    11: "穿刺針(SN)",
    13: "血液回路",
    20: "補液量",
    12: "シングルニードル使用",
    14: "血流量",
    15: "透析液",
    16: "透析液流量",
    17: "透析液使用数",
    18: "透析液温度",
    19: "補液",
    21: "補液選択",
    22: "補液使用数",
    23: "補液温度",
    24: "補液速度",
    25: "抗凝固剤",
    26: "抗凝固剤ワンショット量",
    27: "抗凝固剤持続速度",
    28: "抗凝固剤持続総量",
    29: "IP使用選択",
    30: "IPスタート",
    31: "IPワンショット量",
    32: "IP速度",
    33: "IP速度最大値",
    34: "IPワンショットスタート",
    35: "IP電源自動切り",
    36: "IP電源自動切り時間",
    37: "IP電源OKモニタ切り",
    38: "IP電源OKモニタ切り時間"
  };
  let itemName = itemNames[itemNo];

  let val = getValue(null, "未登録", null);
  let value = "";
  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  let rstDialysisState = ordDetail.rstDialysisState;
  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
  if (!ordDetail.indCondInfo[itemNo]) {
    return {
      itemName: itemName,
      itemNo: itemNo,
      itemCd: null,
      itemType: null,
      data: {
        value: val,
        instructor: "",
        updater: "",
        isDisable: true  // ord_mainに登録されていない治療条件(JSONキーなし)の場合はisDisabledをtrueに設定。セルをグレーアウトする
      }
    };
  }

  const indValue = ordDetail.indCondInfo[itemNo].value;
  const indUnit = ordDetail.indCondInfo[itemNo].unit;
  let itemCd = null;
  let itemType = null;
  const indAndUpdUserFullName = findIndAndUpdUserFullName(itemNo, ordDetail, mstPersonalUser);
  if (indValue === null || indValue === undefined) {
    return {
      itemName: itemName,
      itemNo: itemNo,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, "未登録", null),
        ...indAndUpdUserFullName
      }
    };
  }

  let unit = rstDialysisState !== "0" ? indUnit : null;
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  switch (itemNo) {
    // 治療時間
    case 1:
      value = convertTreatCondTime(indValue);
      unit = null;
      break;

    // VA
    case 2:
      value = convertTreatCondVA(indValue, mstVA, ordDetail, state);
      itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      break;

    // 目標体重
    case 3:
      // if (rstDialysisState !== "0") {
        unit = +indValue == '-1' ? null : `kg`;
        value = +indValue == '-1' ? "DWと同じ" : `${indValue}`;
      // }
      // itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      break;

    // 除水量制限
    // 補液量
    case 4:
    case 20:
      value = indValue;
      unit = `L`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // ダイアライザ
    case 5:
      // itemType = 1;
      value = convertTreatCondDialyzer(rstDialysisState, itemNo, indValue, mstDialyzer, ordDetail, state.mstDialyzerDel, mstDialyzerIncludeDel);
      itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      unit = `本`;
      break;

    // 吸着カラム    6: 吸着カラム(4)
    // 1次膜        7: 吸着器(5) 分離器(6)
    // 2次膜        8: 吸着器(5) 分離器(6)
    // 穿刺針(A針)   9: 穿刺針(SN以外)(2)
    // 穿刺針(V針)  10: 穿刺針(SN以外)(2)
    // 穿刺針(SN)   11: 穿刺針(SN)(3)
    // 血液回路     13: 血液回路(1)
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 13:
      value = convertTreatCondEquipment(rstDialysisState, itemNo, indValue, mstEquipment, ordDetail, state.mstEquipmentDel, mstEquipmentIncludeDel);
      itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      break;

    // シングルニードル使用
    // IP使用選択
    case 12:
    case 29:
      if (indValue == '1') { // mod #9973 value Number→文字列  shiyw
        value = "使用する";
      } else if (indValue == '0') { // mod #9973 value Number→文字列  shiyw
        value = "使用しない";
      } else {
        value = "未登録";
      }
      break;

    // 血流量
    // 透析液流量
    case 14:
    case 16:
      value = indValue;
      unit = `mL/min`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // 透析液
    // 補液
    case 15:
    case 19:
      itemType = ordDetail.indCondInfo[itemNo].medicine_type;
      value = convertTreatCondMedicine(itemNo, indValue,itemType, ordDetail, "2", mstMedicine, mstMedicineMix, mstMedicineIncludeDeleted,
        mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).name;
      if (rstDialysisState !== "0") {
        value = `${ordDetail.indCondInfo[itemNo].value_name_1}`;
      }
      itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      break;

    // 抗凝固剤
    case 25:
      itemType = ordDetail.indCondInfo[itemNo].medicine_type;
      value = convertTreatCondMedicine(itemNo, indValue,itemType, ordDetail, "1", mstMedicine, mstMedicineMix, mstMedicineIncludeDeleted,
        mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).name;
      if (rstDialysisState !== "0") {
        value = `${ordDetail.indCondInfo[itemNo].value_name_1}`;
      }
      itemCd = (indValue != null || indValue != undefined) ? parseInt(indValue) : null;
      break;

    // 透析液使用数
    // 補液使用数
    case 17:
    case 22:
      if (itemNo == "17") {
        unit = convertTreatCondMedicine(itemNo, ordDetail.indCondInfo[15].value,ordDetail.indCondInfo[15].medicine_type, ordDetail, "2", mstMedicine, mstMedicineMix,
          mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).unit;

        value = `${convertTreatCondMedicineAmount(
          indValue,
          ordDetail.indCondInfo[15].value,
          ordDetail.indCondInfo[15].medicine_type,
          "2",
          mstMedicine,
          mstMedicineMix)}`;
      } else if (itemNo == "22") {
        unit = convertTreatCondMedicine(itemNo, ordDetail.indCondInfo[19].value,ordDetail.indCondInfo[19].medicine_type, ordDetail, "2", mstMedicine, mstMedicineMix,
          mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).unit;

        value = `${convertTreatCondMedicineAmount(
          indValue,
          ordDetail.indCondInfo[19].value,
          ordDetail.indCondInfo[19].medicine_type,
          "2",
          mstMedicine,
          mstMedicineMix)}`;
      }
      if (rstDialysisState !== "0") {
        unit = indUnit;
        value = `${indValue}`;
      }
      break;

    // 抗凝固剤持続速度
    case 27:
      value = `${convertTreatCondMedicineAmount(
        indValue,
        ordDetail.indCondInfo[25].value,
        ordDetail.indCondInfo[25].medicine_type,
        "1",
        mstMedicine,
        mstMedicineMix)}`;
      unit = convertTreatCondMedicine(itemNo, ordDetail.indCondInfo[25].value,ordDetail.indCondInfo[25].medicine_type, ordDetail, "1", mstMedicine, mstMedicineMix,
        mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).unit;
      // #10196 数値IFのスタイル全不正 linjunfeng start
      // unit += "/h";

      if (unit) {
        unit += "/h";
      }
      // #10196 数値IFのスタイル全不正 linjunfeng end
      if (rstDialysisState !== "0") {
        unit = indUnit;
        value = `${indValue}`;
      }
      break;

    // 抗凝固剤ワンショット量
    // 抗凝固剤持続総量
    case 26:
    case 28:
      value = `${convertTreatCondMedicineAmount(
        indValue,
        ordDetail.indCondInfo[25].value,
        ordDetail.indCondInfo[25].medicine_type,
        "1",
        mstMedicine,
        mstMedicineMix)}`;
      unit = convertTreatCondMedicine(itemNo, ordDetail.indCondInfo[25].value,ordDetail.indCondInfo[25].medicine_type, ordDetail, "1", mstMedicine, mstMedicineMix,
        mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel).unit;
      if (rstDialysisState !== "0") {
        unit = indUnit;
        value = `${indValue}`;
      }
      break;

    // 透析液温度
    // 補液温度
    case 18:
    case 23:
      value = indValue;
      unit = `℃`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // 補液選択
    case 21:
      if (indValue == '0') { // mod #9973 value Number→文字列  shiyw
        value = "後補液";
      } else if (indValue == '1') { // mod #9973 value Number→文字列  shiyw
        value = "前補液";
      } else {
        value = "未登録";
      }
      break;

    // 補液速度
    case 24:
      value = indValue;
      unit = `L/h`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // IPスタート
    // IPワンショットスタート
    case 30:
    case 34:
      if (indValue == '0') { // mod #9973 value Number→文字列  shiyw
        value = "手動";
      } else if (indValue == '1') { // mod #9973 value Number→文字列  shiyw
        value = "自動";
      } else {
        value = "未登録";
      }
      break;

    // IPワンショット量
    case 31:
      value = indValue;
      unit = `mL`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // IP速度
    // IP速度最大値
    case 32:
    case 33:
      value = indValue;
      unit = `mL/h`;
      if (rstDialysisState !== "0") {
        value = `${indValue}`;
      }
      break;

    // IP電源自動切り
    // IP電源OKモニタ切り
    case 35:
    case 37:
      if (indValue == '1') { // mod #9973 value Number→文字列  shiyw
        value = "入";
      } else if (indValue == '0') { // mod #9973 value Number→文字列  shiyw
        value = "切";
      } else {
        value = "未登録";
      }
      break;

    // IP電源自動切り時間
    // IP電源OKモニタ切り時間
    case 36:
    case 38:
      unit = `分`;
      value = `${indValue}`;
      break;

    default:
      value = indValue;
      break;
  }

  value = value || "未登録";

  const prefixes = [
    "【禁忌・ｱﾚﾙｷﾞｰ】",
    "【禁忌】",
    "【ｱﾚﾙｷﾞｰ】",
    "【分類不一致】",
    "【期限切れ】",
    "【削除済み】",
    "【削除済み含む】"
  ];
  const prefixPattern = new RegExp(`(${prefixes.join('|')})`, 'g');
  const parts = value.toString()?.split(prefixPattern);

  const nonPrefixParts = parts.filter(part => part && !prefixes.includes(part));

  const prefix = parts.filter(part => prefixes.includes(part)).join('');
  const remainingValue = nonPrefixParts.join('');
  val = getValue(prefix, remainingValue, unit);
  return {
      itemName: itemName,
      itemNo: itemNo,
      itemCd: itemCd,
      itemType: itemType,
      data: {
        value: val,
        ...indAndUpdUserFullName
      }
  };
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
}
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

function findUserFullName(id, mstPersonalUser) {
  const user = mstPersonalUser.find(user => +user.userId === +id);
  return user ? user.userFullName : "";
}
function findIndAndUpdUserFullName(itemNo, ordDetail, mstPersonalUser) {
  const indUserId = ordDetail.indCondInfo[itemNo].ind_user_id;
  const updUserId = ordDetail.indCondInfo[itemNo].upd_user_id;
  return {
    instructor: findUserFullName(indUserId, mstPersonalUser),
    updater: findUserFullName(updUserId, mstPersonalUser)
  };
}
function convertTreatCondTime(indValue) {
  const dur = dayjs.duration(indValue, "minutes");
  const hours = dur.hours();
  const minutes = dur.minutes();
  return dayjs()
    .hour(hours)
    .minute(minutes)
    .format("HH:mm");
}
function convertTreatCondVA(indValue, mstVA, ordDetail, state) {
  const va = mstVA.find(va => va.vaCd == indValue); // mod #9973 value Number→文字列  shiyw
// FNSI-修正 マスタ削除の対応 chen mod start
  let vaName = "";
  if (va) {
    vaName = va.vaName;
  } else {
    const vaTmp = state.mstVADel.find(va => va.vaCd == indValue); // mod #9973 value Number→文字列  shiyw
    if (vaTmp) {
      if (ordDetail.rstDialysisState !== "6") {
        vaName = MASTER_DELETE_DISPLAY.DELETED + vaTmp.vaName;
      } else {
        vaName = vaTmp.vaName;
      }
    }
  }
  // return va ? va.vaName : "";
  return vaName;
// FNSI-修正 マスタ削除の対応 chen mod end
}

//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
function convertTreatCondDialyzer(rstDialysisState, itemNo, indValue, mstDialyzer, ordDetail, mstDialyzerDel, mstDialyzerIncludeDel) {
  if (rstDialysisState !== "0") {
    return `[${ordDetail.indCondInfo[itemNo].value_name_1}]`;
  } else {
    const dialyzer = mstDialyzerIncludeDel.data.find(e => e.dialyzerCd == indValue);
    let makerModelNumber = "";

    if (dialyzer) {
      let isTaboo = dialyzer.isTaboo;
      let isAllergy = dialyzer.isAllergy;
      let isDisp = dialyzer.isDisp;
      let isDel = dialyzer.isDel;
      let treatDate = ordDetail.treatDate;
      let useStartDate = dialyzer.useStartDate;
      let useEndDate = dialyzer.useEndDate;
      let prefix = getPrefix({isTaboo, isAllergy, treatDate, useStartDate, useEndDate, isDisp, isDel});

      makerModelNumber = prefix + `[${dialyzer.modelNumber}]`;
    }
    return makerModelNumber;
  }
}

function convertTreatCondEquipment(rstDialysisState, itemNo, indValue, mstEquipment, ordDetail, mstEquipmentDel, mstEquipmentIncludeDel) {
  if (rstDialysisState !== "0") {
    return `${ordDetail.indCondInfo[itemNo].value_name_1}`;
  } else {
    const equipment = mstEquipmentIncludeDel.data.find(equipment => equipment.equipmentCd == indValue);
    let equipmentName = "";
    if (equipment) {
      let isTaboo = equipment.isTaboo;
      let isAllergy = equipment.isAllergy;
      let isDisp = equipment.isDisp;
      let isDel = equipment.isDel;
      let treatDate = ordDetail.treatDate;
      let useStartDate = equipment.useStartDate;
      let useEndDate = equipment.useEndDate;
      let classType = equipment.classType;
      // 吸着カラム    6: 吸着カラム(4)
      // 1次膜        7: 吸着器(5) 分離器(6)
      // 2次膜        8: 吸着器(5) 分離器(6)
      // 穿刺針(A針)   9: 穿刺針(SN以外)(2)
      // 穿刺針(V針)  10: 穿刺針(SN以外)(2)
      // 穿刺針(SN)   11: 穿刺針(SN)(3)
      // 血液回路     13: 血液回路(1)
      let classTypeObj = {
        6: CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType,
        7: [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
        8: [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
        9: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType,
        10: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType,
        11: CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType,
        13: CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType,
      }
      let normalClassType = classTypeObj[itemNo];

      let prefix = getPrefix({isTaboo, isAllergy, normalClassType, classType, treatDate, useStartDate, useEndDate, isDisp, isDel});
      equipmentName = prefix + equipment.equipmentName;
    }
    return equipmentName;
  }
}
/**
 * 対象項目のマスタ参照情報を取得する
 *
 * @param {number} itemNo 項目番号 (指示の対象となる項目)
 * @param {string} indCode 取得対象のマスタ参照用コード (薬剤または調製薬剤のコード)
 * @param {string} medicineType 薬剤・調製薬剤区分(薬剤:1 調製薬剤:2)
 * @param {Object} ordDetail 指示詳細情報 (指示日時や処置情報を含む)
 * @param {string} unitType 指示単位・レセ単位区分 (指示: "1", レセプト: "2")
 * @param {Object} mstMedicine 薬剤マスタ情報
 * @param {Object} mstMedicineMix 調製薬剤マスタ情報
 * @param {Object} mstMedicineIncludeDeleted 削除済みを含む薬剤マスタ情報
 * @param {Object} mstMedicineMixIncludeDeleted 削除済みを含む調製薬剤マスタ情報
 * @param {Object} mstMedicineIncludeDel 削除済みを含む薬剤マスタ情報
 * @param {Object} mstMedicineMixIncludeDel 削除済みを含む調製薬剤マスタ情報
 * @param {Object} mstTreatment 処置マスタ情報
 * @param {Object} mstTreatmentDel 削除済み処置マスタ情報
 * @returns {{name: string, unit: string}} 取得した薬剤または調製薬剤の名称と単位 (該当データがない場合は { name: "", unit: "" })
 */
function convertTreatCondMedicine(itemNo, indCode,medicineType, ordDetail, unitType, mstMedicine, mstMedicineMix,
                                  mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstMedicineIncludeDel,
                                  mstMedicineMixIncludeDel, mstTreatment, mstTreatmentDel) {
  if (![1, 2].includes(medicineType)) return {name: "", unit: ""};

  // 該当する薬剤情報を取得
  let medicine =
    medicineType == 1
      ? mstMedicineIncludeDel.data.find((m) => m.medicineCd == indCode)
      : mstMedicineMixIncludeDel.data.find((m) => m.medicineMixCd == indCode);

  if (!medicine) return {name: "", unit: ""};

  // 薬剤の基本情報を取得
  let {
    isTaboo,      // 禁忌フラグ
    isAllergy,    // アレルギーフラグ
    isDisp,       // 表示可否フラグ
    isDel,        // 削除フラグ
    useStartDate, // 使用開始日
    useEndDate,   // 使用終了日
    classType,    // 分類タイプ
    medicineName, // 薬剤名
    medicineMixName, // 調製薬剤名
    unit,         // 指示単位
    unitSecond,   // レセプト単位
  } = medicine;

  let treatDate = ordDetail.treatDate; // 処置日
  let indTreatmentCd = ordDetail.indTreatmentCd; // 指示処置コード

  // 処置情報を取得
  let treatment = mstTreatment.find((t) => t.treatmentCd == indTreatmentCd) || mstTreatmentDel.find((t) => t.treatmentCd == indTreatmentCd);

  let deviceMode = treatment?.deviceMode;
  const deviceModeOnline = [DEVICEMODE.OHDF, DEVICEMODE.OHF, DEVICEMODE.I_HDF];
  const deviceModeOnlineClassType = [CODES.MEDICINE_CLASS.DIALYSATE.classType, CODES.MEDICINE_CLASS.REPLACEMENT.classType];

  // デバイスモードがオンラインの場合、クラスの分類を変更
  const dialysateClassType = deviceModeOnline.includes(deviceMode) ? deviceModeOnlineClassType : CODES.MEDICINE_CLASS.DIALYSATE.classType;
  const replacementClassType = deviceModeOnline.includes(deviceMode) ? deviceModeOnlineClassType : CODES.MEDICINE_CLASS.REPLACEMENT.classType;

  // クラス分類のマッピング
  const classTypeObj = {
    15: dialysateClassType, // 透析液
    19: replacementClassType, // 補充液
    25: CODES.MEDICINE_CLASS.ANTI_COAGULANT.classType, // 抗凝固剤
  };

  let normalClassType = classTypeObj[itemNo];

  // 表示用のプレフィックスを取得
  let prefix = getPrefix({
    isTaboo,
    isAllergy,
    normalClassType,
    classType,
    treatDate,
    useStartDate,
    useEndDate,
    isDisp,
    isDel,
  });

  // 返却する薬剤情報を作成
  let name = prefix + (medicineType === 1 ? medicineName : medicineMixName);
  let unitValue = unitType === "1" ? unit : unitSecond || "";

  return {name, unit: unitValue};
}
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

/**
 * 数値にマスタの小数点桁数指定を当てて最低桁数を補う処理
 *
 * @param {number} indValue      変換対象の数値
 * @param {number} indCode       変換対象のマスタ参照用コード
 * @param {string} medicineType  薬剤・調製薬剤区分(薬剤:1 調製薬剤:2)
 * @param {string} unitType      指示単位・レセ単位区分 (指示:1 レセ:2)
 * @returns {string}             返却値（表示用）
 */
function convertTreatCondMedicineAmount(indValue, indCode, medicineType, unitType, mstMedicine, mstMedicineMix){
  if(indValue == null){
    return "未登録";
  }
  // 薬剤・調製薬剤のマスタを区分に応じて変更し、対象データを取得します
  let decPoint = 0;
  let value;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //if(medicineType === "1"){
  if(medicineType == 1){
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    const medicine = mstMedicine.find(
      medicine => medicine.medicineCd == indCode // mod #9973 value Number→文字列  shiyw
    );
    if (medicine){
      if(unitType === "1"){
        decPoint = medicine.unitDecimalPoint;
      }else if(unitType ==="2"){
        decPoint = medicine.unitDecimalPointSecond;
      }
    }
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //}else if(medicineType === "2"){
  }else if(medicineType == 2){
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    const medicineMix = mstMedicineMix.find(
      medicineMix => medicineMix.medicineMixCd == indCode // mod #9973 value Number→文字列  shiyw
    );
    if(medicineMix){
      // 調製薬剤には指示単位のみのためunitTypeは無視する
      decPoint = medicineMix.unitDecimalPoint;
    }
  }
  //小数点桁数値と変換対象数値の小数点桁数から大きい方を採用して変換する
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  indValue = (BigNumber(indValue).toFixed());
  //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
  let numbers = String(indValue).split('.');
  let valueDecPoint = (numbers[1]) ? numbers[1].length : 0;
  if(valueDecPoint > decPoint){
    value = (BigNumber(indValue).toFixed());
  }else{
    value = (BigNumber(indValue).toFixed(decPoint));
  }
  return value;
}

function convertKurName(ordDetail, mstKur, mstPersonalUser, mstKurDel) {
  const indValue = ordDetail.indKurCd;
  if (indValue === null || indValue === undefined) {
    return {
      itemName: "クール",
      itemNo: 1,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, "未登録", null),
        instructor: "",
        updater: ""
      }
    };
  }
  const kur = mstKur.find(kur => kur.kurCd === indValue);
  let remainingValue;
  if (!kur) {
    const kurTmp = mstKurDel.find(kur => kur.kurCd === indValue);
    if (kurTmp) {
      remainingValue = kurTmp.kurName;
    } else {
      remainingValue = "未登録";
    }
  } else {
    remainingValue = kur.kurName;
  }
  return {
    itemName: "クール",
    itemNo: 1,
    itemCd: kur?kur.kurCd:null,
    itemType: null,
    data: {
      value: getValue(null, remainingValue, null),
      instructor: findUserFullName(ordDetail.indScheduleUserInfo.ind_user_id, mstPersonalUser),
      updater: findUserFullName(ordDetail.indScheduleUserInfo.upd_user_id, mstPersonalUser)
    }
  };
}

function convertTreatStartTime(ordDetail, mstPersonalUser) {
  const indValue = ordDetail.indTreatStartTime;
  if (indValue === null || indValue === undefined) {
    return {
      itemName: "治療開始時刻",
      itemNo: 2,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, "未登録", null),
        instructor: "",
        updater: ""
      }
    };
  }
  const treatDate = ordDetail.treatDate;
  const prefixStr = treatDate.slice(0, 4) + '/' + treatDate.slice(4, 6) + '/' + treatDate.slice(6, 8);
  const value = `${indValue.substr(0, 2)}:${indValue.substr(2)}`;
  return {
    itemName: "治療開始時刻",
    itemNo: 2,
    itemCd: null,
    itemType: null,
    data: {
      value: getValue(prefixStr + " ", value, null),
      instructor: findUserFullName(ordDetail.indScheduleUserInfo.ind_user_id, mstPersonalUser),
      updater: findUserFullName(ordDetail.indScheduleUserInfo.upd_user_id, mstPersonalUser)
    }
  };
}
function convertBedName(ordDetail, mstBed, mstPersonalUser, mstBedDel) {
  const bed = mstBed.find(bed => bed.bedCd === ordDetail.indBedCd);
  let remainingValue = "未登録";
  if (!bed) {
    const bedTmp = mstBedDel.find(bed => bed.bedCd === ordDetail.indBedCd);
    if (bedTmp) {
      remainingValue = bedTmp.bedName;
    }
  } else {
    remainingValue = bed.bedName;
  }

  return {
    itemName: "ベッド",
    itemNo: 3,
    itemCd: ordDetail.indBedCd,
    itemType: null,
    data: {
      value: getValue(null, remainingValue, null),
      instructor: findUserFullName(ordDetail.indScheduleUserInfo.ind_user_id, mstPersonalUser),
      updater: findUserFullName(ordDetail.indScheduleUserInfo.upd_user_id, mstPersonalUser)
    }
  };
}

//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
function getIndDetailLayout(ordDetail, mstMedicine, mstPersonalUser, mstMedicineMix, mstEquipment, mstKur, mstBed, mstVA, mstDialyzer, mstTreatment, selectedPat, facilityCd,
  mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted, mstDialyzerIncludeDel, mstEquipmentIncludeDel, mstMedicineIncludeDel, mstMedicineMixIncludeDel, state) {
  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  let rstDialysisState = ordDetail.rstDialysisState;
  //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end

  const mstLayout = JSON.parse(JSON.stringify(mstPatViewerLayoutToIndicationDefine));
  const layout = mstLayout
    .find(item => item.categoryNo === LAYOUT_CATE_NO)
    .categoryItem.filter(subItem =>
      LAYOUT_SUB_CATE_NO.includes(subItem.subCategoryNo)
    );
  layout.forEach(subCategory => {
    if (subCategory.subCategoryItem.length <= 1 || subCategory.subCategoryNo === 5) {
      subCategory.subCategoryItem = [];
    }
    switch (subCategory.subCategoryNo) {
      case 2:
        subCategory.itemInfo = indicationdData(subCategory.subCategoryNo, 0, ordDetail, mstKur, mstBed, mstVA, mstDialyzer,
          mstMedicine, mstMedicineMix, mstTreatment, mstPersonalUser, mstEquipment, selectedPat, mstMedicineIncludeDeleted, mstMedicineMixIncludeDeleted,
          mstDialyzerIncludeDel, mstEquipmentIncludeDel, mstMedicineIncludeDel, mstMedicineMixIncludeDel, state);
        break;

      case 5:
        if (ordDetail.indMediInfo) {
          processMedicineInfo(ordDetail, subCategory, rstDialysisState, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstPersonalUser);
        }
        break;

      case 6:
        if (ordDetail.indEquipInfo) {
          processEquipmentInfo(ordDetail, subCategory, rstDialysisState, mstEquipmentIncludeDel, mstDialyzerIncludeDel, mstPersonalUser);
        }
        break;

      case 7:
        if (ordDetail.indIndCommentInfo) {
          processCommentInfo(ordDetail, subCategory, mstPersonalUser);
        }
        break;

      default:
        if (subCategory.subCategoryItem.length > 1) {
          subCategory.subCategoryItem = subCategory.subCategoryItem.map((item) => {
            let itemInfo = indicationdData(
              subCategory.subCategoryNo,
              item.itemInfo.itemNo,
              ordDetail,
              mstKur,
              mstBed,
              mstVA,
              mstDialyzer,
              mstMedicine,
              mstMedicineMix,
              mstTreatment,
              mstPersonalUser,
              mstEquipment,
              selectedPat,
              mstMedicineIncludeDeleted,
              mstMedicineMixIncludeDeleted,
              mstDialyzerIncludeDel,
              mstEquipmentIncludeDel,
              mstMedicineIncludeDel,
              mstMedicineMixIncludeDel,
              state
            );

            return {itemInfo};
          });
        }
    }
  });
  return layout;
}

function processMedicineInfo(ordDetail, subCategory, rstDialysisState, mstMedicineIncludeDel, mstMedicineMixIncludeDel, mstPersonalUser) {
  ordDetail.indMediInfo.forEach(
    async ({cd, amount, unit, medicine_type, ind_user_id, upd_user_id, no}) => {
      let dispVal = amount;
      let decimalPoint;

      // 該当する薬剤情報を取得
      let medicine = medicine_type == 1
        ? mstMedicineIncludeDel.data.find((m) => m.medicineCd == cd)
        : mstMedicineMixIncludeDel.data.find((m) => m.medicineMixCd == cd);

      if (!medicine) return;

      unit = unit || medicine.unit;

      if (rstDialysisState == "0") {
        const numbers = BigNumber(amount).toFixed().split('.');
        decimalPoint = numbers[1] ? numbers[1].length : 0;

        if (amount !== null) {
          dispVal = decimalPoint > medicine.unitDecimalPoint
            ? BigNumber(amount).toFixed()
            : BigNumber(amount).toFixed(medicine.unitDecimalPoint);
        } else {
          dispVal = 0;
        }
      }

      let {
        isTaboo,      // 禁忌フラグ
        isAllergy,    // アレルギーフラグ
        isDisp,       // 表示可否フラグ
        isDel,        // 削除フラグ
        useStartDate, // 使用開始日
        useEndDate,   // 使用終了日
      } = medicine;

      let treatDate = ordDetail.treatDate; // 処置日

      let prefix = getPrefix({
        isTaboo,
        isAllergy,
        treatDate,
        useStartDate,
        useEndDate,
        isDisp,
        isDel,
      });

      let itemInfo = {
        itemName: medicine.medicineMixName || medicine.medicineName,
        itemNo: no,
        itemCd: cd,
        itemType: medicine_type,
        data: {
          value: getValue(prefix, dispVal, unit),
          instructor: findUserFullName(ind_user_id, mstPersonalUser),
          updater: findUserFullName(upd_user_id, mstPersonalUser)
        }
      };
      subCategory.subCategoryItem.push({itemInfo});
    }
  );
}

function processEquipmentInfo(ordDetail, subCategory, rstDialysisState, mstEquipmentIncludeDel, mstDialyzerIncludeDel, mstPersonalUser) {
  if (rstDialysisState !== "0") {
    const prefixes = [
      "【禁忌・ｱﾚﾙｷﾞｰ】",
      "【禁忌】",
      "【ｱﾚﾙｷﾞｰ】",
      "【分類不一致】",
      "【期限切れ】",
      "【削除済み】",
      "【削除済み含む】"
    ];
    const prefixPattern = new RegExp(`(${prefixes.join('|')})`, 'g');

    ordDetail.indEquipInfo.forEach(({cd, amount, unit, ind_user_id, upd_user_id, equip_type, name}) => {
      const parts = name.split(prefixPattern);
      const nonPrefixParts = parts.filter(part => part && !prefixes.includes(part));
      const prefix = parts.filter(part => prefixes.includes(part)).join('');
      const remainingValue = nonPrefixParts.join('');
      let itemInfo = {
        itemName: remainingValue,
        itemNo: cd,
        itemCd: cd,
        itemType: equip_type,
        data: {
          value: getValue(prefix, amount, unit),
          instructor: findUserFullName(ind_user_id, mstPersonalUser),
          updater: findUserFullName(upd_user_id, mstPersonalUser),
        },
      };
      subCategory.subCategoryItem.push({itemInfo});
    });
    return;
  }

  const processEquipmentData = (item, type) => {
    let equipData = null;
    let equipName = "";
    let prefix = "";
    let unit = "";

    if (type === 0) {
      equipData = mstEquipmentIncludeDel.data.find(e => e.equipmentCd === item.cd);
      if (equipData) {
        equipName = equipData.equipmentName;
        unit = item.unit || equipData.unit;
      }
    } else if (type === 1) {
      equipData = mstDialyzerIncludeDel.data.find(e => e.dialyzerCd === item.cd);
      if (equipData) {
        equipName = equipData.modelNumber;
        unit = '本';
      }
    }
    if (equipData) {
      const {
        isTaboo,      // 禁忌フラグ
        isAllergy,    // アレルギーフラグ
        isDisp,       // 表示可否フラグ
        isDel,        // 削除フラグ
        useStartDate, // 使用開始日
        useEndDate,   // 使用終了日
      } = equipData;

      const treatDate = ordDetail.treatDate; // 処置日

      prefix = getPrefix({
        isTaboo,
        isAllergy,
        treatDate,
        useStartDate,
        useEndDate,
        isDisp,
        isDel,
      });
    }
    return {equipName, prefix, unit};
  };

  // ordDetail.indEquipInfo.forEach(({cd, amount, ind_unit, ind_user_id, upd_user_id, equip_type}, index) => {
  ordDetail.indEquipInfo.forEach(({cd, amount, ind_unit, ind_user_id, upd_user_id, equip_type}) => {
    const {equipName, prefix,unit} = processEquipmentData({cd, ind_unit}, equip_type);
    if (!equipName) return;
    let itemInfo = {
      itemName: equipName,
      // itemNo: index+1,
      itemNo: cd,
      itemCd: cd,
      itemType: equip_type,
      data: {
        value: getValue(prefix, amount, unit),
        instructor: findUserFullName(ind_user_id, mstPersonalUser),
        updater: findUserFullName(upd_user_id, mstPersonalUser),
      },
    };
    subCategory.subCategoryItem.push({itemInfo});
  });
}

function processCommentInfo(ordDetail, subCategory, mstPersonalUser) {
  ordDetail.indIndCommentInfo.forEach(
    ({no, content, ind_user_id, upd_user_id}) => {
      let itemInfo = {
        itemName: `コメント${no}`,
        itemNo: no, // ord_main.指示：指示コメント情報 -> 指示コメントを識別するための番号
        itemCd: null,
        itemType: null,
        data: {
          value: getValue(null, content, null),
          instructor: findUserFullName(ind_user_id, mstPersonalUser),
          updater: findUserFullName(upd_user_id, mstPersonalUser)
        }
      };
      subCategory.subCategoryItem.push({itemInfo});
    }
  );
}

function convertDw(ordDetail, selectedPat, mstPersonalUser) {
  let indValue = ordDetail.indDw;
  // add 障害票一覧_指示受け指示承認 修正 chen start
  let instructor = "";
  // add 10443 身体情報・DW・目標体重バグ 関  start
  let updater = "";
  if (ordDetail.indDwUserInfo != "" &&ordDetail.indDwUserInfo != undefined ) {
    let indDwUserInfo = JSON.parse(ordDetail.indDwUserInfo);
    instructor = indDwUserInfo.ind_user_id;
    updater = indDwUserInfo.upd_user_id;
  }
  // add 10443 身体情報・DW・目標体重バグ 関  end
  // add 障害票一覧_指示受け指示承認 修正 chen end
  if (indValue === null || indValue === undefined) {
    let physicalInfo = selectedPat?.pat_unique?.physical_info ? JSON.parse(
      selectedPat?.pat_unique.physical_info
    ) : [];
    if (physicalInfo.length > 0) {
      physicalInfo.reverse();
    }
    const tDate = dayjs(ordDetail.treatDate, "YYYYMMDD").add(
      1,
      "day"
    );

    // mod 10443 身体情報・DW・目標体重バグ 関  start
    let examDate = "";
    let ctlNo = "";
    physicalInfo.forEach(pInfo => {
      if (
        pInfo.exam_date && dayjs(pInfo.exam_date).isBefore(tDate)&&
        // 治療日より未来の登録日を除外する
        pInfo.dw !== undefined && pInfo.dw !== null
      ) {
        if (examDate === "" || dayjs(pInfo.exam_date).isAfter(examDate)) {
          examDate = pInfo.exam_date;
          indValue = pInfo.dw;
          updater = Object.prototype.hasOwnProperty.call(pInfo, "changer_cd") ? pInfo.changer_cd : "";
          instructor = pInfo.indicator_cd;
          ctlNo = pInfo.ctl_no;
        }else if(dayjs(pInfo.exam_date).isSame(examDate)){
          if (ctlNo && pInfo.ctl_no > ctlNo) {
            examDate = pInfo.exam_date;
            indValue = pInfo.dw;
            updater = Object.prototype.hasOwnProperty.call(pInfo, "changer_cd") ? pInfo.changer_cd : "";
            instructor = pInfo.indicator_cd;
            ctlNo = pInfo.ctl_no;
          }
        }
      }
    });
  }

  // add 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  start
  let unit = "kg";
  // add 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  end
  if (indValue === null || indValue === undefined) {
    indValue = "未登録";
    // add 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  start
    unit = "";
    // add 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  end
  } else {
    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
    indValue = `${BigNumber(indValue).toFixed(2)}`;
    //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  // mod 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  start
  if (Object.prototype.hasOwnProperty.call(ordDetail.indCondInfo, "3")) {
    return {
      itemName: "DW",
      itemNo: -1,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, indValue, unit),
        instructor: findUserFullName(instructor, mstPersonalUser),
        updater: findUserFullName(updater, mstPersonalUser)
      }
    };
  }else {
    return {
      itemName: "DW",
      itemNo: -1,
      itemCd: null,
      itemType: null,
      data: {
        value: getValue(null, "未登録", null),
        instructor: ordDetail.upUserId,
        updater: ordDetail.upIndUserId,
        isDisable: true
      }
    };
  }
  // mod 10705 指示受け・指示承認(治療単位)/治療状況リスト・マップのDW欄がグレーアウトになってない 関  end
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
}
//mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

//add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
function getPrefix({ isTaboo, isAllergy, normalClassType, classType, treatDate, useStartDate, useEndDate, maxUseStartDate, minUseEndDate, isDisp, isDel, isIncludeDel }) {
  const TABOO_CLASS_PREFIX = "【禁忌】";
  const ALLERGY_CLASS_PREFIX = "【ｱﾚﾙｷﾞｰ】";
  const TABOO_ALLERGY_CLASS_PREFIX = "【禁忌・ｱﾚﾙｷﾞｰ】";
  const ClASSIFICATION_PREFIX = "【分類不一致】";
  const EXPIRED_DATE_PREFIX = "【期限切れ】";
  const DELETE_PREFIX = "【削除済み】";
  const INCLUDE_DELETED_PREFIX = "【削除済み含む】";
  let prefix = "";
  // 禁忌・アレルギー
  if (isTaboo && isAllergy) {
    prefix += TABOO_ALLERGY_CLASS_PREFIX;
  } else if (isTaboo && !isAllergy) {
    prefix += TABOO_CLASS_PREFIX;
  } else if (!isTaboo && isAllergy) {
    prefix += ALLERGY_CLASS_PREFIX;
  }
  // 分類不一致
  if (normalClassType != null && classType != null ) {
    if (Array.isArray(normalClassType)) {
      if (!normalClassType.includes(Number(classType))) {
        prefix += ClASSIFICATION_PREFIX;
      }
    } else if(normalClassType != classType) {
      prefix += ClASSIFICATION_PREFIX;
    }
  }
  // 期限切れ
  if (treatDate != null && !fitTermCheck(useStartDate, useEndDate, treatDate)) {
    prefix += EXPIRED_DATE_PREFIX;
  } else if (treatDate != null && !fitTermCheck(maxUseStartDate, minUseEndDate, treatDate)) {
    prefix += EXPIRED_DATE_PREFIX;
  }

  // 削除済み
  if (isDisp == 0 || isDel == 1) {
    prefix += DELETE_PREFIX;
  } else if (isIncludeDel) { // 削除済み含む
    prefix += INCLUDE_DELETED_PREFIX;
  }

  return prefix;
}
//add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
