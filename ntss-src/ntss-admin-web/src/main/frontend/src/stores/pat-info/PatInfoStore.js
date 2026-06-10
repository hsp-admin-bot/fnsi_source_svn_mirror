import { ApiHelper } from "@/apis/AxiosHelper";
import store from "@/stores";
import _ from "underscore";
import {
  deepCopy,
  deduplicateObjects,
  deduplicateObjectsGroup
} from "@/functions/common/CommonFunctions";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import { getPatById } from "@/functions/PatInfoFunctions";
import { sendRequestGetMstFacilityByCd } from "@/apis/facility";
import imgDuplication from "@/assets/name_duplication.png"
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import { FACILITY_PAT_SEARCH_DISP_SETTING } from "@/constants/facilitySetting";

// 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
const CardShowingDef = {
  // 患者情報・新規患者登録のデフォルト設定の取得済みフラグ
  defaultSettingLoaded: false,
  // 患者情報・新規患者登録毎のカード開閉状態(開:true, 閉: false)
  condition: {
    basicInfoCard: true,
    otherContactCard: true,
    vendorContactCard: true,
    patMemoCard: true,
    insuranceInfoCard: true,
    difficultySeverityTransportCard: true,
    medicalCareInfoCard: true,
    chargeStaffCard: true,
    tabooAllergyCard: true,
    infectionCard: true,
    implantCard: true,
    medicalHstCard: true,
    visitHstCard: true,
    physicalInfoCard: true,
    patGroupCard: true,
    remoteMonitorCard: true,
    additionSettingCard: true,
  },
}
// 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end

