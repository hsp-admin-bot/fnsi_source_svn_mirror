<template>
  <div id="main-taboo-wrapper" class="main-taboo-area">
    <v-ons-row id="group-name-wrapper1" class="top-space">
      <!-- mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start -->
      <!-- <v-ons-col class="item-word" align="center" width="50%"> -->
      <v-ons-col align="center" width="15%" style="padding: 4px">
      <!-- mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end -->
        禁忌・アレルギー名
      </v-ons-col>
      <!-- mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start -->
      <!-- <v-ons-col> -->
      <v-ons-col width="50%">
      <!-- mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end -->
        <custom-input
          class="input-area"
          :value="displayMstTabooAllergy.content"
          @blur="setGroupName($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>

    <!-- add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start -->
    <v-ons-row id="group-name-wrapper2" class="top-space">
      <v-ons-col align="center" width="15%" style="padding: 4px">
        連携コード1
      </v-ons-col>
      <v-ons-col>
        <v-ons-row>
          <v-ons-col style="margin-right: 5px">
            <custom-input
              class="input-area-inhospital"
              :value="displayMstTabooAllergy.inHospitalCd1"
              @blur="setGroup1($event.target.value)"
            />
          </v-ons-col>
        </v-ons-row>
      </v-ons-col>
      <v-ons-col width="6%">
      </v-ons-col>
      <v-ons-col align="center" width="15%">
        連携コード2
      </v-ons-col>
      <v-ons-col>
        <v-ons-row>
          <v-ons-col style="margin-left: 5px">
            <custom-input
              class="input-area-inhospital"
              :value="displayMstTabooAllergy.inHospitalCd2"
              @blur="setGroup2($event.target.value)"
            />
          </v-ons-col>
        </v-ons-row>
      </v-ons-col>
    </v-ons-row>
    <!-- add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end -->

    <v-ons-row id="item-select-wrapper">
      <!-- del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start -->
      <!-- <v-ons-col class="top-space item-word" align="top" width="50%">禁忌</v-ons-col> -->
      <!-- del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end -->
      <v-ons-col class="custom-select-button">
        <v-ons-button
          ref="medicineMst"
          class="btn3-normal select-button"
          @click="selectMedicine()"
        >
          薬剤追加
        </v-ons-button>
        <v-ons-button
          ref="equipmentMst"
          class="btn3-normal select-button equipment"
          @click="selectEquipment()"
        >
          医療材料追加
        </v-ons-button>
        <v-ons-button
          ref="dialyzerMst"
          class="btn3-normal dialyzer-select-button"
          @click="selectDialyzer()"
        >
          ダイアライザ追加
        </v-ons-button>
        <v-ons-button class="btn3-normal freeword-select-button" @click="selectFreeWord()">
          フリーワード追加
        </v-ons-button>
        <v-ons-button
          ref="genericMedicineSys"
          class="btn3-normal generic-medicine-select-button"
          v-if="canSelectGeneric"
          @click="selectGenericMedicine()"
        >一般名処方追加</v-ons-button>
      </v-ons-col>
    </v-ons-row>

    <!-- del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start -->
    <!-- <v-ons-row id="group-name-wrapper" class="top-space">
      <v-ons-col class="item-word" align="center" width="50%">
        連携コード
      </v-ons-col>
      <v-ons-col>
        <v-ons-row>
          <v-ons-col style="margin-right: 5px">
            <custom-input
              class="input-area-inhospital"
              :value="displayMstTabooAllergy.inHospitalCd1"
              @blur="setGroup1($event.target.value)"
            />
          </v-ons-col>
          <v-ons-col style="margin-left: 5px">
            <custom-input
              class="input-area-inhospital"
              :value="displayMstTabooAllergy.inHospitalCd2"
              @blur="setGroup2($event.target.value)"
            />
          </v-ons-col>
        </v-ons-row>
      </v-ons-col>
    </v-ons-row> -->
    <!-- del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end -->

    <!-- 選択された禁忌・アレルギー一覧 -->
    <div class="list-main-area list-area custom-list-area" :style="heightStyles">
      <table class="ntss-list">
        <thead id="list-header-wrapper" display="block">
          <tr>
            <th class="color-header list-class ntss-list-header-th-sticky">禁忌対象区分</th>
            <th class="color-header ntss-list-header-th-sticky list-header-item-name">禁忌対象名</th>
            <th class="color-header list-delete-header ntss-list-header-th-sticky"/>
          </tr>
        </thead>
        <tr v-for="(column, index) in tabooAllergyDetailList" :key="index" :style="heightStyles">
          <!-- 禁忌対象区分 -->
          <td class="item-word">{{ tabooAllergyDetailClassList[index] }}</td>
          <!-- 禁忌対象名 -->
          <td class="item-word">
            <v-ons-col v-if="column.classCd === FREEWORD" class="allergy">
              <com-textarea
                :content="column.name"
                class="input-required"
                cssClass="text-input textarea-resize-vertical"
                :idTextarea="'com-textarea-free-word' + index"
                @set-content-data="setContentData($event, index)"
              />
            </v-ons-col>
            <v-ons-col v-else>
              {{ displayTabooAllergyName[index] }}
            </v-ons-col>
          </td>
          <!-- 削除ボタン -->
          <td class="item-word">
            <button class="ntss-btn-outset button-delete" @click="deleteTabooAllergy(index)">
              <v-ons-icon icon="fa-trash"/>
            </button>
          </td>
        </tr>
      </table>
      <!-- 薬剤選択ボタンポップオーバー -->
      <pop-over
        v-bind="popoverMedicine"
        :target-position-element="popoverTargetElement('medicineMst')"
        @popover-return="setTabooAllergy($event, MEDICINE)"
        @popover-close="closePopover(popoverMedicine)"
      />
      <!-- 医材選択ボタンポップオーバー -->
      <pop-over
        v-bind="popoverEquipment"
        :target-position-element="popoverTargetElement('equipmentMst')"
        @popover-return="setTabooAllergy($event, EQUIPMENT)"
        @popover-close="closePopover(popoverEquipment)"
      />
      <!-- ダイアライザ選択ボタンポップオーバー -->
      <pop-over
        v-bind="popoverDialyzer"
        :target-position-element="popoverTargetElement('dialyzerMst')"
        @popover-return="setTabooAllergy($event, DIALYZER)"
        @popover-close="closePopover(popoverDialyzer)"
      />
      <!-- 一般名処方選択ボタンポップオーバー -->
      <pop-over
        v-if="canSelectGeneric"
        v-bind="popoverGenericMedicine"
        :target-position-element="popoverTargetElement('genericMedicineSys')"
        @popover-return="setTabooAllergy($event, GENERIC_MEDICINE)"
        @popover-close="closePopover(popoverGenericMedicine)"
      />
    </div>
  </div>
</template>

