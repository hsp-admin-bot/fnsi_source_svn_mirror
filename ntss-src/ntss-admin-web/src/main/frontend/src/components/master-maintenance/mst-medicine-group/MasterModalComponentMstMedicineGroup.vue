<template>
  <div>
    <div>
      <v-ons-row class="row-height">
        <v-ons-col class="item-title">薬剤グループ名</v-ons-col>
        <v-ons-col class="item-data list-input">
          <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start-->
          <!-- <input
            v-model="editRecord.name"
            class="custom-input-number drug-group-name"
            style="width: 30%;vertical-align: inherit; margin-bottom:4px;"
            type="text"
            @change="updateDown()"
          /> -->
          <input
            v-model="editRecord.name"
            class="custom-input-number drug-group-name"
            style="width: 30%;vertical-align: inherit; margin-bottom:4px;"
            type="text"
          />
          <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end-->
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="frame">
        <v-ons-col class="item-title">
          <v-ons-col>グループ情報</v-ons-col>
          <v-ons-col>
            <v-ons-button class="item-button btn3-normal" @click="addMedicineSet()">
              追加
            </v-ons-button>
          </v-ons-col>
        </v-ons-col>
        <v-ons-col class="item-data data-table print-height-auto">
          <div class="detail-list">
            <table class="ntss-list sticky_table" style="position: relative;table-layout: fixed;">
              <thead display="block">
              <tr>
                <th class="ntss-list-header-th-sticky color-header list-header-item-medi-flg">薬剤区分</th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-class">薬剤分類</th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-medi-name">薬剤名</th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-medi-unit">指示単位</th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-medi-unit-step">換算値<v-ons-icon style="margin-left: 5px;" icon="fa-question-circle" @click="showPopOver($event)"></v-ons-icon>
                </th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-medi-group-unit">単位</th>
                <th class="ntss-list-header-th-sticky color-header list-header-item-delete"/>
              </tr>
              </thead>
              <tr v-for="(column, index) in dispArr" :key="index">
                <!--薬剤区分 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start -->
                  <!-- {{ getMediFlg(dispArr[dispLength - index].mediFlg) }} -->
                  {{ getMediFlg(dispArr[index].mediFlg) }}
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end -->
                </td>
                <!--薬剤分類 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start -->
                  <!-- {{ getMedicineClass(dispArr[dispLength - index].classCd) }} -->
                  {{ getMedicineClass(dispArr[index].classCd) }}
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end -->
                </td>
                <!--薬剤名 -->
                <td class="ntss-list-body-td ntss-list-body-td-background medi-name-wrapper">
                  <custom-input
                    class="medi-name"
                    :value="dispArr[index].cd"
                    :display-string="getMedicineName(dispArr[index].cd.editValue, dispArr[index].mediFlg)"
                    disabled
                  />
                  <v-ons-button
                    :ref="index"
                    class="select-button btn3-normal"
                    @click="selectMedicine(index, dispArr[index])"
                  >
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end -->
                    選択
                  </v-ons-button>
                </td>
                <!-- 指示単位 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start -->
                  <!-- {{
                    getMedicineUnit(
                      dispArr[dispLength - index].cd.editValue,
                      dispArr[dispLength - index].mediFlg)
                  }} -->
                  {{
                    getMedicineUnit(
                      dispArr[index].cd.editValue,
                      dispArr[index].mediFlg)
                  }}
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end -->
                </td>
                <!--換算値 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start -->
                  <!-- <custom-input-number
                    :value="dispArr[dispLength - index].conVal"
                    style="width:100%"
                    :digits="8"
                    :decimal-digits="getMediUnitStep(dispArr[dispLength - index])"
                    :min-value="0"
                    :max-value="99999999.999999999"
                    :initial-value-lock="true"
                    @change="changeButton"
                  /> -->
                  <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
                  <!-- <custom-input-number
                    :value="dispArr[index].conVal"
                    style="width:100%; min-width: 100px;"
                    :digits="8"
                    :decimal-digits="getMediUnitStep(dispArr[index])"
                    :min-value="0"
                    :max-value="99999999.999999999"
                    :initial-value-lock="true"
                    @change="changeButton"
                  /> -->
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start-->
                  <!-- <custom-input-number
                    :value="dispArr[index].conVal"
                    style="width:100%; min-width: 100px;"
                    :digits="8"
                    :decimal-digits="getMediUnitStep(dispArr[index])"
                    :min-value="0"
                    :max-value="99999999.999999999"
                    :initial-value-lock="true"
                    @change="changeDown(index)"
                    @wheel="changeDown(index)"
                  /> -->
                  <custom-input-number
                    :value="dispArr[index].conVal"
                    style="width:100%; min-width: 100px;"
                    :digits="8"
                    :decimal-digits="getMediUnitStep(dispArr[index])"
                    :min-value="0"
                    :max-value="99999999.999999999"
                    :initial-value-lock="true"
                  />
                  <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end-->
                  <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
                  <!-- mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end -->
                </td>
                <!-- 単位 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  {{
                    editRecord.medicineGroupUnit
                  }}
                </td>
                <!-- 削除 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <button class="ntss-btn-outset button-delete" @click="delMedicineSet(index)">
                    <v-ons-icon icon="fa-trash"/>
                  </button>
                </td>
              </tr>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <!-- 薬剤選択ボタンポップオーバー -->
    <pop-over
      v-bind="popParam"
      :target-position-element="popoverTargetElement(selectedIndex)"
      @popover-return="selectedMedi($event, selectedIndex)"
      @popover-close="closePopover(popParam)"
    />
    <v-ons-popover cancelable
                   :visible.sync="userMenuPopoverVisible"
                   :target="userMenuPopoverTarget"
                   :cover-target="false"
                   :direction="userMenuPopoverDirection"
                   :class="fontSizeSet"
    >
      <p id="popOverMessage" style="margin: 10px;">テスト</p>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
