<template>
  <div>
    <div class="container" id="container" :style="containerHeight">
      <!-- ログインした名前を表示する -->
      <div class="user-name">
        <div class="user-name-text">{{ getUserName }}</div>
        <div class="label-user-name">ログイン名</div>
      </div>

      <!-- 施設データとユーザーデータを切り替える -->
      <kendo-tabstrip class="k-tabstrip">
        <ul>
          <li class="k-state-active" @click="displayFacility">施設一覧</li>
          <li id="user-tab" @click="displayUser" v-if="isAdminUser">ユーザ一覧</li>
        </ul>
      </kendo-tabstrip>

      <!-- 施設データ -->
      <!--mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
      <!-- <div
        id="main-content-area-facility"
        class="main-content-area master-maintenance-page"
        v-if="showFacility"
      > -->

      <div
        id="main-content-area-facility"
        class="main-content-area master-maintenance-page"
        v-show="showFacility"
      >
      <!--mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        <div class="ntss-list">
          <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
            <div class="header-btn-area">
              <form autocomplete="off">
                <v-ons-input
                  id="searchValue"
                  class="search-toolbar"
                  type="text"
                  maxlength="256"
                  v-model="facilitySearch"
                />
              </form>
              <v-ons-button
                class="toolbar-btn searchBtn"
                style="float: left;"
                @click="searchFacilities"
              >検索</v-ons-button>
              <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
              <label class="grid-align-default">並び替え：</label>
                <kendo-dropdownlist class="search-toolbar"
                  v-model="selectfilterList"
                  :data-source="filterList"
                  :data-text-field="'filterName'"
                  :data-value-field="'filterId'"
                  @select="onSelectOrderKey"
                ></kendo-dropdownlist>
              <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
              <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
              <!-- <v-ons-button
                modifier="outline"
                class="toolbar-btn"
                style="width:10%;"
                @click="openFacilityAdd"
                id="add-facility-btn"
              >追加</v-ons-button> -->
              <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->

              <!--add FNSI-「複数施設証明書を発行する」ボタンを追加 解 start -->
              <label class="grid-align-default"></label>
              <v-ons-button
                modifier="outline"
                class="toolbar-btn"
                style="width:15%;"
                :disabled="manyCerDisabledFlg"
                @click="cersClick"
              >複数施設証明書を発行する</v-ons-button>
              <!--add FNSI-「複数施設証明書を発行する」ボタンを追加 解 end -->
            </div>
            <div class="grid-container">
              <!-- mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start -->
<!--           <kendo-grid
                ref="facilityGrid"
                id="facility-grid"
                :dataSource="this.falicityData"
                :editable="true"
                :pageable="pageable"
                :selectable="true"
                :reorderable="false"
                :height="kendoGridHeight"
                :scrollable="true"
                :resizable="true"
                :sortable="true"
                :change="onChange"
              >-->
              <kendo-grid
                ref="facilityGrid"
                id="facility-grid"
                :dataSource="falicityData"
                :editable="true"
                :pageable="pageable"
                :selectable="true"
                :reorderable="false"
                :height="kendoGridHeight"
                :scrollable="true"
                :resizable="true"
                :sortable="true"
                :change="onChange"
                @hook:mounted="setTableRecordHistory"
              >
                <!-- mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end -->
                <template v-for="(column, index) in facilitiesColumns">
                  <kendo-grid-column
                    v-if="column.field === '$modalType'"
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :sortable="column.sortable"
                    :template="column.template"
                    @editor="editorFacilityDropDown"
                  />
                  <kendo-grid-column
                    v-else-if="column.field === 'isLocked'"
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="false"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :command="column.command"
                    :template="column.template"
                  />
                  <!-- add FNSI-チェックボックスを追加 解 start -->
                  <kendo-grid-column
                    v-else-if="column.field === 'facilitiesChk'"
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="false"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :command="column.command"
                    :template="column.template"
                    :sortable="column.sortable"
                    @editor="editorMainDropDown"
                  />
                  <!-- add FNSI-チェックボックスを追加 解 end -->
                  <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
                  <!-- <kendo-grid-column
                    v-else
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                  ></kendo-grid-column> -->
                  <kendo-grid-column
                    v-else
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :sortable="column.sortable"
                  ></kendo-grid-column>
                  <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
                </template>
              </kendo-grid>
            </div>
            <!-- ログアウトボタン -->
            <div class="grid-footer">
              <v-ons-row width="100%">
                <v-ons-col width="100%">
                  <v-ons-button class="button denial-btn" @click="userSignOut">ログアウト</v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </div>
          </kendo-grid-toolbar>
        </div>
      </div>

      <!-- ユーザーデータ -->
      <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
      <!-- <div
        id="main-content-area-user"
        class="main-content-area master-maintenance-page"
        v-if="showUser"

      > -->
      <div
        id="main-content-area-user"
        class="main-content-area master-maintenance-page"
        v-show="showUser"

      >
        <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        <div class="ntss-list">
          <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
            <div class="header-btn-area">
              <form autocomplete="off">
                <v-ons-input
                  class="search-toolbar"
                  type="text"
                  maxlength="256"
                  v-model="userSearch"
                />
              </form>
              <v-ons-button
                class="toolbar-btn searchBtn"
                style="float: left;"
                @click="searchUsers"
              >検索</v-ons-button>
              <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
                <label class="grid-align-default">並び替え：</label>
                <kendo-dropdownlist class="search-toolbar"
                  v-model="selectfilterUserList"
                  :data-source="filterUserList"
                  :data-text-field="'filterName'"
                  :data-value-field="'filterId'"
                  @select="onSelectUserOrderKey"
                ></kendo-dropdownlist>
              <label class="grid-align-default"></label>
              <!--add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
              <v-ons-button
                modifier="outline"
                class="toolbar-btn user-add-btn"
                @click="openUserAdd"
              >追加</v-ons-button>
            </div>
            <div class="grid-container">
              <kendo-grid
                ref="userGrid"
                id="user-grid"
                :dataSource="userData"
                :editable="true"
                :selectable="true"
                :pageable="pageable"
                :reorderable="false"
                :height="kendoGridHeight"
                :scrollable="true"
                :sortable="true"
                :sort="onSortUser"
                @change="userOnChange"
              >
                <template v-for="(column, index) in userColumns">
                  <kendo-grid-column
                    v-if="column.field === '$modalType'"
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :sortable="column.sortable"
                    :template="column.template"
                    @editor="editorUserDropDown"
                  />
                  <kendo-grid-column
                    v-else-if="column.field === 'isLock'"
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                    :command="column.command"
                  />
                  <kendo-grid-column
                    v-else
                    :key="index"
                    :title="column.title"
                    :field="column.field"
                    :hidden="column.hidden"
                    :locked="column.locked"
                    :editable="column.editable"
                    :width="column.width"
                    :format="column.format"
                    :values="column.values"
                  ></kendo-grid-column>
                </template>
              </kendo-grid>
            </div>
            <!-- ログアウトボタン -->
            <div class="grid-footer">
              <v-ons-row width="100%">
                <v-ons-col width="100%">
                  <v-ons-button class="button denial-btn" @click="userSignOut">ログアウト</v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </div>
          </kendo-grid-toolbar>
        </div>
      </div>

      <!-- 新しい証明書の追加を開くか、証明書のモーダルを編集します  -->
      <v-ons-modal :visible="modalDetailsCondition.isShow" style="overflow-y:scroll">
        <div class="modal-container">
          <div class="modal-center" id="modal-center-cl-add" :style="modalMarginHeight">
            <div class="modal-style">
              <div class="close-x" @click="closeCLCertificateAdd">
                <i class="fas fa-times"></i>
              </div>
              <cl-certificate-add ref="clCertificate" id="cl-add" class="modal-common" />
            </div>
          </div>
        </div>
      </v-ons-modal>
      <!--add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
      <!-- 新しい施設アカウント情報画面を編集します  -->

      <v-ons-modal id="subpopup" :visible="modalDetailsCondition.isCertificateShow" >
        <div class="modal-container">
          <div  class="modal-center" id="modal-center-cl-add" :style="modalMarginHeight">
            <div id="claddmodal" class="modal-style">
              <cl-certificate-show  ref="CLCertificateShow" id="cl-add" class="modal-common" />
            </div>
          </div>
        </div>

      </v-ons-modal>
      <!--add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
      <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start -->
      <!-- 新しい施設を追加するか、施設のモーダルを編集する -->
      <!-- <v-ons-modal :visible="modalFacilityCondition.isShow" style="overflow-y:scroll">
        <div class="modal-container">
          <div class="modal-center" id="modal-center-facility" :style="modalMarginHeight">
            <div class="modal-style">
              <div class="close-x" @click="closeFacilityAdd">
                <i class="fas fa-times"></i>
              </div>
              <facility-add ref="facilityModal" id="facility-add-modal" class="modal-common" />
            </div>
          </div>
        </div>
      </v-ons-modal> -->
      <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
      <!-- 新規ユーザーの追加を開くか、ユーザーのモーダルを編集します  -->
      <v-ons-modal
        :visible="modalUserCondition.isShow"
        class="user-add-modal"
        style="overflow-y:scroll"
      >
        <div class="modal-container">
          <div class="modal-center" id="modal-center-user" :style="modalMarginHeight">
            <div class="modal-style">
              <div class="close-x" @click="closeUserAdd">
                <i class="fas fa-times"></i>
              </div>
              <user-add
                ref="userAddModal"
                :passMin="userSetting.passwordMin"
                id="user-add-modal"
                class="modal-common"
              />
            </div>
          </div>
        </div>
      </v-ons-modal>
    </div>

    <!-- メッセージ削除ユーザー -->
    <message-dialog
      :visible="isDeleteMessage"
      :message-cd="99999999"
      type="2"
      @confirm="confirmDelete"
    />

    <!-- ローディング画面 -->
    <loading-screen />
  </div>
