<template>
  <modal-base @onClose="closeCheckListModal" class="custom-modal">
    <template #header>
      <component :is="header"></component>
    </template>

    <template #body>
      <div style="font-size: 1.5em">
      <div id="checklist-modal-header">
        <!-- タイトル -->
        <v-ons-row>
          <v-ons-col class="custom-ons-col header-col">
            <table class="ntss-list" style="position: unset !important">
              <thead>
                <tr>
                  <th
                    colspan="4"
                    class="text-header-center ntss-list-title"
                    style="text-align: center"
                  >
                    <v-ons-icon
                      v-if="layoutSize >1"
                      class="icon-left"
                      @click="switchLayoutBack"
                      icon="fa-arrow-circle-left"
                      style="float: left !important"
                    ></v-ons-icon>
                    <span>{{ layoutGroupName }}</span>
                    <v-ons-icon
                      v-if="layoutSize >1"
                      class="icon-right"
                      @click="switchLayoutNext"
                      icon="fa-arrow-circle-right"
                      style="float: right !important"
                    ></v-ons-icon>
                  </th>
                </tr>
                <tr>
                  <th
                    colspan="3"
                    class="text-header-center ntss-list-title"
                    style="text-align: left"
                  >
                    <span>{{ layoutName }}</span>
                  </th>
                </tr>
              </thead>
            </table>
          </v-ons-col>
        </v-ons-row>
        <!-- 各項目 -->
        <div style="margin-top: -3px; margin-bottom: -3px; margin-left: 25px;">
          <!-- 一行目：記録番号、点検実施日 -->
          <v-ons-row>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">記録番号</p>
                </v-ons-col>
                <v-ons-col width="40%">
<!--                  mod #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start-->
<!--                  <v-ons-input-->
<!--                    class="custom-input"-->
<!--                    type="number"-->
<!--                    @blur="formatValue($event);"-->
<!--                    @focus="handleFocus"-->
<!--                    @change="preventNegativeNum($event);"-->
<!--                    v-model="editData.inspectInfor.recNo"-->
<!--                    @mousewheel.prevent="stopScrollFun($event)"-->
<!--                    :disabled="!hasDevEditAuthority"-->
<!--                  ></v-ons-input>-->
                  <v-ons-input
                      class="custom-input"
                      @change="updateInspected();"
                      v-model="editData.inspectInfor.recNo"
                      :disabled="!hasDevEditAuthority"
                  ></v-ons-input>
