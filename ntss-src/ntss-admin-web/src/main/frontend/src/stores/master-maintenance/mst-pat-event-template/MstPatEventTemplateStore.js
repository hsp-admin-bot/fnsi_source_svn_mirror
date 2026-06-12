import {
  sendRequestGetSysDataSetList,
  sendRequestGetSysDataSetText,
  sendRequestGetSysDataSetResult, sendRequestGetSysDataSetResultByFacilityCd
} from "@/apis/pat-event";
/**
 * 患者イベントテンプレートマスタメンテナンスStore.
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    /* add リストボックス->データ取得元修正 楊 start */
    // 項目情報List
    inputParamsList: new Map(),
    /* add リストボックス->データ取得元修正 楊 end */
    // 項目情報
    initInputParams: [],
    inputParams: [],
    // スコア情報
    initListScore: [],
    listScore: [],
    // sys_data_set
    sysDataSet: { list: [], text: [] },
    /* add データ取得元修正 楊 start */
    //sys_data
    sysData: { list: [], text: [] },
    // sys_list_data_set
    sysListDataSet: { list: [], text: [] }
    /* add データ取得元修正 楊 end */
  },
  mutations: {
    setSysDataSet(state, sysDataSet) {
      /* mod データ取得元修正 楊 start */
      // mod #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 start
      // const list = sysDataSet.list.filter(element => element.memo == null?false:!element.memo.includes("リストボックス"));
      // const text = sysDataSet.text.filter(element => element.memo == null?false:!element.memo.includes("リストボックス"));
      // const listList = sysDataSet.list.filter(element => element.memo == null?false:element.memo.includes("リストボックス"));
      // const listText = sysDataSet.text.filter(element => element.memo == null?false:element.memo.includes("リストボックス"));
       const list = sysDataSet.list;
       const text = sysDataSet.text;
      // mod #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 end
      /* mod データ取得元修正 楊 end */
      if (list.length === 0) {
        state.sysDataSet.list = [];
      }
      if (text.length === 0) {
        state.sysDataSet.text = [];
      }
      // del #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 start
      /* add データ取得元修正 楊 start */
      // if (listList.length === 0) {
      //   state.sysListDataSet.list = [];
      // }
      // if (listText.length === 0) {
      //   state.sysListDataSet.text = [];
      // }
      // del #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 end
      /* add リストボックス->データ取得元修正 楊 end */
      const buildList = dataSet => {
        let itemList = [];
        let groupList = [];
        let groupNum = 0;

        for (const item of dataSet) {
          const cd = item.sqlCd;
          const detailInfo = item.detailInfo;
          if (detailInfo) {
            for (const detail of detailInfo.details) {
              const groupName = detail.data_category + "-" + detail.data_class;
              let group = groupList.find(g => g.name === groupName);
              if (!group) {
                // グループ追加
                group = { name: groupName, cd: groupNum };
                groupList.push(group);
                groupNum++;
              }
              const info = {
                cd: cd,
                group: group.cd,
                name: detail.data_name,
                field: detail.field_name
              };
              itemList.push(info);
            }
          }
        }
        return { groupList: groupList, itemList: itemList };
      };
      state.sysDataSet.list = buildList(list);
      state.sysDataSet.text = buildList(text);
      // del #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 start
      /* add データ取得元修正 楊 start */
      // state.sysListDataSet.list = buildList(listList);
      // state.sysListDataSet.text = buildList(listText);
      /* add データ取得元修正 楊 end */
      // del #6776 20230704 患者イベントテンプレートマスタ：テキストボックスのデータ 表示未指定 表示未指定、プルダウンフレーム内容なしです 孟堅 end
    },
    /* add リストボックス->データ取得元修正 楊 start */
    setInputParamsList(state, {key, inputParams}) {
      if(key !== undefined && key !== null) {
        state.inputParamsList.set(key,inputParams);
      }
    },
    clearInputParamsList(state) {
      state.inputParamsList.clear();
    },
    setInitInputParams(state, inputParams) {
      state.initInputParams = [];
      if (inputParams === "" || inputParams === null) {
        return;
      }
      const contact = JSON.parse(inputParams);
      for (let i = 0; i < contact.length; i++) {
        state.initInputParams.push({
          item_json: contact[i].item_json,
          field_name: contact[i].field_name,
          is_rst_copy: contact[i].is_rst_copy,
          format_class: contact[i].format_class,
          is_field_display: contact[i].is_field_display,
          _uniqueId: contact[i]._uniqueId,
        });
      }
    },
    setInputParams(state, inputParams) {
      state.inputParams = [];
      if (inputParams === "" || inputParams === null) {
        return;
      }
      const contact = JSON.parse(inputParams);
      for (let i = 0; i < contact.length; i++) {
        state.inputParams.push({
          item_json: contact[i].item_json,
          field_name: contact[i].field_name,
          is_rst_copy: contact[i].is_rst_copy,
          format_class: contact[i].format_class,
          is_field_display: contact[i].is_field_display,
          _uniqueId: contact[i]._uniqueId,
        });
      }
    },
    setInputParamsInsert(state, item) {
      state.inputParams.push(item);
    },
    setInputParamsUpdate(state, { item, index }) {
      state.inputParams[index].item_json = JSON.parse(item);
    },
    setInputParamsParentUpdate(state, { item, index }) {
      state.inputParams[index] = JSON.parse(item);
    },
    setInputParamsDelete(state, index) {
      state.inputParams.splice(index, 1);
    },
    setInputParamsItemProperty(state, { index, field, value }) {
      if (state.inputParams[index]) {
        state.inputParams[index][field] = value;
      }
    },
    setInputParamsItemJsonCalc(state, { index, calc }) {
      if (state.inputParams[index]?.item_json) {
        state.inputParams[index].item_json.calc = calc;
      }
    },
    setInputParamsItemJson(state, { index, itemJson }) {
      if (state.inputParams[index]) {
        state.inputParams[index].item_json = itemJson;
      }
    },
    setInitListScore(state) {
      state.initListScore = [];
      let value;
      const contact = state.initInputParams;
      for (let i = 0; i < contact.length; i++) {
        switch (contact[i].format_class) {
          case 3:
          case 4:
          case 6:
            value = contact[i].field_name;
            state.initListScore.push({
              name: value
            });
            break;
          default:
            break;
        }
      }
    },
    setListScore(state) {
      state.listScore = [];
      let value;
      const contact = state.inputParams;
      for (let i = 0; i < contact.length; i++) {
        switch (contact[i].format_class) {
          case 3:
          case 4:
          case 6:
            value = contact[i].field_name;
            state.listScore.push({
              name: value
            });
            break;
          default:
            break;
        }
      }
    }
  },
  actions: {
    /* add リストボックス->データ取得元修正 楊 start */
    setInputParamsList({ commit }, {key, inputParams}) {
      commit("setInputParamsList", {key, inputParams});
    },
    clearInputParamsList({ commit }) {
      commit("clearInputParamsList");
    },
    /* add リストボックス->データ取得元修正 楊 end */
    setInitInputParams({ commit }, inputParams) {
      commit("setInitInputParams", inputParams);
      commit("setInitListScore");
    },
    setInputParams({ commit }, inputParams) {
      commit("setInputParams", inputParams);
      commit("setListScore");
    },
    setInputParamsInsert({ commit }, item) {
      commit("setInputParamsInsert", item);
      commit("setListScore");
    },
    setInputParamsUpdate({ commit }, { item, index }) {
      commit("setInputParamsUpdate", { item, index });
      commit("setListScore");
    },
    setInputParamsParentUpdate({ commit }, { item, index }) {
      commit("setInputParamsParentUpdate", { item, index });
      commit("setListScore");
    },
    setInputParamsDelete({ commit }, index) {
      commit("setInputParamsDelete", index);
      commit("setListScore");
    },
    setInputParamsItemProperty({ commit }, payload) {
      commit("setInputParamsItemProperty", payload);
      if (payload.field === "field_name" || payload.field === "format_class") {
        commit("setListScore");
      }
    },
    setInputParamsItemJsonCalc({ commit }, payload) {
      commit("setInputParamsItemJsonCalc", payload);
    },
    setInputParamsItemJson({ commit }, payload) {
      commit("setInputParamsItemJson", payload);
    },
    /** sys_data_Setマスタ取得 */
    async fetchSysDataSet({ commit }) {
      const response1 = await sendRequestGetSysDataSetList();
      const response2 = await sendRequestGetSysDataSetText();
      commit("setSysDataSet", { list: response1.data, text: response2.data });
    },
    /** sys_data_Set結果取得 */
    sendRequestGetSysDataSetResult(context, params) {
      return sendRequestGetSysDataSetResult(params);
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    sendRequestGetSysDataSetResultByFacilityCd(context, params) {
      return sendRequestGetSysDataSetResultByFacilityCd(params, params.facilityCd);
    }
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },
  getters: {
    getInputParamsList(state) {
      return state.inputParamsList;
    },
    getInitInputParams(state) {
      return state.initInputParams;
    },
    getInputParams(state) {
      return state.inputParams;
    },
    getInitListScore(state) {
      return state.initListScore;
    },
    getListScore(state) {
      return state.listScore;
    },
    getSysDataSet(state) {
      return state.sysDataSet;
    },
    /* add データ取得元修正 楊 start */
    getSysListDataSet(state) {
      return state.sysListDataSet;
    }
    /* add データ取得元修正 楊 end */
  }
};
