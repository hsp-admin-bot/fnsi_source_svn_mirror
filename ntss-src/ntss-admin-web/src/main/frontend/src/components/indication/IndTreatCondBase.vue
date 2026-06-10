<script>
import { mapGetters,mapActions } from "vuex";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customInputTime from "@/components/common/custom-form-tags/CustomInputTime";
import customRadio from "@/components/common/custom-form-tags/CustomRadio";
import customInputTimeSpecial from "@/components/common/custom-form-tags/CustomInputTimeSpecial";
import customDivShowSelectedItemTreatCond from "@/components/common/custom-form-tags/CustomDivShowSelectedItemTreatCond";
//add #10150 piao start
import {CODES} from "@/constants/TreatmentRecord";
//add #10150 piao end
// add #10196 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import BigNumber from 'bignumber.js';
// add #10196 数値IFのスタイル全不正 linjunfeng end

export default {
  components: {
    "pop-over": MasterSelector,
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-input-time": customInputTime,
    "custom-radio": customRadio,
    "custom-input-time-special":customInputTimeSpecial,
    "show-selected-item": customDivShowSelectedItemTreatCond,
    // add #10196 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #10196 数値IFのスタイル全不正 linjunfeng end
  },

  props: {
    /**
     * @description 入力フィールドの初期値
     */
    value: {
      type: [String,Number],
      default: null
    },
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
    velue: {
      type: [String,Number],
      default: null
    },
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
    /**
     * @description 入力フィールドの編集値
     */
    // velue: {
    //   type: Number,
    //   default: null
    // },
//add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
    /**
     * @description マスタメンテナンス用入力フラグ
     */
    isMst: {
      type: Boolean,
      default: false
    },
//8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
    isIndication: {
      type: Boolean,
      default: false
    },
//8204 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
    /**
     * @description 薬剤・調製薬剤区分
     */
    medicineType: {
      // type: String,
      type: Number,
      default: null
    }
  },

  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        // mod FNSI-小数点の修正 楊 start
        isMedicineCdChg: false,
        // mod FNSI-小数点の修正 楊 end
        popoverContentSelected: {}
      },
      filterDataset: [],
      contentDataset: [],
      treatItemCd: null,
      displayInputValue: {
        initValue: this.value,
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
        //editValue: this.value
        editValue: this.velue ? this.velue : this.value,
        //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
        /* add by chamaojia 2023-04-20 [8537] 初回計算フラグの追加  --start */
        firstCalculateFlag : true
        /* add by chamaojia 2023-04-20 [8537] 初回計算フラグの追加  --end */
      },
      unit: null,
      // add FNSI-【8630】単位が表示されない対応 曲 start
      unitChangeFlag: false,
      // add FNSI-【8630】単位が表示されない対応 曲 end
      editedMedicineType: this.medicineType,
      // add FNSI-【1006】最新の改修対象一覧の667対応 韓 start
      conTreatTime: null,
     // add FNSI-【1006】最新の改修対象一覧の667対応 韓 end
      //add #10150 piao start
      ivOnlineDeviceModeList: [CODES.DEVICE_MODE.HD_HO.cd, CODES.DEVICE_MODE.ECUM_HO.cd, CODES.DEVICE_MODE.OHDF.cd, CODES.DEVICE_MODE.OHF.cd,CODES.DEVICE_MODE.IHDF.cd],
      //add #10150 piao end
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
      // 施設設定マスタ設定フラグ
      supplyLiquidSpeedFlg: false,
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end

      // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
      minValueLquid: 0
      // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    };
  },

  computed: {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("user", { userFacilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch" }),
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      editRecord: "getEditRecord",
      masterPhysicalName: "getMasterName",
    }),
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    ...mapGetters("pat-viewer-modal", ["getSettingIndData"]),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    inputValue() {
      let editedValue = this.popoverData.popoverContentSelected.value;
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      let editedType = this.popoverData.popoverContentSelected.type;
      // 抗凝固剤、透析液、補液
      const useMedicineMixList = ["15","19","25"];
      if (
        useMedicineMixList.includes(this.treatItemCd) &&
        editedValue !== null && typeof editedValue !== 'undefined'
      ) {
        //if (String(editedValue).match(/\$/)) {
        if (editedType == '2') {
          //editedValue = Number(editedValue.split("$")[0]);
          editedValue = Number(editedValue);
          // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
          // this.setMedicineType("2");
          this.setMedicineType(2);
        } else {
          // this.setMedicineType("1");
          this.setMedicineType(1);
        }
      } else {
        this.setMedicineType(null);
      }
      // mod FNSI-小数点の修正 楊 start
      // parsedValue = editedValue
      //   ? parseFloat(this.popoverData.popoverContentSelected.value)
      //   : parseFloat(this.displayInputValue.editValue);
      let parsedValue;
      // 抗凝固剤、透析液、補液の数量の小数点設定
      const useMedicineList = ["17","22","26","27","28"];
      //add #9973 fix Missing decimal places issue 20240122 ztc start
      const existDecimalDigitsByOne = ['18','20','23','33'];
      const existDecimalDigitsByTwo = ['4','24'];
      //add #9973 fix Missing decimal places issue 20240122 ztc end
      //add #10196 数値IFのスタイル全不正 linjunfeng 20240606 start
      const existInteger = ['14','16'];
      //add #10196 数値IFのスタイル全不正 linjunfeng 20240606 end
      if (useMedicineList.includes(this.treatItemCd) && this.decPoint) {
        parsedValue = editedValue
          ? parseFloat(this.popoverData.popoverContentSelected.value).toFixed(this.decPoint)
          : parseFloat(this.displayInputValue.editValue).toFixed(this.decPoint);
      //mod FNSI-5989 劉全航 start
      }else if(this.treatItemCd == "31"||this.treatItemCd == "32"){
        //mod #9973 fix Missing decimal places issue 20240122 ztc start
        // parsedValue = this.displayInputValue.editValue;
        parsedValue = parseFloat(this.displayInputValue.editValue).toFixed(1);
        //mod #9973 fix Missing decimal places issue 20240122 ztc end
      }
      //mod FNSI-5989 劉全航 end
      //add #9973 fix Missing decimal places issue 20240122 ztc start
      else if(existDecimalDigitsByOne.includes(this.treatItemCd)){
        parsedValue = editedValue
            ? parseFloat(this.popoverData.popoverContentSelected.value).toFixed(1)
            : parseFloat(this.displayInputValue.editValue).toFixed(1);
      }
      else if(existDecimalDigitsByTwo.includes(this.treatItemCd)){
        parsedValue = editedValue
            ? parseFloat(this.popoverData.popoverContentSelected.value).toFixed(2)
            : parseFloat(this.displayInputValue.editValue).toFixed(2);
      //add 10150 piao start
      } else if(this.treatItemCd === '19'){
        if(!this.ivOnlineDeviceModeList.includes(this.deviceMode)){
          parsedValue = editedValue ? this.popoverData.popoverContentSelected.value : this.displayInputValue.editValue
        }
      }
      //add 10150 piao end
      //add #9973 fix Missing decimal places issue 20240122 ztc end

      //add #10196 数値IFのスタイル全不正 linjunfeng 20240606 start
      else if(existInteger.includes(this.treatItemCd)){
        parsedValue = editedValue ? this.popoverData.popoverContentSelected.value : this.displayInputValue.editValue;
      }
      //add #10196 数値IFのスタイル全不正 linjunfeng 20240606 end

      else {
        parsedValue = editedValue
          ? parseFloat(this.popoverData.popoverContentSelected.value)
          : parseFloat(this.displayInputValue.editValue);
      }
      parsedValue = isNaN(parsedValue) ? null : parsedValue;

      // #9973 del by Zhou.tao fix decPoint value format Start
      // add 5669 xie start
      // if (parsedValue === null || parsedValue === '') {
      //   return parsedValue;
      // }

      // if (!isNaN(parsedValue)) {
      //   return parseFloat(parsedValue);
      // }
      // #9973 del by Zhou.tao fix decPoint value format End
      return parsedValue;
      // add 5669 xie end
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    facilityCd(){
      let facilityCd = this.userFacilityCd;
      if (this.isMst) {
        facilityCd = this.getFacilitySwitch
      }
      return facilityCd
    }
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },

  watch: {
    inputValue(data) {
      this.$emit("input", data);
      // mod FNSI-小数点の修正 楊 start
      if (!this.isMst) {
        const useMedicineList = ["17","22","26","27","28"];
        if (useMedicineList.includes(this.treatItemCd) && this.decPoint) {
          let componentDataList = this.$parent.$parent.componentData.filter(item => {
            return String(item.cd) === this.treatItemCd;
          });
          let rstDialysisState = componentDataList[0].fields.rstDialysisState;
          if (rstDialysisState === "0") {
            //mod FNSI-6643 劉全航 start
            //  this.displayInputValue.initValue = parseFloat(this.displayInputValue.initValue).toFixed(this.decPoint);
            //  this.displayInputValue.editValue = this.inputValue;
            // #10196 数値IFのスタイル全不正 linjunfeng start
            // if(this.displayInputValue.initValue != '0' ){ // mod #9973 value Number→文字列  shiyw
            if(this.displayInputValue.initValue != '0' && this.displayInputValue.initValue != null){ // mod #9973 value Number→文字列  shiyw
            // #10196 数値IFのスタイル全不正 linjunfeng end
              this.displayInputValue.initValue =
                //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
                //parseFloat(this.displayInputValue.initValue).toFixed(this.displayInputValue.initValue.toString().split('.')[1].length);
                parseFloat(this.displayInputValue.initValue)
                  .toFixed(this.displayInputValue.initValue.toString().indexOf('.') != -1
                    ? this.displayInputValue.initValue.toString().split('.')[1].length : 0);
              //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
            }
            //mod FNSI-6643 劉全航 end
          }
        }
        // add 10179 by kangjie 20240226 start
        this.popoverData.type = this.treatItemCd;
        // add 10179 by kangjie 20240226 end
      }
      // mod FNSI-小数点の修正 楊 end
    }
  },

  methods: {
    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    ...mapActions("master-maintenance", [
      "setEditRecord"
    ]),

    // add #7762 【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
    /**
     * @description マスター選択を表示
     */
    showPopover() {
      this.popoverData.popoverVisible = true;
    },

    /**
     * @description マスター選択を非表示
     */
    closePopover() {
      this.popoverData.popoverVisible = false;
    },

    /**
     * @description マスター選択から選択後のコールバック
     */
    // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
    async updateInput(data) {
    // mod #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
      if (this.$route.path === '/master-maintenance/list/record' && this.masterPhysicalName === 'mst_treatment_set') {
        // add #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 start
        const initIndCondInfo = JSON.parse(this.editRecord.indCondInfo)
        initIndCondInfo[5].value = data.value
        this.editRecord.indCondInfo = JSON.stringify(initIndCondInfo)
        await this.setEditRecord(this.editRecord)
        // add #7762【デグレ】治療方法セットマスタで設定した内容とは異なる内容で予定が作成される 付 end
      }

      this.popoverData.popoverContentSelected = data;
      //mod FNSI-4882 劉全航 start
      // this.displayInputValue.editValue = data.text || "未登録";
      this.displayInputValue.editValue = data.text || null;
      //mod FNSI-4882 劉全航 end
      // mod FNSI-小数点の修正 楊 start
      this.popoverData.isMedicineCdChg = true;
      // mod FNSI-小数点の修正 楊 end
    },
    //add 8681 ljx start
    /**
     * @description マスター選択から選択後のコールバック
     * @param data:選択された値　type：治療条件の項目区分　例：15　透析液
     */
    async updateInputNew(data,type) {
      if (this.$route.path === '/master-maintenance/list/record' && this.masterPhysicalName === 'mst_treatment_set') {
        const initIndCondInfo = JSON.parse(this.editRecord.indCondInfo)
        //選択された値を該当項目に設定
        if(initIndCondInfo[type]){
          initIndCondInfo[type].value = data.value
        }
        this.editRecord.indCondInfo = JSON.stringify(initIndCondInfo)
        await this.setEditRecord(this.editRecord)
      }

      this.popoverData.popoverContentSelected = data;
      this.displayInputValue.editValue = data.text || null;
      this.popoverData.isMedicineCdChg = true;
      // add 10179 by kangjie 20240226 start
      this.popoverData.type = type;
      // add 10179 by kangjie 20240226 end
    },
    //add 8681 ljx end

    /**
     * @description リクエスト用データ作成
     */
    createRequestData(structData) {
      // add 患者経過総合ビューア_治療条件編集：ord_main⇒「ind_cond_info」中的一些项目前后不一致 2023/06/08 kang start
      let updUserId = structData.updUser;
      let updUserFirstName = "";
      let updUserLastName = "";
      let idnUserId = structData.indUser;
      let idnUserFirstName = "";
      let idnUserLastName = "";

      structData.userOptions.find(item=> {
        if (item.user_id == updUserId){
          updUserFirstName = item.user_first_name;
          updUserLastName = item.user_last_name;
        }
        if (item.user_id == idnUserId){
          idnUserFirstName = item.user_first_name;
          idnUserLastName = item.user_last_name;
        }
      });
      // add 患者経過総合ビューア_治療条件編集：ord_main⇒「ind_cond_info」中的一些项目前后不一致 2023/06/08 kang end
      const indInfo = {
        [this.treatItemCd]: {
          // modify 10150_9664 by kangjie 20240912 start
          // value: this.inputValue,
          value: this.inputValue ==null? this.inputValue : this.inputValue.toString(),
          // modify 10150_9664 by kangjie 20240912 end
          value_name_1: this.displayInputValue.editValue,
          unit: this.unit,
          // mode 2023/06/28 kang start ies_6503
          // medicine_type: (null != this.editedMedicineType && undefined != this.editedMedicineType) ? this.editedMedicineType: null,
          medicine_type: (null != this.editedMedicineType && undefined != this.editedMedicineType) ?  Number(this.editedMedicineType): null,
          // mode 2023/06/28 kang end  ies_6503
          ind_user_id: structData.indUser,
          // modify 10150_9664 by kangjie 20240911 start
          // ind_user_last_name: idnUserFirstName,
          // ind_user_first_name: idnUserLastName,
          ind_user_last_name: idnUserLastName,
          ind_user_first_name: idnUserFirstName,
          // modify 10150_9664 by kangjie 20240911 end
          upd_user_id: structData.updUser,
          upd_user_last_name: updUserLastName,
          upd_user_first_name: updUserFirstName,
          // mdoe 2023/06/28 kang start ies_6503
          // input_class: "1", // 1: クライアントから登録、2: 連携から登録、3～: その他システムから登録
          input_class: 1,
          // mode 2023/06/28 kang end ies_6503
          is_editable: structData.editOnly ? "1": "0",
          // mode 患者経過総合ビューア_治療条件編集：ord_main⇒「ind_cond_info」中的一些项目前后不一致 2023/06/15 kang start
          // cop_order_no: 1,
          cop_order_no: null, //電子カルテからの予約オーダを登録する際に使用 ※「00001」→「1」にならないよう、文字列で管理
          // mode 患者経過総合ビューア_治療条件編集：ord_main⇒「ind_cond_info」中的一些项目前后不一致 2023/06/15 kang end
          // mod FNSI-小数点の修正 楊 start
          isAmountchg: this.displayInputValue.initValue == String(this.displayInputValue.editValue) && structData.editOnly,
          // mod FNSI-小数点の修正 楊 end
          // init_value: this.displayInputValue.initValue
          // mod #7118 2022/11/07 【デグレ】ダミースケジュール作成ロジック不正 dou start
          // init_value: this.treatItemCd === "2"||"25" ? this.velue : this.displayInputValue.initValue
          init_value: this.treatItemCd === "2" || this.treatItemCd === "25" ? this.velue : this.displayInputValue.initValue
          // mod #7118 2022/11/07 【デグレ】ダミースケジュール作成ロジック不正 dou end
        }
      };
      // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 start
      /* add by shiyw 2024-04-17 #10196 ord_mainのデータ定義の修正：ind_cond_info中仅15、19、25有字段 medicine_type --start */
      const excludeList = ["15", "19", "25"];
      if (indInfo[this.treatItemCd].medicine_type == null && !excludeList.includes(this.treatItemCd)) {
        // mod #12472 治療方法の変更で補液なし治療からオンライン補液あり治療に、「治療方法のみ」で変更するとpat_treatment_patternに欠損データが発生する。 関 end
        delete indInfo[this.treatItemCd].medicine_type;
      }
      /* add by shiyw 2024-04-17 #10196 ord_mainのデータ定義の修正：ind_cond_info中仅15、19、25有字段 medicine_type --end */
      return indInfo;
    },

    /**
     * 条件送信後の付加情報作成
     */
    createAddData() {
      const addInfo = {
        [this.treatItemCd]: {
          unit: this.unit,
          value_name_1: this.displayInputValue.editValue
        }
      };

      return addInfo;
    },

    // add #10196 数値IFのスタイル全不正 linjunfeng start
    isNumber(numVal) {
      // チェック条件パターン
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },
    // add #10196 数値IFのスタイル全不正 linjunfeng end

    /**
     * 変更箇所チェック
     * @description 変更があれば1、変更がなければ0を返す
     *              親側で変更箇所を集計する
     */
    checkEditCount() {
      if (
        // mod FNSI-【8630】単位が表示されない対応 曲 start
        // mod FNSI-小数点の修正 楊 start
        // this.displayInputValue.initValue === this.displayInputValue.editValue
        // this.displayInputValue.initValue == this.displayInputValue.editValue
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // (!this.unitChangeFlag) && this.displayInputValue.initValue == this.displayInputValue.editValue
        this.displayInputValue.initValue == this.displayInputValue.editValue || (this.isNumber(this.displayInputValue.initValue) && this.isNumber(this.displayInputValue.editValue) && BigNumber(this.displayInputValue.initValue).isEqualTo(BigNumber(this.displayInputValue.editValue)))
        // #10196 数値IFのスタイル全不正 linjunfeng end
        // mod FNSI-小数点の修正 楊 end
        // mod FNSI-【8630】単位が表示されない対応 曲 end
      ) {
        return 0;
      } else {
        return 1;
      }
    },

    /**
     * @description 選択される項目がマスタに存在するかチェック
     */
    checkMstDispStatus(primaryKeyName = null) {
      // DBのPKが定義されない OR 項目が未登録
      if (!primaryKeyName || !this.value) {
        return;
      }

      const mst = this.contentDataset.find(item => {
        return item[primaryKeyName] == this.value; // mod #9973 value Number→文字列  shiyw
      });

      if (mst && mst.isDisp === "0") {
        this.displayInputValue.initValue = "削除済み";
        this.displayInputValue.editValue = "削除済み";
      }
    },

    setMedicineType(value) {
      this.editedMedicineType = value;
    }
  }
};
</script>

