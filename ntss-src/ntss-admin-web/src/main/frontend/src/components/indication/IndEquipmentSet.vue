/** * 医療材料セット */

<template>
  <div>
    <v-ons-row class="container-row-style">
      <v-ons-col width="10em"> 医療材料セット </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButtonEquipmentSet" -->
        <!--   class="common-style-select-button" -->
        <!--   @click="createPopoverDataEquipmentSet()" -->
        <!-- > -->
        <common-master-selector
          :masterType="MasterType.EQUIPMENT_SET_RECORD"
          :initItem="{ value: null }"
          :editItem="{ value: null }"
          :extraParams="{ treatDate: getIndStartDate }"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :hasChangedOption="false"
          :changeOptionMode="'nameOnly'"
          :hasUnregisteredOption="false"
          :btnName="'追加'"
          :isVisible="false"
          :btnClass="'common-style-select-button'"
          :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
          @popover-return="updateInputEquipmentSet"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="container-row-style">
      <v-ons-col width="10em"> 医療材料 </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   ref="popoverButtonEquipment" -->
        <!--   class="common-style-select-button" -->
        <!--   @click="createPopoverDataEquipment()" -->
        <!-- > -->
        <common-master-selector
          :masterType="MasterType.EQUIPMENT_TREATMENT_RECORD"
          :initItem="{ value: null }"
          :editItem="{ value: null }"
          :extraParams="{ treatDate: getIndStartDate }"
          :patientId="selectedPatId"
          :facilityCd="facilityCd"
          :hasChangedOption="false"
          :changeOptionMode="'nameOnly'"
          :hasUnregisteredOption="false"
          :btnName="'追加'"
          :isVisible="false"
          :btnClass="'common-style-select-button'"
          :btnDisabled="!getItemAuthorized('Indication', 'default_authority')"
          @popover-return="updateInputEquipment"
        />
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="container-row-style">
      <div class="content-div-style">
        <div v-show="isLoading" class="content-loading-style">
          <v-ons-icon icon="fa-spinner" size="20px" spin="true" />
        </div>
        <div v-show="!isLoading" class="equipment-set-style">
          <div v-show="listData.length === 0">医療材料を追加してください</div>
          <!-- modify by chamaojia 2023-08-01 [9197] 医療材料セットは正常な順序で展示されており、順序を反転する必要はありません  start -->
          <v-ons-row
            v-for="(data, index) in listData"
            :key="data.id"
            class="equipment-set-row-style"
          >
          <!-- modify by chamaojia 2023-08-01 [9197] 医療材料セットは正常な順序で展示されており、順序を反転する必要はありません  end -->
            <v-ons-col>
              <ind-equipment-edit
                :ref="data.id"
                :fields-data="data"
                :show-all-select-tag="true"
                :has-dialyzer-option="true"
                :is-create="true"
              />
            </v-ons-col>
            <v-ons-col class="equipment-set-delete-container-style">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-button -->
              <!--   class="equipment-set-delete-button-style" -->
              <!--   @click="deleteRow(index)" -->
              <!-- > -->
              <button
                class="ntss-btn-outset button-delete"
                @click="deleteRow(index)"
                :disabled="!getItemAuthorized('Indication', 'default_authority')"
              >
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <v-ons-icon icon="fa-trash"/>
              </button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
    </v-ons-row>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { dialyzerTabooAllergy, dialyzerTabooAllergyIncludeDeleted, equipmentClass, equipmentSetWithDeleted, equipmentTabooAllergy, equipmentTabooAllergyIncludeDeleted } from "@/functions/mst/MstGetters.js";
