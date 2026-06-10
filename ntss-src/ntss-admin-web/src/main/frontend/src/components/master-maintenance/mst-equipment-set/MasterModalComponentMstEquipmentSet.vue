/**
 * マスタメンテナンス機能 医療材料セットマスタ 医療材料セットマスタ詳細.
 * <p>マスタの取得基準: 削除済み・期限切れも含めた医療材料およびダイアライザ(ともに並び順(mst_selector)の考慮あり)</p>
 *
 * <p>マスタ選択ポップオーバー画面における選択項目一覧、選択項目で医療材料とダイアライザのコード重複を回避するため<br />
 * ダイアライザのコンポーネント内部展開コードはdialyzer{n}とする(例. 10(DB上のダイアライザのコード) -> "dialyzer10")。</p>
 *
 */
 <template>
  <div>
    <div class="equip-set-info">
      <v-ons-row class="row-height">
        <v-ons-col class="item-title">医療材料セット名</v-ons-col>
        <v-ons-col class="item-data item-input">
          <custom-input
            :value="equipmentSetInfo.equipmentSetName"
            @blur="onNameChange()"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">省略医療材料セット名</v-ons-col>
        <v-ons-col class="item-data item-input">
          <custom-input
            :value="equipmentSetInfo.equipmentSetShortName"
            @blur="onShortNameChange()"
          />
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col class="item-title">連携コード1</v-ons-col>
        <v-ons-col class="item-data">
          <custom-input
            :value="equipmentSetInfo.equipmentSetInHospitalCd1"
            @blur="onInHospitalCd1Change()"
          />
        </v-ons-col>
        <v-ons-col class="item-title">連携コード2</v-ons-col>
        <v-ons-col class="item-data">
          <custom-input
            :value="equipmentSetInfo.equipmentSetInHospitalCd2"
            @blur="onInHospitalCd2Change()"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="frame">
        <v-ons-col class="item-title">
          <v-ons-col>セット情報</v-ons-col>
            <v-ons-col>
            <!-- mod 画面デザイン 對應 王 start-->
            <!-- <v-ons-button class="item-button" @click="addEquipmentSet()">-->
            <v-ons-button class="item-button btn3-normal" @click="addEquipmentSet()">
              追加
            </v-ons-button>
          </v-ons-col>
        </v-ons-col>
        <v-ons-col class="item-data item-input data-table print-height-auto">

          <div class="detail-list">
            <table class="ntss-list sticky_table" style="position: relative;table-layout: fixed;">
              <thead display="block">
              <tr>
                <th class="ntss-list-header-th-sticky material-info color-header list-name">医療材料名</th>
                <th class="ntss-list-header-th-sticky num-info color-header list-num">数量</th>
                <th class="ntss-list-header-th-sticky num-info color-header list-unit">単位</th>
                <th class="ntss-list-header-th-sticky delete-info color-header list-delete"/>
              </tr>
              </thead>
              <tr v-for="(column, index) in dispArr" :key="column.id">
                <!-- 医療材料名 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <v-ons-col class="item-data material-info medi-name-wrapper">
                    <custom-input
                      :value="dispArr[index].cd"
                      :display-string="
                    setInitialEquipmentInputValue(dispArr[index].cd.editValue, dispArr[index].equip_type.editValue).name
                  "
                      class="material-info-field"
                      disabled
                    />
                    <v-ons-button
                      style="margin-bottom: 5px;"
                      :ref="index"
                      class="select-button btn3-normal"
                      @click="selectEquipment(index, dispArr[index].cd.editValue, dispArr[index].equip_type.editValue)"
                    >
                      選択
                    </v-ons-button>
                  </v-ons-col>
                </td>

                <!-- 数量 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <v-ons-col class="item-data num-info" align="center">
                    <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng start -->
                    <!-- <custom-input-number
                      :value="dispArr[index].amount"
                      :digits="4"
                      :min-value="1"
                      :max-value="9999"
                      style="width:100%;min-width: 100px"
                      @change="changeDown(index)"
                      @wheel="changeDown(index)"
                    /> -->
                    <custom-input-number-pro
                      :value="dispArr[index].amount.editValue"
                      :step="1"
                      :invalidArray="['0']"
                      :required="true"
                      :min="0"
                      :max="9999"
                      @change="changeDown(index)"
                      @handlerInput="(val) =>{ dispArr[index].amount.editValue = val;}"
                    />
                    <!-- #9848+9849 数値IFのスタイル全不正 linjunfeng end -->
                  </v-ons-col>
                </td>

                <td class="ntss-list-body-td ntss-list-body-td-background">
                  {{ setInitialEquipmentInputValue(dispArr[index].cd.editValue, dispArr[index].equip_type.editValue).unit }}
                </td>

                <!-- 削除 -->
                <td class="ntss-list-body-td ntss-list-body-td-background">
                  <button class="ntss-btn-outset button-delete" @click="delEquipmentSet(index)">
                    <v-ons-icon icon="fa-trash"/>
                  </button>
                </td>
              </tr>
            </table>
          </div>
        </v-ons-col>
    </v-ons-row>
    <!-- 医療材料選択ボタンポップオーバー(共通部品 医療材料選択(有効なマスタからの選択)用) -->
    <pop-over v-bind="this.popoverDataValidEquipment"
      :target-position-element="popoverTargetElement(buttonPosi)"
      @popover-return="selectedEquip($event, buttonPosi)"
      @popover-close="closePopover()"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";

