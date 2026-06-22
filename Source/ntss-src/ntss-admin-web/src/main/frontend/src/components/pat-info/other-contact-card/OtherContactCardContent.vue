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
          <tbody>
          <tr class="card-index-row">
            <td colspan="3">
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
            </td>
          </tr>
          <tr>
            <td></td>
            <td colspan="2">
              <custom-checkbox
                :value="getPatDataJsonArray(json, 'is_key_person')"
                checked-value="1"
                unchecked-value="0"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              >
                キーパーソン
              </custom-checkbox>
            </td>
          </tr>
          <tr>
            <td class="item-title">ID</td>
            <td>
              <custom-input
                :value="getPatDataJsonArray(json, 'pat_id')"
                :disabled="hasPatId(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              />
            </td>
            <td class="item-data">
              <span class="other-contact-master-actions">
                <common-master-selector
                  :ref="'ocms' + index"
                  :masterType="MasterType.OTHER_CONTACT_PAT_PAT_INFO"
                  :facilityCd="facilityCd"
                  :patientId="selectedPatId"
                  :extraParams="otherContactComposeExtraParams(index)"
                  :initItem="otherContactPatRowItem(index)"
                  :editItem="otherContactPatRowItem(index)"
                  :popoverAnchorElement="getOtherContactPatPopoverAnchor(index)"
                  :btnVisible="false"
                  :btnName="'選択'"
                  :isVisible="false"
                  :btnClass="'common-style-select-button btn3-normal pat-btn-margin-right'"
                  :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  @popover-return="onOtherContactPatComposeReturn"
                />
                <v-ons-button
                  :ref="`btnSelectPat${index}`"
                  class="common-style-select-button btn3-normal pat-btn-margin-right"
                  @click="selectOtherPat(index)"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >
                  選択
                </v-ons-button>
                <v-ons-button
                  class="common-style-select-button btn2-cancel"
                  @click="clearPatID(json)"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >
                  クリア
                </v-ons-button>
              </span>
            </td>
          </tr>
          <tr>
            <td class="item-title">氏名</td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="last_name"
                :value="getPatDataJsonArray(json, 'last_name')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :is-required="json.ctl_no.editValue >= 0"
                placeholder="姓"
                form-name="氏名(姓)"
                @input="filterInput($event, 'last_name', index)"
                style="vertical-align: middle;"
              />
            </td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="first_name"
                :value="getPatDataJsonArray(json, 'first_name')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :is-required="json.ctl_no.editValue >= 0"
                placeholder="名"
                form-name="氏名(名)"
                @input="filterInput($event, 'first_name', index)"
                style="vertical-align: middle;"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">フリガナ</td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="last_name_kana"
                :value="getPatDataJsonArray(json, 'last_name_kana')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                placeholder="セイ"
                form-name="フリガナ(セイ)"
                style="vertical-align: middle;"
                @input="filterInput($event, 'last_name_kana', index)"
              />
            </td>
            <td class="item-data">
              <custom-simple-textarea-a
                ref="first_name_kana"
                :value="getPatDataJsonArray(json, 'first_name_kana')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                placeholder="メイ"
                form-name="フリガナ(メイ)"
                style="vertical-align: middle;"
                @input="filterInput($event, 'first_name_kana', index)"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">続柄</td>
            <td class="item-data">
              <custom-simple-textarea-a
                :value="getPatDataJsonArray(json, 'relation_name')"
                :display-string="relationName(json)"
                :disabled="hasRelationCd(json) || !getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                style="vertical-align: middle;"
              />
            </td>
            <td class="item-data">
              <span class="other-contact-master-actions">
                <common-master-selector
                  :masterType="MasterType.RELATIONSHIP_PAT_INFO"
                  :facilityCd="facilityCd"
                  :initItem="{ value: getPatDataJsonArray(json, 'relation_cd').initValue }"
                  :editItem="{ value: getPatDataJsonArray(json, 'relation_cd').editValue }"
                  :btnName="'選択'"
                  :isVisible="false"
                  :btnClass="'common-style-select-button btn3-normal pat-btn-margin-right'"
                  :btnDisabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                  @popover-return="setRelation($event, index)"
                />
                <v-ons-button
                  class="common-style-select-button btn2-cancel"
                  @click="clearRelationCd(index, json)"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                >
                  クリア
                </v-ons-button>
              </span>
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
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                maxlength="7"
                form-name="郵便番号"
              />
            </td>
            <td class="item-data">
              <v-ons-button
                class="common-style-select-button  btn3-normal"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                @click="
                  showAddressSearchModal(setAddressValues(json));
                  mapVisible = true;
                  mapUpdateTarget = json;
                "
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
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :content="getPatDataJsonArray(json, 'address')"
                :idTextarea="'com-textarea-other-contact-address' + index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event, 'address', index)"
              />
            </td>
          </tr>
          <!-- TODO: バリデーション未定義 -->
          <tr>
            <td class="item-title">電話番号</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="tel1"
                :value="getPatDataJsonArray(json, 'tel1')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="電話番号"
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </td>
          </tr>
          <!-- TODO: バリデーション未定義 -->
          <tr>
            <td class="item-title">電話番号2</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="tel2"
                :value="getPatDataJsonArray(json, 'tel2')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="電話番号2"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">FAX</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="fax"
                :value="getPatDataJsonArray(json, 'fax')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="FAX"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">Email</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="e_mail"
                :value="getPatDataJsonArray(json, 'e_mail')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="email"
                form-name="Email"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">勤務先名</td>
            <td colspan="2" class="item-data">
              <custom-simple-textarea-a
                :value="getPatDataJsonArray(json, 'work_name')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                style="vertical-align: middle;"
              />
            </td>
          </tr>
          <!-- TODO: バリデーション未定義 -->
          <tr>
            <td class="item-title">勤務先電話番号</td>
            <td colspan="2" class="item-data">
              <custom-input
                ref="work_tel"
                :value="getPatDataJsonArray(json, 'work_tel')"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :validators="[]"
                type="tel"
                form-name="勤務先電話番号"
                readonly="readonly"
                @focus="addFocusEvent($event)"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">メモ1</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :content="getPatDataJsonArray(json, 'memo1')"
                :idTextarea="'com-textarea-other-contact-memo1' + index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event, 'memo1', index)"
              />
            </td>
          </tr>
          <tr>
            <td class="item-title">メモ2</td>
            <td colspan="2" class="item-data">
              <com-textarea
                class="comTextarea"
                :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
                :content="getPatDataJsonArray(json, 'memo2')"
                :idTextarea="'com-textarea-other-contact-memo2'+index"
                cssClass="textarea-custom-text-font textarea-resize-vertical"
                @set-content-data="setContentData($event, 'memo2', index)"
              />
            </td>
          </tr>
          
        
          </tbody>
        </table>
      </div>
    </draggable>

  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized, deepCopy } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions } from "@/compat/vue/vuex";