import { showPopover, closePopover } from "@/functions/PopoverFunctions";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import moment from "moment";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import PopoverMixin from "@/components/PopoverMixin";
import {EventBus} from "@/eventBus";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
import cloneDeep from "lodash/cloneDeep";
import isEqualWith from "lodash/isEqualWith";
// mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end

// 薬剤区分
const medi_cate = {
  normal: {
    VALUE: "0",
    TEXT: "通常"
  },
  set: {
    VALUE: "1",
    TEXT: "セット薬剤"
  },
  mix: {
    VALUE: "2",
    TEXT: "調製薬剤"
  }
};

export default {
  name: "MstMedicineGroup",
  mixins: [PopoverMixin],
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-checkbox": customCheckbox,
    "pop-over": MasterSelector
  },
  props: ["value"],
  data() {
    return {
      regMediInfo: {
        medicineGroupName: "",
        regInfoJsonStr: "",
        regInfoJsonArr: [], // 内部処理用
        regInfoArrCustom: [], // 画面表示用,
        currItem: {}
      },
      //薬剤マスタ
      mstMedicine: [],
      initName:"",
      //薬剤分類マスタ
      mstMediClass: null,
      // セット薬剤
      mstMedicineSet: null,
      // 調製薬剤マスタ
      mstMedicineMix: [],
      //薬剤選択ポップオーバーのパラメータ
      popParam: {
        popoverVisible: false, //表示非表示
        popoverDisplayDirection: "down", //出現位置
        popoverTitleHeader: "薬剤", //タイトル
        popoverFilter: [], //抽出条件
        popoverContentLabel: "薬剤名", //選択する項目一覧のタイトル
        popoverContentDataset: [], //選択する項目一覧
        popoverContentSelected: {}, //選択した項目
        hasUnregisteredOption: false //「未登録」選択の有無
      },
      // 選択されたボタン位置
      selectedIndex: null,
      addFlg: false,
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'down',
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
      regMediInfoDefault:null,
      regMediInfoNew:null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", {
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    //表示用パラメータの変数名を短く変換
    dispArr() {
      return this.regMediInfo.regInfoArrCustom;
    },
    //表示用パラメータのリスト番号を短く変換(ここからindex番号を引くと表示順になる)
    dispLength() {
      return this.regMediInfo.regInfoArrCustom.length - 1;
    }
  },

  watch: {
    dispArr: {
      handler() {
        //セット情報を変更した際、ストアに書き込みを行う
        this.onSetInfoChange();
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
    "editRecord.name" :{
      handler(val){
        if(this.regMediInfoNew){
          EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.initName) && 
         isEqualWith(JSON.stringify(this.regMediInfoNew.regInfoJsonArr),JSON.stringify(this.regMediInfoDefault.regInfoJsonArr)))
        } else {
          EventBus.$emit("mstHolidayRegistered",isEqualWith(val,this.initName))
        }
      },
      deep:true
    },
    regMediInfo :{
      handler(val) {
        this.regMediInfoNew = val;
        EventBus.$emit("mstHolidayRegistered",isEqualWith(this.editRecord.name,this.initName) 
                && isEqualWith(JSON.stringify(val.regInfoJsonArr),JSON.stringify(this.regMediInfoDefault.regInfoJsonArr)) )
      },
      deep:true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
    windowHeight: {
      handler() {
        this.calculateDataListHeight();
      }
    },
    windowWidth: {
      handler() {
        this.calculateDataListHeight();
      }
    },
    getFontSize: {
      handler() {
        this.calculateDataListHeight();
      }
    }
  },

  async created() {
    this.setLoadingScreenVisible(true);
      //施設コードを抽出条件に追加
      const requestParam = {
        facilityCd: this.getFacilitySwitch
      };
      // add FNSI-修正 マスタ削除の対応 Du start
      const [
        // 薬剤マスタ（削除済のデータも含む）
        responseMstMedicineData,
        responseMstMedicineClassData,
        responseMstMedicineMixData,
        // mstMedicineSetRes,
        mstMedicineSetRes,
      ] = await Promise.all([
        // 薬剤マスタ
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
        // 薬剤分類マスタ
        ApiHelper.get("/mstInfo/mstMedicineClassIncludeDeleted", requestParam),
        // 調製薬剤マスタ
        ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", requestParam),
        // セット薬剤
        // ApiHelper.get("/mstInfo/mstMedicineSet", requestParam),
        ApiHelper.get(`/master_maintenance/mst_medicine_set/data/${this.getFacilitySwitch}`),
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MasterModalComponentMstMedicineGroup.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });
      this.mstMedicineSet = mstMedicineSetRes.data.localDataSource.data.map((item) =>{
          if (item.isDisp === "0") {
            item.name = MASTER_DELETE_DISPLAY.DELETED + item.name;
          }
          return item;
        }
      );
      this.mstMediClass = responseMstMedicineClassData.data.map((item) =>{
          if (item.isDisp === "0") {
            item.className = MASTER_DELETE_DISPLAY.DELETED + item.className;
          }
          return item;
        }
      )
      this.mstMedicine = responseMstMedicineData.data.map((item) =>{
          if (item.isDisp === "0") {
            item.medicineName = MASTER_DELETE_DISPLAY.DELETED + item.medicineName;
          }
          return item;
        }
      )
      this.mstMedicineMix = responseMstMedicineMixData.data.map((item) =>{
          if (item.isDisp === "0") {
            item.medicineMixName = MASTER_DELETE_DISPLAY.DELETED + item.medicineMixName;
          }
          return item;
        }
      )
      //add FNSI-修正 マスタ削除の対応 Du  end
    this.initName = this.editRecord.name;
    this.calculateDataListHeight();
  },

  mounted() {
    // 内部処理用ローカル配列に、入力項目をコピー
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "regMedicineInfo") {
        this.regMediInfo.regInfoJsonStr = this.getValueByField(
          this.columnDefinition[num].field
        );
        // modify start #9783
        if (this.regMediInfo.regInfoJsonStr?.length) {
          // セット情報はJSONなので、配列に置換
          this.regMediInfo.regInfoJsonArr = JSON.parse(
            this.regMediInfo.regInfoJsonStr
          );
        }
        // modify end #9783
      }
    }

    // 表示用ローカル配列に、入力項目をコピー
    for (const i in this.regMediInfo.regInfoJsonArr) {
      this.dispArr.splice(i, 1, {
        cd: {
          initValue: this.regMediInfo.regInfoJsonArr[i].cd,
          editValue: this.regMediInfo.regInfoJsonArr[i].cd
        },
        update: {
          initValue: this.regMediInfo.regInfoJsonArr[i].update,
          editValue: this.regMediInfo.regInfoJsonArr[i].update
        },
        mediFlg: this.regMediInfo.regInfoJsonArr[i].mediFlg,
        classCd: this.regMediInfo.regInfoJsonArr[i].classCd,
        conVal: {
          initValue: this.regMediInfo.regInfoJsonArr[i].conVal,
          editValue: this.regMediInfo.regInfoJsonArr[i].conVal
        },
        del: {
          initValue: "0",
          editValue: "0"
        }
      });
    }
    this.$nextTick(() => {
      this.calculateDataListHeight();
    })
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
    this.regMediInfoDefault = cloneDeep(this.regMediInfo);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),

    getValueByField(field) {
      return this.editRecord[field];
    },
    //[確認]ボタンの状態の変更をトリガーします
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
    // updateCheckDeleteDropDown(e){
    //    console.log(e.target.value);
    //    if (e.target.value == "1") {
    //      this.changeButton();
    //    }else if(e.target.value == "0"){
    //      EventBus.$emit("mstHolidayRegistered", true);
    //    }
    // },
    // updateDown(){
    //    if (this.editRecord.name!==this.initName) {
    //      this.changeButton();
    //    }else{
    //      EventBus.$emit("mstHolidayRegistered", true);
    //    }
    // },
    // changeDown(index){
    //   console.log(this.dispArr[index].conVal.editValue);
    //   console.log(this.dispArr[index].conVal.initValue);
    //       if (this.dispArr[index].conVal.editValue!=this.dispArr[index].conVal.initValue) {
    //         this.changeButton();
    //       }else{
    //         EventBus.$emit("mstHolidayRegistered", true);
    //       }
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },

    /**
     * @description 薬剤用ポップオーバーを表示
     */
    selectMedicine(index, currItem) {
      this.currItem = currItem;

      //選択したボタンの位置を格納
      this.selectedIndex = index;

      //絞り込み条件を作成(薬剤分類)
      //薬剤分類マスタから分類名称と分類コード一覧を保持したリストを作成
      const mediClassList = this.mstMediClass.map(item => {
        return {
          text: item.className, //分類名称
          value: item.classCd //分類コード
        };
      });
      //リストに全選択の項目を追加
      mediClassList.unshift({ text: "すべて", value: 0 });

      //絞り込み条件(薬剤区分・薬剤分類)をパラメータに設定
      this.popParam.popoverFilter = [
        {
          //薬剤区分の絞り込み条件を追加
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: medi_cate.normal.TEXT, value: medi_cate.normal.VALUE },
            {
              text: medi_cate.set.TEXT,
              value: medi_cate.set.VALUE
            },
            { text: medi_cate.mix.TEXT, value: medi_cate.mix.VALUE }
          ]
        },
        {
          //薬剤分類の絞り込み条件を追加
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: mediClassList
        }
      ];

      //薬剤名一覧を作成
      //薬剤マスタの薬剤名称と薬剤コードに薬剤区分と薬剤分類を追加したリストを作成
      // add FNSI-修正 マスタ削除の対応 Du start
      const mediList = this.mstMedicine.map(item => {
        return {
          value: item.medicineCd, //薬剤コード
          fnValue: {
            薬剤区分: medi_cate.normal.VALUE, // 通常
            薬剤分類: item.classCd
          },
          text: item.medicineName, //薬剤名称,
          category: medi_cate.normal.VALUE,
          setInfo: null,
          isDisp: "1"
        };
      });

      const mediSetList = this.mstMedicineSet.map(item => {
        return {
          value: "MEDICINE_SET".concat(item.code), //薬剤セットコード
          fnValue: {
            薬剤区分: medi_cate.set.VALUE, // セット薬剤
            薬剤分類: ""
          },
          text: item.name, //薬剤セット名,
          category: medi_cate.set.VALUE,
          setInfo: item.setInfo,
          isDisp: "1"
        };
      });

      const mediMixList = this.mstMedicineMix.map(item => {
        return {
          // 薬剤マスタcdと区別するため、文字列へ変換
          value: `${item.medicineMixCd}$`,
          fnValue: {
            薬剤区分: medi_cate.mix.VALUE,
            薬剤分類: item.classCd
          },
          text: item.medicineMixName, //調製薬剤名称
          category: medi_cate.mix.VALUE,
          setinfo: null,
          isDisp: "1"
        };
      });

      //リストをパラメータに格納
      this.popParam.popoverContentDataset = [...mediList, ...mediMixList, ...mediSetList];
      this.popParam.popoverContentDataset = this.popParam.popoverContentDataset.filter(item => {
        return item.isDisp === "1";
      });
      // add FNSI-修正 マスタ削除の対応 Du end
      const mediCd = currItem.cd.editValue;
      const mediClass = currItem.mediFlg;
      const findSelectedMedicine = (arr, cd) => arr.find(i => i.value === cd);
      const selectedItem =
        mediClass === "0"
          ? findSelectedMedicine(mediList, mediCd)
          : mediClass === "1"
            ? findSelectedMedicine(mediSetList, "MEDICINE_SET".concat(mediCd))
            : findSelectedMedicine(mediMixList, `${mediCd}$`);
      this.popParam.popoverContentSelected = selectedItem || {};

      //ポップオーバー表示
      showPopover(this.popParam);
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
    },

    /**
     * @description 薬剤選択ボタン押下時のポップオーバー表示位置を取得
     * @param ポップオーバー表示位置
     */
    popoverTargetElement(index) {
      //ポップオーバーの表示位置を取得(薬剤選択ボタン押下時はそのボタンの位置、それ以外はnull)
      const position = index === null ? null : this.$refs[index][0];
      return position;
    },

    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedMedi(event, index) {
      //選択した薬剤名称とその分類を表示用・保存用パラメータに格納
      this.mediChange(event, index);
      //選択したボタンの場所データをリセット
      this.selectedIndex = null;
      this.addFlg = false;
    },

    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closePopover,

    // セット情報、行追加
    addMedicineSet() {
      this.addFlg = true;

      this.regMediInfo.regInfoJsonArr.push({
        cd: "", // 薬剤コード
        update: "", // 薬剤コード更新日時
        mediFlg: "", // 薬剤区分
        classCd: "", // 薬剤分類
        conVal: 0, // 換算値
        del: "0" // 削除フラグ
      });
      this.dispArr.push({
        cd: { initValue: "", editValue: "" },
        mediFlg: "",
        update: { initValue: "", editValue: "" },
        classCd: "",
        conVal: { initValue: 0, editValue: 0 },
        del: { initValue: "0", editValue: "0" }
      });
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
      // this.changeButton();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end

      // 最後までスクロールする
      this.$nextTick(() => {
        const ele = document.getElementsByClassName("data-table")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
    },

    /**
     * @description セット情報、削除ボタン押下時の行削除処理
     */
    delMedicineSet(num) {
      //保存用パラメータから削除
      this.regMediInfo.regInfoJsonArr.splice(num, 1);
      //表示用パラメータから削除
      this.dispArr.splice(num, 1);
    },

    // セット情報変更
    onSetInfoChange() {
      for (const i in this.regMediInfo.regInfoJsonArr) {
        // 薬剤コード
        this.regMediInfo.regInfoJsonArr[i].cd = this.dispArr[i].cd.editValue;

        // 薬剤区分
        this.regMediInfo.regInfoJsonArr[i].mediFlg = this.dispArr[i].mediFlg;

        //薬剤分類
        this.regMediInfo.regInfoJsonArr[i].classCd = this.dispArr[i].classCd;

        // 換算値
        this.regMediInfo.regInfoJsonArr[i].conVal = this.dispArr[
          i
        ].conVal.editValue;

        // 更新日時
        this.regMediInfo.regInfoJsonArr[i].update = this.dispArr[
          i
        ].update.editValue;
      }

      //保存用パラメータをコピー
      const saveArr = Array.from(this.regMediInfo.regInfoJsonArr);

      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "regMedicineInfo") {
          this.regMediInfo.regInfoJsonStr = JSON.stringify(saveArr);
          this.updateEditRecord(
            "regMedicineInfo",
            this.regMediInfo.regInfoJsonStr
          );
        }
      }
    },

    /**
     * 入力データの検証チェック
     */
    validateData() {
      // 単位
      let selectedCheckFlg = true;
      let message = "";
      if (this.regMediInfo.regInfoJsonArr.length > 0) {
        for (let i = 0; i < this.regMediInfo.regInfoJsonArr.length; i++) {
          if (this.regMediInfo.regInfoJsonArr[i].cd == "") {
            selectedCheckFlg = false;
          }
        }
        if (!selectedCheckFlg) {
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message = "薬剤をご選択ください。";
          message = messageFormat(DIALOG_MESSAGES[12000125].message);
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        }
        if (message != "") {
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "",
            title: DIALOG_MESSAGES[12000125].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message
          });
          return false;
        }
      }
      return true;
    },

    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      return this.validateData();
    },

    // セット情報の薬剤が変更された際、薬剤名称と薬剤分類を変更する処理
    mediChange(event, index) {
      if (event) {
        if (event.category == medi_cate.normal.VALUE) {
          this.doSelectMedicine(event, index);
        } else if (event.category == medi_cate.set.VALUE) {
          this.doSelectMedicineSet(event, index);
        }else if(event.category == medi_cate.mix.VALUE){
          this.doSelectMedicineMix(event, index);
        }
        //add 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start
        this.dispArr.sort((a, b) => {
          let indexA;
          for (indexA = 0; indexA < this.popParam.popoverContentDataset.length; indexA++) {
            if (this.popParam.popoverContentDataset[indexA].value.toString().replace("MEDICINE_SET", "").replace("$", "") === a.cd.editValue.toString()
             && this.popParam.popoverContentDataset[indexA].fnValue.薬剤区分.toString() === a.mediFlg.toString()) break;
          }
          let indexB;
          for (indexB = 0; indexB < this.popParam.popoverContentDataset.length; indexB++) {
            if (this.popParam.popoverContentDataset[indexB].value.toString().replace("MEDICINE_SET", "").replace("$", "") === b.cd.editValue.toString()
            && this.popParam.popoverContentDataset[indexB].fnValue.薬剤区分.toString() === b.mediFlg.toString()) break;
          }
          if (indexA > indexB) return 1;
          if (indexB > indexA) return -1;
          return 0;
        })
        //add 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end
      }
    },

    /**
     * @description
     * @param
     */
    doSelectMedicine(event, index) {
      let existFlg = false;
      for (let i = 0; i < this.dispArr.length; i++) {
        if (event.value == this.dispArr[i].cd.editValue
          && this.dispArr[i].mediFlg == medi_cate.normal.VALUE) {
          // 薬剤コードが一致かつ対象の一覧の薬剤区分が通常
          existFlg = true;
        }
      }
      if (!existFlg) {
        //変更対象となる表示情報のリスト番号を作成
        //mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start
        //const arrLength = this.dispLength - index;
        const arrLength = index;
        //mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end
        //選択した薬剤のコードをリストに格納
        this.dispArr[arrLength].cd.editValue = event.value;

        //選択した薬剤の薬剤分類をリストに格納
        this.dispArr[arrLength].classCd = event.fnValue.薬剤分類;

        // 薬剤区分
        this.dispArr[arrLength].mediFlg = medi_cate.normal.VALUE;

        // 更新日時
        this.dispArr[arrLength].update.editValue = moment().format(
          "YYYY-MM-DD HH:mm:ss"
        );
      }
    },

    /**
     * @description
     * @param
     */
    doSelectMedicineMix(event, index) {
      // 変換していた調製薬剤コードを薬剤コードに変換
      let medicineCd = Number(event.value.split("$")[0]);

      let existFlg = false;
      for (let i = 0; i < this.dispArr.length; i++) {
        if (medicineCd == this.dispArr[i].cd.editValue
          && this.dispArr[i].mediFlg == medi_cate.mix.VALUE) {
          existFlg = true;
        }
      }
      if (!existFlg) {
        //変更対象となる表示情報のリスト番号を作成
        //mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　start
        //const arrLength = this.dispLength - index;
        const arrLength = index;
        //mod 7848 【デグレ】コンバートした薬効換算マスタの詳細が正しく表示されない 周安寧　end

        //選択した薬剤のコードをリストに格納
        this.dispArr[arrLength].cd.editValue = medicineCd;

        //選択した薬剤の薬剤分類をリストに格納
        this.dispArr[arrLength].classCd = event.fnValue.薬剤分類;

        // 薬剤区分
        this.dispArr[arrLength].mediFlg = medi_cate.mix.VALUE;

        // 更新日時
        this.dispArr[arrLength].update.editValue = moment().format(
          "YYYY-MM-DD HH:mm:ss"
        );
      }
    },

    /**
     * @description
     * @param
     */
    doSelectMedicineSet(event) {
      let updateTime = moment().format("YYYY-MM-DD HH:mm:ss");

      if (this.addFlg) {
        this.regMediInfo.regInfoJsonArr.pop();
        this.dispArr.pop();
        this.addFlg = false;
      }

      // セット情報
      if (event.setInfo) {
        let setInfoArr = JSON.parse(event.setInfo);
        // 選択ボタンを押した行の削除有無処理
        this.removeNotExist(setInfoArr, this.currItem.cd.editValue, this.currItem.mediFlg);

        // 取得したセットJSONでループ
        for(let i = 0; i < setInfoArr.length;i++){
          // 1.セットデータ対応薬剤/調製薬剤マスタ取得
          let existFlg = false;
          let mstData = this.mstMedicine;
          let cdKey = "medicineCd";
          let selMediFlg = medi_cate.normal.VALUE;
          if (setInfoArr[i].class === "2") {
            // 調製薬剤なら
            mstData = this.mstMedicineMix;
            cdKey = "medicineMixCd";
            selMediFlg = medi_cate.mix.VALUE;
          }
          const medicineInfo = mstData.find(mst => mst[cdKey] === setInfoArr[i].cd);

          // 2.対応マスタ存在チェック
          if(!medicineInfo){
            continue;
          }

          // 3.現画面表示データと一致するものは追加しない
          for(let j = 0; j < this.dispArr.length; j++){
            if(setInfoArr[i].cd == this.dispArr[j].cd.editValue &&
              (setInfoArr[i].class == "1" && this.dispArr[j].mediFlg == medi_cate.normal.VALUE
              || setInfoArr[i].class == "2" && this.dispArr[j].mediFlg == medi_cate.mix.VALUE )
              ) {
              // cdが一致かつ薬剤同士、調製薬剤同士の場合
              existFlg = true;
              break;
            }
          }
          if (!existFlg) {
            // セーブ
            this.regMediInfo.regInfoJsonArr.push({
              cd: setInfoArr[i].cd,                   // 薬剤コード
              update: updateTime,                     // 薬剤コード更新日時
              mediFlg: selMediFlg,                    // 薬剤区分
              classCd: medicineInfo.classCd,          // 薬剤分類
              conVal: 0,                              // 換算値
              del: "0"                                // 削除フラグ
            });
            this.dispArr.push({
              cd: { initValue: "", editValue: setInfoArr[i].cd },
              mediFlg: selMediFlg,
              update: { initValue: "", editValue: updateTime },
              classCd: medicineInfo.classCd,
              conVal: { initValue: 0, editValue: 0 },
              del: { initValue: "0", editValue: "0" }
            });
          }
        }
      }
    },

    /**
     * @description 選択ボタンを押した行を残すか削除するかのチェック制御
     * @param arr json形式で取得したセットデータ内の薬剤一覧
     * @param value 選択ボタンを押した箇所の現在薬剤コード
     * @param mediFlg 選択ボタンを押した箇所の薬剤区分
     */
    removeNotExist(arr, value, mediFlg) {
      let checkFlg = false;
      arr.forEach(e => {
        if(e.cd == value &&
          (e.class == "1" && mediFlg == medi_cate.normal.VALUE
          || e.class == "2" && mediFlg == medi_cate.mix.VALUE )
        ) {
          // cdが一致かつ薬剤同士、調製薬剤同士の場合
          checkFlg = true;
        }
      });

      if(!checkFlg) {
        //保存用パラメータから削除
        this.regMediInfo.regInfoJsonArr.forEach((e, index) => {
          if(e.cd == value && e.mediFlg == mediFlg) {
            this.regMediInfo.regInfoJsonArr.splice(index, 1);
          }
        });

        //表示用パラメータから削除
        this.dispArr.forEach((e, index) => {
          if(e.cd.editValue == value && e.mediFlg == mediFlg) {
            this.dispArr.splice(index, 1);
          }
        });
      }
    },

    /**
     * @description 薬剤コードを薬剤名称に変換する処理
     * @param 画面上に表示する薬剤のコード
     */
    getMedicineName(cd,medicineType) {
      // 薬剤区分ごとに薬剤マスタ／調製薬剤マスタから薬剤名称を取得する
      if(medicineType == medi_cate.normal.VALUE){
        //薬剤
        if (!this.mstMedicine) {
          return "";
        }
        const medicine = this.mstMedicine.find(medi => medi.medicineCd === cd);
        return medicine ? medicine.medicineName : "";
      }else if(medicineType == medi_cate.mix.VALUE){
        //調製薬剤
        if (!this.mstMedicineMix) {
          return "";
        }
        const medicine = this.mstMedicineMix.find(medi => medi.medicineMixCd === cd);
        return medicine ? medicine.medicineMixName : "";
      }
    },

    getMedicineUnit(cd,medicineType) {
      // 薬剤区分ごとに薬剤マスタ／調製薬剤マスタから薬剤単位を取得する
      if(medicineType == medi_cate.normal.VALUE){
        //薬剤
        if (!this.mstMedicine) {
          return "";
        }
        const medicine = this.mstMedicine.find(medi => medi.medicineCd === cd);
        return medicine ? medicine.unit : "";
      }else if(medicineType == medi_cate.mix.VALUE){
        //調製薬剤
        if (!this.mstMedicineMix) {
          return "";
        }
        const medicine = this.mstMedicineMix.find(medi => medi.medicineMixCd === cd);
        return medicine ? medicine.unit : "";
      }
    },

    /**
     * @description 薬剤コードに対応する薬剤分類を返す処理
     * @param 画面上に表示する薬剤分類
     */
    getMediFlg(index) {
      switch (index) {
        case medi_cate.normal.VALUE:
          return medi_cate.normal.TEXT;
        case medi_cate.set.VALUE:
          return medi_cate.set.TEXT;
        case medi_cate.mix.VALUE:
          return medi_cate.mix.TEXT;
        default:
          return "";
      }
    },

    /**
     * @description 薬剤分類に対応する薬剤分類を返す処理
     * @param 画面上に表示する薬剤分類
     */
    getMedicineClass(classCd) {
      if (!this.mstMediClass) {
        return "";
      }

      const mediClass = this.mstMediClass.find(
        medi => medi.classCd === classCd
      );
      return mediClass ? mediClass.className : "";
    },

    /**
     * @description 薬剤コードを薬剤数量のステップ数に変換する処理
     * @param 画面上に表示する薬剤の単位
     */
    getMediUnitStep(data){
      let decPoint = null;
      let mstData = this.mstMedicine;
      if (data.mediFlg == medi_cate.mix.VALUE) {
        // 調製薬剤なら
        mstData = this.mstMedicineMix;
      }
      //薬剤マスタが取得出来ているなら変換を行う
      if (mstData.length > 0) {
        for (const item of mstData) {
          //薬剤マスタの薬剤コードと画面上の薬剤コードが同じ薬剤の名称を取得
          if (item.medicineCd === data.cd.editValue || item.medicineMixCd === data.cd.editValue) {
            decPoint = item.unitDecimalPoint;
            break;
          }
        }
      }
      decPoint = parseInt(decPoint);
      if(isNaN(decPoint)){
        decPoint = 0;
      }
      return decPoint;
    },

    /**
     * @description プロンプト
     */
    showPopOver(event) {
      let pop = document.getElementById("popOverMessage");
      // add 全マスタメッセージ調整 王 start
      // pop.innerText = "指示数量1あたりの数量を入れる。";
      pop.innerText = DIALOG_MESSAGES[12000067].message;
      // add 全マスタメッセージ調整 王 end
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    /**
     * @description データリストの高さを計算します
     */
    calculateDataListHeight(){
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'clientHeight')" 横展開2 linjunfeng start
      // let rowHeight = document.getElementsByClassName("row-height")[0].clientHeight;
      // let totalHeight = document.getElementsByClassName("modal-container")[0].clientHeight;
      // let topHeight = document.getElementsByClassName("toolbar")[0].clientHeight;
      // let bottomHeight = document.getElementsByClassName("modal-footer")[0].clientHeight;
      let rowHeight = document.getElementsByClassName("row-height")[0] ? document.getElementsByClassName("row-height")[0].clientHeight : 0;
      let totalHeight = document.getElementsByClassName("modal-container")[0] ? document.getElementsByClassName("modal-container")[0].clientHeight : 0;
      let topHeight = document.getElementsByClassName("toolbar")[0] ? document.getElementsByClassName("toolbar")[0].clientHeight : 0;
      let bottomHeight = document.getElementsByClassName("modal-footer")[0] ? document.getElementsByClassName("modal-footer")[0].clientHeight : 0;
      // #9863 Error in created hook (Promise/async): "TypeError: Cannot read properties of undefined (reading 'clientHeight')" 横展開2 linjunfeng end
      let dataList = document.getElementsByClassName("data-table")[0];

      let actualHeight = totalHeight - topHeight - bottomHeight - rowHeight - 11;

      if (dataList) {
        dataList.style.height = actualHeight + "px";
      }
    },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 start
    // changeButton() {
    //   EventBus.$emit("mstHolidayRegistered", false);
    // }
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_薬効換算マスタ 張玲 2024/01/04 end
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto {
    height: auto !important;
  }
}
.setInfo-list {
  height: 52vh;
  border: 1px solid;
  overflow: auto;
}
table {
  border-collapse: collapse;
}
table th,
table td {
  /*border: solid 1px black;*/
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

.list-input input {
  width: 70%;
}

.list-delete {
  flex: 0 0 12%;
}

.list-class {
  flex: 0 0 20%;
}

.list-name {
  flex: 0 0 40%;
}

.list-name span {
  line-height: 39px;
}

.list-num {
  flex: 0 0 13%;
}

.list-code {
  flex: 0 0 10%;
}

.list-timing-code {
  flex: 0 0 16%;
}

.item-select {
  padding: 2px;
}

.item-button {
  width: 60px;
  padding: 0;
  margin-left: 2px;
}

.select-button {
  width: 50px;
  padding: 1px;
  margin: 2px 0 0 2px;
  margin-bottom: 5px;
}

/* 項目名 */
.item-title {
  max-width: 11em;
  margin-left: 5px;
}
/* @media screen and (max-width: 1050px){
  .item-title {
    max-width: 9rem;
  }
} */

.medi-name {
  width: calc(100% - 50px);
  min-width: 11em;
}
.medi-col {
  display: flex;
  position: relative;
  justify-content: flex-end;
}
.center-inside {
  max-width: 60px;
  float: right;
  display: flex;
  margin-left: 10px;
  padding: 5px 0px;
}
.data-table {
  display: block;
  overflow-x: auto;
}
.data-table >>> ons-row {
  min-width: 550px;
  overflow-x: auto;
}
.data-table >>> ons-row >>> ons-col{
  white-space: normal;
}
.drug-group-name {
  max-width: 440px;
  min-width: 140px;
}
@media screen and  (min-width:376px) and (max-width:667px) {
  .setInfo-list {
    height: 35vh;
  }
}
/* @media screen and (max-width: 667px) {
  .item-title {
    width: 10%;
    max-width: 33%;
    margin-left: 5px;
  }
  .list-input {
    flex: 0 0 67%;
  }
} */

.ntss-list {
  position: unset;
}

.frame{
  border: 1px solid black;
  overflow: auto;
}

.item-data {
  padding-bottom: 3px;
  padding-left: 3px;
  padding-right: 3px;
}

/* 一覧領域の幅
 * 各項目の幅：59em
 * 各項目のマージンなど：10px * 7
 * 選択ボタンの幅：50px
 */
.detail-list {
  min-width: calc(51em + 10px * 7 + 50px);
}
.list-header-item-delete {
  width: 3em;
}
.list-header-item-medi-flg {
  width: 6em;
}
.list-header-item-class {
  width: 7em;
}
.list-header-item-medi-name {
  width: 100%;
  min-width: calc(11em + 50px);
}
.list-header-item-medi-unit {
  width: 7em;
}
.list-header-item-medi-unit-step {
  width: 10em;
}
.list-header-item-medi-group-unit {
  width: 7em;
}
.medi-name-wrapper {
  white-space: nowrap;
}
/* 削除ボタン */
.button-delete {
  display: block;
  margin: auto;
}
</style>