export default {
  namespaced: true,
  strict: true,

  state: {
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 start
    mstWard: null,
    deleteMstWard: null,
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 end
    operation_order: null,
    Is_Add: 0,
    Is_Update: false,
    /**
     * @description PatHeaderのcreatedでのselectPat処理中はtrueになるフラグ
     * @type {Boolean}
     */
    inSelectPatAtPatHeaderCreated: false,
    /**
     * @description 選択患者
     * @summary 患者情報3テーブルの内容を持つ
     * @type {Object}
     *   {
     *     pat_personal_main: { pat_id, ... },
     *     pat_main: { is_same, ... },
     *     pat_unique: { medical_hst_info, ... }
     *   }
     */
    selectedPat: null,
    selectedShrPat: null,
    isSharingMode: false,
    // 感染症マスタ削除済みデータを含む選択患者情報 ※患者カレンダーで使用
    selectedPatIncludeDel: null,

    /**
     * @description 検索患者リスト
     * @type {Array} [{ pat_id, hosp_pat_id, pat_last_name, pat_first_name}, ...]
     */
    searchedPatList: [],
    searchedShrPatList: [],
    searchedPatListPatGroup: [],
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    unselectedPatList: [],
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end

    /**
     * @description 治療患者リスト(親画面で選択されている患者グループ)
     * @type {Array} [{ pat_id, pat_last_name, pat_first_name, ord_no, kur_name, bed_name, is_same }, ...]
     */
    treatmentPatList: [],

    /**
     * @description 遷移元機能名
     * @summary 表示データを治療患者リストにする場合の遷移元機能名を管理
     * @type {String}
     */
    srcFuncName: "",

    /**
     * @description 患者情報画面(ヘッダ引き出しではないカード一覧)の表示フラグ
     * @summary ヘッダからのカード引き出し無効化用
     * @type {Boolean}
     */
    isPatInfoPageShowing: false,

    /**
     * @description スワイプ可能フラグ
     * @summary 編集中の患者切り替え制御用
     * @type {Boolean}
     */
    isHeaderSwipeDisabled: false,

    /**
     * @description 患者読み込み中フラグ
     * @summary ヘッダと検索患者リストの2箇所での読み込み状態を管理
     * @type {Boolean}
     */
    isLoadingPat: false,

    /**
     * @description カード一覧表示フラグ
     * @summary 患者情報ヘッダのカード一覧表示切り替えを管理
     * @type {Boolean}
     */
    isPatInfoVisible: false,

    /**
     * @description 指示者リスト
     * @summary 患者情報保存時に指定する指示者リストを管理
     * @type {Array}
     */
    indUserList: [],

    /**
     * @description 指示者の利用者ID
     * @summary 登録対象となる指示者の利用者IDを管理
     * @type {String}
     */
    indUserId: null,

    /**
     * @description 指示者設定フラグ
     * @summary 指示者が設定されているかを管理
     * @type {Boolean}
     */
    isIndUserSetting: false,

    /**
     * @description 身体情報
     * @summary 身体情報のモーダル画面に渡すデータを管理
     * @type {Object}
     */
    selectedPhysicalInfoData: null,

    /**
     * @description 在宅透析患者フラグ
     * @summary 在宅患者かどうかを管理
     * @type {Boolean}
     */
    isHomeDialysisPat: false,

    /**
     * @description 保険情報
     * @summary 保険情報のモーダル画面に渡すデータを管理
     * @type {Object}
     */
    advancedSettings: {},
    /**
     * @description ？？？？患者フラグ
     * @summary patIdがnullな？？？？患者かどうかを管理
     * @type {Boolean}
     */
    isNullPat: false,
    isNullShrPat: false,

    /**
     * @description 他施設フラグ
     * @summary ヘッダーで施設選択時の判定
     * @type {Boolean}
     */
    isOtherFacility: false,
    /**
     * @description 他施設CD
     * @summary ヘッダーで選択した施設を保存
     * @type {Boolean}
     */
    otherFacilityCd: null,
    /**
     * @description 加算情報
     * @summary 患者情報に保存する加算情報
     * @type {Object}
     */
    patAdditionInfo: [],

    /**
     * @description 加算マスタ
     * @type {Object}
     */
    mstAddition: [],

    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    reportStartDate: null,
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    patSearchDetails: [],
    /*add FNSI-患者情報共有よりの改修 江 start*/
    mstFacility: [],

    isOwnFacility: true,
    // add FNSI-修復施設切換Bug 関 start
    selectedFacilityCd: "",
    // add FNSI-修復施設切換Bug 関 end
    isNewPatPage: false,

    defaultSelectedPatId: null,
    /*add FNSI-患者情報共有よりの改修 江 end*/
    /**
     * @description pat_mainのacceptance_status_info更新中フラグ
     * @summary pat_mainのacceptance_status_infoの更新中はtrue
     * @type {Boolean}
     */
    isUpdatingAcceptanceStatusInfo: false,
    /*add  吉 start*/
    simlpSearchQurey: {},
    /*add  吉 end*/
    //add FutreNetWeb+SI課題管理 NO.3786 劉全航 start
    patBirthday: "",
    //add FutreNetWeb+SI課題管理 NO.3786 劉全航 end
    /**
     * @description 検索タイプ(0：初期状態、1：簡易、2：詳細)
     */
    patSearchType: 0,

    isPatInfoChaned: false,

    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    sortPatInfo: [],

    searchedPatInfo: [],

    addSearchedPatInfo: [],

    addSearchedPatInfoSort: [],
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    patSearchedTreatDate: null,
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    // add start 馬 #9578
    patGroupEditSortCondition: [],
    patGroupEditAddSearchedPatInfo: [],
    // add end 馬 #9578
    editedComponentArr: [],
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    searchedDetailedCondtion: null,
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    startRenderPatInfoContent: false,
    physicalInfoUpDate: null,
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    // 患者情報・新規患者登録のカード開閉状態
    cardShowing: {
      patInfoCreate: deepCopy(CardShowingDef),
      patInfo: deepCopy(CardShowingDef),
    },
    // 患者情報・新規患者登録毎の患者情報カード一覧のスクロール位置
    cardListScrollPos: {
      patInfoCreate: 0,
      patInfo: 0,
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    // 機能別患者リストグリッドカラム
    patListGridColumn: null,
  },

  getters: {
    // add start 馬 #9578
    getPatGroupEditSortCondition(state) {
      return state.patGroupEditSortCondition;
    },
    getPatGroupEditAddSearchedPatInfo(state) {
      return state.patGroupEditAddSearchedPatInfo;
    },
    // add end 馬 #9578
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 start
    getMstWard(state) {
      return state.mstWard;
    },
    getDeleteMstWard(state) {
      return state.deleteMstWard;
    },
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 end
    getIsUpdate(state) {
      return state.Is_Update;
    },
    getOperations(state) {
      return state.operation_order;
    },
    getIsAdd(state) {
      return state.Is_Add;
    },
    /*add FNSI-患者情報共有よりの改修 江 start*/
    mstFacility(state) {
      return state.mstFacility;
    },
    isOwnFacility: (state) => state.isOwnFacility,
    // add FNSI-修復施設切換Bug 関 start
    selectedFacilityCd: (state) => state.selectedFacilityCd,
    // add FNSI-修復施設切換Bug 関 end
    defaultSelectedPatId: (state) => state.defaultSelectedPatId,
    getOperation: (state) => state.operation_order,
    isNewPatPage: (state) => state.isNewPatPage,
    /*add FNSI-患者情報共有よりの改修 江 end*/
    inSelectPatAtPatHeaderCreated: (state) =>
      state.inSelectPatAtPatHeaderCreated,
    selectedPat: (state) => state.selectedPat,
    selectedShrPat: (state) => state.selectedShrPat,
    selectedPatIncludeDel: (state) => state.selectedPatIncludeDel,
    selectedPatId: (state) => {
      if (state.selectedPat === null) {
        return null;
      }
      return state.selectedPat.pat_personal_main.pat_id;
    },
    selectedHospPatId: (state) => {
      if (state.selectedPat === null) {
        return null;
      }
      return state.selectedPat.pat_personal_main.hosp_pat_id;
    },
    selectedPatSex: (state) => {
      if (state.selectedPat === null) {
        return null;
      }
      return state.selectedPat.pat_personal_main.pat_sex;
    },
    selectedPatFacilityCd: (state) => {
      if (state.selectedPat === null) {
        return null;
      }
      return state.selectedPat.pat_personal_main.facility_cd;
    },
    selectedPatName: (state) => {
      if (state.selectedPat === null) {
        return null;
      }
      // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
      //return `${state.selectedPat.pat_personal_main.pat_last_name} ${state.selectedPat.pat_personal_main.pat_first_name}`;
      return `${
        state.selectedPat.pat_personal_main.pat_last_name == null
          ? ""
          : state.selectedPat.pat_personal_main.pat_last_name
      }
      ${
        state.selectedPat.pat_personal_main.pat_first_name == null
          ? ""
          : state.selectedPat.pat_personal_main.pat_first_name
      }`;
      // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
    },

    searchedPatList: (state) => state.searchedPatList,
    searchedShrPatList: (state) => state.searchedShrPatList,
    searchedPatListPatGroup: (state) => state.searchedPatListPatGroup,
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    unselectedPatList: (state) => state.unselectedPatList,
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    treatmentPatList: (state) => state.treatmentPatList,
    srcFuncName: (state) => state.srcFuncName,
    isPatInfoPageShowing: (state) => state.isPatInfoPageShowing,
    isHeaderSwipeDisabled: (state) => state.isHeaderSwipeDisabled,
    isLoadingPat: (state) => state.isLoadingPat,
    isPatInfoVisible: (state) => state.isPatInfoVisible,
    indUserList: (state) => state.indUserList,
    indUserId: (state) => state.indUserId,
    isIndUserSetting: (state) => state.isIndUserSetting,
    selectedPhysicalInfoData: (state) => state.selectedPhysicalInfoData,
    isHomeDialysisPat: (state) => state.isHomeDialysisPat,
    advancedSettings: (state) => state.advancedSettings,
    isNullPat: (state) => state.isNullPat,
    isNullShrPat: (state) => state.isNullShrPat,
    getIsOtherFacility: (state) => state.isOtherFacility,
    getOtherFacilityCd: (state) => state.otherFacilityCd,
    patAdditionInfo(state) {
      return state.patAdditionInfo;
    },

    mstAddition(state) {
      return state.mstAddition;
    },

    patSearchDetails: (state) => state.patSearchDetails,
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    getReportStartDate: (state) => state.reportStartDate,
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/
    isUpdatingAcceptanceStatusInfo: (state) =>
      state.isUpdatingAcceptanceStatusInfo,
    //add   吉 start
    getStorSimlpSearchQurey(state) {
      return state.simlpSearchQurey;
    },
    //add   吉 end
    //add FutreNetWeb+SI課題管理 NO.3786 劉全航 start
    getPatBirthday(state) {
      return state.selectedPat.pat_personal_main.pat_birthday;
    },
    //add FutreNetWeb+SI課題管理 NO.3786 劉全航 end
    patSearchType: (state) => state.patSearchType,

    isPatInfoChaned: (state) => state.isPatInfoChaned,

    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    getSortPatInfo(state) {
      return state.sortPatInfo;
    },

    getSearchedPatInfo(state) {
      return state.searchedPatInfo;
    },

    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    getPatSearchedTreatDate(state) {
      return state.patSearchedTreatDate;
    },
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    hasEditedComponent: (state) => {
      return state.editedComponentArr.length > 0;
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    getSearchedDetailedCondtion(state) {
      return state.searchedDetailedCondtion;
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    // 患者情報・新規患者登録画面のカード展開/折畳状態
    getCardShowing: (state) => (cardListName) => {
      return state.cardShowing[cardListName];
    },
    // 患者情報・新規患者登録毎の患者情報カード一覧のスクロール位置
    getCardListScrollPos: (state) => (cardListName) => {
      return state.cardListScrollPos[cardListName];
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    // 機能別患者リストグリッド用列設定取得
    getPatListGridColumn: state => state.patListGridColumn,
  },

  actions: {
    /**
     * @description 新規患者登録
     * @summary 患者情報画面の保存処理で使用する
     * @param {Object} patInfo 登録用患者情報+変更箇所({ pat_personal_main, pat_main, pat_unique, pat_group_info, changed_record })
     */
    async createPat({ getters, commit }, patInfo) {
      const patInfoJson = _.mapObject(patInfo, (value) =>
        JSON.stringify(value)
      );
      const response = await ApiHelper.post(
        "/patInfo/createPat",
        patInfoJson
      ).catch(() => {
        throw new Error("新規患者登録失敗");
      });

      // シーケンスで発行されたpat_idを設定
      const assignedPatId = response.data;
      patInfo.pat_personal_main.pat_id = assignedPatId;
      // 登録患者をリストに追加
      const newPat = {
        pat_id: assignedPatId,
        hosp_pat_id: patInfo.pat_personal_main.hosp_pat_id,
        pat_sex: patInfo.pat_personal_main.pat_sex,
        pat_last_name: patInfo.pat_personal_main.pat_last_name,
        pat_first_name: patInfo.pat_personal_main.pat_first_name,
        is_same: patInfo.pat_main.is_same,
        /*add FNSI-検査結果内結バグの改修 江 start*/
        pat_first_name_kana: patInfo.pat_personal_main.pat_first_name_kana,
        pat_last_name_kana: patInfo.pat_personal_main.pat_last_name_kana,
        in_out_class: patInfo.pat_personal_main.in_out_class,
        /*add FNSI-検査結果内結バグの改修 江 end*/
      };

      // 登録患者と同姓同名患者が存在する場合、患者リストを再検索する
      if (newPat.is_same === "1") {
        // 必要な情報のみ取り出す
        const tmpSearchedPatList = await searchPatList(getters);
        commit("updateSearchedPatList", tmpSearchedPatList);
      }

      commit("addSearchedPatList", [newPat]);
      // commit("setSelectedPat", patInfo);
    },

    /**
     * @description PatHeaderのcreatedでのselectPat処理中かのフラグを設定する
     */
    setInSelectPatAtPatHeaderCreated(
      { commit },
      inSelectPatAtPatHeaderCreated
    ) {
      commit("setInSelectPatAtPatHeaderCreated", inSelectPatAtPatHeaderCreated);
    },

    /**
     * @description 選択患者をストアに格納する
     * @summary 患者選択画面で患者保持のために使用する
     * @param {Number} patId 選択された患者ID
     */
    async selectPat({ commit }, payload) {
      let patId;
      let facilityCd;

      if (typeof payload === "number" || typeof payload === "string") {
        patId = payload;
        facilityCd = null;
      } else {
        patId = payload?.selectedPatId;
        facilityCd = payload?.selectedFacility ?? null;
      }
      if(!patId) return
      // add FNSI-FutreNetWeb+SI課題管理No.5494 李 start
      // const patInfo = await getPatById(patId).catch(() => {
      //   throw new Error();
      // }).finally(() =>store.dispatch("loading-screen/setLoadingScreenVisible", false));
      store.dispatch("loading-screen/startLoadingScreen");
      const patInfo = await getPatById(patId, facilityCd).catch(() => {
        throw new Error();
      });
      
      // 元データ（削除済み含む）を退避
      const patInfoIncludeDel = JSON.parse(JSON.stringify(patInfo));
      
      // add 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関 start
      const requestParam = {
        facilityCd: patInfo.pat_main.facility_cd,
      };
      const response = await ApiHelper.get(
        "/mstInfo/mstInfection",
        requestParam
      ).catch(() => {
        getErrorMessage(
          "InfectionCardContent.vue",
          "created",
          "感染症マスタ取得失敗"
        );
        throw new Error(
          "[InfectionCardContent.vue]created(): 感染症マスタ取得失敗"
        );
      });
      let infectInfoJson = JSON.parse(patInfo.pat_main.infect_info);
      let mstInfect = response.data;
      // mod 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 start
      // let infectList = infectInfoJson.filter(item => mstInfect.find(temp => temp.infectionCd == item.infection_cd));
      // patInfo.pat_main.infect_info = JSON.stringify(infectList);
      let infectinfoList = [];
      for (const mst of mstInfect) {
        const targetInfection = infectInfoJson.find((infection) => {
          return infection.infection_cd == mst.infectionCd;
        });
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          // infectInfoにないコード(患者新規登録時、または新規追加されたマスタ)の場合は結果不明で追加
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
        } else {
          // 存在するコードはそのまま追加
          infection_cd = targetInfection.infection_cd;
          infect = targetInfection.infect;
          exam_date = targetInfection.exam_date;
          up_date = targetInfection.up_date;
        }
        const infection = {
          infection_cd,
          infect,
          exam_date,
          up_date,
        };
        infectinfoList.push(infection);
      }
      patInfo.pat_main.infect_info = JSON.stringify(infectinfoList);
      // mod 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 end
      // add 8331 患者情報の感染症で削除済みの項目がSi側で表示される 関  end
      // add FNSI-FutreNetWeb+SI課題管理No.5494 李 end
      commit("setSelectedPat", patInfo);
      // 元データ（削除済み含む）を保存
      commit("setSelectedPatIncludeDel", patInfoIncludeDel);
      commit("setPhysicalInfoUpDate", null);
      store.dispatch("loading-screen/finishLoadingScreen");
    },

    /**
     * @description 選択患者をストアに格納する
     * @summary 患者選択画面で患者保持のために使用する
     * @param {Number} patId 選択された患者ID
     */
    async selectSharePat({ commit }, payload) {
      let patId;
      let facilityCd;
      let unfinishedShareFlg = false;

      if (typeof payload === "number" || typeof payload === "string") {
        patId = payload;
        facilityCd = null;
      } else {
        patId = payload?.selectedPatId;
        facilityCd = payload?.selectedFacility ?? null;
        unfinishedShareFlg = payload?.unfinishedShareFlg ?? false;
      }
      if(!patId) return
      store.dispatch("loading-screen/startLoadingScreen");
      const patInfo = await getPatById(patId, facilityCd).catch(() => {
        throw new Error();
      });
      const requestParam = {
        facilityCd: patInfo.pat_main.facility_cd,
      };
      const response = await ApiHelper.get(
        "/mstInfo/mstInfection",
        requestParam
      ).catch(() => {
        getErrorMessage(
          "InfectionCardContent.vue",
          "created",
          "感染症マスタ取得失敗"
        );
        throw new Error(
          "[InfectionCardContent.vue]created(): 感染症マスタ取得失敗"
        );
      });
      let infectInfoJson = JSON.parse(patInfo.pat_main.infect_info);
      let mstInfect = response.data;
      let infectinfoList = [];
      for (const mst of mstInfect) {
        const targetInfection = infectInfoJson.find((infection) => {
          return infection.infection_cd == mst.infectionCd;
        });
        let infection_cd;
        let infect;
        let exam_date;
        let up_date;
        if (targetInfection === undefined) {
          // infectInfoにないコード(患者新規登録時、または新規追加されたマスタ)の場合は結果不明で追加
          infection_cd = mst.infectionCd;
          infect = "0";
          exam_date = null;
          up_date = null;
        } else {
          // 存在するコードはそのまま追加
          infection_cd = targetInfection.infection_cd;
          infect = targetInfection.infect;
          exam_date = targetInfection.exam_date;
          up_date = targetInfection.up_date;
        }
        const infection = {
          infection_cd,
          infect,
          exam_date,
          up_date,
        };
        infectinfoList.push(infection);
      }
      patInfo.pat_main.infect_info = JSON.stringify(infectinfoList);
      commit("setSelectedShrPat", deepCopy(patInfo));
      if (!unfinishedShareFlg) { 
        commit("setSelectedPat", patInfo);
        commit("setPhysicalInfoUpDate", null);
      }
      store.dispatch("loading-screen/finishLoadingScreen");
    },

    /**
     * @description 選択患者を未選択状態とする
     */
    clearSelectedPat({ commit }) {
      commit("setSelectedPat", null);
      commit("setSelectedPatIncludeDel", null);
    },

    /**
     * @description 選択患者更新
     * @summary 患者情報画面の保存処理で使用する
     * @param {Object} patInfo 更新用患者レコード+変更箇所({ pat_personal_main, pat_main, pat_unique, pat_group_info, is_changed_next_pat_info, changed_record })
     */
    async updatePat({ getters, commit }, patInfo) {
      const uri = "/patInfo/updatePatById";
      const patId = getters.selectedPatId;
      const patInfoJson = _.mapObject(patInfo, (value) =>
        JSON.stringify(value)
      );

      // mod FNSI-排他処理 劉 start
      //await ApiHelper.put(`${uri}/${patId}`, patInfoJson).catch(() => {
      //throw new Error("患者更新失敗");
      await ApiHelper.put(`${uri}/${patId}`, patInfoJson).catch((error) => {
        throw error;
        // mod FNSI-排他処理 劉 end
      });
      // commit("setSelectedPat", patInfo);

      // 患者リストも更新
      const newRecord = {
        pat_id: patId,
        hosp_pat_id: patInfo.pat_personal_main.hosp_pat_id,
        pat_sex: patInfo.pat_personal_main.pat_sex,
        pat_last_name: patInfo.pat_personal_main.pat_last_name,
        pat_first_name: patInfo.pat_personal_main.pat_first_name,
        is_same: patInfo.pat_main.is_same,
        /*add FNSI-検査結果内結バグの改修 江 start*/
        pat_first_name_kana: patInfo.pat_personal_main.pat_first_name_kana,
        pat_last_name_kana: patInfo.pat_personal_main.pat_last_name_kana,
        in_out_class: patInfo.pat_personal_main.in_out_class,
        /*add FNSI-検査結果内結バグの改修 江 end*/
      };

      // 必要な情報のみ取り出す
      const tmpSearchedPatList = await searchPatList(getters);

      const updatedPatIndex = tmpSearchedPatList.findIndex(
        (pat) => pat.pat_id === patId
      );
      if (updatedPatIndex === -1) {
        // 選択中に患者リストが更新されリストに存在しなくなった場合
        tmpSearchedPatList.push(newRecord);
      } else {
        tmpSearchedPatList.splice(updatedPatIndex, 1, newRecord);
      }

      commit("updateSearchedPatList", tmpSearchedPatList);
      commit("setPhysicalInfoUpDate", null);
    },

    /**
     * @description 患者検索
     * @summary pat_personal_mainを検索する
     * @param {String} sql 検索用SQL
     * @returns {Array} 患者情報オブジェクト配列([{ pat_id, hosp_pat_id, pat_last_name, pat_first_name }, ...])
     */
    async searchPat({ commit }, sql) {
      const uri = `/patInfo/getSearchResultPersonal`;
      const response = await ApiHelper.post(`${uri}`, { sql }).catch(() => {
        throw new Error("患者検索失敗");
      });
      commit("addSearchedPatList", response.data);
    },
    // 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  start
    async searchPatPatGroup({ commit }, sql) {
      const uri = `/patInfo/getSearchResultPersonal`;
      const response = await ApiHelper.post(`${uri}`, { sql }).catch(() => {
        throw new Error("患者検索失敗");
      });
      commit("addSearchedPatListPatGroup", response.data);
    },
    // 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  end

    /**
     * @description 患者検索結果クリア
     */
    clearSearchedPatList({ commit }) {
      commit("updateSearchedPatList", []);
    },

    //add 10389 患者グループ既存BUG gjn start
    /**
     * @description 患者検索結果クリア,患者グループ
     */
    clearSearchedPatListGroup({ commit }) {
      commit("updateUnSelectedPatList", []);
    },
    //add 10389 患者グループ既存BUG gjn end

    /**
     * @description 患者リストソート
     * @param {Array} sortConditions ソート条件オブジェクト配列
     *   [
     *     { key(第1ソートキー文字列), isAsc(並び順フラグ true: 昇順 false: 降順) },
     *     { key(第2ソートキー文字列), isAsc },
     *     { key(第3ソートキー文字列), isAsc }
     *   ]
     */
    async sortPatList({ getters, commit, rootGetters }, sortConditions) {
      const facilityCd = rootGetters["user/getFacilityCd"];
      const treatDate = rootGetters["report-menu/getTreatDate"];
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
      const detailedCondtion = getters.getSearchedDetailedCondtion;
      // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

      // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
      // const tmpPatList = deepCopy(getters.searchedPatList);
      // // 患者リストにはソート用データがないので取得
      // const patIdList = getters.searchedPatList.map(pat => pat.pat_id);
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      let isPatGroup = false;
      for (const condition of sortConditions) {
        if (condition.hasOwnProperty("patGroup")) {
          isPatGroup = true;
          break;
        }
      }
      let tmpPatList;
      let patIdList;
      // if (getters.getAddSearchedPatInfo && getters.getAddSearchedPatInfo.length > 0 ) {
      //   tmpPatList = deepCopy(getters.getAddSearchedPatInfo);
      //   patIdList = getters.getAddSearchedPatInfo.map(pat => pat.pat_id);
      // } else {
      //   tmpPatList = deepCopy(getters.searchedPatList);
      //   patIdList = getters.searchedPatList.map(pat => pat.pat_id);
      // }
      // mod start 馬 #9578
      if (isPatGroup) {
        if (getters.getPatGroupEditAddSearchedPatInfo?.length) {
          tmpPatList = deepCopy(getters.getPatGroupEditAddSearchedPatInfo);
          patIdList = tmpPatList.map((pat) => pat.pat_id);
        } else {
          tmpPatList = deepCopy(getters.unselectedPatList);
          patIdList = tmpPatList.map((pat) => pat.pat_id);
        }
      } else {
        tmpPatList = deepCopy(getters.searchedPatList);
        patIdList = getters.searchedPatList.map((pat) => pat.pat_id);
      }
      // mod end 馬 #9578
      // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      if (patIdList.length === 0) {
        return;
      }
      //mod 10389 フロントエンドソート解除機能 gjn start
      const { data: patList } = await ApiHelper.post(
        "/patInfo/getPatByIdList/" + "1",
        {
          patIdList,
          sortConditions,
          treatDate,
          facilityCd,
          tmpPatList,
          // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
          detailedCondtion,
          // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
        }
      ).catch((err) => {
        throw new Error(err);
      });
      //バックエンドのソート
      tmpPatList = JSON.parse(patList.tmpPatListSort);
      //mod 10389 フロントエンドソート解除機能 gjn end

      //del 10389 フロントエンドソート解除機能 gjn start
      //patList.pat_personal_main = JSON.parse(patList.pat_personal_main);
      //patList.pat_main = JSON.parse(patList.pat_main);
      // add FNSI-No.341 患者リストのソート項目不足 吉 start
      // if(null != patList.pat_unique){
      //   patList.pat_unique = JSON.parse(patList.pat_unique);
      // }
      //主たる透析困難理由
      // if(null != patList.mst_dialysis_difficulty){
      //   patList.mst_dialysis_difficulty = JSON.parse(patList.mst_dialysis_difficulty);
      // }
      //治療方法
      // if(null != patList.mst_treatment){
      //   patList.mst_treatment = JSON.parse(patList.mst_treatment);
      // }
      //重症度
      // if(null != patList.mst_severity){
      //   patList.mst_severity = JSON.parse(patList.mst_severity);
      // }
      //搬送区分
      // if(null != patList.mst_transport){
      //   patList.mst_transport = JSON.parse(patList.mst_transport);
      // }
      //透析導入原疾患  主病
      // if(null != patList.mst_disease){
      //   patList.mst_disease = JSON.parse(patList.mst_disease);
      // }
      //診療科  透析実施科
      // if(null != patList.mst_course){
      //   patList.mst_course = JSON.parse(patList.mst_course);
      // }
      //病棟
      // if(null != patList.mst_ward){
      //   patList.mst_ward = JSON.parse(patList.mst_ward);
      // }
      // add FNSI-No.341 患者リストのソート項目不足  吉 end
      // let ordList = [];
      // if (treatDate !== "") {
      //   const response = await ApiHelper.post(
      //     `/mainData/selectByPatIdsWithBedAndKur/${facilityCd}/${treatDate}`,
      //     {patIds: patIdList}
      //   ).catch(error => { throw error; });
      //   ordList = response.data;
      // }
      // ソート用データを紐付ける
      // tmpPatList.forEach(async pat => {
      //   const personalInfo = patList.pat_personal_main.find( el => el.pat_id === pat.pat_id );
      //   const mainInfo = patList.pat_main.find(el => el.pat_id === pat.pat_id);
      //   // add FNSI-No.341 患者リストのソート項目不足  吉 start
      //   const patUniqueInfo = patList.pat_unique.find(el => el.pat_id === pat.pat_id);
      //   // add FNSI-No.341 患者リストのソート項目不足  吉 end
      //   pat.pat_id = personalInfo.pat_id;
      //   pat.facility_cd = mainInfo.facility_cd;
      //   pat.pat_birthday = personalInfo.pat_birthday;
      //   pat.pat_birthday_age = personalInfo.pat_birthday;
      //   pat.in_out_class = personalInfo.in_out_class;
      //   pat.dialysis_start_date = JSON.parse(
      //     mainInfo.medical_care_info
      //   ).dialysis_start_date;
      //   pat.hosp_pat_id = personalInfo.hosp_pat_id;
      //   pat.pat_name = [personalInfo.pat_last_name || "", personalInfo.pat_first_name || ""].join(" ").trim();
      //   pat.pat_name_kana = [personalInfo.pat_last_name_kana || "", personalInfo.pat_first_name_kana || ""].join(" ").trim();
      //   pat.pat_name_alpha = [personalInfo.pat_last_name_alpha || "", personalInfo.pat_first_name_alpha || ""].join(" ").trim();
      //   pat.in_out_current_state = mainInfo.in_out_current_state !== null ? +mainInfo.in_out_current_state : -1;
      //   pat.pat_blood_type_abo = personalInfo.pat_blood_type_abo !== null ? personalInfo.pat_blood_type_abo : -1;
      //   pat.pat_sex = personalInfo.pat_sex;
      //   pat.pat_kur = "";
      //   pat.pat_bed_name = "";
      //   // add FNSI-No.341 患者リストのソート項目不足 吉 start
      //   pat.taboo_allergy_info = mainInfo.taboo_allergy_info !== null && mainInfo.taboo_allergy_info !=="[]" ?
      //     JSON.parse(mainInfo.taboo_allergy_info)[0].taboo_allergy_class :-1;
      //   pat.is_infect = mainInfo.is_infect !== null ? mainInfo.is_infect :-1;
      //   pat.is_implant = mainInfo.is_implant !== null ? mainInfo.is_implant :-1;
      //   pat.is_diabetes = mainInfo.is_diabetes !== null ? mainInfo.is_diabetes :-1;
      //   pat.is_blood_suger_exam = mainInfo.is_blood_suger_exam !== null ? mainInfo.is_blood_suger_exam :-1;
      //   pat.is_wheel_chair = mainInfo.is_wheel_chair !== null ? mainInfo.is_wheel_chair :-1;

      //   pat.main_course_cd=mainInfo.medical_care_info !== null && mainInfo.medical_care_info !=="[]" ?
      //     JSON.parse(mainInfo.medical_care_info).main_course_cd :-1;
      //   pat.dialysis_course_cd=mainInfo.medical_care_info !== null && mainInfo.medical_care_info !=="[]" ?
      //     JSON.parse(mainInfo.medical_care_info).dialysis_course_cd :-1;
      //   pat.ward_cd=mainInfo.medical_care_info !== null && mainInfo.medical_care_info !=="[]" ?
      //     JSON.parse(mainInfo.medical_care_info).ward_cd :-1;
      //   pat.severity_cd=personalInfo.severity_cd !== null  ?  personalInfo.severity_cd :-1;
      //   pat.transport_cd=personalInfo.transport_cd !== null  ?  personalInfo.transport_cd :-1;
      //   //主たる透析困難理由
      //   if(null != personalInfo.dial_diff_com_info){
      //     var personalJson = JSON.parse(personalInfo.dial_diff_com_info);
      //     var flag= false;
      //     for(var i=0;i< personalJson.length;i++){
      //       if(personalJson[i].is_main == "1"){
      //         pat.dial_diff_com_info=personalJson[i].dial_diff_cd;
      //         flag=true;
      //       }
      //     }
      //     if(!flag){
      //       pat.dial_diff_com_info=-1;
      //     }
      //   }else{
      //     pat.dial_diff_com_info=-1;
      //   }
      //   //透析導入原疾患   主病
      //   if(patUniqueInfo && null != patUniqueInfo.medical_hst_info){
      //     var uniqueJson = JSON.parse(patUniqueInfo.medical_hst_info);
      //     var flag1= false;
      //     var flag2= false;
      //     for(var k=0;k< uniqueJson.length;k++){
      //       if(uniqueJson[k].is_dialysis_underlying_disease == "1"){
      //         pat.is_dia_under_dis=uniqueJson[k].disease_cd;
      //         flag1=true;
      //       }
      //       if(uniqueJson[k].is_main_disease == "1"){
      //         pat.is_main_disease=uniqueJson[k].disease_cd;
      //         flag2=true;
      //       }
      //     }
      //     if(!flag1){
      //       pat.is_dia_under_dis=-1;
      //     }
      //     if(!flag2){
      //       pat.is_main_disease=-1;
      //     }
      //   }else{
      //     pat.is_main_disease=-1;
      //     pat.is_dia_under_dis=-1;
      //   }
      //   // add FNSI-No.341 患者リストのソート項目不足  吉 end

      //   if (ordList.length > 0) {
      //     const ord = ordList.find(ord => ord.patId === pat.pat_id);
      //     if (ord) {
      //       pat.pat_kur = ord.kurStartTime || "";
      //       pat.pat_bed_name = ord.bedName || "";
      //       // add FNSI-No.341 患者リストのソート項目不足 吉 start
      //       pat.ind_tr_cd=ord.indTreatmentCd || "";
      //       // add FNSI-No.341 患者リストのソート項目不足  吉 end
      //     }
      //   }

      // });
      //解释：根据isAsc参数来判断是升序还是降序排序，然后比较a和b的大小，isAsc(true: 昇順 false: 降順)
      // ソート用比較関数
      // const compareFunc = (a, b, isAsc) => {
      //   if (isAsc) {
      //     return a < b ? -1 : a > b ? 1 : 0;
      //   }
      //   return a > b ? -1 : a < b ? 1 : 0;
      // };
      // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm start
      // 患者IDソート用比較関数(hosp_pat_idを左から12桁まで埋め合わせて、ソートする。埋め合わせたidが同じ場合、実際idとしてソートする)
      // const compareHospPatIdFunc = (a, b, isAsc) => {
      //   // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 start
      //   if(null != a && a.replace(/0/g, "") == '' && null != b && b.replace(/0/g, "") == ''){
      //     if (isAsc) {
      //       return a.length < b.length ? -1 : a.length > b.length ? 1 :0;
      //     }
      //     return a.length > b.length ? -1 : a.length < b.length ? 1 : 0;
      //   }
      //   // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる 吉 end
      //   const aByZero = a.padStart(12, '0').toLowerCase();
      //   const bByZero = b.padStart(12, '0').toLowerCase();
      //   if (isAsc) {
      //     return aByZero < bByZero ? -1 : aByZero > bByZero ? 1 : a < b ? 1 : a > b ? -1 :0;
      //   }
      //   return aByZero > bByZero ? -1 : aByZero < bByZero ? 1 : a > b ? 1 : a < b ? -1 : 0;
      // };
      // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm end

      // ソート用関数
      // const sortFunc = (a, b, sortCondition) => {
      //   const sortKey = sortCondition.key;
      //   const isAsc = !!sortCondition.isAsc;
      //   const [valueA, valueB] = [a[sortKey], b[sortKey]];
      //   if (valueA !== valueB) {
      //     // mod FNSI-No.341 患者リストのソート項目不足 吉 start
      //     // if (sortKey === "pat_birthday" || sortKey === "dialysis_start_date" || sortKey === "pat_birthday_age") {
      //     if (sortKey === "pat_birthday" || sortKey === "dialysis_start_date" ) {
      //       // mod FNSI-No.341 患者リストのソート項目不足 吉 end
      //       // 日付未登録は一番若い扱い
      //       const dateA = valueA ? valueA : "99991231";
      //       const dateB = valueB ? valueB : "99991231";
      //       // 年齢・透析歴の昇順は日付の降順となる
      //       return compareFunc(dateA, dateB, !isAsc);
      //     }

      //     // add FNSI-No.341 患者リストのソート項目不足 吉 start
      //     if(sortKey === "pat_birthday_age"){
      //       const dateA = valueA ? valueA : "99991231";
      //       const dateB = valueB ? valueB : "99991231";
      //       return compareFunc(dateA, dateB, isAsc);
      //     }
      //     //診療科  透析実施科
      //     if(sortKey === "main_course_cd" || sortKey === "dialysis_course_cd"){
      //       for(var i=0;i<patList.mst_course.length;i++){
      //         var numA;
      //         var numB;
      //         if(patList.mst_course[i] == a[sortKey]){
      //           numA=i;
      //         }
      //         if(patList.mst_course[i] == b[sortKey]){
      //           numB=i;
      //         }
      //       }
      //       return compareFunc(numA, numB, isAsc);
      //     }
      //     //病棟
      //     if(sortKey === "ward_cd"){
      //       for(var ii=0;ii<patList.mst_ward.length;ii++){
      //         var numAA;
      //         var numBB;
      //         if(patList.mst_ward[ii] == a[sortKey]){
      //           numAA=ii;
      //         }
      //         if(patList.mst_ward[ii] == b[sortKey]){
      //           numBB=ii;
      //         }
      //       }
      //       return compareFunc(numAA, numBB, isAsc);
      //     }
      //     //重症度
      //     if(sortKey === "mst_severity" ){
      //       for(var k=0;k<patList.mst_severity.length;k++){
      //         var numC;
      //         var numD;
      //         if(patList.mst_severity[k] == a[sortKey]){
      //           numC=k;
      //         }
      //         if(patList.mst_severity[k] == b[sortKey]){
      //           numD=k;
      //         }
      //       }
      //       return compareFunc(numC, numD, isAsc);
      //     }
      //     //搬送区分
      //     if( sortKey === "mst_transport"){
      //       for(var j=0;j<patList.mst_transport.length;j++){
      //         var numE;
      //         var numF;
      //         if(patList.mst_transport[j] == a[sortKey]){
      //           numE=j;
      //         }
      //         if(patList.mst_transport[j] == b[sortKey]){
      //           numF=j;
      //         }
      //       }
      //       return compareFunc(numE, numF, isAsc);
      //     }
      //     //主たる透析困難理由
      //     if( sortKey === "dial_diff_com_info"){
      //       for(var l=0;l<patList.mst_dialysis_difficulty.length;l++){
      //         var numG;
      //         var numH;
      //         if(patList.mst_dialysis_difficulty[l] == a[sortKey]){
      //           numG=l;
      //         }
      //         if(patList.mst_dialysis_difficulty[l] == b[sortKey]){
      //           numH=l;
      //         }
      //       }
      //       return compareFunc(numG, numH, isAsc);
      //     }
      //     //透析導入原疾患   主病
      //     if( sortKey === "is_dia_under_dis" || sortKey === "is_main_disease"){
      //       for(var y=0;y<patList.mst_disease.length;y++){
      //         var numI;
      //         var numJ;
      //         if(patList.mst_disease[y] == a[sortKey]){
      //           numI=y;
      //         }
      //         if(patList.mst_disease[y] == b[sortKey]){
      //           numJ=y;
      //         }
      //       }
      //       return compareFunc(numI, numJ, isAsc);
      //     }
      //     //治療方法
      //     if( sortKey === "ind_tr_cd"){
      //       for(var q=0;q<patList.mst_treatment.length;q++){
      //         var numK;
      //         var numL;
      //         if(patList.mst_treatment[q] == a[sortKey]){
      //           numK=q;
      //         }
      //         if(patList.mst_treatment[q] == b[sortKey]){
      //           numL=q;
      //         }
      //       }
      //       return compareFunc(numK, numL, isAsc);
      //     }
      //     // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm start
      //     // 患者ID
      //     if( sortKey === "hosp_pat_id"){
      //       return compareHospPatIdFunc(valueA, valueB, isAsc);
      //     }
      //     // add #9948 患者IDのソートが桁数を考慮せずに左端の数字からソートされる zkm end
      //     // add FNSI-No.341 患者リストのソート項目不足  吉 end
      //     return compareFunc(valueA, valueB, isAsc);
      //   }
      //   return 0;
      // };

      // tmpPatList.sort((a, b) => {
      //   // 第1ソート条件
      //   const sortResult1 = sortFunc(a, b, sortConditions[0]);
      //   if (sortResult1 !== 0) {
      //     return sortResult1;
      //   }
      //   // 同値は下位のソート条件で続行

      //   // 第2ソート条件
      //   if (!sortConditions[1]) {
      //     return 0;
      //   }
      //   const sortResult2 = sortFunc(a, b, sortConditions[1]);
      //   if (sortResult2 !== 0) {
      //     return sortResult2;
      //   }

      //   // 第3ソート条件
      //   if (!sortConditions[2]) {
      //     return 0;
      //   }
      //   return sortFunc(a, b, sortConditions[2]);
      // });

      //let tmpStr = "6299_PatInfoStore_sortPatList: ";

      // ソート用プロパティを削除
      // tmpPatList.forEach(pat => {
      //   delete pat.pat_birthday;
      //   //del 入外区分が入院の場合、患者名は紫色にする  吉 start
      //   // delete pat.in_out_class;
      //   //del 入外区分が入院の場合、患者名は紫色にする  吉 end
      //   delete pat.dialysis_start_date;

      //   tmpStr = tmpStr + pat.patId + ", ";
      // });
      // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
      // commit("updateSearchedPatList", tmpPatList);
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      // if (getters.getAddSearchedPatInfo && getters.getAddSearchedPatInfo.length > 0 ) {
      //   commit("setAddSearchedPatInfo", tmpPatList);
      // } else {
      //   commit("updateSearchedPatList", tmpPatList);
      // }
      // mod start 馬 #9578
      //del 10389 フロントエンドソート解除機能 gjn end

      if (isPatGroup) {
        if (getters.getPatGroupEditAddSearchedPatInfo?.length) {
          commit("setPatGroupEditAddSearchedPatInfo", tmpPatList);
        } else {
          commit("updateUnSelectedPatList", tmpPatList);
        }
      } else {
        commit("updateSearchedPatList", tmpPatList);
      }
      // mod end 馬 #9578
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    },

    /**
     * @description 在宅透析患者フラグ
     */
    async checkHomeDialysisPat({ getters, commit }) {
      let returnval = false;
      const response = await ApiHelper.put(
        `/patInfo/findHomeDialysisPat/${getters.selectedPatId}`
      ).catch((error) => {
        throw error;
      });
      if ("" === response.data || null === response.data) {
        returnval = false;
      } else {
        returnval = true;
      }
      commit("setIsHomeDialysisPat", returnval);
    },

    async setAdvancedSettings({ getters, commit }) {
      const responseFacility = await sendRequestGetMstFacilityByCd(
        getters.selectedPatFacilityCd
      ).catch((error) => {
        throw error;
      });
      let advancedSettings = {};
      try {
        if (responseFacility.data.advancedSettings) {
          advancedSettings = JSON.parse(responseFacility.data.advancedSettings);
        }
      } catch {
        advancedSettings = {};
      }
      if (!advancedSettings.func_advcds) {
        advancedSettings.func_advcds = [];
      }
      commit("setAdvancedSettings", advancedSettings);
    },

    setSearchedPatList({ commit }, searchedPatList) {
      commit("setSearchedPatList", searchedPatList);
    },
    setSearchedShrPatList({ commit }, searchedShrPatList) {
      if (!searchedShrPatList) {
        commit("setSearchedPatList", null);
        commit("setSearchedShrPatList", null);
        return;
      }
      const filteredList = searchedShrPatList.filter((item) => item?.hosp_pat_id);
      commit("setSearchedPatList", filteredList);
      commit("setSearchedShrPatList", searchedShrPatList);
    },
    setSearchedPatListPatGroup({ commit }, setSearchedPatListPatGroup) {
      commit("setSearchedPatListPatGroup", setSearchedPatListPatGroup);
    },
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    setUnselectedPatListForGroup({ commit }, unselectedPatList) {
      commit("updateUnSelectedPatList", unselectedPatList);
    },
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    setIsNullPat({ commit }, bool) {
      // ？？？？患者フラグセット
      commit("setIsNullPat", bool);
    },
    setIsNullShrPat: (state, b) => {
      state.isNullShrPat = b;
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    setReportStartDate({ commit }, reportStartDate) {
      commit("setReportStartDate", reportStartDate);
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/

    /**
     * @description 加算・管理料リストを作成
     * @summary 加算マスタを取得して初期表示用の加算・管理料リストを作成
     * @param {String} routeName ルート画面名
     * @returns {Array} 患者情報の加算情報オブジェクト配列([{ cd, is_enable, reg_date, last_date }, ...])
     */
    async sendRequestGetMstAddition(
      { state, commit, rootGetters, getters },
      {routeName, loginFacilityCd, ownFacility}
    ) {
      // 初期化
      commit("setPatAdditionInfo", []);
      commit("setMstAddition", []);

      // 施設コードの取得 新規患者登録時か否かで取得元変更
      // const facilityCd =
      //   state.selectedPat && routeName !== "pat-info-create"
      //     ? state.selectedPat.pat_personal_main.facility_cd
      //     : rootGetters["user/getFacilityCd"];

      const facilityCd =
        state.selectedPat && routeName !== "pat-info-create"
          ? (state.isOtherFacility
            ? (state.otherFacilityCd ?? loginFacilityCd)
            : loginFacilityCd)
          : rootGetters["user/getFacilityCd"];

      // 加算日情報の取得(患者情報表示時のみ実施)
      let calculationDateList = null;
      if (state.selectedPat && routeName !== "pat-info-create") {
        // 表示患者の加算情報の最新算定日を取得する
        calculationDateList = await ApiHelper.get(
          "/addition_info/calculationDateList",
          {
            patId: getters.selectedPatId,
            ownFacility: ownFacility,
            facilityCd: facilityCd
          }
        ).catch((error) => {
          throw error;
        });
      }

      // 加算マスタ取得
      await ApiHelper.get("/mstInfo/mstAddition", { facilityCd }).then(
        (response) => {
          if (response.data) {
            // 加算マスタをstateに保存
            commit("setMstAddition", response.data);

            // 初期表示用の加算・管理料リストを作成
            let lisPatAddition = [];
            for (let i = 0; i < response.data.length; i++) {
              const patItem = response.data[i];
              // 算定日を取得
              let lastDate = "";
              if (
                calculationDateList != null &&
                calculationDateList.data.length > 0
              ) {
                const addition = calculationDateList.data.find((add) => {
                  return add.cd == patItem.additionCd;
                });
                if (typeof addition === "object") {
                  lastDate = addition.last_date;
                }
              }

              const additionPat = {
                sort_order: i,
                cd: patItem.additionCd,
                is_enable: "0",
                last_date: lastDate,
                reg_date: patItem.regDate,
              };
              lisPatAddition.push(additionPat);
            }
            commit("setPatAdditionInfo", lisPatAddition);
          }
        }
      );
      // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 start
      ApiHelper.get("/mstInfo/mstWardIncludeDel", { facilityCd })
        .then((response) => {
          let deleteMstWard = response.data;
          let mstWard = response.data.filter((item) => {
            return item.isDisp !== "0" && item.isDel !== "1";
          });
          commit("setMstWard", mstWard);
          commit("setDeleteMstWard", deleteMstWard);
        })
        .catch((error) => {
          getErrorMessage("PatInfoStore.vue", "created", error);
          throw error;
        });
      // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 end
    },

    /**
     * @description 資料進捗状況を取得する
     */
    async getAcceptanceStatusInfo({ state, commit, getters }) {
      const patId = getters.selectedPatId;
      if (patId) {
        // 更新中
        state.isUpdatingAcceptanceStatusInfo = true;

        // 選択中患者Idの治療進捗状況(pat_main.acceptance_status_info)を取得する
        await getWithLoader(`/patInfo/getAcceptanceStatusInfo/${patId}`)
          .then((response) => {
            if (response.data) {
              commit("setAcceptanceStatusInfo", response.data);
            }
          })
          .catch((error) => {
            throw new Error("患者治療進捗状態取得失敗 error:" + error);
          })
          .finally(function () {
            // 更新完了
            state.isUpdatingAcceptanceStatusInfo = false;
          });
      }
    },
    /**
     * @description 患者治療進捗状態を再構築する
     */
    async rebuildAcceptanceStatusInfo({ state, commit, getters }) {
      const patId = getters.selectedPatId;
      if (patId) {
        store.dispatch("loading-screen/setLoadingScreenVisible", true);
        // 更新中
        state.isUpdatingAcceptanceStatusInfo = true;

        // 選択中患者Idの治療進捗状況(pat_main.acceptance_status_info)を更新して結果を取得する
        await postWithLoader(`/patInfo/rebuildAcceptanceStatusInfo/${patId}`)
          .then((response) => {
            if (response.data) {
              commit("setAcceptanceStatusInfo", response.data);
              store.dispatch("loading-screen/setLoadingScreenVisible", false);
            }
          })
          .catch((error) => {
            store.dispatch("loading-screen/setLoadingScreenVisible", false);
            throw new Error("患者治療進捗状態更新失敗 error:" + error);
          })
          .finally(function () {
            // 更新完了
            state.isUpdatingAcceptanceStatusInfo = false;
          });
      }
    },
    /*add FNSI-患者情報共有よりの改修 江 start*/
    setMstFacility({ commit }, mstFacility) {
      commit("setMstFacility", mstFacility);
    },
    setIsOwnFacility({ commit }, isOwnFacility) {
      commit("setIsOwnFacility", isOwnFacility);
    },
    // add FNSI-修復施設切換Bug 関 start
    setSelectedFacilityCd({ commit }, selectedFacilityCd) {
      commit("setSelectedFacilityCd", selectedFacilityCd);
    },
    // add FNSI-修復施設切換Bug 関 end
    setIsNewPatPage({ commit }, isNewPatPage) {
      commit("setIsNewPatPage", isNewPatPage);
    },
    setDefaultSelectedPatId({ commit }, defaultSelectedPatId) {
      commit("setDefaultSelectedPatId", defaultSelectedPatId);
    },
    /*add FNSI-患者情報共有よりの改修 江 end*/
    //add   吉 start
    setStorSimlpSearchQurey({ commit }, params) {
      commit("setStorSimlpSearchQurey", params);
    },
    //add   吉 end
    setPatSearchType({ commit }, type) {
      commit("setPatSearchType", type);
    },

    // 機能別患者リスト：grid列項目作成
    async setPatListGridColumn({ commit ,rootGetters},searchedCountText) {
      // 列幅(文字サイズ考慮)
      const getWidthArray = emValue => {
        switch (emValue) {
          case 1:
            return [52, 60, 62, 66];
          case 2:
            return [52, 58, 60, 66];
          case 3:
            return [77, 89, 95, 107];
          case 4:
            return [66, 72, 78, 86];
          case 5:
            return [67, 82, 89, 105];
          case 6:
            return [84, 105, 115, 135];
          case 7:
          default:
            return [135, 124, 136, 135];
        }
      };

      // 表示列設定取得
      const facilityCd = rootGetters["user/getFacilityCd"];
      const response = await sendRequestGetMstFacilitySettingValue(
        facilityCd, FACILITY_PAT_SEARCH_DISP_SETTING
      );

      // 表示対象の列設定をセット
      let columns = []
      if(response?.data){
        response?.data.forEach(item =>{
          // itemがsys_facility_setting.option_valueのIDと紐づけ必須
          switch (item) {
            case "0":
              columns.push(
                {
                  key: "viewTreatDate",
                  code: "viewTreatDate",
                  field: "viewTreatDate",
                  title: "治療日",
                  width: getWidthArray(5),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "1":
              columns.push(
                {
                  key: "kur_name",
                  code: "kurCd",
                  field: "kur_name",
                  title: "クール",
                  width: getWidthArray(4),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "2":
              columns.push(
                {
                  key: "bed_name",
                  code: "bedCd",
                  field: "bed_name",
                  title: "ベッド",
                  width: getWidthArray(4),
                  centerAlign: false,
                  hidden: false,
                  locked: false,
                  lockable: false
                }
              )
              break;
            case "3":
              columns.push(
                {
                  key: "pat_id",
                  code: "pat_id",
                  field: "pat_id",
                  title: "患者ID",
                  width: getWidthArray(6),
                  centerAlign: false,
                  hidden: false,
                  locked: false,
                  lockable: false
                }
              )
              break;
            case "4":
              // 名前部
              const nameText = `if (pat_id) { if (pat_last_name) {##: pat_last_name # # } if (pat_first_name) {##: pat_first_name # # } } else { # ？？？？患者 # }`
              columns.push(
                {
                  key: "patName",
                  code: "patName",
                  field: "patName",
                  title: "患者名",
                  width: getWidthArray(7),
                  centerAlign: false,
                  hidden: false,
                  lockable: false,
                  headerTemplate:`患者名<span class="searched-cnt">${searchedCountText}</span>`,
                  template: `#if (is_same === \"1\") { ${nameText}#<img src=\"${imgDuplication}\" class=\"same-icon\"> #} else { ${nameText} } #`,

                }
              )
              break;
            case "5":
              columns.push(
                {
                  key: "dialysisState",
                  code: "rstDialysisState",
                  field: "dialysisState",
                  title: "治療",
                  width: getWidthArray(2),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "6":
              columns.push(
                {
                  key: "roundState",
                  code: "roundState",
                  field: "roundState",
                  title: "回診",
                  width: getWidthArray(1),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "7":
              columns.push(
                {
                  key: "startTime",
                  code: "startTime",
                  field: "startTime",
                  title: "開始時刻",
                  width: getWidthArray(3),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "8":
              columns.push(
                {
                  key: "endScheduleTime",
                  code: "endScheduleTime",
                  field: "endScheduleTime",
                  title: "終了予定",
                  width: getWidthArray(3),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            case "9":
              columns.push(
                {
                  key: "endTime",
                  code: "endTime",
                  field: "endTime",
                  title: "終了時刻",
                  width: getWidthArray(3),
                  centerAlign: false,
                  hidden: false,
                  lockable: false
                }
              )
              break;
            default:
              break;
          }
        });
      }

      // 項目列セット
      commit("setPatListGridColumn", columns);
    },
    // グリッド列幅設定
    setGridColumnWidth({ commit }, params) {
      commit("setGridColumnWidth", params);
    },
  },
  mutations: {
    // add start 馬 #9578
    setPatGroupEditSortCondition(state, condition) {
      state.patGroupEditSortCondition = condition;
    },
    setPatGroupEditAddSearchedPatInfo(state, info) {
      state.patGroupEditAddSearchedPatInfo = info;
    },
    // add end 馬 #9578
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 start
    setMstWard(state, data) {
      state.mstWard = data;
    },
    setDeleteMstWard(state, data) {
      state.deleteMstWard = data;
    },
    // add 7770 患者情報のパンくずリストの更新でマスタ情報を読み込んでいない 趙 end
    //add   吉 start
    setStorSimlpSearchQurey(state, data) {
      state.simlpSearchQurey = data;
    },
    //add   吉 end
    setIsAdd(state, data) {
      state.Is_Add = data;
    },
    setIsUpdate(state, data) {
      state.Is_Update = data;
    },
    setOperation(state, data) {
      state.operation_order = data;
    },
    setInSelectPatAtPatHeaderCreated(state, inSelectPatAtPatHeaderCreated) {
      state.inSelectPatAtPatHeaderCreated = inSelectPatAtPatHeaderCreated;
    },
    /**
     * @description 患者検索結果ストア格納
     * @param {Object} patRecord 更新用患者レコード
     */
    setSelectedPat: (state, patRecord) => {
      state.selectedPat = patRecord;
    },
    setSelectedShrPat: (state, patRecord) => {
      state.selectedShrPat = patRecord;
    },
    clearSelectedShrPat(state) {
      state.selectedShrPat = null;
    },
    /**
     * @description 患者検索結果(感染症マスタ削除済み含む)ストア格納
     * @param {Object} patRecord 更新用患者レコード
     */
    setSelectedPatIncludeDel: (state, patRecord) => {
      state.selectedPatIncludeDel = patRecord;
    },

    /**
     * @description 患者検索結果ストア格納
     * @param {Array} patRecords 患者検索結果
     */
    addSearchedPatList: (state, patRecords) => {
      const margedPatList = deduplicateObjects(
        [...state.searchedPatList, ...patRecords],
        "pat_id"
      );
      state.searchedPatList = margedPatList;
    },
    // 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  start
    addSearchedPatListPatGroup: (state, patRecords) => {
      const margedPatList = deduplicateObjectsGroup(
        // modify start #9578
        [...state.unselectedPatList, ...patRecords],
        // modify end #9578
        "pat_id"
      );
      state.searchedPatListPatGroup = margedPatList;
    },
    // 患者詳細検索の検索結果がサイドコンテンツにのみ反映される  5836  shan  end

    /**
     * @description 患者検索結果ストア格納
     * @param {Array} searchedPatList 患者検索結果
     */
    setSearchedPatList: (state, searchedPatList) => {
      state.searchedPatList = searchedPatList;
    },

    /**
     * @description 患者共有検索結果ストア格納
     * @param {Array} searchedShrPatList 患者共有検索結果
     */
    setSearchedShrPatList: (state, searchedShrPatList) => {
      state.searchedShrPatList = searchedShrPatList;
    },

    /**
     * @description 患者検索結果ストア格納
     * @param {Array} patRecords 患者検索結果
     */
    updateSearchedPatList: (state, patRecords) => {
      state.searchedPatList = patRecords;
    },

    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    /**
     * @description 患者検索結果ストア格納
     * @param {Array} patRecords 患者検索結果
     */
    updateUnSelectedPatList: (state, patRecords) => {
      state.unselectedPatList = patRecords;
    },
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end

    /**
     * @description 患者検索結果ストア格納
     * @param {Array} patRecords 患者検索結果
     */
    updateTreatmentPatList: (state, patRecords) => {
      state.treatmentPatList = patRecords;
    },

    /**
     * @description 遷移元機能名を格納
     * @param {String}
     */
    setSrcFuncName: (state, s) => {
      state.srcFuncName = s;
    },

    /**
     * @description 患者情報画面ページ表示中フラグ切り替え
     */
    toggleIsPatInfoPageShowing: (state) => {
      state.isPatInfoPageShowing = !state.isPatInfoPageShowing;
    },

    /**
     * @description スワイプ可能フラグ変更
     * @param {Boolean}
     */
    setIsHeaderSwipeDisabled: (state, b) => {
      state.isHeaderSwipeDisabled = b;
    },

    setIsPatInfoPageShowing: (state, b) => {
      state.isPatInfoPageShowing = b;
    },

    setIsLoadingPat: (state, b) => {
      state.isLoadingPat = b;
    },

    /**
     * @description カード一覧表示フラグ切り替え
     * @param {Boolean}
     */
    setIsPatInfoVisible: (state, b) => {
      state.isPatInfoVisible = b;
    },

    /**
     * @description 指示者リスト格納
     * @param {Array}
     */
    setIndUserList: (state, list) => {
      state.indUserList = list;
    },

    /**
     * @description 指示者の利用者IDを格納
     * @param {String}
     */
    setIndUserId: (state, s) => {
      state.indUserId = s;
    },

    /**
     * @description 指示者設定フラグを格納
     * @param {Boolean}
     */
    setIsIndUserSetting: (state, b) => {
      state.isIndUserSetting = b;
    },

    /**
     * @description 身体情報を格納
     * @param {Object}
     */
    setSelectedPhysicalInfoData: (state, o) => {
      state.selectedPhysicalInfoData = o;
    },

    /**
     * @description 在宅透析患者フラグを格納
     * @param {Boolean}
     */
    setIsHomeDialysisPat: (state, b) => {
      state.isHomeDialysisPat = b;
    },

    setAdvancedSettings: (state, rec) => {
      state.advancedSettings = rec;
    },
    /**
     * @description ？？？？患者フラグを格納
     * @param {Boolean}
     */
    setIsNullPat: (state, b) => {
      state.isNullPat = b;
    },
    setIsNullShrPat: (state, b) => {
      state.isNullShrPat = b;
    },

    setPatAdditionInfo(state, payload) {
      state.patAdditionInfo = payload;
    },

    setMstAddition(state, payload) {
      state.mstAddition = payload;
    },

    setOtherFacilityInfo(state, payload) {
      state.isOtherFacility = payload.isOtherFacility
      state.otherFacilityCd = payload.otherFacilityCd
    },

    addPatSearchDetail(state, newItem) {
      state.patSearchDetails.push(newItem);
    },

    updatePatSearchDetail(state, updateItem) {
      state.patSearchDetails.forEach((detail, index) => {
        if (detail.queryId === updateItem.queryId) {
          state.patSearchDetails[index] = updateItem;
        }
      });
    },

    deletePatSearchDetail(state, itemId) {
      state.patSearchDetails.forEach((detail, index) => {
        if (detail.queryId === itemId) {
          state.patSearchDetails.splice(index, 1);
        }
      });
    },

    setPatSearchDetails(state, list) {
      state.patSearchDetails = list;
    },

    /**
     * 治療進捗状況更新
     * @param {*} state
     * @param {*} info
     */
    setAcceptanceStatusInfo(state, info) {
      if (state.selectedPat != null && state.selectedPat.pat_main != null) {
        state.selectedPat.pat_main.acceptance_status_info =
          JSON.stringify(info);
      }
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
    setReportStartDate(state, reportStartDate) {
      state.reportStartDate = reportStartDate;
    },
    /*add FNSI-改修内容転入転出の患者情報連動 任 end*/

    /*add FNSI-患者情報共有よりの改修 江 start*/
    setMstFacility(state, mstFacility) {
      state.mstFacility = mstFacility;
    },
    setIsOwnFacility(state, isOwnFacility) {
      state.isOwnFacility = isOwnFacility;
    },
    // add FNSI-修復施設切換Bug 関 start
    setSelectedFacilityCd(state, selectedFacilityCd) {
      state.selectedFacilityCd = selectedFacilityCd;
    },
    // add FNSI-修復施設切換Bug 関 end
    setIsNewPatPage(state, isNewPatPage) {
      state.isNewPatPage = isNewPatPage;
    },
    setDefaultSelectedPatId(state, defaultSelectedPatId) {
      state.defaultSelectedPatId = defaultSelectedPatId;
    },
    /*add FNSI-患者情報共有よりの改修 江 end*/
    setPatSearchType: (state, type) => {
      state.patSearchType = type;
    },

    setIsPatInfoChaned: (state, isPatInfoChaned) => {
      state.isPatInfoChaned = isPatInfoChaned;
    },
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    setSortPatInfo: (state, sortPatInfo) => {
      state.sortPatInfo = sortPatInfo;
    },
    setSearchedPatInfo: (state, searchedPatInfo) => {
      state.searchedPatInfo = searchedPatInfo;
    },
    // add 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 start
    setPatSearchedTreatDate: (state, patSearchedTreatDate) => {
      state.patSearchedTreatDate = patSearchedTreatDate;
    },
    // add 9231 透析困難マスタを追加しても、登録済み患者の患者情報に表示されない。 関 end
    setEditedComponent: (state, editedComponent) => {
      !state.editedComponentArr.includes(editedComponent) &&
        state.editedComponentArr.push(editedComponent);
    },
    removeEditedComponent: (state, editedComponent) => {
      state.editedComponentArr = state.editedComponentArr.filter(
        (component) => component !== editedComponent
      );
    },
    resetEditedComponent: (state) => {
      state.editedComponentArr = [];
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    setSearchedDetailedCondtion: (state, data) => {
      state.searchedDetailedCondtion = data;
    },
    // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
    setStartRenderPatInfoContent: (state, data) => {
      state.startRenderPatInfoContent = data;
    },
    setPhysicalInfoUpDate: (state, data) => {
      state.physicalInfoUpDate = data;
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
    // 患者情報・新規患者登録のデフォルト設定の取得済みフラグの設定
    setCardShowingDefaultSettingLoaded: (state, data) => {
      state.cardShowing[data.cardListName].defaultSettingLoaded = data.defaultSettingLoaded;
    },
    // 患者情報・新規患者登録毎のカード開閉状態(開:true, 閉: false)の設定
    setCardShowingCondition: (state, data) => {
      state.cardShowing[data.cardListName].condition = data.cardShowingCondition;
    },
    // 患者情報・新規患者登録毎の患者情報カード一覧のスクロール位置の設定
    setCardListScrollPos: (state, data) => {
      state.cardListScrollPos[data.cardListName] = data.scrollPos;
    },
    // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    // 機能別患者リストグリッド列
    setPatListGridColumn(state, column) {
      state.patListGridColumn = column;
    },
    // グリッド列幅設定
    setGridColumnWidth(state, params) {
      for (let index = 0; index < state.patListGridColumn.length; index++) {
        if (state.patListGridColumn[index].field === params.field) {
          state.patListGridColumn[index].width[params.selectedFontSize] = params.width;
        }
      }
    },
  },
};

/**
 * 患者リストの再検索処理
 */
async function searchPatList(getters) {
  // 患者リストを再検索する
  const uriPersonalMain = "/patInfo/getPatPersonalMainByList";
  const searchedPatIdList = deepCopy(getters.searchedPatList).map(pat => pat.pat_id)

  // 検索中の患者リストが空の場合、検索を行わず今の患者リストをそのまま返す
  if (searchedPatIdList.length <= 0) {
    return getters.searchedPatList;
  }

  const resPersonalMain = await ApiHelper.post(uriPersonalMain, searchedPatIdList).catch(() => {
    throw new Error("[SearchPatSimple.vue]searchPat(): 検索失敗");
  });

  // 必要な情報のみ取り出す
  return resPersonalMain.data.map(pat => {
    return {
      pat_id: pat.pat_id,
      hosp_pat_id: pat.hosp_pat_id,
      pat_sex: pat.pat_sex,
      pat_last_name: pat.pat_last_name,
      pat_first_name: pat.pat_first_name,
      is_same: pat.is_same,
      /*add FNSI-検査結果内結バグの改修 江 start*/
      pat_first_name_kana: pat.pat_first_name_kana,
      pat_last_name_kana: pat.pat_last_name_kana,
      in_out_class: pat.in_out_class
      /*add FNSI-検査結果内結バグの改修 江 end*/
    }
  })
}
/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
async function getWithLoader(url, params) {
  store.dispatch("loading-screen/setLoadingScreenMessage", "処理中・・・");
  store.dispatch("loading-screen/setLoadingScreenVisible", true);
  return await ApiHelper.get(url, params).finally(() =>
    store.dispatch("loading-screen/setLoadingScreenVisible", false)
  );
}
/**
 * 共通ローダを実行するPOSTリクエスト
 * @param {String} url URL
 * @param {any} params パラメータ
 */
async function postWithLoader(url, params) {
  return await ApiHelper.post(url, params);
}
