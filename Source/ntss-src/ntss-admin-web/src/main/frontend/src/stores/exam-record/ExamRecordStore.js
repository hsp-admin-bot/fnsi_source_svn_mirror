/**
 * 検査記録用ストア ExamRecordStore
 */
import {
  sendRequestGetMstExamSetList,
  sendRequestGetMstExamItemList,
  sendRequestGetPatExamMainDetailList,
  sendRequestGetMstExamSetSort,
  sendRequestGetMstExamItemSort,
  sendRequestGetPatExamMainRecordList,
  sendRequestGetPatExamMainPatIdLastDate
} from "@/apis/exam-Record";
import store from "@/stores";
import {
  sendRequestGetMstFacilitySettingValue
} from "@/apis/facility-setting";
// add FNSI-NO423入院患者名の配布 関 start
import { ApiHelper } from "@/apis/AxiosHelper";
// add FNSI-NO423入院患者名の配布 関 end

import {
  LAST_DEFINED_PERIOD,
  EXAM_RESULT_DISP_ORDER,
} from "@/constants/facilitySetting";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { findExamSet, getNormalValueKeys, getResultValueClass } from "@/functions/exam-record/ExamRecordFunctions";
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import { getAppClientWidth } from "@/functions/common/LayoutMeasureHelper";

const getComponentInitialized = (state) => state.componentInitialized.header && state.componentInitialized.list;
const resetComponentInitializedIfNeeds = (initialized, state) => {
  if (!initialized && getComponentInitialized(state)) {
    // 一度すべてのコンポーネントの初期化が終わった状態でfalseが渡されたら
    // すべての初期化済情報をリセットする
    state.componentInitialized.header = false;
    state.componentInitialized.list = false;
  }
};

