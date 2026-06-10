<template>
  <div class="display-area">
    <div class="flex-area">
      <div scope="col" class="button-content-area">
        <div class="btn-left">
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 mod start -->
          <!-- <v-ons-button
            class="nik-btn btn-left btn3-normal"
            modifier="outline"
            @click="addGroup"
            >新規登録</v-ons-button
          > -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   class="nik-btn btn-left btn3-normal" -->
          <!--   modifier="outline" -->
          <!--   :disabled="editFlag" -->
          <!--   @click="addGroup" -->
          <!--   >新規登録</v-ons-button -->
          <!-- > -->
          <v-ons-button
            class="nik-btn btn-left btn3-normal"
            modifier="outline"
            :disabled="editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
            @click="addGroup"
            >新規登録</v-ons-button
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 mod end -->
        </div>
        <div class="btn-right">
          <v-ons-button
            v-show="!isPatGroupEditComponent"
            modifier="outline"
            class="nik-btn btn2-cancel"
            style="margin-right: 10px;"
            @click="applyCancelSort"
            v-if="isAllowSort">キャンセル</v-ons-button
          >
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 mod start -->
          <!-- <v-ons-button
            v-show="!isPatGroupEditComponent"
            modifier="outline"
            class="nik-btn btn3-normal"
            @click="displaySort"
            v-if="!isAllowSort">設定編集</v-ons-button
          > -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-show="!isPatGroupEditComponent" -->
          <!--   modifier="outline" -->
          <!--   class="nik-btn btn3-normal" -->
          <!--   :disabled="editFlag" -->
          <!--   @click="displaySort" -->
          <!--   v-if="!isAllowSort">設定編集</v-ons-button -->
          <!-- > -->
          <v-ons-button
            v-show="!isPatGroupEditComponent"
            modifier="outline"
            class="nik-btn btn3-normal"
            :disabled="editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
            @click="displaySort"
            v-if="!isAllowSort">設定編集</v-ons-button
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!-- 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 mod end -->
          <v-ons-button
            v-show="!isPatGroupEditComponent"
            modifier="outline"
            class="nik-btn btn1-execute"
            @click="applySort"
            v-if="isAllowSort">保存</v-ons-button
          >
        </div>
      </div>
      <div class="main-content-area" style="width: 99.5%;">
        <table class="ntss-list">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky " style="width: 0.30em;" scope="col" v-show="!isAllowSort"></th>
              <th class="ntss-list-header-th-sticky " style="width: 13.8em; min-width: 13.8em;" scope="col" v-show="isAllowSort">並び順</th>
              <th class="ntss-list-header-th-sticky " style="min-width: 13.8em;" scope="col">患者グループ名</th>
              <th class="ntss-list-header-th-sticky " style="width: 13.8em; min-width: 13.8em;" scope="col" v-show="isAllowSort">連携コード1</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="patGroup in patGroups"
              :key="patGroup.patGroupCd"
              :id="'patGroup_' + patGroup.patGroupCd"
              @click="selectPatGroup(patGroup.patGroupCd)"
            >
              <td
                v-show="!isAllowSort"
                class="ntss-list-body-td-first"
                @click="editGroup(patGroup.patGroupCd)"
              ></td>
              <td
                class="order-td"
                :class="getRowStyleClassSort(patGroup)"
                v-show="isAllowSort"
                @click="showSortInput(patGroup)"
              >
                <span
                  class="order-input"
                  :class =" {'display-edit': isOnlySort(patGroup.patGroupCd)}"
                >
                  <span :class="{'k-dirty': patGroup.isEdited}"></span>
                  {{patGroup.index}}
                </span>
              </td>
              <td
                class="ntss-list-body-td name-td"
                :class="{'master-edited-row': patGroup.isEitedPatGroup}"
                @click="editGroup(patGroup.patGroupCd)"
              >
                {{ patGroup.patGroupName }}
              </td>
              <td
                v-if="isAllowSort && !patGroup.isInHospitalCd_1"
                class="ntss-list-body-td"
                :class="{'master-edited-row master-edited-cell': patGroup.isEitedPatGroup}"
                @click="validInputBox(patGroup.patGroupCd)"
              >
                {{ patGroup.inHospitalCd_1 }}
              </td>
              <td
                v-if="isAllowSort && patGroup.isInHospitalCd_1"
                :class="{'master-edited-row': patGroup.isEitedPatGroup}"
              >
                <input type="text"
                  :id="'txtInHospitalCd_1_' + patGroup.patGroupCd"
                  v-model="patGroup.inHospitalCd_1"
                  class="input-text"
                  maxLength="20"
                  @change="changePatGroup(patGroup.patGroupCd)"
                  @keypress.enter="inValidInputBox(patGroup.patGroupCd)"
                  @blur="inValidInputBox(patGroup.patGroupCd)"
                />
              </td>
            </tr>
          </tbody>
        </table>
        <!-- Loading -->
        <v-ons-modal :visible="isLoading">
          <p class="loading-modal">
            {{ loadingMessage }}
            <v-ons-icon icon="fa-spinner" spin />
          </p>
        </v-ons-modal>
      </div>
    </div>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  /*mod FNSI-改修内容患者グループbug 任 start*/
  /*import {mapGetters} from "vuex";*/
  import {mapActions, mapGetters} from "vuex";
  /*mod FNSI-改修内容患者グループbug 任 end*/
  import PatGroup from "@/apis/pat-group";
  /*add FNSI-改修内容患者groupbug 任 start*/
  import {ApiHelper} from "@/apis/AxiosHelper";
  /*add FNSI-改修内容患者groupbug 任 end*/
  import {EventBus} from "@/eventBus.js";
  // add 画面印刷プレビューと印刷の実現 黄 start
  import moment from "moment";
  import {getCurrentFunctionCd} from "@/router/routing-helper";
  // add 画面印刷プレビューと印刷の実現 黄 end
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  // add #9561 患者グループでの並び順設定が他の画面と異なる 商 start
  import $ from "jquery";
  // add #9561 患者グループでの並び順設定が他の画面と異なる 商 end
  import { messageFormat } from '@/functions/common/MessageFormat';
  // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add start
  // del #10359 編集権限の動作不正 dengshen start
  // import { AUTHORITY_CODES } from "@/constants/userAuthority";
  // del #10359 編集権限の動作不正 dengshen end
  import { FUNC_PAT_INFO } from "@/constants/function-code";
  // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add end、
  // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
  import store from "@/stores";
  // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end

