import {
  sendRequestGetMstChecklist,
  sendRequestUpdateMstChecklist
} from "@/apis/mst-checklist";
import { deepCopy } from "@/functions/common/CommonFunctions";
import {
  sendRequestMstDeviceEdgeNoByFacilityCd,
  sendRequestMstDeviceEdgeNo,
  sendRequestMstChecklistSync
} from "@/apis/device-edge-order";
// ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
import {sendRequestGetAllMedicineClassIncludeDeleted } from "@/apis/pat-prescription";
// ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
// ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s START
// ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
// ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 START
import { sendRequestDeleteOrdChecklist } from "@/apis/check-list";
// ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 END
import { sendRequestGetMstEquipmentClassIncludeDeleted } from "@/apis/treatment-record";
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
// FNSI-修正 マスタ削除の対応 楊 add end

// ******************************************
// function
// ******************************************
// 透析工程コードに一致する透析工程名を返す
function getProgName(list, code) {
  for (let elm of list) {
    if (elm.dialysisProgCd === code) {
      return elm.dialysisProgName;
    }
  }
  return "";
}

function getListName(list, code) {
  for (let elm of list) {
    if (elm.class_cd === code) {
      return elm.list_name;
    }
  }
  return "";
}

// リストコードの一致するデータを返す
function getOldSetting(oldSetting, listCd) {
  for (let setting of oldSetting) {
    if (setting.list_cd == listCd) {
      return setting;
    }
  }
  return null;
}

// noの一致するデータを返す
function getOldItem(oldSetting, no) {
  for (let setting of oldSetting) {
    if (setting.no == no) {
      return setting;
    }
  }
  return null;
}
// add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
function difference(a, b) {
  return a.filter(x => !b.some(y => x.class_cd == y.class_cd
    && x.disp_no == y.disp_no
    && x.func_class == y.func_class
    && x.list_name == y.list_name))
}

