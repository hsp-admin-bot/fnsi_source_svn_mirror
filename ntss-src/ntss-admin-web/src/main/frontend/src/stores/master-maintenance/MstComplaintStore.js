/**
 * マスタ編集（愁訴処置マスタ）ストア
 */
import {
  sendRequestGetMstComplaint,
  sendRequestUpdateMstComplaint,
  sendRequestGetMstCompTreatment,
  sendRequestUpdateMstCompTreatment,
  sendRequestGetMstComplaintByFacilityCd
} from "@/apis/treatment-record";
import {
  sendRequestMstDeviceEdgeNoByFacilityCd,
  sendRequestMstComplaintSync
} from "@/apis/device-edge-order";
// add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
import { MstComplaint } from "@/models/master-maintenance/mst-complaint/MstComplaint";
import { MstCompTreatment } from "@/models/master-maintenance/mst-complaint/MstCompTreatment";
// add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end

import Vue from "vue";

export default {
  strict: true,
  namespaced: true,
  state: {
    dataSource: {
      length: 0,
      mstComplaints: [],
      mstCompTreatments: []
    },
    condition: {
      freeWord: "",
      includeDeleted: false
    },
    /**
     * 愁訴マスタ編集モデル（モーダル用）
     */
    complaintModal: null,
    /**
     * 処置マスタ編集モデル（モーダル用）
     */
    compTreatmentModal: null,
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
    notDelLenght: 0,
    changeFlg: false,
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
  },
  mutations: {
    /**
     * DataSourceに愁訴マスタを設定する.
     * @param {*} state stateオブジェクト
     * @param {*} list 愁訴マスタ
     */
    setMstComplaints(state, list) {
      state.dataSource.mstComplaints = list;
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
    setNotDelLenght(state, notDelLenght) {
      state.notDelLenght = notDelLenght;
    },
    getNotDelLenght(state) {
      return state.notDelLenght;
    },
    setChangeFlg(state, changeFlg) {
      state.changeFlg = changeFlg;
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    /**
     * DataSourceに処置マスタを設定する.
     * @param {*} state stateオブジェクト
     * @param {*} list 処置マスタ
     */
    setMstCompTreatments(state, list) {
      state.dataSource.mstCompTreatments = list;
    },
    /**
     * 愁訴マスタに行を追加する.
     * @param {*} state stateオブジェクト
     * @param {*} record 追加行
     */
    addMstComplaint(state, record) {
      state.dataSource.mstComplaints.push(record);
    },
    /**
     * 処置マスタに行を追加する.
     * @param {*} state stateオブジェクト
     * @param {*} record 追加行
     */
    addMstCompTreatment(state, record) {
      state.dataSource.mstCompTreatments.push(record);
    },
    /**
     * DataSourceのサイズを設定する.
     * @param {*} state stateオブジェクト
     */
    setDataSourceSize(state) {
      state.dataSource.length =
      state.dataSource.mstComplaints.length >
      state.dataSource.mstCompTreatments.length
          ? state.dataSource.mstComplaints.length
          : state.dataSource.mstCompTreatments.length;
    },
    /**
     * 検索条件を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} condition 検索条件
     */
    setCondition(state, condition) {
      state.condition = condition;
    },
    /**
     * 愁訴マスタ編集で必要な情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} model 愁訴マスタ（モーダル用）
     */
    setMstComplaintEdit(state, model) {
      state.complaintModal = model;
    },
    /**
     * 処置マスタ編集で必要な情報を設定する.
     * @param {*} state stateオブジェクト
     * @param {*} model 処置マスタ（モーダル用）
     */
    setMstCompTreatmentEdit(state, model) {
      state.compTreatmentModal = model;
    },
    /**
     * 並び替えをします.
     * @param {*} state stateオブジェクト
     */
    sort(state) {
      const compare = (a, b) =>
        a.sortRankFirst - b.sortRankFirst || a.sortRankSecond - b.sortRankSecond;
      //グリッドデータの並び替え
      state.dataSource.mstComplaints.sort(compare);
      state.dataSource.mstCompTreatments.sort(compare);
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。【マニュアル検証指摘】 張玲 start
      // 並び順を採番しなおす
      for (let i = 0; i < state.dataSource.mstComplaints.length; i++) {
        if (state.dataSource.mstComplaints[i].isDisp === '1') {
          state.dataSource.mstComplaints[i].sortRankFirst = i + 1;
        }
      }
      for (let i = 0; i < state.dataSource.mstCompTreatments.length; i++) {
        if (state.dataSource.mstCompTreatments[i].isDisp === '1') {
          state.dataSource.mstCompTreatments[i].sortRankFirst = i + 1;
        }
      }
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。【マニュアル検証指摘】 張玲 end
    },
    /**
     * DataSoruceの愁訴マスタを更新します.
     * @param {*} state stateオブジェクト
     * @param {*} model 編集行
     */
    editMstComplaint(state, model) {
      // const editRecord = editInfo.editRecord;
      // const isSortMode = editInfo.isSortMode;
      if (!model) return
      // 該当レコードがあれば内容を更新
      const foundData = state.dataSource.mstComplaints.find(e => {
        return e.code === model.code;
      })
      const index = state.dataSource.mstComplaints.indexOf(foundData);
      if (index >=0 && model.code > 0 && model.initData.is_disp == '0') model.up_date = null;
      Vue.set(state.dataSource.mstComplaints, index, model);
    },
    /**
     * DataSoruceの処置
     * マスタを更新します.
     * @param {*} state stateオブジェクト
     * @param {*} model 編集行
     */
    editMstCompTreatment(state, model) {
      // 該当レコードがあれば内容を更新
      if (!model) return
      const foundData = state.dataSource.mstCompTreatments.find(e => {
        return e.code === model.code;
      })
      const index = state.dataSource.mstCompTreatments.indexOf(foundData);
      if (index >=0 && model.code > 0 && model.initData.is_disp == '0') model.up_date = null;
      Vue.set(state.dataSource.mstCompTreatments, index, model);
    },
  },
  actions: {
    /**
     * 愁訴マスタ取得.
     * @param {*} commit commitオブジェクト
     */
    /* eslint-disable no-unused-vars */
    getMstComplaint({ commit }) {
      // マスタ取得前に古いデータを消す
      commit("setMstComplaints", []);
      commit("setDataSourceSize");
      return sendRequestGetMstComplaint();
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
    setNotDelLenght({ commit }, notDelLenght) {
      commit("setNotDelLenght", notDelLenght);
    },
    setChangeFlg({ commit }, changeFlg) {
      commit("setChangeFlg", changeFlg);
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    /**
     * 愁訴マスタ取得.
     * @param {*} commit commitオブジェクト
     */
    /* eslint-disable no-unused-vars */
    getMstComplaintByFacilityCd({ commit }, facilityCd) {
      // マスタ取得前に古いデータを消す
      commit("setMstComplaints", []);
      commit("setDataSourceSize");
      return sendRequestGetMstComplaintByFacilityCd(facilityCd);
    },
    /**
     * 愁訴マスタ更新.
     * @param {*} commit commitオブジェクト
     * @param {*} payload 愁訴マスタ
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateMstComplaint({ commit }, payload) {
      return sendRequestUpdateMstComplaint(payload);
    },
    /**
     * DataSourceに愁訴マスタを設定する.
     * @param {*} commit commitオブジェクト
     * @param {*} list 愁訴マスタ
     */
    setMstComplaints({ commit }, list) {
      commit("setMstComplaints", list);
      commit("setDataSourceSize");
    },
    /**
     * DataSourceに処置マスタを設定する.
     * @param {*} commit commitオブジェクト
     * @param {*} list 処置マスタ
     */
    setMstCompTreatments({ commit }, list) {
      commit("setMstCompTreatments", list);
      commit("setDataSourceSize");
    },
    /**
     * DataSourceに愁訴マスタを追加する.
     * @param {*} commit commitオブジェクト
     * @param {*} model 愁訴マスタ
     */
    addMstComplaint({ commit }, model) {
      commit("addMstComplaint", model);
      commit("setDataSourceSize");
    },
    /**
     * DataSourceに処置マスタを追加する.
     * @param {*} commit commitオブジェクト
     * @param {*} model 処置マスタ
     */
    addMstCompTreatment({ commit }, model) {
      commit("addMstCompTreatment", model);
      commit("setDataSourceSize");
    },
    /**
     * 愁訴マスタ編集で必要な情報を設定する.
     * @param {*} commit commitオブジェクト
     * @param {*} model 愁訴マスタ（モーダル用）
     */
    setMstComplaintEdit({ commit }, model) {
      commit("setMstComplaintEdit", model);
      commit("editMstComplaint", model);
    },
    /**
     * 処置マスタ取得.
     * @param {*} commit commitオブジェクト
     */
    /* eslint-disable no-unused-vars */
    getMstCompTreatment({ commit }) {
      // マスタ取得前に古いデータを消す
      commit("setMstCompTreatments", []);
      commit("setDataSourceSize");
      return sendRequestGetMstCompTreatment();
    },
    /**
     * 処置マスタ更新.
     * @param {*} commit commitオブジェクト
     * @param {*} payload 処置マスタ
     */
    // TODO: 局所的なeslintの設定を削除する
    /* eslint-disable no-unused-vars */
    updateMstCompTreatment({ commit }, payload) {
      return sendRequestUpdateMstCompTreatment(payload);
    },
    /**
     * 検索条件を設定する.
     * @param {*} commit commitオブジェクト
     * @param {*} condition 検索条件
     */
    setCondition({ commit }, condition) {
      commit("setCondition", condition);
    },
    /* 処置マスタ編集で必要な情報を設定する.
     * @param {*} commit commitオブジェクト
     * @param {*} model 処置マスタ（モーダル用）
     */
    setMstCompTreatmentEdit({ commit }, model) {
      commit("setMstCompTreatmentEdit", model);
      commit("editMstCompTreatment", model);
    },
    /**
     * 並び替えをします.
     * @param {*} commit commitオブジェクト
     */
    sort({ commit }) {
      commit("sort");
    },
    /**
     * DataSoruceの愁訴マスタを更新します.
     * @param {*} commit commitオブジェクト
     * @param {*} model 編集行
     */
    editMstComplaint({ commit }, model) {
      commit("editMstComplaint", model);
    },
    /**
     * DataSoruceの処置マスタを更新します.
     * @param {*} commit commitオブジェクト
     * @param {*} model 編集行
     */
    editMstCompTreatment({ commit }, model) {
      commit("editMstCompTreatment", model);
    },
    getDeviceEdgeNoListByFacilityCd(tmp, facilityCd) {
      return sendRequestMstDeviceEdgeNoByFacilityCd(facilityCd);
    },
    mstSyncDeviceEdge(context, param) {
      return sendRequestMstComplaintSync({
        facilityCd: param.facilityCd,
        deviceEdgeNo: param.deviceEdgeNo
      });
    }
  },
  getters: {
    /**
     * 愁訴マスタを全件返します.
     * @param {*} state
     */
    getAllMstComplaints(state) {
      return state.dataSource.mstComplaints;
    },
    /**
     * 処置マスタを全件返します.
     * @param {*} state
     */
    getAllMstCompTreatments(state) {
      return state.dataSource.mstCompTreatments;
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
    getNotDelLenght(state) {
      return state.notDelLenght;
    },
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    /**
     * 愁訴マスタ編集モデル（モーダル用）を取得する.
     * @param {*} state stateオブジェクト
     */
    getFilteredDataSource(state) {
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      const getMaxCompTreatment = (mstCompTreatmentsLst, num)=>{
        for (let i = 0; i < num; i++) {
          const mstCompTreat = {
            comp_treatment_cd : 0,
            treatment : null,
            treat_class : null,
            treat_medicine_cd : null,
            amount : 0,
            procedure_cd : null,
            take_medicine_cd : null,
            is_disp : "1",
            reg_date : new Date(),
            up_date : new Date(),
            in_hosp_astartdate : new Date(),
            in_hosp_bstartdate : new Date(),
            in_hospital_cd_a1 : null,
            in_hospital_cd_a2 : null,
            in_hospital_cd_a3 : null,
            in_hospital_cd_a4 : null,
            in_hospital_cd_b1 : null,
            in_hospital_cd_b2 : null,
            in_hospital_cd_b3 : null,
            in_hospital_cd_b4 : null
          };
          let emptyRow = new MstCompTreatment(mstCompTreat);
          mstCompTreatmentsLst.push(emptyRow);
        }
        return mstCompTreatmentsLst;
      };
      const getMaxMstComplaint = (mstComplaintsLst,num) => {
        for (let i = 0;i<num; i++) {
          const complaint = {
            complaint_cd: 0,
            complaint_name: "",
            is_disp: "1",
            reg_date: new Date(),
            up_date: new Date(),
            in_hospital_cd_1: null,
            in_hospital_cd_2: null
          };
          const emptyRow =  new MstComplaint(complaint, null, null);
          mstComplaintsLst.push(emptyRow);
        }
      };
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
      if(!state.condition.freeWord && state.condition.includeDeleted) {
        // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
        if (state.changeFlg) {
          return state.dataSource;
        }
        state.changeFlg = true;
        // code値 0: データなし行、0より大きい: DB登録済データ行、0より小さい: 新規追加行
        let mstComplaintsLst = state.dataSource.mstComplaints.filter(e => e.code != 0 && (e.initData == null || e.initData.is_disp == "1"));        // 愁訴 有効データ取得（DB登録済データ、新規追加）
        let mstComplaintsDel = state.dataSource.mstComplaints.filter(e => e.initData != null && e.initData.is_disp == "0");                         // 愁訴 削除済データ取得
        let mstCompTreatmentsLst = state.dataSource.mstCompTreatments.filter(e => e.code != 0 && (e.initData == null || e.initData.is_disp == "1"));// 処置 有効データ取得（DB登録済データ、新規追加）
        let mstCompTreatmentsDel = state.dataSource.mstCompTreatments.filter(e => e.initData != null && e.initData.is_disp == "0");                 // 処置 削除済データ取得
        let mstComplaintsNotDel = mstComplaintsLst.length;          // 愁訴 有効データ行数
        let mstCompTreatmentsNotDel = mstCompTreatmentsLst.length;  // 処置 有効データ行数

        state.notDelLenght = mstComplaintsNotDel > mstCompTreatmentsNotDel ? mstComplaintsNotDel : mstCompTreatmentsNotDel;
        if(mstComplaintsNotDel <= mstCompTreatmentsNotDel) {
          // 最大未削除集合はちょうど最後のグループを満たしています。ただ、空の行を満たして最大集合に合わせるだけです。
          const num = mstCompTreatmentsNotDel - mstComplaintsNotDel;
          getMaxMstComplaint(mstComplaintsLst, num);
        } else {
          const num = mstComplaintsNotDel - mstCompTreatmentsNotDel;
          getMaxCompTreatment(mstCompTreatmentsLst, num);

        }
        for(let i = 0; i < mstComplaintsDel.length; i++){
          let item = mstComplaintsDel[i];
          mstComplaintsLst.push(item);
        }
        for(let i = 0; i < mstCompTreatmentsDel.length; i++){
          let item = mstCompTreatmentsDel[i];
          mstCompTreatmentsLst.push(item);
        }
        state.dataSource.mstComplaints = mstComplaintsLst;
        state.dataSource.mstCompTreatments = mstCompTreatmentsLst;
        state.dataSource.length = mstComplaintsLst.length > mstCompTreatmentsLst.length ?
          mstComplaintsLst.length : mstCompTreatmentsLst.length;
        // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
        return state.dataSource;
      }
      if(state.dataSource.length === 0) {
        return state.dataSource;
      }

      let mstComplaints = state.dataSource.mstComplaints;
      let mstCompTreatments = state.dataSource.mstCompTreatments;
      if(state.condition.freeWord) {
        // フリーワードでフィルタ後、有効データの下に削除済みデータを表示
        mstComplaints = mstComplaints.filter(e => e.name && e.name.indexOf(state.condition.freeWord) >= 0);
        let mstComplaintsLst = mstComplaints.filter(e => e.initData == null || e.initData.is_disp == "1");  // 愁訴 有効データ取得（DB登録済データ、新規追加）
        let mstComplaintsDel = mstComplaints.filter(e => e.initData != null && e.initData.is_disp == "0");  // 愁訴 削除済データ取得
        mstComplaintsLst.push(...mstComplaintsDel);
        mstComplaints = mstComplaintsLst;
        
        mstCompTreatments = mstCompTreatments.filter(e =>
          e.treatment && e.treatment.indexOf(state.condition.freeWord) >= 0 ||
          e.treatMedicine && e.treatMedicine.name && e.treatMedicine.name.includes(state.condition.freeWord) ||
          e.procedure && e.procedure.name && e.procedure.name.includes(state.condition.freeWord) ||
          e.amount && String(e.amount).includes(state.condition.freeWord) ||
          e.treatMedicine && e.treatMedicine.unit && e.treatMedicine.unit.includes(state.condition.freeWord)
        );
        let mstCompTreatmentsLst = mstCompTreatments.filter(e => e.initData == null || e.initData.is_disp == "1");  // 処置 有効データ取得（DB登録済データ、新規追加）
        let mstCompTreatmentsDel = mstCompTreatments.filter(e => e.initData != null && e.initData.is_disp == "0");  // 処置 削除済データ取得
        mstCompTreatmentsLst.push(...mstCompTreatmentsDel);
        mstCompTreatments = mstCompTreatmentsLst;
      }
      if(!state.condition.includeDeleted){
        // 抽出条件の「削除を表示する」が未チェックの場合はMstComplaintMainComponent側で愁訴, 処置のデータなし行の表示／非表示の調整がされる
        mstComplaints = mstComplaints.filter(e => e.code != 0 && (e.initData == null || e.initData.is_disp == "1"));           // 愁訴 有効データ取得（DB登録済データ※未削除、新規追加）
        mstCompTreatments = mstCompTreatments.filter(e => e.code != 0 && (e.initData == null || e.initData.is_disp == "1"));   // 処置 有効データ取得（DB登録済データ※未削除、新規追加）
      }
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      state.notDelLenght = mstComplaints.length >
                            mstCompTreatments.length
                                ? mstComplaints.length
                                : mstCompTreatments.length;
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
      return {
        length: mstComplaints.length >
          mstCompTreatments.length
              ? mstComplaints.length
              : mstCompTreatments.length,
        mstComplaints: mstComplaints,
        mstCompTreatments: mstCompTreatments
      }
    },
    /**
     * 愁訴マスタ編集モデル（モーダル用）を取得する.
     * @param {*} state stateオブジェクト
     */
    getMstComplaintEdit(state) {
      return state.complaintModal;
    },
    /**
     * 処置マスタ編集モデル（モーダル用）を取得する.
     * @param {*} state stateオブジェクト
     */
    getMstCompTreatmentEdit(state) {
      return state.compTreatmentModal;
    },
    /**
     * 編集されたかどうか.
     * @param {*} state stateオブジェクト
     */
    isChanged(state) {
      if (state.dataSource.mstComplaints.some(e => e.isEditedAtThisTime() || e.isSortedOrChangeDisp())) return true;
      return state.dataSource.mstCompTreatments.some(e => e.isEditedAtThisTime() || e.isSortedOrChangeDisp());
    }
  }
};