export default {
  name: "PatGroupListComponent",
  data() {
    return {
      patGroups: [],
      isLoading: false,
      loadingMessage: "",
      initPatGroups: [],
      /*add FNSI-改修内容患者groupbug 任 start*/
      sameList: null,
      /*add FNSI-改修内容患者groupbug 任 end*/
      isAllowSort: false,
      sortStatusList: [],
      selfScreenName: "",
      isPatGroupEditComponent: false,
      isSortMode: false,
      // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add start
      // del #10359 編集権限の動作不正 dengshen start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // del #10359 編集権限の動作不正 dengshen end
      editFlag: null,
      // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add end
      condition: ""
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 房 start
    //...mapGetters("pat-group", ["isEditedSort", "isEitedPatGroupList"]),
    ...mapGetters("pat-group", ["isEditedSort", "isEitedPatGroupList", "selectedPatGroup"]),
    // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 房 end
    // add 画面印刷プレビューと印刷の実現 黄 end
    // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add start
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add end
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
    currentPath() {
      return this.$route.path;
    }
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
  },
  watch: {
    $route() {
      this.initializeSort();
      this.getPatGroups();
      this.selectPatGroup(this.$route.params.patGroupCd);
    },
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
    currentPath(newPath) {
      if(newPath.toString().includes("edit")){
        store.dispatch("report/getMstReport", {funcCd: "02303",printFlag: 0});
      }else {
        store.dispatch("report/getMstReport", {funcCd: "02303",printFlag: 1});
      }
    }
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
  },
  methods: {
    /*add FNSI-改修内容患者グループbug 任 start*/
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("pat-group", ["setIsEditedSort", "setIsEitedPatGroupList"]),
    /*add FNSI-改修内容患者グループbug 任 end*/
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    getPatGroups() {
      if (this.$route.name === "pat-group") {
        this.startLoading("患者グループリストを取得しています");
      }

      PatGroup.list(this.facilityCd)
        .then(({ data }) => {
          if (data.patGroupInfo) {
            let index = 1;
            data.patGroupInfo.forEach(e => {
              e.index = index++;
              // add #9561 患者グループでの並び順設定が他の画面と異なる 商 start
              e.oldIndex = e.index;
              e.inputDate = null;
              // add #9561 患者グループでの並び順設定が他の画面と異なる 商 end
            });
          }
          data.patGroupInfo.forEach(item => {
            item.isEdited = false;
            this.sortStatusList.push({
              patGroupCd: item.patGroupCd,
              sortStatus: false
            });
          });
          // 患者グループ属性の付与
          data.patGroupInfo.forEach(item => {
           item.isInHospitalCd_1 = false;
           item.isEitedPatGroup = false;
          })
          // 検索条件入力済の場合
          if (this.condition != "") {
            const filterList = data.patGroupInfo.filter(patGroup => patGroup.patGroupName.toLowerCase().includes(this.condition));
            this.patGroups = filterList;
            this.initPatGroups = data.patGroupInfo;
          } else {
            this.patGroups = data.patGroupInfo;
            this.initPatGroups = data.patGroupInfo;
          }
        })
        .finally(() => this.stopLoading());
    },
    // add 画面印刷プレビューと印刷の実現 黄 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
        let paramPatIds = [];
        if(this.selectedPatGroup && this.selectedPatGroup.selectedPatList) {
          paramPatIds = this.selectedPatGroup.selectedPatList.map(({ pat_id }) => pat_id);
        }
        //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
        // 印刷パラメータを応答
        const param = {
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 start
          patIds: paramPatIds,
          //mod #9558 機能帳票でパラメータが正しく渡されていない 房 end
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
          //facilityCd: this.getFacilityCd,
          facilityCd: this.facilityCd,
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
          // add #7233 デフォルト帳票について 日本指摘対応 商 start
          functionCd:"02301",
          // add #7233 デフォルト帳票について 日本指摘対応 商 end
          date: moment(Date.now()).format("YYYY/MM/DD"),
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
          fromDate:moment((new Date())).format("YYYY/MM/DD"), // 検索条件の対象期間開始日は当日を設定する
          toDate: moment(new Date()).format("YYYY/MM/DD") // 検索条件の対象期間終了日は当日を設定する
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end
    addGroup() {
      /*mod FNSI-改修内容患者groupbug 任 start*/
      /*this.$router.push({ name: "pat-group-new" });*/
      const sameList = this.sameList;
      if (this.isEditedSort || this.isEitedPatGroupList) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer == 1) {
              this.setIsEditedSort(false);
              this.setIsEitedPatGroupList(false);
              this.$router.push({ name: "pat-group-new",params:{ sameList } });
            }
          }
        });
      } else {
        // すでに新規登録画面を表示している場合はrefreshを行う
        // 新規表示の場合のみ画面遷移を行う
        if(this.$route.name === "pat-group-new"){
          EventBus.$emit("refresh",true);
        }else{
          this.$router.push({ name: "pat-group-new",params:{ sameList } });
        }
      }
      /*mod FNSI-改修内容患者groupbug 任 end*/
    },
    editGroup(patGroupCd) {
      /*mod FNSI-改修内容患者groupbug 任 start*/
      /*this.$router.push({ name: "pat-group-edit", params: { patGroupCd } });*/
      const sameList = this.sameList;
      if (this.isEditedSort || this.isEitedPatGroupList) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer == 1) {
              this.setIsEditedSort(false);
              this.setIsEitedPatGroupList(false);
              this.$router.push({ name: "pat-group-edit", params: { patGroupCd,sameList } });
            }
          }
        });
      } else {
        this.$router.push({ name: "pat-group-edit", params: { patGroupCd,sameList } });
      }
      /*mod FNSI-改修内容患者groupbug 任 end*/
    },
    // 並び順の編集イベント
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 start
    // changeSort(patGroup) {
    //   patGroup.isEdited = true;
    //   this.setIsEditedSort(true);
    // },
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 end
    startLoading(message) {
      this.isLoading = true;
      this.loadingMessage = message;
    },
    stopLoading() {
      this.isLoading = false;
    },
    // (患者グループ)並び順モードの設定
    setPatGroupsSortMode(isSortPatGroups) {
      if (isSortPatGroups) {
        this.isAllowSort = true;
        this.isSortMode = true;
      } else {
        this.isAllowSort = false;
        this.isSortMode = false;
      }
      EventBus.$emit('setSortMode', this.isSortMode);
    },
    setFilterCondition(condition) {
      if(condition.patGroupName && condition.patGroupName.trim() !="") {
        const filterList = this.initPatGroups.filter(patGroup => patGroup.patGroupName.toLowerCase().includes(condition.patGroupName.trim().toLowerCase()));
        this.patGroups = filterList;
        this.condition = condition.patGroupName.trim().toLowerCase();
      } else {
        this.patGroups = this.initPatGroups;
        this.condition = "";
      }
    },
    // 並び順の表示イベント
    displaySort() {
      this.setPatGroupsSortMode(true);
    },
    // 並び順のキャンセルイベント
    applyCancelSort() {
      if (this.isEditedSort || this.isEitedPatGroupList) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer == 1) {
              this.initializeSort();
              this.getPatGroups();
              this.selectPatGroup()
            }
          }
        });
      } else {
        this.initializeSort();
        this.getPatGroups();
        this.selectPatGroup()
      }
    },
    // 並び順保存イベント
    async applySort() {
      this.patGroups = this.patGroups.sort((a, b) => {
        // mod #9561 患者グループでの並び順設定が他の画面と異なる 商 start
        //return +a.index - +b.index;
        return (+a.index - +b.index || a.inputDate - b.inputDate);
        // mod #9561 患者グループでの並び順設定が他の画面と異なる 商 end
      });
      this.patGroups.forEach(item => { item.isEdited = false });
      // (編集済)患者グループの抽出
      const editedPatGroupList = this.patGroups.filter((item) => item.isEitedPatGroup == true);
      // 患者グループ一覧の更新
      await PatGroup.updatePatGroupList(this.facilityCd, editedPatGroupList)
        .then(() => {
          this.patGroups.forEach(item => {
            item.isInHospitalCd_1 = false;
            item.isEitedPatGroup = false;
          })
          this.setIsEitedPatGroupList(false);
        });
      // 患者グループ並び順の更新
      await PatGroup.updateMstSelector(this.facilityCd, this.patGroups)
        .then(() => {
          this.initializeSort();
          this.getPatGroups();
          this.selectPatGroup();
        });
    },
    isOnlySort(patGroupCd) {
      let sortStatus = false;
      for (const item of this.sortStatusList) {
        if (patGroupCd === item.patGroupCd) {
          sortStatus = item.sortStatus;
          break;
        }
      }

      return sortStatus;
    },
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 start
    // showSortInput(patGroupCd) {
    //   for (const item of this.sortStatusList) {
    //     if (item.patGroupCd === patGroupCd) {
    //       item.sortStatus = true;
    //       this.$nextTick(() => {
    //         document.getElementById('sort_input_' + patGroupCd).focus();
    //       });
    //     } else {
    //       item.sortStatus = false;
    //     }
    //   }
    // },
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 end
    // add #9561 患者グループでの並び順設定が他の画面と異なる 商 start
    showSortInput(patGroup) {
      if(patGroup.isEdited) {
        return;
      }
      var evtTarget = event.target || event.srcElement;
      if (evtTarget.tagName === "SPAN") evtTarget = evtTarget.parentNode;
      const oldValue = evtTarget.innerText;
      if(!this.isAllowSort) {
        return;
      }
      patGroup.isEdited = true;
      const spanSort = evtTarget.getElementsByTagName("span")[0];
      spanSort.style.display='none';
      $(
        `<input name="list_name">`
      ).appendTo(evtTarget)
        .kendoNumericTextBox({
          format: "n0",
          min: 0,
          max: 2147483647,
          setp: 1,
          value: oldValue
        })
        .blur(function(){$(this.parentNode.parentNode).remove();spanSort.style.display='inline';patGroup.isEdited=false})
        .change((e)=>{this.setContentData(e.target.value,patGroup)});

      $(evtTarget).find("input").get(0).focus();
    },
    setContentData(newValue, patGroup){
      patGroup.index = newValue;
      patGroup.inputDate = Date.now();
      this.setIsEditedSort(true);
    },
    getRowStyleClassSort(patGroup) {
      if (patGroup.index !== patGroup.oldIndex) {
        return "master-sort-edited";
      }
      return "";
    },
    // add #9561 患者グループでの並び順設定が他の画面と異なる 商 end
    /*add FNSI-改修内容患者グループbug 任 start*/
    async refresh(){
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      if (this.isEditedSort || this.isEitedPatGroupList) {
        const isDispose = await this.$ons.notification.confirm(
          messageFormat(DIALOG_MESSAGES[13000004].message),
          {title: DIALOG_MESSAGES[13000004].title}
        );
        if (isDispose == 1) {
          this.refreshScreen();
        }
      } else {
        this.refreshScreen();
      }
    },
    // リフレッシュ処理の本処理
    async refreshScreen() {
      this.setLoadingScreenVisible(true);
      await this.initializeSort();
      await this.getPatGroups();
      await this.selectPatGroup()
      this.setLoadingScreenVisible(false);
    },
    /*add FNSI-改修内容患者グループbug 任 end*/
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 start
    // hideSortInputs() {
    //   this.sortStatusList.forEach(item => item.sortStatus = false);
    // },
    // del #9561 患者グループでの並び順設定が他の画面と異なる 商 end
    // 並び順の初期化
    initializeSort() {
      this.isPatGroupEditComponent = this.$route.name == "pat-group-new" || this.$route.name == "pat-group-edit" ? true : false;
      this.setPatGroupsSortMode(false);
      this.setIsEditedSort(false);
      this.setIsEitedPatGroupList(false);
    },
    // 入力欄の有効化
    validInputBox(patGroupCd) {
      this.patGroups.forEach(item => {
        if (item.patGroupCd == patGroupCd) {
          item.isInHospitalCd_1 = true;
        }
      })
    },
    // 入力欄の無効化
    inValidInputBox(patGroupCd) {
      this.patGroups.forEach(item => {
        if (item.patGroupCd == patGroupCd) {
          item.isInHospitalCd_1 = false;
        }
      })
    },
    // 患者グループの変更
    changePatGroup(patGroupCd) {
      this.patGroups.forEach(item => {
        if (item.patGroupCd == patGroupCd) {
          item.isEitedPatGroup = true;
          this.setIsEitedPatGroupList(true);
        }
      })
    },
    // 患者グループの選択
    selectPatGroup(patGroupCd = null) {
      this.clearSelectedPatGroup();
      if (patGroupCd != null) {
        const element = document.getElementById("patGroup_" + patGroupCd);
        if (element) {
          element?.classList?.add("selected-row");
        } else {
          return;
        }
      }
    },
    // 患者グループ選択行のクリア
    clearSelectedPatGroup() {
      Array.from(document.getElementsByClassName("selected-row")).forEach(element => {
        element.classList.remove("selected-row");
      });
    },
    // 入力欄のフォーカス
    focusInputBox() {
      this.patGroups.forEach(item => {
        if (item.isInHospitalCd_1) {
          const element = document.getElementById("txtInHospitalCd_1_" + item.patGroupCd);
          element.focus();
        }
      })
    }
  },
  created() {
    // // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add start
    // mod #10359 編集権限の動作不正 dengshen start
    // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    // this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    // this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    this.editFlag = !this.getUseFunctions.includes(FUNC_PAT_INFO);
    // mod #10359 編集権限の動作不正 dengshen end
    // // 9820-利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう zhoubin 20231114 add end
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    this.sortStatusList = [];
    this.getPatGroups();
    /*add FNSI-改修内容患者groupbug 任 start*/
    // mod 8220 施設イベント詳細画面の表示が遅い 関 start
    // ApiHelper.get('/bbsInfo/getIsSame').then(rsp => {
    //   this.sameList = rsp.data;
    // })
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw start
    // ApiHelper.post('/bbsInfo/getPatIsSame',[this.facilityCd]).then(rsp => {
    ApiHelper.post('/bbsInfo/getPatIsSame').then(rsp => {
      // #11205 -ペンテスト2－4認可制御の不備  mod 20260317 shiyw end
      this.sameList = rsp.data;
    })
    // mod 8220 施設イベント詳細画面の表示が遅い 関  end
    // add 性能改善メモリ不足 shan start
    EventBus.$off("filterPatGroupist", this.setFilterCondition);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    /*add FNSI-改修内容患者groupbug 任 end*/
    /*add FNSI-改修内容患者グループbug 任 start*/
    EventBus.$on("refresh", this.refresh);
    /*add FNSI-改修内容患者グループbug 任 end*/
    EventBus.$on("filterPatGroupist", this.setFilterCondition);
    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
  },
  updated() {
    this.$nextTick(() => {
      this.focusInputBox();
    });
  },
  beforeDestroy() {
    EventBus.$off("filterPatGroupist", this.setFilterCondition);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("refresh", this.refresh);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // 並び順の初期化
    this.initializeSort();
    // 患者グループ選択の初期化
    this.selectPatGroup();
// add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
    store.dispatch("report/getMstReport", {funcCd: "02303",printFlag: 1});
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
  }
};
</script>