<script>
import { mapGetters, mapState } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end

// mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
// import MasterSelector from "@/components/common/master-selector/MasterSelector";
import MasterSelector from "@/components/common/master-selector/MasterSelectorMultiple";
// mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
import { showPopover, closePopover } from "@/functions/PopoverFunctions";
import customInput from "@/components/common/custom-form-tags/CustomInput";
import { equipmentClass, medicineClass } from "@/functions/mst/MstGetters.js";
import { FUNC_PRESCRIPTION } from "@/constants/function-code.js";
import CommonTextArea from "@/components/common/CommonTextArea";
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
// FNSI-修正 マスタ削除の対応 楊 add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { customComparator } from "@/utils/util.js";
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
import dayjs from "@/compat/date/dayjs";
import { getModalBodyElement, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
//#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
// 禁忌対象区分
// 薬剤
const MEDICINE = "1";
// 医療材料
const EQUIPMENT = "3";
// ダイアライザ
const DIALYZER = "4";
// フリーワード
const FREEWORD = "5";
// 一般名処方
const GENERIC_MEDICINE = "6";

export default {
  components: {
    "pop-over": MasterSelector,
    "custom-input": customInput,
    "com-textarea": CommonTextArea
  },

  data() {
    return {
      //区分
      medicineType: [{text: "内服", value: 1}, {text: "外用", value: 2}],
      // 薬剤マスタ一覧
      mstMedicineList: null,
      // 医療材料マスタ一覧
      mstEquipmentList: null,
      // ダイアライザマスタ一覧
      mstDialyzerList: null,
      // 一般名処方マスタ一覧
      sysGenericMedicineList: null,
      // add 9987 by kangjie 20231214 start add  調製薬剤
      mstMedicineMix: null,
      // add 9987 by kangjie 20231214 end
      // 禁忌・アレルギーマスタ一覧
      mstTabooAllergyList: null,
      //画面表示用の禁忌・アレルギーマスタ
      displayMstTabooAllergy: {
        content: { initValue: "", editValue: "" },
        inHospitalCd1: { initValue: "", editValue: "" },
        inHospitalCd2: { initValue: "", editValue: "" },
        detailInfo: { initValue: [], editValue: [] }
      },
      //削除判定フラグ
      deleteCheck: false,
      // 薬剤選択ポップオーバー用オブジェクト
      popoverMedicine: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "薬剤",
        popoverFilter: [],
        popoverContentLabel: "薬剤名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      // 医材選択ポップオーバー用オブジェクト
      popoverEquipment: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "医療材料",
        popoverFilter: [],
        popoverContentLabel: "医療材料名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      // ダイアライザ選択ポップオーバー用オブジェクト
      popoverDialyzer: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "ダイアライザ",
        popoverFilter: [],
        popoverContentLabel: "ダイアライザ名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      popoverGenericMedicine: {
        popoverVisible: false,
        popoverDisplayDirection: "down",
        popoverTitleHeader: "一般名処方",
        popoverFilter: [],
        popoverContentLabel: "一般名処方名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      // フィルター用医材選択ポップオーバーオブジェクト
      popoverEquipmentFilter: {},
      // フィルター用ダイアライザ選択ポップオーバーオブジェクト
      popoverDialyzerFilter: {},
      // 一般名処方選択ポップオーバーオブジェクト
      popoverGenericMedicineFilter: {},
      // 選択された禁忌・アレルギーマスタの詳細(禁忌対象区分,禁忌対象コードにチェックボックス判定フラグを追加したリスト)
      tabooAllergyDetailList: {},
      // ストア保存用、選択された禁忌・アレルギーマスタの詳細(禁忌対象区分,禁忌対象コードのリスト)
      storeTabooAllergyDetailList: {},
      //禁忌対象区分定数
      MEDICINE,
      EQUIPMENT,
      DIALYZER,
      GENERIC_MEDICINE,
      FREEWORD,
      // リストの高さ
      listHeight: 500,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx start
      editRecordCompare: null,
      editRecordClone: null,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx end
    };
  },

  computed: {
    // mod 禁忌・アレルギーマスタ 障害対応 孔s start
    // ...mapGetters("master-maintenance", ["getEditRecord"]),
    ...mapGetters("master-maintenance", ["getEditRecord","getMasterRecordList","getFacilitySwitch"]),
    // mod 禁忌・アレルギーマスタ 障害対応 孔s end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["isUseFunction"]),
    ...mapGetters("window-size", {
      splittedWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),
    ...mapState("master-maintenance", ["schemaModel"]),
    /**
     * @description 禁忌対象区分リストを数字に対応する区分に変換する処理
     * @returns 画面表示用の禁忌対象区分リスト
     */
    tabooAllergyDetailClassList() {
      const arr = [];
      this.tabooAllergyDetailList.forEach(item => {
        arr.push(this.displayTabooAllergyClass(item.classCd));
      });
      return arr;
    },

    /**
     * @description 禁忌対象コードに対応する、各コードに設定された名称を返す処理
     * @returns 画面表示用の禁忌対象リスト
     */
    displayTabooAllergyName() {
      const arr = [];
      this.tabooAllergyDetailList.forEach(item => {
        arr.push(this.changeTabooAllergyName(item.classCd, item.cd, item.type));
      });
      return arr;
    },
    heightStyles() {
      // リストの高さをCSS変数を利用して書き換え
      return { "--height": `${this.listHeight}px` };
    },
    canSelectGeneric() {
      return this.isUseFunction(FUNC_PRESCRIPTION);
    }
  },

  watch: {
    /**
     * ウィンドウサイズが変更されたらリストをリサイズする
     */
    splittedWidth() {
      this.calculateListHeight();
    },
    windowHeight() {
      this.calculateListHeight();
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx start
    editRecordClone: {
      handler(val) {
        const editRecord= cloneDeep(val);
        const editRecordCompare = cloneDeep(this.editRecordCompare);
        editRecordCompare.detailInfo = editRecordCompare.detailInfo ? JSON.parse(editRecordCompare.detailInfo) : [];
        editRecord.detailInfo = editRecord.detailInfo ? JSON.parse(editRecord.detailInfo) : [];
        editRecordCompare.detailInfo.sort((a, b) => {
          return a.cd > b.cd ? 1 : -1;
        });
        editRecord.detailInfo.sort((a, b) => {
          return a.cd > b.cd ? 1 : -1;
        });
        editRecord.detailInfo.forEach((item) => {
          delete item.index;
        });
        EventBus.$emit( "mstHolidayRegistered", isEqualWith(editRecordCompare, editRecord, customComparator));
      },
      deep: true
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx end
  },

  async created() {
    /**
     * @description 施設コードを取得
     */
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.facilityCd = this.getFacilityCd;
    this.facilityCd = this.getFacilitySwitch;
    // mod マスタ一覧 1･施設切替を可能とする 孔s end

    /**
     * @description 薬剤マスタ,医材マスタ,ダイアライザーマスタ一覧をそれぞれ取得する処理
     */
    //施設コードを抽出条件に追加
    const requestParam = {
      facilityCd: this.facilityCd
    };
    const [
      mstMedicine,
      mstEquipment,
      mstdialyzer,
      sysGenericMedicine,
      // add 9987 by kangjie 20231214 start add 調製薬剤
      mstMedicineMix
      // add 9987 by kangjie 20231214 end
    ] = await Promise.all([
      ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
      ApiHelper.get("/mstInfo/mstEquipmentIncludeDeleted", requestParam),
      ApiHelper.get("/mstInfo/mstDialyzerIncludeDeleted", requestParam),
      ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted"),
      // add 9987 by kangjie 20231214 start add 調製薬剤
      ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", requestParam)
      // add 9987 by kangjie 20231214 end
    ]).catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MstTabooAllergyMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw new Error(
        `[SearchPatSimple.vue]created(): マスタ取得失敗
        エラー内容: ${error}`
      );
    });
    this.mstMedicineList = mstMedicine.data;
    this.mstEquipmentList = mstEquipment.data;
    this.mstDialyzerList = mstdialyzer.data;
    this.sysGenericMedicineList = sysGenericMedicine.data;
    // add 9987 by kangjie 20231214 start
    this.mstMedicineMix = mstMedicineMix.data;
    // add 9987 by kangjie 20231214 end

    //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
    this.mstMedicineList.forEach((t, index) => {
      t.index = index;
    });
    this.mstEquipmentList.forEach((t, index) => {
      t.index = index;
    });
    this.mstDialyzerList.forEach((t, index) => {
      t.index = index;
    });
    this.sysGenericMedicineList.forEach((t, index) => {
      t.index = index;
    });
    //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
    /**
     * @description ストア書き込み用、禁忌対象一覧リスト作成処理
     */
    //禁忌・アレルギーマスタの詳細項目を配列形式に変換(新規登録の場合は空の配列を保持)
    this.storeTabooAllergyDetailList =
      this.getEditRecord.detailInfo === "" || !this.getEditRecord.detailInfo
        ? []
        : JSON.parse(this.getEditRecord.detailInfo);

    //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
    this.storeTabooAllergyDetailList.forEach((t) => {
      let classCdForTaboo = t.classCd;
      let cd = t.cd;
      let index;
      switch (classCdForTaboo) {
        case MEDICINE:
          index = this.mstMedicineList.find(item => {
            return item.medicineCd === cd
          }).index;
          break;
        case EQUIPMENT:
          index = this.mstEquipmentList.find(item => {
            return item.equipmentCd === cd
          }).index;
          break;
        case DIALYZER:
          index = this.mstDialyzerList.find(item => {
            return item.dialyzerCd === cd
          }).index;
          break;
        case GENERIC_MEDICINE:
          index = this.sysGenericMedicineList.find(item => {
            return item.genericCd === cd
          }).index;
          break;
      }
      t.index = index;
    });
    //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
    /**
     * @description 削除フラグを付与し、一覧画面表示用のリスト作成処理
     */
    this.tabooAllergyDetailList = this.storeTabooAllergyDetailList.map(item => {
      return { ...item, isChecked: this.deleteCheck };
    });
    //表示順序を整頓
    this.listSort(this.tabooAllergyDetailList);
    this.listSort(this.storeTabooAllergyDetailList);

    /**
     * @description 画面表示用ローカル配列に、禁忌・アレルギーマスタ各項目の値を保持
     */
    for (const property in this.displayMstTabooAllergy) {
      switch (property) {
        //内容取得
        case "content":
          this.displayMstTabooAllergy.content.initValue = this.getEditRecord.name;
          this.displayMstTabooAllergy.content.editValue = this.displayMstTabooAllergy.content.initValue;
          break;
        case "inHospitalCd1":
          this.displayMstTabooAllergy.inHospitalCd1.initValue = this.getEditRecord.inHospitalCd1;
          this.displayMstTabooAllergy.inHospitalCd1.editValue = this.displayMstTabooAllergy.inHospitalCd1.initValue;
          break;
        case "inHospitalCd2":
          this.displayMstTabooAllergy.inHospitalCd2.initValue = this.getEditRecord.inHospitalCd2;
          this.displayMstTabooAllergy.inHospitalCd2.editValue = this.displayMstTabooAllergy.inHospitalCd2.initValue;
          break;
        //詳細取得
        case "detailInfo":
          this.displayMstTabooAllergy.detailInfo.initValue = this.tabooAllergyDetailList;
          this.displayMstTabooAllergy.detailInfo.editValue = this.displayMstTabooAllergy.detailInfo.initValue;
          break;

        default:
          break;
      }
    }

    /**
     * @description ストアの詳細の値が未設定の場合、初期化(内容のみ入力して登録する場合用)
     */
    //一覧表示する禁忌・アレルギーの有無を確認
    if (!this.getEditRecord.detailInfo) {
      this.editRecordClone.detailInfo = JSON.stringify([]);
    }
  },

  mounted() {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx start
    this.editRecordCompare = cloneDeep(this.getEditRecord);
    this.editRecordClone = cloneDeep(this.getEditRecord);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_禁忌・アレルギーマスタ 20240105 mrx end
    this.$nextTick(() => {
      this.calculateListHeight();
    });
     //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },

  methods: {
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration() {
      const hasEmptyTbooAllergy = this.tabooAllergyDetailList
        .filter(t => t.classCd === FREEWORD)
        .some(t => !t.name.trim());

      if (hasEmptyTbooAllergy) {
        this.tabooAllergyDetailList.forEach((t, index) => {
          if (t.classCd === FREEWORD && !t.name.trim()) {
            getScopedElementById("com-textarea-free-word" + index, this.$el || this)?.parentNode?.classList?.add("input-invalid")
          }
        })

        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "禁忌対象名を入力してください"
          title: DIALOG_MESSAGES['00200093'].title,
          message: messageFormat(DIALOG_MESSAGES['00200093'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });

        return false;
      }

      return true;
    },

    /**
     * @description 禁忌グループ名変更の処理
     * @param 変更後の禁忌グループ名
     */
    setGroupName(value) {
      // add 禁忌・アレルギーマスタ 障害対応 孔s start
      const masterField = this.schemaModel["name"];
      if (masterField.validation.maxlength && value.length > masterField.validation.maxlength){
        value=value.substring(0,masterField.validation.maxlength)
      }
      // add 禁忌・アレルギーマスタ 障害対応 孔s end
      this.editRecordClone.name = value;
    },

    setGroup1(value) {
      // add 禁忌・アレルギーマスタ 障害対応 孔s start
      const masterField = this.schemaModel["inHospitalCd1"];
      if (masterField.validation.maxlength && value.length > masterField.validation.maxlength){
        value=value.substring(0,masterField.validation.maxlength)
      }
      // add 禁忌・アレルギーマスタ 障害対応 孔s end
      this.editRecordClone.inHospitalCd1 = value;
      //[確認]ボタンの状態の変更をトリガーします
      if (this.displayMstTabooAllergy.inHospitalCd1.editValue === "") {
        this.displayMstTabooAllergy.inHospitalCd1.editValue = null
      }
    },

    setGroup2(value) {
      // add 禁忌・アレルギーマスタ 障害対応 孔s start
      const masterField = this.schemaModel["inHospitalCd2"];
      if (masterField.validation.maxlength && value.length > masterField.validation.maxlength){
        value=value.substring(0,masterField.validation.maxlength)
      }
      // add 禁忌・アレルギーマスタ 障害対応 孔s end
      this.editRecordClone.inHospitalCd2 = value;
      //[確認]ボタンの状態の変更をトリガーします
      if (this.displayMstTabooAllergy.inHospitalCd2.editValue === "") {
        this.displayMstTabooAllergy.inHospitalCd2.editValue = null
      }
    },

    /**
     * @description 薬剤用ポップオーバーを表示
     */
    selectMedicine() {
      Promise.all([medicineClass(this.facilityCd)])
        .then(([responseMedicineClassData]) => {
          //薬剤分類一覧の分類名称と分類コード
          let filterArr = [];
          //薬剤分類マスタ一覧
          const classData = responseMedicineClassData;

          // 薬剤分類マスタから分類名称と分類コード一覧を保持
          const filterMapping = item => {
            return {
              text: item.className,
              value: item.classCd
            };
          };

          //保持した分類名称と分類コード一覧に項目追加
          filterArr = classData.map(filterMapping);
          filterArr.unshift({ text: "すべて", value: 0 });

          // 薬剤マスタ一覧の薬剤名称と薬剤コード一覧に薬剤分類を追加して保持
          let contentArr = this.mstMedicineList
            .filter(item => item.isDisp !== "0" && item.isDel !== "1")
            .map(item => {
              return {
                value: item.medicineCd,
                fnValue: {
                  薬剤分類: item.classCd
                },
                text: item.medicineName
              };
            });

          //薬剤名称がnullの場合は一覧から外す
          contentArr = contentArr.filter(item => {
            return item.text !== null;
          });
          //ポップオーバー用ローカル変数に値を入力
          this.popoverMedicine.popoverFilter = [
            {
              popoverFilterLabel: "薬剤分類",
              popoverFilterDataset: filterArr
            }
          ];
          this.popoverMedicine.popoverContentDataset = contentArr;
          //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
          let tabooAllergyDetailListCd = this.tabooAllergyDetailList.filter(item => item.classCd == 1);
          const popoverContentSelectedValue = [];
          tabooAllergyDetailListCd.forEach((ele) => {
            //削除したものは転送しません
            if(contentArr != null){
            if(contentArr.some(t => t.value == ele.cd)){
              popoverContentSelectedValue.push(ele.cd);
            }
          }
          });
          this.popoverMedicine.popoverContentSelected.value = popoverContentSelectedValue;
          //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end
          //ポップオーバー表示
          showPopover(this.popoverMedicine);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstTabooAllergyMainComponent.vue', 'selectMedicine', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        });
    },

    /**
     * @description 医療材料用ポップオーバーを表示
     */
    selectEquipment() {
      Promise.all([equipmentClass(this.facilityCd)])
        .then(([responseEquipmentClassData]) => {
          //医療材料分類一覧の分類名称と分類コード
          let filterArr = [];
          //医療材料分類マスタ一覧
          const classData = responseEquipmentClassData;

          // 医療材料分類一覧から分類名称と分類コード一覧を保持
          const filterMapping = item => {
            return {
              text: item.className,
              value: item.classCd
            };
          };

          //保持した分類名称と分類コード一覧に項目追加
          filterArr = classData.map(filterMapping);
          filterArr.unshift({ text: "すべて", value: 0 });

          // 抽出初期条件により抽出された、初期表示する一覧を保持(薬剤マスタ一覧の薬剤名称と薬剤コード一覧)
          let contentArr = this.mstEquipmentList
            .filter(item => item.isDisp !== "0" && item.isDel !== "1" && item.facilityCd == this.facilityCd)
            .map(item => {
              return {
                value: item.equipmentCd,
                fnValue: {
                  医療材料分類: item.classCd
                },
                //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
                text: item.equipmentName,
                useStartDate: item.useStartDate,
                useEndDate: item.useEndDate
                //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
              };
            });

          //医療材料名称がnullの場合は一覧から外す
          contentArr = contentArr.filter(item => {
            return item.text !== null;
          });

          //ポップオーバー用ローカル変数に値を入力
          this.popoverEquipment.popoverFilter = [
            {
              popoverFilterLabel: "医療材料分類",
              popoverFilterDataset: filterArr
            }
          ];

          //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
          let tabooAllergyDetailListCd = this.tabooAllergyDetailList. filter(item => item.classCd ==3);
          const popoverContentSelectedValue = [];
          tabooAllergyDetailListCd.forEach((ele) => {
            //削除したものは転送しません
            if(contentArr != null){
            if(contentArr.some(t => t.value == ele.cd)){
              popoverContentSelectedValue.push(ele.cd);
            }
            }
          });
          this.popoverEquipment.popoverContentSelected.value = popoverContentSelectedValue;
          this.popoverEquipment.popoverContentDataset = contentArr;
          //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
          const nowdate = dayjs().format("YYYYMMDD");
          contentArr = this.popoverEquipment.popoverContentDataset.filter(item => {
            return fitTermCheck(item.useStartDate, item.useEndDate, nowdate)
            || popoverContentSelectedValue.includes(item.value);
          });
          //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
          //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end
          this.popoverEquipment.popoverContentDataset = contentArr;

          //ポップオーバー表示
          showPopover(this.popoverEquipment);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstTabooAllergyMainComponent.vue', 'selectEquipment', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          throw error;
        });
    },
    /**
     * @description ダイアライザ用ポップオーバーを表示
     */
    selectDialyzer() {
      //ダイアライザ分類名称とコード(メーカー一覧とメーカー毎に任意のコードを付与したリスト)
      let filterArr = [];
      //重複無しのメーカー一覧
      let makerList = [];
      //表示用メーカー一覧(メーカー名をnull→"メーカー名無し"に変更)
      let displaymakerList = [];

      //ダイアライザマスタ内に定義された、メーカー一覧
      const arrayMaker = this.mstDialyzerList.map(item => {
        return item.maker;
      });

      //メーカーが重複していないダイアライザ一覧(最初に出現したメーカーのレコードを取得)
      const classData = this.mstDialyzerList.filter((item, index) => {
        return arrayMaker.indexOf(item.maker) === index;
      });

      //重複無しのダイアライザ一覧から各メーカーを保持
      makerList = classData.map(item => {
        return item.maker;
      });

      //メーカー名がnullの項目を変換して保持
      displaymakerList = makerList.map(item => {
        return item === null ? "メーカー名なし" : item;
      });

      // メーカー一覧に分類コードを付与(ダイアライザは薬剤や医療材料と違い、分類コードのテーブルが無いため)
      filterArr = displaymakerList.map((item, index) => {
        return { text: item, value: index + 1 };
      });

      //分類コード一覧に項目追加
      filterArr.unshift({ text: "すべて", value: 0 });

      //ダイアライザマスタ一覧に、メーカー別で分類コードを付与
      const dialyzerNum = this.mstDialyzerList.map(item => {
        //分類コード
        let ownClass = null;
        //メーカー名毎に分類コードを付与
        for (const index in filterArr) {
          if (item.maker === makerList[index]) {
            return parseInt(index) + 1;
          }
        }
        return ownClass;
      });

      //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
      let dialyzerTypeData = [
        { text: "すべて", value: 0 },
        { text: "中空糸", value: 1 },
        { text: "積層", value: 2 }
      ]
      //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end

      // マスタデータから重複を除いたメーカー名のリストを取得する
      let functionClassData = this.mstDialyzerList
        .map(item => item.functionClass)
        .filter(
          (item, index, self) => item !== null && self.indexOf(item) === index
        )
        .map(item => {
          return {
            text: item,
            value: item
          };
        });
      functionClassData.sort(this.sortPopoverValue)
      functionClassData.unshift({ text: "すべて", value: 0 });
      functionClassData.push({ text: "未分類", value: null });

      // ダイアライザ名称とダイアライザコード一覧に分類コードを追加して保持
      let contentArr = this.mstDialyzerList
        .filter(item => item.isDisp !== "0" && item.isDel !== "1" && item.facilityCd.toString() == this.getFacilitySwitch.toString())
        .map((item, index) => {
          return {
            value: item.dialyzerCd,
            fnValue: {
              メーカー: dialyzerNum[index],
              //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
              ダイアライザ種別: parseInt(item.dialyzerType) + 1,
              //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
              機能分類: item.functionClass
            },
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
            text: item.modelNumber,
            useStartDate: item.useStartDate,
            useEndDate: item.useEndDate
            //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
          };
        });

      //ダイアライザ型番がnullの場合は一覧から外す
      contentArr = contentArr.filter(item => {
        return item.text !== null;
      });

      //ポップオーバー用のローカル変数に値を代入
      this.popoverDialyzer.popoverFilter = [
        {
          popoverFilterLabel: "メーカー",
          popoverFilterDataset: filterArr
        },
        {
          popoverFilterLabel: "ダイアライザ種別",
          popoverFilterDataset: dialyzerTypeData
        },
        {
          popoverFilterLabel: "機能分類",
          popoverFilterDataset: functionClassData
        }

      ];
      this.popoverDialyzer.popoverContentDataset = contentArr;
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
      //ホームページは選択したダイアライザを追加ページに渡します
      let tabooAllergyDetailListCd = this.tabooAllergyDetailList. filter(item => item.classCd ==4);
      const popoverContentSelectedValue = [];
      tabooAllergyDetailListCd.forEach((ele) => {
        //削除したものは転送しません
        if(contentArr != null){
        if(contentArr.some(t => t.value == ele.cd)){
              popoverContentSelectedValue.push(ele.cd);
            }
          }
      });
      this.popoverDialyzer.popoverContentSelected.value = popoverContentSelectedValue;
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      const nowdate = dayjs().format("YYYYMMDD");
      contentArr = this.popoverDialyzer.popoverContentDataset.filter(item => {
        return fitTermCheck(item.useStartDate, item.useEndDate, nowdate)
            || popoverContentSelectedValue.includes(item.value);
      });
      this.popoverDialyzer.popoverContentDataset = contentArr;
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end
      //ポップオーバー表示
      showPopover(this.popoverDialyzer);
    },

    /**
     * @description 一般名処方用ポップオーバーを表示
     */
    selectGenericMedicine() {

      // 一般名処方コードと薬剤分類で検索
      let contentArr = this.sysGenericMedicineList
        .filter(item => item.isDisp !== "0" && item.isDel !== "1")
        .map(item => {
          return {
            value: { genericCd: item.genericCd, medicineType: item.medicineType},
            fnValue: {},
            text: item.genericName
          };
        });

      //薬剤名称がnullの場合は一覧から外す
      contentArr = contentArr.filter(item => {
        return item.text !== null;
      });
      this.popoverGenericMedicine.popoverContentDataset = contentArr;
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
      const tabooAllergyDetailListCopy =this.tabooAllergyDetailList.filter(item => item.classCd == 6);
      const popoverContentSelectedOld = [];
      for(let index = 0;index < tabooAllergyDetailListCopy.length;index++){
        let newCd = tabooAllergyDetailListCopy[index].cd;
        popoverContentSelectedOld.push(contentArr.find(item2 => {return item2.value.genericCd === newCd}).value)
      }
      this.popoverGenericMedicine.popoverContentSelected.value =popoverContentSelectedOld;
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end
      //ポップオーバー表示
      showPopover(this.popoverGenericMedicine);
    },

    /**
     * @description マスタ選択ポップオーバーの表示位置を取得
     * @param ポップオーバーの表示位置区分
     */
    popoverTargetElement(position) {
      return this.$refs[position];
    },

    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択したオブジェクト情報
     * @param 選択した禁忌対象の区分
     */
    setTabooAllergy(event, eventClass) {
      let mstClass = eventClass;
      // add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
      const eventList = event;
      let errCount = 0;
      // add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end
      //禁忌対象一覧へ選択済の禁忌対象
      // del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
      // let hasCd = false;
      // del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end

      //選択したオブジェクトと同じコードの禁忌対象を一覧から抽出
      let sameCdDetailList = [];
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
      let loseCdDetailList = [];
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end
      if(mstClass !== GENERIC_MEDICINE) {
        // mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
        // sameCdDetailList = this.tabooAllergyDetailList.filter(
        //   item => item.cd === event.value
        // );
        eventList.forEach(event=>{
          sameCdDetailList.push(
            this.tabooAllergyDetailList.filter(
              item => item.cd === event.value && item.classCd === mstClass))
        });
        // mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end
      } else {
        // mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
        // sameCdDetailList = this.tabooAllergyDetailList.filter(
        //   item => item.cd === event.value.genericCd && item.type === event.value.medicineType
        // );
        eventList.forEach(event=>{
          sameCdDetailList.push(
            this.tabooAllergyDetailList.filter(
              item => item.cd === event.value.genericCd && item.type === event.value.medicineType && item.classCd === mstClass))
        });
        // mod 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end
      }

      // del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
      // //選択したオブジェクトと同じコードの禁忌対象が存在するか判定
      // if (sameCdDetailList.length > 0) {
      //   // 吹き出しから同じものを選択した場合
      //   hasCd = sameCdDetailList.find(item => item.classCd === mstClass);
      // }

      // //禁忌対象一覧へ選択済みのオブジェクトが選択された際はエラーメッセージを返す。未選択なら禁忌対象一覧に追加。
      // if (hasCd) {
      //   // 選択したマスタが重複した場合
      //   this.$ons.notification.alert({
      //     title: "選択失敗",
      //     message: "既に禁忌対象として選択済みです。"
      //   });
      // } else {
      //   //選択した禁忌対象コード,禁忌対象区分,削除フラグを禁忌対象一覧リストに追加
      //   this.tabooAllergyDetailList.push({
      //     cd: mstClass !== GENERIC_MEDICINE ? event.value : event.value.genericCd,
      //     type: mstClass !== GENERIC_MEDICINE ? null : event.value.medicineType,
      //     classCd: mstClass,
      //     name: "",
      //     deleteCheck: false
      //   });

      //   //ストア用禁忌対象一覧リストに選択した禁忌対象コード,禁忌対象区分を追加
      //   this.storeTabooAllergyDetailList.push({
      //     cd: mstClass !== GENERIC_MEDICINE ? event.value : event.value.genericCd,
      //     type: mstClass !== GENERIC_MEDICINE ? null : event.value.medicineType,
      //     classCd: mstClass,
      //     name: ""
      //   });

      //   //ストア用禁忌対象一覧リストをjson形式に変換
      //   const jsonStoreTabooAllergyDetailList = JSON.stringify(
      //     this.storeTabooAllergyDetailList
      //   );

      //   //ストアに禁忌対象一覧を書き込み
      //   this.setEditRecord({
      //     ...this.getEditRecord,
      //     detailInfo: jsonStoreTabooAllergyDetailList
      //   });
      //   //禁忌対象一覧を再描画
      //   this.refresh();
      // }
      // del 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start

      // add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s start
      //選択したオブジェクトと同じコードの禁忌対象が存在するか判定
      if (sameCdDetailList.length > 0) {
        // 吹き出しから同じものを選択した場合
        sameCdDetailList.forEach(sameCdDetail=>{
            if(sameCdDetail.length > 0){
              errCount++;
            }
        })
      }

      //禁忌対象一覧へ選択済みのオブジェクトが選択された際はエラーメッセージを返す。未選択なら禁忌対象一覧に追加。
      let errMsg = "";
      for (let index = 0; index < eventList.length; index++) {
        if (sameCdDetailList[index].length>0) {
          errMsg += eventList[index].text+"</br>";
        } else {
          const event = eventList[index];
          //選択した禁忌対象コード,禁忌対象区分,削除フラグを禁忌対象一覧リストに追加
          this.tabooAllergyDetailList.push({
            cd: mstClass !== GENERIC_MEDICINE ? event.value : event.value.genericCd,
            type: mstClass !== GENERIC_MEDICINE ? null : event.value.medicineType,
            classCd: mstClass,
            name: "",
            deleteCheck: false
          });

          //ストア用禁忌対象一覧リストに選択した禁忌対象コード,禁忌対象区分を追加
          this.storeTabooAllergyDetailList.push({
            cd: mstClass !== GENERIC_MEDICINE ? event.value : event.value.genericCd,
            type: mstClass !== GENERIC_MEDICINE ? null : event.value.medicineType,
            classCd: mstClass,
            name: ""
          });
        }
      }

      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 start
      loseCdDetailList =this.tabooAllergyDetailList.filter(
        item => item.classCd === mstClass
      );
      //add #9589 削除済み場合によっては、まとめる前に取り出します。 start
      let storeTabooAllergyDetailListDel = [];
      let TabooAllergyDetailListDel = [];
      if(this.mstMedicineList != null && mstClass == 1){
       this.storeTabooAllergyDetailList.forEach((ele) => {
        if(this.mstMedicineList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.medicineCd == ele.cd) && ele.classCd == 1){
         storeTabooAllergyDetailListDel.push(ele);
        }
          });
          this.tabooAllergyDetailList.forEach((ele) => {
            if(this.mstMedicineList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.medicineCd == ele.cd) && ele.classCd == 1){
              TabooAllergyDetailListDel.push(ele);
            }
          });
        }
      if(this.mstEquipmentList != null && mstClass == 3){
      this.storeTabooAllergyDetailList.forEach((ele) => {
        if(this.mstEquipmentList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.equipmentCd == ele.cd) && ele.classCd == 3){
          storeTabooAllergyDetailListDel.push(ele);
        }
          });
          this.tabooAllergyDetailList.forEach((ele) => {
            if(this.mstEquipmentList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.equipmentCd == ele.cd) && ele.classCd == 3){
              TabooAllergyDetailListDel.push(ele);
            }
          });
      }
      if(this.mstDialyzerList != null && mstClass == 4){
          this.storeTabooAllergyDetailList.forEach((ele) => {
            if(this.mstDialyzerList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.dialyzerCd == ele.cd) && ele.classCd == 4){
              storeTabooAllergyDetailListDel.push(ele);
            }
          });
          this.tabooAllergyDetailList.forEach((ele) => {
            if(this.mstDialyzerList.some(t => (t.isDisp == "0" || t.isDel == "1") && t.dialyzerCd == ele.cd) && ele.classCd == 4){
              TabooAllergyDetailListDel.push(ele);
            }
          });
        }
      //add #9589 削除済み場合によっては、まとめる前に取り出します。 end
      if(mstClass !== GENERIC_MEDICINE){
        for(let key = 0; key < loseCdDetailList.length; key++){
          if(eventList.find(item => {return item.value == loseCdDetailList[key].cd})=== undefined){
            this.tabooAllergyDetailList = this.tabooAllergyDetailList.filter(
              item => item.classCd === mstClass && item.cd != loseCdDetailList[key].cd  || item.classCd != mstClass)
            this.storeTabooAllergyDetailList =this.storeTabooAllergyDetailList.filter(
              item => item.classCd === mstClass && item.cd != loseCdDetailList[key].cd  || item.classCd != mstClass)
          }
        }
      }else{
        for(let key = 0; key < loseCdDetailList.length; key++){
          if(eventList.find(item => {return item.value.genericCd == loseCdDetailList[key].cd})=== undefined){
            this.tabooAllergyDetailList = this.tabooAllergyDetailList.filter(
              item => item.classCd === mstClass && item.cd != loseCdDetailList[key].cd  || item.classCd != mstClass)
            this.storeTabooAllergyDetailList =this.storeTabooAllergyDetailList.filter(
              item => item.classCd === mstClass && item.cd != loseCdDetailList[key].cd  || item.classCd != mstClass)
          }
        }
      }
      //add #9589 削除済をセットに入れます。 start
      if(storeTabooAllergyDetailListDel.length != 0){
        this.storeTabooAllergyDetailList = this.storeTabooAllergyDetailList.concat(storeTabooAllergyDetailListDel);
       }
       if(TabooAllergyDetailListDel.length != 0){
        this.tabooAllergyDetailList = this.tabooAllergyDetailList.concat(TabooAllergyDetailListDel);
       }
      //add #9589 削除済をセットに入れます。 end
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 ljg 20231030 end

      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi start
      // if (errCount > 0) {
      //   // 選択したマスタが重複した場合
      //   this.$ons.notification.alert({
      //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      //     // title: "下記の禁忌対象が選択されました",
      //     title: DIALOG_MESSAGES['00300004'].title,
      //     // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      //     message: errMsg
      //   });
      // }
      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi end
      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi start
      // if (errCount !== eventList.length) {
      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi end
        //ストアに禁忌対象一覧を書き込み
        this.editRecordClone.detailInfo = JSON.stringify(
          this.storeTabooAllergyDetailList
        );
        //禁忌対象一覧を再描画
        this.refresh();
      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi start
      // }
      //del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231003 zhaoqi end
      // add 禁忌・アレルギーマスタ モーダルの見た目修正 孔s end
    },

    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closePopover,

    /**
     * @description 選択項目削除ボタン押下時の処理
     */
    deleteTabooAllergy(index) {
      //選択した禁忌対象を削除
      this.tabooAllergyDetailList.splice(index, 1);
      //ストア用禁忌対象一覧リストからも、削除した禁忌対象を削除
      this.storeTabooAllergyDetailList.splice(index, 1);

      //ストア用禁忌対象一覧リストをjson形式に変換
      this.editRecordClone.detailInfo = JSON.stringify(
        this.storeTabooAllergyDetailList
      );
      //禁忌対象一覧の更新
      this.refresh();
    },

    /**
     * @description 数値に対応する禁忌対象区分を返す処理
     * @param 禁忌対象区分の数値
     * @returns 禁忌対象区分の数値に対応する禁忌対象区分
     */
    displayTabooAllergyClass(displayClass) {
      //禁忌対象区分
      let tabooAllergyClass = null;

      switch (displayClass) {
        case "1":
          tabooAllergyClass = "薬剤";
          break;
        // add 9987 by 20231214 start
        case "2":
          tabooAllergyClass = "調製薬剤";
          break;
        // add 9987 by 20231214 end
        case "3":
          tabooAllergyClass = "医療材料";
          break;

        case "4":
          tabooAllergyClass = "ダイアライザ";
          break;

        case "5":
          tabooAllergyClass = "フリーワード";
          break;

        case "6":
          tabooAllergyClass = "一般名処方";
          break;

        default:
          break;
      }
      return tabooAllergyClass;
    },

    /**
     * @description 各禁忌対象区分のコードに対応する名称を返す処理
     * @param 禁忌対象区分
     * @param 各禁忌対象区分内で設定されたコード
     * @returns 各禁忌対象区分のコードに対応する名称
     */
    changeTabooAllergyName(tabooClass, cd, type) {
      //名称
      let tabooAllergyName = null;

      //薬剤の場合
      if (tabooClass === "1") {
        //薬剤マスタ内データのコードと設定されたコードを比較
        const selectedMstMedicine = this.mstMedicineList.find(mstListData => {
          return mstListData.medicineCd === parseInt(cd);
        });
        //設定されたコードに対応する名称を取得
        if (selectedMstMedicine) {
          if (selectedMstMedicine.isDisp === "0" || selectedMstMedicine.isDel === "1") {
            tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED + selectedMstMedicine.medicineName
          } else {
            tabooAllergyName = selectedMstMedicine.medicineName
          }
        }
      }

      // add 9987 by kangjie 20231214 start
      if (tabooClass === "2") {
        const selectMstMedicineMix  = this.mstMedicineMix.find(mstMedicineList =>{
          return mstMedicineList.medicineMixCd === parseInt(cd);
        });
        if (selectMstMedicineMix) {
          if (selectMstMedicineMix.isDisp === "0" || selectMstMedicineMix.isDel === "1") {
            tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED + selectMstMedicineMix.medicineMixName
          } else {
            tabooAllergyName = selectMstMedicineMix.medicineMixName
          }
        }
      }
      // add 9987 by kangjie 20231214 end

      //医療材料の場合
      else if (tabooClass === "3") {
        //医療材料マスタ内データのコードと設定されたコードを比較
        const selectedMstEquipment = this.mstEquipmentList.find(mstListData => {
          return mstListData.equipmentCd === parseInt(cd);
        });
        //設定されたコードに対応する名称を取得
        if (selectedMstEquipment) {
          if (selectedMstEquipment.isDisp === "0" || selectedMstEquipment.isDel === "1") {
            tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED + selectedMstEquipment.equipmentName
          } else {
            tabooAllergyName = selectedMstEquipment.equipmentName
          }
        }
      }

      //ダイアライザの場合
      else if (tabooClass === "4") {
        //ダイアライザマスタ内データのコードと設定されたコードを比較
        const selectedMstDialyzer = this.mstDialyzerList.find(mstListData => {
          return mstListData.dialyzerCd === parseInt(cd);
        });
        //設定されたコードに対応する名称を取得
        if (selectedMstDialyzer) {
          if (selectedMstDialyzer.isDisp === "0" || selectedMstDialyzer.isDel === "1") {
            tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED + selectedMstDialyzer.modelNumber
          } else {
            tabooAllergyName = selectedMstDialyzer.modelNumber
          }
        }
      }

      else if(tabooClass === "6") {
        //一般名処方マスタ内データのコードと設定されたコードを比較
        const selectedSysGenericMedicine = this.sysGenericMedicineList.find(mstListData => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //return mstListData.genericCd === cd && mstListData.medicineType === type;
          return mstListData.genericCd === cd && mstListData.medicineType == type;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        });
        //設定されたコードに対応する名称を取得
        if (selectedSysGenericMedicine) {
          if (selectedSysGenericMedicine.isDisp === "0" || selectedSysGenericMedicine.isDel === "1") {
            tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED + selectedSysGenericMedicine.genericName
          } else {
            tabooAllergyName = selectedSysGenericMedicine.genericName
          }
        }
      }

      if (!tabooAllergyName) {
        tabooAllergyName = MASTER_DELETE_DISPLAY.DELETED
      }
      return tabooAllergyName;
    },

    /**
     * @description 禁忌対象一覧更新処理
     */
    refresh() {
      //詳細取得
      this.displayMstTabooAllergy.detailInfo.initValue = this.tabooAllergyDetailList;
      this.displayMstTabooAllergy.detailInfo.editValue = this.displayMstTabooAllergy.detailInfo.initValue;

      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
      this.storeTabooAllergyDetailList.forEach((t) => {
        let classCdForTaboo = t.classCd;
        let cd = t.cd;
        let index;
        switch (classCdForTaboo) {
          case MEDICINE:
            index = this.mstMedicineList.find(item => {
              return item.medicineCd === cd
            }).index;
            break;
          case EQUIPMENT:
            index = this.mstEquipmentList.find(item => {
              return item.equipmentCd === cd
            }).index;
            break;
          case DIALYZER:
            index = this.mstDialyzerList.find(item => {
              return item.dialyzerCd === cd
            }).index;
            break;
          case GENERIC_MEDICINE:
            index = this.sysGenericMedicineList.find(item => {
              return item.genericCd === cd
            }).index;
            break;
        }
        t.index = index;
      });
      //add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end

      //削除フラグ付与
      this.tabooAllergyDetailList = this.storeTabooAllergyDetailList.map(
        item => {
          return { ...item, isChecked: this.deleteCheck };
        }
      );

      //表示順序を整頓
      this.listSort(this.tabooAllergyDetailList);
      this.listSort(this.storeTabooAllergyDetailList);
      // add redmine 4538 宋qy end
    },

    /**
     * @description 禁忌対象一覧の表示順序整頓
     */
    listSort(target) {
      target.sort(function(taboo1, taboo2) {
        //各禁忌対象の区分を比較し、昇順で並び替え
        if (taboo1.classCd < taboo2.classCd) return -1;
        if (taboo1.classCd > taboo2.classCd) return 1;
        //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
        if (taboo1.index < taboo2.index) return -1;
        if (taboo1.index > taboo2.index) return 1;
        //mod #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
        //比較対象が同値の場合
        return 0;
      });
    },

    /**
     * @description フリーワード追加ボタン押下時の処理
     */
    selectFreeWord() {
      //フリーワードの禁忌対象コード,禁忌対象区分,削除フラグを禁忌対象一覧リストに追加
      this.tabooAllergyDetailList.push({
        cd: null,
        type: null,
        classCd: FREEWORD,
        name: "",
        deleteCheck: false
      });

      //ストア用禁忌対象一覧リストに選択した禁忌対象コード,禁忌対象区分を追加
      this.storeTabooAllergyDetailList.push({
        cd: null,
        type: null,
        classCd: FREEWORD,
        name: ""
      });

      this.editRecordClone.detailInfo = JSON.stringify(
        this.storeTabooAllergyDetailList
      );

      //禁忌対象一覧の更新
      this.refresh();
    },

    /**
     * @description フリーワード区分の禁忌対象名をストアに保存する
     * @param index
     */
    setName(index) {
      // 編集された禁忌対象名をストア保存用のリストにセット
      this.storeTabooAllergyDetailList[
        index
      ].name = this.tabooAllergyDetailList[index].name;
      this.editRecordClone.detailInfo = JSON.stringify(
        this.storeTabooAllergyDetailList
      );
    },

    calculateListHeight() {
      // 画面の高さ
      const fullHeight = getModalBodyElement(this.$el || this)?.clientHeight || 0;
      // ヘッダーの高さ
      const headHeight =
        (getScopedElementById("group-name-wrapper1", this.$el || this)?.clientHeight || 0) +
        (getScopedElementById("group-name-wrapper2", this.$el || this)?.clientHeight || 0) +
        (getScopedElementById("item-select-wrapper", this.$el || this)?.clientHeight || 0);
      // リストの高さを設定 (NOTE: 「margin-top: 5px」が3箇所設定されているのでその分を引く)
      this.listHeight = fullHeight - headHeight - 5 * 3;
    },
    sortPopoverValue(a, b) {
      let r = 0;
      if (a.value < b.value) {
        r = -1;
      } else if (a.value > b.value) {
        r = 1;
      }
      return r;
    },

    setContentData(newValue, index) {
      this.tabooAllergyDetailList[index].name = newValue;
      this.setName(index);
      getScopedElementById("com-textarea-free-word" + index, this.$el || this)?.parentNode?.classList?.remove("input-invalid");
    }
  }
};
</script>