function mergeList(a, b) {
  return [...a.filter(x => !b.some(y => x.list_cd == y.list_cd && x.disp_no == y.disp_no)), ...b];
}
// add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
export default {
  namespaced: true,
  state: {
    // -----------------------------------------
    // チェックリストマスタ編集画面用
    // -----------------------------------------
    // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
    editList: [],
    // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
    // チェックリスト編集内容のインデックス
    selectEditIndex: 0,
    selectEditSetting: null,
    // 編集前の選択中設定内容 (変更箇所表示用)
    old_selectEditSetting: null,
    // 編集前のチェックリスト設定内容 (変更箇所表示用)
    old_checklistSetting: null,
    // チェックリスト設定
    checklistSetting: [],
    // チェックリスト設定グリッド表示用
    mstCheckListColumn: [
      {
        field: "dummy_disp_no",
        title: " ",
        width: "10px",
        locked: true,
        editable: () => false
      },
      {
        field: "disp_no",
        title: "並び順",
        width: "8em",
        locked: false,
        editable: () => true,
        hidden: true,
        // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
        // template:
        //   "<v-ons-input type='number' min='0' v-model.number='#:disp_no#'>#:disp_no#</v-ons-input>"
        format: "{0:n0}",
        values: null,
        // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
      },
      // DEL チェックリストマスタ 「工程名」の列名を「工程」に修正。(詳細画面と文言統一) 孔s start
      // {
      //   field: "dialysis_prog_name",
      //   title: "工程名",
      //   width: "8em",
      //   editable: () => false
      // },
      // {
      //   field: "list_name",
      //   title: "リスト名",
      //   width: "40em",
      //   editable: () => false
      // },
      // DEL チェックリストマスタ 「工程名」の列名を「工程」に修正。(詳細画面と文言統一) 孔s end
      //ADD チェックリストマスタ 1.「工程名」の列名を「工程」に修正。(詳細画面と文言統一)2.工程、リスト名を一覧で修正可能とする 孔s START
      {
        field: "dialysis_prog_name",
        title: "工程名",
        width: "8em",
        editable: () => false,
        hidden: true
      },
      {
        field: "dialysis_prog_cd",
        title: "工程",
        width: "12em",
        editable: () => true,
        values:[
          { value: 0, text: "透析開始前"},
          { value: 1, text: "透析中" },
          { value: 2, text: "透析終了後" },
          { value: 3, text: "未使用" }
        ]
      },
      {
        field: "list_name",
        title: "リスト名",
        width: "40em",
        editable: () => true
      },
      //ADD チェックリストマスタ 1.「工程名」の列名を「工程」に修正。(詳細画面と文言統一)2.工程、リスト名を一覧で修正可能とする END
      //ADD チェックリストマスタ 詳細列を追加してそこからモーダルを起動する START
      {
        field: "check_btn",
        title: "詳細",
        width: "8em",
        editable: () => false
      }
      //ADD チェックリストマスタ 詳細列を追加してそこからモーダルを起動する 孔s END
    ],
    // 治療条件 コンボボックス用データ
    condList: [
      { func_class: 1, class_cd: 5, list_name: "ダイアライザ・吸着カラム・1次膜・2次膜" },
      { func_class: 1, class_cd: 9, list_name: "穿刺針" },
      { func_class: 1, class_cd: 13, list_name: "血液回路" },
      { func_class: 1, class_cd: 15, list_name: "透析液" },
      { func_class: 1, class_cd: 19, list_name: "補液" },
      { func_class: 1, class_cd: 25, list_name: "抗凝固剤" }
    ],
    // 医療材料分類マスタ
    mstEquipClassList: null,
    // 透析工程リスト
    mstDialysisProgressList: [
      { dialysisProgCd: 0, dialysisProgName: "透析開始前" },
      { dialysisProgCd: 1, dialysisProgName: "透析中" },
      { dialysisProgCd: 2, dialysisProgName: "透析終了後" },
      { dialysisProgCd: 3, dialysisProgName: "未使用" }
    ],
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    mstMedicineClassList: null,
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
    // 変更フラグ
    changeFlg: false,
    schema: {
      disp_no: { type: "number", validation: { min: 0 } },
      dummy_disp_no: { type: "number" },
      dialysis_prog_name: { type: "text" },
      list_name: { type: "text" }
    }
  },
  getters: {
    // チェックリストマスタ設定
    getChecklistSetting(state) {
      return state.checklistSetting.checklistSettings;
    },
    // チェックリスト設定グリッド項目
    getMstChecklistColumn(state) {
      return state.mstCheckListColumn;
    },
    // 治療条件項目一覧
    getCondList(state) {
      return state.condList;
    },
    // 医療材料分類マスタ一覧
    getMstEquipClassList(state) {
      return state.mstEquipClassList;
    },
    // 透析工程リスト
    getMstDialysisProgressList(state) {
      return state.mstDialysisProgressList;
    },
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    // 薬剤分類マスタ一覧
    getMstMedicineClassList(state) {
      return state.mstMedicineClassList;
    },
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
    // 編集中のチェックリストマスタ設定
    getSelectChecklistSetting(state) {
      return state.selectEditSetting;
    },
    // 変更フラグ
    getChangeFlg(state) {
      return state.changeFlg;
    },
    getSchema(state) {
      return state.schema;
    }
  },
  actions: {
    // -----------------------------------------
    // チェックリストマスタ画面用
    // -----------------------------------------
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    cleanCheckSettingList({ commit }){
      commit("setChecklistSetting", []);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    // チェックリストマスタ設定情報取得
    async fetchCheckSettingList({ commit }, facilityCd) {
      try {
        // 施設コードを指定してチェックリストマスタ設定情報を取得
        const response = await sendRequestGetMstChecklist({
          facilityCd: facilityCd
        });
        const dataList = response.data.copyWithin(0, 0);

        dataList.forEach((value, index, array) => {
          // JSONデータ変換
          // チェックリストマスタ項目
          array[index].checklistSettings = JSON.parse(
            array[index].checklistSettings
          );
        });

        // 取得した設定内容を保存
        let setting = dataList[0];

        // 表示順セット
        for (let i = 0; i < setting.checklistSettings.length; i++) {
          //del チェックリストマスタ 同一行程ごとに番号を振る。 孔s start
          // setting.checklistSettings[i].disp_no = i + 1;
          //del チェックリストマスタ 同一行程ごとに番号を振る。 end
          //add チェックリストマスタ 同一行程ごとに番号を振る。 start
          if(i==0){
            setting.checklistSettings[i].disp_no=1
          } else if (setting.checklistSettings[i].dialysis_prog_cd==setting.checklistSettings[i-1].dialysis_prog_cd){
            setting.checklistSettings[i].disp_no = setting.checklistSettings[i-1].disp_no+1;
          } else {
            setting.checklistSettings[i].disp_no=1
          }
          //add チェックリストマスタ 同一行程ごとに番号を振る。 孔s end
          setting.checklistSettings[i].chgflg = false;
          setting.checklistSettings[i].chgflg_listname = false;
          setting.checklistSettings[i].chgflg_progcd = false;
          setting.checklistSettings[i].chgflg_dispno = false;
          for (
            let j = 0;
            j < setting.checklistSettings[i].funclist.length;
            j++
          ) {
            setting.checklistSettings[i].funclist[j].no = j;
            setting.checklistSettings[i].funclist[j].disp_no = j + 1;
          }
        }

        commit("setOldChecklistSetting", setting);
        commit("setChecklistSetting", setting);
      } catch (e) {
        alert(e.message);
      }
    },
    // 医療材料分類マスタ一覧情報取得
    async fetchMstEquipClassList({ commit }, facilityCd) {
      try {
        // 施設コードを指定して医療材料分類マスタ一覧情報を取得
        const response = await sendRequestGetMstEquipmentClassIncludeDeleted({
          facilityCd: facilityCd
        });
        const dataList = response.data.copyWithin(0, 0);
        let settings = [];
        // ダイアライザ
        settings.push({
          funcflg: 2,
          class_cd: 0,
          list_name: "ダイアライザ",
          isDel: "0",
          isDisp:"1"
        });

        dataList.forEach((value, index, array) => {
          // 医療材料
          // コンボボックス用データ作成
          settings.push({
            funcflg: 2,
            class_cd: array[index].classCd,
            list_name: array[index].isDel === "1" || array[index].isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + array[index].className : array[index].className
          });
        });

        // #11589 2025.02.25 add 「未分類」を追加 TDC米沢 start
        // 未分類
        settings.push({
          funcflg: 2,
          class_cd: -1,
          list_name: "未分類",
          isDel: "0",
          isDisp:"1"
        });
        // #11589 2025.02.25 add 「未分類」を追加 TDC米沢 end

        // 取得した設定内容を保存
        commit("setMstEquipClassList", settings);
      } catch (e) {
        alert(e.message);
      }
    },
    // 工程情報セット
    setDialysisProgName({ state, commit }, code) {
      let setting = state.selectEditSetting;
      setting.dialysis_prog_cd = code;
      setting.dialysis_prog_name = getProgName(
        state.mstDialysisProgressList,
        code
      );
      // チェックリストマスタ設定情報登録
      commit("setSelectEditSetting", setting);
    },
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    // 薬剤分類マスタ一覧情報取得
    async fetchMstMedicineClassList({ commit }, facilityCd) {
      try {
        // 施設コードを指定して薬剤分類マスタ一覧情報を取得
        const response = await sendRequestGetAllMedicineClassIncludeDeleted(facilityCd);
        const dataList = response.data.copyWithin(0, 0);
        let settings = [];

        dataList.forEach((value, index, array) => {
          // 薬剤分類
          // コンボボックス用データ作成
          settings.push({
            funcflg: 3,
            class_cd: array[index].classCd,
            list_name: array[index].isDel === "1" || array[index].isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + array[index].className : array[index].className
          });
        });

        // #11589 2025.02.25 add 「未分類」を追加 TDC米沢 start
        // 未分類
        settings.push({
          funcflg: 3,
          class_cd: -1,
          list_name: "未分類",
          isDel: "0",
          isDisp:"1"
        });

        // #11589 2025.02.25 add 「未分類」を追加 TDC米沢 end
        // 取得した設定内容を保存
        commit("setMstMedicineClassList", settings);
      } catch (e) {
        alert(e.message);
      }
    },
    //add データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
    //add 工程、リスト名を一覧で修正可能とする 孔s start
    edit({ commit }, editInfo) {
      commit("edit", editInfo);
    },
    //add チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s end
    // 選択中のチェックリストマスタ設定情報登録
    setSelectEditSetting({ state, commit }, setting) {
      const old_setting = deepCopy(state.old_selectEditSetting);
      let now_setting = deepCopy(setting);
      // 変更チェック
      now_setting.chgflg_listname = false;
      now_setting.chgflg_progcd = false;
      if (old_setting.list_name != now_setting.list_name) {
        now_setting.chgflg_listname = true;
      }
      if (old_setting.dialysis_prog_cd != now_setting.dialysis_prog_cd) {
        now_setting.chgflg_progcd = true;
      }

      for (let i = 0; i < now_setting.funclist.length; i++) {
        const oldSetting = deepCopy(
          getOldItem(
            state.old_selectEditSetting.funclist,
            now_setting.funclist[i].no
          )
        );
        now_setting.funclist[i].chgflg_disp_no = false;
        now_setting.funclist[i].chgflg_func_class = false;
        now_setting.funclist[i].chgflg_list_name = false;
        now_setting.funclist[i].chgflg_class_cd = false;

        if (oldSetting.disp_no != now_setting.funclist[i].disp_no) {
          now_setting.funclist[i].chgflg_disp_no = true;
        }
        if (oldSetting.func_class != now_setting.funclist[i].func_class) {
          now_setting.funclist[i].chgflg_func_class = true;
        }
        if (oldSetting.list_name != now_setting.funclist[i].list_name) {
          now_setting.funclist[i].chgflg_list_name = true;
        }
        if (oldSetting.class_cd != now_setting.funclist[i].class_cd) {
          now_setting.funclist[i].chgflg_class_cd = true;
        }

        if (
          now_setting.funclist[i].chgflg_func_class === true ||
          now_setting.funclist[i].chgflg_class_cd === true ||
          (oldSetting.func_class === 0 &&
            now_setting.funclist[i].func_class === 0 &&
            now_setting.funclist[i].chgflg_list_name === true)
        ) {
          now_setting.funclist[i].chgflg = true;
        } else {
          now_setting.funclist[i].chgflg = false;
        }
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        if ((oldSetting.class_cd != null && oldSetting.class_cd != now_setting.funclist[i].class_cd) ||
        (oldSetting.func_class != null && oldSetting.func_class != now_setting.funclist[i].func_class ||
          (oldSetting.list_name != null && oldSetting.list_name != now_setting.funclist[i].list_name))) {

            now_setting.funclist[i].ord_checklist_change_flg = "1";
        }
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      }

      // チェックリストマスタ設定情報登録
      commit("setSelectEditSetting", now_setting);
    },

    // 新規登録フラグ
    setNewflg({ commit }, flg) {
      // 新規登録フラグ
      commit("setNewflg", flg);
    },
    // 変更フラグ
    setChangeFlg({ commit }, flg) {
      // 変更フラグ
      commit("setChangeFlg", flg);
    },

    // チェックリスト設定項目列セット
    setMstCheckListColumn({ commit }, columns) {
      // チェックリスト項目列セット
      commit("setMstCheckListColumn", columns);
    },

    // チェックリストマスタ編集モーダル表示時
    setEditChecklist({ state, commit }, index) {
      // チェックリスト編集内容のインデックス
      commit("setSelectEditIndex", index);
      // 編集前の内容セット
      let selOldSetting = deepCopy(
        getOldSetting(
          state.old_checklistSetting.checklistSettings,
          state.checklistSetting.checklistSettings[index].list_cd
        )
      );
      commit("setOldSelectEditSetting", selOldSetting);

      // チェックリスト表示内容作成
      let selSetting = deepCopy(
        state.checklistSetting.checklistSettings[index]
      );

      selSetting.chgflg_listname = false;
      selSetting.chgflg_progcd = false;
      if (selOldSetting.list_name != selSetting.list_name) {
        selSetting.chgflg_listname = true;
      }
      if (selOldSetting.dialysis_prog_cd != selSetting.dialysis_prog_cd) {
        selSetting.chgflg_progcd = true;
      }

      // 変更状態セット
      for (let i = 0; i < selSetting.funclist.length; i++) {
        // 変更フラグセット
        selSetting.funclist[i].chgflg = false;
        selSetting.funclist[i].chgflg_disp_no = false;
        selSetting.funclist[i].chgflg_func_class = false;
        selSetting.funclist[i].chgflg_list_name = false;
        selSetting.funclist[i].chgflg_class_cd = false;
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        selSetting.funclist[i].ord_checklist_change_flg = "0";
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

        // 変更前情報
        const selOldSetting_funclist = deepCopy(
          getOldItem(selOldSetting.funclist, selSetting.funclist[i].no)
        );

        if (selOldSetting_funclist.disp_no != selSetting.funclist[i].disp_no) {
          selSetting.funclist[i].chgflg_disp_no = true;
        }
        if (
          selOldSetting_funclist.func_class != selSetting.funclist[i].func_class
        ) {
          selSetting.funclist[i].chgflg_func_class = true;
        }
        // if (
        //   selOldSetting_funclist.list_name != selSetting.funclist[i].list_name
        // ) {
        //   selSetting.funclist[i].chgflg_list_name = true;
        // }
        if (
          selOldSetting_funclist.class_cd != selSetting.funclist[i].class_cd
        ) {
          selSetting.funclist[i].chgflg_class_cd = true;
        }
        if (
          selSetting.funclist[i].chgflg_func_class === true ||
          selSetting.funclist[i].chgflg_list_name === true ||
          selSetting.funclist[i].chgflg_class_cd === true
        ) {
          selSetting.funclist[i].chgflg = true;
        }
      }
      commit("setSelectEditSetting", selSetting);
    },

    // 表示順セット(マスタ一覧画面)
    mstChecklistSortData({ state, commit }, data) {
      // 現在の内容
      let nowSettings = deepCopy(state.checklistSetting);
      // 編集前の内容
      let oldSettings = deepCopy(state.old_checklistSetting);
      // 編集内容
      let editSetting = deepCopy(data);
      // 変更フラグ
      let isChange = state.changeFlg;

      // 変更チェック
      for (let i = 0; i < editSetting.length; i++) {
        nowSettings.checklistSettings[i].chgflg_dispno = false;
        // 変更直前のデータ
        let iNowSetting = getOldSetting(
          nowSettings.checklistSettings,
          editSetting[i].list_cd
        );
        // DBから取得したデータ
        let iOldSetting = getOldSetting(
          oldSettings.checklistSettings,
          editSetting[i].list_cd
        );
        if (iNowSetting.disp_no != editSetting[i].disp_no
          || iOldSetting.disp_no != editSetting[i].disp_no) {
          isChange = true;
          nowSettings.checklistSettings[i].disp_no = editSetting[i].disp_no;
          nowSettings.checklistSettings[i].chgflg_dispno = true;
        }
      }

      // 変更があった場合
      if (isChange == true) {
        // 並べ替え
        nowSettings.checklistSettings.sort(function(a, b) {
          if (a.dialysis_prog_cd < b.dialysis_prog_cd) return -1;
          if (a.dialysis_prog_cd > b.dialysis_prog_cd) return 1;
          // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng start
          // if (a.chgflg_progcd ) return 1;
          // if (b.chgflg_progcd ) return -1;
          // if (a.disp_no < b.disp_no) return -1;
          // if (a.disp_no > b.disp_no) return 1;
          if (a.disp_no <= b.disp_no) return -1;
          if (a.disp_no > b.disp_no) return 1;
          if (a.chgflg_progcd ) return 1;
          if (b.chgflg_progcd ) return -1;
          // #11001 並び順の変更後反映を押しても並び順が切り替わらない。 linjunfeng end
          return 0;
        });
        //DEL チェックリストマスタ 同一行程ごとに番号を振る。 孔s START
        // リストコード振り直し
        // for (let i = 0; i < editSetting.length; i++) {
        //   nowSettings.checklistSettings[i].list_cd = i + 1;
        // }
        //DEL チェックリストマスタ 同一行程ごとに番号を振る。 孔s END

        // add 並び順の反映後に番号の振り直しをする 孔s start
        for (let i = 0; i < nowSettings.checklistSettings.length; i++) {
          if(i==0){
            nowSettings.checklistSettings[i].disp_no=1
          } else if (nowSettings.checklistSettings[i].dialysis_prog_cd==nowSettings.checklistSettings[i-1].dialysis_prog_cd){
            nowSettings.checklistSettings[i].disp_no = nowSettings.checklistSettings[i-1].disp_no+1;
          } else {
            nowSettings.checklistSettings[i].disp_no=1
          }
        }
        for (let i = 0; i < editSetting.length; i++) {
          nowSettings.checklistSettings[i].chgflg_dispno = false;
          // 変更直前のデータ
          let iNowSetting = getOldSetting(
            nowSettings.checklistSettings,
            nowSettings.checklistSettings[i].list_cd
          );
          // DBから取得したデータ
          let iOldSetting = getOldSetting(
            oldSettings.checklistSettings,
            nowSettings.checklistSettings[i].list_cd
          );
          if (iNowSetting.disp_no != iOldSetting.disp_no) {
            nowSettings.checklistSettings[i].chgflg_dispno = true;
          }
        }
        // add 並び順の反映後に番号の振り直しをする 孔s end
        // データ保持
        commit("setChecklistSetting", nowSettings);
        // 変更フラグセット
        commit("setChangeFlg", isChange);
      }
    },

    // 表示順セット(編集画面)
    sortData({ state, commit }) {
      // 編集内容
      let editSetting = state.selectEditSetting;

      // 並べ替え
      editSetting.funclist.sort(function(a, b) {
        // add チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする。 孔s start
        if (a.func_class == null) return 1;
        if (b.func_class == null) return -1;
        // add チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする。 孔s end
        if (a.disp_no < b.disp_no) return -1;
        if (a.disp_no > b.disp_no) return 1;
        return 0;
      });
      // add チェックリスト設定画面の並び順変更を修正する。 孔s start
      for(let i = 0; i < editSetting.funclist.length; i++){
        editSetting.funclist[i].disp_no = i + 1;
      }
      // add チェックリスト設定画面の並び順変更を修正する。 孔s end

      commit("setSelectEditSetting", editSetting);
    },

    // 編集内容を登録
    regEditData({ state, commit, dispatch }) {
      // 変更フラグ
      let isChange = false;
      // 通常リストの空チェック
      let isError = false;
      // 編集内容セット
      let regSetting = deepCopy(state.old_selectEditSetting);
      let editSetting = deepCopy(state.selectEditSetting);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
      let editFunclist = deepCopy(editSetting.funclist);
      let regFunclist = deepCopy(regSetting.funclist);
      let list_cd = editSetting.list_cd;
      let differenceList = difference(editFunclist, regFunclist);
      if (differenceList.length > 0) {
        differenceList.forEach(x => x.list_cd = list_cd);
        let editList = deepCopy(state.editList);
        editList = mergeList(editList, differenceList);
        commit("setEditList", editList);
      }
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
      // 変更があった場合
      if (
        regSetting.list_name != editSetting.list_name ||
        regSetting.dialysis_prog_cd != editSetting.dialysis_prog_cd
      ) {
        isChange = true;
      }

      regSetting.list_name = editSetting.list_name;
      regSetting.dialysis_prog_cd = editSetting.dialysis_prog_cd;
      regSetting.dialysis_prog_name = editSetting.dialysis_prog_name;
      regSetting.disp_no = editSetting.disp_no;

      regSetting.chgflg_dispno = editSetting.chgflg_dispno;
      regSetting.chgflg_listname = editSetting.chgflg_listname;
      regSetting.chgflg_progcd = editSetting.chgflg_progcd;

      for (let i = 0; i < regSetting.funclist.length; i++) {
        let setData = editSetting.funclist[i];
        if (editSetting.funclist[i].func_class === null) {
          // 未登録の場合
          setData.func_class = null;
          setData.class_cd = null;
          setData.list_name = null;
        } else if (editSetting.funclist[i].func_class === 0) {
          // 通常リストの場合
          setData.func_class = 0;
          setData.class_cd = null;
          setData.list_name = editSetting.funclist[i].list_name;
          if (
            editSetting.funclist[i].list_name === null ||
            editSetting.funclist[i].list_name.trim() === ""
          ) {
            isError = true;
          }
        } else {
          // 治療材料/医療材料の場合
          setData.func_class = editSetting.funclist[i].func_class;
          setData.class_cd = editSetting.funclist[i].class_cd;
          if (editSetting.funclist[i].func_class === 1) {
            // 治療条件の場合
            setData.list_name = getListName(
              state.condList,
              editSetting.funclist[i].class_cd
            );
          } else if (editSetting.funclist[i].func_class === 2) {
            // 医療材料の場合
            setData.list_name = getListName(
              state.mstEquipClassList,
              editSetting.funclist[i].class_cd
            );
          //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
          } else if (editSetting.funclist[i].func_class === 3) {
            // 薬剤分類の場合
            setData.list_name = getListName(
              state.mstMedicineClassList,
              editSetting.funclist[i].class_cd
            );
          }
          //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s end
        }

        // 変更があった場合
        if (
          editSetting.funclist[i].chgflg === true ||
          editSetting.funclist[i].chgflg_disp_no
        ) {
          isChange = true;
        }
        regSetting.funclist.splice(i, 1, setData);
      }

      if (isError === true) {
        return false;
      }

      // チェックリスト設定情報
      let checklistSetting = deepCopy(state.checklistSetting);
      regSetting.chgflg = isChange;
      checklistSetting.checklistSettings[state.selectEditIndex] = regSetting;
      // チェックリストマスタ設定情報登録
      commit("setChecklistSetting", checklistSetting);
      // 変更フラグセット
      commit("setChangeFlg", isChange);

      // 並べ替え
      dispatch("mstChecklistSortData", checklistSetting.checklistSettings);

      return true;
    },
    // チェックリストマスタ設定情報登録
    async regChecklistSetting({ state, commit }) {
      try {
        // 登録情報
        const regSetting = deepCopy(state.checklistSetting);

        // DEL チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 START
        //ADD チェックリストマスタ 同一行程ごとに番号を振る 孔s START
        // for (let index = 0; index < regSetting.checklistSettings.length; index++) {
        //   regSetting.checklistSettings[index].list_cd = index+1
        // }
        //ADD チェックリストマスタ 同一行程ごとに番号を振る 孔s END
        // DEL チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 END
        // 表示順・変更フラグ削除
        regSetting.checklistSettings.forEach((value, index, array) => {
          delete array[index]["disp_no"];
          delete array[index]["dummy_disp_no"];
          delete array[index]["chgflg"];
          delete array[index]["chgflg_listname"];
          delete array[index]["chgflg_progcd"];
          delete array[index]["chgflg_dispno"];
          for (let i = 0; i < array[index].funclist.length; i++) {
            delete array[index].funclist[i]["no"];
            delete array[index].funclist[i]["disp_no"];
            delete array[index].funclist[i]["chgflg"];
            delete array[index].funclist[i]["chgflg"];
            delete array[index].funclist[i]["chgflg_disp_no"];
            delete array[index].funclist[i]["chgflg_list_name"];
            delete array[index].funclist[i]["chgflg_class_cd"];
            delete array[index].funclist[i]["chgflg_func_class"];
          }
        });
        // 設定内容(JSON→文字列)
        // チェックリストマスタ項目
        regSetting.checklistSettings = JSON.stringify(
          regSetting.checklistSettings
        );
        // 更新日時
        regSetting.upDate = new Date();
        // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
        const param = {
          mstChecklist: regSetting,
          editList: state.editList
        }
        // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
        // 登録結果
        // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou start
        // const response = await sendRequestUpdateMstChecklist(regSetting);
        const response = await sendRequestUpdateMstChecklist(param);
        // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou end

        // 登録成功
        if (response.status == 200) {
          // 変更フラグ
          commit("setChangeFlg", false);

          return true;
        }
      } catch (e) {
        alert(e.message);
        return false;
      }
    },
    // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 START
    async deleteOrdCheckList({ state }, facility) {
      try {
        let checklist = deepCopy(state.checklistSetting.checklistSettings);
        let delList = [];

        //工程の変更を見つけてください。それは未使用です。
        const chg_progcd = checklist.filter(item => item.chgflg_progcd && item.dialysis_prog_cd === 3)
          .map(item => {
            return item.list_cd
          });
        chg_progcd.forEach(listCd => {
          let tempData = {
            facilityCd: facility,
            listCd: listCd
          }
          delList.push(tempData);
        });

        // 詳細な変更があるアイテムを検索する
        checklist = checklist.filter(item => item.chgflg && !chg_progcd.find(f => f == item.list_cd))
        checklist.forEach(item =>
          item.funclist = item.funclist.filter(ff => ff.chgflg_class_cd || ff.chgflg_func_class || ff.chgflg_list_name)
        )

        checklist.forEach(item => {
          item.funclist.forEach(ff => {
            let tempData = {
              facilityCd: facility,
              listCd: item.list_cd,
              rstChecklistInfo: {
                item_number: ff.item_number
              }
            };
            delList.push(tempData)
          })
        })

        return sendRequestDeleteOrdChecklist(delList);

      } catch (e) {
        alert(e.message);
      }
    },
    // ADD チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 END
    getDeviceEdgeNoList() {
      return sendRequestMstDeviceEdgeNo();
    },
// ADD マスタ一覧 1･施設切替を可能とする 孔 START
    getDeviceEdgeNoListByFacilityCd(tmp, facilityCd) {
      return sendRequestMstDeviceEdgeNoByFacilityCd(facilityCd);
    },
// ADD マスタ一覧 1･施設切替を可能とする 孔 END
    /**
     * @param {*} context
     * @param {Object} params
     * @param {String} params.facilityCd
     * @param {number} params.deviceEdgeNo
     */
    mstSyncDeviceEdge(context, params) {
      return sendRequestMstChecklistSync({
        facilityCd: params.facilityCd,
        deviceEdgeNo: params.deviceEdgeNo
      });
    }
  },
  mutations: {
    // -----------------------------------------
    // チェックリスト設定用
    // -----------------------------------------
    // チェックリスト設定
    setChecklistSetting(state, data) {
      state.checklistSetting = data;
    },
    // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
    setEditList(state, editList) {
      state.editList = editList;
    },
    // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
    setOldChecklistSetting(state, data) {
      state.old_checklistSetting = data;
    },
    // 医療材料分類マスタ
    setMstEquipClassList(state, data) {
      state.mstEquipClassList = data;
    },
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 孔s start
    // 薬剤分類マスタ
    setMstMedicineClassList(state, data) {
      state.mstMedicineClassList = data;
    },
    //add チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する。 end
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする START
    edit(state, editInfo) {
      const editRecord = editInfo.editRecord;
      const isSortMode = editInfo.isSortMode;
      const editTemp = Object.keys(editInfo.value)[0];
      // 該当レコードがあれば内容を更新、なければ追加
      const foundData = state.checklistSetting.checklistSettings.find(e => {
        return e.list_cd === editRecord.list_cd;
      });
      const index = state.checklistSetting.checklistSettings.indexOf(foundData);

      if (editTemp === "dialysis_prog_cd") {
        foundData.chgflg_progcd = true;
        foundData.dialysis_prog_name = getProgName(
          state.mstDialysisProgressList,
          editInfo.value.dialysis_prog_cd
        );
        foundData.dialysis_prog_cd=editInfo.value.dialysis_prog_cd;
      }else if (editTemp === "list_name"){
        foundData.chgflg_listname = true
        foundData.list_name=editInfo.value.list_name
      }
      if (foundData.chgflg_progcd || foundData.chgflg_listname) {
        foundData.chgflg = true
        state.changeFlg=true;
      }
      // 該当レコードがあれば編集内容を反映
      if (foundData.operation != 1 && !isSortMode) {
        foundData.operation = 2;
      }
      if (isSortMode) {
        foundData.sortInputTime = Date.now();
      }
      state.checklistSetting.checklistSettings.splice(index, 1, foundData);
    },
    //ADD チェックリストマスタ 工程、リスト名を一覧で修正可能とする 孔s END
    // チェックリスト設定
    setMstCheckListColumn(state, data) {
      state.mstCheckListColumn = data;
    },
    setSelectEditIndex(state, idx) {
      state.selectEditIndex = idx;
    },
    setSelectEditSetting(state, setting) {
      state.selectEditSetting = setting;
    },
    setOldSelectEditSetting(state, setting) {
      state.old_selectEditSetting = setting;
    },
    // 変更フラグ
    setChangeFlg(state, flg) {
      state.changeFlg = flg;
    }
  }
};