<style scoped>
.ntss-list {
  /* margin-top: 5px; */
  position: relative;
}
.loading-modal {
  font-size: 2.5em;
}
.selected-row {
  color: var(--master-maintenance-kgrid-selected-color);
  background-color: var(--master-maintenance-kgrid-selected-background-color) !important;
}
.order-input {
  display: block;
  padding-left: 8px;
  width: 13.8em;
  color: var(--ntss-list-body-color);
}
input.order-input {
  font-size: 1em
}
.k-edit-cell .order-td {
  padding: 4px 12px;
}
.order-td {
  border: solid 1px var(--ntss-list-border-color);
  height: 2.4em;
}
.focus {
  padding: 4px 12px;
}
.btn-left {
  text-align: left;
}
.btn-right {
  text-align: right;
}
.ntss-list-header-th-sticky {
  z-index: 1;
}
.ntss-list-body-td-first {
  border: solid 1px var(--ntss-list-border-color);
  padding: 8px 0px;
  width: 0.3em;
  height: 1.5em;
}
.display-edit {
  display: none;
}
.master-sort-edited .k-dirty {
  border-color: #050505 transparent transparent #050505;
}
.display-area {
  height: 100%;
  width: 100%;
}
.flex-area {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
}
.button-content-area {
  display: flex;
  justify-content: space-between;
  margin: 0 5px 0 5px;
}
.main-content-area {
  position: relative;
  top: 5px;
  bottom: 0;
  left: 0;
  right: 0;
  overflow-x: auto;
  overflow-y: auto;
  margin: 5px;
  margin-top: 0;
  height: 100%;
}
/* add #9561 患者グループでの並び順設定が他の画面と異なる 商 start */
.order-td >>> .k-numerictextbox{
  width: calc(94% - 12px);
  font-size: 1em;
}
/* add #9561 患者グループでの並び順設定が他の画面と異なる 商 end */
.name-td {
  word-break: keep-all;
}
.input-text {
  border: 2px green solid !important;
  height: 2.5em;
  margin: 0 8px 0 8px;
  vertical-align: middle
}
</style>
