/**
 * 検査結果モーダル用ストア
 */
import {
  sendRequestGetPatExamMainOneOrder,
  sendRequestInsertPatExamMainOneOrder,
  sendRequestUpdatePatExamMainOneOrder,
  sendRequestDeletePatExamMainOneOrder,
  sendRequestGetMstExamItemSort,
  sendRequestGetMstExamItemListForItemCd,
  sendRequestGetMstExamItemListForExamClass,
  sendRequestGetRstStartDateList,
} from "@/apis/exam-Record";

import {
  PAT_PERSONAL_MAIN_COL_PAT_SEX_W,
  PAT_PERSONAL_MAIN_COL_PAT_SEX_M
} from "@/constants/PatInfo";

import { deepCopy } from "@/functions/common/CommonFunctions";
import { dateFormat } from "@/functions/common/DateTimeUtils";
import { findExamSet } from "@/functions/exam-record/ExamRecordFunctions";

export default {
  strict: true,
  namespaced: true,
  state: {
    // 検査区分リスト
    examDivList: null,
    // 検査区分選択情報
    examSelectDiv: -1,
    // 検査日付
    examDate: null,
    // 検査時間
    examTime: null,
    // 検査項目明細データソース
    examMainDataSource: null,
    // 検査項目登録用データソース
    examMainData:null,
    // 検査項目明細Column
    examMainColumn: null,
    // モーダル起動ステータス（0：新規、1：編集）
    modalState: 0,
    // 連携オーダー番号(画面表示用)
    copOrderNo:null,
    // 抽出条件
    modalCondition: {
      examSetCd: -1,
      normalRange: true,
      allDataFlg: false
    },
    // ログインユーザー情報
    userAccountInfo: null,
    // 検査セットリスト
    examSetNameList: null,
    // 透析実績データリスト
    examPatList: null,
    // 検査結果コード
    examMainCd: null,
    // 最終更新日時,
    examUpDate: null,
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    // sub画面開けるフラグ
    isOpen: false
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
  },
  getters: {
    getSelectExamRecordSetting(state) {
      return state.selectExamrecordSetting;
    },
    getSelectExamrecord(state) {
      return state.selectExamrecord;
    },
    getCmbStafflist(state) {
      return state.cmbStafflist;
    },
    getExamDivList(state) {
      return state.examDivList;
    },
    getExamMainDataSource(state) {
      return state.examMainDataSource;
    },
    getExamMainData(state){
      return state.examMainData;
    },
    getExamMainColumn(state) {
      return state.examMainColumn;
    },
    getModalState(state) {
      return state.modalState;
    },
    getExamDate(state) {
      return state.examDate;
    },
    getExamTime(state) {
      return state.examTime;
    },
    getExamSelectDiv(state){
      return state.examSelectDiv;
    },
    getCopOrderNo(state){
      return state.copOrderNo;
    },
    getExamSetNameList(state) {
      return state.examSetNameList;
    },
    getExamPatList(state){
      return state.examPatList;
    },
    getModalCondition(state) {
      return state.modalCondition;
    },
    getExamMainCd(state){
      return state.examMainCd;
    },
    getExamUpDate(state){
      return state.examUpDate;
    },
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    getIsOpenFlag(state) {
      return state.isOpen;
    }
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
  },
  actions: {
    /**
     * 検査結果データ登録処理
     * @param {*}
     */
    async insertExamrecord({state},insertData) {
      let setExamResult = [];
      let ordNo;
      // 登録用json形式への変換用配列の生成
      for(let n = 0 ; n < state.examMainData.length; n++){
        if(state.examMainData[n].result || state.examMainData[n].freememo){
          let columnRecord = {};
          columnRecord.hl = state.examMainData[n].hl || null;
          columnRecord.result = state.examMainData[n].result || null;
          columnRecord.com_cd = state.examMainData[n].comCd || null;
          columnRecord.item_cd = Number(state.examMainData[n].itemCd);
          columnRecord.result_date = insertData.examDate.replace("-","/").replace("-","/");
          columnRecord.freememo = state.examMainData[n].freememo || null;
          columnRecord.item_name = state.examMainData[n].itemName;
          // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
          // columnRecord.type = Number(state.examMainData[n].type);
          // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
          columnRecord.unit = state.examMainData[n].unit;
          // columnRecord.jlac10_cd = state.examMainData[n].jlac10Cd || null;
          // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
          // mod sys_data_setのsql29に正常値上限と正常値下限の表示用 夏 start
          if(!state.examMainData[n].upper && state.examMainData[n].upper !== 0){
            columnRecord.upper = null;
          }else{
            columnRecord.upper = Number(state.examMainData[n].upper);
          }

          if(!state.examMainData[n].lower && state.examMainData[n].lower !== 0){
            columnRecord.lower = null;
          }else{
            columnRecord.lower = Number(state.examMainData[n].lower);
          }
          // mod sys_data_setのsql29に正常値上限と正常値下限の表示用 夏 end
          // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
          //if(!state.examMainData[n].inputUpper && state.examMainData[n].inputUpper !== 0){
          //  columnRecord.input_upper = null;
          //}else{
          //  columnRecord.input_upper = Number(state.examMainData[n].inputUpper);
          //}

          //if(!state.examMainData[n].inputLower && state.examMainData[n].inputLower !== 0){
          //  columnRecord.input_lower =null;
          //}else{
          //  columnRecord.input_lower = Number(state.examMainData[n].inputLower);
          //}

          columnRecord.exam_class =  state.examMainData[n].examClass || null;
          //add #12462 患者共有情報  by zrx start
          columnRecord.jlac10_cd =  state.examMainData[n].jlac10Cd || null;
          //add #12462 患者共有情報  by zrx end
          setExamResult.push(columnRecord);
        }
      }
      // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 start
      //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
      // let d = 0;
      // let res = 0;
      // let examItemMap = insertData.examItemMap;
      for(let n = 0 ; n < setExamResult.length ; n++) {
        // if (examItemMap[setExamResult[n].item_cd] != null && examItemMap[setExamResult[n].item_cd].inputDecimalFigure != null) {
        //   d = examItemMap[setExamResult[n].item_cd].inputDecimalFigure;
        //   res = setExamResult[n].result;
        //   if(!isNaN(res)){
        //     setExamResult[n].result = parseFloat(res).toFixed(d);
        //   }
        // }
      //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
        // del sys_data_setのsql29に正常値上限と正常値下限の表示用 夏 start
        // delete setExamResult[n].upper;
        // delete setExamResult[n].lower;
        // del sys_data_setのsql29に正常値上限と正常値下限の表示用 夏 end
        delete setExamResult[n].type;
        //del #12462 患者共有情報  by zrx start
        // delete setExamResult[n].jlac10_cd;
        //del #12462 患者共有情報  by zrx end
      }
      // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 end
      if(insertData.ordNo == -1){
        ordNo = null;
      }else{
        ordNo = insertData.ordNo;
      }
      try{
        await sendRequestInsertPatExamMainOneOrder(
          {
            patId:Number(insertData.patId),
            facilityCd:insertData.facilityCd,
            regExamDate:insertData.examDate,
            regOrderClass:insertData.orderClass,
            ordNo:ordNo,
            resultExamDate:insertData.examDate,
            examResultInfo:JSON.stringify(setExamResult),
            staff:Number(state.userAccountInfo.userId)
          }
        );
      }catch(e){
        console.error(e);
        return {result: false, message: e}
      }
      return { result: true };

    },

    /**
     * 検査結果データ更新処理
     * @param {*}
     */
    // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 start
    // async updateExamrecord ({state}, {examDate, mergeFlg, target, examResult, orderClass}) {
    async updateExamrecord ({state}, {patId,facilityCd,examDate, mergeFlg, target, examResult, orderClass, examItemMap}) {
    // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 end
      let setExamResult = [];
      // 登録用json形式への変換用配列の生成
      for(let n = 0 ; n < state.examMainData.length; n++){
        //mod FNSI-BMIの計算しない問題を修正します 関 start
        // if(state.examMainData[n].result || state.examMainData[n].freememo){
        if(state.examMainData[n].result || state.examMainData[n].freememo || state.examMainData[n].examClass == '1'){
        //mod FNSI-BMIの計算しない問題を修正します 関 end
          let columnRecord = {};
          columnRecord.hl = state.examMainData[n].hl || null;
          columnRecord.result = state.examMainData[n].result || null;
          columnRecord.com_cd = state.examMainData[n].comCd || null;
          columnRecord.item_cd = Number(state.examMainData[n].itemCd);
          columnRecord.result_date = examDate.replace("-","/").replace("-","/");
          columnRecord.freememo = state.examMainData[n].freememo || null;
          columnRecord.item_name = state.examMainData[n].itemName;
          columnRecord.type = Number(state.examMainData[n].type);
          columnRecord.unit = state.examMainData[n].unit;
          // columnRecord.jlac10_cd = state.examMainData[n].jlac10Cd || null;

          if(!state.examMainData[n].upper && state.examMainData[n].upper !== 0){
            columnRecord.upper = null;
          }else{
            columnRecord.upper = Number(state.examMainData[n].upper);
          }

          if(!state.examMainData[n].lower && state.examMainData[n].lower !== 0){
            columnRecord.lower = null;
          }else{
            columnRecord.lower = Number(state.examMainData[n].lower);
          }

          //if(!state.examMainData[n].inputUpper && state.examMainData[n].inputUpper !== 0){
          //  columnRecord.input_upper = null;
          //}else{
          //  columnRecord.input_upper = Number(state.examMainData[n].inputUpper);
          //}

          //if(!state.examMainData[n].inputLower && state.examMainData[n].inputLower !== 0){
          //  columnRecord.input_lower =null;
          //}else{
          //  columnRecord.input_lower = Number(state.examMainData[n].inputLower);
          //}
          columnRecord.exam_class =  state.examMainData[n].examClass || null;
          //add #12462 患者共有情報  by zrx start
          columnRecord.jlac10_cd =  state.examMainData[n].jlac10Cd || null;
          //add #12462 患者共有情報  by zrx end
          setExamResult.push(columnRecord);
        }
      }

      // マージ実施
      let mergedExamResult = [];
      //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
      // add FNSI-NO504-冗長なjsonデータを削除する 関 start
      // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 start
      // let d = 0;
      // let res = 0;
      for(let n = 0 ; n < setExamResult.length ; n++) {
        // if (examItemMap[setExamResult[n].item_cd] != null && examItemMap[setExamResult[n].item_cd].inputDecimalFigure != null) {
        //   d = examItemMap[setExamResult[n].item_cd].inputDecimalFigure;
        //   res = setExamResult[n].result;
        //   if(!isNaN(res)){
        //     setExamResult[n].result = parseFloat(res).toFixed(d);
        //   }
        // }
      //mod #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
      // mod FNSI-IES317 チェック項目の小数点を手動で入力する機能の実現 関 end
        delete setExamResult[n].upper;
        delete setExamResult[n].lower;
        delete setExamResult[n].type;
        //del #12462 患者共有情報  by zrx start
        // delete setExamResult[n].jlac10_cd;
        //del #12462 患者共有情報  by zrx end
      }
      // add FNSI-NO504-冗長なjsonデータを削除する 関 end
      let strSetExamResult = JSON.stringify(setExamResult);
      let numExamMainCd = Number(state.examMainCd);
      if (mergeFlg) {
        let MergedCdList = []; // マージされたitem_cd

        // マージ元をオブジェクトに変換する
        const baseExamResult = JSON.parse(examResult); // マージ元

        // マージ元がnullの場合は処理しない(検査依頼からのマージetc)
        if (baseExamResult !== null) {
          // マージ元にあるデータをベースにして上書き
          baseExamResult.forEach(baseItem => {
            let isMerged = false; // マージ済みかどうか
            setExamResult.forEach(mergeItem => {
              if (baseItem.item_cd.toString() === mergeItem.item_cd.toString()) {
                // マージ元とマージ先に同じ検査項目コードがあった場合、上書き
                mergeItem.result_date = examDate.replace("-","/").replace("-","/");
                mergedExamResult.push(mergeItem);
                MergedCdList.push(mergeItem.item_cd);
                isMerged = true;
              }
            })
            if (!isMerged) {
              baseItem.result_date = examDate.replace("-","/").replace("-","/");
              mergedExamResult.push(baseItem);
            }
          });
          // マージ先にしかないデータ投入
          setExamResult.forEach(mergeItem => {
            if (MergedCdList.indexOf(mergeItem.item_cd) === -1) {
              mergeItem.result_date = examDate.replace("-","/").replace("-","/");
              mergedExamResult.push(mergeItem);
            }
          });
          strSetExamResult = JSON.stringify(mergedExamResult);
        }
        numExamMainCd = Number(target);
      }

      const setParam = {
        patId:patId,
        facilityCd:facilityCd,
        examMainCd: numExamMainCd,
        examResultInfo: strSetExamResult,
        upStaff: Number(state.userAccountInfo.userId),
        examDate: examDate,
        regOrderClass: orderClass
      };
      try{
        await sendRequestUpdatePatExamMainOneOrder(setParam);
      }catch(e){
        console.error(e);
        return {result: false, message: e}
      }
      return { result: true };
    },

    /**
     * 検査結果データ削除処理
     */
    async deleteExamrecord({state}){
      const setParam = {
        examMainCd: state.examMainCd,
        upStaff: Number(state.userAccountInfo.userId),
        checkDate: state.examUpDate
      };
      try{
        await sendRequestDeletePatExamMainOneOrder(setParam);
      }catch(e){
        return {result: false, message: e}
      }
      return { result: true };
    },

    /**
     * 検査結果記録データ設定情報設定
     * examResultCd: 検査結果ID
     */
    async setExamModalDataSource ({dispatch, state, commit }, selectData) {
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
      let examMainData;
      let selectSortSetData = [];
      let examDate = null;
      let examTime = null;
      let sort;
      let examSelectDiv = 0;
      let copOrderNo = "";

      //共通部品生成
      let examDiv = [{
        'examOrderName':'透析前','examOrderCode':1},{'examOrderName':'透析後','examOrderCode':2},{'examOrderName':'その他','examOrderCode':0
      }];

      // 全件検索及びセット処理
      await dispatch("setExamAllSet",(selectData));
      let dispData = deepCopy(await state.examMainDataSource);

      //画面表示対象データ取得
      if (state.modalState === 1) {
        // 更新時検索条件フィールドセット
        await commit("setModalCondition",{ examSetCd: -1, normalRange: true, allDataFlg: false});
        // 更新画面生成時：患者検査結果テーブルより生成
        try{
          examMainData = await sendRequestGetPatExamMainOneOrder(
            selectData.field.slice(1,selectData.field.length-2),
            selectData.selectedPatId
          );
        }catch(e){
          console.error(e);
          throw new Error("1オーダー検査結果データ取得", { cause: e });
        }
        for(let i=0;i < examMainData.data.length;i++){
          //値セット// mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
          if(!examMainData.data[i]["lower"] && !examMainData.data[i]["upper"]
              && examMainData.data[i]["lower"] !== 0  && examMainData.data[i]["upper"] !== 0) {
            examMainData.data[i]["normalValue"] = "";
          }else if(!examMainData.data[i]["lower"] && examMainData.data[i]["lower"] !== 0){
            examMainData.data[i]["normalValue"] = "～" + formatNumber(examMainData.data[i]["upper"]);
          }else if(!examMainData.data[i]["upper"] && examMainData.data[i]["upper"] !== 0){
            examMainData.data[i]["normalValue"] = formatNumber(examMainData.data[i]["lower"]) + "～";
          }else{
            examMainData.data[i]["normalValue"]= formatNumber(examMainData.data[i]["lower"]) + "～" + formatNumber(examMainData.data[i]["upper"]);
          }
          // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
        }

        //結果データ1件以上でソート処理
        if(examMainData.data.length > 0){
          // 更新画面生成時：患者検査結果テーブルより生成
          try{
            sort = await sendRequestGetMstExamItemSort(
              examMainData.data[0].facilityCd,
              selectData.selectedPatId
            );
          }catch(e){
            console.error(e);
            throw new Error("検査項目ソートデータ取得失敗", { cause: e });
          }

          //1.データ取得時のセット情報を加える
          //1.1 オーダー連携番号
          examSelectDiv = examMainData.data[0].regOrderClass;
          if(examMainData.data[0].copOrderNo1 != null){
            copOrderNo = "連携番号:"+ examMainData.data[0].copOrderNo1;
          }

          //1.2 取得データの日付情報
          if (examMainData.data[0].resultExamDateName != null) {
            examDate = examMainData.data[0].resultExamDateName.slice(0,4)
            + '-' + examMainData.data[0].resultExamDateName.slice(4,6)
            + '-' + examMainData.data[0].resultExamDateName.slice(6,8);
            examTime = examMainData.data[0].resultExamDateName.slice(8,10)
            + ':' + examMainData.data[0].resultExamDateName.slice(10,12);
          }

          //検査セット ソート処理

        let sortList = [];
        sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));

          //2. 検査項目＋登録データ処理
          let sortOutData = [];
          for(let itemkey = 0; itemkey < examMainData.data.length; itemkey++){
            // 登録データを全件見て一致するdispDataのコードがあるかチェック
            let itemFlg = false;
            for(let dispkey = 0; dispkey < dispData.length;dispkey++){
              if(dispData[dispkey].itemCd == examMainData.data[itemkey].itemCd){
                // 対象があればデータを上書きする
                itemFlg = true;
                dispData[dispkey] = examMainData.data[itemkey];
              }
            }
            if(!itemFlg){
              // 入力データがあったのに現行対象に含まれない場合：末尾に項目として追加しておく
              dispData.push(examMainData.data[itemkey]);
              sortOutData.push(examMainData.data[itemkey]);
            }
          }

          //3. 初期表示データをソート順通りに並び替えかつマスタ削除済項目を追加
          for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
            for(let itemkey = 0; itemkey < examMainData.data.length; itemkey++){
              //全項目対象時
              if (sortList[sortkey].code == examMainData.data[itemkey].itemCd){
                selectSortSetData.splice(sortkey,0,examMainData.data[itemkey]);
              }
            }
          }
          for(let outkey = 0; outkey < sortOutData.length; outkey++){
            selectSortSetData.push(sortOutData[outkey]);
          }

          //4.検査結果id/最終更新日時を保管
          await commit("setExamMainCd", examMainData.data[0].examMainCd);
          await commit("setExamUpDate", dateFormat.utc2Jst(examMainData.data[0].upDate));
        }

        //5.画面初期表示データに検索結果(登録データ)をセットし
        //  全体の入力値データに全項目データ＋検索結果データ統合値をセット
        await commit("setExamMainDataSource", selectSortSetData);
        await commit("setExamMainData", dispData);

      }else{
        // 新規画面生成時：連携オーダー情報無し
        examSelectDiv = 0;
        // 新規作成時検索条件フィールドセット
        await commit("setModalCondition",{ examSetCd: -1, normalRange: true, allDataFlg: true});
      }
      await commit("setExamDivList", examDiv);
      state.examSelectDiv = examSelectDiv;
      state.examDate = examDate;
      state.examTime = examTime;
      state.copOrderNo = copOrderNo;
    },

    /**
     * 検査結果カラムの構成作成
     * examResultCd: 検査結果ID
     */
    setExamModalColumn({commit}){
     // 固定列
     let fixedColumns = [
      {field: "itemCd",title: "検査項目コード",hidden: true,editable: () => false},
      {field: "itemName",title: "検査項目名", width:"8em", editable: () => false,headerTemplate:"<label id=\"examitemnamemodallbl\">検査項目名</label>"},
      {field: "upper",title: "正常値（上限）",hidden: true,editable: () => false},
      {field: "lower",title: "正常値（下限）",hidden: true,editable: () => false},
      {field: "normalValue",title: "正常範囲",width:"8em",editable: () => false},
      {field: "inputUpper",title: "入力上限値",hidden: true,editable: () => false},
      {field: "inputLower",title: "入力下限値",hidden: true,editable: () => false},
      {field: "inputIntegerFigure",title: "整数部桁数",hidden: true,editable: () => false},
      {field: "inputDecimalFigure",title: "小数部桁数",hidden: true,editable: () => false},
      {field: "type",title: "データ形式",hidden: true,editable: () => false},
      {field: "result",title: "検査データ",width:"8em", editable: () => true},
      {field: "comCd",title: "検査コメントコード",hidden: true,editable: () => false},
      {field: "freememo",title: "コメント",width:"8em",editable: () => true}
    ];
    commit("setExamMainColumn", fixedColumns);
    },

    /**
     * 検査結果入力情報の保存データ最新化処理（画面の表示条件制御に関係なく対象は更新されなければならないため）
     * examResultCd: 検査結果ID
     */
    async selectExamData({state,commit},examSetNameList) {
      // 現時点の画面表示された項目値(dispData)を登録用データ値(inputData)に反映する
      let dispData = state.examMainDataSource;
      let inputData = state.examMainData;
      let insFlg;
      // 現行画面表示情報の保管
      if(dispData){
        for (var i = 0; i < dispData.length; i++) {
          insFlg = false;
          for(var n = 0; n < inputData.length; n++){
            if(dispData[i].itemCd == inputData[n].itemCd){
                //一致するデータがあればSaveDataを更新
                inputData[n].result = dispData[i].result;
                inputData[n].freememo = dispData[i].freememo;
                insFlg = true;
                break;
            }
          }
          if(!insFlg){
            inputData.push(dispData[i]);
          }
        }
      }

    // 画面表示条件分岐
    if (state.modalCondition.examSetCd == -1 && state.modalCondition.allDataFlg) {
      // セット未選択(全件)かつ結果無し行表示ON時
      // 画面表示項目値を登録用データ値で完全上書き（全件セット）
      dispData = inputData;
    }else if(state.modalCondition.examSetCd == -1  && !state.modalCondition.allDataFlg){
      dispData = [];
      // セット未選択(全件)かつ結果無し行表示OFF
      // 画面表示項目値を登録用データ値の登録値及びコメントが1文字以上入っている項目に限ってセットする
      for(var mv = 0; mv < inputData.length; mv++){
        if(!(inputData[mv].result == null) || !(inputData[mv].freememo == null || inputData[mv].freememo == "")){
          // 検査データ項目またはコメント値に値が入っていること
          dispData.push(inputData[mv]);
        }
      }
    }else if (state.modalCondition.examSetCd != -1 && state.modalCondition.allDataFlg) {
      // セット選択済かつ結果無し行表示ON：
      // 画面表示項目値を一旦リセットし、登録用データ値から選択したセットの情報のみを投入して表示
      dispData = [];
      const examSet = findExamSet(state.modalCondition.examSetCd, examSetNameList);
      const itemNoList = examSet ? JSON.parse(examSet.examItemInfo) : [];
      for(var s = 0; s < inputData.length; s++){
        for(var m = 0; m < itemNoList.length; m++){
          if(inputData[s].itemCd == itemNoList[m].exam_item_cd){
            dispData.push(inputData[s]);
            break;
          }
        }
      }
    }else{
        // セット選択済かつ結果無し行表示OFF：
        // 画面表示項目値を一旦リセットし、登録用データ値から選択したセットの情報のうち値があるデータのみ投入して表示
        dispData = [];
        const examSet = findExamSet(state.modalCondition.examSetCd, examSetNameList);
        const itemNoList = examSet ? JSON.parse(examSet.examItemInfo) : [];
        for(var ss = 0; ss < inputData.length; ss++){
          for(var mm = 0; mm < itemNoList.length; mm++){
            if(inputData[ss].itemCd == itemNoList[mm].exam_item_cd){
              if(!(inputData[ss].result == null) || !(inputData[ss].freememo == null || inputData[ss].freememo == "")){
                // 検査データ項目またはコメント値に値が入っていること
                dispData.push(inputData[ss]);
              }
              break;
            }
          }
        }
      }
      await commit("setExamMainDataSource", dispData);
      await commit("setExamMainData", inputData);

    },

    /**
     * セット項目の選択追加処理
     * examResultCd: 検査結果ID
     */
    async setExamDataSet({commit,state},selectData) {
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
      let dispData = await state.examMainDataSource;
      let inputData = await state.examMainData;

      let selectSetData;
      let selectSortSetData = [];
      let sort;

      // 更新画面生成時：患者検査結果テーブルより生成
      try{
        selectSetData = await sendRequestGetMstExamItemListForItemCd(
          selectData.facilityCd,
          selectData.itemCd,
          selectData.selectedPatId
        );
        sort = await sendRequestGetMstExamItemSort(selectData.facilityCd, selectData.selectedPatId);
      }catch(e){
        console.error(e);
        throw new Error("検査項目マスタデータ取得失敗", { cause: e });
      }

      //要注意：男女チェック時に施設設定マスタの性別指定なし時制御については未実装
      if(selectSetData != null){
        for(var i=0;i<selectSetData.data.length;i++){
          //正常範囲値（デフォルトは入力上下限）
          //let checkValueUpper = resExamItem.data[i].inputUpper;
          //let checkValueLower = resExamItem.data[i].inputLower;
          let checkValueUpper = null;
          let checkValueLower = null;
          let upper = null;
          let lower = null;
          //範囲の男女共通別取得：
          if(selectSetData.data[i]["normalValueClass"] == "0"){
            //共通パラメータ時
            upper = "upper";
            lower = "lower";
          }else if(selectData.patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_W) {
            //女性の場合
            upper = "normalValueUpperW";
            lower = "normalValueLowerW";
          }else if(selectData.patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_M){
            //男性その他の場合
            upper = "normalValueUpperM";
            lower = "normalValueLowerM";
          }else{
            //性別未設定(女性でも男性でもない)
            if(selectData.defaultSex == 1){
              // 性別未設定：男性数値使用
              upper = "normalValueUpperM";
              lower = "normalValueLowerM";
            }else if(selectData.defaultSex == 2){
              // 性別未設定：女性数値使用
              upper = "normalValueUpperW";
              lower = "normalValueLowerW";
            }
          }
          //値セット// mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
          if(!selectSetData.data[i][lower] && !selectSetData.data[i][upper]
            && selectSetData.data[i][lower] !== 0  && selectSetData.data[i][upper] !== 0) {
            selectSetData.data[i]["normalValue"] = "";
          }else if(!selectSetData.data[i][lower] && selectSetData.data[i][lower] !== 0){
            checkValueUpper = formatNumber(selectSetData.data[i][upper]);
            selectSetData.data[i]["normalValue"] = "～" + formatNumber(selectSetData.data[i][upper]);
          }else if(!selectSetData.data[i][upper]&& selectSetData.data[i][upper] !== 0){
            checkValueLower = formatNumber(selectSetData.data[i][lower]) ;
            selectSetData.data[i]["normalValue"] = formatNumber(selectSetData.data[i][lower]) + "～";
          }else{
            checkValueUpper = formatNumber(selectSetData.data[i][upper]);
            checkValueLower = formatNumber(selectSetData.data[i][lower]) ;
            selectSetData.data[i]["normalValue"] = formatNumber(selectSetData.data[i][lower]) + "～" + formatNumber(selectSetData.data[i][upper]);
          }
          // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
          selectSetData.data[i]["upper"] = checkValueUpper;
          selectSetData.data[i]["lower"] = checkValueLower;
        }

        //検査セット ソート処理
        let sortList = [];
        sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));
        selectSortSetData = [];
        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          for(let itemkey = 0; itemkey < selectSetData.data.length; itemkey++){
            //全項目対象時
            if (sortList[sortkey].code == selectSetData.data[itemkey].itemCd){
              selectSortSetData.splice(sortkey,0,selectSetData.data[itemkey]);
            }
          }
        }
      }

      for(let dispKey = 0; dispKey < selectSortSetData.length; dispKey++){
        //追加対象検査項目コードが既に存在する場合は追加しない
        if(dispData.some(
          item => item.itemCd == selectSortSetData[dispKey].itemCd
        )){
          //一致データあり
        }else{
          //一致データ無し
          dispData.push(selectSortSetData[dispKey]);
        }
      }

      await commit("setExamMainDataSource", dispData);
      await commit("setExamMainData", inputData);

    },

    /**
     * 検査項目全件挿入処理（ソート付）
     * examResultCd: 検査結果ID
     */
    async setExamAllSet({commit},selectData) {
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
      let selectSetData;
      let selectSortSetData = [];
      let sort;
      // 更新画面生成時：患者検査結果テーブルより生成
      try{
        selectSetData = await sendRequestGetMstExamItemListForExamClass(
          selectData.facilityCd,
          selectData.selectedPatId
        );
        sort = await sendRequestGetMstExamItemSort(selectData.facilityCd, selectData.selectedPatId);
      }catch(e){
        throw new Error("検査項目マスタデータ取得失敗", { cause: e });
      }

      //要注意：男女チェック時に施設設定マスタの性別指定なし時制御については未実装
      if(selectSetData != null){
        for(var i=0;i<selectSetData.data.length;i++){
          //正常範囲値（デフォルトは入力上下限）
          //let checkValueUpper = resExamItem.data[i].inputUpper;
          //let checkValueLower = resExamItem.data[i].inputLower;
          let checkValueUpper = null;
          let checkValueLower = null;
          let upper = null;
          let lower = null;
          //範囲の男女共通別取得：
          if(selectSetData.data[i]["normalValueClass"] == "0"){
            //共通パラメータ時
            upper = "upper";
            lower = "lower";
          }else if(selectData.patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_W) {
            //女性の場合
            upper = "normalValueUpperW";
            lower = "normalValueLowerW";
          }else if(selectData.patSex == PAT_PERSONAL_MAIN_COL_PAT_SEX_M){
            //男性その他の場合
            upper = "normalValueUpperM";
            lower = "normalValueLowerM";
          }else{
            //性別未設定(女性でも男性でもない)
            if(selectData.defaultSex == 1){
              // 性別未設定：男性数値使用
              upper = "normalValueUpperM";
              lower = "normalValueLowerM";
            }else if(selectData.defaultSex == 2){
              // 性別未設定：女性数値使用
              upper = "normalValueUpperW";
              lower = "normalValueLowerW";
            }
          }
          //値セット
          if(!selectSetData.data[i][lower] && !selectSetData.data[i][upper]
            && selectSetData.data[i][lower] !== 0  && selectSetData.data[i][upper] !== 0) {
            selectSetData.data[i]["normalValue"] = "";
          }else if(!selectSetData.data[i][lower] && selectSetData.data[i][lower] !== 0){
            // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc start
            checkValueUpper = formatNumber(selectSetData.data[i][upper]);
            selectSetData.data[i]["normalValue"] = "～" + formatNumber(selectSetData.data[i][upper]);
          }else if(!selectSetData.data[i][upper]&& selectSetData.data[i][upper] !== 0){
            checkValueLower = formatNumber(selectSetData.data[i][lower]);
            selectSetData.data[i]["normalValue"] = formatNumber(selectSetData.data[i][lower]) + "～";
          }else{
            checkValueUpper = formatNumber(selectSetData.data[i][upper]);
            checkValueLower = formatNumber(selectSetData.data[i][lower]);
            selectSetData.data[i]["normalValue"] = formatNumber(selectSetData.data[i][lower]) + "～" + formatNumber(selectSetData.data[i][upper]);
            // mod #8144 2023/05/23 正常範囲が表示されない項目もある ztc end
          }
          selectSetData.data[i]["upper"] = checkValueUpper;
          selectSetData.data[i]["lower"] = checkValueLower;
        }

        //検査セット ソート処理
        let sortList = [];
        sort.data.forEach(e => sortList = sortList.concat(e.orderSettings.items));
        selectSortSetData = [];
        for (let sortkey = 0; sortkey < sortList.length; sortkey++) {
          for(let itemkey = 0; itemkey < selectSetData.data.length; itemkey++){
            //全項目対象時
            if (sortList[sortkey].code == selectSetData.data[itemkey].itemCd){
              selectSortSetData.splice(sortkey,0,selectSetData.data[itemkey]);
            }
          }
        }
      }
      await commit("setExamMainDataSource", selectSortSetData);
      await commit("setExamMainData", selectSortSetData);
    },


     // モーダル表示時に
    setUserAccountInfo({ commit }, info) {
      // ログインユーザー情報をセット
      commit("setUserAccountInfo", { userAccountInfo: info });
    },
    // 抽出条件
    setModalCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setModalCondition", condition);
    },
    // 患者検査1オーダー
    setExamMainDataSource({commit}, condition){
      // 患者検査1オーダーセット
      commit("setExamMainDataSource", condition);
    },
    // 患者検査1オーダー(登録用)
    setExamMainData({commit}, condition){
      // 患者検査1オーダー（登録用）
      commit("setExamMainData", condition);
    },
    // 患者検査1オーダー(Column)
    setExamMainColumn({commit}, condition){
      // 患者検査1オーダーセット
      commit("setExamMainColumn", condition);
    },
    // 検査セット一覧セット
    setExamSetNameList({commit},data){
      commit("setExamSetNameList", data);
    },
    // 検査結果コード
    setExamMainCd({commit},condition){
      commit("setExamMainCd",condition);
    },
    // 最終更新日時
    setExamUpdate({commit},condition){
      commit("setExamUpdate",condition);
    },

    // 透析実績連動リスト
    setExamPatList({ commit }, select) {
      commit("setExamPatList", []);
      return sendRequestGetRstStartDateList(select.patId,select.facilityCd).then(response => {
        commit("setExamPatList", response.data);
        return Promise.resolve(response.data);
      });
    },

    // ストア情報初期化
    modalStoreReset({commit}){
      commit("setExamDivList",null);
      commit("setExamMainDataSource",null);
      commit("setExamMainData",null);
      commit("setExamMainColumn",null);
      commit("setModalState",null);
      commit("resetUserAccountInfo",null);
      commit("setModalCondition",null);
      commit("setExamSetNameList",null);
      commit("setExamPatList",null);
      commit("setExamMainCd",null);
    },

  },

  mutations: {
    // グリッドコンボボックス用スタッフ一覧
    // チェックリスト設定
    setExamDivList(state, data) {
      state.examDivList = data;
    },
    setExamMainDataSource(state, data) {
      state.examMainDataSource = data;
    },
    setExamMainData(state, data) {
      state.examMainData = data;
    },
    setExamMainColumn(state, data) {
      state.examMainColumn = data;
    },
    setModalState(state, data) {
      state.modalState = data;
    },
    setUserAccountInfo(state, payload) {
      state.userAccountInfo = payload.userAccountInfo;
    },
    resetUserAccountInfo(state, data) {
      state.userAccountInfo = data;
    },
    // 抽出条件
    setModalCondition(state, condition) {
      state.modalCondition = condition;
    },
    // 検査セット一覧
    setExamSetNameList(state, data){
      state.examSetNameList = data;
    },
    // 透析実績一覧
    setExamPatList(state,data){
      state.examPatList = data;
    },
    // 検査結果コード
    setExamMainCd(state,data){
      state.examMainCd = data;
    },
    // 最終更新日時
    setExamUpDate(state,data){
      state.examUpDate = data;
    },
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 start
    // sub画面開けるフラグ
    setIsOpenFlag(state, data){
      state.isOpen = data;
    },
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる V1.0B 房 end
  }
};
