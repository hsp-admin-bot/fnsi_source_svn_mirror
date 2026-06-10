<template>
  <div>
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
          <!--mod FNSI-画面部品デザイン じょはく start-->
          <button
            v-show="actionMode"
            class="button-delete ntss-btn-outset"
            @click="setJsonIndex(json, index)"
          >
          <!--mod FNSI-画面部品デザイン じょはく end-->
            <v-ons-icon icon="fa-trash"/>
          </button>
          <br />
<!--          add 編集権限の適用 liang start-->
          <tr>
            <td class="item-title">会社名</td>
            <td colspan="2" class="item-data">
              <custom-simple-textarea-a
                ref="company_name"
                :is-required="json.ctl_no.editValue >= 0"
                :value="getPatDataJsonArray(json, 'company_name')"
                :validators="[]"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                form-name="会社名"
                style="vertical-align: middle;"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">
              郵便番号<span class="zip-hyphen">(ﾊｲﾌﾝなし)</span>
            </td>
            <td class="item-data">
              <custom-input
                ref="zip_cd"
                :value="getPatDataJsonArray(json, 'zip_cd')"
                :validators="[]"
                type="tel"
                maxlength="7"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                form-name="郵便番号"
              />
            </td>
            <td class="item-data">
              <v-ons-button
                class="common-style-select-button btn3-normal"
                @click="
                  showAddressSearchModal(setAddressValues(json));
                  mapVisible = true;
                  mapUpdateTarget = json;
                "
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                住所検索
              </v-ons-button>
            </td>
          </tr>
          <tr>
            <td class="item-title">住所</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :content="getPatDataJsonArray(json, 'address')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :idTextarea="'com-textarea-vendor-contact-address'+index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event,'address',index)"
              />
            </td>
          </tr>
          <!-- バリデーション未定義 -->
          <tr>
            <td class="item-title">代表電話番号</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="company_tel"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :value="getPatDataJsonArray(json, 'company_tel')"
                :validators="[]"
                type="tel"
                form-name="電話番号"
              />
            </td>
          </tr>
          <tr></tr>
          <tr>
            <td class="item-title">代表FAX</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="fax"
                :value="getPatDataJsonArray(json, 'fax')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="FAX"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">担当者名</td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="worker_last_name"
                :value="getPatDataJsonArray(json, 'worker_last_name')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                placeholder="姓"
                form-name="氏名(姓)"
                style="vertical-align: middle;"
              />
            </td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="worker_first_name"
                :value="getPatDataJsonArray(json, 'worker_first_name')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                placeholder="名"
                form-name="氏名(名)"
                style="vertical-align: middle;"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">電話番号</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="worker_tel"
                :value="getPatDataJsonArray(json, 'worker_tel')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="電話番号"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">Email</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="worker_e_mail"
                :value="getPatDataJsonArray(json, 'worker_e_mail')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="email"
                form-name="Email"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">メモ１</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :content="getPatDataJsonArray(json, 'memo1')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :idTextarea="'com-textarea-vendor-contact-memo1'+index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event,'memo1',index)"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">メモ２</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :content="getPatDataJsonArray(json, 'memo2')"
                :disabled = "!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :idTextarea="'com-textarea-vendor-contact-memo2'+index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event,'memo2',index)"
              />
            </td>
          </tr>
        </table>
      </div>
    </draggable>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import {mapActions, mapGetters} from "vuex";
import { EventBus } from "@/eventBus.js";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
// del #10359 編集権限の動作不正 dengshen start
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// import {AUTHORITY_CODES} from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end

export default {
  name: "VendorContactCard",
  mixins: [baseCardContent],
  data() {
    return {
      arrayColName: "vendor_contact_info",
      mapVisible: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      isInitFinished: false,
      // add FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 liang start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 liang end
      // del #10359 編集権限の動作不正 dengshen end
      mapUpdateTarget: null,
      deleteIndexArr: []
    };
  },
  // add 編集権限の適用 liang start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 liang end
  computed: {
    // add 編集権限の適用 liang start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 liang end
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    jsonArray: {
      get() {
        let arrVendorContact = [];
        for (var VendorInf of this.editRecord[this.arrayColName]) {
          arrVendorContact.push(VendorInf);
        }
        return arrVendorContact;
      },

      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },
    // add by maxueqiang bug:3722 連絡先の住所検索結果に本人情報の住所検索結果が表示される
    setAddressValues(){
      return function(json){
        return {
          postalCode: this.getPatDataJsonArray(json, 'zip_cd').editValue,
          address: this.getPatDataJsonArray(json, 'address').editValue
        }
      }
    }
    // add by maxueqiang bug:3722 end
  },

  created() {
    const eventBusName = this.isCreationPat ? "selectPatInfoAddressVendorContactNew" : "selectPatInfoAddressVendorContactChange";
    EventBus.$on(eventBusName, event => {
      if (!this.mapVisible) return;

      this.setPatDataJsonArray(this.mapUpdateTarget, "address", event.address);
      this.setPatDataJsonArray(this.mapUpdateTarget, "zip_cd", event.zipCd);
      this.mapVisible = false;
      this.mapUpdateTarget = null;
    });
  },
  beforeDestroy() {
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 start
    // EventBus.$off("selectPatInfoAddressVendorContact")
    const eventBusName = this.isCreationPat ? "selectPatInfoAddressVendorContactNew" : "selectPatInfoAddressVendorContactChange";
    EventBus.$off(eventBusName);
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  methods: {
    ...mapActions("multi-modal", ["showAddressSearchModal"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    // 項目追加処理
    addItem() {
      // 新規項目作成
      const newItem = {
        ctl_no: 0,
        disp_order: 0,
        company_name: null,
        zip_cd: null,
        address: null,
        company_tel: null,
        fax: null,
        worker_last_name: null,
        worker_first_name: null,
        worker_tel: null,
        worker_e_mail: null,
        memo1: null,
        memo2: null
      };
      this.pushJsonArray(this.arrayColName, newItem);
    },
    // add FNSI-画面部品デザイン じょはく start
    setJsonIndex(json, index) {
      this.selectJson = json;
      this.selectIndex = index;
      this.deleteJsonArray( this.arrayColName, this.selectJson, this.selectIndex );
    },
    // add FNSI-画面部品デザイン じょはく end

    setContentData(e, key, index) {
      this.setPatDataJsonArray(this.jsonArray[index], key, e);
    },
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
.zip-hyphen {
  font-size: 10px;
}
.card-table >>> textarea.custom-textarea {
  color: black !important;
}
.custom-textarea-edited {
  border: 2px green solid;
}
.custom-textarea-required {
  background-color: #ffff99;
}
.custom-textarea-invalid {
  background-color: rgba(255, 0, 0, 0.5);
}
</style>