import { mapGetters } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
// add 編集権限の適用 liang start
// del #10359 編集権限の動作不正 dengshen start
// import {AUTHORITY_CODES} from "@/constants/userAuthority";
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 liang end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import _ from "@/compat/collections/lodash";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";

export default {
  name: 'OtherContactCard',
  mixins: [baseCardContent],
  components: {
    "common-master-selector": commonMasterSelector
  },
  data() {
    return {
      arrRelation: [],
      arrayColName: "other_contact_info",
      patPersonalMain: null,
      mstRelation: null,
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      delMstRelations: null,
      // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      // add by maxueqiang
      deleteMstRelation: null,
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 liang start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 liang end
      // del #10359 編集権限の動作不正 dengshen end
      MasterType,
      selectedIndex: null,
      resolvedPatIdByRow: {},
      patContactInfoKeys: [
        "zip_cd",
        "address",
        "tel1",
        "tel2",
        "fax",
        "e_mail",
        "work_name",
        "work_tel",
        "memo1",
        "memo2"
      ],
      mapVisible: false,
      mapUpdateTarget: null,
      selectPatInfoAddressEventName: null,

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
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", [ "selectedPat", "selectedPatId", "selectedFacilityCd", "getIsOtherFacility", "getOtherFacilityCd"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    jsonArray: {
      get() {
        // mod FNSI-画面部品デザイン じょはく start
        let arrOtherContact = [];
        for (var otherInf of this.editRecord[this.arrayColName]) {
          arrOtherContact.push(otherInf);
        }
        return arrOtherContact;
        // return this.editRecord[this.arrayColName];
        // mod FNSI-画面部品デザイン じょはく end
      },

      set(sortedAry) {
        this.editRecord[this.arrayColName] = sortedAry;
      }
    },

    // 続柄の選択は CommonMasterSelector に移行済み
    // add by maxueqiang bug:3722 連絡先の住所検索結果に本人情報の住所検索結果が表示される
    setAddressValues(){
      return function(json) {
        return {
          postalCode: this.getPatDataJsonArray(json, 'zip_cd').editValue,
          address: this.getPatDataJsonArray(json, 'address').editValue
        }
      }
    }
    // add by maxueqiang bug:3722 end
  },

  // マスタ取得完了後にポップオーバーオブジェクトを作成
  watch: {
    selectedPatId() {
      this.switchingSelectedPatFlg = true;
      this.refreshData();
      this.$nextTick(() => {
        this.switchingSelectedPatFlg = false;
      });
    },

    // 続柄の選択は CommonMasterSelector に移行済み
  },

  async created() {
    this.refreshData()
    this.selectPatInfoAddressEventName = this.isCreationPat ? "selectPatInfoAddressOtherContactNew" : "selectPatInfoAddressOtherContactChange";
    EventBus.$off(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
    EventBus.$on(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
  },
  // add bug #7125 修正 chen start
  beforeUnmount() {
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 start
    // EventBus.$off("selectPatInfoAddressOtherContact")
    if (this.selectPatInfoAddressEventName) {
      EventBus.$off(this.selectPatInfoAddressEventName, this.onSelectPatInfoAddress);
    }
    // mod #10789 新患登録画面を経由すると患者情報の住所が上書きできなくなる 本田 end
  },
  // add bug #7125 修正 chen end

  methods: {
    onSelectPatInfoAddress(event) {
      if (!this.mapVisible) return;

      this.setPatDataJsonArray(this.mapUpdateTarget, "address", event.address);
      this.setPatDataJsonArray(this.mapUpdateTarget, "zip_cd", event.zipCd);
      this.mapVisible = false;
      this.mapUpdateTarget = null;
    },
    ...mapActions("multi-modal", ["showAddressSearchModal"]),
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    getOtherContactPatPopoverAnchor(index) {
      const ref = this.$refs[`btnSelectPat${index}`];
      return ref ? (Array.isArray(ref) ? ref[0] : ref) : null;
    },
    addFocusEvent(event){
      let element = event.target;
      element.removeAttribute("readonly");
    },
    async selectOtherPat(index) {
      // 施設内の全患者を取得
      const uri = "/patInfo/getPatContactInfo";
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      // const response = await ApiHelper.get(uri).catch(error => {
      const resData = await ApiHelper.get(uri)
        .then(res => {
          return res.data
              .filter(value => value.is_del !== '1' || value.hosp_pat_id == this.jsonArray[index].pat_id.editValue)
          .map(item => ({
            ...item,
            pat_last_name: (item.is_del === "1")
                ? `【削除済み】${item.pat_last_name}`
                : item.pat_last_name,
          }));
        })
        .catch(error => {
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('OtherContactCardContent.vue', 'selectOtherPat', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw new Error(
              `[OtherContactCardContent.vue]selectOtherPat(): 施設内患者取得失敗
  エラー内容: ${error}`
          );
        });

      // TODO: 新規患者のときにも除外されてしまう
      if (this.selectedPat !== null) {
        // 選択患者は除外
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
        // this.patPersonalMain = response.data.filter(
        this.patPersonalMain = resData.filter(
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
          pat => pat.pat_id !== this.selectedPatId
        );
      } else {
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
        // this.patPersonalMain = response.data;
        this.patPersonalMain = resData;
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      }

      //facilityCdでフィルタリング
      this.patPersonalMain = this.patPersonalMain.filter(
        pat => pat.facility_cd === this.facilityCd
      );
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      // const patMain = response.data.filter(pat => pat.hosp_pat_id === this.jsonArray[index].pat_id.editValue);
      const patMain = resData.filter(pat => pat.hosp_pat_id === this.jsonArray[index].pat_id.editValue);
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      let value = null;
      if (patMain.length > 0) {
        value = patMain[0].pat_id;
      }

      this.resolvedPatIdByRow = {
        ...this.resolvedPatIdByRow,
        [index]: value
      };
      this.selectedIndex = index;
      await this.$nextTick();
      const cmsRef = this.$refs[`ocms${index}`];
      const cms = cmsRef && (cmsRef[0] || cmsRef);
      if (cms && typeof cms.openPopover === "function") {
        await cms.openPopover();
      }
    },

    otherContactComposeExtraParams(index) {
      const json = this.jsonArray[index];
      const hospPatId = json && json.pat_id ? json.pat_id.editValue : null;
      return {
        excludePatId: this.selectedPatId != null ? String(this.selectedPatId) : "",
        initHospPatId: hospPatId != null && hospPatId !== "" ? String(hospPatId) : ""
      };
    },

    otherContactPatRowItem(index) {
      const value = this.resolvedPatIdByRow[index];
      return { value: value != null ? value : null };
    },

    onOtherContactPatComposeReturn(data) {
      const selectedPatId = data != null ? data.value : null;
      this.setPatContactInfo(selectedPatId);
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      const requestParam = {
        facilityCd: this.selectedFacilityCd == "" ? this.facilityCd : this.selectedFacilityCd,
        selectedPatId: this.selectedPatId
      };

      // add by maxueqiang ,課題６＿マスタ削除・期限切れ・禁忌アレル...
      const deleteUri = "/mstInfo/mstRelationshipIncludeDel";
      const deleteResponse = await ApiHelper.get(deleteUri, requestParam).catch(error => {
        getErrorMessage('OtherContactCardContent.vue', 'created', error);
        throw new Error(
          `[OtherContactCardContent.vue]created(): マスタ取得失敗
        エラー内容: ${error}`
        );
      });

      this.deleteMstRelation = deleteResponse.data;
      const relationCds = this.editRecord?.[this.arrayColName]
          ?.filter(value => value !== undefined)
          ?.map(item => item?.relation_cd?.editValue);
      const dataFilter = deleteResponse.data.filter(item =>{
        return item.isDisp !== "0" && item.isDel !== "1"
      });
      this.mstRelation = dataFilter;
      this.delMstRelations = (Array.isArray(deleteResponse.data) ? deleteResponse.data : [])
          .filter(item => (item.isDisp === "0" || item.isDel === "1")
              && relationCds?.includes(item.relationshipCd))
          .map(item => ({
            ...item,
            relationshipName: (item.isDisp === "0" || item.isDel === "1")
                ? `【削除済み】${item.relationshipName}`
                : item.relationshipName,
          }));
      this.selectedIndex = null;
      this.resolvedPatIdByRow = {};
      this.syncArrRelationFromJsonArray();
      this.initRecord = deepCopy(this.editRecord);
    },

    // add FNSI-画面部品デザイン じょはく start
    setJsonIndex(json, index) {
      this.selectJson = json;
      this.selectIndex = index;
      this.deleteJsonArray( this.arrayColName, this.selectJson, this.selectIndex);
    },
    // add FNSI-画面部品デザイン じょはく end

    // 選択したIDとテーブル名pat_main内で一致した患者データを返す
    getPatPersonalMainRecord(selectedPatId) {
      return this.patPersonalMain.find(
        element =>
          element.pat_id === selectedPatId ||
          String(element.pat_id) === String(selectedPatId)
      );
    },

    // ポップオーバー確定イベントハンドラ
    setPatContactInfo(selectedPatId) {
      // add FNSI-連絡先のID選択と続柄選択で、クリアボタンを無くし、未登録を選択することでクリアと同等の動きにする liang start
      if ( selectedPatId == null || selectedPatId === "") {
        this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], "pat_id", null);
        this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], "last_name", null);
        this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], "first_name", null);
        this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], "last_name_kana", null);
        this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], "first_name_kana", null);
        for (const key of this.patContactInfoKeys) {
          this.setPatDataJsonArray(this.jsonArray[this.selectedIndex], key, null);
        }
      } else {
        // add FNSI-連絡先のID選択と続柄選択で、クリアボタンを無くし、未登録を選択することでクリアと同等の動きにする liang end
        // JSONをデシリアライズ
        const objectPatContactInfos = JSON.parse(
          this.getPatPersonalMainRecord(selectedPatId).pat_contact_info
        );
        // 選択ボタンを押した項目に院内IDを設定
        this.setPatDataJsonArray(
          this.jsonArray[this.selectedIndex],
          "pat_id",
          this.getPatPersonalMainRecord(selectedPatId).hosp_pat_id
        );
        this.setPatDataJsonArray(
          this.jsonArray[this.selectedIndex],
          "last_name",
          this.getPatPersonalMainRecord(selectedPatId).pat_last_name
        );
        this.setPatDataJsonArray(
          this.jsonArray[this.selectedIndex],
          "first_name",
          this.getPatPersonalMainRecord(selectedPatId).pat_first_name
        );
        this.setPatDataJsonArray(
          this.jsonArray[this.selectedIndex],
          "last_name_kana",
          this.getPatPersonalMainRecord(selectedPatId).pat_last_name_kana
        );
        this.setPatDataJsonArray(
          this.jsonArray[this.selectedIndex],
          "first_name_kana",
          this.getPatPersonalMainRecord(selectedPatId).pat_first_name_kana
        );
        // 各項目に選択IDの関係情報を設定
        for (const key of this.patContactInfoKeys) {
          this.setPatDataJsonArray(
            this.jsonArray[this.selectedIndex],
            key,
            objectPatContactInfos[key]
          );
        }
      }
    },

    setRelation(selectedMst, index) {
      this.arrRelation[index] = selectedMst?.value;
      this.setPatDataJsonArray(this.jsonArray[index], "relation_cd", selectedMst?.value);
      this.setPatDataJsonArray(this.jsonArray[index], "relation_name", selectedMst?.text);
    },

    // IDクリア
    clearPatID(json) {
      this.setPatDataJsonArray(json, "pat_id", null);
      this.setPatDataJsonArray(json, "last_name", null);
      this.setPatDataJsonArray(json, "first_name", null);
      this.setPatDataJsonArray(json, "last_name_kana", null);
      this.setPatDataJsonArray(json, "first_name_kana", null);
      for (const key of this.patContactInfoKeys) {
        this.setPatDataJsonArray(json, key, null);
      }
    },

    // 患者IDセットフラグ
    hasPatId(json) {
      // mod FutreNetWeb+SI課題管理No5797 趙 start
      // return this.getPatDataJsonArray(json, "pat_id").editValue !== null;
      return true;
      // mod FutreNetWeb+SI課題管理No5797 趙 end
    },

    // 続柄コードセットフラグ
    hasRelationCd(json) {
      return this.getPatDataJsonArray(json, "relation_cd").editValue !== null;
    },

    // 続柄コードクリア
    clearRelationCd(index, json) {
      this.arrRelation[index] = null;
      this.setPatDataJsonArray(json, "relation_cd", null);
      this.setPatDataJsonArray(json, "relation_name", null);
    },

    syncArrRelationFromJsonArray() {
      this.arrRelation = this.jsonArray.map(item => item?.relation_cd?.initValue ?? null);
    },

    // 続柄名称取得
    relationName(json) {
      if (this.hasRelationCd(json)) {
        const selectedRelationName = this.getPatDataJsonArray(json, "relation_name").editValue;
        if (selectedRelationName) {
          return selectedRelationName;
        }
        // コードがセットされている場合はマスタ名称
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
        // return this.mstCdToName(
        return this.mstCdToNameIncludeDeleted(
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
          this.deleteMstRelation,
          json.relation_cd.editValue,
          "relationshipCd",
          "relationshipName"
        );
      } else {
        // 手入力の場合はその内容
        return this.getPatDataJsonArray(json, "relation_name").editValue;
      }
    },

    // 項目追加処理
    addItem() {
      // 新規項目作成
      const newItem = {
        ctl_no: 0,
        disp_order: 0,
        is_key_person: "0",
        pat_id: null,
        last_name: null,
        first_name: null,
        last_name_kana: null,
        first_name_kana: null,
        relation_cd: null,
        relation_name: null,
        zip_cd: null,
        address: null,
        tel1: null,
        tel2: null,
        fax: null,
        e_mail: null,
        work_name: null,
        work_address: null,
        work_tel: null,
        memo1: null,
        memo2: null
      };
      this.pushJsonArray(this.arrayColName, newItem);
    },
    async setContentData(newValue, paramName, index) {
      this.setPatDataJsonArray(this.jsonArray[index], paramName, newValue);
    },
    // 続柄の選択は CommonMasterSelector に移行済み
    // mod 患者名入力チェック不正について、対応する。 dengshen start
    // filterInput(e){
    //   e.target.value = e.target.value.replace(/[`~!@#$%^&*()_\-+=<>?:"{}|,./;'\\[\]·~！@#￥%……&*（）——\-+={}|《》？：“”【】、；‘’，。、]/g, '').replace(/\s/g, "");
    // },
    filterInput: _.debounce(function (e) {
      e.target.value = e.target.value.replace(/[`~!@#$%^&*()_+=<>?:"{}|,./;'\\[\]·~！@#￥%……&*（）——+={}|《》？：“”【】、；‘’，。、＃-]/g, '').replace(/\s/g, "");
    }),
    // mod 患者名入力チェック不正について、対応する。 dengshen end
  }
};
</script>

<!-- カード共通スタイル読み込み -->
<style src="../base-components/BaseCardStyle.css" scoped></style>
<style scoped>
/* カード個別のスタイルはここ */
.card-table .card-index-row td {
  padding: 0;
}
.zip-hyphen {
  font-size: 10px;
}
.card-table :deep(textarea.custom-textarea) {
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
:deep(ons-checkbox.checkbox) {
  margin-top: 0;
}

/* CommonMasterSelector 根が v-ons-col で幅100%になり後続ボタンが折り返すのを防ぐ */
.other-contact-master-actions {
  display: inline-flex;
  flex-direction: row;
  flex-wrap: nowrap;
  align-items: center;
  vertical-align: middle;
}
.other-contact-master-actions :deep(ons-col),
.other-contact-master-actions :deep(.v-ons-col) {
  width: auto;
  flex: 0 0 auto;
}
</style>