// [共通部品] UI関連
import customInput from "@/components/common/custom-form-tags/CustomInput";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox";
//#8484　医療材料選択IFのリスト不正　Start
// 共通部品 医療材料選択(有効なマスタからの選択)
import ValidEquipmentSelectMixin from "@/components/ValidEquipmentSelectMixin";
//#8484　医療材料選択IFのリスト不正　End
// 部材(医療材料・ダイアライザ)の医療材料区分 equipType に関する共通関数
import { 
  encryptPersistentCodeToInternalCd, 
  decryptDialyzerCdToPersistentCode, 
  detectEquipTypeFromCode 
} from "@/functions/EquipTypeFunctions";

import { EventBus } from "@/eventBus";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add #9848+9849 数値IFのスタイル全不正 linjunfeng end

export default {
  mixins: [ValidEquipmentSelectMixin],
  name: "MstEquipmentSet",
  components: {
    "custom-input": customInput,
    "custom-input-number": customInputNumber,
    "custom-checkbox": customCheckbox,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #9848+9849 数値IFのスタイル全不正 linjunfeng end
  },

  props: {
    /** 共通部品 医療材料選択(有効なマスタからの選択)の再描画を制御する */
    subComponentReload: {
      type: Boolean,
      default: true
    }
  },

  data() {
    return {
      equipmentSetInfo: {
        equipmentSetName: { initValue: "", editValue: "" }, // 医療材料セット名
        equipmentSetShortName: { initValue: "", editValue: "" }, // 省略医療材料セット名
        equipmentSetInHospitalCd1: { initValue: "", editValue: "" }, // 連携コード1
        equipmentSetInHospitalCd2: { initValue: "", editValue: "" }, // 連携コード2
        setInfoJsonStr: "", // (医療材料)セット情報(mst_equipment_setテーブルのset_infoカラム)
        setInfoJsonArr: [], // 内部処理用
        setInfoJsonArrCustom: [] // 画面表示用
      },
      //医療材料分類マスタ
      mstEquipmentClass: [],
      //クリックした医材選択ボタンの位置
      buttonPosi: null,
      //医療材料マスタ
      mstEquipment: [],
      // ダイアライザマスタ
      mstDialyzer: [],

      /**
       * @description 「医療材料」初期値・編集フィールド.
       */
       equipmentInputValue: {
        initValue: null,
        editValue: null
      },
    };
  },

  computed: {
    //施設コード取得用
    ...mapGetters("master-maintenance", {
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      facilityCd: "getFacilitySwitch",
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", ["getFontSize"]),
    //操作対象の医療材料セットの医療材料一覧(画面表示用パラメータの変数名を短く置き換え)
    dispArr() {
      return this.equipmentSetInfo.setInfoJsonArrCustom;
    },
  },

  watch: {
    dispArr: {
      handler() {
        //医療材料名称、数量を変更した際、セット情報をストアに格納
        this.onSetInfoChange();
      },
      deep: true
    },
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
    },
  },

  async created() {
    // 画面の表示状態を初期化
    this.setLoadingScreenVisible(true);
    // 医療材料セット情報から内部処理用・表示用ローカル配列を生成する
    this.buildEquipmentSetArr();
  },

  mounted() {
    this.$nextTick(() => {
      // 医療材料一覧の表示高さを再計算.
      this.calculateDataListHeight();
    })
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },

  /**
   * コンポーネント破棄前.
   */
   beforeDestroy() {
    // dataの初期化(メモリリークに対する基本的な対応)
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]), // 共通ローダー・表示状態(true: 表示, false: 非表示)

    /**
     * @description 医療材料用ポップオーバーを表示
     */
     selectEquipment(index, equipmentCd, equipType) {
      if (index == null) {return;}
      //選択したボタンの位置を格納
      this.buttonPosi = index;
      // 選択済医療材料
      const selectedItem = this.mstEquipmentDialyzerIncludedDeleted.find(
        // ダイアライザの場合のcdは内部展開したコードで比較(例. 10 -> "dialyzer10")
        equipment => equipment.value == encryptPersistentCodeToInternalCd(equipmentCd, equipType)
      ); 
      this.popoverDataValidEquipment.popoverContentSelected = selectedItem || {};
      //ポップオーバー表示
      this.createPopoverData();
    },

    /**
     * 医材選択ボタン押下時のポップオーバー表示位置を取得.
     * ポップオーバーの表示位置を取得(医材選択ボタン押下時はそのボタンの位置(this.$refs[index][0]))
     * @param {Number} クリックされた選択ボタンの位置(インデックス).
     * @return {Element} クリックされた選択ボタン要素.
     */
     popoverTargetElement(index) {
      // 詳細画面描画前に呼ばれた場合にはポップオーバー表示をキャンセルする考慮
      if (index === null) {
        this.closePopover();
      }
      const position = index === null ? null : this.$refs[index][0];
      return position;
    },

    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した医療材料情報
     */
     selectedEquip(event, index) {
      //選択した医療材料名称とその分類を表示用・保存用パラメータに格納
      this.equipChange(event, index);
      //選択したボタンの場所データをリセット
      this.buttonPosi = null;
    },

    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
    },

    /**
     * 共通部品 医療材料選択(有効なマスタからの選択)と数量入力に渡す医療材料fieldsDataの生成.
     * @param {Object} equipment 表示用ローカル配列(dispArr)の医療材料.
     * @return {Object} objFieldsData 共通部品 医療材料選択(有効なマスタからの選択)と数量入力に渡す医療材料(fieldsData).  
     */
    buildFieldsData(equipment, listIndex) {
      let objFieldsData = {
        cd: null,
        amount: 0, 
        unit: null,
        needleType: null,
        equipType: 0, 
        id: listIndex, // 医療材料一覧のうち、医療材料を識別するためのインデックス
      };
      if(equipment == undefined) {return objFieldsData;}
      objFieldsData.cd = equipment.cd.editValue || null;
      objFieldsData.amount = equipment.amount.editValue || 0;
      objFieldsData.equipType = equipment.equip_type.editValue || 0;

      return objFieldsData;
    },

    /**
     * 医療材料セット情報から内部処理用・表示用ローカル配列を生成する
     */
    buildEquipmentSetArr() {
      // 内部処理用ローカル配列(医療材料セットのDB永続化用)に、入力項目(初期値・編集値)を編集
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "name") {
          this.equipmentSetInfo.equipmentSetName.initValue = this.getValueByField(
            this.columnDefinition[num].field
          );
          this.equipmentSetInfo.equipmentSetName.editValue = this.equipmentSetInfo.equipmentSetName.initValue;
        } else if (this.columnDefinition[num].field === "equipmentSetShortName") {
          this.equipmentSetInfo.equipmentSetShortName.initValue = this.getValueByField(
            this.columnDefinition[num].field
          );
          this.equipmentSetInfo.equipmentSetShortName.editValue = this.equipmentSetInfo.equipmentSetShortName.initValue;
        } else if (this.columnDefinition[num].field === "inHospitalCd1") {
          this.equipmentSetInfo.equipmentSetInHospitalCd1.initValue = this.getValueByField(
            this.columnDefinition[num].field
          );
          this.equipmentSetInfo.equipmentSetInHospitalCd1.editValue = this.equipmentSetInfo.equipmentSetInHospitalCd1.initValue;
        } else if (this.columnDefinition[num].field === "inHospitalCd2") {
          this.equipmentSetInfo.equipmentSetInHospitalCd2.initValue = this.getValueByField(
            this.columnDefinition[num].field
          );
          this.equipmentSetInfo.equipmentSetInHospitalCd2.editValue = this.equipmentSetInfo.equipmentSetInHospitalCd2.initValue;
        } else if (this.columnDefinition[num].field === "setInfo") {
          this.equipmentSetInfo.setInfoJsonStr = this.getValueByField(
            this.columnDefinition[num].field
          );

          // this.equipmentSetInfoが存在しない場合(JSONパースエラーが出る)の考慮を追加
          if (this.equipmentSetInfo && this.equipmentSetInfo.setInfoJsonStr && this.equipmentSetInfo.setInfoJsonStr !== null) {
            if (this.equipmentSetInfo.setInfoJsonStr.length !== 0) {
              // セット情報はJSONなので、配列に置換
              this.equipmentSetInfo.setInfoJsonArr = JSON.parse(
                this.equipmentSetInfo.setInfoJsonStr
              );
            }
          }
        }
      }

      // 表示用ローカル配列(画面の表示要素の制御用)に、入力項目(材料コード・数量・医療材料区分・画面上の削除フラグ("1": 画面操作者から削除の指示(デフォルト:0)))を編集
      for (const i in this.equipmentSetInfo.setInfoJsonArr) {
        this.dispArr.splice(i, 1, {
          id: _.uniqueId("equipment"),
          cd: {
            initValue: this.equipmentSetInfo.setInfoJsonArr[i].cd,
            editValue: this.equipmentSetInfo.setInfoJsonArr[i].cd
          },
          amount: {
            initValue: this.equipmentSetInfo.setInfoJsonArr[i].amount >0 && this.equipmentSetInfo.setInfoJsonArr[i].amount <  9999 ? this.equipmentSetInfo.setInfoJsonArr[i].amount: 0,
            editValue: this.equipmentSetInfo.setInfoJsonArr[i].amount >0 && this.equipmentSetInfo.setInfoJsonArr[i].amount <  9999 ? this.equipmentSetInfo.setInfoJsonArr[i].amount: 0,
          },
          equip_type: {
            initValue: this.equipmentSetInfo.setInfoJsonArr[i].hasOwnProperty("equip_type") ? this.equipmentSetInfo.setInfoJsonArr[i].equip_type : 0,
            editValue: this.equipmentSetInfo.setInfoJsonArr[i].hasOwnProperty("equip_type") ? this.equipmentSetInfo.setInfoJsonArr[i].equip_type : 0
          },
          del_check: {
            initValue: "0",
            editValue: "0"
          }
        });
      }
    },

    /** 
     * 追加する医療材料の初期値設定、および画面上の行追加. 
     */
    addEquipmentSet() {
      this.equipmentSetInfo.setInfoJsonArr.push({
        cd: "",
        // add 9973 -4 by kangjie 20231025 start
        // amount: 1,
        amount: "1",
        // add 9973 -4 by kangjie 20231025 end
        equip_type: null
      });
      this.dispArr.push({
        id: _.uniqueId("equipment"),
        cd: { initValue: "", editValue: "" },
        // add 9973 -4 by kangjie 20231025 start
        // amount: { initValue: 1, editValue: 1 },
        amount: { initValue: "1", editValue: "1" },
        // add 9973 -4 by kangjie 20231025 end
        equip_type: { initValue: null, editValue: null },
        del_check: { initValue: "0", editValue: "0" }
      });
      this.changeButton();

      // 医療材料一覧の最下部までスクロールする
      this.$nextTick(() => {
        const ele = document.getElementsByClassName("data-table")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
    },

    /**
     * 削除を指定された医療材料を医療材料セット一覧より削除.
     */
    delEquipmentSet(i) {
      // 表示用ローカル配列から指示された医療材料を削除する
      this.equipmentSetInfo.setInfoJsonArr.splice(i, 1);
      this.dispArr.splice(i, 1);
      this.changeButton();
      // 共通部品 医療材料選択(有効なマスタからの選択と数量入力)の画面の再表示を指示し、
      // 最新の医療材料セット一覧(ただしDB永続化前の状態)を表示する
      this.doSubComponentReload();
    },

    // 医療材料セット名変更
    onNameChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "name") {
          this.updateEditRecord(
            "name",
            this.equipmentSetInfo.equipmentSetName.editValue
          );
        }
      }
      if (this.equipmentSetInfo.equipmentSetName.initValue!=this.equipmentSetInfo.equipmentSetName.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },

    // 連携コード1変更
    onInHospitalCd1Change() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "inHospitalCd1") {
          this.updateEditRecord(
            "inHospitalCd1",
            this.equipmentSetInfo.equipmentSetInHospitalCd1.editValue
          );
        }
      }
       if (this.equipmentSetInfo.equipmentSetInHospitalCd1.initValue!=this.equipmentSetInfo.equipmentSetInHospitalCd1.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },

    // 連携コード2変更
    onInHospitalCd2Change() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "inHospitalCd2") {
          this.updateEditRecord(
            "inHospitalCd2",
            this.equipmentSetInfo.equipmentSetInHospitalCd2.editValue
          );
        }
      }
      if (this.equipmentSetInfo.equipmentSetInHospitalCd2.initValue!=this.equipmentSetInfo.equipmentSetInHospitalCd2.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },

    // 省略医療材料セット名変更
    onShortNameChange() {
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "equipmentSetShortName") {
          this.updateEditRecord(
            "equipmentSetShortName",
            this.equipmentSetInfo.equipmentSetShortName.editValue
          );
        }
      }
       if (this.equipmentSetInfo.equipmentSetShortName.initValue!=this.equipmentSetInfo.equipmentSetShortName.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },

    changeDown(index){
      if (this.dispArr[index].amount.initValue!=this.dispArr[index].amount.editValue) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },
    /**
     * 選択した医療材料名称を表示用・保存用パラメータに格納する処理.
     * @param {Object} fieldsData 医療材料選択(有効なマスタからの選択)のfieldsData.
     * @param {Number} index 医療材料一覧のうちの更新した医療材料のインデックス.
     */
    equipChange(fieldsData, index) {
      // 医療材料の追加の場合はindexは最後尾と解釈
      index = index == undefined ? this.dispArr.length - 1 : index;

      this.dispArr[index].cd.editValue = decryptDialyzerCdToPersistentCode(fieldsData.value);
      this.dispArr[index].equip_type.editValue = detectEquipTypeFromCode(fieldsData.value);

      if (this.dispArr[index].cd.editValue == this.dispArr[index].cd.initValue && 
          this.dispArr[index].equip_type.editValue == this.dispArr[index].equip_type.initValue) {
            EventBus.$emit("mstHolidayRegistered", true);
      } else {
            this.changeButton();
      }
    },

    /**
     * 医療材料名称・数量を変更した際に情報をストアに格納.
     */
    onSetInfoChange() {
      for (const i in this.equipmentSetInfo.setInfoJsonArr) {
        this.equipmentSetInfo.setInfoJsonArr[i].cd = this.dispArr[i].cd.editValue;
	// add 9973 -4 by kangjie 20231026 start
        this.equipmentSetInfo.setInfoJsonArr[i].amount = this.dispArr[i].amount.editValue + "";
	// add 9973 -4 by kangjie 20231026 end
        this.equipmentSetInfo.setInfoJsonArr[i].equip_type = this.dispArr[i].equip_type.editValue;
      }
      //保存用パラメータをコピー
      const saveArr = Array.from(this.equipmentSetInfo.setInfoJsonArr);

      //材料が選択されていない or 数量がnullの場合は保存パラメータから除外
      for (let i = saveArr.length - 1; i > -1; i--) {
        const saveCd = saveArr[i].cd;
        const saveNum = saveArr[i].amount;
        if (!saveCd || saveNum === null) {
          //保存用パラメータから削除
          saveArr.splice(i, 1);
        }
      }

      // 医療材料セットの更新
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "setInfo") {
          this.equipmentSetInfo.setInfoJsonStr = JSON.stringify(saveArr);
          this.updateEditRecord(
            "setInfo",
            this.equipmentSetInfo.setInfoJsonStr
          );
        }
      }
    },

    /**
     * 共通部品 医療材料選択(有効なマスタからの選択と数量入力)の画面の再表示を指示する.
     */
    doSubComponentReload() {
      this.subComponentReload = false;
      this.$nextTick(() => (this.subComponentReload = true));
    },

    /**
     * @description 医療材料一覧の表示高さを再計算.
     */
    calculateDataListHeight(){
      let infoHeight = document.getElementsByClassName("equip-set-info")[0].clientHeight;
      let totalHeight = document.getElementsByClassName("modal-container")[0].clientHeight;
      let topHeight = document.getElementsByClassName("toolbar")[0].clientHeight;
      let bottomHeight = document.getElementsByClassName("modal-footer")[0].clientHeight;
      let dataList = document.getElementsByClassName("data-table")[0]

      let actualHeight = totalHeight - topHeight - bottomHeight - infoHeight - 9;

      dataList.style.height = actualHeight + "px";
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng start
    validateOnRegistration() {
      let amountFlg = true;
      for (let i = 0; i < this.dispArr.length; i++) {
        if (this.dispArr[i].amount.editValue == "" || isNaN(this.dispArr[i].amount.editValue) || this.dispArr[i].amount.editValue == 0) {
          amountFlg = false;
        }
      }
      if (!amountFlg) {
        // エラーメッセージ表示
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000170].title,
          message: DIALOG_MESSAGES[13000170].message
        });
        return false;
      }
      return true;
    },
    // add #9848+9849 確定時,薬剤指定済みの場合、必須チェック（空と0を区別する） linjunfeng end
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.setInfo-list {
  height: 62vh;
  border-left: 1px solid;
  border-right: 1px solid;
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

.item-button, .select-button {
  width: 60px;
}

.item-button {
  padding: 0;
  margin-left: 2px;
  margin-block: 2px;
}

.select-button {
  padding: 1px;
  margin: 2px 0 0 2px;
}

/* 項目名 */
.item-title {
  max-width: 11em;
  margin-left: 5px;
}

/* 項目内容 */
.item-data {
  padding-right: 3px;
  padding-left: 3px;
  padding-bottom: 3px;
}
.item-data.select-button {
  box-align: right;
}

/* 削除チェックボックスの疑似中央揃え */
.delete-info>label {
  display:block; 
  padding: 0px calc((100% - 1.3em)/2);
}

.material-info {
  flex: max-content;
}
/* 医療材料名フィールド */
.material-info-field {
  /* フィールドの幅 = TD幅 - ボタン幅 */
  width: calc(100% - 60px);
  min-width: 11em;
}

.num-info {
  flex: 0 0 25%;
}

@media screen and (max-height: 510px) {
  .setInfo-list {
    height: 36vh;
  }
}
@media screen and (max-height: 610px) and (min-height: 510px) {
  .setInfo-list {
    height: 43vh;
  }
}
@media screen and (max-height: 740px) and (min-height: 610px){
  .setInfo-list {
    height: 50vh;
  }
}
@media screen and (max-height: 830px) and (min-height: 740px){
  .setInfo-list {
    height: 56vh;
  }
}
@media screen and  (min-width:480px) and (max-width:869px) {
  .setInfo-list {
    height: 56vh;
  }
}
@media screen and (max-width: 667px) {
  .setInfo-list >>> .item-title {
    max-height: 62px;
  }
}
@media screen and (max-width: 375px) {
  .setInfo-list >>> .item-title {
    max-height: 62vh;
  }
}
.frame{
  border: 1px solid black;
}

.data-table {
  display: block;
  overflow-x: auto;
}
.data-table >>> ons-row {
  min-width: 640px;
}
@media screen and (max-width: 667px) {
  .setInfo-list >>> .item-title {
    max-height: 62px;
  }
  .data-table {
    display: block;
    overflow-x: auto;
  }
}
@media screen and (max-width: 375px) {
  .setInfo-list >>> .item-title {
    max-height: 62vh;
  }
  .data-table {
    display: block;
    overflow-x: auto;
    /* max-height: 49vh; */
  }
}
/* 一覧領域の幅
 * 各項目の幅：37em
 * 各項目のマージンなど：10px * 7
 * 選択ボタンの幅：60px
 */
.detail-list {
  min-width: calc(36em + 10px * 7 + 60px);
}
.list-delete {
  width: 3em;
}
.list-name {
  width: 100%;
  min-width: calc(11em + 60px);
}
.list-num {
  width: 10em;
}
.list-unit {
  width: 12em;
}
/* 医療材料名（データ行）の表示調整 */
.medi-name-wrapper {
  white-space: nowrap;
}
/* 削除ボタン */
.button-delete {
  display: block;
  margin: auto;
}
</style>