export default {
  strict: true,
  namespaced: true,
  state: {
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    examRouteFlg: true,
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
    componentInitialized: {
      header: false,
      list: false,
    },
    // 検査結果一覧グリッド用列設定
    examRecordColumn: null,
    // 検査結果詳細グリッド用列設定
    examRecordDetailColumn: null,
    // 抽出条件
    condition: {
      // getterをcomputedのmapGettersして利用する際には
      // この時点で存在しているプロパティのみの変更が検知されるため、
      // ダミー値でプロパティの定義をしておく
      common: {
        examDate: undefined,
        examDateSt: undefined,
        examDateEd: undefined,
        examSetCd: undefined,
      },
      list: {
        viewDayType: undefined,
        viewPatId: undefined,
        viewExamDate: undefined,
      },
      detail: {
        outRange: undefined,
        normalRange: undefined,
        unitDisplay: undefined,
        examGraphCd: undefined,
	      examPatId: undefined,
        examPatSex: undefined,
      },
    },
    // 明細欄選択項目
    detailSelectItems:[],
    // 検査結果一覧画面-一覧データ
    examDataSource: null,
    // 検査結果詳細
    examDetailDataSource: null,
    // デフォルト検査範囲月(画面呼び出し時に値セット)
    examDefaultMonth: null,
    // 患者性別未設定時使用フラグ（1:男性,2:女性)
    examDefaultSex: null,
    // 検査結果ファイル取込時患者ID判定設定 (1:12桁前方ゼロ詰め,2:完全一致(前方スペース詰め))
    checkResultForFacility: null,
    // 検査セットリスト
    examSetNameList: null,
    // 検査結果画面表示順設定（1:画面右過去、画面左未来, 2:画面右未来、画面左過去)
    examResultDispOrder: null,
    },
  getters: {
    getComponentInitialized,
    // 抽出条件
    getCondition(state) {
      return {
        ...state.condition.common,
        ...state.condition.list,
      };
    },
    // 抽出条件
    getDetailCondition(state) {
      return {
        ...state.condition.common,
        ...state.condition.detail,
      };
    },
    // 選択項目
    getDetailSelectItems(state){
      return state.detailSelectItems;
    },
    // 検査結果一覧グリッド用列設定
    getExamRecordColumn(state) {
      return state.examRecordColumn;
    },
    // 検査結果詳細グリッド用列設定
    getExamRecordDetailColumn(state) {
      return state.examRecordDetailColumn;
    },
    getExamDataSource(state) {
      return state.examDataSource;
    },
    getExamDefaultSex(state){
      return state.examDefaultSex;
    },
    getCheckResultForFacility(state){
      return state.checkResultForFacility;
    },
    getExamSetNameList(state) {
      return state.examSetNameList;
    },
    getExamDetailDataSource(state) {
      return state.examDetailDataSource;
    },
    getExamResultDispOrder(state){
      return state.examResultDispOrder;
    },
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    getExamRouteFlg(state){
      return state.examRouteFlg;
    },
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end

  },
  actions: {
    setHeaderComponentInitialized({ commit }, initialized) {
      commit("setHeaderComponentInitialized", initialized);
    },
    setListComponentInitialized({ commit }, initialized) {
      commit("setListComponentInitialized", initialized);
    },
    // 検査結果一覧：grid列項目作成
    resetExamRecordGridColumn({ commit }) {
      //画面幅を取得
      let baseWidth = getAppClientWidth();
      //列幅定義
      let columnWidth = parseFloat(baseWidth / 10);
      if (baseWidth < 1000){
        columnWidth = parseFloat(baseWidth / 6);
      }

      // 固定列
      let fixedColumns = [
          {field: "examResultCd",title: " " ,hidden: true},
          {field: "hope_pat_id",title: " ",width: columnWidth + "px", locked: true, lockable: true, hidden: false},
          {field: "pat_id", title:" ",hidden:true},
          {field: "pat_name",title: " ",width: columnWidth + "px",locked: true,lockable: true},
          {field: "treatDate", title: " ", hidden: true },
          {field: "viewTreatDate",title: " ", width: columnWidth + "px", locked: true, lockable: true, hidden: false}
        ];

      let detailsColumnsDefinitions = [
        { field: "Item_0",title:" ",hidden: true ,columns:[
          { field: "OrderClass0_0", title:" ", width: columnWidth +"px",hidden:true },
          { field: "OrderClass1_0", title:" ", width: columnWidth +"px",hidden:true },
          { field: "OrderClass2_0", title:" ", width: columnWidth +"px",hidden:true }
        ]}
      ];

      // 可変列
      for (let i = 0; i < detailsColumnsDefinitions.length; i++) {
        let addColumn = {
          field: "examrecord_" + detailsColumnsDefinitions[i].field,
          title: detailsColumnsDefinitions[i].title,
          width: detailsColumnsDefinitions[i].width,
          columns: detailsColumnsDefinitions[i].columns,
          lockable: false,
          hidden: false
        };
        fixedColumns.push(addColumn);
      }
      // 検査結果一覧項目列セット
      commit("setExamRecordColumn", fixedColumns);
    },

    // 検査結果詳細：grid列項目作成
    resetStatusDetailGridColumn({ commit }) {
      let baseWidth = getAppClientWidth();
      //列幅定義
      let columnWidth = parseFloat(baseWidth / 8);
      //600px未満(スマートフォン) 600以上1080以下,1080以上（iphone/ipad/PCを想定）
      if (baseWidth < 600){
        columnWidth = parseFloat(baseWidth / 10 * 3);
      }else if(baseWidth < 800){
        columnWidth = parseFloat(baseWidth / 4);
      }else if(baseWidth < 1080){
        columnWidth = parseFloat(baseWidth / 100 * 15);
      }
      // 固定列
      let fixedColumns = [
        {field: "examItemCd",title: "検査項目コード",hidden: true},
        {field: "examItemName",title: "検査項目名",width: columnWidth + "px",locked: true,lockable: true,headerTemplate:'<label id="examitemnamelbl">検査項目名</label>'},
        {field: "normalValueUpper",title: "正常値（上限）",hidden: true},
        {field: "normalValueLower",title: "正常値（下限）",hidden: true},
        {field: "normalValue",title: "正常範囲",width: columnWidth + "px",locked: true,lockable: true},
        //mod検査結果ページで単位を追加する 劉全航 start
        {field: "unit",title: "単位",width: columnWidth + "px",locked: true,lockable: true}
        //mod検査結果ページで単位を追加する 劉全航 end
      ];
      let detailsColumnsDefinitions = [
        { field: "A",title: "A",columns:[
          { field: "A", title: "A", width: 0 + "px" }
        ]}
      ];
      // 可変列
      for (let i = 0; i < detailsColumnsDefinitions.length; i++) {
        let addColumn = {
          field: detailsColumnsDefinitions[i].field,title: detailsColumnsDefinitions[i].title,
          width: detailsColumnsDefinitions[i].width,columns: detailsColumnsDefinitions[i].columns,
          lockable: false,hidden: false
        };
        fixedColumns.push(addColumn);
      }
      commit("setExamRecordDetailColumn", fixedColumns);
    },

    /**
     * 検査結果一覧データ設定情報リセット
     */
    resetExamDataSource({ commit }){
      commit("setExamDataSource", null);
    },

    /**
     * 検査結果詳細データ設定情報リセット
     * patId: 患者ID
     */
    resetExamDetailDataSource({ commit }){
      commit("setExamDetailDataSource", null);
    },

    /**
     * 検査結果詳細データ項目検索取得処理
     */
    async setExamSelectData({ commit ,state}, selectData){
      let resMstItem;
      let sortColumnData = [];
      let resExamMain;
      let resExamPat = selectData.patIdList;
      let patIdList;

      // 最終検査日
      let resExamLastDate;

      if(resExamPat.length >= 1){
        patIdList = resExamPat.map(function(element) {
          return element.pat_id;
        });
      }else{
        patIdList = [-1];
      }
      //1.検索条件日付 加工
      const examStartDate = state.condition.common.examDateSt;
      const examEndDate = state.condition.common.examDateEd;
      const viewDayType = state.condition.list.viewDayType;

      //画面幅を取得
      let baseWidth = getAppClientWidth();
      //列幅定義
      let columnWidth = parseFloat(baseWidth / 10);
      if (baseWidth < 1000){
        columnWidth = parseFloat(baseWidth / 6);
      }

      // 固定列
      let columnData = [
        {field: "examResultCd",title: "検査結果ID" ,hidden: true},
        {field: "hosp_pat_id",title: "患者ID",width: columnWidth + "px", locked: true, lockable: true, hidden: false},
        {field: "pat_id", title:"患者ID(システムID)",hidden:true},
        {field: "pat_name",title: "患者名",width: columnWidth+ "px",locked: true,lockable: true},
        {field: "treatDate", title: "検査日時", hidden: true },
        {field: "viewTreatDate",title: "最終検査日", width: columnWidth+ "px", locked: true, lockable: true, hidden: false}
      ];

      try{
        //項目テーブルからデータ取得
        resMstItem = await sendRequestGetMstExamItemList(selectData.facilityCd, selectData.selectedPatId);
      }catch(e){
        // add by liuzhibo 2022-11-10[7042]検査結果一覧画面が開けないの修正 -- start /
        store.dispatch("loading-screen/setLoadingScreenVisible", false)
        // add by liuzhibo 2022-11-10[7042]検査結果一覧画面が開けないの修正 -- end /
        console.error(e);
        throw new Error("検査項目マスタ取得エラー", { cause: e });
      }
      //column列データ取得成功時
      if (resMstItem.status === 200 && resMstItem.data.length > 0 && resMstItem.data[0] !== null){
        //1.項目別初期情報作成
        for(let m = 0; m< resMstItem.data.length; m++){
          let columnRecord = {};
          let columnsRecordArray = [
            // mod FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start
            // {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_1",title:"透析前",width:columnWidth,hidden:false,sortable:false},
            // {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_2",title:"透析後",width:columnWidth,hidden:false,sortable:false},
            // {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_0",title:"その他",width:columnWidth,hidden:false,sortable:false}
            {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_1",title:"透析前",width:columnWidth+20,hidden:false,sortable:true},
            {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_2",title:"透析後",width:columnWidth+20,hidden:false,sortable:true},
            {field:"item_"+ String(resMstItem.data[m].examItemCd)+"_order_0",title:"その他",width:columnWidth+20,hidden:false,sortable:true}
            // mod FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end
          ];
          columnRecord.field = "item_"+ String(resMstItem.data[m].examItemCd);
          columnRecord.hidden = false;
          columnRecord.lockable = true;
          columnRecord.title = String(resMstItem.data[m].examItemName);
          columnRecord.columns = columnsRecordArray;
          columnRecord.sortable = false;
          columnData.push(columnRecord);
        }

        try{
          //mainテーブルからデータ取得
          resExamMain = await sendRequestGetPatExamMainRecordList(
            patIdList,
            examStartDate,
            examEndDate,
            selectData.patientShareMode,
            selectData.selectedPatId
          );
          resExamLastDate = await sendRequestGetPatExamMainPatIdLastDate(patIdList, selectData.selectedPatId);
        }catch(e){
          // add by liuzhibo 2022-11-10[7042]検査結果一覧画面が開けないの修正 -- start /
          store.dispatch("loading-screen/setLoadingScreenVisible", false)
          // add by liuzhibo 2022-11-10[7042]検査結果一覧画面が開けないの修正 -- end /
          console.error(e);
          throw new Error("検査項目マスタ取得エラー", { cause: e });
        }
        // 施設設定マスタから透析困難リセット機能の設定値を取得
        // bug:4686,add by maxueqiang start
        const urigetFacilitySettingValue = `/facilitySetting/getFacilitySettingValue`;
        const response = await ApiHelper.get(
          `${urigetFacilitySettingValue}/${selectData.facilityCd}/${LAST_DEFINED_PERIOD}`,
          selectData.selectedPatId ? { selectedPatId: selectData.selectedPatId } : undefined
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('ExamRecordStore.js', 'setExamSelectData', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        });
        let lastDefinedPerid = response.data;
        // bug:4686,add by maxueqiang start
        //2.患者別情報作成
        for(let n = 0; n< resExamPat.length; n++){
          let patMaxDate = null;
          let patMaxDateName = null;
          //最新データで優先順位表示のために検査結果日付でソートする
          const sortExamMainByDate = resExamMain.data.sort((a, b) => new Date(b.resultExamDate) - new Date(a.resultExamDate));

          // 最新検査日を取得（期間内）: sortExamMainByDate は降順なので最初の一致する患者の行の日付を基準にする
          let latestDateInPeriod = null;
          if (viewDayType === 2) {
            // 表示条件「2:最新検査日」なら、最新検査日を取得
            for (let i = 0; i < sortExamMainByDate.length; i++) {
              if (resExamPat[n].pat_id == sortExamMainByDate[i].patId || resExamPat[n].pat_id == sortExamMainByDate[i].patIdDst) {
                latestDateInPeriod = sortExamMainByDate[i].resultExamDateName.slice(0, 8);
                break;
              }
            }
          }

          for(let i = 0;i<sortExamMainByDate.length; i++){
            if(resExamPat[n].pat_id == sortExamMainByDate[i].patId || resExamPat[n].pat_id == sortExamMainByDate[i].patIdDst){
              // 表示条件「2:最新検査日」なら、期間内の最新日以外はスキップ
              if (viewDayType === 2 && sortExamMainByDate[i].resultExamDateName.slice(0, 8) !== latestDateInPeriod) {
                continue;
              }
              //商品コードよりマスタの上限・下限値取得(共通・性別及び未設定時)
              let checkValueUpper;
              let checkValueLower;
              let selectItemData;
              let selectItemJlac10;

              // 商品コードでマスタ検索してマスタ情報取得
              if(resMstItem.data.some(item => item["examItemCd"] == sortExamMainByDate[i].itemCd) &&
                  !(resMstItem.data.some(item =>  item["jlac10Cd"] === sortExamMainByDate[i].jlac10Cd && !!item["jlac10Cd"]))){

                //患者行に各列最新日付の最新データをセット
                resExamPat[n]["item_"+ sortExamMainByDate[i].itemCd + "_order_" + sortExamMainByDate[i].regOrderClass]
                = sortExamMainByDate[i].result;
                resExamPat[n]["item_"+ sortExamMainByDate[i].itemCd + "_order_" + sortExamMainByDate[i].regOrderClass+ "_class"]
                = sortExamMainByDate[i].hl;
                resExamPat[n]["item_" + sortExamMainByDate[i].itemCd + "_order_" + sortExamMainByDate[i].regOrderClass + "_date"]
                = sortExamMainByDate[i].resultExamDateName;

                //マスタに対応する情報があるときのみデータを取得し上限下限値を取得
                selectItemData = resMstItem.data.filter(item => item["examItemCd"] == sortExamMainByDate[i].itemCd)[0];

                // 正常範囲のkey取得
                const { normalValueUpper, normalValueLower } =
                  getNormalValueKeys(selectItemData["normalValueClass"], resExamPat[n].pat_sex, state.examDefaultSex);
                checkValueUpper = selectItemData[normalValueUpper];
                checkValueLower = selectItemData[normalValueLower];

                // 異常値の文字色判定
                resExamPat[n]["item_"+ sortExamMainByDate[i].itemCd + "_order_" + sortExamMainByDate[i].regOrderClass+ "_class"] 
                  = getResultValueClass(sortExamMainByDate[i].result, checkValueLower, checkValueUpper);
              }

              // JLAC10コードで項目マスタデータを取得
              if(resMstItem.data.some(item =>  item["jlac10Cd"] === sortExamMainByDate[i].jlac10Cd && !!item["jlac10Cd"]) ){
                // 降順で項目マスタデータをソートする
                const sortMstItemByDate = resMstItem.data.sort((a, b) => (new Date(a.regDate) < new Date(b.regDate)) ? 1 : -1);
                //ログインしている施設の検査項目をチェックして存在した場合この項目を優先で表示する
                const selectItemByFacility = sortMstItemByDate.filter(item => item["facilityCd"] === selectData.facilityCd);
                selectItemJlac10 = selectItemByFacility.length > 0 ? selectItemByFacility.find(item => item["jlac10Cd"] == sortExamMainByDate[i].jlac10Cd) : sortMstItemByDate.find(item => item["jlac10Cd"] == sortExamMainByDate[i].jlac10Cd);

                const isSameExamItemCd = selectItemJlac10.examItemCd != sortExamMainByDate[i].itemCd;
                const isSameFacilityCd = selectItemJlac10.facilityCd == sortExamMainByDate[i].facilityCd;
                if (isSameExamItemCd && isSameFacilityCd) {
                  resExamPat[n]["item_"+ sortExamMainByDate[i].itemCd + "_order_" + sortExamMainByDate[i].regOrderClass]
                  = sortExamMainByDate[i].result;
                } else {
                  resExamPat[n]["item_"+ selectItemJlac10.examItemCd + "_order_" + sortExamMainByDate[i].regOrderClass]
                  = sortExamMainByDate[i].result;
                }

                resExamPat[n]["item_"+ selectItemJlac10.examItemCd + "_order_" + sortExamMainByDate[i].regOrderClass+ "_class"]
                = sortExamMainByDate[i].hl;

                resExamPat[n]["item_" + selectItemJlac10.examItemCd + "_order_" + sortExamMainByDate[i].regOrderClass + "_date"]
                = sortExamMainByDate[i].resultExamDateName;
                
                // 正常範囲のkey取得
                const { normalValueUpper, normalValueLower } =
                  getNormalValueKeys(selectItemJlac10["normalValueClass"], resExamPat[n].pat_sex, state.examDefaultSex);
                checkValueUpper = selectItemJlac10[normalValueUpper];
                checkValueLower = selectItemJlac10[normalValueLower];  
                
                // 異常値の文字色判定
                resExamPat[n]["item_"+ selectItemJlac10.examItemCd + "_order_" + sortExamMainByDate[i].regOrderClass+ "_class"]  
                  = getResultValueClass(sortExamMainByDate[i].result, checkValueLower, checkValueUpper);
              }
            }
          }

          // 2019/09/17 最終検査日を全データの最終検査日とするため、対象データから最終検査日を取得しloopで一致するpatIdのユーザに割り当て
          for(let i = 0;i<resExamLastDate.data.length; i++){
            if(resExamPat[n].pat_id == resExamLastDate.data[i].patId || resExamPat[n].pat_id == resExamLastDate.data[i].patIdDst){
              patMaxDate = resExamLastDate.data[i].lastDate;
              if(resExamLastDate.data[i].lastDate != null && resExamLastDate.data[i].lastDate != ''){
                patMaxDateName = resExamLastDate.data[i].lastDate.slice(0,4)
                + '/' + resExamLastDate.data[i].lastDate.slice(4,6)
                + '/' + resExamLastDate.data[i].lastDate.slice(6,8);
              }else{
                patMaxDateName = '';
              }
            }
          }
          // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou start
          //resExamPat[n]["pat_name"] = resExamPat[n].pat_last_name + "" + resExamPat[n].pat_first_name;
          resExamPat[n]["pat_name"] = (resExamPat[n].pat_last_name == null ? "" : resExamPat[n].pat_last_name) + "" + (resExamPat[n].pat_first_name== null ? "" :resExamPat[n].pat_first_name);
          // mod 9251 NKK連携 profile（標準）（拡張） 姓名を分割して保存していたデータが、姓の欄に結合して更新されてしまう。 zhou end
          resExamPat[n]["treatDate"] = patMaxDate;
          resExamPat[n]["viewTreatDate"] = patMaxDateName;
          // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 start
          resExamPat[n]["pat_full_name"] = (resExamPat[n].pat_last_name_kana==null ?"     " : resExamPat[n].pat_last_name_kana)
           + "" + (resExamPat[n].pat_first_name_kana==null ?"     " : resExamPat[n].pat_first_name_kana) + ""
           + resExamPat[n].pat_last_name + ""
           + resExamPat[n].pat_first_name;
           // add FNSI-数値ソート、文字ソート、空後方で結合してソートする 江 end
        }

        //3.項目別列ごとに患者別データに対応する値があるかどうか判定(表示・非表示制御)
        for(let s = 6 ;s< columnData.length; s++){
          let columnsHidden = true;
          for(let p = 0; p< columnData[s].columns.length; p++){
            if(resExamPat.some(item => item[columnData[s].columns[p].field])){
              columnData[s].columns[p].hidden = false;
              columnsHidden = false;
            }else{
              columnData[s].columns[p].hidden = true;
            }
          }
          columnData[s].hidden = columnsHidden;
        }

        //4.項目のソート順を変更
        let sort;
        try{
          //項目テーブルからデータ取得
          sort = await sendRequestGetMstExamItemSort(selectData.facilityCd, selectData.selectedPatId);
        }catch(e){
          console.error(e);
          throw new Error("検査項目ソート順：mst_selectorエラー", { cause: e });
        }
        //4.1.検査セット ソート処理
        let sortList = [];
        sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));
        //4.2.固定columnセット
        for(let setNo = 0; setNo < 6; setNo++){
          sortColumnData.splice(setNo,0,columnData[setNo]);
        }
        //4.2x itemキーにあってSortキーにないコードを末尾に順につける
        for(let itemkey = 6; itemkey < columnData.length; itemkey++){
          let itemFlg = false;
          for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
            if ("item_"+sortList[sortkey].code == columnData[itemkey].field){
              itemFlg =true;
            }
          }
          if(!itemFlg){
            //Sortデータにいない項目はソートリスト末尾にIDをセット
            let pushData = {code:Number(columnData[itemkey].field.slice(5)), name:"追加項目名"}
            sortList.push(pushData);
          }
        }
        //4.3.可変columnセット
        let columnsLength = 0;
        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          for(let itemkey = 0; itemkey < columnData.length; itemkey++){
            //データが1件もないColumnを追加せずに処理
            if ("item_"+sortList[sortkey].code == columnData[itemkey].field
              && columnData[itemkey]["hidden"] == false) {
                for(let hiddenkey = 2; hiddenkey >= 0; hiddenkey--){
                  if( columnData[itemkey].columns[hiddenkey].hidden == true){
                    columnData[itemkey].columns.splice(hiddenkey,1);
                  }
                }
                columnData[itemkey]["values"] = [{value:columnsLength}];
                sortColumnData.splice(sortkey + 6, 0,columnData[itemkey]);
                columnsLength = columnsLength + columnData[itemkey].columns.length;
            }
          }
        }
      }

      //非表示列セット
      let detailsColumnsDefinitions = [
        { field: "Item_0",title:" ",hidden: true ,columns:[
          { field: "OrderClass0_0", title:" ", width: "0px",hidden:true },
          { field: "OrderClass1_0", title:" ", width: "0px",hidden:true },
          { field: "OrderClass2_0", title:" ", width: "0px",hidden:true }
        ]}
      ];
      // 可変列
      for (let i = 0; i < detailsColumnsDefinitions.length; i++) {
        let addColumn = {
          field: "examrecord_" + detailsColumnsDefinitions[i].field,
          title: detailsColumnsDefinitions[i].title,
          width: detailsColumnsDefinitions[i].width,
          columns: detailsColumnsDefinitions[i].columns,
          lockable: false,
          hidden: false
        };
        if(sortColumnData.length <= 6){
          sortColumnData.push(addColumn);
        }
      }
      // add FNSI-NO423入院患者名の配布 関 start
        let patSimpleSearch = await ApiHelper.configPost("/patInfo/getPatSameAndInOutClass", {
          facilityCdList: [selectData.facilityCd]
        }, selectData.selectedPatId ? { params: { selectedPatId: selectData.selectedPatId } } : {})
      for (let index = 0; index < resExamPat.length; index++) {
        if (patSimpleSearch.data[resExamPat[index]["pat_id"]] != null) {
          resExamPat[index]["i_class"] = patSimpleSearch.data[resExamPat[index]["pat_id"]]["in_out_class"] == 1 ? "pat-name-in-hospital" : "";
          resExamPat[index]["img_display"] = patSimpleSearch.data[resExamPat[index]["pat_id"]]["is_same"] == 1 ? "" : "display:none";
        }
      }
      // add FNSI-NO423入院患者名の配布 関 end
      //データ取得成功時
      await commit("setExamRecordColumn",sortColumnData);
      await commit("setExamDataSource", resExamPat);
    },

    /**
     * 患者個別検査結果詳細データ項目検索取得処理
     */
    async setExamDetailSelectData({ commit, state }, {facilityCd, examDateOrder, patientShareMode, selectedPatId}){
      // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
      const formatNumber = (targetFormatNum) => {
        if (targetFormatNum == null) return targetFormatNum;
        if (targetFormatNum.toString().indexOf('e') > 0)
          targetFormatNum = parseFloat(targetFormatNum).toFixed(9)
        if (targetFormatNum.toString().indexOf('e') > 0 && targetFormatNum.toString().indexOf('-') == 0)
          targetFormatNum = "-" + parseFloat(targetFormatNum.slice(1, targetFormatNum.length)).toFixed(9)
        return targetFormatNum;
      };
      // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
      //1.検索条件日付 加工
      const examStartDate = state.condition.common.examDateSt;
      const examEndDate = state.condition.common.examDateEd;

      //検索時の項目セット指定がある場合：セット情報取得
      const examSet = findExamSet(state.condition.common.examSetCd, state.examSetNameList);
      const examItemInfo = examSet ? JSON.parse(examSet.examItemInfo) : null;
      let resExamItem = null;
      let resExamMain;

      //2.column列フィールド検索処理
      //画面幅を取得
      let baseWidth = getAppClientWidth();
      //列幅定義
      let columnWidth = parseFloat(baseWidth / 8);
      let columnArrayWidth = parseFloat(baseWidth / 8);
      const minColumnArrayWidth = 130;

      //600px未満(スマートフォン) 600以上1080以下,1080以上（iphone/ipad/PCを想定）
      if (baseWidth < 600){
        columnWidth = parseFloat(baseWidth / 10 * 3);
        columnArrayWidth= parseFloat(baseWidth / 10 * 4);
      }else if(baseWidth < 800){
        columnWidth = parseFloat(baseWidth / 4);
        columnArrayWidth= parseFloat(baseWidth / 4);
      }else if(baseWidth < 1080){
        columnWidth = parseFloat(baseWidth / 100 * 15);
        columnArrayWidth= parseFloat(baseWidth /100 * 70 / 5);
      }
      // 1行枠が130px未満の場合：130pxに固定
      if(columnArrayWidth < minColumnArrayWidth){
        columnArrayWidth = minColumnArrayWidth;
      }

      let columnData = [
        {field: "examItemCd",title: "検査項目コード",hidden: true},
        {field: "examItemName",title: "検査項目名",width: columnWidth + "px",locked: true,lockable: true,headerTemplate:'<label id="examitemnamelbl">検査項目名</label>'},
        {field: "normalValueUpper",title: "正常値（上限）",hidden: true},
        {field: "normalValueLower",title: "正常値（下限）",hidden: true},
        {field: "normalValue",title: "正常範囲",width: columnWidth + "px",locked: true,lockable: true},
        //mod検査結果ページで単位を追加する 劉全航 start
        {field: "unit",title: "単位",width: columnWidth + "px",locked: true,lockable: true}
        //end検査結果ページで単位を追加する 劉全航 start
      ];
      
      // 患者が選択されていない場合は移行の処理は行わない
      if (state.condition.detail.examPatId == null) {
        return;
      }
      
      try{
        //項目テーブルからデータ取得
        resExamItem = await sendRequestGetMstExamItemList(facilityCd, selectedPatId);
      }catch(e){
        console.error(e);
        throw new Error("検査項目データ取得エラー", { cause: e });
      }
      //column列データ取得成功時
      if (resExamItem.status === 200 && resExamItem.data.length > 0 && resExamItem.data[0] !== null
      ){
        //3.Mainテーブル検索処理
        resExamMain =
          await sendRequestGetPatExamMainDetailList(
            state.condition.detail.examPatId,
            examStartDate,
            examEndDate,
            examDateOrder,
            patientShareMode
          );
        const addResultMap = new Map();

        resExamMain.data.forEach(main => {
          const examListStart = JSON.parse(main.examResultInfo || "[]");
          const newIds = [];
          examListStart.forEach(item => {
            const tKey = item.item_cd + "";
            newIds.push(tKey);
            item.examMainCd = main.examMainCd;
            item.facilityCd = main.facilityCd;
            item.regOrderClass = main.regOrderClass;
          });
          main.ids = newIds;
          main.examResultInfo = JSON.stringify(examListStart);

          if (main.facilityCd === facilityCd) return;

          const examDateKey = main.resultExamDateName.slice(0, 8);
          const examList = JSON.parse(main.examResultInfo || "[]");
          examList.forEach(item => {
            if (item.jlac10_cd == null) return;
            const key = [
              main.patId,
              examDateKey,
              String(item.jlac10_cd)
            ].join("_");

            const val = Number(item.result);
            if (Number.isNaN(val)) return;

            addResultMap.set(key, (addResultMap.get(key) || 0) + val);
          });
          main.examResultInfo = JSON.stringify(examList);
        });
        //4.画面詳細(column列データ)表示データ生成／mainテーブルデータ生成(resExamItem)
        for(var n=0;n<resExamMain.data.length;n++){
          let columnRecord = {};
          let columnsRecord = {};
          let columnsRecordArray = [];
          columnRecord.field = "M"+ String(resExamMain.data[n].examMainCd) + "Cd";

          columnsRecord.field = "M" + String(resExamMain.data[n].examMainCd) + "Cd";
          columnsRecord.title = resExamMain.data[n].regOrderClassName;
          const isOtherFacility = resExamMain.data[n].facilityCd !== facilityCd;
          columnsRecord.isOtherFacility = isOtherFacility;

          const dateObj =
          new Date(resExamMain.data[n].resultExamDateName.slice(0,4)
          + '/' + resExamMain.data[n].resultExamDateName.slice(4,6)
          + '/' + resExamMain.data[n].resultExamDateName.slice(6,8));
          const dateStr = ("0"+(dateObj.getMonth() + 1)).slice(-2) + '/'
            + ("0"+(dateObj.getDate())).slice(-2)
            + '(' + ['日', '月', '火', '水', '木', '金', '土'][dateObj.getDay()] + ')';
          const timeStr = resExamMain.data[n].resultExamDateName.slice(8,10) + ":" + resExamMain.data[n].resultExamDateName.slice(10,12);
          columnRecord.title = `${dateStr}${timeStr}`;
          // 日付(曜日)に休日の色設定
          const holidayStyle = getHolidayStyle(resExamMain.data[n].resultExamDate);
          columnRecord.headerTemplate = `<label class="${holidayStyle}">${dateStr}</label>${timeStr}`;
            
          columnsRecord.width = columnArrayWidth + "px";
          if (isOtherFacility) {
            columnsRecord.attributes = {
              class: "other-facility-cell"
            };
            columnsRecord.headerAttributes = {
              class: "other-facility-header"
            };
            columnRecord.headerAttributes = {
              class: "other-facility-header"
            };
            columnRecord.headerTemplate = `
              <div class="other-facility-header">
                <label class="${holidayStyle}">${dateStr}</label>${timeStr}
              </div>
            `;
          } else {
            columnRecord.headerTemplate = `
              <label class="${holidayStyle}">${dateStr}</label>${timeStr}
            `;
          }
          columnsRecordArray.push(columnsRecord);

          columnRecord.columns = columnsRecordArray;
          columnRecord.lockable = false;
          columnRecord.hidden = false;
          columnRecord.columnsNo = columnData.length;
          columnRecord.isOtherFacility = isOtherFacility;

          let examRecordList = JSON.parse(resExamMain.data[n].examResultInfo);

          if (resExamMain.data[n].facilityCd === facilityCd && examRecordList) {
            const examDateKey = resExamMain.data[n].resultExamDateName.slice(0, 8);

            examRecordList.forEach(item => {
              if (item.jlac10_cd == null) return;

              const key = [
                resExamMain.data[n].patId,
                examDateKey,
                String(item.jlac10_cd)
              ].join("_");

              if (addResultMap.has(key)) {
                const baseVal = Number(item.result);
                const addVal = addResultMap.get(key);

                if (!Number.isNaN(baseVal)) {
                  item.result = baseVal + addVal;
                }
              }
            });
          }

          //要注意：男女チェック時に施設設定マスタの性別指定なし時制御については未実装
          if(examRecordList != null){
            for(var i=0;i<resExamItem.data.length;i++){
              if (resExamItem.data[i].examClass == 0) {
                const newList = [];
                resExamItem.data[i].regOrderClassArr = [];
                const tExamItemCd = resExamItem.data[i].examItemCd + "";

                for (let g = 0; g < resExamMain.data.length; g++) {
                  if (resExamMain.data[g].facilityCd == facilityCd) {
                    if (resExamMain.data[g].ids.indexOf(tExamItemCd) != -1) {
                      newList.push(resExamMain.data[g].regOrderClass);
                    }
                  }
                }
                if (newList.length != 0) resExamItem.data[i].regOrderClassArr = newList;
              }

              //正常範囲値（デフォルトは入力上下限）
              let checkValueUpper = null;
              let checkValueLower = null;
              
              // 正常範囲のkey取得
              const { normalValueUpper, normalValueLower } =
                getNormalValueKeys(resExamItem.data[i]["normalValueClass"], state.condition.detail.examPatSex, state.examDefaultSex);

              //値セット
              // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
              if(!resExamItem.data[i][normalValueLower] && !resExamItem.data[i][normalValueUpper]
                && resExamItem.data[i][normalValueLower] !== 0  && resExamItem.data[i][normalValueUpper] !== 0){
                  resExamItem.data[i]["normalValue"] = "";
              }else if(!resExamItem.data[i][normalValueLower] && resExamItem.data[i][normalValueLower] !== 0){
                checkValueUpper = formatNumber(resExamItem.data[i][normalValueUpper]);
                resExamItem.data[i]["normalValue"] =  "～" + formatNumber(resExamItem.data[i][normalValueUpper]);
              }else if(!resExamItem.data[i][normalValueUpper] && resExamItem.data[i][normalValueUpper] !== 0){
                checkValueLower = resExamItem.data[i][normalValueLower] ;
                resExamItem.data[i]["normalValue"] = formatNumber(resExamItem.data[i][normalValueLower]) + "～";
              }else{
                checkValueUpper = formatNumber(resExamItem.data[i][normalValueUpper]);
                checkValueLower = formatNumber(resExamItem.data[i][normalValueLower]);
                resExamItem.data[i]["normalValue"] = formatNumber(resExamItem.data[i][normalValueLower]) + "～" + formatNumber(resExamItem.data[i][normalValueUpper]);
              }
              // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end

              for(var m=0;m< examRecordList.length;m++){
                const setValue = () => {
                  resExamItem.data[i]["M" + resExamMain.data[n].examMainCd+"Cd"] = examRecordList[m].result;

                  // 異常値の文字色判定
                  resExamItem.data[i]["M" + resExamMain.data[n].examMainCd+"CdClass"] 
                    = getResultValueClass(examRecordList[m].result, checkValueLower, checkValueUpper);
                  
                  //チェックに文字が入っている場合：フラグを立てる
                  if(resExamItem.data[i]["M" + resExamMain.data[n].examMainCd+"CdClass"]
                    && resExamItem.data[i]["M" + resExamMain.data[n].examMainCd+"CdClass"].length >= 1){
                    if(examItemInfo){
                      // #10103 異常値のみ表示と検査セットで絞った際に異常値が表示されない linjunfeng start
                      // if(examItemInfo.some(item => item.item_cd == resExamItem.data[i].examItemCd)){
                      if(examItemInfo.some(item => item.exam_item_cd == resExamItem.data[i].examItemCd)){
                      // #10103 異常値のみ表示と検査セットで絞った際に異常値が表示されない linjunfeng end
                        resExamItem.data[i]["normalOver"] = true;
                        columnRecord["examOver"] = true;
                      }
                    }else{
                      resExamItem.data[i]["normalOver"] = true;
                      columnRecord["examOver"] = true;
                    }
                  }
                  //画面表示フラグ：データが1件あれば表示へ
                  resExamItem.data[i]["hidden"] = false;
                };

                if (facilityCd == examRecordList[m].facilityCd) {
                  if (resExamItem.data[i].examItemCd == examRecordList[m].item_cd) {
                    setValue();
                    break;
                  } else {
                    const item = resExamItem.data[i];
                    const record = examRecordList[m];
                    const main = resExamMain.data[n];

                    const isDifferentItem = item.examItemCd !== record.item_cd;
                    const isSameClass = item.jlac10Cd != null && record.jlac10_cd != null && item.jlac10Cd === record.jlac10_cd;
                    const flag = item.dialysisProgressFlag;
                    const isValidFlag = flag === 3 || flag === main.regOrderClass;
                    const isUsed = record.isUserTable != true;
                    const isSameFacility = item.facilityCd !== main.facilityCd;
                    if (isDifferentItem && isSameClass && isValidFlag && isUsed && isSameFacility) {
                      setValue();
                      break;
                    }
                  }
                } else {
                  if (examRecordList[m].exam_class == "0") {
                    if (resExamItem.data[i].jlac10Cd != null && resExamItem.data[i].jlac10Cd == examRecordList[m].jlac10_cd && resExamItem.data[i].examClass == 0) {
                      if (!examRecordList[m].isUserTable) {
                        const valueToCheck = examRecordList[m].jlac10_cd;
                        const count = resExamItem.data.filter(item => item.jlac10Cd === valueToCheck).length;
                        const regArr = resExamItem.data[i]?.regOrderClassArr;

                        if (count === 1 || (regArr && regArr.includes(examRecordList[m].regOrderClass))) {
                          examRecordList[m].isUserTable = true;
                          setValue();
                          break;
                        }
                      }
                    }
                  }

                  if (examRecordList[m].exam_class == "1") {
                    if (resExamItem.data[i].defaultCalcExamItemCd == examRecordList[m].defaultCalcExamItemCd && resExamItem.data[i].examClass == 1) {
                      examRecordList[m].isUsedefaultCD = true;
                      examRecordList[m].isUserTable = true;
                      setValue();
                      break;
                    }
                  }

                  if (examRecordList[m].exam_class == "2") {
                    if (resExamItem.data[i].jlac10Cd != null && resExamItem.data[i].examClass == 2 && resExamItem.data[i].jlac10Cd == examRecordList[m].jlac10_cd) {
                      examRecordList[m].isUserTable = true;
                      setValue();
                      break;
                    }
                  }
                }
              }
              // 検査セット指定時(異常値指定を除く）：対象検査セットが持つ検査項目を全て表示対象／それ以外を表示対象外
              if(examItemInfo){
                if(examItemInfo.some(item => resExamItem.data[i].examItemCd == item.exam_item_cd)){
                  resExamItem.data[i]["hidden"] = false;
                }else{
                  resExamItem.data[i]["hidden"] = true;
                }
              }
            }
            resExamMain.data[n].examResultInfo = JSON.stringify(examRecordList);
          }
          //columnデータセット:
          if(state.condition.detail.outRange && columnRecord["examOver"] == true){
            //範囲外検索時かつ範囲外データ
            columnData.push(columnRecord);
          }else if(!state.condition.detail.outRange){
            //通常検索時
            columnData.push(columnRecord);
          }
        }
        //空行データセット
        let detailsColumnsDefinitions = [
          { field: "A",title: "A",columns:[ { field: "A", title: "A", width: 0 + "px" } ]}
        ];
        for (let i = 0; i < detailsColumnsDefinitions.length; i++) {
          let addColumn = {
            field: detailsColumnsDefinitions[i].field,title: detailsColumnsDefinitions[i].title,width: detailsColumnsDefinitions[i].width,
            columns: detailsColumnsDefinitions[i].columns,lockable: false,hidden: false
          };
          columnData.push(addColumn);
        }

        let sort;
        try{
          //項目テーブルからデータ取得
          sort = await sendRequestGetMstExamItemSort(facilityCd, selectedPatId);
        }catch(e){
          console.error(e);
          throw new Error("検査項目ソート順：mst_selectorエラー", { cause: e });
        }
        //検査セット ソート処理
        let sortList = [];
        sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));
        let sortExamItem = [];

        // itemキーにあってSortキーにないコードを末尾に順につける
        for(let itemkey = 0; itemkey < resExamItem.data.length; itemkey++){
          let itemFlg = false;
          for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
            if (sortList[sortkey].code == resExamItem.data[itemkey].examItemCd){
              itemFlg =true;
            }
          }
          if(!itemFlg){
            //Sortデータにいない項目はソートリスト末尾にIDをセット
            let pushData = {code:Number(resExamItem.data[itemkey].examItemCd), name:"追加項目名"}
            sortList.push(pushData);
          }
        }

        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          for(let itemkey = 0; itemkey < resExamItem.data.length; itemkey++){
            if(state.condition.detail.outRange){
              //対象外データのある項目のみ対象
              if (sortList[sortkey].code == resExamItem.data[itemkey].examItemCd
                && resExamItem.data[itemkey]["normalOver"] == true
                && resExamItem.data[itemkey]["hidden"] == false) {
                sortExamItem.splice(sortkey,0,resExamItem.data[itemkey]);
              }
            }else{
              //全項目対象時
              if (sortList[sortkey].code == resExamItem.data[itemkey].examItemCd
                && resExamItem.data[itemkey]["hidden"] == false) {
                sortExamItem.splice(sortkey,0,resExamItem.data[itemkey]);
              }
            }
          }
        }

        const allData = [];
        if (Array.isArray(resExamMain.data)) {
          resExamMain.data.forEach(item => {
            if (item.examResultInfo) {
              try {
                const parsed = JSON.parse(item.examResultInfo);
                if (Array.isArray(parsed)) {
                  const filtered = parsed.filter(examItem => examItem.isUserTable !== true);
                  allData.push(...filtered);
                }
              } catch (_error) {
                console.error("JSON parse error:", item.examResultInfo);
              }
            }
          });
        }

        const resultArr = [];
        const cleanVal = v => {
          return (v === null || v === undefined || v === "null") ? "" : v;
        };
        allData.forEach(item => {
          if (item.exam_class == 0 && facilityCd != item.facilityCd && (!item.jlac10_cd || item.isUserTable != true)) {
            const newKey = "M" + item.examMainCd + "Cd";
            const exist = resultArr.find(
              result => result.examItemCd === item.item_cd
            );
            if (exist) {
              exist[newKey] = item.result;
            } else {
              const newObj = {
                consoleClass: "1",
                dataType: "0",
                defaultCalcExamItemCd: "",
                facilityCd: "",
                fnExamItemCd: "",
                hidden: false,
                isDel: "0",
                isDisp: "1",
                isInHospital: "1",
                normalValue: "",
                normalValueClass: "",
                normalValueUpper: "",
                regDate: "",
                upDate: ""
              };

              newObj[newKey] = item.result;
              newObj.examItemCd = item.item_cd;
              newObj.examItemName = item.item_name;

              const lower = cleanVal(item.lower);
              const upper = cleanVal(item.upper);
              newObj.normalValue = lower || upper ? `${lower}~${upper}` : "";
              newObj.normalValueUpper = item.normalValueUpper;
              newObj.regDate = item.result_date;
              newObj.upDate = item.result_date;
              newObj.jlac10_cd = item.jlac10_cd;

              resultArr.push(newObj);
            }
          }
        });

        const front = sortExamItem.filter(a =>
          resultArr.some(b => b.examItemCd == a.examItemCd)
        );
        const back = resultArr.filter(b =>
          !sortExamItem.some(a => a.examItemCd == b.examItemCd)
        );
        const willShowData = [...front, ...back];
        sortExamItem = sortExamItem.concat(willShowData);

        //画面明細部
        await commit("setExamRecordDetailColumn",columnData);
        await commit("setExamDetailDataSource", sortExamItem);
      }
    },

    /**
     * セットリスト：ソート処理
     */
    async setSortNameList({commit,state}, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      let nameList = await state.examSetNameList;
      let sortList = [];
      let sortNameList = [];
      let sort;
      // 更新画面生成時：患者検査結果テーブルより生成
      try{
        sort = await sendRequestGetMstExamSetSort(facilityCd, selectedPatId);
      }catch(e){
        console.error(e);
        throw new Error("検査項目セット取得処理エラー", { cause: e });
      }
      //検査セット ソート処理
      sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));

      // itemキーにあってSortキーにないコードを末尾に順につける
      for(let itemkey = 0; itemkey < nameList.length; itemkey++){
        let itemFlg = false;
        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          if (sortList[sortkey].code == nameList[itemkey].examSetCd){
            itemFlg =true;
          }
        }
        if(!itemFlg){
          //Sortデータにいない項目はソートリスト末尾にIDをセット
          let pushData = {code:Number(nameList[itemkey].examSetCd), name:"追加項目名"}
          sortList.push(pushData);
        }
      }
      //検査セットソート実行
      for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
        for(let itemkey = 0; itemkey < nameList.length; itemkey++){
          if (sortList[sortkey].code === nameList[itemkey].examSetCd) {
            sortNameList.splice(sortkey,0,nameList[itemkey]);
          }
        }
      }
    await commit("setExamSetNameList", sortNameList);
    },

    // 抽出条件
    setCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setCondition", condition);
    },
    // 抽出条件
    setDetailCondition({ commit }, detailCondition) {
      // 抽出条件セット
      commit("setDetailCondition", detailCondition);
    },
    // 選択項目
    setDetailSelectItems({commit}, selectItems){
      commit('setDetailSelectItems', selectItems);
    },
    setExamRecordColumn({ commit }, columns) {
      // 検査結果一覧項目列セット
      commit("setExamRecordColumn", columns);
    },
    setExamRecordDetailColumn({ commit }, columns) {
      // 検査結果詳細項目列セット
      commit("setExamRecordDetailColumn", columns);
    },

    // 性別未設定時参照先取得
    examSelectDefaultSex({ commit }, payload){
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      commit("setExamDefaultSex", null);
      return sendRequestGetMstFacilitySettingValue(facilityCd,"1017", selectedPatId).then(response => {
        commit("setExamDefaultSex", response.data);
        return Promise.resolve(response.data);
      });
    },

    // 検査結果ファイル取込時患者ID判定設定取得
    patIdJudgSetting({ commit }, payload){
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      commit("setCheckResultForFacility", null);
      return sendRequestGetMstFacilitySettingValue(facilityCd,"3003", selectedPatId).then(response => {
        commit("setCheckResultForFacility", response.data);
        return Promise.resolve(response.data);
      });
    },

    // 検査結果画面表示順設定取得
    resultDispOrderSetting({ commit }, payload){
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      commit("setExamResultDispOrder", null);
      return sendRequestGetMstFacilitySettingValue(facilityCd,EXAM_RESULT_DISP_ORDER, selectedPatId).then(response => {
        commit("setExamResultDispOrder", response.data);
        return Promise.resolve(response.data);
      });
    },

    // 検査セット一覧取得
    examSetNameList({ commit }, payload) {
      const facilityCd = payload && typeof payload === "object" ? payload.facilityCd : payload;
      const selectedPatId = payload && typeof payload === "object" ? payload.selectedPatId : undefined;
      commit("setExamSetNameList", []);
      return sendRequestGetMstExamSetList(facilityCd, selectedPatId).then(response => {
        commit("setExamSetNameList", response.data);
        return Promise.resolve(response.data);
      });
    },

    // 性別未設定時使用情報
    setExamDefaultSex({commit},data){
      commit("setExamDefaultSex",data);
    },

    // 検査結果ファイル取込時患者ID判定設定
    setCheckResultForFacility({commit},data){
      commit("setCheckResultForFacility",data);
    },

    // 検査セット一覧セット
    setExamSetNameList({commit},data){
      commit("setExamSetNameList", data);
    },

    // 検査結果画面表示順設定
    setExamResultDispOrder({commit},data){
      commit("setExamResultDispOrder",data);
    },
    // ストア情報初期化
    storeReset({commit}){
      commit("setDetailSelectItems",[]);
      commit("setExamRecordColumn",null);
      commit("setExamRecordDetailColumn",null);
      commit("setExamDataSource",null);
      commit("setExamDetailDataSource",null);
      commit("setExamSetNameList",null);
      commit("setExamDefaultSex",null);
      commit("setCheckResultForFacility",null);
      commit("setExamResultDispOrder",null);
    },
  },
  mutations: {
    setHeaderComponentInitialized(state, initialized) {
      resetComponentInitializedIfNeeds(initialized, state);
      state.componentInitialized.header = initialized;
    },
    setListComponentInitialized(state, initialized) {
      resetComponentInitializedIfNeeds(initialized, state);
      state.componentInitialized.list = initialized;
    },
    // 抽出条件
    setCondition(state, condition) {
      // #8368対応時のメモ：
      // 現時点では検査結果一覧の検索条件としては
      // examDateを使用していないが、
      // 患者カレンダーから遷移する際に設定されて
      // 検査結果画面の関数scrollFromRightでスクロール位置調整のために
      // 参照されているのでsetConditionでの処理対象としておく
      // （将来的に検査結果一覧の検索条件としても実装しなおされる見込みではある）
      state.condition.common.examDate = condition.examDate;
      state.condition.list.viewDayType = condition.viewDayType;
      state.condition.common.examDateSt = condition.examDateSt;
      state.condition.common.examDateEd = condition.examDateEd;
      state.condition.common.examSetCd = condition.examSetCd;
      state.condition.list.viewPatId = condition.viewPatId;
      state.condition.list.viewExamDate = condition.viewExamDate;
    },
    // 抽出条件
    setDetailCondition(state, detailCondition) {
      state.condition.common.examDateSt = detailCondition.examDateSt;
      state.condition.common.examDateEd = detailCondition.examDateEd;
      state.condition.common.examSetCd = detailCondition.examSetCd;
      state.condition.detail.outRange = detailCondition.outRange;
      state.condition.detail.normalRange = detailCondition.normalRange;
      state.condition.detail.unitDisplay = detailCondition.unitDisplay;
      state.condition.detail.examGraphCd = detailCondition.examGraphCd;
      state.condition.detail.examPatId = detailCondition.examPatId;
      state.condition.detail.examPatSex = detailCondition.examPatSex;
    },
    // 選択項目
    setDetailSelectItems(state,selectItems){
      state.detailSelectItems = selectItems;
    },

    // 検査結果一覧グリッド列
    setExamRecordColumn(state, column) {
      state.examRecordColumn = column;
    },
    // 検査結果詳細グリッド列
    setExamRecordDetailColumn(state, column) {
      state.examRecordDetailColumn = column;
    },
    // 検査結果一覧
    setExamDataSource(state, data) {
      state.examDataSource = data;
    },
    // 検査結果詳細
    setExamDetailDataSource(state, data) {
      state.examDetailDataSource = data;
    },
    // 検査デフォルト性別
    setExamDefaultSex(state, data){
      state.examDefaultSex = data;
    },
    // 検査結果ファイル取込時患者ID判定設定
    setCheckResultForFacility(state, data){
      state.checkResultForFacility = data;
    },
    // 検査セット一覧
    setExamSetNameList(state, data){
      state.examSetNameList = data;
    },
    // 検査結果画面表示順設定
    setExamResultDispOrder(state, data){
      state.examResultDispOrder = data;
    },
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng start
    setExamRouteFlg(state, data){
      state.examRouteFlg = data;
    },
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。linjunfeng end
  }
};