</template>

<script>
// mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
// import { mapActions, mapGetters } from "vuex";
import { mapActions, mapGetters, mapMutations } from "vuex";
// mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
import moment from "moment";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import loadingScreen from "@/components/common/LoadingScreen";
import $ from "jquery";
import CLCertificateAdd from "@/components/cl-details/CLCertificateAdd.vue";
//import FacilityAdd from "@/components/cl-facility/FacilityAdd.vue";
import UserAdd from "@/components/cl-user/UserAdd.vue";
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
import CLCertificateShow from "@/components/cl-show/CLCertificateShow.vue";
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
export default {
  components: {
    "cl-certificate-add": CLCertificateAdd,
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //"facility-add": FacilityAdd,
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    "user-add": UserAdd,
    "message-dialog": messageDialog,
    "loading-screen": loadingScreen,
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    "cl-certificate-show": CLCertificateShow,
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  },
  created() {
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    // this.facilityArray = [];
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    this.setLoadingScreenVisible(true);
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    // this.setOrderKey(this.orderKey);
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    this.setUserOrderKey(this.userOrderKey)
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    let that = this;
    setTimeout(function() {
      that.facilitySearch = that.getFacilitySearch;
    }, 1);
    this.filterFacilityKey = this.getFilterFacilityKey;
    this.showFacility = this.getShowFacility;
    this.showUser = this.getShowUser;
    this.selectfilterList = this.getSelectfilterList;
    this.orderKey = this.getSelectfilterList;
    this.setOrderKey(this.orderKey);
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    if (this.isAdminUser) {
      Promise.all([
        this.getUserSetting(),
        this.setFacilitySetting(),
        this.getFacilities(),
        this.getUsers()
      ])
        .then(() => {
          this.addIsLockColumn();
          this.resetLoadingScreenVisibleCount();
        })
        .catch(() => {
          this.setLoadingScreenVisible(false);
        });
    } else {
      Promise.all([
        this.getUserSetting(),
        this.setFacilitySetting(),
        this.getFacilities()
      ])
        .then(() => {
          this.addIsLockColumn();
          this.resetLoadingScreenVisibleCount();
        })
        .catch(() => {
          this.setLoadingScreenVisible(false);
        });
    }
  },
  mounted() {
    this.calculateTableHeight();
    this.calculateMarginModalHeight();
    this.$nextTick(() => {
      document.getElementById("searchValue").value = "";
      this.clearModalUserState();
      this.closeCLCertificateAdd();
    });

    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 start */
    this.syncManyCerDisabledFlg();
    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 end */
  },
  data() {
    return {
      // add FNSI-「複数施設証明書を発行する」ボタンを追加 解 start
      // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // facilityArray: [],
      // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      result: false,
      manyCerDisabledFlg: true,
      // add FNSI-「複数施設証明書を発行する」ボタンを追加 解 end
      facilityCdUnlock: "", //施設のCDロック解除
      facilityNameUnlock: "", //施設名のロックを解除
      userIdUnlock: "", //ロックされたときにロックを解除するために使用するユーザーID
      isUnlockFacilityMessage: false, // メッセージロック解除機能
      isUnlockUserMessage: false, //メッセージロック解除ユーザー
      isDeleteMessage: false, // メッセージ削除ユーザー
      facilitySearch: "", //  施設の検索名
      userSearch: "", // ユーザーの検索名
      showFacility: true, // 施設表を表示
      showUser: false, // ユーザーテーブルを表示
      filterFacilityKey: "", //データのフィルタリングに使用
      filterUserKey: "", //データのフィルタリングに使用
      //県データ
      prefectureDataSource: [
        { text: "北海道", value: "01" },
        { text: "青森県", value: "02" },
        { text: "岩手県", value: "03" },
        { text: "宮城県", value: "04" },
        { text: "秋田県", value: "05" },
        { text: "山形県", value: "06" },
        { text: "福島県", value: "07" },
        { text: "茨城県", value: "08" },
        { text: "栃木県", value: "09" },
        { text: "群馬県", value: "10" },
        { text: "埼玉県", value: "11" },
        { text: "千葉県", value: "12" },
        { text: "東京都", value: "13" },
        { text: "神奈川県", value: "14" },
        { text: "新潟県", value: "15" },
        { text: "富山県", value: "16" },
        { text: "石川県", value: "17" },
        { text: "福井県", value: "18" },
        { text: "山梨県", value: "19" },
        { text: "長野県", value: "20" },
        { text: "岐阜県", value: "21" },
        { text: "静岡県", value: "22" },
        { text: "愛知県", value: "23" },
        { text: "三重県", value: "24" },
        { text: "滋賀県", value: "25" },
        { text: "京都府", value: "26" },
        { text: "大阪府", value: "27" },
        { text: "兵庫県", value: "28" },
        { text: "奈良県", value: "29" },
        { text: "和歌山県", value: "30" },
        { text: "鳥取県", value: "31" },
        { text: "島根県", value: "32" },
        { text: "岡山県", value: "33" },
        { text: "広島県", value: "34" },
        { text: "山口県", value: "35" },
        { text: "徳島県", value: "36" },
        { text: "香川県", value: "37" },
        { text: "愛媛県", value: "38" },
        { text: "高知県", value: "39" },
        { text: "福岡県", value: "40" },
        { text: "佐賀県", value: "41" },
        { text: "長崎県", value: "42" },
        { text: "熊本県", value: "43" },
        { text: "大分県", value: "44" },
        { text: "宮崎県", value: "45" },
        { text: "鹿児島県", value: "46" },
        { text: "沖縄県", value: "47" }
      ],

      //ユーザーテーブルで使用されるドロップダウンリストのデータ
      dropDownUserDataSource: ["編集", "削除"],

      //施設テーブルで使用されるドロップダウンリストデータ
      //dropDownFacilityDataSource: ["発行", "編集"],
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      dropDownFacilityDataSource: ["アカウント発行", "CL証明書一覧"],
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end

      //add FNSI-ドロップダウンリスト追加 解 start
      dropDownCerMainDataSource: ["", "主", "副"],
      //add FNSI-ドロップダウンリスト追加 解 end

      //2テーブルで使用されるページング可能な属性
      pageable: {
        pageSize: 10,
        numeric: true,
        messages: {
          display:
            "計<font style='font-size:20px; font-weight:bolder'>{2}</font>" +
            "  &nbsp " +
            "{0}-{1} 表示",
          empty: "データなし"
        }
      },

      //施設テーブルの列
      facilitiesColumns: [
        //add FNSI-チェックボックスを追加 解 start
        {
          field: "facilitiesChk",
          title: "選択",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
          // mod #6658 dengshen start
          // sortable: false,
          sortable: true,
          // mod #6658 dengshen start
          width: 120

        },
        //add FNSI-チェックボックスを追加 解 end
        {
          field: "facilityName",
          title: "施設名",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
         //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
          sortable: true
         //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        },
        {
          field: "prefecturesCd",
          title: "都道府県",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
          sortable: true
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        },
        {
          field: "facilityCd",
          title: "施設コード",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
          sortable: true
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        },
        /*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
        // {
        //   field: "issuedNumber",
        //   title: "ダウロード数／発行数",
        //   hidden: false,
        //   locked: false,
        //   editable: () => false,
        //   values: null,
        //   //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
        //   sortable: true
        //   //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        // },
        // {
        //   field: "expiredDate",
        //   title: "公開期限",
        //   hidden: false,
        //   locked: false,
        //   editable: () => false,
        //   format: "{0: yyyy MM/dd hh:mm}",
        //   values: null,
        //   //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
        //   sortable: true
        //   //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        // },
        /*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
        {
          field: "latestIssuedUser",
          title: "発行者",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null,
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
          sortable: true
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        },
        {
          field: "$modalType",
          title: "操作",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
          sortable: false,
          template:
            "<span style='color:rgb(69,173,278)'>操作 <i class='fas fa-caret-down'></i></span>"
        },
        {
          field: "facilityCount",
          title: " ",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null,
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
          sortable: false
          //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
        }
      ],

      //ユーザー表の列
      userColumns: [
        {
          field: "userName",
          title: "氏名",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null
        },
        {
          field: "userId",
          title: "ID",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null
        },
        {
          field: "departmentCd",
          title: "部署",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null
        },
        {
          field: "userRole",
          title: "権限",
          hidden: false,
          locked: false,
          editable: () => false,
          values: null
        },
        {
          field: "isLock",
          title: "ロック解除",
          hidden: false,
          locked: false,
          editable: () => true,
          command: [
            {
              name: "解除",
              className: "btn-kendo",
              click: e => {
                e.preventDefault();
                let userId = $(e.target).closest("tr")[0].cells[1].innerText;
                this.userIdUnlock = userId;
                this.unlockUser();
              },
              visible: function(dataItem) {
                return dataItem.isLock;
              }
             }
          ],
          values: null,
          template: " "
        },
        {
          field: "regDate",
          title: "登録日",
          hidden: false,
          locked: false,
          editable: () => false,
          format: "{0: yyyy MM/dd hh:mm}",
          values: null
        },
        {
          field: "$modalType",
          title: "操作",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
          sortable: false,
          template:
            "<span style='color:rgb(69,173,278)'>操作 <i class='fas fa-caret-down'></i></span>"
        },
        {
          field: "id",
          title: "ID",
          hidden: true,
          locked: false,
          editable: () => false,
          values: null
        }
      ],
     //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
     filterList : [
      {"filterId": "facilityName", "filterName": "施設名"},
      {"filterId": "prefecturesCd", "filterName": "都道府県"},
      {"filterId": "facilityCd", "filterName": "施設コード"},
      /*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
      //{"filterId": "expiredDate", "filterName": "公開期限"},
      /*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
      {"filterId": "latestIssuedUser", "filterName": "発行者"}

    ],
    filterUserList : [
      {"filterId": "userName", "filterName": "氏名"},
      {"filterId": "userId", "filterName": "ID"},
      {"filterId": "departmentCd", "filterName": "部署"},
      {"filterId": "userRole", "filterName": "権限"},
      {"filterId": "regDate", "filterName": "登録日"}
    ],

    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
    selectfilterList :["prefecturesCd"],
    selectfilterUserList :["departmentCd"],
    orderKey: "prefecturesCd",
    userOrderKey: "departmentCd",
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
    kendoGridToolbarHeight: 400,
    kendoGridHeight: 400,
    mainContainerHeight: 0,
    modalMargin: 100
    };
  },
  computed: {
    ...mapGetters("cl-facility", {
      facilities: "getFacilities",
      modalFacilityCondition: "getModalFacilityCondition",
      getSelectedFacility: "getSelectedIndex",
      getFacilitySetting: "getFacilitySetting"
    }),

    ...mapGetters("cl-user", {
      users: "getUsers",
      modalUserCondition: "getModalUserCondition",
      getSelectedUser: "getSelectedIndex",
      userSetting: "getUserSetting",
      getSortOptions: "getSortOptions"
    }),

    ...mapGetters("cl-detail", {
      modalDetailsCondition: "getModalDetailsCondition"
    }),

    ...mapGetters("user", [
      "isAdminUser",
      "isGeneralUser",
      "getUserName",
      "getUserId"
    ]),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),

    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    ...mapGetters("cl-manage-view", {
      getFacilityArray:"getFacilityArray",
      getFacilitySearch:"getFacilitySearch",
      getFilterFacilityKey:"getFilterFacilityKey",
      getShowFacility:"getShowFacility",
      getShowUser:"getShowUser",
      getSelectfilterList:"getSelectfilterList",
      getPage:"getPage",
      getSort:"getSort",
    }),
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },

    containerHeight() {
      return { "--height": `${this.mainContainerHeight}px` };
    },
    modalMarginHeight() {
      return { "margin-top": `${this.modalMargin}px` };
    },
    // 県IDを県名に変換し、それがtrueまたはfalseであるかどうかのロックを決定します
    falicityData() {
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      const page = this.getPage;
      const sort = this.getSort;
      if (sort || page) {
        this.$nextTick(() => {
          sort && $("#facility-grid").data("kendoGrid").dataSource.sort(sort)
          page && $("#facility-grid").data("kendoGrid").pager.dataSource.page(page)
        });
      }
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      let facilityList = this.facilities.map(facility => {
        let prefectureNames = this.prefectureDataSource.filter(
          prefecture => prefecture.value === facility.prefecturesCd
        );
        // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
        facility.facilitiesChk = "";
        this.getFacilityArray.forEach(item => {
          if (facility.facilityName == item.facilityName && facility.facilityCd == item.facilityCd){
            facility.facilitiesChk = item.type;
          }
        });
        // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
        return {
          facilityName: facility.facilityName,
          prefecturesCd:
            prefectureNames.length == 0 ? "" : prefectureNames[0].text,
          facilityCd: facility.facilityCd,
          issuedNumber: facility.issuedNumber,
          expiredDate: facility.expiredDate,
          isLocked: facility.attemptFail >= this.getFacilitySetting.lockCount,
          latestIssuedUser: facility.latestIssuedUser,
          facilityCount: facility.facilityCount,
          // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
          facilitiesChk: facility.facilitiesChk
          // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
        };
      });

      //検索値ですべての列の施設のデータをフィルタリングする
      let filterFacilityKey = this.filterFacilityKey;
      facilityList = facilityList.filter(function(row) {
        return Object.keys(row).some(function(key) {
          if (key !== "isLocked") {
            if (key === "expiredDate") {
              let date =
                row[key] !== ""
                  ? moment(row[key]).format("YYYY MM/DD hh:mm")
                  : "";

              return String(date).includes(filterFacilityKey);
            } else {
              return String(row[key]).includes(filterFacilityKey);
            }
          }
        });
      });

      return facilityList;
    },
    //すべての列でユーザーのデータを検索値でフィルタリングする
    userData() {
      let userList = this.users;
      let filterUserKey = this.filterUserKey;
      let filterColumns = [
        "userId",
        "userName",
        "regDate",
        "departmentCd",
        "userRole"
      ]; //この配列にはフィルター列のみが含まれます
      userList = userList.filter(function(row) {
        return Object.keys(row).some(function(key) {
          if (filterColumns.includes(key)) {
            if (key === "regDate") {
              let date =
                row[key] !== ""
                  ? moment(row[key]).format("YYYY MM/DD hh:mm")
                  : "";
              return String(date).includes(filterUserKey);
            } else {
              return String(row[key]).includes(filterUserKey);
            }
          }
        });
      });
      // del 5027修正 解 start
      if (this.getSortOptions) {
        userList = {
          data: userList,
          sort: {
            dir: this.getSortOptions.dir,
            field: this.getSortOptions.field
          }
        };
      }
      // del 5027修正 解 start
      return userList;
    },
    // add 6774 対応 解 start
    getIsCertificateShow() {
      return this.modalDetailsCondition.isCertificateShow;
    },
    // add 6774 対応 解 end
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    getFacilitySearchChange() {
      return this.facilitySearch;
    }
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
  },
  watch: {
    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 start */
    getFacilityArray() {
      this.syncManyCerDisabledFlg();
    },
    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 end */
    // add 6774 対応 解 start
    getIsCertificateShow(value) {
      if (value == true) {
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
        // this.facilityArray = [];
        this.setFacilityArray([]);
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      }
    },
    // add 6774 対応 解 end
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    getFacilitySearchChange() {
      this.setFacilitySearch(this.facilitySearch);
    },
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    windowHeight() {
      this.calculateTableHeight();
      this.calculateMarginModalHeight();
    },
    windowWidth() {
      this.calculateTableHeight();
      this.calculateMarginModalHeight();
    }
  },
  methods: {
    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 start */
    syncManyCerDisabledFlg() {
      const list = this.getFacilityArray || [];
      this.manyCerDisabledFlg = list.length <= 1;
    },
    /* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 end */
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    setTableRecordHistory () {
      let sort = null
      let page = null
      if (this.$route.params.sort) {
        sort = this.$route.params.sort[0]
      }
      if (this.$route.params.page) {
        page = this.$route.params.page
      }
      if (sort || page) {
        this.$nextTick(() => {
          setTimeout(() => {
            sort && $("#facility-grid").data("kendoGrid").dataSource.sort(sort)
            page && $("#facility-grid").data("kendoGrid").pager.dataSource.page(page)
          }, 500);
        })
      }
    },
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    // add FNSI-「複数施設証明書を発行する」対応 解 start
    cersClick() {
      let selectCount = this.isExistsMainData();
      if (selectCount > 1) {
        const alert = {
          title: "エラー",
          message: "主（発行対象）施設が複数選択不可です。"
        };
        this.$ons.notification.alert(alert);
        return;
      }

      if (selectCount === 0) {
        const alert = {
          title: "エラー",
          message: "主（発行対象）施設が必須です。"
        };
        this.$ons.notification.alert(alert);
        return;
      }

      let data = {
        isShow: false,
        passwordCl: "",
        facilityName: "",
        facilityCd: "",
        isCertificateShow: false
      };
      this.setIsUpdateStateFalse();
      this.setCertificate(data);
      this.setModalDetails(this.getFacilityCds());
      this.openCLCertificateAdd();
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setFacilityArray([]);
      this.setManyCerDisabledFlg();
      const page = $("#facility-grid").data("kendoGrid").pager.dataSource._page
      const sort = $("#facility-grid").data("kendoGrid").dataSource._sort
      if (sort || page) {
        this.$nextTick(() => {
          sort && $("#facility-grid").data("kendoGrid").dataSource.sort(sort)
          page && $("#facility-grid").data("kendoGrid").pager.dataSource.page(page)
        });
      }
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    },
    getFacilityCds() {
      var facilityCd = "";
      var facilityName = "";
      var displayFacilityCd = "";
      var displayFacilityName = "";

      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // for (var i = 0; i < this.facilityArray.length; i++) {
      //   if (this.facilityArray[i]["type"] === "主") {
      //     facilityCd = this.facilityArray[i]['facilityCd'];
      //     facilityName = this.facilityArray[i]['facilityName'];
      for (var i = 0; i < this.getFacilityArray.length; i++) {
        if (this.getFacilityArray[i]["type"] === "主") {
          facilityCd = this.getFacilityArray[i]['facilityCd'];
          facilityName = this.getFacilityArray[i]['facilityName'];
          // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
        }

        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
        // displayFacilityCd += this.facilityArray[i]['facilityCd'] + " "
        // displayFacilityName += this.facilityArray[i]['facilityName'] + " "
        displayFacilityCd += this.getFacilityArray[i]['facilityCd'] + " "
        displayFacilityName += this.getFacilityArray[i]['facilityName'] + " "
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      }

      return {
               facilityCd: facilityCd,
               facilityName: facilityName,
               displayFacilityCd: displayFacilityCd.substring(0, displayFacilityCd.length - 1),
               displayFacilityName: displayFacilityName.substring(0, displayFacilityName.length - 1),
               latestIssuedUser: this.getUserName
             }
    },
    removeFacilityFromArray(facilityCd) {
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // if (this.facilityArray.length === 1 && this.facilityArray[0]['facilityCd'] === facilityCd) {
      //   this.facilityArray = [];
      if (this.getFacilityArray.length === 1 && this.getFacilityArray[0]['facilityCd'] === facilityCd) {
        this.setFacilityArray([]);
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      } else {
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
        // for (var i = 0; i < this.facilityArray.length; i++) {
        //   if (this.facilityArray[i]['facilityCd'] === facilityCd) {
        //     this.facilityArray.splice(i,1);
        for (var i = 0; i < this.getFacilityArray.length; i++) {
          if (this.getFacilityArray[i]['facilityCd'] === facilityCd) {
            this.removeFacilityFromArrayItem(i);
            // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
            //delete this.facilityArray[i]
            break;
          }
        }
      }
    },
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    // addFacilityToArray(val, facilityCd, facilityName) {
    //   var arrIndex = 0;
    //   var isExists = false;
    //   for (var i = 0; i < this.facilityArray.length; i++) {
    //     if (this.facilityArray[i]['facilityCd'] === facilityCd) {
    //       isExists = true;
    //       arrIndex = i;
    //       break;
    //     }
    //   }
    //
    //   if (isExists) {
    //     this.facilityArray[arrIndex]['facilityCd'] = facilityCd;
    //     this.facilityArray[arrIndex]['facilityName'] = facilityName;
    //     this.facilityArray[arrIndex]['type'] = val;
    //   } else {
    //     let facilityJson = {
    //        "type": val,
    //        "facilityCd": facilityCd,
    //        "facilityName": facilityName
    //     };
    //     this.facilityArray.push(facilityJson);
    //   }
    //
    //  this.setFacilityArray(this.facilityArray);
    // },
    // del #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    setManyCerDisabledFlg() {
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // if (this.facilityArray.length > 1) {
      if (this.getFacilityArray.length > 1) {
        // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
        this.manyCerDisabledFlg = false;
      } else {
        this.manyCerDisabledFlg = true;
      }
    },

    isExistsMainData() {
      var mainCount = 0;
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // for (var i = 0; i < this.facilityArray.length; i++) {
      //   if (this.facilityArray[i]['type'] === '主') {
      for (var i = 0; i < this.getFacilityArray.length; i++) {
        if (this.getFacilityArray[i]['type'] === '主') {
          // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
          mainCount++;
        }
      }
      return mainCount;
    },

    // add FNSI-「複数施設証明書を発行する」対応 解 end
    calculateTableHeight() {
      let tabstripHeight = document.getElementsByClassName(
        "k-tabstrip-wrapper"
      )[0].scrollHeight;
      let headerBtnArea = document.getElementsByClassName("header-btn-area")[0]
        .scrollHeight;
      let gridFooter = document.getElementsByClassName("grid-footer")[0]
        .scrollHeight;
      let kPaperWrap = document.getElementsByClassName("k-pager-wrap")[0]
        .scrollHeight;

      let subElementHeight =
        tabstripHeight + headerBtnArea + gridFooter + kPaperWrap;
      let tableHeight = this.windowHeight - subElementHeight;
      this.kendoGridToolbarHeight = tableHeight + kPaperWrap;
      this.kendoGridHeight = tableHeight;
    },
    calculateMarginModalHeight() {
      let tabstripHeight = document.getElementsByClassName("modal-common");
      Array.from(tabstripHeight)?.forEach(item => {
        if (item.scrollHeight != 0) {
          let margin = (this.windowHeight - item.scrollHeight) / 2;
          if (this.windowHeight <= item.scrollHeight) {
            this.modalMargin = 0;
          } else if (item.scrollHeight != 0) {
            this.modalMargin = margin;
          }
        }
      });
    },
    ...mapActions("cl-facility", {
      getFacilities: "getFacilities",
      setModalFacilityVisible: "setModalFacilityVisible",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      //clearModalFacilityState: "clearModalFacilityState",
      //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      setSelectedFacility: "setSelectedIndex",
      setModalFacilityFunction: "setModalFacilityFunction",
      setModalFacilityState: "setModalFacilityState",
      getFacilityFiltered: "getFacilityFiltered",
      getFacilityByCd: "getFacilityByCd",
      //mod 6363の対応 xiebzh start
      //setIsUpdateStateFalse: "setIsUpdateStateFalse",
      //mod 6363の対応 xiebzh start
      clearModalState: "clearModalState",
      setFacilitySetting: "setFacilitySetting",
      updateFacilityAttemptFail: "updateFacilityAttemptFail",
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      setOrderKey: "setOrderKey",
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    }),
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
    ...mapActions("cl-manage-view", {
      setFacilityArray:"setFacilityArray",
      setFacilitySearch:"setFacilitySearch",
      setFilterFacilityKey:"setFilterFacilityKey",
      setShowFacility:"setShowFacility",
      setShowUser:"setShowUser",
      setSelectfilterList:"setSelectfilterList",
      setPage:"setPage",
      setSort:"setSort",
    }),
    ...mapMutations("cl-manage-view", {
      addFacilityToArray: "addFacilityToArray",
      removeFacilityFromArrayItem: "removeFacilityFromArrayItem",
    }),
    // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    ...mapActions("cl-user", {
      getUsers: "getUsers",
      setSelectedUser: "setSelectedIndex",
      setModalUserVisible: "setModalUserVisible",
      clearModalUserState: "clearModalUserState",
      setModalUserState: "setModalUserState",
      setModalUserFunction: "setModalUserFunction",
      deleteUser: "deleteUser",
      getUserFiltered: "getUserFiltered",
      getUserSetting: "getUserSetting",
      updateLoginAttempt: "updateLoginAttempt",
      setSortOptions: "setSortOptions",
     //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
      setUserOrderKey: "setOrderKey",
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    }),

    ...mapActions("user", ["signOut"]),

    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("app", ["clearApiResult"]),

    //ログアウト
    userSignOut() {
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setFacilityArray([]);
      this.setFacilitySearch("");//施設の検索名
      this.setFilterFacilityKey("");//データのフィルタリングに使用
      this.setShowFacility(true); // 施設表を表示
      this.setShowUser(false); // ユーザーテーブルを表示
      this.setSelectfilterList("prefecturesCd");
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      this.signOut();
      this.$router.push({ name: "clManagementLogin" });
    },

    //ユーザーの削除を確認します
    confirmDelete(answer) {
      this.isDeleteMessage = false;
      if (answer === "OK") {
        this.setLoadingScreenVisible(true);
        this.deleteUser(this.getSelectedUser.userId)
          .then(() => {
            this.resetLoadingScreenVisibleCount();
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      }
    },

    ...mapActions("cl-detail", {
      setModalDetails: "setModalDetailsCondition",
      setModalDetailVisible: "setModalDetailVisible",
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
      setModalCertificatesVisible:"setModalCertificatesVisible",
      //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
      selectCertificateByFacilityCd: "selectCertificateByFacilityCd",
      //add FNSI-チェックボックスを追加 解 start
      setCertificate: "setCertificate",
      //add FNSI-チェックボックスを追加 解 end
      clearModalDetail: "clearModalDetail",
      //mod 6363の対応 xiebzh start
      setIsUpdateStateFalse: "setIsUpdateStateFalse"
      //mod 6363の対応 xiebzh end
    }),

    //名前でユーザーを検索
    searchUsers() {
      this.filterUserKey = this.userSearch;
    },

    //名前で施設を検索
    searchFacilities() {
      this.filterFacilityKey = this.facilitySearch;
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setFacilitySearch(this.facilitySearch);
      this.setFilterFacilityKey(this.filterFacilityKey);
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      // add 6774 dengshen start
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // this.facilityArray = [];
      this.setFacilityArray([]);
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      this.setManyCerDisabledFlg();
      // add 6774 dengshen end
    },

    //行をクリックすると施設を選択
    onChange(event) {
      this.setSelectedFacility({
        //del FNSI-複数施設証明書を発行する 解 start
        //facilityCd: event.sender.select()[0].children[2].innerText,
        //facilityName: event.sender.select()[0].children[0].innerText
        //del FNSI-複数施設証明書を発行する 解 end

        //add FNSI-複数施設証明書を発行する 解 start
        facilityCd: event.sender.select()[0].children[4].innerText,
        facilityName: event.sender.select()[0].children[1].innerText
        //add FNSI-複数施設証明書を発行する 解 end
      });
      this.setModalDetails({
        facilityCd: this.getSelectedFacility.facilityCd,
        facilityName: this.getSelectedFacility.facilityName,
        displayFacilityCd: this.getSelectedFacility.facilityCd,
        displayFacilityName: this.getSelectedFacility.facilityName,
        latestIssuedUser: this.getUserName
      });
    },

    //行をクリックしたときにユーザーを選択
    userOnChange(event) {
      this.setSelectedUser({
        id: event.sender.select()[0].cells[7].innerText,
        userId: event.sender.select()[0].cells[1].innerText,
        userName: event.sender.select()[0].children[0].innerText,
        departmentCd: event.sender.select()[0].children[2].innerText,
        userRole: event.sender.select()[0].children[3].innerText,
        userPass: ""
      });
    },

    //ユーザーモードの追加と編集を開く
    openUserAdd() {
      this.setModalUserFunction(false);
      this.setModalUserVisible(true);
      this.$refs.userAddModal.clearError();
    },

    //閉じるユーザーモーダルの追加と編集
    closeUserAdd() {
      this.clearModalUserState();
      this.$refs.userAddModal.onBlur();
      this.$refs.userAddModal.clearError();
    },

  //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    openCLCertificateDownload() {
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      // this.$router.push({ name: "CLCertificateDetails" });
      const page = $("#facility-grid").data("kendoGrid").pager.dataSource._page
      const sort = $("#facility-grid").data("kendoGrid").dataSource._sort
      this.$router.push({ name: "CLCertificateDetails", params: {page, sort} });
      // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    },
  //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
   //del FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    // //追加および編集機能モーダルを開く
    // openFacilityAdd() {
    //   this.setModalFacilityFunction(false);
    //   this.setModalFacilityVisible(true);
    //   this.$refs.facilityModal.clearError();
    // },

    // //施設の追加と編集モードを閉じる
    // closeFacilityAdd() {
    //   this.clearModalFacilityState(false);
    //   this.clearModalState();
    //   this.$refs.facilityModal.onBlur();
    //   this.$refs.facilityModal.clearError();
    // },
    //del FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
    //証明書の追加と編集モードを開きます
    openCLCertificateAdd() {
      this.setModalDetailVisible(true);
      this.$refs.clCertificate.clearError();
    },

    //証明書モーダルの追加と編集を閉じる
    closeCLCertificateAdd() {
      this.setModalDetailVisible(false);
      this.clearModalDetail();
      this.$refs.clCertificate.clearError();
    },
    //施設テーブルの表示
    displayFacility() {
      this.showFacility = true;
      this.showUser = false;
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setShowFacility(this.showFacility);
      this.setShowUser(this.showUser);
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end

    },

    //ユーザー表を表示する
    displayUser() {
      this.showFacility = false;
      this.showUser = true;
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setShowFacility(this.showFacility);
      this.setShowUser(this.showUser);
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    },

    // add FNSI-列をクリックしたときにドロップダウンリスト 解 start
    editorMainDropDown(container, data) {
      $(`<input class="k-textbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: this.dropDownCerMainDataSource,
          //optionLabel: "選択",
          change: () => {
              let val = data.model[data.field];
              if (val === '' || val === null || val === ' ') {
                this.removeFacilityFromArray(data.model['facilityCd']);
              } else {
                // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
                // this.addFacilityToArray(val, data.model['facilityCd'], data.model['facilityName']);
                const page = $("#facility-grid").data("kendoGrid").pager.dataSource._page
                const sort = $("#facility-grid").data("kendoGrid").dataSource._sort
                this.setPage(page);
                this.setSort(sort);
                this.addFacilityToArray(data);
                setTimeout(() => {
                  sort && $("#facility-grid").data("kendoGrid").dataSource.sort(sort)
                  page && $("#facility-grid").data("kendoGrid").pager.dataSource.page(page)
                }, 500);
                // mod #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
              }
              this.setManyCerDisabledFlg();

              setTimeout(() => {
                this.calculateMarginModalHeight();
              }, 1);
            },
            open: () => {
              $(".k-list-optionlabel").hide();
            }
          });
    },

    // add FNSI-列をクリックしたときにドロップダウンリスト 解 end

    //列をクリックしたときにドロップダウンリストを表示
    editorFacilityDropDown(container, data) {
      //this.getIsUpdateCertificateByFacilityCd(this.getSelectedFacility.facilityCd);
      if (data.model['facilityCount'] > 0) {
        this.dropDownFacilityDataSource = ["施設PW変更", "CL証明書一覧"];
      } else {
        this.dropDownFacilityDataSource = ["アカウント発行", "CL証明書一覧"];
      }

      $(`<input class="k-textbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: this.dropDownFacilityDataSource,
          optionLabel: "操作",
          change: () => {
            // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
            const page = $("#facility-grid").data("kendoGrid").pager.dataSource._page
            const sort = $("#facility-grid").data("kendoGrid").dataSource._sort
            this.setPage(page);
            this.setSort(sort);
            // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
            this.selectCertificateByFacilityCd(
              this.getSelectedFacility.facilityCd
            );
            let val = data.model[data.field];
            //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
            //if (val === "発行") {
            if (val === "アカウント発行" || val === "施設PW変更") {
            //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
              this.openCLCertificateAdd();
            //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
            //} else if (val === "編集") {
            } else if (val === "CL証明書一覧") {
              this.openCLCertificateDownload()
              // this.setLoadingScreenVisible(true);
              // this.setModalFacilityState()
              //   .then(() => {
              //     this.resetLoadingScreenVisibleCount();
              //   })
              //   .catch(() => {
              //     this.setLoadingScreenVisible(false);
              //   });
              // this.setLoadingScreenVisible(true);
              // this.getFacilityByCd()
              //   .then(() => {
              //     this.resetLoadingScreenVisibleCount();
              //   })
              //   .catch(() => {
              //     this.setLoadingScreenVisible(false);
              //   });
              // this.openFacilityAdd();
              //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
            }
            data.model[data.field] = "操作";
            setTimeout(() => {
              this.calculateMarginModalHeight();
            }, 1);
          },
          open: () => {
            $(".k-list-optionlabel").hide();
          }
        });
    },
    //列をクリックしたときにドロップダウンリストを表示
    editorUserDropDown(container, data) {
      $(`<input class="k-textbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: this.dropDownUserDataSource,
          optionLabel: "操作",
          change: () => {
            let val = data.model[data.field];
            if (val === "編集") {
              this.setLoadingScreenVisible(true);
              this.setModalUserState()
                .then(() => {
                  this.resetLoadingScreenVisibleCount();
                })
                .catch(() => {
                  this.setLoadingScreenVisible(false);
                });
              this.setModalUserVisible(true);
              this.setModalUserFunction(true);
              this.$refs.userAddModal.clearError();
            } else if (val === "削除") {
              if (this.getSelectedUser.userId === this.getUserId) {
                const alert = {
                  title: "警告",
                  message: "自分を削除することはできません"
                };
                this.$ons.notification.alert(alert);
              } else {
                this.isDeleteMessage = true;
              }
            }
            data.model[data.field] = "操作";
            setTimeout(() => {
              this.calculateMarginModalHeight();
            }, 1);
          },
          open: () => {
            $(".k-list-optionlabel").hide();
          }
        });
    },

    //施設のロックを解除することを確認します
    unlockFacility() {
      let obj = {
        facilityCd: this.facilityCdUnlock,
        attemptFail: 0,
        facilityName: this.facilityNameUnlock
      };
      this.setLoadingScreenVisible(true);
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      const page = $("#facility-grid").data("kendoGrid").pager.dataSource._page
      const sort = $("#facility-grid").data("kendoGrid").dataSource._sort
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
      this.updateFacilityAttemptFail(obj)
        .then(() => {
          // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
          if (sort || page) {
            this.$nextTick(() => {
              setTimeout(() => {
                sort && $("#facility-grid").data("kendoGrid").dataSource.sort(sort)
                page && $("#facility-grid").data("kendoGrid").pager.dataSource.page(page)
              }, 500);
            })
          }
          // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
          this.resetLoadingScreenVisibleCount();
        })
        .catch(() => {
          this.setLoadingScreenVisible(false);
          this.alert();
        });
    },

    //ユーザーのロック解除を確認します
    unlockUser() {
      let obj = {
        userId: this.userIdUnlock,
        numLoginAttempt: 0
      };
      this.setLoadingScreenVisible(true);
      this.updateLoginAttempt(obj)
        .then(() => {
          this.resetLoadingScreenVisibleCount();
        })
        .catch(() => {
          this.setLoadingScreenVisible(false);
          this.alert();
        });
    },

    //ユーザーの役割に基づいて「ロック解除」列を追加します
    addIsLockColumn() {
      if (this.isAdminUser) {
        let column = {
          field: "isLocked",
          title: "ロック解除",
          hidden: false,
          locked: false,
          command: [
            {
              name: "解除",
              click: e => {
                e.preventDefault();
                let facilityCd = $(e.target).closest("tr")[0].cells[4]
                  .innerText;
                let facilityName = $(e.target).closest("tr")[0].cells[1]
                  .innerText;
                this.facilityCdUnlock = facilityCd;
                this.facilityNameUnlock = facilityName;
                this.unlockFacility();
              },
              visible: function(dataItem) {
                return dataItem.isLocked;
              }
            }
          ],
          editable: () => true,
          values: null
        };
        /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
        //this.facilitiesColumns.splice(5, 0, column);
        this.facilitiesColumns.splice(3, 0, column);
        /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
      } else {
        let column = {
          field: "isLocked",
          title: "ロック解除",
          hidden: false,
          locked: false,
          command: [
            {
              className: "k-state-disabled",
              name: "解除",
              click: () => {},
              visible: function(dataItem) {
                return dataItem.isLocked;
              }
            }
          ],
          editable: () => true,
          values: null
        };
        /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
        //this.facilitiesColumns.splice(5, 0, column);
        this.facilitiesColumns.splice(3, 0, column);
        /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
      }
    },

    alert() {
      if (this.hasApiError) {
        // エラー保持状況フラグを更新
        this.$nextTick(() => {
          const alert = {
            title: "エラー",
            message: this.getApiResult.message,
            callback: () => {
              this.clearApiResult();
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    },
    onSortUser(event) {
      this.setSortOptions(event.sort);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start -->
    onSelectOrderKey(e) {
      this.setOrderKey(e.dataItem.filterId);
      this.getFacilities();
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen start
      this.setSelectfilterList(e.dataItem.filterId);
      // add #6690 「操作するたびに対象施設が表示していない1ページ目にもどる」について、対応する。 dengshen end
    },
    onSelectUserOrderKey(e) {
      this.setUserOrderKey(e.dataItem.filterId);
      this.getUsers();
    },
    //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end -->
  }

};

</script>

<style scoped>
#app > div {
  background-color: rgb(232, 247, 251);
  width: 100%;
  height: 100%;
}
.container {
  width: 100%;
  height: 100vh;
  max-height: 100vh;
  overflow-y: scroll;
  overflow-x: hidden;
}
.user-name {
  font-size: 1.5em;
  font-weight: bold;
  width: 100%;
  text-align: right;
  height: 1.5em;
  line-height: 2.5em;
  position: absolute;
}

.user-name-text {
  width: auto;
  float: right;
  margin-right: 5vw;
}
.label-user-name {
  width: auto;
  float: right;
  padding-right: 5px;
}
.user-name p {
  margin-right: 100px;
}
#add-facility-btn {
  visibility: hidden;
}
#facility-grid td {
  overflow: visible;
}
.user-add-modal {
  height: 100%;
}
.user-add {
  position: relative;
  height: 70%;
  background-color: aliceblue;
  color: black;
  width: 50%;
  margin: 0 auto;
  border: 1px black solid;
  border-radius: 10px;
}
.user-add-btn {
  margin-left: 3vw;
}
.close-x {
  font-size: 24px;
  color: red;
  position: absolute;
  right: 5px;
}
.close-x:hover {
  cursor: pointer;
}
.modal-container {
  height: 100%;
  padding: 0;
  overflow-y: scroll;
}
.modal-style {
  position: relative;
  height: 50vh;
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*min-height: 50vh;
  max-height: 50vh;*/
  min-height:520px;
  min-width: 460px;
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  color: black;
  width: 50%;
  margin: 0 auto;
}
.modal__content {
  overflow-y: scroll;
}
.searchBtn {
  background-color: grey;
}
.dropdown {
  margin-left: 20px;
  text-align: center;
  width: 30%;
  float: left;
}
.search-toolbar {
  font-size: 1em;
  width: 20%;
  margin-right: 10px;
  float: left;
}
.main-content-area {
  position: relative;
  z-index: 0;
  width: 99%;
  margin-left: 1%;
  overflow-y: unset;
  height: auto;
}
.k-tabstrip {
  margin-top: 30px;
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  /*width: 98%;*/
  width: 99%;
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  margin-left: 1%;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.grid-footer {
  padding: 5px 5px 0px 5px;
  margin-top: 1.5em;
  width: inherit;
  font-size: 0.7em;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.csv-btn {
  margin-right: 1em;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style >>> .k-tooltip.k-tooltip-validation {
  width: auto;
}
.btn-kendo {
  background: black;
}
.denial-btn {
  margin-right: 4vw;
  width: 150px;
  height: 35px;
  font-size: 1.5em;
  line-height: 35px;
  float: right;
  border-radius: 5px;
}
.k-grid-toolbar >>> * + * {
  margin-left: 0;
}
.searchBtn {
  margin-right: 1em;
}
/*add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start*/
.grid-align-default {
  padding: 0.2em 0.2em 0.2em 0.2em;
}
/*add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end*/
@media only screen and (max-width: 900px) {
  .modal-style {
    position: relative;
    height: 100vh;
    min-height: 100vh;
    max-height: 100vh;
    color: black;
    margin: 0 auto;
  }
  .cl-add-page {
    padding: 0;
  }
  .main-content-area {
    position: relative;
    z-index: 0;
    width: 100%;
    margin-left: 1%;
    overflow-y: unset;
  }
  .container {
    width: 100%;
    height: 80vh;
    min-height: 100vh;
    overflow-y: scroll;
    overflow-x: hidden;
  }
  .search-toolbar {
    width: 40%;
  }
  .grid-container {
    overflow: auto;
  }
  #facility-grid {
    width: 1600px;
  }
  #user-grid {
    width: 1600px;
  }
  .k-tabstrip {
    width: 100%;
  }
  #facility-grid >>> .k-auto-scrollable {
    width: auto;
  }
}
@media only screen and (max-width: 480px) {
  .modal-style {
    width: 100%;
  }
}
@media print {
  #subpopup {
    background-color: white !important;
    hight:100% !important;
    width:100% !important;
  }

  /*add 6360 start*/

  #cl-add{
    width: 800px !important;
    heigth: 300px !important;
  }

  .modal-center {
    width: 100% !important;
    heigth: 100% !important;
  }

  .facility-add-page {
    width: 500px !important;
  }
  .header-btn-area {
    display: none !important;
  }

  .grid-footer {
    display: none !important;
  }

  .k-pager-wrap {
    display: none !important;
  }

  .k-grid-pager {
    display: none !important;
  }

  .ntss-list {
    display: none !important;
  }

  * { margin: 0 !important; padding: 0 !important; }
  html, body {
    width: 100%;
    height: 100%;
    overflow: hidden;
  }
  /*add 6360 end*/
}

/* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 start */
.button--outline[disabled] {
  color: #999 !important;
  border-color: #ccc !important;
  background-color: transparent;
}
/* add #9245 CL証明書管理サイトの「複数施設証明書の発行する」ボタンが非活性になる 20260403 end */
</style>