import _ from "@/compat/collections/lodash";
import { nextId } from "@/functions/common/id";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import IndEquipmentEdit from "@/components/indication/IndEquipmentEdit";
import { EventBus } from "@/compat/vue/event-bus.js";
import { dateFormat, fitTermCheck, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
//mod FNSI-5910 劉全航 start
// import { ApiHelper } from "@/apis/AxiosHelper";
// import { createJournal } from "@/apis/journal";
//mod FNSI-5910 劉全航 end
// mod #6107 2023/03/22 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
import { messageFormat } from "@/functions/common/MessageFormat";
// mod #6107 2023/03/22 メッセージボックス全調整 張博 end
import * as MasterType from "@/components/common/master-selector/MasterType";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";

export default {
  mixins: [IndicationOwnerMixin],
  components: {
    "pop-over": MasterSelector,
    "ind-equipment-edit": IndEquipmentEdit,
    "common-master-selector": commonMasterSelector
  },

  data() {
    return {
      MasterType,
      popoverDataEquipmentSet: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      popoverDataEquipment: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        //#10126:医療材料選択IF追加修正 Start
        popoverContentSelected: {},
        hasUnregisteredOption: false
        //#10126:医療材料選択IF追加修正 End
      },
      listData: [],
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initialListLength: 0,
      listEditDirty: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      isLoading: false,
      equipmentSetData: [],
      includeDeletedEquipmentByCd: null,
      includeDeletedDialyzerByCd: null,
      includeDeletedMapsPromise: null,
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 start
      // 実績変更フラグ
      isRstUpdateFlg: false,
      // 実績の変更をするか確認するメッセージフラグ
      isShowedMessage: false
      // add FNSI-【1006】最新の改修対象一覧のIES475対応 韓 end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    //mod FNSI-5910 劉全航 start
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    //mod FNSI-5910 劉全航 end
    /* del by chamaojia 2023-09-28 [9197] この関数は使用されていません  --start */
    // // FNSI-#5909 編集画面にマスト登録した順番で表示されるように修正 ljx modify start
    // reverseListData() {
    //     return this.listData.reverse();
    // }
    // //FNSI-#5909 編集画面にマスト登録した順番で表示されるように修正 ljx modify end
    /* del by chamaojia 2023-09-28 [9197] この関数は使用されていません  --end */
  },

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),

    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    ensureIncludeDeletedMaps() {
      if (this.includeDeletedEquipmentByCd) {
        return Promise.resolve();
      }
      if (this.includeDeletedMapsPromise) {
        return this.includeDeletedMapsPromise;
      }
      this.includeDeletedMapsPromise = Promise.all([
        equipmentTabooAllergyIncludeDeleted(this.selectedPatId),
        dialyzerTabooAllergyIncludeDeleted(this.selectedPatId)
      ])
        .then(([equipmentData, dialyzerData]) => {
          this.includeDeletedEquipmentByCd = new Map(
            equipmentData.map(item => [item.equipmentCd, item])
          );
          this.includeDeletedDialyzerByCd = new Map(
            dialyzerData.map(item => [item.dialyzerCd, item])
          );
        })
        .catch(error => {
          this.includeDeletedMapsPromise = null;
          getErrorMessage("IndEquipmentSet.vue", "ensureIncludeDeletedMaps", error);
          throw error;
        });
      return this.includeDeletedMapsPromise;
    },

    buildSetRowFromMaster(item, equipType) {
      const verifyMaster = equipType === 0
        ? this.includeDeletedEquipmentByCd
        : this.includeDeletedDialyzerByCd;
      const verifyCodeName = equipType === 0 ? "equipmentCd" : "dialyzerCd";
      const equipData = verifyMaster?.get(item.cd);
      const cd = equipData?.[verifyCodeName];
      if (!cd) {
        return null;
      }
      const displayName = equipData
        ? getPrefix({ treatDate: this.getIndStartDate, ...equipData })
          + (equipType === 0 ? equipData.equipmentName : equipData.modelNumber)
        : "";
      return {
        id: nextId("equipment"),
        cd,
        amount: item.amount,
        equipType,
        displayName,
        unit: equipData?.unit ?? null
      };
    },

    /**
     * @description 医療材料セット
     *              ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverDataEquipmentSet() {
      this.ensureIncludeDeletedMaps();
      this.equipmentSetData = await equipmentSetWithDeleted(this.selectedPatId).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndEquipmentSet.vue', 'createPopoverDataEquipmentSet', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        }
      );

      const contentArr = this.equipmentSetData.map(item => {
        return {
          value: item.equipmentSetCd,
          text: item.equipmentSetName
        };
      });
      this.popoverDataEquipmentSet.popoverTitleHeader = "医療材料セット";
      this.popoverDataEquipmentSet.popoverContentLabel = "医療材料セット名";
      this.popoverDataEquipmentSet.popoverContentDataset = contentArr;
      this.popoverDataEquipmentSet.popoverVisible = true;
    },

    /**
     * @description 医療材料
     *              ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     */
    async createPopoverDataEquipment() {
      this.ensureIncludeDeletedMaps();
      const equipmentData = await equipmentTabooAllergy(this.selectedPatId)
        .then(response => {
          // 予定範囲と医療材料の使用期限を見て表示内容を補正する
          return response.filter(equipment => {
            return fitTermCheck(equipment.useStartDate, equipment.useEndDate, this.getIndStartDate);
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndEquipmentSet.vue', 'createPopoverDataEquipment', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
      const classData = await equipmentClass(this.facilityCd).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndEquipmentSet.vue', 'createPopoverDataEquipment', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };

      let filterArr = classData.map(filterMapping);
      // del #8203 2022/12/23 医療材料編集モーダル＞分類選択プルダウンの選択肢修正 dou start
      //mod FNSI-6937 劉全航 start
      // filterArr.unshift({ text: "すべて", value: 0 });
      // filterArr.unshift(
      //     { text: "すべて", value: 0 },
      //     { text: "未登録", value: -1}
      // );
      //mod FNSI-6937 劉全航 end
      // del #8203 2022/12/23 医療材料編集モーダル＞分類選択プルダウンの選択肢修正 dou end
      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      const contentParamIsDisp = item => {
        return item.isDisp === "1";
      };
      const contentMapping = item => {
        return {
          value: item.equipmentCd,
          fnValue: {
            医療材料分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: item.equipmentName
          text: getPrefix(item) + item.equipmentName,
          unit: item.unit
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      const contentArr = equipmentData
        .filter(contentParamIsDisp)
        .map(contentMapping);
      // ダイアライザをフィルタデータに追加
      filterArr.push({
        text: "ダイアライザ",
        //mod FNSI-6829 劉全航 start
        // value: -1
        value: "dialyzer"
        //mod FNSI-6829 劉全航 end
      });
      // add #8203 2022/12/23 医療材料編集モーダル＞分類選択プルダウンの選択肢修正 dou start
      filterArr.unshift({ text: "すべて", value: 0 });
      filterArr.push({ text: "未登録", value: -1 });
      // add #8203 2022/12/23 医療材料編集モーダル＞分類選択プルダウンの選択肢修正 dou end
      const dialyzerDataset = await dialyzerTabooAllergy(this.selectedPatId)
        .then(response => {
          // 予定範囲と医療材料の使用期限を見て表示内容を補正する
          return response.filter(dialyzer => {
            return fitTermCheck(dialyzer.useStartDate, dialyzer.useEndDate, this.getIndStartDate);
          });
        });

      // ダイアライザをコンテンツデータに追加
      const contentDialyzer = dialyzerDataset
        .filter(item => {
          return item.isDisp === "1";
        })
        .map(item => {
          return {
            // 医療材料と競合するため、マスター選択用値を作って使用
            value: `dialyzer${item.dialyzerCd}`,
            cd: item.dialyzerCd,
            fnValue: {
              //mod FNSI-6829 劉全航 start
              // 医療材料分類: -1
              医療材料分類: "dialyzer"
              //mod FNSI-6829 劉全航 end
            },
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
            // text: item.equipmentName
            text: getPrefix(item) + item.modelNumber,
            unit: item.unit
            // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          };
        });

      contentArr.push(...contentDialyzer);

      this.popoverDataEquipment.popoverTitleHeader = "医療材料";
      this.popoverDataEquipment.popoverFilter = [
        {
          popoverFilterLabel: "医療材料分類",
          popoverFilterDataset: filterArr
        }
      ];
      this.popoverDataEquipment.popoverContentLabel = "医療材料名";
      this.popoverDataEquipment.popoverContentDataset = contentArr;
      this.popoverDataEquipment.popoverVisible = true;
    },

    /**
     * @description 医療材料セットマスター選択を非表示
     */
    closePopoverEquipmentSet() {
      this.popoverDataEquipmentSet.popoverVisible = false;
    },

    /**
     * @description 医療材料マスター選択を非表示
     */
    closePopoverEquipment() {
      this.popoverDataEquipment.popoverVisible = false;
    },

    /**
     * @description 医療材料セットマスター選択から選択後のコールバック
     */
    updateInputEquipmentSet(data) {
      const setInfoRaw = data?.setInfo;
      if (setInfoRaw == null || setInfoRaw === "") {
        return;
      }
      let equipmentSetJson;
      try {
        if (typeof setInfoRaw === "string") {
          equipmentSetJson = JSON.parse(setInfoRaw);
        } else if (Array.isArray(setInfoRaw)) {
          equipmentSetJson = setInfoRaw;
        } else if (
          typeof setInfoRaw === "object" &&
          setInfoRaw.value != null &&
          typeof setInfoRaw.value === "string"
        ) {
          equipmentSetJson = JSON.parse(setInfoRaw.value);
        } else {
          equipmentSetJson = setInfoRaw;
        }
      } catch (error) {
        getErrorMessage("IndEquipmentSet.vue", "updateInputEquipmentSet", error);
        return;
      }
      if (!Array.isArray(equipmentSetJson)) {
        return;
      }
      const appendRows = () => {
        const listData = equipmentSetJson
          .map(item => {
            const equipType = !Object.prototype.hasOwnProperty.call(item, "equip_type")
              ? 0
              : item.equip_type;
            return this.buildSetRowFromMaster(item, equipType);
          })
          .filter(item => item && item.cd);
        if (listData.length > 0) {
          this.listData = this.listData.concat(listData);
          this.markListEdited();
        }
      };
      if (this.includeDeletedEquipmentByCd) {
        appendRows();
        return;
      }
      this.ensureIncludeDeletedMaps()
        .then(appendRows)
        .catch(() => {});
    },

    /**
     * @description マスター選択から選択後のコールバック
     */
    updateInputEquipment(data) {
      if (!data?.value) {
        return;
      }
      const isDialyzer =
        data?.key_class === "-2" ||
        data?.key_class === -2 ||
        data?.dialyzerCd != null ||
        data?.dialyzerType != null ||
        data?.fnValue?.["医療材料分類"] === "dialyzer";
      const listData = [{
        id: nextId("equipment"),
        cd: data.value,
        amount: "1",
        equipType: isDialyzer ? 1 : 0,
        displayName: data.text || "",
        unit: data.unit ?? null
      }];
      this.listData = this.listData.concat(listData);
      this.markListEdited();
    },

    /**
     * @description 医材セットから項目を削除
     */
    deleteRow(item) {
      this.listData.splice(item, 1);
      this.markListEdited();
    },
    markListEdited() {
      this.listEditDirty = true;
    },

    /**
     * @description APIにリクエストする
     */
    async updateIndInfo(structData) {
      // 必須項目の入力チェック
      let hasError = false;
      // メッセージ置換文字
      let stringParam = null;
      const equipmentSetItems = _.omit(this.$refs, "popoverButton");

      // 未選択チェック
      if (await this.chkUnselected(equipmentSetItems)) {
        stringParam = "医療材料";
        this._indicationDialogOwner().messageDialogInfo.messageCd = 22010001;
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.stringParams = [stringParam];
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        return true;
      }

      // 使用期限のチェック
      if (!await this.chkInExpiryDate(equipmentSetItems, structData.indStartDate, structData.indEndDate)) {
        // キャンセルの場合処理終了
        return true;
      }
      //mod FNSI-5910 劉全航 start
      /* del by chamaojia 2023-08-07 [9303] このパラメータや論理判断は不要  --start */
      // let countMax = 0
      // for (const key in equipmentSetItems) {
      //   if (equipmentSetItems[key][0]) {
      //     countMax = countMax + 1;
      //   }
      // }
      // let iCount = 0
      /* del by chamaojia 2023-08-07 [9303] このパラメータや論理判断は不要  --end */
      let sendJsonList = [];
      let sharedOrdMainList = null;
      if (structData.type && "equip-create" === structData.type) {
        const startDate = structData.indStartDate.replace(/-/g, "");
        const endDate = structData.indEndDate == null
          ? null
          : structData.indEndDate.replace(/-/g, "");
        const searchData = await ApiHelper.get(
          `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
        ).catch(error => {
          getErrorMessage("IndEquipmentSet.vue", "updateIndInfo", error);
          throw error;
        });
        sharedOrdMainList = searchData.data;
      }
      for (const key in equipmentSetItems) {
        if (equipmentSetItems[key][0]) {
          /* del by chamaojia 2023-08-07 [9303] このパラメータや論理判断は不要  --start */
          // iCount = iCount + 1;
          // if (iCount != countMax) {
          //   structData.nLstFlg = 1;
          // } else {
          //   structData.nLstFlg = null;
          // }
          /* del by chamaojia 2023-08-07 [9303] このパラメータや論理判断は不要  --end */
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
          let sendJson = await equipmentSetItems[key][0].updateIndInfo(
            structData,
            null,
            null,
            sharedOrdMainList
          );
          if(sendJson){
            sendJsonList.push(sendJson);
          }
          // await equipmentSetItems[key][0].updateIndInfo(structData);
          /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */
        }
      }
      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---start */
      // add #12455 条件送信後に医材変更＆実績反映すると数量が0になる zkm start
      let response;
      if (structData.type && 'equip-create' === structData.type) {
        response = await ApiHelper.post(
          "/patients/equip/create",
          sendJsonList
        ).catch(error => {
          getErrorMessage("IndEquipmentSet.vue", "updateIndInfo", error);
          throw error;
        });
      } else {
        response = await ApiHelper.post(
          "/mainData/createOrdMainEquipInfoBatch",
          sendJsonList
        ).catch(error => {
          getErrorMessage("IndEquipmentSet.vue", "updateIndInfo", error);
          throw error;
        });
      }

      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
      if (200 === response.status && 22020004 === response.data.msgCd) {
        this._indicationDialogOwner().messageDialogInfo.messageCd = response.data.msgCd;
        this._indicationDialogOwner().messageDialogInfo.type = "1";
        this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
        return;
      }
      // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

      /* add by shiyw 2022-08-26 [FNSI-6961] --> Performance Optimization: change "One medicine one Ajax call" to "All medicine in one Ajax call"  ---end */
      if (!hasError) {
        EventBus.$emit("isRefresh");
        // モーダルを閉じる
        this._hideIndicationModal();
      }
    },

    //mod FNSI-5910 劉全航 start
    // async showUpdateCheckDialog(flag) {
    //     let rtn = false;
    //     await this.$ons.notification.confirm({
    //       title: "",
    //       message: "条件送信済みまたは治療中、治療終了後の指示を変更しました。<br>" +
    //                "実績データへの反映をしますか？",
    //       callback: answer => {
    //         if (answer === 1) {
    //           rtn = true;
    //         }
    //       }
    //     });
    //     if (flag ===1) {
    //       // 薬剤を追加した場合
    //       this.isShowedMessage = true;
    //     }
    //     return rtn;
    // },
    //mod FNSI-5910 劉全航 end

    /**
     * 未選択項目チェック処理
     */
    async chkUnselected(equipmentSetItems) {
      let rtn = false;
      for (const key in equipmentSetItems) {
        if (equipmentSetItems[key][0]) {
          if (!equipmentSetItems[key][0].equipmentInputValue.editValue) {
            rtn = true;
          }
        }
      }
      return rtn;
    },

    /**
     * 使用期限のチェック処理
     */
    async chkInExpiryDate(equipmentSetItems, indStartDate, indEndDate) {
      let msg = "";
      for (const key in equipmentSetItems) {
        const child = equipmentSetItems[key][0];
        if (child) {
          const selectedObj = child.popoverData?.popoverContentSelected || {};
          const materialClass = selectedObj.fnValue?.["医療材料分類"];
          const isDialyzer = child.fieldsData?.equipType === 1
            || materialClass === "dialyzer"
            || materialClass === -1;
          if (isDialyzer) {
            // ダイアライザの場合
            const dialyzerCd = selectedObj.cd ?? child.fieldsData?.cd;
            const tmpDialyzerObj = this.$store.getters["pat-viewer/getMstDialyzerData"].filter(
              dialyzer => dialyzer.dialyzerCd === dialyzerCd
            );
            if (tmpDialyzerObj.length > 0) {
              const dialyzerObj = tmpDialyzerObj[0];
              if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, indStartDate, indEndDate)) {
                msg += "</br>" + dialyzerObj.modelNumber + "："
                    + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                    + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
              }
            }
          } else {
            // 医療材料の場合
            const equipmentCd = selectedObj.value ?? child.fieldsData?.cd;
            const tmpEquipmentObj = this.$store.getters["pat-viewer/getMstEquipmentData"].filter(
              equipment => equipment.equipmentCd === equipmentCd
            );
            if (tmpEquipmentObj.length > 0) {
              const equipmentObj = tmpEquipmentObj[0];
              if (!fitTermCheckForUpdate(equipmentObj.useStartDate, equipmentObj.useEndDate, indStartDate, indEndDate)) {
                msg += "</br>" + equipmentObj.equipmentName + "："
                    + dateFormat.normalDateWithCheck(equipmentObj.useStartDate)
                    + "～" + dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
              }
            }
          }
        }
      }
      if (msg) {
        let rtn = false;
        // 処理中スクリーンを一旦解除
        this.setLoadingScreenVisible(false);
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000057].title,
          // message: "指示期間に使用期間外となる医療材料が含まれています。" + msg + "</br>登録してよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000057].message,msg),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              // 処理を続行するので処理中スクリーンを復帰
              this.setLoadingScreenVisible(true);
              rtn = true;
            } else {
              // 処理を中止するので保存ボタン無効を解除
              this._indicationDialogOwner().updateDisable = false;
            }
          }
        });
        return rtn;
      } else {
        // チェック対象項目なし / 期限切れ項目なしの場合
        return true;
      }
    },

    /**
     * チェック処理
     */
    checkEdit(num) {
      // キャンセル時チェック処理
      if (1 === num) {
        const equipmentSetItems = this.$refs;
        let isCheck = false;

        Object.keys(equipmentSetItems).forEach(key => {
          if (equipmentSetItems[key][0]) {
            if (equipmentSetItems[key][0].checkEdit()) {
              this._indicationDialogOwner().messageDialogInfo.messageCd = 20010001;
              this._indicationDialogOwner().messageDialogInfo.type = "2";
              this._indicationDialogOwner().messageDialogInfo.isDialogVisible = true;
              isCheck = equipmentSetItems[key][0].checkEdit();
            }
          }
        });
        return isCheck;
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isEdit(){
      return this.listEditDirty || this.listData.length !== this.initialListLength;
    },
  },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
  mounted(){
    this.initialListLength = this.listData.length;
    this.listEditDirty = false;
  }
  // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
};
</script>

<style scoped>
.container-row-style {
  margin-bottom: 5px;
}

.equipment-set-input-style {
  width: 65%;
  margin: 0px 5px 0px 0px;
}

.content-div-style {
  width: 100%;
  overflow: hidden auto;
  border: 1px solid rgb(154, 154, 154);
}

.content-loading-style {
  text-align: center;
}

.equipment-set-style {
  border-collapse: collapse;
}

.equipment-set-row-style {
  text-align: left;
  border-bottom: 1px solid rgb(154, 154, 154);
}

.equipment-set-delete-container-style {
  vertical-align: top;
  flex: 0;
}

:deep(.ntss-custom-input-cond) {
  height: 2em;
  font-size: inherit;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  display: -webkit-inline-box;
  display: -ms-inline-flexbox;
  display: inline-flex;
}

.button-delete {
  height: 100%;
}
</style>