<style scoped>
@media print {
  .list-area{
    height: auto !important;
  }
}
.input-required :deep(textarea){
  color: black;
  background-color: #ffff99;
}
.input-invalid :deep(textarea){
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

.main-taboo-area {
  margin: 0 5px;
  height: 100%;
}

.top-space {
  margin-top: 5px;
}

.item-word {
  border: solid 1px var(--ntss-list-border-color);
  padding: 4px;
  word-break: break-all;
}

.input-area {
  width: 100%;
  box-sizing: border-box;
  padding: 0;
}

.input-area-inhospital {
  width: 100%;
  box-sizing: border-box;
  padding: 0;
  height: 100%;
}

.list-main-area {
  margin-top: 5px;
}

.list-area {
  overflow-y: auto;
  --height: 500px;
  height: var(--height);
}

.select-button {
  margin: 4px 0 0 2px;
}

.dialyzer-select-button,
.freeword-select-button,
.generic-medicine-select-button {
  margin: 4px 0 0 2px;
}

.list-delete-header {
  width: 3em;
}

.list-class {
  width: 8em;
}

.list-header-item-name {
  width: 100%;
}

.allergy {
  padding: 2px 4px 2px 4px;
  box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border: solid 1px var(--ntss-list-border-color);
}

.allergy :deep(.text-input) {
  font-size: unset;
  display: flex;
  align-items: center;
}

textarea {
  width: 100%;
  resize: none;
  box-sizing: border-box;
}

div :deep(.text-input) {
  width: 100%;
  height: 100%;
}

div :deep(.text-input:focus) {
  border-top: 2px solid #9A9A9A;
  border-left: 2px solid #9A9A9A;
  border-bottom: 2px solid #EEEEEE;
  border-right: 2px solid #EEEEEE;
}

.custom-select-button :deep(ons-button) {
  font-size: unset;
  width: auto;
}

.custom-list-area :deep(ons-col) {
  display: flex;
  align-items: center;
}

.custom-list-area .allergy :deep(div) {
  width: 100%;
}

.ntss-list {
  position: relative;
  table-layout: fixed;
}

th.ntss-list-header-th-sticky {
  z-index: 1;
}

.ntss-list tr:nth-child(2n) {
  background-color: transparent !important;
}

.ntss-list tr:hover {
  background-color: transparent !important;
}

.button-delete {
  display: block;
  margin: auto;
}
:deep(.custom-textarea){
  background-color: #ffff99;
}
</style>