<!--                  mod #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end-->
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">点検実施日</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <v-ons-input
                    type="date"
                    :disabled="true"
                    class="custom-input"
                    v-model="editData.inspectInfor.menteDate"
                    @change="updateInspected"
                  ></v-ons-input>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- 二行目：点検者、確認者 -->
          <v-ons-row>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">点検者</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <div class="custom-like-input">
                    {{ getUserName(editData.inspectInfor.checkerId1) }}
                  </div>
                </v-ons-col>
                <v-ons-col width="30%">
                  <v-ons-button
                    ref="btnInspector"
                    class="common-style-select-button"
                    @click="selectInspector"
                    :disabled="!hasDevEditAuthority"
                  >
                    選択
                  </v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">確認者</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <div class="custom-like-input">
                    {{ getUserName(editData.inspectInfor.checkerId2) }}
                  </div>
                </v-ons-col>
                <v-ons-col width="30%">
                  <v-ons-button
                    ref="btnChecker"
                    class="common-style-select-button"
                    @click="selectChecker"
                    :disabled="!hasDevEditAuthority"
                  >
                    選択
                  </v-ons-button>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- 三行目：型式、製造番号 -->
          <v-ons-row>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">型式</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <p class="display_box" style="line-height: 5px;">
                    {{ editData.machineInfor.machineType }}
                  </p>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">製造番号</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <p class="display_box" style="line-height: 5px;">
                    {{ editData.machineInfor.machineSerial }}
                  </p>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- 四行目：バージョン、装置名 -->
          <v-ons-row>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">バージョン</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <p class="display_box" style="line-height: 5px;">
                    {{ editData.machineInfor.version }}
                  </p>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="line-height: 5px;width:100%">装置名</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <p class="display_box" style="line-height: 5px;">
                    {{ editData.machineInfor.machineName }}
                    <img v-if="this.getTheme === 0" src="img/periodic-inspection/stop-watch.png" id="stop-watch-icon" @click="ShowSomeThing(editData.machineInfor.machineTypeCd, editData.machineInfor.machineSerial)"/>
                    <img v-else-if="this.getTheme === 1" src="img/periodic-inspection/stop-watch-dark.png"
                      id="stop-watch-icon" @click="ShowSomeThing(editData.machineInfor.machineTypeCd, editData.machineInfor.machineSerial)"/>
                  </p>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <!-- 五行目：総合判定、点検者コメント -->
          <!-- mod #11065 【03】編集権限バグ修正 関 start -->
          <v-ons-row>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="width:100%" class="p-flex">総合判定</p>
                </v-ons-col>
                <v-ons-col width="20%" style="height: 100%;">
                  <v-ons-select style="width: 100%" class="ntss-separate-dosing select-center"
                    @change="updateAns()"
                    v-model="editData.inspectInfor.menteAns1"
                    :disabled="!hasDevEditAuthority">
                    <option style="padding-left: 40%!important;" v-for="item in ansList" :key="item.id"
                      :value="item.id">
                      {{ item.name }}
                    </option>
                  </v-ons-select>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-ons-item header-col">
              <v-ons-row class="display_box" style="line-height: 5px;">
                <v-ons-col width="30%" style="min-width:7rem;">
                  <p style="line-height: 5px;width:100%;white-space: nowrap;">点検者コメント</p>
                </v-ons-col>
                <v-ons-col width="*">
                  <textarea
                    style="width: 100%; max-width: 100%; min-width: 100%; min-height: 2rem; font-size: inherit; font-family: inherit;"
                    v-model="editData.inspectInfor.menteComment1"
                    @blur="updateInspected"
                    :disabled="!hasDevEditAuthority"></textarea>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>

          <pop-over
            v-bind="popoverData"
            :target-position-element="popoverTargetElement"
            @popover-close="closePopover"
            @popover-return="selectedValue"
          />
        </div>
      </div>
      <!-- 定期点検記録簿 -->
      <div v-show="editData.table1 && editData.table1.length > 0" modal-body style="margin-right: 5px; margin-bottom: 15px; margin-left: 5px;">
        <v-ons-row class="display_box">
          <v-ons-col style="border: 1px solid #999;" width="100%">
            <v-ons-col style="margin: 0 auto;" width="100%">
              <v-ons-row>
                <v-ons-col class="custom-record-col">
                  <p style="text-align: center; line-height: 5px">
                    定期点検記録簿
                  </p>
                </v-ons-col>
              </v-ons-row>
              <v-ons-row class="custom-ons-box">
                <v-ons-col>
                  <div style="overflow-x: auto; width: 100%;">
                    <table border="1" class="custom-table-check-modal ons-col-border" style="min-width: 43em;">
                      <thead>
                        <tr>
                          <th class="text-header-center ntss-list-title col-item">項目</th>
                          <th class="text-header-center ntss-list-title col-standard">基準</th>
                          <th class="text-header-center ntss-list-title col-operation-inspect">作業
                            <v-ons-select style="width: 50%;" class="ntss-separate-dosing select-center"
                              @change="changeAns($event, 1)" v-model="editData.inspectInfor.menteAnsHeader1"
                              :disabled="!hasDevEditAuthority">
                              <option v-for="item in djjlList" :key="item.id" :value="item.id">
                                {{ item.name }}
                              </option>
                            </v-ons-select>

                          </th>
                          <th class="text-header-center ntss-list-title col-comment">コメント</th>
                          <th class="text-header-center ntss-list-title col-inspector">点検者</th>
                        </tr>
                      </thead>
                      <tbody v-for="(item, ind) in editData.table1" :key="ind" class="abc">
                        <tr>
                          <td colspan="5" class="text-header-center ntss-list-title header_three">{{ item.catelogyName }}</td>
                        </tr>
                        <tr v-for="(i, index) in item.detailItems" :key="index"
                          :style="{ backgroundColor: index % 2 == 0 ? 'var(--ntss-list-item-background-color)' : 'var(--ntss-list-content-2nd-background-color)' }">
                          <td>{{ i.menteContent1 }}</td>
                          <td>{{ i.menteContent2 }}</td>
                          <td class="not-padding" style="text-align: center">
                            <v-ons-select style="width: 100%;" v-if="i.ansPattern == 1"
                              class="ntss-separate-dosing select-center" v-model="i.judge"
                              @change="updateStatusItem(i, 1, $event)" :disabled="!hasDevEditAuthority">
                              <option v-for="item in djjlList" :key="item.id" :value="item.id">
                                {{ item.name }}
                              </option>
                            </v-ons-select>
                            <v-ons-select style="width: 100%" v-if="i.ansPattern == 2"
                              class="ntss-separate-dosing select-center" v-model="i.judge"
                              @change="updateStatusItem(i, 1, i.ansPattern)" :disabled="!hasDevEditAuthority">
                              <option v-for="item in djjlList1" :key="item.id" :value="item.id">
                                {{ item.name }}
                              </option>
                            </v-ons-select>
                          </td>
                          <td>
                            <com-textarea v-if="i.isCmt == 1" :idTextarea="'com-textarea-table1-comment-' + ind + '-' + index"
                              :content="i.comment" class="comTextarea"
                              cssClass="textarea-custom-text-font textarea-resize-vertical" style="width: 100%;"
                              @blur="updateInspected(0, 1, ind, i.detail_cd)"
                              @set-content-data="setContentDataComment($event, 1, ind, index, i.detail_cd)"
                              :disabled="!hasDevEditAuthority"
                            />
                          </td>
                          <td :style="{backgroundColor:index%2 == 0?'var(--ntss-list-item-background-color)':'var(--ntss-list-content-2nd-background-color)'}" class="td-color">
                            {{ i.judge != "" ? i.checkerFullName : "" }}
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </v-ons-col>
              </v-ons-row>

              <v-ons-row>
                <v-ons-col class="custom-record-col" style="margin-top: 5px;">
                  <v-ons-row>
                    <v-ons-col width="100%">
                      レ：点検、〇：分解、×：交換、A：調整、T：締付、C：清掃
                    </v-ons-col>
                  </v-ons-row>
                </v-ons-col>
              </v-ons-row>

            </v-ons-col>
          </v-ons-col>
        </v-ons-row>
      </div>
      <!-- 定期交換部品記録簿 -->
      <div v-show="editData.table2 && editData.table2.length > 0" modal-body style="margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
        <v-ons-row class="display_box">
          <v-ons-col style="border: 1px solid #999;" width="100%">
            <v-ons-col style="margin: 0 auto;" width="100%">
              <v-ons-row>
                <v-ons-col class="custom-record-col">
                  <p style="text-align: center; line-height: 5px">
                    定期交換部品記録簿
                  </p>
                </v-ons-col>
              </v-ons-row>
              <v-ons-row class="custom-ons-box">
                <v-ons-col>
                  <div style="overflow-x: auto; width: 100%;">
                    <table border="1" class="custom-table-check-modal ons-col-border" style="min-width: 49.5em;">
                      <thead>
                        <tr>
                          <th class="text-header-center ntss-list-title col-item">項目</th>
                          <th class="text-header-center ntss-list-title col-replace-parts">基準</th>
                          <th class="text-header-center ntss-list-title col-recommend-replace-time">交換推奨時間</th>
                          <th
                            class="text-header-center ntss-list-title col-operation custom-checkbox custom-header freeze ntss-list-header-th-sticky">
                            交換
                            <v-ons-checkbox @change="changeAns($event, 2)"
                              v-model="editData.inspectInfor.menteAnsHeader2"
                              :disabled="!hasDevEditAuthority"></v-ons-checkbox>
                          </th>
                          <th class="text-header-center ntss-list-title col-comment">コメント</th>
                          <th class="text-header-center ntss-list-title col-inspector">作業者</th>
                        </tr>
                      </thead>
                      <tbody v-for="(item, index) in editData.table2" :key="index">
                        <tr>
                          <td colspan="6" class="text-header-center ntss-list-title header_three">{{ item.catelogyName }}</td>
                        </tr>
                        <tr v-for="(i, ind) in item.detailItems" :key="ind"
                          :style="{ backgroundColor: ind % 2 == 0 ? 'var(--ntss-list-item-background-color)' : 'var(--ntss-list-content-2nd-background-color)' }">
                          <td>{{ i.menteContent1 }}</td>
                          <td>{{ i.menteContent2 }}</td>
                          <td>{{ i.menteContent3 }}</td>
                          <td class="not-padding" style="text-align: center">
                            <v-ons-checkbox v-model="i.judge" @change="updateStatusItem(i, 2, $event)"
                            :disabled="!hasDevEditAuthority">
                            </v-ons-checkbox>
                            <!-- mod #11065 【03】編集権限バグ修正 関 end -->
                          </td>
                          <td>
                            <com-textarea v-if="i.isCmt == 1" :idTextarea="'com-textarea-table2-comment-' + index + '-' + ind"
                              :content="i.comment" class="comTextarea"
                              cssClass="textarea-custom-text-font textarea-resize-vertical" style="width: 100%;"
                              @blur="updateInspected(0, 2, index, i.detail_cd)"
                              @set-content-data="setContentDataComment($event, 2, index, ind, i.detail_cd)"
                              :disabled="!hasDevEditAuthority" />
                          </td>                          <td
                            :style="{ backgroundColor: ind % 2 == 0 ? 'var(--ntss-list-item-background-color)' : 'var(--ntss-list-content-2nd-background-color)' }"
                            class="td-color">
                            {{ i.judge != "" ? i.checkerFullName : "" }}
                         </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-col>
        </v-ons-row>
        <modal-MachinePartsRunning v-if="showMachinePartsRunning" class="parentModalPeriodicInspection"> </modal-MachinePartsRunning>
      </div>
    </div>
    <!-- ボタン -->
    </template>
    <template #footer>
      <div class="flex-container" style="overflow-x: auto">
      <div>
        <v-ons-button class="btn2-cancel" style="width: 100px; margin-right: 0.5em;" @click="closeCheckListModal()">
          キャンセル
        </v-ons-button>
      </div>
      <div class="denial-btn-area close-button" style="background: none; padding-right: 15px;margin: auto">
        <button class="btn3-normal button registration-btn" @click="showHistoryModal">
          点検履歴
        </button>
      </div>
<!--      mod 11021 定期点検結果のみ削除仕様 zkm start-->
<!--      <div class="denial-btn-area close-button" style="background: none; width: 10em" />-->
      <div v-if="hasAns" style="margin-right: 10px;">
        <v-ons-button
          class="btn1-execute"
          :disabled="!hasDevEditAuthority"
          @click="delDateFunc()"
        >
          点検結果削除
        </v-ons-button>
      </div>
      <!--      mod 11021 定期点検結果のみ削除仕様 zkm end-->
      <div>
        <v-ons-button
          class="btn1-execute"
          style="width: 100px;"
          :disabled="!hasDevEditAuthority || !isChanged"
          @click="updateDateFunc()"
        >
          保存
        </v-ons-button>
      </div>
          </div>
    </template>
  </modal-base>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import store from "@/stores";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import CommonTextArea from "@/components/common/CommonTextArea";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import MachinePartsRunningComponent from "@/components/periodic-inspection/MachinePartsRunningComponent";
import {ApiHelper} from "@/apis/AxiosHelper";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { customComparatorForType } from "@/utils/util.js";
import { deepCopy } from "@/functions/common/CommonFunctions";

