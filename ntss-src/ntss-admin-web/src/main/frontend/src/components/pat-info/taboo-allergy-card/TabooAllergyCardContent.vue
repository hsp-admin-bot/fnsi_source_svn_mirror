<template>
  <div>
    <v-ons-button ref="showAllTabooAllergy" @click="allTabooAllergyVisible = true" class="btn-ntss-custom btn3-normal">
      禁忌・アレルギー全表示
    </v-ons-button>
    <!-- 禁忌・アレルギー内容全表示ポップオーバー -->
    <v-ons-popover
      v-if="allTabooAllergyVisible"
      cancelable
      :class="[fontSizeSet, 'vons-popover']"
      :visible.sync="allTabooAllergyVisible"
      :target="$refs.showAllTabooAllergy"
      :direction="
        popoverDisplayDirection(
          $refs.showAllTabooAllergy,
          allTabooAllergyVisible
        )
      "
      mask-color="rgba(0, 0, 0, 0)"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="taboo-allergy-detail-div">
        <taboo-allergy-detail class-name="禁忌" v-bind="allTabooDetailName" />
        <taboo-allergy-detail
          class-name="アレルギー"
          v-bind="allAllergyDetailName"
        />
      </div>
    </v-ons-popover>
    <draggable
      v-model="jsonArray"
      v-bind="{
        animation: 200,
        delay: 10,
        disabled: !actionMode,
        forceFallback: true
      }"
    >
      <div
        v-for="(json, index) in jsonArray"
        :key="index"
        :class="classObjectItem(json)"
      >
        <table class="card-table">
          {{
            index + 1
          }}
          <!-- mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start -->
          <button
            v-show="actionMode"
            class="button-delete ntss-btn-outset"
            @click="setJsonIndex(json, index)"
          >
            <v-ons-icon icon="fa-trash"/>
          </button>
          <!-- mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 end -->
          <br />
          <tr>
            <td></td>
            <td class="item-data" colspan="2">
              <!-- JSON配列のラジオボタンは"name"に必ずindexを付与 -->
              <custom-radio
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :value="getPatDataJsonArray(json, 'taboo_allergy_class')"
                :name="'taboo-allergy-class' + index"
                radio-value="1"
              >
                禁忌
              </custom-radio>
              <custom-radio
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :value="getPatDataJsonArray(json, 'taboo_allergy_class')"
                :name="'taboo-allergy-class' + index"
                radio-value="2"
              >
                アレルギー
              </custom-radio>
            </td>
          </tr>
          <tr>
            <td class="item-title">内容</td>
            <td class="item-data">
              <!-- mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start -->
              <custom-input
                v-if="isClassTabooAllergy(json)"
                :value="getPatDataJsonArray(json, 'content')"
                :display-string="tabooAllergyContent(json)"
                :disabled="hasCd(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                readonly="readonly"
                @focus="addFocusEvent($event)"
                ref="content_name"
                :is-required="json.ctl_no.editValue >= 0"
                form-name="内容"
              />
              <custom-input
                v-else
                :value="getPatDataJsonArray(json, 'content')"
                :display-string="variousMstContent(json)"
                :disabled="hasCd(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                readonly="readonly"
                @focus="addFocusEvent($event)"
              />
            </td>
            <td class="item-data">
              <v-ons-button
                :ref="'selectMst' + index"
                class="common-style-select-button btn3-normal pat-btn-margin-right"
                @click="selectContent(index)"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              >
                選択
              </v-ons-button>
              <v-ons-button
                class="common-style-select-button btn2-cancel pat-btn-margin-right"
                :disabled="isEmptyContent(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                style="width: 4em !important;"
                @click="clearCd(json)"
              >
                クリア
              </v-ons-button>
              <v-ons-button
                v-show="isClassTabooAllergy(json)"
                :ref="'showDetail' + index"
                class="common-style-select-button btn3-normal"
                :disabled="isEmptyContent(json) || getIsOtherFacility"
                @click="showTabooAllergyDetail(index)"
              >
                詳細
              </v-ons-button>
            </td>
          </tr>
          <tr>
            <td class="item-title">備考</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :content="getPatDataJsonArray(json, 'memo')"
                :idTextarea="'com-textarea-taboo-allergy-memo'+index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event, 'memo', index)"
              />
            </td>
          </tr>
        </table>
      </div>
    </draggable>
    <!-- 禁忌・アレルギー選択ポップオーバー -->
    <pop-over
      v-bind="popoverData"
      :target-position-element="popoverTargetElementMst"
      @popover-return="setTabooAllergy($event.value, $event.text)"
      @popover-close="closePopover(popoverData)"
    />
    <!-- 禁忌・アレルギー内容詳細ポップオーバー -->
    <v-ons-popover
      v-if="tabooAllergyDetailVisible"
      cancelable
      :class="[fontSizeSet, 'vons-popover']"
      :visible.sync="tabooAllergyDetailVisible"
      :target="popoverTargetElementDetail"
      :direction="
        popoverDisplayDirection(
          popoverTargetElementDetail,
          tabooAllergyDetailVisible
        )
      "
      mask-color="rgba(0, 0, 0, 0)"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="taboo-allergy-detail-div">
        <taboo-allergy-detail v-bind="selectedTabooAllergyDetailName" />
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import _ from "underscore";
import { deduplicateObjects } from "@/functions/common/CommonFunctions";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import tabooAllergyDetail from "@/components/pat-info/taboo-allergy-card/TabooAllergyDetail";
import { mapGetters, mapActions } from "vuex"; //施設コード取得のために追加
import PopoverMixin from "@/components/PopoverMixin";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { PAT_HEADER } from "@/components/pat-info/PatInfoConfig.js"

