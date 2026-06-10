/**
 * 施設全宅モーダル画面用ページ
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="facility-body" id="destination-group-modal-content">
      <!-- 全施設検索 -->
      <div id="sys-facility-search-wrapper">
        <!-- mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start -->
        <sys-facility-search @GetFilterData="GetFilterData"/>
        <!-- <sys-facility-search /> -->
        <!-- mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end -->
      </div>
      <!-- 一覧 -->
      <div id="staff-list-wrapper" style="overflow: auto" :style="heightStyles">
        <table class="ntss-list sticky_table" style="position: relative;">
          <thead>
            <tr>
              <th
                style="z-index: 5; white-space: normal ; text-align:center;"
                class="ntss-list-header-th-sticky"
              >
                <!--mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start-->
                <!--全選択ボタン-->
                <ons-checkbox v-if="isEditing" :disabled="true"></ons-checkbox>
                <ons-checkbox v-else @click="allFunctionChange"></ons-checkbox>
              </th>
              <th class="ntss-list-header-th-sticky">施設名</th>
              <th class="ntss-list-header-th-sticky">都道府県</th>
              <th class="ntss-list-header-th-sticky">電話番号</th>
              <th class="ntss-list-header-th-sticky">FAX</th>
              <th class="ntss-list-header-th-sticky">住所</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(facility, index) in facilityList"
              :class="'ntss-list-body-tr'"
              :key="index"
              @click="onRowClick(facility)"
            >
              <td class='ntss-list-body-td td-select'>
                <ons-checkbox
                  v-if="isEditing && facility.facilityCd.length > 0"
                  @click.stop="onChangeChk(facility, $event)"
                  :disabled="addedFacilityCds.includes(facility.facilityCd) && facility.facilityCd !== getEditRecord.favoriteFacilityCd"
                  :checked="facility.facilityCd === selectedFacility.facilityCd || (addedFacilityCds.includes(facility.facilityCd) && facility.facilityCd !== getEditRecord.favoriteFacilityCd)"
                  ref="checkboxlist"
                ></ons-checkbox>
                <!--変更   施設コード=="" -->
                <ons-checkbox
                  v-else-if="isEditing && facility.facilityCd.length == 0"
                  @click.stop="onChangeChk(facility, $event)"
                  :disabled="addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd) && facility.medicalInstitutionCd !== getEditRecord.medicalInstitutionCd"
                  :checked="facility.medicalInstitutionCd === selectedFacility.medicalInstitutionCd || (addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd) && facility.medicalInstitutionCd !== getEditRecord.medicalInstitutionCd)"
                  ref="checkboxlist"
                ></ons-checkbox>
                <!--追加   施設コード=="" -->
                <ons-checkbox
                  v-else-if="!isEditing && facility.facilityCd.length > 0"
                  @click.stop="toggleSelectedFacility(facility)"
                  :disabled="addedFacilityCds.includes(facility.facilityCd)"
                  :checked="selectedFacilityCds.includes(facility.facilityCd) || addedFacilityCds.includes(facility.facilityCd)"
                  ref="checkboxlist"
                ></ons-checkbox>
                <!--追加   施設コード=="" -->
                <ons-checkbox
                  v-else-if="!isEditing && facility.facilityCd.length == 0"
                  @click.stop="toggleSelectedFacility(facility)"
                  :disabled="addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd)"
                  :checked="selectedMedicalInstitutionCds.includes(facility.medicalInstitutionCd) || addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd)"
                  ref="checkboxlist"
                ></ons-checkbox>
                <!--mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end -->
              </td>
              <td class='ntss-list-body-td'>{{ facility.facilityName }}</td>
              <td class='ntss-list-body-td'>{{ facility.prefName }}</td>
              <td class='ntss-list-body-td'>{{ facility.phoneNo }}</td>
              <td class='ntss-list-body-td'>{{ facility.faxNo }}</td>
              <td class='ntss-list-body-td'>{{ facility.address }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <button class="btn2-cancel button denial-btn" @click="cancel">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <button class="common-style-select-button button registration-btn" :disabled="registeredFlag" @click="onConfirm">確定</button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters, mapMutations, mapState } from "vuex";
import { EventBus } from "@/eventBus.js";
import SysFacilitySearchComponent from "@/components/master-maintenance/mst-favorite-facility/SysFacilitySearchComponent";
import _ from "underscore";
// add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
import { ApiHelper } from '../../../apis/AxiosHelper';
// add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
import cloneDeep from "lodash/cloneDeep";
import isEqual from "lodash/isEqual";

export default {
  name: "MstFavoriteFacilityEditModal",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase,
    "sys-facility-search": SysFacilitySearchComponent
  },
  data() {
    return {
      facilityList: [],
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: 'right',
      listHeight: 500,
      defaultFacilityCd: "",
      // 医療機関コード の場合
      defaultMedicalInstitutionCd: "",
      selectedFacility: {
        facilityCd: "",
        medicalInstitutionCd: "",
        prefCd: "",
        facilityName: "",
        address: "",
        phoneNo: "",
        faxNo: "",
        prefName: "",
      },
      selectedFacilities: [],
      //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
       // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo start
      // limit: 0,
      lastScrollTop: 0,
       // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo end
      scrollFlag: true,
      initCondition: null,
      //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
      // 全施設マスタ取得時に指定するoffset
      offset: 0,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", [
      "getEditRecord",
      // "getMasterRecordList"
    ]),
    ...mapGetters("mst-favorite-facility", {
      storeCondition:"condition"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    // ...mapGetters("master-maintenance", {
      // getFilteredMasterRecordList: "getFilteredMasterRecordList",
    // }),
    ...mapState("master-maintenance", ["gridData"]),
    // add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    heightStyles() {
      // リストの高さをCSS変数を利用して書き換え
      return { "height": `${this.listHeight}px` };
    },
    isEditing() {
      return !_.isEmpty(this.getEditRecord);
    },
    registeredFlag() {
      return this.isEditing ? isEqual(this.selectedFacility, this.selectedFacilityClone) : this.selectedFacilities.length === 0;
    },
    selectedFacilityCds() {
      return this.selectedFacilities.map(f => f.favoriteFacilityCd);
    },
    addedFacilityCds() {
      return this.gridData.map(d => d.favoriteFacilityCd);
    },
    addedFacilityCdsWithoutDefault() {
      return this.addedFacilityCds.filter(favoriteFacilityCd => favoriteFacilityCd !== this.getEditRecord.favoriteFacilityCd);
    },
    // 医療機関コード の場合
    selectedMedicalInstitutionCds() {
      return this.selectedFacilities.map((f) => f.medicalInstitutionCd);
    },
    addedMedicalInstitutionCds() {
      return this.gridData.map((d) => d.medicalInstitutionCd);
    },
    addedMedicalInstitutionCdsWithoutDefault() {
      return this.addedMedicalInstitutionCds.filter(medicalInstitutionCd => medicalInstitutionCd !== this.getEditRecord.medicalInstitutionCd);
    }
  },
  watch: {
    /**
      * ウィンドウの高さが変更された時
      */
    windowHeight() {
      this.calculateListHeight();
    },
  },
  methods: {
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      // "editRecordBeEmpty",
      "setMasterRecordList"
    ]),
    ...mapMutations("master-maintenance", [
      "setMstFavoriteFacilityAddRows"
    ]),

    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    ...mapActions("mst-favorite-facility", [
      "setConditionPrefCd",
      "conditionsClear",
      "getMstFacilityByCd"
    ]),
    // ...mapActions("mst-favorite-facility", [
    //   "setConditionPrefCd",
    //   "fetchAllFacility",
    //   "conditionsClear"
    // ]),
    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    calculateListHeight() {
      // 画面の高さ
      const fullHeight = document.getElementById("destination-group-modal-content").clientHeight;
      // ヘッダーの高さ
      const headHeight = document.getElementById("sys-facility-search-wrapper").clientHeight
      // リストの高さを設定
      this.listHeight = fullHeight - (headHeight + 10);
    },
    setFacilityList() {
      // let sorted = [];
      // console.log(JSON.stringify(this.gridData))
      // this.gridData.forEach(sort => {
      //   this.facilityByCondition.forEach(e => {
      //     if (sort.medicalInstitutionCd === e.medicalInstitutionCd) {
      //       sorted.push(e);
      //     }
      //   })
      // });
      // this.facilityByCondition.forEach(e => {
      //   if (!sorted.includes(e)) {
      //     sorted.push(e)
      //   }
      // });
      // //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
      // const list = sorted.slice(0, this.limit)
      // console.log(JSON.stringify(list))
      // this.facilityList = list;
      //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    },
    setSelectedFacility() {
      const record = this.getEditRecord;
      // 当該行 ≠ 「削除」の場合
      if (record.isDisp === '1') {
        this.selectedFacility = {
          facilityCd: record.favoriteFacilityCd ? record.favoriteFacilityCd : "",
          // 医療機関コード の場合
          medicalInstitutionCd: record.medicalInstitutionCd ? record.medicalInstitutionCd : "",
          prefCd: record.prefCd ? record.prefCd : "",
          facilityName: record.name ? record.name : "",
          address: record.address ? record.address : "",
          phoneNo: record.phoneNo ? record.phoneNo : "",
          faxNo: record.faxNo ? record.faxNo : "",
          prefName: record.prefName ? record.prefName : "",
      }
      this.selectedFacilityClone = cloneDeep(this.selectedFacility);
      this.defaultFacilityCd = record.favoriteFacilityCd ? record.favoriteFacilityCd : "";
      // 医療機関コード の場合
      this.defaultMedicalInstitutionCd = record.medicalInstitutionCd ? record.medicalInstitutionCd : "";
      }
    },
    /**
     * 全体オン/オフ
     */
    allFunctionChange(e) {
      this.$refs.checkboxlist.forEach((item) => {
        let rowIndex = item.parentNode.parentNode.rowIndex;
        // 選択されていない項目
        if (!item.disabled) {
          // 全選択ボタン選択
          if (e.currentTarget.checked == true) {
            // 最小の状態
            if (item.checked == false) {
              this.toggleSelectedFacility(this.facilityList[rowIndex - 1]);
            }
            item.checked = true;
          } else {
            if (item.checked == true) {
              this.toggleSelectedFacility(this.facilityList[rowIndex - 1]);
            }
            item.checked = false;
          }
        }
      });
    },

    onChangeChk(facility) {
      // mod redmine #4533対応 孔 start
      // if ((facility.facilityCd.length != 0 && (
      //   this.selectedFacility.facilityCd === facility.facilityCd ||
      //   this.addedFacilityCds.includes(facility.facilityCd)))
      //   // 医療機関コード の場合
      //   || (facility.facilityCd.length == 0 && (
      //   this.selectedMedicalInstitutionCds.medicalInstitutionCd === facility.medicalInstitutionCd ||
      //   this.addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd)))
      // ) {
      //   return;
      // }
      // 選択施設 = 選択済施設の場合
      if (facility.facilityCd.length > 0 && this.addedFacilityCdsWithoutDefault.includes(facility.facilityCd) ||
        facility.facilityCd.length == 0 && this.addedMedicalInstitutionCdsWithoutDefault.includes(facility.medicalInstitutionCd)) {
        return;
      }

      if (
        this.selectedFacility.facilityCd === facility.facilityCd &&
        this.selectedFacility.medicalInstitutionCd === facility.medicalInstitutionCd
      ) {
        this.selectedFacility = {
          facilityCd: "",
          medicalInstitutionCd: "",
          prefCd: "",
          facilityName: "",
          address: "",
          phoneNo: "",
          faxNo: "",
          prefName: "",
        }
        return
      }
      // mod redmine #4533対応 孔 end
      this.selectedFacility = facility;
    },
    toggleSelectedFacility(facility) {
     if (facility.facilityCd.length > 0 &&
     this.addedFacilityCds.includes(facility.facilityCd)
     // 医療機関コード の場合
     || facility.facilityCd.length == 0 &&
     this.addedMedicalInstitutionCds.includes(facility.medicalInstitutionCd)) {
        return;
      }

      const index = this.selectedFacilities.findIndex(
        f => (facility.facilityCd.length > 0 && f.favoriteFacilityCd === facility.facilityCd )
        // 医療機関コード の場合
        || (facility.facilityCd.length == 0 && f.medicalInstitutionCd === facility.medicalInstitutionCd)
      );
      if (index >= 0) {
        this.selectedFacilities.splice(index, 1);
      } else {
        this.selectedFacilities.push(this.makeFavoriteFacilityRecord(facility));
      }
    },
    onRowClick(facility) {
      this.isEditing
        ? this.onChangeChk(facility)
        : this.toggleSelectedFacility(facility);
    },
    onConfirm() {
      this.isEditing ? this.registration() : this.closeModalWindow(this.selectedFacilities);
    },
    /**
     * 処理：選択・入力された情報で権限情報登録(更新)
     */
    registration() {
      if (this.selectedFacility.facilityCd.length > 0 && (this.selectedFacility.facilityCd === this.defaultFacilityCd)
      // 医療機関コード の場合
      || this.selectedFacility.facilityCd.length == 0 && (this.selectedFacility.medicalInstitutionCd === this.defaultMedicalInstitutionCd)
      ) {
        // 変更がない場合は何もしないで画面を閉じる
        // mod redmine #4533対応 孔 start
        // this.closeModalWindow();
        if (this.getEditRecord.isDisp === "1") this.closeModalWindow();
        // mod redmine #4533対応 孔 end
      }
      // 編集中マスタを更新
      // mod redmine #4533対応 孔 start
      // this.setEditRecord({
      //   ...this.getEditRecord,
      //   ...this.makeFavoriteFacilityRecord(this.selectedFacility)
      // });
      const editRecord = cloneDeep(this.getEditRecord);
      if (this.selectedFacility.facilityCd.length == 0 && this.selectedFacility.medicalInstitutionCd.length == 0) {
        editRecord.isDisp = '0';
      } else {
        const selectedRowItem = this.makeFavoriteFacilityRecord(this.selectedFacility);
        Object.keys(selectedRowItem).forEach((key) => {
          editRecord[key] = selectedRowItem[key];
        });
        editRecord.isDisp = "1";
      }
      this.setEditRecord(editRecord);
      this.closeModalWindow();
    },
    makeFavoriteFacilityRecord(facility = {}) {
      return {
        name: facility.facilityName,
        favoriteFacilityCd: facility.facilityCd,
        medicalInstitutionCd: facility.medicalInstitutionCd,
        prefCd: facility.prefCd,
        prefName: facility.prefName,
        phoneNo: facility.phoneNo,
        faxNo: facility.faxNo,
        address: facility.address,
      }
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 編集有無の初期化
      let isEdit = false;
      // 「追加」・「変更」の判別
      if (!this.isEditing) {
        // -----追加処理-----
        // (新規)追加件数 > "0"の場合
        if (this.selectedFacilityCds.length > 0) {
          // 編集済
          isEdit = true;
        }
      } else {
        // ----変更処理----
        // 選択施設 ≠ (デフォルト)施設の場合
        if (this.selectedFacility.facilityCd !== this.defaultFacilityCd ||
          this.selectedFacility.facilityCd.length == 0 && (this.selectedFacility.medicalInstitutionCd !== this.defaultMedicalInstitutionCd)) {
          // 編集済
          isEdit = true;
        }
      }
      // 編集済の場合
      if (isEdit) {
        // 破棄確認の表示
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            // OK
            if (answer == 1) {
              // 画面の終了
              this.closeModalWindow();
            }
          }
        });
      } else {
        // 画面の終了
        this.closeModalWindow();
      }
    },
    /**
     * モーダル画面を閉じる処理
     */
    closeModalWindow(payload = []) {
      // state.editRecordを空にする
      // this.editRecordBeEmpty();
      this.hideModal();
      this.setMstFavoriteFacilityAddRows(payload);
      // EventBus.$emit("onCloseMasterEditModal", payload);
    },
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    handleScroll () {
      const dom = document.getElementById('staff-list-wrapper')
      const clientHeight = dom.clientHeight
      const scrollTop = dom.scrollTop
      const scrollHeight = dom.scrollHeight
      // mod 9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo start
      if (scrollTop > this.lastScrollTop) {
      if (Math.abs(scrollHeight - scrollTop - clientHeight) < 4 && this.scrollFlag) {
        this.scrollFlag = false;
        this.getList(this.$store.state['mst-favorite-facility'].condition)
        }
      }
      this.lastScrollTop = scrollTop;
      // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo end
    },
    async getList(condition) {
      this.setLoadingScreenVisible(true)
      const arr = this.gridData.map(item => item.medicalInstitutionCd)
      // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo start
      const getAllFacility = await ApiHelper.post(`/master_maintenance/mst_favorite_facility/getSysFacility/${this.offset}?selectedInsCd=${arr.toString()}`,condition)
      // if (getAllFacility.data.length < 100) {
      //   this.scrollFlag = false
      // }
      // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo end
      for (let i = 0; i < getAllFacility.data.length; i++) {
        this.facilityList.push({
          "facilityCd": getAllFacility.data[i].facilityCd || '',
          "prefCd": getAllFacility.data[i].prefCd,
          "medicalInstitutionCd": getAllFacility.data[i].medicalInstitutionCd,
          "facilityName": getAllFacility.data[i].facilityName,
          "address": getAllFacility.data[i].address,
          "phoneNo": getAllFacility.data[i].phoneNo,
          "faxNo": getAllFacility.data[i].faxNo,
          "prefName": getAllFacility.data[i].prefName
        })
      }
      
      // 全施設マスタ取得時のoffsetカウントアップ 
      // ** よく使う施設マスタ登録済（画面上部に固定表示）のデータ件数はoffsetに含めない **
      this.offset += getAllFacility.data.length;
      
      this.scrollFlag = true
      this.setLoadingScreenVisible(false)
    },
    GetFilterData(data) {
       // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo start
      // this.limit = 0
      // this.scrollFlag = false
       // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo end
      document.getElementById('staff-list-wrapper').scrollTop = 0;
      // 値クリア
      this.facilityList = [];
      this.offset = 0;
      const arr = this.getMasterRecordListByCondition(data.inUsed)
      arr.forEach((item) => {
        this.facilityList.push({
          "facilityCd": item.favoriteFacilityCd || '',
          "prefCd": item.prefCd,
          "medicalInstitutionCd": item.medicalInstitutionCd,
          "facilityName": item.name,
          "address": item.address,
          "phoneNo": item.phoneNo,
          "faxNo": item.faxNo,
          "prefName": item.prefName
        })
      })
      this.getList(data.inUsed)
    },
    getMasterRecordListByCondition(condition) {
      const _freeWord = condition.freeWord ? condition.freeWord.toLowerCase() : ''
      const _prefCd = condition.prefCd
      const arr = this.gridData.filter((facility) => {
        let searchBool = true
        if (_freeWord) {
          // add/ #12699 よく使う施設マスタの追加ウィンドウでフリーワード検索が不正 tianqidong start
          const facilityName = (facility.name || '').toLowerCase()
          const phoneNo = (facility.phoneNo || '').toLowerCase()
          const faxNo = (facility.faxNo || '').toLowerCase()
          const address = (facility.address || '').toLowerCase()
          if (facilityName.indexOf(_freeWord) >= 0 || phoneNo.indexOf(_freeWord) >= 0 || faxNo.indexOf(_freeWord) >= 0 || address.indexOf(_freeWord) >= 0) {
          // add/ #12699 よく使う施設マスタの追加ウィンドウでフリーワード検索が不正 tianqidong end  
            searchBool = true;
          }else{
            return false;
          }
        }
        if (_prefCd){
          if (facility.prefCd === _prefCd) {
            searchBool = true;
          }else{
            return false;
          }
        }
        return searchBool
      })
      return arr
    }
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
  },
  async created() {
    // add redmine #4533対応 孔 start
    await this.setConditionPrefCd(this.getEditRecord.prefCd || "")
    // add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    // mod よく使う施設マスタ　初期表示不正、都道府県が表示不正のタイミングがある zhaoqi xugj start
    await this.getMstFacilityByCd(this.facilityCd).then(response => {
      this.$store.state['mst-favorite-facility'].condition.prefCd = response.data.prefecturesCd !== null && response.data.prefecturesCd.trim() ?
        response.data.prefecturesCd : "";
    })
    // mod よく使う施設マスタ　初期表示不正、都道府県が表示不正のタイミングがある zhaoqi xugj end
    // add redmine #4533対応 孔 end
    this.setLoadingScreenVisible(true)
    this.setLoadingScreenMessage('処理中・・・')
    const arr = this.getMasterRecordListByCondition(this.$store.state['mst-favorite-facility'].condition)
    arr.forEach((item) => {
      this.facilityList.push({
        "facilityCd": item.favoriteFacilityCd || '',
        "prefCd": item.prefCd,
        "medicalInstitutionCd": item.medicalInstitutionCd,
        "facilityName": item.name,
        "address": item.address,
        "phoneNo": item.phoneNo,
        "faxNo": item.faxNo,
        "prefName": item.prefName
      })
    })
    this.initCondition = JSON.parse(JSON.stringify(this.$store.state['mst-favorite-facility'].condition))
    await this.getList(this.$store.state['mst-favorite-facility'].condition)
    // this.setFacilityList();
    // add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    this.setSelectedFacility();
    this.setLoadingScreenVisible(false)
    EventBus.$on("setFacilityList", this.setFacilityList);
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
  },
  mounted() {
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    window.addEventListener("scroll", this.handleScroll, true)
     // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo start
    this.lastScrollTop = document.getElementById('staff-list-wrapper').scrollTop;
     // mod #9497 よく使う施設マスタの施設選択画面で最下部の追加読み込みが動かない zhangbo end
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    this.$nextTick(() => {
      this.calculateListHeight();
    });
  },
  beforeDestroy() {
    this.conditionsClear();
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    window.removeEventListener("scroll", this.handleScroll, true)
    //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    EventBus.$off("setFacilityList", this.setFacilityList);
  }
};
</script>

<style scoped>
#destination-group-modal-content {
  height: 100%;
}
.facility-body{
  padding: 0 3px 0 3px;
  overflow: hidden;
}
.list-item__center {
  background-position: bottom;
}
.button-label {
  width: 5em;
}
.sticky_table{
  overflow: auto;
}
.td-select {
  text-align: center;
  z-index: 2;
  background-color: var(--ntss-list-background-color);
}
.sticky_table th:first-child,td:first-child {
  /* 横スクロール時に固定する */
  position: -webkit-sticky;
  position: sticky;
  left: 0;
}

</style>