const MENTECLASS = 2;
export default {
  mixins: [ComponentGuardMixin],
  name: "CheckListModal",
  components: {
    "modal-base": ModalBase,
    "modal-MachinePartsRunning": MachinePartsRunningComponent,
    "pop-over": MasterSelector,
    "com-textarea": CommonTextArea,
  },
  data() {
    return {
      authorityCds: [AUTHORITY_CODES.DEV_PEDIT, AUTHORITY_CODES.DEV_EDIT],
      hasDevEditAuthority: false,
      layoutName: "",
      layoutGroupName: "",
      nowLayout: 0,
      layoutSize: 0,
      selectItem: {},
      main: "",
      header: "",
      checklistGridToolbarHeight: 500,
      checklistGridHeight: 300,
      tableTop: 0,
      getEditDateDataFormat: null,
      showMachinePartsRunning: false,
      selectedTarget: null,
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start
      // min: 0,
      // max: 2147483647,
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end
      focusFlg: false,
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "right",
        popoverTitleHeader: "",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        // add 11872 利用者指定IFのデフォルト選択状態 zrx start  定期点検-定期点検結果登録
        popoverContentSelected:{},
        // add 11872 利用者指定IFのデフォルト選択状態 zrx start  定期点検-定期点検結果登録
      },
      confirmVisible: false,
      dialogType: "2",
      updateDate: [],
      oldDateDetail: [],
      tableIndex1: [],
      tableIndex2: [],
      djjlList: [
        { id: "", name: "" },
        { id: 1, name: "レ" },
        { id: 2, name: "〇" },
        { id: 3, name: "✖" },
        { id: 4, name: "A" },
        { id: 5, name: "T" },
        { id: 6, name: "C" },
      ],
      djjlList1:[
        {id:"", name:""},
        {id:1, name:"レ"},
      ],
      ansList: [
        { id: null, name: "" },
        { id: 1, name: "合格" },
        { id: 3, name: "不合格" },
        { id: 2, name: "作業中" },
      ],
      initEditData: null,
      // add 11021 定期点検結果のみ削除仕様 zkm start
      hasAns: false,
      // add 11021 定期点検結果のみ削除仕様 zkm end
      menteLayoutList: []
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      accountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("account-edit", ["getTheme"]),
    ...mapGetters("periodic-inspection", [
      "getParamsGetDetail",
      "getAllUser",
      "getPeriodicResultDetail",
      "getOpenFirstPeriodic",
      "getLayoutGroupList",
      "getHistoryParams",
      "getLayoutList",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "getIsOpenBySubView",
      "getIsOpenByHistoryView",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    ]),
    ...mapGetters("periodic-inspection", { editData: "getDetailData" }),
    ...mapGetters("user", ["getFacilityCd"]),
    popoverTargetElement() {
      return this.selectedTarget === null
        ? null
        : this.$refs[this.selectedTarget];
    },
    isChanged() {
      return this.menteLayoutList.some(menteLayout => !isEqualWith(menteLayout.initEditData, menteLayout.editData, customComparatorForType));
    }
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal", "showMachineModal"]),
    ...mapActions("periodic-inspection", [
      "sendRequestGetDetail",
      "sendRequestUpdateMente",
      "setOpenFirstPeriodic",
      "sendRequestGetAllLayout",
      "setHistoryParams",
    ]),
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapMutations("periodic-inspection", [
      "setMachine",
      "setBeforeModel",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "setIsOpenBySubView",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      "setDetailData",
    ]),
    requestrReportParams(param) {
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      if(!this.getIsOpenBySubView) return;
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        // 印刷パラメータを応答
        var arr = [this.editData.machineInfor.machineNo];
        const param = {
          patId: this.selectedPatId,
          date: dayjs(this.editData.inspectInfor.menteDate).format("YYYYMMDD"),
          fromDate: dayjs(this.editData.inspectInfor.menteDate).format("YYYYMMDD"),
          toDate: dayjs(this.editData.inspectInfor.menteDate).format("YYYYMMDD"),
          mainte_no: this.editData.inspectInfor.devMenteNo,
          functionCd: "03301",
          facilityCd: this.getFacilityCd,
          machineNos: arr
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start
    // preventNegativeNum(e) {
    //   // 数値範囲内かどうかの確認
    //   if (this.min !== undefined && this.max !== undefined) {
    //     if (e.target.value > this.max) {
    //       this.editData.inspectInfor.recNo = this.min;
    //       this.blurFlg = true;
    //     } else if (e.target.value < this.min) {
    //       this.editData.inspectInfor.recNo = this.max;
    //       this.blurFlg = true;
    //     } else {
    //       this.blurFlg = false;
    //     }
    //   }
    //   this.updateInspected();
    // },
    // stopScrollFun(e) {
    //   if (!this.focusFlg) {
    //     return;
    //   }
    //   let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
    //     (e.detail && (e.wheelDelta > 0 ? -1 : 1))
    //   if (!e.target.value) {
    //     e.target.value = 0
    //   }
    //   let value = parseFloat(e.target.value);
    //   const parameterStep = 1;
    //   if (delta > 0) {
    //     // 滑ります
    //     value += parameterStep
    //   } else {
    //     // 下がります
    //     value -= parameterStep
    //   }
    //   // 数値範囲内かどうかの確認
    //   if (value > this.max) {
    //     value = this.min;
    //   }
    //   if (value < this.min) {
    //     value = this.max;
    //   }
    //   this.editData.inspectInfor.recNo = value;
    // },
    // formatValue(event) {
    //   // 限界値判定
    //   let value = event.target.value;
    //   if (value == this.max && this.blurFlg) {
    //     this.editData.inspectInfor.recNo = this.min;
    //     this.blurFlg = false;
    //   } else if (value == this.min && this.blurFlg) {
    //     this.editData.inspectInfor.recNo = this.max;
    //     this.blurFlg = false;
    //   }
    //   this.editData.inspectInfor.recNo = +value
    //   this.focusFlg = false;
    // },
    // handleFocus() {
    //   this.focusFlg = true;
    // },
    // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end
    createPopoverData(popoverVisible, popoverTitleHeader, popoverContentLabel) {
      this.popoverData.popoverVisible = popoverVisible;
      this.popoverData.popoverTitleHeader = popoverTitleHeader;
      this.popoverData.popoverContentLabel = popoverContentLabel;
      // mod 11872 利用者指定IFのデフォルト選択状態 zrx start  定期点検-定期点検結果登録
      if(popoverContentLabel ===  "実施者名") {
        this.popoverData.popoverContentSelected.value =
          this.initEditData?.inspectInfor?.checkerId1 ? this.initEditData.inspectInfor.checkerId1 : this.accountInfo.userId;
      }
      if(popoverContentLabel ===  "確認者名") {
        this.popoverData.popoverContentSelected.value =
          this.initEditData?.inspectInfor?.checkerId2 ? this.initEditData.inspectInfor.checkerId2 : this.accountInfo.userId;
      }
      // mod 11872 利用者指定IFのデフォルト選択状態 zrx end  定期点検-定期点検結果登録
    },
    selectChecker() {
      this.selectedTarget = "btnChecker";
      this.createPopoverData(true, "確認者", "確認者名");
    },
    selectInspector() {
      this.selectedTarget = "btnInspector";
      this.createPopoverData(true, "実施者", "実施者名");
    },
    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    selectedValue(data) {
      if (this.selectedTarget == "btnChecker") {
        this.editData.inspectInfor.checkerId2 = data.value;
      } else {
        this.editData.inspectInfor.checkerId1 = data.value;
      }
      this.updateInspected();
    },
    getUserName(id) {
      const user = this.getAllUser.find((rec) => {
        return rec.user_id === id;
      });
      if (user) {
        return user.checkerFullName;
      }
      return "";
    },
    //mod FNSI-No.9790 バラメタを追加する　杜　start
    updateInspected(item = 0, tableIndex = 0, index = 0, detail_cd = 0) {
      this.colectData(item, tableIndex, index, detail_cd);
    },
    updateInspectedAcceptUser() {
      this.editData.inspectInfor.checkerId1 = this.tempAcceptUser;
      this.dataAcceptUser = this.tempAcceptUser;
      this.colectData();
      this.popoverVisibleAcceptUser = false;
    },
    updateInspectedConfirmUser() {
      this.editData.inspectInfor.checkerId2 = this.tempConfirmUser;
      this.dataConfirmUser = this.tempConfirmUser;
      this.colectData();
      this.popoverVisibleConfirmUser = false;
    },
    updateAns() {
      this.colectData();
    },
    async updateStatusItem(item, tableIndex, e) {
      const nowMenteLayout = this.menteLayoutList[this.nowLayout];
      let userId = null;
      if(tableIndex == 1){
        userId = this.getPeriodicInspectorUserId(nowMenteLayout.initEditData.table1,item);
      } else if(tableIndex == 2){
        item.judge = e.target.checked;
        userId = this.getPeriodicInspectorUserId(nowMenteLayout.initEditData.table2,item);
      }

      this.editData.inspectInfor.detail =
        this.editData.inspectInfor.detail === null
          ? "[]"
          : this.editData.inspectInfor.detail;
      let detailOfResult = JSON.parse(this.editData.inspectInfor.detail);
      let intemModify = detailOfResult.findIndex(
        (x) =>
          tableIndex === x.tableIndex &&
          x.detail_cd === item.detail_cd &&
          item.detail_cd !== 0 &&
          x.cate_cd === item.cate_cd
      );
      if (intemModify >= 0) {
        detailOfResult[intemModify] = {
          detail_cd: item.detail_cd,
          comment: item.comment,
          judge: item.judge,
          user_id: userId,
          tableIndex: tableIndex,
          date: dayjs(item.upDate).toISOString(),
          edition: item.edition,
          cate_cd: item.cate_cd,
          cate_edi: item.cate_edi,
        };
      } else {
        detailOfResult.push({
          detail_cd: item.detail_cd,
          comment: item.comment,
          judge: item.judge,
          user_id: this.accountInfo.userId,
          tableIndex: tableIndex,
          date: dayjs(item.upDate).toISOString(),
          edition: item.edition,
          cate_cd: item.cate_cd,
          cate_edi: item.cate_edi,
        });
      }
      this.editData.inspectInfor.detail = JSON.stringify(detailOfResult);
      await this.colectData(item, tableIndex);
    },

    async changeAns(e, table) {
      this.editData.inspectInfor.detail =
        this.editData.inspectInfor.detail === null
          ? "[]"
          : this.editData.inspectInfor.detail;
      let detailOfResult = JSON.parse(this.editData.inspectInfor.detail);
      let tableInfor =
        table === 1 ? this.editData.table1 : this.editData.table2;
      var statue;
      let menteLayoutTable = null;
      if (table === 1) {
        statue = e.target.value;
        menteLayoutTable = deepCopy(this.menteLayoutList[this.nowLayout].initEditData.table1);
      } else {
        statue = e.target.checked;
        menteLayoutTable = deepCopy(this.menteLayoutList[this.nowLayout].initEditData.table2);
      }

      tableInfor.forEach((item,categoryIndex) => {
        item.detailItems.forEach((itemDetail) => {
          const djjlListIds = this.djjlList.map((i) => String(i.id));
          const djjlList1Ids = this.djjlList1.map((i) => String(i.id));
          if (table === 1) {
            if(itemDetail.ansPattern == 1){
              if(djjlListIds.includes(statue)){
                itemDetail.judge = statue;
              }
            }else if(itemDetail.ansPattern == 2){
              if(djjlList1Ids.includes(statue)){
                itemDetail.judge = statue;
              }
            }
          }else{
            itemDetail.judge = statue;
          }
          const copyItemDetail = deepCopy(itemDetail);
          delete copyItemDetail.checkerFullName;
          let nowMenteLayoutDetailTable = menteLayoutTable[categoryIndex].detailItems.find(
            (x) =>
              x.detail_cd === itemDetail.detail_cd &&
              itemDetail.detail_cd !== 0 &&
              x.cate_cd === itemDetail.cate_cd
          );
          delete nowMenteLayoutDetailTable.checkerFullName;
          let userId = null;
          if(isEqualWith(JSON.parse(JSON.stringify(nowMenteLayoutDetailTable)),JSON.parse(JSON.stringify(copyItemDetail)),customComparatorForType)){
            userId = copyItemDetail.user_id;
          } else{
            userId = this.accountInfo.userId;
          }
          let intemModify = detailOfResult.findIndex(
            (x) =>
              x.detail_cd === itemDetail.detail_cd &&
              itemDetail.detail_cd !== 0 &&
              x.tableIndex == table &&
              x.cate_cd === itemDetail.cate_cd
          );
          if (intemModify >= 0) {
            detailOfResult[intemModify] = {
              detail_cd: itemDetail.detail_cd,
              comment: itemDetail.comment,
              judge: itemDetail.judge,
              user_id: userId,
              tableIndex: table,
              date: dayjs(itemDetail.upDate).toISOString(),
              edition: itemDetail.edition,
              cate_cd: itemDetail.cate_cd,
            };
          } else {
            detailOfResult.push({
              detail_cd: itemDetail.detail_cd,
              comment: itemDetail.comment,
              judge: itemDetail.judge,
              user_id: this.accountInfo.userId,
              tableIndex: table,
              date: dayjs(itemDetail.upDate).toISOString(),
              edition: itemDetail.edition,
              cate_cd: itemDetail.cate_cd,
            });
          }
        });
      });
      this.editData.inspectInfor.detail = JSON.stringify(detailOfResult);
      if (this.editData.inspectInfor.devMenteNo == null) {
        this.getPeriodicResultDetail.result.regDate = new Date();
      }
      tableInfor.forEach((itemTable) => {
         itemTable.detailItems.forEach((i) => {
         this.colectData(i,table);
         })
      });
    },
    async colectData(item, tableIndex = 0, index = 0, detail_cd = 0) {
      if ((tableIndex === 1 || tableIndex === 2) && detail_cd !== 0) {
        const detail =
          this.editData.inspectInfor.detail &&
          JSON.parse(this.editData.inspectInfor.detail);
        let table;
        let nowMenteLayoutTable = null;
        // 定期点検記録簿のコメントを入力する場合は、table1から値を取得する
        if (tableIndex === 1) {
          table = this.editData.table1[index];
          // 定期交換部品記録簿のコメントを入力する場合は、table2から値を取得する
          nowMenteLayoutTable = deepCopy(this.menteLayoutList[this.nowLayout].initEditData.table1[index]);
        } else {
          table = this.editData.table2[index];
          nowMenteLayoutTable = deepCopy(this.menteLayoutList[this.nowLayout].initEditData.table2[index]);
        }
        const detailTable = table.detailItems.find(
          (x) => x.detail_cd === detail_cd
        );
        const copyDetailTable = deepCopy(detailTable);
        delete copyDetailTable.checkerFullName;
        const nowMenteLayoutDetailTable = nowMenteLayoutTable.detailItems.find(
          (x) => x.detail_cd === detail_cd
        );
        delete nowMenteLayoutDetailTable.checkerFullName;
        let userId = null;
        if(isEqualWith(JSON.parse(JSON.stringify(nowMenteLayoutDetailTable)),JSON.parse(JSON.stringify(copyDetailTable)),customComparatorForType)){
          userId = copyDetailTable.user_id;
        } else{
          userId = this.accountInfo.userId;
        }
        const jsonIndex = detail.findIndex(
          (x) => x.tableIndex === tableIndex && x.detail_cd === detail_cd
        );
        if (jsonIndex >= 0) {
          detail[jsonIndex].comment = detailTable ? detailTable.comment : "";
          detail[jsonIndex].date = dayjs(detailTable.upDate).toISOString();
          detail[jsonIndex].edition = detailTable.edition;
          detail[jsonIndex].user_id = userId;
          detail[jsonIndex].judge =
            detailTable.judge == "" ? "" : detailTable.judge;
          detail[jsonIndex].cate_cd = detailTable.cate_cd;
        } else {
          detail.push({
            detail_cd: detailTable.detail_cd,
            comment: detailTable.comment,
            judge: detailTable.judge,
            user_id: this.accountInfo.userId,
            tableIndex: tableIndex,
            date: dayjs(detailTable.upDate).toISOString(),
            edition: detailTable.edition,
            cate_cd: detailTable.cate_cd,
          });
        }
        this.editData.inspectInfor.detail = JSON.stringify(detail);
      }
      let paramsForUpdate = {
        devMenteNo: this.editData.inspectInfor.devMenteNo,
        facilityCd: this.getFacilityCd,
        menteClass: MENTECLASS,
        machineNo: this.editData.machineInfor.machineNo,
        recNo: this.editData.inspectInfor.recNo,
        menteDate: this.editData.inspectInfor.menteDate,
        menteLayoutGroupCd:
          this.getPeriodicResultDetail.result.menteLayoutGroupCd,
        menteLayoutCd: this.editData.inspectInfor.menteLayoutCd,
        mainteLayoutGroupEdition:
          this.getPeriodicResultDetail.result.mainteLayoutGroupEdition,
        mainteCategoryCd: this.getPeriodicResultDetail.result.mainteCategoryCd,
        mainteLayoutEdition:
          this.getPeriodicResultDetail.result.mainteLayoutEdition,
        checkerId1: this.editData.inspectInfor.checkerId1,
        checkerId2: this.editData.inspectInfor.checkerId2,
        menteAns1: this.editData.inspectInfor.menteAns1,
        menteComment1: this.editData.inspectInfor.menteComment1,
        detail: this.editData.inspectInfor.detail,
        isDisp: "1",
        isDel: 0,
        regDate: this.getPeriodicResultDetail.result.regDate,
        upDate: new Date(),
      };
      var layoutGroupName = this.layoutGroupName.toString();
      const param = {
        layoutGroupName: layoutGroupName,
        item: paramsForUpdate,
      };
      for (var h = 0; h < this.updateDate.length; h++) {
        if (this.updateDate[h].layoutGroupName == layoutGroupName) {
          this.updateDate[h] = param;
        }
      }
      if (tableIndex === 1 && item !== 0) {
        this.setCheckerName1(paramsForUpdate, item);
      } else if (tableIndex === 2 && item !== 0) {
        this.setCheckerName2(paramsForUpdate, item);
      }
    },
    async updateDateFunc() {
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setIsOpenBySubView(false);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      this.setLoadingScreenVisible(true);
      var flag = false;
      if (this.updateDate != null && this.updateDate.length > 0) {
        for (var i = 0; i < this.updateDate.length; i++) {
          var nowDate = this.updateDate[i];
          for (var k = 0; k < this.oldDateDetail.length; k++) {
            var oldDate = this.oldDateDetail[k];
            if (nowDate.layoutGroupName == oldDate.layoutGroupName && nowDate.item != "") {
              if (nowDate.item.recNo != oldDate.item.recNo) {
                flag = true;
              }
              if (nowDate.item.checkerId1 != oldDate.item.checkerId1) {
                flag = true;
              }
              if (nowDate.item.checkerId2 != oldDate.item.checkerId2) {
                flag = true;
              }
              if (nowDate.item.menteAns1 != oldDate.item.menteAns1) {
                flag = true;
              }
              if (nowDate.item.menteComment1 != oldDate.item.menteComment1) {
                flag = true;
              }
              if (nowDate.item.detail != oldDate.item.detail) {
                flag = true;
              }
            }
          }
        }
        if (flag) {
          const cloneObj = JSON.parse(JSON.stringify(this.updateDate))

          for (let i = 0; i < cloneObj.length; i++) {
            const nowDate = cloneObj[i];
            const listDetail1 = [];
            if(!(nowDate.item == null || nowDate.item == "")){
              JSON.parse(nowDate.item.detail).forEach((item) => {
                if (item.tableIndex == 2) {
                  listDetail1.push({
                    detail_cd: item.detail_cd,
                    comment: item.comment,
                    judge: item.judge ? '1' : '',
                    user_id: item.user_id,
                    tableIndex: item.tableIndex,
                    date: dayjs(item.upDate).toISOString(),
                    edition: item.edition,
                    cate_cd: item.cate_cd,
                    cate_edi: item.cate_edi,
                  });
                }else{
                  listDetail1.push(item);
                }
              });
              nowDate.item.detail = JSON.stringify(listDetail1);
            }
          }

          await this.sendRequestUpdateMente(cloneObj);
          this.setLoadingScreenVisible(false);
          EventBus.$emit("postUpdate");
          this.hideModal();
        } else {
          this.setLoadingScreenVisible(false);
          this.closeCheckListModal();
        }
      } else {
        this.setLoadingScreenVisible(false);
        this.closeCheckListModal();
      }
    },
    // add 11021 定期点検結果のみ削除仕様 zkm start
    async delDateFunc() {
      store.dispatch("report/getMstReport", {funcCd: "03301", printFlag: 0});
      this.setLoadingScreenVisible(true);
      const cloneObj = JSON.parse(JSON.stringify(this.oldDateDetail));
      await ApiHelper.post(`mente-main/detail-del`, {devMenteNo: cloneObj[0].item.devMenteNo});
      this.setLoadingScreenVisible(false);
      EventBus.$emit("postUpdate");
      this.hideModal();
    },
    // add 11021 定期点検結果のみ削除仕様 zkm end
    closeCheckListModal() {
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setIsOpenBySubView(false);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000117].title,
          message: messageFormat(DIALOG_MESSAGES[13000117].message),
          callback: answer => {
            if (answer === 1) {
              EventBus.$emit("postUpdate");
              this.hideModal();
            }
          }
        });
      } else {
        EventBus.$emit("postUpdate");
        this.hideModal();
      }
    },
    async showHistoryModal() {
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setIsOpenBySubView(false);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      if(this.isChanged){
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000117].title,
          message: messageFormat(DIALOG_MESSAGES[13000117].message),
          callback: answer => {
            if(answer === 1){
              EventBus.$emit("postUpdate");
              this.setHistoryParams({searchDate:this.editData.inspectInfor.menteDate});
              EventBus.$emit('showHistory');
            }
          }
        });
      }else{
        this.setHistoryParams({searchDate:this.editData.inspectInfor.menteDate});
        EventBus.$emit('showHistory');
      }
    },
    setCheckerName1(dataDetail1, item) {
      item.checkerFullName = '';
      const listDetail1 = [];
      JSON.parse(dataDetail1.detail).forEach((obj) => {
        if (obj.tableIndex == 1) {
          listDetail1.push(obj);
        }
      });
      listDetail1.forEach((detail) => {
        detail.checkerFullName = this.getAllUser
          .filter((user) => user.user_id == +detail.user_id)
          .map((i) => i.checkerFullName)[0]
          ? this.getAllUser
            .filter((user) => user.user_id == +detail.user_id)
            .map((i) => i.checkerFullName)[0]
          : "";
      });
      listDetail1.forEach((itemDetail) => {
        if (
          item.detail_cd == itemDetail.detail_cd &&
          item.menteCategoryCd == itemDetail.cate_cd
        ) {
          item.checkerFullName = itemDetail.checkerFullName;
        }
      });
    },
    setCheckerName2(dataDetail2, item) {
      item.checkerFullName = '';
      const listDetail2 = [];
      JSON.parse(dataDetail2.detail).forEach((obj) => {
        if (obj.tableIndex == 2) {
          listDetail2.push(obj);
        }
      });
      listDetail2.forEach((detail) => {
        detail.checkerFullName = this.getAllUser
          .filter((user) => user.user_id == +detail.user_id)
          .map((i) => i.checkerFullName)[0]
          ? this.getAllUser
            .filter((user) => user.user_id == +detail.user_id)
            .map((i) => i.checkerFullName)[0]
          : "";
      });
      listDetail2.forEach((itemDetail) => {
        if (
          item.detail_cd == itemDetail.detail_cd &&
          item.menteCategoryCd == itemDetail.cate_cd
        ) {

          item.checkerFullName = itemDetail.checkerFullName;
        }
      });
    },
    // add FNSI-No.IES224 画面の最上段中央にレイアウト名を表示し、複数ある場合はレイアウト名の左右に「◀」「▶」を表示し切り替えることができるようにする 吉 start
    async switchLayoutNext() {
      this.setLoadingScreenVisible(true);
      if (this.nowLayout == this.layoutSize - 1) {
        this.nowLayout = 0;
      } else {
        this.nowLayout = this.nowLayout + 1;
      }

      this.getParamsGetDetail.menteLayoutGroupCd =
        this.getParamsGetDetail.letmenteLayoutGroupNo[this.nowLayout];
      this.getParamsGetDetail.devMenteNo =
        this.getParamsGetDetail.devMenteNoArr[this.nowLayout];
      var listLayoutGroup = this.getLayoutGroupList;
      this.layoutGroupName = listLayoutGroup.find(
        (x) =>
          x.menteLayoutGroupCd === this.getParamsGetDetail.menteLayoutGroupCd).groupName;
      if (
        null != this.updateDate &&
        this.updateDate.length != 0 &&
        null != this.updateDate[this.nowLayout] &&
        this.updateDate[this.nowLayout].layoutGroupName == this.layoutGroupName
      ) {
        this.getParamsGetDetail.flagInfo = this.updateDate[this.nowLayout];
        await this.sendRequestGetDetail(this.getParamsGetDetail);
      } else {
        await this.sendRequestGetDetail(this.getParamsGetDetail);
      }
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start
      // this.editData.inspectInfor.recNo = +this.editData.inspectInfor.recNo;
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end
      var listLayout = this.getLayoutList;
      if (null != this.editData.inspectInfor.menteLayoutNo) {
        if (listLayout[2].find((x) => x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd && x.editionNo === this.editData.inspectInfor.menteLayoutNo) !== undefined) {
          this.layoutName = listLayout[2].find(
            (x) =>
              x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd &&
              x.editionNo === this.editData.inspectInfor.menteLayoutNo).layoutHeader;
        }

      } else {
        if (listLayout[1].find((x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd) !== undefined) {
          this.layoutName = listLayout[1].find(
            (x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd).layoutHeader;
        }
      }
      this.popoverData.popoverContentDataset = this.getAllUser.map((item) => {
        return {
          value: item.user_id,
          text: item.checkerFullName,
        };
      });
      var layoutGroupName = this.layoutGroupName.toString();
      var flag = true;
      for (var i = 0; i < this.oldDateDetail.length; i++) {
        if (this.oldDateDetail[i].layoutGroupName == layoutGroupName) {
          flag = false;
        }
      }
      if (flag) {
        const param = {
          layoutGroupName: layoutGroupName,
          item: JSON.parse(JSON.stringify(this.editData.inspectInfor)),
        };
        this.oldDateDetail.push(param);
      }
      await this.setOpenFirstPeriodic(this.editData.inspectInfor.devMenteNo);
      this.setLoadingScreenVisible(false);
      this.initEditData = deepCopy(this.editData);
      if (this.initEditData) {
        delete this.initEditData.inspectInfor.detail;
      }
    },
    async switchLayoutBack() {
      this.setLoadingScreenVisible(true);
      if (this.nowLayout == 0) {
        this.nowLayout = this.layoutSize - 1;
      } else {
        this.nowLayout = this.nowLayout - 1;
      }
      this.getParamsGetDetail.menteLayoutGroupCd =
        this.getParamsGetDetail.letmenteLayoutGroupNo[this.nowLayout];
      this.getParamsGetDetail.devMenteNo =
        this.getParamsGetDetail.devMenteNoArr[this.nowLayout];
      var listLayoutGroup = this.getLayoutGroupList;
      this.layoutGroupName = listLayoutGroup.find(
        (x) =>
          x.menteLayoutGroupCd === this.getParamsGetDetail.menteLayoutGroupCd).groupName;
      // add  吉 start
      var listLayout = this.getLayoutList;
      // add  吉 end
      if (
        null != this.updateDate &&
        this.updateDate.length != 0 &&
        null != this.updateDate[this.nowLayout] &&
        this.updateDate[this.nowLayout].layoutGroupName == this.layoutGroupName
      ) {
        this.getParamsGetDetail.flagInfo = this.updateDate[this.nowLayout];
        await this.sendRequestGetDetail(this.getParamsGetDetail);
      } else {
        await this.sendRequestGetDetail(this.getParamsGetDetail);
      }
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start
      // this.editData.inspectInfor.recNo = +this.editData.inspectInfor.recNo;
      // del #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end
      if (null != this.editData.inspectInfor.menteLayoutNo) {
        if (listLayout[2].find((x) => x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd && x.editionNo === this.editData.inspectInfor.menteLayoutNo) !== undefined) {
          this.layoutName = listLayout[2].find(
            (x) =>
              x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd &&
              x.editionNo === this.editData.inspectInfor.menteLayoutNo).layoutHeader;
        }
      } else {
        if (listLayout[1].find((x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd) !== undefined) {
          this.layoutName = listLayout[1].find(
            (x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd).layoutHeader;
        }
      }
      this.popoverData.popoverContentDataset = this.getAllUser.map((item) => {
        return {
          value: item.user_id,
          text: item.checkerFullName,
        };
      });
      var layoutGroupName = this.layoutGroupName.toString();
      var flag = true;
      for (var i = 0; i < this.oldDateDetail.length; i++) {
        if (this.oldDateDetail[i].layoutGroupName == layoutGroupName) {
          flag = false;
        }
      }
      if (flag) {
        const param = {
          layoutGroupName: layoutGroupName,
          item: JSON.parse(JSON.stringify(this.editData.inspectInfor)),
        };
        this.oldDateDetail.push(param);
      }
      await this.setOpenFirstPeriodic(this.editData.inspectInfor.devMenteNo);
      this.setLoadingScreenVisible(false);
      this.initEditData = deepCopy(this.editData);
      if (this.initEditData) {
        delete this.initEditData.inspectInfor.detail;
      }
    },
    async reload() {
      this.setLoadingScreenVisible(true);
      await this.setInitData();
      this.setLoadingScreenVisible(false);
    },

    async setInitData() {
      this.confirmVisible = true;
      let listLayoutGroup = this.getLayoutGroupList;
      const menteLayoutList = [];
      const paramsGetDetail = deepCopy(this.getParamsGetDetail);
      if (this.getParamsGetDetail != null && this.getParamsGetDetail.letmenteLayoutGroupNo != null) {
        this.layoutSize = this.getParamsGetDetail.letmenteLayoutGroupNo.length;
        for (let i = 0;i < this.getParamsGetDetail.letmenteLayoutGroupNo.length;i++) {
          if (this.getParamsGetDetail.letmenteLayoutGroupNo[i] == this.getParamsGetDetail.menteLayoutGroupCd) {
            this.nowLayout = i;
          } else {
            paramsGetDetail.menteLayoutGroupCd = this.getParamsGetDetail.letmenteLayoutGroupNo[i];
            paramsGetDetail.devMenteNo = this.getParamsGetDetail.devMenteNoArr[i];
            paramsGetDetail.flagInfo = this.updateDate[i];
            await this.sendRequestGetDetail(paramsGetDetail);
            const copyEditData = deepCopy(this.editData);
            if (copyEditData) {
              delete copyEditData.inspectInfor.detail;
            }
            menteLayoutList[i] = { initEditData:copyEditData, editData:copyEditData };
          }
        }
      }
      this.layoutGroupName = listLayoutGroup.find(
        (x) =>
          x.menteLayoutGroupCd === this.getParamsGetDetail.menteLayoutGroupCd).groupName;
      let listLayout = this.getLayoutList;
      await this.sendRequestGetDetail(this.getParamsGetDetail);
      const copyEditData = deepCopy(this.editData);
      if (copyEditData) {
        delete copyEditData.inspectInfor.detail;
      }
      menteLayoutList[this.nowLayout] = { initEditData:copyEditData, editData:copyEditData };
      this.initEditData = copyEditData;
      this.menteLayoutList = menteLayoutList;
      if (this.editData.inspectInfor.menteLayoutNo != null) {
        if (listLayout[2].find((x) => x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd && x.editionNo === this.editData.inspectInfor.menteLayoutNo) !== undefined) {
          this.layoutName = listLayout[2].find(
            (x) =>
              x.mainteLayoutCd === this.editData.inspectInfor.menteLayoutCd &&
              x.editionNo === this.editData.inspectInfor.menteLayoutNo).layoutHeader;
        }
      } else {
        if (listLayout[1].find((x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd) !== undefined) {
          this.layoutName = listLayout[1].find(
            (x) => x.menteLayoutCd === this.editData.inspectInfor.menteLayoutCd).layoutHeader;
        }
      }
      this.popoverData.popoverContentDataset = this.getAllUser.map((item) => {
        return {
          value: item.user_id,
          text: item.checkerFullName,
        };
      });
      let layoutGroupName = this.layoutGroupName.toString();
      const param = {
        layoutGroupName: layoutGroupName,
        item: JSON.parse(JSON.stringify(this.editData.inspectInfor)),
      };
      this.oldDateDetail.push(param);
    },

    /**
     * @description 定期点検記録簿、定期交換部品記録簿の初期データの復元
     * @param {Object} initDataList  画面の初期値
     * @param {Object} editDataList  画面の現在の入力値
     * @return データの変更有無フラグ
     */
    restoreMenteLayoutDetail(initDataList,editDataList){
      let isChangedFlg = false;
      editDataList.forEach((editData, categoryIndex) => {
        editData.detailItems.forEach((detailItem, detailItemIndex) => {
          const editedKeyList = [];
          Object.keys(detailItem).forEach(key => {
            if(!initDataList[categoryIndex].detailItems[detailItemIndex].hasOwnProperty(key) && detailItem[key] === ""){
              delete detailItem[key];
              isChangedFlg = true;
            } else if((!initDataList[categoryIndex].detailItems[detailItemIndex].hasOwnProperty(key) && detailItem[key] !== "")
              || (initDataList[categoryIndex].detailItems[detailItemIndex].hasOwnProperty(key) && initDataList[categoryIndex].detailItems[detailItemIndex][key] !== detailItem[key])){
              editedKeyList.push(key);
            }
          });
          if(!editedKeyList.some(editedKey => !["user_id","checkerFullName"].includes(editedKey)) && editedKeyList.indexOf("user_id") >= 0){
            if(initDataList[categoryIndex].detailItems[detailItemIndex].hasOwnProperty("user_id")){
              detailItem.user_id = initDataList[categoryIndex].detailItems[detailItemIndex].user_id;
            } else{
              delete detailItem.user_id;
            }
            isChangedFlg = true;
          }
          if(!editedKeyList.some(editedKey => !["user_id","checkerFullName"].includes(editedKey)) && editedKeyList.indexOf("checkerFullName") >= 0){
            if(initDataList[categoryIndex].detailItems[detailItemIndex].hasOwnProperty("checkerFullName")){
              detailItem.checkerFullName = initDataList[categoryIndex].detailItems[detailItemIndex].checkerFullName;
            } else{
              delete detailItem.checkerFullName;
            }
            isChangedFlg = true;
          }
        });
      });
      return isChangedFlg;
    },

    /**
     * @description 定期点検記録簿、定期交換部品記録簿の点検者のユーザIDの取得
     * @param {Object} initDataList  画面の初期値
     * @param {Object} editRowData  画面の現在の行データ
     * @return 点検者のユーザID
     */
    getPeriodicInspectorUserId(initDataList,editRowData){
      let userId = null;
      const copyEditRowData = deepCopy(editRowData);
      delete copyEditRowData.checkerFullName;
      let categoryIndex = -1;
      let detailItemIndex = -1;
      for(let index = 0;index < initDataList.length;index++){
        detailItemIndex = initDataList[index].detailItems.findIndex(
          (x) =>
            x.detail_cd === editRowData.detail_cd &&
            editRowData.detail_cd !== 0 &&
            x.cate_cd === editRowData.cate_cd
        );
        if(detailItemIndex >= 0){
          categoryIndex = index;
          break;
        }
      }
      const initRowData = deepCopy(initDataList[categoryIndex].detailItems[detailItemIndex]);
      delete initRowData.checkerFullName;
      if(isEqualWith(JSON.parse(JSON.stringify(initRowData)),JSON.parse(JSON.stringify(copyEditRowData)),customComparatorForType)){
        userId = copyEditRowData.user_id;
      } else{
        userId = this.accountInfo.userId;
      }
      return userId;
    },
    /**
     * @description                コメント格納処理
     * @param {string} inputValue  入力値
     * @param {string} tableNo     テーブル番号(1：定期点検記録簿 / 2：定期交換部品記録簿)
     * @param {string} tableIndex  テーブル索引
     * @param {string} recordIndex レコード索引
     */
    setContentDataComment(inputValue, tableNo, tableIndex, recordIndex, detailCd) {
      // テーブル名の取得
      const tableName = "table" + String(tableNo);
      // コメントの格納
      this.editData[tableName][tableIndex].detailItems[recordIndex].comment = inputValue;
      // 検査結果の更新
      this.updateInspected(0, tableNo, tableIndex, detailCd);
    },
    ShowSomeThing(machineTypeCd, machineSerial) {
      const params = {
        facilityCd: this.getFacilityCd,
        machineTypeCd: machineTypeCd,
        machineSerial: machineSerial,
      };
      this.setMachine(params);
      this.setBeforeModel({name:"PeriodicInspectionModal"});
      this.showMachinePartsRunning = true;
    },
    async closeShowSomeThing(data)
    {
      this.showMachinePartsRunning = false;
    },
    showSubModals(callModalFunction, arg) {
      callModalFunction(arg);
    },
  },
  watch: {
    editData:{
      handler(newVal){
        const nowMenteLayout = this.menteLayoutList[this.nowLayout];
        if(nowMenteLayout){
          const copyEditData = deepCopy(newVal);
          let table1ChangedFlg = false;
          let table2ChangedFlg = false;
          if(copyEditData.table1.length > 0){
            table1ChangedFlg = this.restoreMenteLayoutDetail(nowMenteLayout.initEditData.table1,copyEditData.table1);
          }
          if(copyEditData.table2.length > 0){
            table2ChangedFlg = this.restoreMenteLayoutDetail(nowMenteLayout.initEditData.table2,copyEditData.table2);
          }
          if(table1ChangedFlg || table2ChangedFlg){
            this.setDetailData(deepCopy(copyEditData));
          }
          if (copyEditData) {
            delete copyEditData.inspectInfor.detail;
          }
          nowMenteLayout.editData = copyEditData;
          this.menteLayoutList[this.nowLayout] = nowMenteLayout;
        }
      },
      deep:true
    }
  },
  async created() {
    this.hasDevEditAuthority = this.hasAuthority();
    this.setLoadingScreenVisible(true);
    EventBus.$off("reload", this.reload);
    EventBus.$on("closeShowSomeThingModal", this.closeShowSomeThing);
    EventBus.$on("reload", this.reload);
    EventBus.$on("requestReportParams", this.requestrReportParams);
    let listLayoutGroup = this.getLayoutGroupList;
    if (this.getParamsGetDetail != null && this.getParamsGetDetail.letmenteLayoutGroupNo != null) {
      for (let i = 0;i < this.getParamsGetDetail.letmenteLayoutGroupNo.length;i++) {
        let layoutGroupNameStr = listLayoutGroup.find(
          (x) =>
            x.menteLayoutGroupCd ===
            this.getParamsGetDetail.letmenteLayoutGroupNo[i]).groupName;
        const param = {
          layoutGroupName: layoutGroupNameStr,
          item: "",
        };
        this.updateDate.push(param);
      }
    }
    await this.sendRequestGetAllLayout();
    await this.setInitData();
    await this.setOpenFirstPeriodic(this.editData.inspectInfor.devMenteNo);
    this.hasAns = '' !== this.initEditData.inspectInfor.menteAns1;
    this.setLoadingScreenVisible(false);
  },
  beforeUnmount() {
    // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
    //store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
    if(!this.getIsOpenByHistoryView) {
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
    }
    this.setIsOpenBySubView(false);
    // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    EventBus.$off("reload", this.reload);
    EventBus.$off("closeShowSomeThingModal", this.closeShowSomeThing);
    EventBus.$off("requestReportParams", this.requestrReportParams);
  },
};
</script>

<style scoped>
.custom-table-check-modal {
  border-collapse: collapse;
  width: 100%;
  margin-bottom: 5px;
  table-layout: fixed;
}

.custom-table-check-modal tbody tr:first-child {
  background: rgb(202, 202, 202);
  color: black;
}

.custom-table-check-modal tbody tr:not(first-child) td {
  padding-left: 5px;
}

td.not-padding {
  padding-left: 0px !important;
}

.custom-record-col {
  margin: 0 5px 0 5px;
}
.custom-ons-item {
  margin: 0 5px 0 5px;
}
.custom-ons-col {
  margin: 5px;
}
.custom-ons-box {
  padding: 0 5px 0 5px;
}
.answer {
  text-align: center;
  height: auto;
  align-items: center;
  background-color: lightblue;
}
.custom-ons-btn {
  padding: 0;
  width: 80px;
  margin-left: 5px;
}
.clicked-background {
  background: rgb(19, 94, 255);
  color: #ffffff;
}
.custom-center-p {
  min-height: 35px;
  height: auto;
  line-height: 35px;
  margin: 0;
  word-break: break-all;
  color: #000000;
}
.custom-input :deep(.text-input:disabled) {
  color: #000000;
  font-size: 15px;
  opacity: 1;
}

.custom-input :deep(.text-input),
.custom-font-size :deep(.text-input) {
  color: #000000;
  font-size: 15px;
  opacity: 1;
}
.custom-input[disabled] {
  opacity: 1;
  font-size: 15px;
}
.custom-like-input {
  width: 95%;
  border: solid 1px #ccc;
  border-radius: 3px;
  cursor: not-allowed;
  display: flex;
  align-items: center;
  /* line-height: 33px; */
  height: 2em;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.registration-btn,
.denial-btn {
  font-size: 15px;
}
@media only screen and (max-width: 650px) {
  .header-col {
    min-width: 100% !important;
  }
  .answer-title {
    flex: 0 0 32% !important;
    max-width: 100% !important;
  }
}
.answer-title-box {
  min-width: max-content;
  padding-right: 5px;
}
/* 削除ボタン */
.delete-button {
  background-color: #ff3366 !important;
  background-image: -webkit-linear-gradient(rgba(255, 255, 255, 0.3) 0%,
      transparent 50%,
      transparent 50%,
      rgba(0, 0, 0, 0.1) 100%);
  background-image: linear-gradient(rgba(255, 255, 255, 0.3) 0%,
      transparent 50%,
      transparent 50%,
      rgba(0, 0, 0, 0.1) 100%);
}
.close-button {
  margin-left: auto;
}
.display_box {
  width: 100%;
  display: flex;
  align-items: center;
}
.margin_box {
  width: 95%;
  margin: 0 auto;
}
/* 定期点検記録簿・定期交換部品記録簿 */
.col-item {
  border-left: solid 1px black;
  width: 10em;
}
.col-operation-inspect {
  width: 5.5em;
}
.col-operation {
  min-width: 5.5em !important;
  width: 5.5em !important;
}
.col-comment {
  width: 11em;
}
.col-inspector {
  border-right: solid 1px black;
  width: 6em;
}
/* 定期点検記録簿 */
.col-standard {
  min-width: 20em;
  width: calc(100% - 35.5em);
}
/* 定期交換部品記録簿 */
.col-replace-parts {
  min-width: 10em;
  width: calc(100% - 35.5em);
}
.col-recommend-replace-time {
  width: 6em;
}
.header_three {
  border-left: solid 1px black;
  border-right: solid 1px black;
}
.writeRowCss {
  background-color: var(--ntss-list-item-background-color);
}
.grayRowCss {
  border-color: 1px solid var(--ntss-list-content-2nd-background-color);
}
.answer-title,.display_box{
  display: flex;
  align-items: center;
}
/* 定期点検結果登録画面レイアウト不備 6572 shan start */
.ntss-list-title {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: unset;
  padding: 4px;
  border: solid 1px rgb(153, 153, 153);
  border-top: none;
  white-space: pre;
  text-align: left;
  position: sticky;
  top: calc(2em + 7px);
  z-index: 2;
}
th.ntss-list-title {
  position: sticky;
  top: 0px;
  z-index: 2;
}
.p-flex {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.td-color {
  color: var(--ntss-base-color);
}

.ons-col-border {
  border: solid var(--ntss-list-border-color);
  border-width: 0 1px 1px 0;
}

.ons-col-border th,
.ons-col-border td {
  border: solid var(--ntss-list-border-color);
  border-width: 0 1px 1px 0;
}

/* #9789 確認者の吹き出し内のリストが中央寄せ 蔡 start */
/*
:deep(.select-input) {
  text-align: center;
  padding-right: 0px;
  padding-left: 0px;
}
*/
.select-center :deep(.select-input) {
  text-align: center;
  padding-right: 0px;
  padding-left: 0px;
}
input {
  padding: 0px 0px;
  border-width: 0px;
  border-top-width: 0px;
  border-right-width: 0px;
  border-bottom-width: 0px;
  border-left-width: 0px;
}

div :deep(.modal-body) {
  overflow-x: hidden;
}

#checklist-modal-header {
  padding-bottom: 10px;
}

#stop-watch-icon {
  float: left;
  width: 20px;
  height: 20px;
}

.custom-checkbox :deep(.checkbox) {
  margin-top: 2px;
}
.custom-checkbox {
  max-width: 4.4em;
  min-width: 4.4em;
  width: 4.4em;
}
.custom-checkbox {
  text-align: center;
}
.custom-checkbox,
.custom-equip,
.custom-model,
.custom-bed {
  z-index: 4;
}
.freeze-horizontal.custom-checkbox,
.freeze-horizontal.custom-equip,
.freeze-horizontal.custom-model,
.freeze-horizontal.custom-bed {
  z-index: 3;
}

.freeze,
.freeze-vertical,
.freeze-horizontal {
  position: relative;
  left: unset;
}

.custom-header,
.custom-col-date {
  position: -webkit-sticky;
  position: sticky;
}

.custom-header {
  white-space: unset;
  height: 2em;
}
.ons-checkbox.checkbox {
  margin-right: 0px !important;
}

@media print {
  .modal-mask :deep(.modal-container) {
    width: 95%;
  }
  .modal-mask :deep(.modal-wrapper) {
    display: inline-block !important;
  }

  /* テーブル全体を印刷幅に収める */
  .custom-table-check-modal {
    width: 100% !important;
    table-layout: fixed !important;
    min-width: unset !important;
  }
  .custom-table-check-modal th,
  .custom-table-check-modal td {
    min-width: unset !important;
    word-break: break-all !important;
    white-space: normal !important;
    overflow-wrap: break-word !important;
  }
  .custom-table-check-modal .col-item,
  .custom-table-check-modal .col-replace-parts {
    width: 6em !important;
    min-width: 6em !important;
  }
  .custom-table-check-modal .col-standard {
    width: 12em !important;
    min-width: 12em !important;
  }
}
</style>