<style scoped>
/* add 9664補液及び透析液仕様修正します yangqingzhe start */
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
 /* add 9664補液及び透析液仕様修正します yangqingzhe end */
/* アクションチャート内inputタグ */
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}

.action-condition-column {
  /* mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
  /* flex: 0 0 30%; */
  flex: 0 0 9%;
  /* mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
  max-width: 30%;
  white-space: normal;
  margin: auto;
}

.action-condition-input-label {
  width: 100px;
  font-size: 15px;
}

.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}

.action-condition-calculate-button {
  margin: 0px 0px 0px 5px;
  font-size: 13px;
  padding: 0px;
}

ons-row {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}

.action-condition-data-column >>> .time-span {
  min-width: fit-content;
  height: 2em;
  box-sizing: border-box;
}
.action-condition-data-column >>> input[type="number"] {
  min-width: 1.4em;
  height: fit-content !important;
}

/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
.ntss-custom-input-cond {
  height: 2em;
  font-size: inherit;
  width: auto;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  display: inline-flex;
}
/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
/*// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
::v-deep .com-basic-sub-btn {
    margin-left: 5px
  }
  ::v-deep .com-basic-sub-input { 
    margin-left: 10px;
    min-width: 13em;
    width: 100%;
    max-width: 28em;
    background-color: #f7f7f7;
  }
 /* // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