// 禁忌・アレルギー区分定数
const classTaboo = "1"; // 禁忌
const classAllergy = "2"; // アレルギー

// 禁忌・アレルギー詳細区分定数
const classMedicine = "1"; // 薬剤
// 9987 by kangjie 20231215 start
const classMedicineMix = "2";
// 9987 by kangjie 20231215 end
const classEquipment = "3"; // 医療材料
const classDialyzer = "4"; // ダイアライザ
const classFreeWord = "5"; // フリーワード
const classGenericMedicine = "6"; // 一般名処方

const DELETED = "【削除済み】"
const INCLUDE_DELETED = "【削除済み含む】"

export default {
  name: "TabooAllergyCard",
  components: {
    "taboo-allergy-detail": tabooAllergyDetail
  },

  mixins: [baseCardContent, PopoverMixin],

  data() {
    return {
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 じょはく start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 じょはく end
      // del #10359 編集権限の動作不正 dengshen end
      // JSON配列カラム名
      arrayColName: "taboo_allergy_info",

      // 各種マスタ格納オブジェクト
      mstTabooAllergy: null,
      mstMedicine: null,
      mstMedicineMix: null,
      mstEquipment: null,
      mstDialyzer: null,
      sysGenericMedicine: null,

      // マスタ選択ポップオーバー用オブジェクト
      popoverData: {},

      // 選択した要素番号を保持
      selectedIndex: null,

      // 禁忌・アレルギー詳細表示フラグ
      tabooAllergyDetailVisible: false,
      allTabooAllergyVisible: false,

      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isInitFinished: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end

      /**
       * @description 画面の高さ(レスポンシブ対応)
       */
      windowHeight: window.innerHeight,

      /**
       * @description 画面の幅(レスポンシブ対応)
       */
      windowWidth: window.innerWidth,

    };
  },
  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end

  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
    // 禁忌・アレルギーのJSON配列
    jsonArray: {
    // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start
      get() {
        let arrVendorContact = [];
        for (var VendorInf of this.editRecord[this.arrayColName]) {
          arrVendorContact.push(VendorInf);
        }
        // mod bug 7778 修正 chen start
        // mod FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 仕様変更 周 start
        return arrVendorContact;
        // return this.sortByDispOrder(arrVendorContact);
        // mod FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 仕様変更 周 end
        // mod bug 7778 修正 chen end
        // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 end
      },

      // draggableで並び替えた後に配列を書き換える
      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },

    // 選択された項目のJSON配列要素
    selectedTabooAllergyInfo() {
      if (this.selectedIndex === null) {
        return null;
      }
      return this.jsonArray[this.selectedIndex];
    },
    // マスタ選択ポップオーバーの表示位置とする対象コンポーネント
    popoverTargetElementMst() {
      return this.getPopoverTargetElement("selectMst");
    },

    // 禁忌・アレルギー詳細ポップオーバーの表示位置とする対象コンポーネント
    popoverTargetElementDetail() {
      return this.getPopoverTargetElement("showDetail");
    },

    // 選択された禁忌・アレルギー詳細
    selectedTabooAllergyDetail() {
      if (!_.has(this.selectedTabooAllergyInfo, "taboo_allergy_cd")) {
        return;
      }

      // 選択された禁忌・アレルギーのマスタコードを取得
      const targetCd = this.selectedTabooAllergyInfo.taboo_allergy_cd.editValue;

      const detail = [];

      if (targetCd !== null) {
        // マスタから内容の詳細を取得
        const targetMst = this.mstTabooAllergy.find(
          mst => mst.tabooAllergyCd === targetCd
        );
        // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240320 ztc start
        // if (targetMst !== undefined) {
        if (targetMst !== undefined && !!targetMst.detailInfo) {
          // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 20240320 ztc end
          // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
          // detail.push(...JSON.parse(targetMst.detailInfo));
          const detailInfo = JSON.parse(targetMst.detailInfo).map(item => {
            return {
              ...item,
              // 禁忌アレルギーコード
              tabooAllergyCd: targetMst.tabooAllergyCd,
              // 参照先禁忌アレルギーが削除されているかを示すフラグ
              tabooAllergyDeleted: targetMst.isDisp === "0" || targetMst.isDel === "1"
            }
          })
          detail.push(...detailInfo);
          // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
        } else {
          return;
        }
      } else {
        const detailInfo = {cd: null,
                            name: this.selectedTabooAllergyInfo.content.editValue,
                            classCd: classFreeWord,
          // add #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
                            tabooAllergyCd: this.selectedTabooAllergyInfo.taboo_allergy_cd.editValue,
                            tabooAllergyDeleted: false,
          // add #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
                            type: null};
        detail.push(detailInfo);
      }
      return detail;
    },

    // 選択した禁忌・アレルギー詳細に含まれる薬剤名称
    selectedTabooAllergyMedicine() {
      return this.extractMedicineNameFromDetail(
        this.selectedTabooAllergyDetail
      );
    },
    // add 9987 by kangjie 20231215 start
    // del #9981 5430 余計なコーディングの削除 limf start
    // 選択した禁忌・アレルギー詳細に含まれる調整薬剤名称
    selectedTabooAllergyMedicineMix() {
      return this.extractMedicineMixNameFromDetail(
        this.selectedTabooAllergyDetail
      );
    },
    // del #9981 5430 余計なコーディングの削除 limf end
    // add 9987 by kangjie 20231215 start
    // 選択した禁忌・アレルギー詳細に含まれる医療材料名称
    selectedTabooAllergyEquip() {
      return this.extractEquipNameFromDetail(this.selectedTabooAllergyDetail);
    },

    // 選択した禁忌・アレルギー詳細に含まれるダイアライザ名称
    selectedTabooAllergyDialyzer() {
      return this.extractDialyzerNameFromDetail(
        this.selectedTabooAllergyDetail
      );
    },

    // 選択した禁忌・アレルギー詳細に含まれる一般名処方名称
    selectedTabooAllergyGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(
        this.selectedTabooAllergyDetail
      );
    },

    // 選択した禁忌・アレルギー詳細に含まれるフリーワード名称
    selectedTabooAllergyFreeWord() {
      return this.extractFreeWordNameFromDetail(
        this.selectedTabooAllergyDetail
      );
    },

    // 各区分の名称を集めた詳細表示ポップオーバー用オブジェクト
    selectedTabooAllergyDetailName() {
      return {
        medicine: this.selectedTabooAllergyMedicine,
        // add 9987 by kangjie 20231215 start
        // del #9981 5430 余計なコーディングの削除 limf start
        medicineMix: this.selectedTabooAllergyMedicineMix,
        // del #9981 5430 余計なコーディングの削除 limf end
        // add 9987 by kangjie 20231215 end
        equip: this.selectedTabooAllergyEquip,
        dialyzer: this.selectedTabooAllergyDialyzer,
        genericMedicine: this.selectedTabooAllergyGenericMedicine,
        freeWord: this.selectedTabooAllergyFreeWord
      };
    },

    // 全ての禁忌詳細
    allTabooDetail() {
      return this.collectAllTabooAllergyDetail(classTaboo);
    },

    // 全ての禁忌薬剤名称
    allTabooMedicine() {
      return this.extractMedicineNameFromDetail(this.allTabooDetail);
    },
    // add 9987 by kangjie 20231215 start
    // del #9981 5430 余計なコーディングの削除 limf start
    // 全ての禁忌調整薬剤名称
    allTabooMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allTabooDetail);
    },
    // del #9981 5430 余計なコーディングの削除 limf end
    // add 9987 by kangjie 20231215 start
    // 全ての禁忌医療材料名称
    allTabooEquip() {
      return this.extractEquipNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌ダイアライザ名称
    allTabooDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌一般名処方名称
    allTabooGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌フリーワード名称
    allTabooFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allTabooDetail);
    },

    // 全ての禁忌名称を集めた詳細表示ポップオーバー用オブジェクト
    allTabooDetailName() {
      const obj = {
        medicine: this.allTabooMedicine,
        // add 9987 by kangjie 20231215 start
        // del #9981 5430 余計なコーディングの削除 limf start
        medicineMix: this.allTabooMedicineMix,
        // del #9981 5430 余計なコーディングの削除 limf end
        // add 9987 by kangjie 20231215 start
        equip: this.allTabooEquip,
        dialyzer: this.allTabooDialyzer,
        genericMedicine: this.allTabooGenericMedicine,
        freeWord: this.allTabooFreeWord
      };
      return obj;
    },

    // 全てのアレルギー詳細
    allAllergyDetail() {
      return this.collectAllTabooAllergyDetail(classAllergy);
    },

    // 全てのアレルギー薬剤名称
    allAllergyMedicine() {
      return this.extractMedicineNameFromDetail(this.allAllergyDetail);
    },
    // add 9987 by kangjie 20231215 start
    // del #9981 5430 余計なコーディングの削除 limf start
    // 全てのアレルギー調整薬剤名称
    allAllergyMedicineMix() {
      return this.extractMedicineMixNameFromDetail(this.allAllergyDetail);
    },
    // del #9981 5430 余計なコーディングの削除 limf end
    // add 9987 by kangjie 20231215 end

    // 全てのアレルギー医療材料名称
    allAllergyEquip() {
      return this.extractEquipNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギーダイアライザ名称
    allAllergyDialyzer() {
      return this.extractDialyzerNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー一般名処方名称
    allAllergyGenericMedicine() {
      return this.extractGenericMedicineNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギーフリーワード名称
    allAllergyFreeWord() {
      return this.extractFreeWordNameFromDetail(this.allAllergyDetail);
    },

    // 全てのアレルギー名称を集めた詳細表示ポップオーバー用オブジェクト
    allAllergyDetailName() {
      return {
        medicine: this.allAllergyMedicine,
        // add 9987 by kangjie 20231215 start
        // del #9981 5430 余計なコーディングの削除 limf start
        medicineMix: this.allAllergyMedicineMix,
        // del #9981 5430 余計なコーディングの削除 limf end
        // add 9987 by kangjie 20231215 end
        equip: this.allAllergyEquip,
        dialyzer: this.allAllergyDialyzer,
        genericMedicine: this.allAllergyGenericMedicine,
        freeWord: this.allAllergyFreeWord
      };
    }
  },

  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },

    // マスタ取得完了後にポップオーバーオブジェクトを作成
    mstTabooAllergy() {
      this.popoverData = this.createPopoverData(
        "禁忌・アレルギー",
        null,
        null,
        "禁忌・アレルギー名",
        this.mstTabooAllergy.filter(o => o.isDisp !== "0" && o.isDel !== "1"),
        "tabooAllergyCd",
        "content",
        null
      );
    },
    // add #12462 患者情報共有 Ji start
    getOtherFacilityCd() {
      this.refreshData();
    },
    jsonArray: {
      handler (val) {
        const isEdited = val.some((item) => {
          return item.ctl_no.editValue !== item.ctl_no.initValue;
        })
        if (isEdited) {
          this.setEditedComponent(this.$options.name);
        } else {
          this.removeEditedComponent(this.$options.name);
        }
      },
      deep: true
    },
    // add #12462 患者情報共有 Ji end
  },

  mounted() {
    window.addEventListener("resize", this.setHeightAndWidth);
  },

  async created() {
    this.refreshData()
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 じょはく start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 じょはく end
    // del #10359 編集権限の動作不正 dengshen end
    //施設コードを抽出条件に追加

    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
    this.isInitFinished = true;
    // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
  },
  // add bug #7125 修正 chen start
  beforeDestroy() {
    window.removeEventListener('resize', this.setHeightAndWidth)
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add bug #7125 修正 chen end

  methods: {
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    setHeightAndWidth () {
      this.windowHeight = window.innerHeight;
      this.windowWidth = window.innerWidth;
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      const requestParam = {
        // mod #12462 患者情報共有 Ji start
        // facilityCd: this.getFacilityCd
        facilityCd: this.getIsOtherFacility ? (this.getOtherFacilityCd ?? this.getFacilityCd) : this.getFacilityCd
	// mod #12462 患者情報共有 Ji end
      };

      const [
        resTabooAllergy,
        resMedicine,
        resMedicineMix,
        resEquipment,
        resDialyzer,
        resGenericMedicine
      ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstTabooAllergyIncludeDeleted", requestParam),
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam),
        ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", requestParam),
        ApiHelper.get("/mstInfo/mstEquipmentIncludeDeleted", requestParam),
        ApiHelper.get("/mstInfo/mstDialyzerIncludeDeleted", requestParam),
        ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted", requestParam)
      ]).catch(error => {
        this.setLoadingScreenVisible(false);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('TabooAllergyCardContent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw new Error(
          `[TabooAllergyCardContent.vue]created(): マスタ取得失敗
        エラー内容: ${error}`
        );
      });
      this.setLoadingScreenVisible(false);
      this.mstTabooAllergy = resTabooAllergy.data;
      this.mstMedicine = resMedicine.data;
      this.mstMedicineMix = resMedicineMix.data;
      this.mstEquipment = resEquipment.data;
      this.mstDialyzer = resDialyzer.data;
      this.sysGenericMedicine = resGenericMedicine.data;
      this.initRecord = deepCopy(this.editRecord);
    },
    // add bug #7125 修正 chen end
    // add FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 仕様変更 周 start
    sortByDispOrder(jsonArray) {
      if(null !== jsonArray && jsonArray.length > 1) {
        jsonArray.sort((a, b) => {
          if(a.disp_order.editValue > b.disp_order.editValue) {
            return 1;
          }
          if(a.disp_order.editValue < b.disp_order.editValue) {
            return -1;
          }
        });

        return jsonArray;
      }

      // add FNSI7513-profile連携（XML）で受信した詳細情報（造影剤アレルギー） 仕様変更 周 start
      return jsonArray;
      // add FNSI7513-profile連携（XML）で受信した詳細情報（造影剤アレルギー） 仕様変更 周 end
    },
    // add FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 仕様変更 周 end

    //bug:4274 add by maxueqiang
    addFocusEvent(event){
      let element = event.target;
      element.removeAttribute("readonly");
    },
    //bug:4274 add by maxueqiang end
    // 禁忌・アレルギーコードクリア
    clearCd(json) {
      this.setPatDataJsonArray(json, "taboo_allergy_cd", null);
      this.setPatDataJsonArray(json, "content", null);
      this.setPatDataJsonArray(json, "category_class", "0");
    },

    // 内容有無フラグ
    isEmptyContent(json) {
      if (this.getPatDataJsonArray(json, "content").editValue === null) {
        return true;
      } else {
        return false;
      }
    },

    // マスタコードセットフラグ
    hasCd(json) {
      return (
        // mod FNSI7415-profile連携（XML）で受信した詳細情報（その他アレルギー） 周 start
        //this.getPatDataJsonArray(json, "taboo_allergy_cd").editValue !== null
        this.getPatDataJsonArray(json, "taboo_allergy_cd").editValue !== null
        && this.getPatDataJsonArray(json, "taboo_allergy_cd").editValue !== ''
        // mod FNSI7415-profile連携（XML）で受信した詳細情報（その他アレルギー） 周 end
      );
    },

    // 禁忌・アレルギー内容取得
    tabooAllergyContent(json) {
      if (this.hasCd(json)) {

        // add FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 周 start
        if(json.category_class.initValue === '0' && json.taboo_allergy_class.initValue === '2'
        && json.taboo_allergy_cd.initValue === '') {
          return json.content.initValue;
        }
        // add FNSI7514-profile連携（XML）で受信した詳細情報（金属アレルギー） 周 end

        // 詳細項目の削除有無
        const isIncludeDeleted = this.getIsIncludeDeleted(json);

        // コードがセットされている場合はマスタ名称
        const mstName = this.mstCdToNameIncludeDeleted(
            this.mstTabooAllergy,
            json.taboo_allergy_cd.editValue,
            "tabooAllergyCd",
            "content"
          );
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // return isIncludeDeleted && !mstName.includes(DELETED) ? mstName + INCLUDE_DELETED : mstName;
        return isIncludeDeleted && !mstName.includes(DELETED) ? INCLUDE_DELETED + mstName : mstName;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      } else {
        // 手入力の場合はその内容
        return this.getPatDataJsonArray(json, "content").editValue;
      }
    },

    // 禁忌・アレルギー内容取得
    variousMstContent(json) {
      if (this.hasCd(json)) {
        // コードがセットされている場合はマスタ名称
        const categoryClass = this.getPatDataJsonArray(json, "category_class")
          .editValue;
        const selectedMst = this.setSelectedMst(categoryClass);
        // 詳細項目の削除有無
        const isIncludeDeleted = this.getIsIncludeDeleted(json);

        const mstName = this.mstCdToNameIncludeDeleted(
            selectedMst.mst,
            json.taboo_allergy_cd.editValue,
            selectedMst.cd,
            selectedMst.content
          );

        return isIncludeDeleted && !mstName.includes(DELETED) ? mstName + INCLUDE_DELETED : mstName;
      } else {
        // 手入力の場合はその内容
        return this.getPatDataJsonArray(json, "content").editValue;
      }
    },

    // 禁忌アレルギー詳細に参照先マスタから削除されている項目が存在する場合true存在しない場合falseを返す
    getIsIncludeDeleted(json) {
      // modify by maxueqiang 障碍票:17
      if (!(null !== this.mstTabooAllergy && this.mstTabooAllergy.length>0)) {
        return false;
      }
      // マスタから内容の詳細を取得
      let selectMstTaboo = this.mstTabooAllergy.find(
        mst => mst.tabooAllergyCd === json.taboo_allergy_cd.editValue
      );
      if (!(undefined !== selectMstTaboo && null !== selectMstTaboo)){
        return false;
      }
      let detailInfo = selectMstTaboo.detailInfo;
      if (!(undefined !== detailInfo && null !== detailInfo)){
        return false;
      }
      // modify by maxueqiang end
      const selectedDetail = JSON.parse(detailInfo);

      // 禁忌アレルギー詳細から削除されている項目を検索しBooleanを返却
      return selectedDetail.some(item => {
        let targetMst = null;
        switch (item.classCd) {
          case classMedicine :
            // '1': 薬剤マスタ
            targetMst = this.mstMedicine.find(
              mst => mst.medicineCd === item.cd
            );
            break;
          case classEquipment :
            // '3': 医療材料マスタ
            targetMst = this.mstEquipment.find(
              mst => mst.equipmentCd === item.cd
            );
            break;
          case classDialyzer :
            // '4': ダイアライザマスタ.ダイアライザコード
            targetMst = this.mstDialyzer.find(
              mst => mst.dialyzerCd === item.cd
            );
            break;
          case classFreeWord :
            // '5': フリーワード場合falseを返却
            return false;
          case classGenericMedicine :
            // '6': 一般名処方マスタ.一般名処方コード
            targetMst = this.sysGenericMedicine.find(
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
              //mst => mst.genericCd === item.cd && mst.medicineType === item.type
              mst => mst.genericCd === item.cd && mst.medicineType == item.type
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            );
            break;
          default:
            return false;
        }

        return !targetMst || targetMst.isDisp === "0" || targetMst.isDel === "1";
      })
    },

    addItem() {
      // 新規項目作成
      const newItem = {
        ctl_no: 0,
        disp_order: 0,
        taboo_allergy_cd: null,
        taboo_allergy_class: "1",
        category_class: "0",
        content: null,
        memo: null
      };
      this.pushJsonArray(this.arrayColName, newItem);
    },

    selectContent(index) {

      // selectedIndexを初期化することでgetPopoverTargetElement()で再計算を行い
      // マスタ選択のダイアログが正しい位置に表示されるようにする
      this.selectedIndex = null;

      // 選択ボタンを押した位置を保持
      this.selectedIndex = index;
      const taboo_allergy_cd = this.getPatDataJsonArray(this.jsonArray[this.selectedIndex], "taboo_allergy_cd").editValue;
      this.popoverData.popoverContentSelected.value = taboo_allergy_cd;
      // ポップオーバーを表示
      this.showPopover(this.popoverData);
    },

    // ポップオーバー確定イベントハンドラ
    setTabooAllergy(selectedCd, selectedName) {
      console.log(`setTabooAllergy_${selectedCd}_${selectedName}`);
      // 選択ボタンを押した項目に内容を設定
      this.setPatDataJsonArray(
        this.selectedTabooAllergyInfo,
        "taboo_allergy_cd",
        selectedCd
      );
      this.setPatDataJsonArray(
        this.selectedTabooAllergyInfo,
        "content",
        selectedName
      );
      this.setPatDataJsonArray(
        this.selectedTabooAllergyInfo,
        "category_class",
        "0"
      );
    },

    showTabooAllergyDetail(index) {
      // 選択ボタンを押した位置を保持
      this.selectedIndex = index;
      // ポップオーバーを表示
      this.tabooAllergyDetailVisible = true;
    },

    // ポップオーバー表示位置ターゲットとなる要素を取得
    getPopoverTargetElement(refName) {
      if (this.selectedIndex === null) {
        // 初期表示時は未選択なのでnull
        return null;
      }
      return this.$refs[refName + this.selectedIndex][0];
    },

    // add 9987 by kangjie 20231215 start
    extractMedicineMixNameFromDetail(tabooAllergyDetail) {
      // classMedicineMix
      return this.extractTabooAllergyNameFromDetail (
          tabooAllergyDetail,
      classMedicineMix,
      this.mstMedicineMix,
      "medicineMixCd",
      "medicineMixName");
    },
    // add 9987 by kangjie 20231215 end

    // 禁忌・アレルギーマスタの内容詳細から薬剤名称を取り出す
    extractMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        classMedicine,
        this.mstMedicine,
        "medicineCd",
        "medicineName"
      );
    },

    // del #9981 5430 余計なコーディングの削除 limf start
    // mod FNSI-徐博 start
    // 禁忌・アレルギーマスタの内容詳細の薬剤が含まれる調整薬剤名称を取り出す
    // extractMedicineMixNameFromDetail(tabooAllergyDetail) {
    //   if ( tabooAllergyDetail != undefined ) {
    //     // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 start
    //      let isParentDeleted=false
    //   if (this.selectedTabooAllergyInfo) {
    //     // 選択された禁忌・アレルギーのマスタコードを取得
    //     const targetCd = this.selectedTabooAllergyInfo.taboo_allergy_cd.editValue;
    //     // マスタから内容の詳細を取得
    //     const targetMst = this.mstTabooAllergy.find(
    //       mst => mst.tabooAllergyCd === targetCd
    //     );
    //     // 選択された禁忌・アレルギーが削除済みか判定
    //      isParentDeleted = !targetMst || targetMst.isDisp === "0" || targetMst.isDel === "1";
    //   }
    //   // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 end
    //     // 禁忌・アレルギーマスタの内容詳細から薬剤コードを取り出す
    //     const medicineList = tabooAllergyDetail
    //       .filter(detail => detail.classCd === classMedicine)
    //       .map(detail => detail.cd);
    //
    //   // 詳細登録された薬剤を含む調整薬剤を絞り込み名称を取得する
    //   const medicineMixNameList = this.mstMedicineMix
    //       .filter(item => {
    //         const mixInfo = JSON.parse(item.mixInfo)
    //         let isInclude = false
    //         if (mixInfo) {
    //           isInclude =
    //             mixInfo.some(info =>
    //               medicineList.some(medicineCd => info.cd === medicineCd)
    //             )
    //         }
    //         return isInclude
    //       })
    //       .map(item => {
    //         if (item.isDisp !== "0" && item.isDel !== "1" && !isParentDeleted) {
    //           return item.medicineMixName
    //         } else {
    //           // 禁忌アレルギーが削除済または該当調整薬剤が削除済の場合名称の頭に【削除済み】を付与する
    //           return DELETED + item.medicineMixName
    //         }
    //       })
    //
    //     return medicineMixNameList
    //   }
    // },
    // mod FNSI-徐博 end
    // del #9981 5430 余計なコーディングの削除 limf end

    // 禁忌・アレルギーマスタの内容詳細から医療材料名称を取り出す
    extractEquipNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        classEquipment,
        this.mstEquipment,
        "equipmentCd",
        "equipmentName"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細からダイアライザ名称を取り出す
    extractDialyzerNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        classDialyzer,
        this.mstDialyzer,
        "dialyzerCd",
        "modelNumber"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細から一般名処方名称を取り出す
    extractGenericMedicineNameFromDetail(tabooAllergyDetail) {
      return this.extractTabooAllergyNameFromDetail(
        tabooAllergyDetail,
        classGenericMedicine,
        this.sysGenericMedicine,
        "genericCd",
        "genericName"
      );
    },

    // 禁忌・アレルギーマスタの内容詳細からフリーワード名称を取り出す
    extractFreeWordNameFromDetail(tabooAllergyDetail) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      // del #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
      // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 start
      //  let isParentDeleted=false
      // if (this.selectedTabooAllergyInfo) {
      // // 選択された禁忌・アレルギーのマスタコードを取得
      // const targetCd = this.selectedTabooAllergyInfo.taboo_allergy_cd.editValue;
      // // マスタから内容の詳細を取得
      // const targetMst = this.mstTabooAllergy.find(
      //   mst => mst.tabooAllergyCd === targetCd
      // );
      //   // 選択された禁忌・アレルギーが削除済みか判定
      //   if (targetMst !== undefined) {
      //     isParentDeleted = !targetMst || targetMst.isDisp === "0" || targetMst.isDel === "1";
      //   } else {
      //     isParentDeleted = false;
      //   }
      // }
      // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 end
      // del #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
      // フリーワード名称は禁忌・アレルギーマスタの詳細から取得
      return tabooAllergyDetail
          .filter(detail => detail.classCd === classFreeWord)
          // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
          // .map(detail => isParentDeleted ? DELETED + detail.name : detail.name);
          .map(detail => detail.tabooAllergyDeleted ? DELETED + detail.name : detail.name);
      // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
    },

    // 禁忌・アレルギーマスタの内容詳細から名称を取り出す
    // ※引数でいずれかの区分と名称変換に必要な情報を指定
    extractTabooAllergyNameFromDetail(
      tabooAllergyDetail,
      tabooAllergyClass,
      mst,
      cdColumn,
      nameColumn
    ) {
      if (tabooAllergyDetail === undefined) {
        return;
      }
      // del #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
      // // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 start
      // let isParentDeleted=false
      // if (this.selectedTabooAllergyInfo) {
      // // 選択された禁忌・アレルギーのマスタコードを取得
      // const targetCd = this.selectedTabooAllergyInfo.taboo_allergy_cd.editValue;
      // // マスタから内容の詳細を取得
      // const targetMst = this.mstTabooAllergy.find(
      //   mst => mst.tabooAllergyCd === targetCd
      // );
      // // 選択された禁忌・アレルギーが削除済みか判定
      // isParentDeleted = !targetMst || targetMst.isDisp === "0" || targetMst.isDel === "1";
      // }
      // // mod 5796デグレ：禁忌・アレルギー全表示ボタンを押下した際の動作不正 張 end
      // del #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
      return tabooAllergyDetail
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // .filter(detail => detail.classCd === tabooAllergyClass)
        .filter(detail => detail.classCd === tabooAllergyClass && detail.tabooAllergyDeleted != true)
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
        // .map(detail => this.mstCdToNameIncludeDeleted(mst, detail.cd, cdColumn, nameColumn, isParentDeleted));
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // .map(detail => this.mstCdToNameIncludeDeleted(mst, detail.cd, cdColumn, nameColumn, detail.tabooAllergyDeleted));
        .map(detail => this.mstCdToNameIncludeExpiredAndDeleted(mst, detail.cd, cdColumn, nameColumn, detail.tabooAllergyDeleted));
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
    },

    // 全ての禁忌、またはアレルギー詳細を集める
    // ※引数でいずれかの区分を指定
    collectAllTabooAllergyDetail(tabooAllergyClass) {
      if (this.mstTabooAllergy === null) {
        // マスタ読み込み完了前は何もしない
        return;
      }

      const tabooAllergy = [];
      const otherDetailInfoList = [];
      this.jsonArray.forEach(json => {
        // add 9987 by kangjie 20231229 start
        // if (json.category_class.editValue === "0") {
        if (json.category_class.editValue === "0" || json.category_class.editValue === "5") {
          // add 9987 by kangjie 20231229 end
          // 対象区分：禁忌・アレルギーのみを集める
          tabooAllergy.push(json);
        } else {
          // 対象区分：禁忌・アレルギー以外を集める
          // mst_taboo_allergyテーブルのdetail_infoカラムの形で格納
          if (json.taboo_allergy_class.editValue === tabooAllergyClass) {
            otherDetailInfoList.push({
              // 各マスタへの紐づけ
              classCd: json.category_class.editValue,
              // 各マスタコード
              cd: json.taboo_allergy_cd.editValue
            });
          }
        }
      });

      // 引数で指定された区分で登録されている全てのコード(削除項目を除く)を取得
      // del #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf start
      // const allCd = tabooAllergy
      //   .filter(
      //     json =>
      //       json.ctl_no.editValue >= 0 &&
      //       json.taboo_allergy_cd.editValue !== null &&
      //       json.taboo_allergy_class.editValue === tabooAllergyClass
      //   )
      //   .map(json => json.taboo_allergy_cd.editValue);
      // del #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf end
      // mod #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf start
      // if (_.isEmpty(allCd) && _.isEmpty(otherDetailInfoList)) {
      if (_.isEmpty(tabooAllergy) && _.isEmpty(otherDetailInfoList)) {
        // mod #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf end
        return;
      }

      // コードをマスタの内容詳細に変換する、
      // また対象区分：禁忌・アレルギー以外を設定する
      const allDetail = [...otherDetailInfoList];
      // mod #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf start
      // allCd.forEach(cd => {
      tabooAllergy.forEach(cd => {
        if (tabooAllergyClass === cd.taboo_allergy_class.editValue) {
          const targetMst = this.mstTabooAllergy.find(
            mst => mst.tabooAllergyCd === cd.taboo_allergy_cd.editValue
          );
          if (targetMst !== undefined && targetMst.detailInfo && targetMst.detailInfo !== '[]') {
            // 内容詳細JSONをデシリアライズして展開
            // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf start
            // allDetail.push(...JSON.parse(targetMst.detailInfo));
            const detailInfo = JSON.parse(targetMst.detailInfo)?.map(item => {
              return {
                ...item,
                // 禁忌アレルギーコード
                tabooAllergyCd: targetMst.tabooAllergyCd,
                // 参照先禁忌アレルギーが削除されているかを示すフラグ
                tabooAllergyDeleted: targetMst.isDisp === "0" || targetMst.isDel === "1"
              }
            })
            allDetail.push(...detailInfo);
            // mod #9981 禁忌・アレルギー全表示で特定の操作で削除済みと表示される limf end
          } else {
            const detailInfo = {
              cd: null,
              name: cd.content.editValue,
              classCd: PAT_HEADER.CLASS_FREEWORD,
              tabooAllergyCd: cd.taboo_allergy_cd.editValue,
              tabooAllergyDeleted: false,
              type: null
            };
            allDetail.push(detailInfo);
          }
        }
        // mod #9982 禁忌アレルギー全表示に直接入力した場合フリーワードに表示されない limf end
      });

      // 区分とコードと禁忌対象名の重複を排除
      return deduplicateObjects(allDetail, "classCd", "cd", "name");
    },

    /**
     * @description 表示方向
     */
    popoverDisplayDirection(popoverTarget, visible) {
      if (!visible) return null;

      if (popoverTarget) {
        const elemPosition = popoverTarget.$el
          ? popoverTarget.$el.getBoundingClientRect()
          : popoverTarget.getBoundingClientRect();
        let direction = "right";

        if (this.windowHeight <= 420) {
          // heightが狭い(スマホ横とか)ときは上下じゃ途切れるので右か左に表示
          if (elemPosition.right < this.windowWidth / 2) {
            direction = "right";
          } else {
            direction = "left";
          }
        } else if (this.windowWidth - elemPosition.right < 500) {
          if (elemPosition.top < this.windowHeight / 2) {
            direction = "down";
          } else {
            direction = "up";
          }
        }
        return direction;
      }
    },

    isClassTabooAllergy(json) {
      return this.getPatDataJsonArray(json, "category_class").editValue === "0";
    },

    setSelectedMst(categoryClass) {
      let mst = null;
      let cd = null;
      let content = null;
      switch (categoryClass) {
        case "1":
          // '1': 薬剤マスタ.薬剤コード
          mst = this.mstMedicine;
          cd = "medicineCd";
          content = "medicineName";
          break;
        case "2":
          // '2': 調製薬剤マスタ.調製薬剤コード
          mst = this.mstMedicineMix;
          cd = "medicineMixCd";
          content = "medicineMixName";
          break;
        case "3":
          // '3': 医療材料マスタ.医療材料コード
          mst = this.mstEquipment;
          cd = "equipmentCd";
          content = "equipmentName";
          break;
        case "4":
          // '4': ダイアライザマスタ.ダイアライザコード
          mst = this.mstDialyzer;
          cd = "dialyzerCd";
          content = "modelNumber";
          break;
        case "6":
          // '6': 一般名処方マスタ.一般名処方コード
          mst = this.sysGenericMedicine;
          cd = "genericCd";
          content = "genericName";
          break;
        default:
          break;
      }
      return { mst, cd, content };
    },

    setContentData(newValue, paramName, index) {
      this.setPatDataJsonArray(this.jsonArray[index], paramName, newValue);
    },
    // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 start
     setJsonIndex(json, index) {
      this.selectJson = json;
      this.selectIndex = index;
      this.deleteJsonArray( this.arrayColName, this.selectJson, this.selectIndex );
    },
    // mod 入力必須項目のチェックがされない / 入力欄の色の不正 5795 関 end
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/*add 適用 liang start*/
.custom-input >>> .text-input {
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}
/*add 適用 liang end*/
/* カード個別のスタイルはここ */
.vons-popover >>> .popover__content {
  width: 300px;
  margin: 3px;
  border: solid 1px var(--preventive-checked-border-color);
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
  overflow: hidden;
}
.taboo-allergy-detail-div {
  max-height: 600px;
  padding: 25px;
  overflow: auto;
  height: calc(100% - 50px);
}

.vons-popover >>> .popover__arrow {
  border-bottom: solid 1px var(--preventive-checked-border-color);
  border-left: solid 1px var(--preventive-checked-border-color);
  background-image: linear-gradient(
    45deg,
    var(--ntss-list-background-color),
    var(--ntss-list-background-color) 50%,
    transparent 50%
  );
}
.btn-ntss-custom{
  font-size: 1em;
}
.card-table >>> textarea.custom-textarea {
  color: black !important;
}

</style>
