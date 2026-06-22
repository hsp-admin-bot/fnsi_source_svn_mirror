<template>
  <div class="main-content-area d-flex flex-column flex-1 master-maintenance-page">
    <div class="d-flex flex-column flex-1">
      <div class="d-flex justify-content-flex-end">
        <span style="margin-top: 5px;margin-right: 15px;">最終更新日時： {{ nowDate }}</span>
        <v-ons-button class="nik-btn btn3-normal" @click="reloadFun">
          更新
        </v-ons-button>
        <v-ons-checkbox
          style="margin-top: 5px;margin-left: 15px;"
          input-id="Submit"
          @change="AutoUpdate"
        ></v-ons-checkbox>
        <span style="margin-top: 5px;">自動更新</span>
      </div>

      <!-- Connections -->
      <div class="icon-row d-flex justify-content-space-between icon-group">
        <!-- Note -->
        <div
          class="note d-flex flex-column align-items-center"
          @click="showNotePopover($event)"
        >
          <img src="img/external-coop/note.png" class="icon" :style="{ width: iconSize }"/>
        </div>
        <!-- / Note -->
        <!--mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start-->
        <!--<div :class="['first-connection', checkDeviceInfo ? 'ok' : 'ng']"></div>-->
        <!--mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start-->
<!--        <div :class="['first-connection', checkDeviceInfo && checkFac ? 'ok' : checkDeviceInfo && !checkFac ? 'no' : 'ng']"></div>-->
        <div :class="['first-connection', checkDeviceInfo && checkFac && checkSecondConnValid ? 'ok' : !checkDeviceInfo || !checkSecondConnValid ? 'ng' : 'no']" :style="{ height: connectionHeight }"></div>
        <!--mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm end-->
        <!--mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end-->
        <!-- Modem-->
        <div class="modem d-flex flex-column align-items-center">
          <img
            src="img/external-coop/modem.png"
            class="icon"
            :style="{ width: iconSize }"
            @click="showModemPopover($event)"
          />
<!--          mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang start-->
          <!-- mod FNSI-6085 ljx start-->
<!--                    <img
            src="img/external-coop/stop.png"
            v-show="checkFac"
            class="img-power center"
            @click="clickSendRequestIconFacility"
          />
          <img
            src="img/external-coop/open.png"
            class="img-power center"
            v-show="!checkFac"
            @click="clickSendRequestIconFacility"
          />-->
          <!-- add 5615 IFエッジコマンド実行 関 start -->
<!--          <v-ons-button
            v-if="isMasterUser"
            class="nik-btn Processing btn3-normal"
            @click="Processing"
          >
            処理要求
          </v-ons-button>-->
          <!-- mod FNSI-6085 ljx end-->

          <!-- add 5615 IFエッジコマンド実行 関 end -->
          <!-- <img
            src="img/external-coop/stop.png"
            class="img-power center"
            @click="clickSendRequestIconFacility"
          /> -->
          <!-- <img
            src="img/external-coop/open.png"
            class="img-power center"
            v-if="checkFac&&isNkkStaff"
          /> -->
        </div>
<!--          mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang end-->
        <!-- / Modem-->

        <!--mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start-->
<!--        <div :class="['connection', checkDeviceInfo ? 'ok' : 'ng']"></div>-->
        <div :class="['connection', checkDeviceInfo && checkSecondConnValid ? 'ok' : 'ng']" :style="{ height: connectionHeight }"></div>
        <!--mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm end-->

        <!-- Cloud-->
        <div class="cloud d-flex flex-column align-items-center">
          <img
            src="img/external-coop/cloud.png"
            class="icon"
            :style="{ width: iconSize }"
            @click="showCloudPopover($event)"
          />
<!--          mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang start-->
<!--          <img-->
<!--                  src="img/external-coop/stop.png"-->
<!--                  v-if="!checkDeviceInfo"-->
<!--                  class="img-power center"-->
<!--                  @click="clickSendRequestIconServer"-->
<!--          />-->
<!--          <img-->
<!--                  src="img/external-coop/open.png"-->
<!--                  class="img-power center"-->
<!--                  v-if="checkDeviceInfo"-->
<!--                  @click="clickSendRequestIconServer"-->
<!--          />-->
<!--      del #7766 全施設のbackendサーバー停止をユーザが操作可能 王永吉 start/>-->
<!--          <img-->
<!--            src="img/external-coop/stop.png"-->
<!--            class="img-power center"-->
<!--            @click="clickSendRequestIconServer"-->
<!--          />-->
<!--      del #7766 全施設のbackendサーバー停止をユーザが操作可能 王永吉 end/>-->
<!--          mod FNSI-改修内容・エッジをクリックしたときのエッジのコントロールの制御がない。・クラウドの停止処理は廃止。 liang start&ndash;&gt;-->
            <!-- <img
              src="img/external-coop/open.png"
              class="img-power center"
              v-if="checkDeviceInfo&&isNkkStaff"
          /> -->
<!--          mod FNSI-改修内容・エッジをクリックしたときのエッジのコントロールの制御がない。・クラウドの停止処理は廃止。  liang end&ndash;&gt;-->
<!--          mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang end-->
        </div>
        <!-- / Cloud-->
      </div>
      <!-- Connections -->

      <!-- Button Row -->
      <div class="d-flex justify-content-center" style="gap: 10px; align-items: center;">
        <v-ons-button v-show="checkFac&&hasIfEdge&&isNkkStaff&&isMasterUser" class="nik-btn btn3-normal" @click="clickSendRequestIconFacility">
          停止
        </v-ons-button>
        <v-ons-button v-show="!checkFac&&hasIfEdge&&isNkkStaff&&isMasterUser" class="nik-btn btn3-normal" @click="clickSendRequestIconFacility">
          起動
        </v-ons-button>
        <v-ons-button v-if="isMasterUser" class="nik-btn btn3-normal" @click="Processing">
          処理要求
        </v-ons-button>
      </div>
      <!-- Grid -->
      <div class="grid d-flex flex-column flex-1">
          <div
            ref="checklistGrid"
            class="external-coop-direct-grid flex-1"
          ></div>
        <!-- bug:4350,modify by maxueqiang -->
        <!-- v-show="isMasterUser" -->
        <div class="actions d-flex justify-content-space-between">
          <v-ons-button
            class="common-style-cancel-button btn2-cancel pat-btn-margin-right pat-btn-margin-bottom"
            @click="cancel"
          >
            キャンセル
          </v-ons-button>
          <v-ons-button
            class="common-style-ok-button btn1-execute pat-btn-margin-bottom"
            :disabled="!hasChanges"
            @click="save"
          >
            保存
          </v-ons-button>
        </div>
      </div>
      <!-- / Grid -->
    </div>
    <!-- / Main -->

    <!-- Note Popover -->
    <v-ons-popover
      cancelable
      v-model:visible="notePopoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      direction="down up"
      :class="[fontSizeSet, 'note content-popover']"
    >
      <div class="pop-up">
        <div style="overflow: auto">
          <table class="table-status">

            <!-- modify by chamaojia 2024-10-11 [11140] JSON structure change start -->
            <!-- mod #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start -->
            <tbody v-for="arrVal in ifEdgeConnStatus">
              <tr>
                <td class="text header" style="text-align: left" :colspan="arrVal.coopCdArr.length === 0 ? 2 : arrVal.coopCdArr.length + 1">{{arrVal.coopVersion}}連携先情報</td>
              </tr>
              <tr>
                <td>種別</td>
                <td v-if="arrVal.coopCdArr.length === 0"></td>
                <td
                  v-for="(item, index) in arrVal.coopCdArr"
                  :key="index"
                >
                  {{ renderCoop(item.key) }}
                </td>
              </tr>
              <tr>
                <td>状態</td>
                <td v-if="arrVal.coopCdArr.length === 0"></td>
                <td
                  v-for="(item, index) in arrVal.coopCdArr"
                  :key="index"
                >
                  <!--mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start-->
                  <!--{{ renderStatus(item.status) }}-->
                  {{ acceptStatus(item.status) }}
                  <!--mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end-->
                </td>
              </tr>
              <tr>
                <td>最終日時</td>
                <td v-if="arrVal.coopCdArr.length === 0"></td>
                <td
                  v-for="(item, index) in arrVal.coopCdArr"
                  :key="index"
                >
                <!-- #10453 mod 死活監視が動作していない 2024-05-17 卓 start -->
                  {{ formatDateTime(renderMoniTime(item)) }}
                <!-- #10453 mod 死活監視が動作していない 2024-05-17 卓 end -->
                </td>
              </tr>
            </tbody>
            <!-- mod #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end -->
            <!-- modify by chamaojia 2024-10-11 [11140] JSON structure change end -->

          </table>
        </div>
      </div>
    </v-ons-popover>
    <!-- / Note Popover -->

    <!-- Modem Popover -->
    <v-ons-popover
      cancelable
      v-model:visible="modemPopoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      direction="down up"
      :class="[fontSizeSet, 'modem content-popover']"
    >
      <div class="pop-up">
        <div style="overflow: auto">
          <table class="table-status">
            <tbody>
              <tr>
                <!-- #10453 mod 死活監視が動作していない 2024-05-11 卓 start -->
                <td class="text header" :colspan="facilityConnEdge.length === 0 ? 2 : facilityConnEdge.length + 2">連携アプリ情報</td>
                <!-- #10453 mod 死活監視が動作していない 2024-05-11 卓 end -->
              </tr>
              <tr>
                <td>状態</td>
                <td v-if="facilityConnEdge.length === 0"></td>
                <td
                  v-for="(item, index) in facilityConnEdge[0]"
                  :key="index"
                >
                  {{ renderStatus(item.status) }}
                </td>
              </tr>
              <!-- #10453 add 死活監視が動作していない 2024-04-30 卓 start -->
              <tr>
                <td>接続</td>
                <td v-if="facilityConnEdge.length === 0"></td>
                <td
                  v-for="(item, index) in facilityConnEdge[0]"
                  :key="index"
                >
                  {{ renderIfEdgeType(item.key)}}
                </td>
              </tr>
              <!-- #10453 add 死活監視が動作していない 2024-04-30 卓 end -->
              <tr>
                <td>最終日時</td>
                <td v-if="facilityConnEdge.length === 0"></td>
                <td
                  v-for="(item, index) in facilityConnEdge[0]"
                  :key="index"
                >
                  {{ formatDateTime(item.moni_time) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </v-ons-popover>
    <!-- / Modem Popover -->

    <!-- Cloud Popover -->
    <v-ons-popover
      cancelable
      v-model:visible="cloudPopoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      direction="down up"
      :class="[fontSizeSet, 'cloud content-popover']"
    >
    <!-- add 5615 IFエッジコマンド実行 関 start -->
      <!-- mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start -->
      <!--<pop-over
        v-bind="popoverData"
        @popover-close="closePopover"
      />-->

      <!-- mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end -->
    <!-- add 5615 IFエッジコマンド実行 関 end -->
      <div class="pop-up">
        <div>
          <table>
            <tbody>
              <tr>
                <td class="text header" colspan="2">データベース情報</td>
              </tr>
              <tr>
                <td>状態</td>
                <td v-if="getHealthmonServerConn.length === 0"></td>
                <td>
                  {{ renderStatus(getHealthmonServerConn.status) }}
                </td>
              </tr>
              <tr>
                <td>最終日時</td>
                <td v-if="getHealthmonServerConn.length === 0"></td>
                <td>{{ formatDateTime(getHealthmonServerConn.moni_time) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </v-ons-popover>
    <!-- / Cloud Popover -->

    <v-ons-popover
      class="change-status-popover"
      cancelable
      direction="left right"
      v-model:visible="changeStatusPopoverVisible"
      :target="popoverTarget"
      @preshow="popoverPreShow"
      @postshow="changeStatusPopoverShow(); popoverPostShow($event)"
      @posthide="popoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label class="popoverLabel">方向:</label>
          </v-ons-col>
          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="cSDirectionSubmit"
              value="S"
              v-model="changeStatusResult.direction"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="20%" vertical-align="center">
            <label for="cSDirectionSubmit" class="popoverLabel">送信</label>
          </v-ons-col>
          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="cSDirectionReceiving"
              value="R"
              v-model="changeStatusResult.direction"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="20%" vertical-align="center">
            <label for="cSDirectionReceiving" class="popoverLabel"
              >受信</label
            >
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label class="popoverLabel">{{ changeStatusResult.source.label }}</label>
          </v-ons-col>
          <v-ons-col width="70%" vertical-align="center">
            <kendo-multiselect
              :data-source="changeStatusResult.source.data"
              data-text-field="text"
              data-value-field="value"
              v-model="changeStatusResult.source.selected"
            />
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の終了 -->
        <v-ons-row class="condition-row">
          <v-ons-col>
            <div class="popoverLabel" style="text-align: center">↓</div>
          </v-ons-col>
        </v-ons-row>
        <!-- 配信結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label class="popoverLabel">{{ changeStatusResult.dest.label }}</label>
          </v-ons-col>
          <v-ons-col class="ons-col-wrap" width="70%" vertical-align="center">
            <kendo-dropdownlist
              ref="changeStatusDestDropDown"
              :data-source="changeStatusResult.dest.data"
              data-text-field="text"
              data-value-field="value"
              :auto-select-first-on-empty="false"
              v-model="changeStatusResult.dest.selected"
            />
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button
              class="cancel btn2-cancel"
              @click="closeChangeStatusPopover"
            >キャンセル</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button
              class="ok btn3-normal"
              @click="doChangeStatusResult"
            >確定</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>

    <!-- add FNSI-連携情報を追加 李 start -->
    <!-- ConIntelligence Popover -->
    <!--//mod #9523 患者連携情報の表示内容について zrx start -->
    <v-ons-popover
      ref="conIntelligencePopover"
      class="change-status-popover-con"
      cancelable
      animation="none"
      v-model:visible="conIntelligencePopoverVisible"
      :target="popoverTarget"
      :cover-target="false"
      direction="left"
      :class="[fontSizeSet, 'con content-popover']"
      @preshow="popoverPreShow"
      @postshow="conIntelligencePopoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="pop-up-con con-intelligence-popover-body external-coop-con-intel-body">
        <v-ons-list
          :key="'con-intel-acc-list-' + conIntelligenceAccordionTick"
          class="treatment-record-accordion"
        >
          <v-ons-list-item
            v-for="(title, colIdx) in conIntelligenceColumnTitles"
            :key="'con-intel-acc-' + colIdx"
            expandable
          >
            <div class="center">
              <span class="con-intelligence-section-label">{{ title }}</span>
            </div>
            <div class="right">
              <span class="list-item__expand-chevron"></span>
            </div>
            <div class="expandable-content">
              <div
                v-if="conIntelligenceKvRows(colIdx).length"
                class="con-intelligence-expandable-panel"
              >
                <table class="table-status con-intelligence-inner-table">
                  <thead>
                    <tr>
                      <td class="con-intelligence-table-head-cell">項目名</td>
                      <td class="con-intelligence-table-head-cell con-intelligence-table-head-cell--value"></td>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(kv, rowIdx) in conIntelligenceKvRows(colIdx)"
                      :key="'con-intel-r-' + colIdx + '-' + rowIdx"
                    >
                      <td class="con-intelligence-key-cell">{{ kv.key }}</td>
                      <td class="con-intelligence-value-cell">{{ kv.displayValue }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </v-ons-list-item>
        </v-ons-list>
        <!--//mod #9523 患者連携情報の表示内容について zrx end -->
      </div>
    </v-ons-popover>
    <!-- add FNSI-連携情報を追加 李 end -->

    <pop-over
        v-bind="popoverData"
        @popover-close="closePopover"
      @refresh-change="handleRefreshChange"
      />

    <v-ons-dialog
      class="change-status-dialog"
      cancelable
      animation="none"
      v-model:visible="changeStatusDialogVisible"
      @postshow="changeStatusPopoverShow"
    >
      <div style="margin:10px;">
        <v-ons-row class="condition-row">
          <v-ons-col width="30%" vertical-align="center">
            <label class="popoverLabel">方向:</label>
          </v-ons-col>
          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="cSDirectionSubmit"
              value="S"
              v-model="changeStatusResult.direction"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="20%" vertical-align="center">
            <label for="cSDirectionSubmit" class="popoverLabel">送信</label>
          </v-ons-col>
          <v-ons-col width="10%" vertical-align="center">
            <v-ons-checkbox
              input-id="cSDirectionReceiving"
              value="R"
              v-model="changeStatusResult.direction"
            ></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width="20%" vertical-align="center">
            <label for="cSDirectionReceiving" class="popoverLabel"
              >受信</label
            >
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="100%">
            <label class="popoverLabel">{{ changeStatusResult.source.label }}</label>
          </v-ons-col>
          <v-ons-col width="100%">
            <kendo-multiselect
              :data-source="changeStatusResult.source.data"
              data-text-field="text"
              data-value-field="value"
              v-model="changeStatusResult.source.selected"
            />
          </v-ons-col>
        </v-ons-row>
        <!-- 処理結果の終了 -->
        <v-ons-row class="condition-row">
          <v-ons-col>
            <div class="popoverLabel" style="text-align: center">↓</div>
          </v-ons-col>
        </v-ons-row>
        <!-- 配信結果の開始 -->
        <v-ons-row class="condition-row">
          <v-ons-col width="100%">
            <label class="popoverLabel">{{ changeStatusResult.dest.label }}</label>
          </v-ons-col>
          <v-ons-col class="ons-col-wrap" width="100%">
            <kendo-dropdownlist
              ref="changeStatusDestDropDownCon"
              :data-source="changeStatusResult.dest.data"
              data-text-field="text"
              data-value-field="value"
              :auto-select-first-on-empty="false"
              v-model="changeStatusResult.dest.selected"
            />
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row" style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button
              class="cancel btn2-cancel"
              @click="closeChangeStatusPopover"
            >キャンセル</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button
              class="ok btn3-normal"
              @click="doChangeStatusResult"
            >確定</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-dialog>
  </div>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { getViewportWidth, getScopedWindow, resolveRefElement } from "@/functions/common/LayoutMeasureHelper";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { GRID_COLUMNS, COOP_LIST, ANA_RESULT_LIST, COOP_RESULT_LIST } from "./GridColums";
import { GRID_SCHEMA } from "./GridSchema";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import PopoverMixin from "@/components/PopoverMixin";
import PrintMixin from "@/components/PrintMixin";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { getOnsPopoverPartsFromEvent, getOnsPopoverFromEvent } from "@/functions/common/OnsenFunctions";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import { markRaw } from "@/compat/vue/runtime";
// add 5615 IFエッジコマンド実行 関 start
import ExternalSelector from "@/components/common/master-selector/ExternalSelector";
// add 5615 IFエッジコマンド実行 関 end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { sortableCompare } from "@/functions/SortFunctions";
import _ from "@/compat/collections/lodash";
import { customComparator } from "@/utils/util.js";

function createDataSource(options = {}) {
  return new kendo.data.DataSource(options);
}

function readKendoDataSource(source) {
  return source?.read?.();
}

function toKendoDataSourcePlainItem(item) {
  if (item && typeof item.toJSON === "function") {
    return item.toJSON();
  }
  return item;
}

function getKendoDataSourceItems(source) {
  try {
    return Array.from(source?.data?.() || []);
  } catch (_error) {
    return [];
  }
}

function getKendoDataSourcePlainItems(source) {
  return getKendoDataSourceItems(source).map(item => toKendoDataSourcePlainItem(item));
}

function getKendoDataSourceDirtyItems(source) {
  return getKendoDataSourceItems(source).filter(item => item?.dirty);
}

function setKendoDataSourceItems(source, items = []) {
  return source?.data?.(Array.isArray(items) ? items : Array.from(items || []));
}

function hasKendoDataSourceChanges(source) {
  try {
    return !!source?.hasChanges?.();
  } catch (_error) {
    return false;
  }
}

function syncKendoDataSource(source) {
  return source?.sync?.();
}

function getKendoEventContainerElement(event) {
  const container = event?.container;
  if (container?.jquery) {
    return container[0] || null;
  }
  return container || event?.cell || event?.currentTarget?.closest?.("td") || null;
}

function findKendoGridBodyRows(grid) {
  try {
    return Array.from(grid?.tbody?.[0]?.rows || []);
  } catch (_error) {
    return [];
  }
}

function getKendoWidgetDataItems(grid) {
  return getKendoDataSourceItems(grid?.dataSource);
}

function getKendoGridSelectedDataItem(grid) {
  const selected = grid?.select?.();
  const row = selected?.closest?.("tr")?.[0] || selected?.[0]?.closest?.("tr") || selected?.[0] || null;
  return row ? grid?.dataItem?.(row) || null : null;
}

import { getScopedAlertDialogs } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [PopoverMixin, PrintMixin],
  data() {
    return {
      blowTimer: 0,
      age: 0,
      notePopoverVisible: false,
      modemPopoverVisible: false,
      cloudPopoverVisible: false,
      // add FNSI-連携情報を追加 李 start
      conIntelligencePopoverVisible: false,
      //mod #9523 患者連携情報の表示内容について zrx start
      /** 連携情報リスト再マウント用（Onsen 手動折りたたみと Vue :expanded の競合を避ける） */
      conIntelligenceAccordionTick: 0,
      //mod #9523 患者連携情報の表示内容について zrx end
      // add FNSI-連携情報を追加 李 end
      changeStatusPopoverVisible: false,
      popoverTarget: null,
      nowDate: "",
      editingFlg: false,
      lastScrollTop: 0,
      selfScreenName: "",
      scrollable: true,
      isSorted: false,
      isRefreshing: false,
      columns: GRID_COLUMNS,
      schema: GRID_SCHEMA,
      coopList: COOP_LIST,
      anaResults: ANA_RESULT_LIST,
      coopResults: COOP_RESULT_LIST,
      pendingCase: 0,
      errorCase: 0,
      outRegDate: "",
      outAnaDate: "",
      // FNSI- 稼働連携ビューア画面イメージ。 liang start
      RegDate: "",
      baseDate:"",
      opeCd:"",
      // FNSI- 稼働連携ビューア画面イメージ。 liang end
      remindFlg: false,
      hasChanges: false,
      holdFlag: false,
      holdTimeOut: null,
      mouseDownTime: 0,
      changeStatusResult: {
        direction: ["S", "R"],
        source: {
          label: "",
          data: [],
          selected: []
        },
        dest: {
          label: "",
          data: [],
          selected: null
        }
      },
      changeStatusFormDirty: false,
      changeStatusType: null,
      changeStatusDialogVisible: false,
      //Android端末で編集中であることを示すフラグ
      androidFlg: false,
      iosFlg: false,
      // add 5615 IFエッジコマンド実行 関 start
      popoverData: {
        popoverVisible: false,
        popoverDisplayDirection: "bottom",
        popoverTitleHeader: "IFエッジリモートコマンド実行",
        popoverFilterLabel: "",
        popoverFilterDataset: [],
        popoverContentLabel: "コマンド名",
        popoverContentDataset: [],
        popoverSearchQuery: "",
        hasUnregisteredOption: true,
      },
      // add 5615 IFエッジコマンド実行 関 end

      //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
      ifEdgeConnStatus:[],
      //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end
      currentSort: null,
      gridData:null,
      directGridWidget: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      originalDataSource: [],
      windowWidth: getViewportWidth(this.$el || this), // ウィンドウ幅保持変数
      scrollQuerySelector: ".k-grid-content",
      addClassTargetQuerySelector: [".k-auto-scrollable table"],
    };
  },
  // add 5615 IFエッジコマンド実行 関 end
  components: {
    "pop-over": ExternalSelector,
  },
  // add 5615 IFエッジコマンド実行 関 end
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("external-coop", [
      "getExternalCoopList",
      "getHealthmonFacilityConn",
      "getHealthmonServerConn",
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      "getMntIfEdgeConn",
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      "getCloudInfo",
      "getToFacilityCd",
      // add FNSI-連携情報を追加 李 start
      "getConIntelligenceList",
      // add FNSI-連携情報を追加 李 end
      "getToFacilityCd",
      "getCondition",
      // add 5615 IFエッジコマンド実行 関 start
      "getEdgeCommand",
      // add 5615 IFエッジコマンド実行 関 end
      //add 6085 施設がIFエッジある施設であるかの判断 ljx start
      "getHasIfEdge",
      //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    ]),
    ...mapGetters("account-edit", {
      userAccountInfo: "getStateUserAccountInfo"
    }),
    condition: {
      get() {
        return this.getCondition;
      }
    },
    // #10453 mod 死活監視が動作していない 2024-04-30 卓 start
    facilityConnEdge() {
      let list = [];
      let arr = this.getHealthmonFacilityConn;
      for (var val of arr) {
        let facilityConnArr = [];
        /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --start */
        for (var itemKey in val) {
          if (itemKey == "edge") {
            for (var key in val[itemKey]) {
              if (Object.prototype.hasOwnProperty.call(val[itemKey], key) && key != "key" && (key === "edge_b" || key === "edge_m")) {
                val[itemKey][key].key = key;
                facilityConnArr.push(val[itemKey][key]);
              }
            }
          }
        }
        /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --end */
        list.push(facilityConnArr)
      }
      return list;
      //return this.getHealthmonFacilityConn.filter(item => item.key === "edge");
    },
    //  #10453 mod 死活監視が動作していない 2024-04-30 卓 end

    //del #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    // facilityConnNoEdge() {
    //   let list = [];
    //   //mod 9490 2023.8.25 lmf start
    //   //       let arr = this.getHealthmonFacilityConn;
    //   let arr = [];
    //   const facilityCd = this.facilityCd;
    //   ApiHelper.get(`/external_coop_oper_viewer/if_edge_healmon_on/${facilityCd}`,
    //     {
    //       facilityCd: this.facilityCd,
    //     }).then(response => {
    //     if (response.status == 200) {
    //       let healthmonFacilityConn = [];
    //       healthmonFacilityConn.push(response.data && JSON.parse(JSON.stringify(response.data)));
    //       if (healthmonFacilityConn) {
    //         arr = healthmonFacilityConn[0];
    //           let facilityConnArr = [];
    //         for (var key in arr) {
    //           if (arr.hasOwnProperty(key) && key != "key" && key !== "edge") {
    //             arr[key].key = key;
    //             facilityConnArr.push(arr[key]);
    //           }
    //         }
    //         list.push(facilityConnArr)
    //       }
    //     }
    //   });
    //   //mod 9490 2023.8.25 lmf start
    //   return list;
    // },
    //del #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end

    // add FNSI-連携情報を追加 李 start
    conIntelligenceList() {
      return this.getConIntelligenceList;
    },
    //add #9523 患者連携情報の表示内容について zrx start
    /** pat_coop_detail.save_1～10 に対応する見出し（装置設定の空行表示と同様にデータ無しでも行を確保） */
    conIntelligenceColumnTitles() {
      return [
        "連携情報カラム１",
        "連携情報カラム２",
        "連携情報カラム３",
        "連携情報カラム４",
        "連携情報カラム５",
        "連携情報カラム６",
        "連携情報カラム７",
        "連携情報カラム８",
        "連携情報カラム９",
        "連携情報カラム１０"
      ];
    },
    //add #9523 患者連携情報の表示内容について zrx end
    // add 5615 IFエッジコマンド実行 関 start
    EdgeCommandList() {
      return this.getEdgeCommand;
    },
    // add 5615 IFエッジコマンド実行 関 end
    // add FNSI-連携情報を追加 李 end
    isMasterUser() {
      return this.userAccountInfo.userType === 1 ? true : false;
    },
    checkDeviceInfo() {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // if (this.getHealthmonServerConn && this.getHealthmonServerConn.status) {
      //   if (this.getHealthmonServerConn.status.charAt(0) === "0") {
      //     return true;
      //   }
      // }
      if (this.getMntIfEdgeConn) {
        return true;
      }
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      return false;
    },
    // add 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start
    checkSecondConnValid() {
      let facilityConn = this.getHealthmonFacilityConn;

      let moni_time_edge_b = null;
      let moni_time_edge_m = null;
      if(null != facilityConn) {
        for (var val of facilityConn) {
          for (var itemKey in val) {
            if (itemKey === "edge") {
              for (var key in val[itemKey]) {
                if (key === "edge_b") {
                  moni_time_edge_b = val[itemKey][key].moni_time;
                }
                if (key === "edge_m") {
                  moni_time_edge_m = val[itemKey][key].moni_time;
                }
              }
            }
          }
        }
      }

      let serverConn = this.getHealthmonServerConn;
      if (null != serverConn) {
        if (null != serverConn.journal_interval && null !== moni_time_edge_b) {
          var validBDate = dayjs(moni_time_edge_b).add(serverConn.journal_interval, 'seconds');
          if (!validBDate.isAfter(dayjs())) {
            return false;
          }
        }
        if (null != serverConn.main_interval && null != moni_time_edge_m) {
          var validMDate = dayjs(moni_time_edge_m).add(serverConn.main_interval, 'seconds');
          if (!validMDate.isAfter(dayjs())) {
            return false;
          }
        }
      }
      return true;
    },
    // add 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm end
    isNkkStaff() {
      return this.userAccountInfo.facilityCd === "nkknkk";
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    hasIfEdge() {
      return this.getHasIfEdge;
    },
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    checkFac() {
      let flag = false
      let arr = this.getHealthmonFacilityConn;
      if(null != this.getHealthmonFacilityConn){
        for(var val of arr){
          /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --start */
          for (var itemKey in val) {
            if (itemKey == "edge") {
              for (var key in val[itemKey]) {
                if (key === "edge_b") {
                  // mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start
                  // if(val[itemKey][key].status === "01"){
                  //   return true;
                  if(val[itemKey][key].status !== "01"){
                    return false;
                    // mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start
                  }
                }
                // add 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start
                if (key === "edge_m") {
                  if(val[itemKey][key].status !== "01"){
                    return false;
                  }
                }
                // add 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm end
              }
            }
          }
          /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --end */
        }
      }

      // if (
      //   this.getHealthmonFacilityConn &&
      //   // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      //   // this.getHealthmonFacilityConn.find(i => i.key === "ini_dial") &&
      //   //this.getHealthmonFacilityConn.find(i => i.key === "ini_dial").status
      //   this.getHealthmonFacilityConn.find(i => i.key === "edge") &&
      //   this.getHealthmonFacilityConn.find(i => i.key === "edge").status
      //   // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      // ) {
      //   if (
      //     // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      //     // this.getHealthmonFacilityConn
      //     //   .find(i => i.key === "ini_dial")
      //     //   .status.charAt(0) === "0"
      //     this.getHealthmonFacilityConn
      //       .find(i => i.key === "edge")
      //       .status === "01"
      //     // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      //   ) {
      //     return true;
      //   }
      // }
      // mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm start
      // return false;
      return true;
      // mod 11772_11750 【因島】IFEdgeのLANを切断しても連携稼働ビューアで通信エラーとならない zkm end
    },
    selectedFacilityCd() {
      return this.getToFacilityCd != null ? this.getToFacilityCd : this.facilityCd;
    },
    // #10453 add 死活監視が動作していない 2024-05-13 卓 start
    getEdgeState(){
      const arr = this.getHealthmonFacilityConn;
      /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --start */
      for (var val of arr) {
        if (val.edge && val.edge.edge_b && val.edge.edge_b.status)
          return val.edge.edge_b.status;
      }
      /* modify by chamaojia 2024-10-11 [11140] JSON structure change end  --end */
    },
    getEdgeMoniTime(){
      const arr = this.getHealthmonFacilityConn;
      /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --start */
      for (var val of arr) {
        if (val.edge && val.edge.edge_b && val.edge.edge_b.status)
          return val.edge.edge_b.moni_time;
      }
      /* modify by chamaojia 2024-10-11 [11140] JSON structure change end  --end */
    },
    // #10453 add 死活監視が動作していない 2024-05-13 卓 end
    /** 
     * 画面幅に応じてアイコンサイズを計算する処理
     * NOTE: ウィンドウ幅に応じてアイコンサイズをスムーズに変化させます。
     * - 740px以下 → 3.5em固定
     * - 1800px以上 → 10em固定
     * - その間は3.5em～10emで変化
     */
    iconSize() {
      const minWidth = 740;
      const maxWidth = 1800;
      const minSize = 3.5; // em
      const maxSize = 10;  // em
      const ratio = Math.min(Math.max((this.windowWidth - minWidth) / (maxWidth - minWidth), 0), 1);
      return `${(minSize + (maxSize - minSize) * ratio)}em`;
    },
    /**
     * 画面幅に応じて接続線の太さを計算する処理
     * NOTE: ウィンドウ幅に応じて接続線の太さをスムーズに変化させます。
     * - 740px以下 → 0.3em固定
     * - 1800px以上 → 1.5em固定
     * - その間は0.3em～1.5emで変化
     */
    connectionHeight() {
      const minWidth = 740;
      const maxWidth = 1800;
      const minHeight = 0.3;
      const maxHeight = 1.5;
      const ratio = Math.min(Math.max((this.windowWidth - minWidth) / (maxWidth - minWidth), 0), 1);
      return `${(minHeight + (maxHeight - minHeight) * ratio)}em`;
    },
  },
  // add FNSI- refreshメソッドに「$on」を追加 zhuhongrui start
  mounted() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh",this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh",this.refresh);

    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    this.getIfEdgeConnStatus(this.selectedFacilityCd);
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end
    getScopedWindow(this.$el || this)?.addEventListener?.('resize', this.handleResize);
  },
  // add FNSI- refreshメソッドに「$on」を追加 zhuhongrui strat
  methods: {
    getChecklistGridRef() {
      return this.$refs.checklistGrid || null;
    },
    getChecklistGridRootElement() {
      const ref = this.getChecklistGridRef();
      if (ref?.nodeType === 1) {
        return ref;
      }
      return ref?.gridRootEl?.() || ref?.$el || null;
    },
    installDirectGridFacade() {
      const root = this.getChecklistGridRootElement();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridHeaderEl = () => root.querySelector(".k-grid-header") || null;
    },
    normalizeDirectGridColumn(column = {}) {
      const gridColumn = {
        field: column.field,
        title: column.title,
        format: column.format,
        editable: column.editable,
        values: column.values,
        width: column.width,
        validation: column.validation,
        template: column.template,
        attributes: column.attributes ? { ...column.attributes } : undefined,
        hidden: !!column.hidden
      };
      if (["dump", "dumpPath", "inRegDate", "outRegDate", "inAnaDate", "outAnaDate", "opeCd", "retryCnt", "ordNo", "patId", "conIntelligence"].includes(column.field)) {
        gridColumn.hidden = !this.isMasterUser;
      }
      if (column.field === "dump") {
        gridColumn.command = { name: "dumpDetail", text: "詳細", click: event => this.showEditModal(event) };
        gridColumn.attributes = { ...(gridColumn.attributes || {}), "aria-disabled": column };
      } else if (column.field === "dumpPath") {
        gridColumn.command = { text: "編集", click: event => this.showDumpPathEditModal(event) };
      } else if (column.field === "crud") {
        gridColumn.editable = () => this.isMasterUser;
      } else if (column.field === "message") {
        gridColumn.editable = () => this.onClick();
        gridColumn.attributes = { class: "grid-column-message" };
      } else if (column.field === "conIntelligence") {
        gridColumn.attributes = { class: "grid-column-con-intelligence" };
        gridColumn.command = { name: "conIntelligenceDetail", text: "詳細", click: event => this.showConIntelligence(event) };
      } else if (["anaResult", "coopResult", "ordNo", "patId", "direction"].includes(column.field)) {
        gridColumn.attributes = { ...(gridColumn.attributes || {}), class: [gridColumn.attributes?.class, "backgroud-white"].filter(Boolean).join(" ") };
      } else if (column.field === "hospPatId") {
        gridColumn.attributes = { class: "hosp-pat-id-body" };
      }
      Object.keys(gridColumn).forEach(key => {
        if (gridColumn[key] === undefined || gridColumn[key] === null) {
          delete gridColumn[key];
        }
      });
      return gridColumn;
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => this.normalizeDirectGridColumn(column));
    },
    getDirectGridColumnSignature() {
      return JSON.stringify((this.columns || []).map(column => ({
        field: column.field,
        title: column.title,
        width: column.width,
        hidden: !!column.hidden || (["dump", "dumpPath", "inRegDate", "outRegDate", "inAnaDate", "outAnaDate", "opeCd", "retryCnt", "ordNo", "patId", "conIntelligence"].includes(column.field) && !this.isMasterUser),
        editable: typeof column.editable === "function" ? "function" : column.editable,
        values: Array.isArray(column.values) ? column.values.length : 0,
        command: ["dump", "dumpPath", "conIntelligence"].includes(column.field)
      })));
    },
    initDirectGridIfReady() {
      const root = this.getChecklistGridRootElement();
      if (!root || !this.gridData) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridWidget) {
        if (this.directGridColumnSignature !== nextSignature) {
          this.directGridWidget.setOptions({ columns: this.buildDirectGridColumns() });
          this.directGridColumnSignature = nextSignature;
        }
        this.applyDirectGridDataSourceContract();
        this.installDirectGridFacade();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const $root = $(root);
      $root.kendoGrid({
        dataSource: this.gridData,
        columns: this.buildDirectGridColumns(),
        scrollable: {
          virtual: true
        },
        selectable: true,
        editable: true,
        sortable: { compare: this.compareByField },
        resizable: true,
        cellClose: event => this.onCellClose(event),
        save: event => this.onSave(event),
        sort: event => this.handleSortGrid(event),
        dataBound: event => this.onDataBoundKendoGrid(event)
      });
      this.directGridWidget = markRaw($root.data("kendoGrid"));
      this.directGridColumnSignature = nextSignature;
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridDataSourceContract() {
      if (!this.directGridWidget || !this.gridData) {
        return;
      }
      if (this.directGridWidget.dataSource !== this.gridData) {
        this.directGridWidget.setDataSource(this.gridData);
      }
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.directGridWidget?.resize?.(true);
        this.applyDirectGridStyleContract();
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getChecklistGridRootElement();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tbody").forEach(tbody => {
        Array.from(tbody.children || []).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    destroyDirectGrid() {
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      const root = this.getChecklistGridRootElement();
      if (root) {
        root.innerHTML = "";
      }
    },
    getChecklistGridWidget() {
      return this.getChecklistGridRef()?.gridWidget?.() || this.getChecklistGridRef()?.kendoWidget?.() || null;
    },
    formatDateTime(value) {
      if (!value) {
        return "";
      }

      let formatStr;
      if (typeof value === "string") {
        formatStr = value.trim();
        if (formatStr.length > 0) {
          return dayjs(formatStr).format("YYYY/MM/DD HH:mm:ss");
        }
        return formatStr;
      }

      return dayjs(value).format("YYYY/MM/DD HH:mm:ss");
    },
      //add 共通ローダー設定 張岩 start
      // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
      "suspendLoadingScreen",
      "resumeLoadingScreen"
    ]),
    //add 共通ローダー設定 張岩 end
    ...mapActions("multi-modal", ["showExternalCoopModal", "showExternalCoopDumpPathModal", "showExternalCoopMessageModal"]),
    ...mapActions("external-coop", [
      "setToFacilityCd",
      "edit",
      "sendRequestGetEdgeState",
      "sendRequestIconStartStop",
      "updateSysCoopJournal",
      "setEditRecord",
      "searchExternalCoopList",
      // add FNSI-連携情報を追加 李 start
      "searchConIntelligenceState",
      // add FNSI-連携情報を追加 李 end
      // add 5615 IFエッジコマンド実行 関 start
      "sendRequestGetEdgeCommandState",
      // add 5615 IFエッジコマンド実行 関 end
      //add 6085 施設がIFエッジある施設であるかの判断 ljx start
      "sendRequestGetHasIfEdge",
      //add 6085 施設がIFエッジある施設であるかの判断 ljx end
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    /**
     * ConIntelligence popover postshow: clamp off-screen left edge, then reveal.
     * Onsen direction="left" maps to style.right (see ons-popover positions map).
     */
    conIntelligencePopoverPostShow(event) {
      const root = getOnsPopoverFromEvent(event);
      const popoverEl = getOnsPopoverPartsFromEvent(event)?.popover
        || root?.querySelector?.(".popover");
      // Hide the whole popover until position is corrected (avoids flash).
      if (root) {
        root.style.opacity = "0";
      }
      // Shared viewport resize / arrow logic; may set visibility visible.
      popoverPostShow(event);
      if (popoverEl) {
        const margin = 6;
        const rect = popoverEl.getBoundingClientRect();
        if (rect.left < margin) {
          // Hide inner box while adjusting inline right offset.
          popoverEl.style.visibility = "hidden";
          const rightPx = parseFloat(popoverEl.style.right);
          if (popoverEl.style.right !== "" && !Number.isNaN(rightPx)) {
            // Decrease right to shift the popover rightward into the viewport.
            popoverEl.style.right = `${rightPx - (margin - rect.left)}px`;
          }
          popoverEl.style.visibility = "visible";
        }
      }
      if (root) {
        root.style.opacity = "";
      }
    },
    renderCoop(key) {
      const item = this.coopList.find(i => {
        return i.value == key;
      });
      return item ? item.text : key;
    },
    generateDataSource() {
      this.gridData = createDataSource({
        data: this.getExternalCoopList,
        schema: this.schema
      });
      readKendoDataSource(this.gridData);
      this.changeHandler(); // 編集状態をリセット
      this.originalDataSource = [];
      const gridDataList = getKendoDataSourcePlainItems(this.gridData);
      if(gridDataList != null && gridDataList.length > 0){
        this.originalDataSource = _.cloneDeep(gridDataList);
      }
      this.$nextTick(() => this.initDirectGridIfReady());
    },
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    getIfEdgeConnStatus(facilityCd) {
      this.ifEdgeConnStatus = [];
      let arr = [];
      // const facilityCd = this.facilityCd;
      ApiHelper.get(`/external_coop_oper_viewer/if_edge_healmon_on/${facilityCd}`).then(response => {
        if (response.status == 200) {
          let healthmonFacilityConn = [];
          healthmonFacilityConn.push(response.data && JSON.parse(JSON.stringify(response.data)));
          /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --start */
          if (healthmonFacilityConn) {
            arr = healthmonFacilityConn[0];
            for (var itemKey in arr) {
              if (itemKey == "edge") {
                continue;
              }
              let facilityConnArr = []
              for (var key in arr[itemKey]) {
                if (Object.prototype.hasOwnProperty.call(arr[itemKey], key) && key != "key") {
                  arr[itemKey][key].key = key;
                  facilityConnArr.push(arr[itemKey][key]);
                }
              }
              let fcEntity= {};
              fcEntity.coopVersion = itemKey;
              fcEntity.coopCdArr = facilityConnArr;
              this.ifEdgeConnStatus.push(fcEntity)
            }
          }
          /* modify by chamaojia 2024-10-11 [11140] JSON structure change start  --end */
        }
      });
    },
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end
    //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
    renderIfEdgeType(value){
      /* modify by chamaojia 2024-10-11 [11140] Change of header definition in JSON  --start */
      if (value && value === "edge_b") {
        return "業務用";
      }else  if (value && value === "edge_m") {
        return "管理用" ;
      }
      /* modify by chamaojia 2024-10-11 [11140] Change of header definition in JSON  --end */
    },
    //#10453 mod 死活監視が動作していない 2024-04-30 卓 end
    renderStatus(status) {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // if (status && status.charAt(0) === "F") {
      if (status && status === "F1") {
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        return "NG";
      } else if (status && status.charAt(0) === "0") {
        return "OK";
      } else {
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        // return "";
        return "STOP";
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      }
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    acceptStatus(status) {
      // #10453 add 死活監視が動作していない 2024-05-13 卓 start
      if (this.getEdgeState==="F0"||this.getEdgeState==="F1"){
        return "-";
      }
      // #10453 add 死活監視が動作していない 2024-05-13 卓 end
      // 電文種別 ステータス判定
      if (status && status === "F1") {
        return "NG";
      } else if (status && status === "01") {
        // 電文種別のステータスが正常な場合はエッジステータスの判定を実施
        // #10453 mod 死活監視が動作していない 2024-05-13 卓 start
        if (this.getEdgeState === "01") return "OK";  // 正常
        if (this.getEdgeState === "F0") return "-";   // 手動停止
        // const arr = this.getHealthmonFacilityConn;
        // if (arr) {
          // for (var val of arr) {
          //   if (val.edge && (val.edge.status === "01")) return "OK";  // 正常
          //   if (val.edge && (val.edge.status === "F0")) return "-";   // 手動停止
          // }
        // }
        // #10453 mod 死活監視が動作していない 2024-05-13 卓 end
        return "NG";  // 異常
      } else if(!status){
        return "NG";
      } else {
        return "-";
      }
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    // #10453 add 死活監視が動作していない 2024-05-17 卓 start
    renderMoniTime(item) {
      const moni_time = item.moni_time;
      if (this.getEdgeState === "F0" || this.getEdgeState === "F1") {
        return this.getEdgeMoniTime;
      }
      return moni_time;
    },
    // #10453 add 死活監視が動作していない 2024-05-17 卓 end
  async clickSendRequestIconFacility() {
// mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang start
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      if(!this.getMntIfEdgeConn){
          await this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "IFエッジと通信不可なので、実施できません。"
            title: DIALOG_MESSAGES[12000104].title,
            message: messageFormat(DIALOG_MESSAGES[12000104].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          return;
        }
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      if(this.checkFac) {
        const ok = await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000036].title,
          // message: "エッジ側連携処理を停止します。<br>よろしいですか？"
          message: messageFormat(DIALOG_MESSAGES[13000036].message),
           // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        });
        if (!ok) {
          return;
        }else{
          // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
          this.setLoadingScreenMessage("処理中・・・");
          this.setLoadingScreenVisible(true);
          // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
          let params = {
            facility_cd:this.getToFacilityCd,
            type:"command",
            command:"stop",
            dir_path: "/home/ntss/if_edge/conf/"
          }
          // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
          // ApiHelper.post("/external_coop_oper_viewer/start/edge/side/process",params)
          // await this.$ons.notification.confirm({
          await ApiHelper.post("/external_coop_oper_viewer/start/edge/side/process",params)
          this.setLoadingScreenVisible(false);
          await this.$ons.notification.alert({
            // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "エッジ側連携処理完了"
            title: DIALOG_MESSAGES[12000105].title,
            message: messageFormat(DIALOG_MESSAGES[12000105].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      } else {
        const ok = await this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "",
          title: DIALOG_MESSAGES[13000037].title,
          // message: "エッジ側連携処理を開始します。<br>よろしいですか？"
          message: messageFormat(DIALOG_MESSAGES[13000037].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        });
        if (!ok) {
          return;
        }else{
          // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
          this.setLoadingScreenMessage("処理中・・・");
          this.setLoadingScreenVisible(true);
          // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
          let params = {
            facility_cd:this.getToFacilityCd,
            type:"command",
            command:"start",
            dir_path: "/home/ntss/if_edge/conf/"
          }
          // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
          // ApiHelper.post("/external_coop_oper_viewer/start/edge/side/process",params)
          // await this.$ons.notification.confirm({
          await ApiHelper.post("/external_coop_oper_viewer/start/edge/side/process",params)
          this.setLoadingScreenVisible(false);
          await this.$ons.notification.alert({
            // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "エッジ側連携処理完了"
            title: DIALOG_MESSAGES[12000105].title,
            message: messageFormat(DIALOG_MESSAGES[12000105].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
        }
      }
// mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang end
    // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//       if (this.getHealthmonFacilityConn) {
//         const checkStatus = this.getHealthmonFacilityConn.find(
//           i => i.key === "edge"
//         ).status;
//         // const param = {
//         //   facility_cd: this.facilityCd,
//         //   if_edge_no: 1,
//         //   healthmon_facility_conn: {
//         //     edge: {
//         //       status: checkStatus == '01' ? 'F0' : '01',
//         //       type: null,
//         //       moni_time: null
//         //     }
//         //   },
//         //   healthmon_server_conn: null
//         // };
//         // this.sendRequestIconStartStop(param);
//         if (checkStatus && checkStatus === "01") {
//           this.getHealthmonFacilityConn.find(i => i.key === "edge").status =
//             "STOP";
//         } else {
//           this.getHealthmonFacilityConn.find(i => i.key === "edge").status =
//             "01";
//         }
//       }
    // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      await this.sendRequestGetEdgeState({
        facilityCd:this.getToFacilityCd,
      });
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    },
    // del #7766 全施設のbackendサーバー停止をユーザが操作可能 王永吉 start
//     async clickSendRequestIconServer() {
// // mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang start
//        if(this.checkDeviceInfo) {
//         const ok = await this.$ons.notification.confirm({
//           title: "",
//           message: "クラウド側連携処理を停止します。<br>よろしいですか？"
//         });
//         if (!ok) {
//           return;
//         }
//       } else {
//         const ok = await this.$ons.notification.confirm({
//           title: "",
//           message: "クラウド側連携処理を開始します。<br>よろしいですか？"
//         });
//         if (!ok) {
//           return;
//         }
//       }
// // mod FNSI-改修内容日機装ユーザーの場合、機器の操作を可能にする。施設ユーザーの場合、機器の操作を不可にする。 liang end
//       if (this.getHealthmonServerConn) {
//         const checkStatus = this.getHealthmonServerConn.status;
//         const param = {
//           facility_cd: this.facilityCd,
//           if_edge_no: 1,
//           healthmon_server_conn: {
//             ini_dial: {
//               status: checkStatus,
//               type: null,
//               moni_time: null
//             }
//           },
//           healthmon_facility_conn: null
//         };
//         this.sendRequestIconStartStop(param);
// //         mod FNSI-改修内容紫の処理ロジックが、右側が赤なら紫 的なロジックだった場合、消す。liang start
// //         if (checkStatus && checkStatus.charAt(0) === "F") {
// //           this.getHealthmonServerConn.status = "01";
// //         } else {
// //           this.getHealthmonServerConn.status = "F1";
// //         }
// // mod FNSI-改修内容紫の処理ロジックが、右側が赤なら紫 的なロジックだった場合、消す。liang end
//       }
//     },
    // del #7766 全施設のbackendサーバー停止をユーザが操作可能 王永吉 end
    dumpPathHandler({ ctlNo, dumpPath }) {
      let item = getKendoDataSourceItems(this.gridData).find(i => i.ctlNo === ctlNo);
      if (item) {
        item.set("dumpPath", dumpPath);
        const originalItem = this.originalDataSource.find((item) => {
          return item.ctlNo === ctlNo;
        });
        const isEqual = _.isEqualWith(
          originalItem?.dumpPath,
          dumpPath,
          customComparator
        );
        if(isEqual){
          delete item.dirtyFields["dumpPath"];
          const ctlNoColIndex = this.columns.findIndex(item => item.field === "ctlNo");
          const dumpPathColIndex = this.columns.findIndex(item => item.field === "dumpPath");
          const checklistGridRows = findKendoGridBodyRows(this.directGridWidget);
          const row = checklistGridRows.find(item => item.children?.[ctlNoColIndex]?.innerText == ctlNo);
          this.$nextTick(() => {
            row?.children?.[dumpPathColIndex]?.classList?.remove("k-dirty-cell");
          });
          if(Object.keys(item.dirtyFields).length === 0){
            item.set("dirty", false);
            delete item.dirtyFields.dirty;
          }
        }
        this.scheduleDirectGridRowVisual(item);
        this.changeHandler();
      }
    },
    changeHandler() {
      this.hasChanges = hasKendoDataSourceChanges(this.gridData);
    },
    showNotePopover(ev) {
      this.popoverTarget = ev.target;
      this.notePopoverVisible = true;
    },
    showModemPopover(ev) {
      this.popoverTarget = ev.target;
      this.modemPopoverVisible = true;
    },
    showCloudPopover(ev) {
      this.popoverTarget = ev.target;
      this.cloudPopoverVisible = true;
    },
    // add FNSI-連携情報を追加 李 start
    async showConIntelligence(ev) {
      let selectedPatId = null;
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      let coopVersion = null;
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      let externalCoopList = JSON.parse(JSON.stringify(this.getExternalCoopList));
      // 患者番号の取得
      externalCoopList.filter(
        item => {
        if (item.ctlNo == parseInt(ev.currentTarget.closest("tr").firstChild.innerText)) {
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          selectedPatId = item.hospPatId;
          selectedPatId = item.patId;
          coopVersion = "0" + item.coopVersion;
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        }
      });

      await this.searchConIntelligenceState({
        facilityCd: this.selectedFacilityCd,
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        coopVersion: coopVersion,
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        selectedPatId: selectedPatId
      });
      //mod #9523 患者連携情報の表示内容について zrx start
      this.conIntelligenceAccordionTick += 1;
      this.popoverTarget = ev.target;
      this.conIntelligencePopoverVisible = true;
      const ownerWindow = getScopedWindow(this.$el || this);
      this.$nextTick(() => {
        if (!this.expandConIntelligenceAccordionAll()) {
          ownerWindow?.setTimeout?.(() => this.expandConIntelligenceAccordionAll(), 50);
        }
      });
    },
    /**
     * 連携情報 Popover 内の Onsen 手風琴を全展開（Vue :expanded は付けず競合を避ける）
     * @returns {boolean} 対象ノードが見つかったか
     */
    expandConIntelligenceAccordionAll() {
      const pop = this.$refs.conIntelligencePopover;
      const el = pop && (pop.$el || pop);
      if (!el || typeof el.querySelector !== "function") {
        return false;
      }
      const content = el.querySelector(".popover__content") || el;
      if (!content || typeof content.querySelectorAll !== "function") {
        return false;
      }
      const items = content.querySelectorAll("ons-list-item.list-item--expandable");
      if (!items.length) {
        return false;
      }
      items.forEach((node) => {
        try {
          node.expanded = true;
        } catch (e) {
          // noop
        }
      });
      return true;
    },
    /**
     * 連携情報カラム colIdx（0～9）を装置設定と同様「項目名＋値」の行へ展開
     * （従来の Object.values 相当の空文字値は行として出さない）
     */
    conIntelligenceKvRows(colIdx) {
      const list = this.conIntelligenceList;
      if (!Array.isArray(list) || colIdx < 0 || colIdx > 9) {
        return [];
      }
      const obj = list[colIdx];
      if (!obj || typeof obj !== "object" || Array.isArray(obj)) {
        return [];
      }
      return Object.keys(obj)
        .map(key => ({
          key,
          displayValue: this.formatConIntelligenceValue(obj[key])
        }))
        .filter(row => row.displayValue !== "");
    },
    formatConIntelligenceValue(val) {
      if (val === null || val === undefined) {
        return "";
      }
      if (typeof val === "object") {
        try {
          return JSON.stringify(val);
        } catch (e) {
          return String(val);
        }
      }
      const s = String(val);
      return s;
    },
    //mod #9523 患者連携情報の表示内容について zrx end
    // add FNSI-連携情報を追加 李 end
    async save() {
      //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao end
      const dirtyItems = getKendoDataSourceDirtyItems(this.gridData)
        .map(d => toKendoDataSourcePlainItem(d));

      if (dirtyItems.length === 0) {
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao start
        this.setLoadingScreenVisible(false);
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao end
        return;
      }

      let anaCheck = false;
      let coopCheck = false;
      if (dirtyItems) {
        dirtyItems.forEach(item => {
          const original = item.originalStates;
          if (item.direction == "R") {
            if (item.anaResult == "0" && original.anaResult != "0") {
              anaCheck = true;
            }
          } else if (item.direction == "S") {
            if (item.anaResult == "0" && original.anaResult != "0") {
              anaCheck = true;
            }
            if (item.coopResult == "0" && original.coopResult != "0") {
              coopCheck = true;
            }
          }
        });
      }
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      // const anaQuestion = "再処理しますか？";
      const anaQuestion = messageFormat(DIALOG_MESSAGES[13000038].message);
      if (anaCheck) {
        const ok = await this.$ons.notification.confirm({
          // title: "",
          title: DIALOG_MESSAGES[13000038].title,
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          message: anaQuestion
        });

        if (!ok) {
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao start
        this.setLoadingScreenVisible(false);
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao end
          return;
        }
      }
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      // const coopQuestion = "再送信しますか？";
      const coopQuestion = messageFormat(DIALOG_MESSAGES[13000039].message);
      if (coopCheck) {
        const ok = await this.$ons.notification.confirm({
          // title: "",
          title: DIALOG_MESSAGES[13000039].title,
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          message: coopQuestion
        });

        if (!ok) {
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao start
        this.setLoadingScreenVisible(false);
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao end
          return;
        }
      }

      try {
        // add FutreNetWeb+SI課題管理No6105 趙 start
        try {
        // add FutreNetWeb+SI課題管理No6105 趙 end
          const params = {updateList: dirtyItems};
          await this.updateSysCoopJournal(params);
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // this.$ons.notification.alert(`データ更新が完了しました`, {
          //   title: "更新完了"
          // });
          this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00100007'].message), {
            title: DIALOG_MESSAGES['00100007'].title
          });
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          syncKendoDataSource(this.gridData);
          EventBus.$emit("callSearch");
          this.hasChanges = false;
        // add FutreNetWeb+SI課題管理No6105 趙 start
        } catch (RestClientException) {
          getErrorMessage('ExternalCoopComponent.vue', 'save', 'API呼び出しに失敗しました。');
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // this.$ons.notification.alert("API呼び出しに失敗しました。", {
          //   title: "内部エラー"
          // });
          this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200025'].message), {
            title: DIALOG_MESSAGES['00200025'].title
          });
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        }
        // add FutreNetWeb+SI課題管理No6105 趙 end
      }catch (err) {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('ExternalCoopComponent.vue', 'save', 'システムエラーが発生しました');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("システムエラーが発生しました。", {
        //   title: "エラー"
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
          title: DIALOG_MESSAGES['00200002'].title
        });
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao start
        this.setLoadingScreenVisible(false);
        //add 8369外部連携稼働ビューアで保存押下後のローダーが表示されない zhao end
    },
    cancel() {
      if (hasKendoDataSourceChanges(this.gridData)) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "変更をキャンセルしますか?",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: ok => {
            if (ok) {
              this.isSorted = false;
              readKendoDataSource(this.gridData);
              this.hasChanges = false;
            }
          }
        });
      }
    },
    // add FNSI- 自動更新の機能を追加。 liang start
    async AutoUpdate(event){
      //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // NOTE: 破棄確認をスキップ
      await this.refresh(false);
      //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      if (event.target.checked) {
        // NOTE: 自動更新時の注意喚起メッセージ表示
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES["12000350"].title,
          message: messageFormat(DIALOG_MESSAGES["12000350"].message),
        });
        //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        if (this.blowTimer > 0) {
          clearTimeout(this.blowTimer);
        }
        //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        this.blowTimer = setInterval(() => {
          if (this.hasChanges == false) {
            this.refresh();
          }
        }, 30000);
      } else {
        clearTimeout(this.blowTimer);
        this.blowTimer = 0;
      }
    },
    // add FNSI- 自動更新の機能を追加。 liang end

    async refresh(isConfirmSkip = true) {
      if (this.isRefreshing) {
        return;
      }
      if (
        this.selfScreenName === this.$route.name &&
        !this.hasVisibleAlertDialog()) {
        this.isRefreshing = true;
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        try {
          await this.$nextTick();
          await new Promise(resolve => setTimeout(resolve, 0));
          await this.sendRequestGetEdgeState({
            facilityCd:this.getToFacilityCd,
          });

          //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
          this.getIfEdgeConnStatus(this.getToFacilityCd);
          //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end

          // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
          if (isConfirmSkip && hasKendoDataSourceChanges(this.gridData)) {
            this.suspendLoadingScreen();
            let ok;
            try {
              ok = await this.$ons.notification.confirm({
                // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
                // title: "内容破棄",
                title: DIALOG_MESSAGES[13000004].title,
                // message: "編集内容が破棄されます。</br>よろしいですか？",
                message: messageFormat(DIALOG_MESSAGES[13000004].message),
                // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
              });
            } finally {
              this.resumeLoadingScreen();
            }

            if (!ok) {
              return;
            }
          }

          var facilityCdmain = this.facilityCd
          if(this.getToFacilityCd !=null && this.getToFacilityCd !="" && this.getToFacilityCd != undefined){
            facilityCdmain = this.getToFacilityCd;
          }
          await EventBus.$emitAsync("callSearch");
          await this.sendRequestGetEdgeState({
            facilityCd:facilityCdmain,
          });
          this.nowDate = dayjs(new Date()).format("YYYY/MM/DD HH:mm:ss");

          this.isSorted = false;
          this.hasChanges = false;
        } finally {
          this.setLoadingScreenVisible(false);
          this.isRefreshing = false;
        }
      }
    },
    //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    async reloadFun(){
      await this.refresh();
      if(this.blowTimer>0){
        clearTimeout(this.blowTimer);
        this.blowTimer = setInterval(() => {
          if(this.hasChanges == false){
            this.refresh();
          }
        }, 30000);
      }
    },
    //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    updateEditRecord(e) {
      const row = e.currentTarget?.closest?.("tr");
      const selectedRowItem = row
        ? this.directGridWidget?.dataItem?.(row)
        : null;
      if (selectedRowItem) {
        this.setEditRecord(selectedRowItem);
      }
    },
    showEditModal(e) {
      this.updateEditRecord(e);
      this.showExternalCoopModal();
    },
    showDumpPathEditModal(e) {
      this.updateEditRecord(e);
      this.showExternalCoopDumpPathModal();
    },
    onClick() {
      const checklistGrid = this.getChecklistGridWidget();
      const selectedRowData = getKendoGridSelectedDataItem(checklistGrid);
      this.showExternalCoopMessageModal();
      this.setEditRecord(selectedRowData);
    },
    checkDirection(e) {
      if (this.isMasterUser && (e.direction == "S")) {
        return true;
      }

      return false;
    },
    onCellClose(event) {
      this.hasChanges = hasKendoDataSourceChanges(this.gridData);
      this.$nextTick(() => {
        if (event?.model) {
          this.applyDirectGridRowVisual(event.model);
        } else {
          this.refreshAllDirectGridEditVisuals();
        }
      });
    },
    isDataItemDirty(dataItem) {
      if (!dataItem) {
        return false;
      }
      if (dataItem.dirty) {
        return true;
      }
      if (!dataItem.dirtyFields) {
        return false;
      }
      return Object.keys(dataItem.dirtyFields).some(
        field => field !== "dirty" && dataItem.dirtyFields[field]
      );
    },
    findDirectGridCellForField(row, field) {
      const cells = Array.from(row?.children || []);
      if (!cells.length || field == null || field === "") {
        return null;
      }
      const fieldText = String(field);
      const byDataField = cells.find(cell => {
        const dataField = cell?.getAttribute?.("data-field") || cell?.dataset?.field || "";
        return String(dataField) === fieldText;
      });
      if (byDataField) {
        return byDataField;
      }
      const root = this.getChecklistGridRootElement();
      const headerCells = Array.from(
        root?.querySelectorAll?.(".k-grid-header th[data-field], .k-grid-header .k-table-th[data-field]") || []
      ).filter(cell => cell?.style?.display !== "none" && cell?.getAttribute?.("aria-hidden") !== "true");
      const headerIndex = headerCells.findIndex(cell => {
        const dataField = cell?.getAttribute?.("data-field") || cell?.dataset?.field || "";
        return String(dataField) === fieldText;
      });
      if (headerIndex >= 0 && cells[headerIndex]) {
        return cells[headerIndex];
      }
      const visibleColumns = (this.directGridWidget?.columns || []).filter(column => column?.hidden !== true);
      const index = visibleColumns.findIndex(column => String(column?.field) === fieldText);
      return index >= 0 ? (cells[index] || null) : null;
    },
    markDirectGridDirtyCell(cell) {
      if (!cell?.classList) {
        return;
      }
      cell.classList.add("k-dirty-cell");
      if (cell.querySelector(".k-dirty")) {
        return;
      }
      const marker = document.createElement("span");
      marker.className = "k-dirty";
      cell.insertBefore(marker, cell.firstChild || null);
    },
    syncDirectGridDirtyCellMarkersForRow(row, dataItem) {
      if (!row) {
        return;
      }
      row.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
      row.querySelectorAll("td.k-dirty-cell, .k-table-td.k-dirty-cell")
        .forEach(cell => cell.classList.remove("k-dirty-cell"));
      if (!this.isDataItemDirty(dataItem)) {
        return;
      }
      Object.keys(dataItem.dirtyFields || {}).forEach(field => {
        if (!dataItem.dirtyFields[field] || field === "dirty") {
          return;
        }
        const cell = this.findDirectGridCellForField(row, field);
        if (cell) {
          this.markDirectGridDirtyCell(cell);
        }
      });
    },
    applyDirectGridRowVisual(model) {
      if (!model) {
        return;
      }
      this.getDirectGridRowsByModel(model).forEach(row => {
        const dataItem = this.directGridWidget?.dataItem?.(row) || model;
        this.syncDirectGridDirtyCellMarkersForRow(row, dataItem);
        this.changeRowColor(row.children, null, row);
      });
    },
    refreshAllDirectGridEditVisuals() {
      findKendoGridBodyRows(this.directGridWidget).forEach(row => {
        const dataItem = this.directGridWidget?.dataItem?.(row);
        this.syncDirectGridDirtyCellMarkersForRow(row, dataItem);
        this.changeRowColor(row.children, null, row);
      });
    },
    scheduleDirectGridRowVisual(model) {
      this.$nextTick(() => this.applyDirectGridRowVisual(model));
    },
    changeRowColor(currentTrc, edited, row) {
      const addClass = "edited-bgColor";
      row?.classList?.remove(addClass);
      const dataItem = row ? this.directGridWidget?.dataItem?.(row) : null;
      if (this.isDataItemDirty(dataItem)) {
        row?.classList?.add(addClass);
        return;
      }
      let edit = false;
      for (let clCount = 1; clCount < currentTrc.length; clCount++) {
        edit = this.isEditRow(currentTrc[clCount]);
        if (edit) {
          row?.classList?.add(addClass);
          return;
        }
      }
    },
    isEditRow(currentTd) {
      return currentTd.classList.contains("k-dirty-cell");
    },
    getDirectGridRowsByUid(uid) {
      if (!uid) {
        return [];
      }
      return findKendoGridBodyRows(this.directGridWidget).filter(
        row => row.getAttribute("data-uid") === uid
      );
    },
    getDirectGridRowsByModel(model) {
      if (model?.uid) {
        return this.getDirectGridRowsByUid(model.uid);
      }
      const ctlNo = model?.ctlNo;
      if (ctlNo == null) {
        return [];
      }
      const ctlNoColIndex = this.columns.findIndex(item => item.field === "ctlNo");
      return findKendoGridBodyRows(this.directGridWidget).filter(row => row.children?.[ctlNoColIndex]?.innerText == ctlNo);
    },
    onSave(e) {
      const { ctlNo } = e.model;
      const originalItem = this.originalDataSource.find((item) => {
        return item.ctlNo === ctlNo;
      });
      const editField = Object.keys(e.values)[0];
      const editedValue = e.values[editField];
      const isEqual = _.isEqualWith(
        originalItem?.[editField],
        editedValue,
        customComparator
      );
      if (isEqual){
        delete e.model.dirtyFields[editField];
        this.$nextTick(() => {
          getKendoEventContainerElement(e)?.classList?.remove("k-dirty-cell");
        });
        if (Object.keys(e.model.dirtyFields).length === 0) {
          e.model.set("dirty", false);
          delete e.model.dirtyFields.dirty;
        }
      }
      this.scheduleDirectGridRowVisual(e.model);
    },
    handleSortGrid(e) {
      if (["coopResult", "anaResult"].includes(e.sort.field) && this.holdFlag) {
        e.preventDefault();
        this.holdFlag = false;
      }
      this.currentSort = e.sort;
    },
    onDataBoundKendoGrid(e) {
      this.applyDirectGridStyleContract();
      const ctlNoColIndex = e.sender.columns.findIndex(item => item.field === "ctlNo");
      const dumpColIndex = e.sender.columns.findIndex(item => item.field === "dump");
      const dumpPathColIndex = e.sender.columns.findIndex(item => item.field === "dumpPath");
      const gridRowData = findKendoGridBodyRows(e.sender);
      const dataItems = getKendoWidgetDataItems(e.sender);
      gridRowData.forEach((row) => {
        const ctlNo = row.cells?.[ctlNoColIndex]?.innerText;
        const originalItem = dataItems.find((item) => {
          return item.ctlNo == ctlNo;
        });
        if (!originalItem) {
          return;
        }
        if(originalItem.dump === null){
          const dumpButton = row.cells?.[dumpColIndex]?.children?.[0];
          if(dumpButton && !dumpButton.classList.contains("visibility-hidden")){
            dumpButton.classList.add("visibility-hidden");
          }
        }
        if(originalItem.dumpPath === null){
          const dumpPathButton = row.cells?.[dumpPathColIndex]?.children?.[0];
          if(dumpPathButton && !dumpPathButton.classList.contains("visibility-hidden")){
            dumpPathButton.classList.add("visibility-hidden");
          }
        }
      });
      this.$nextTick(() => this.refreshAllDirectGridEditVisuals());
    },
    setMouseEvent() {
      const $this = this;
      const gridHeaderRoot = this.$refs.checklistGrid?.gridHeaderEl?.() || this.$refs.checklistGrid?.gridRootEl?.() || resolveRefElement(this, "checklistGrid") || this.$el || null;
      const coopResultElem = gridHeaderRoot?.querySelector?.('th[data-field="coopResult"]');
      const anaResultElem = gridHeaderRoot?.querySelector?.('th[data-field="anaResult"]');
      const ownerWindow = getScopedWindow(this.$el || this);
      const mouseDownFunc = (e) => {
        $this.mouseDownTime = new Date().getTime();

        $this.holdTimeOut = ownerWindow?.setTimeout?.(() => {
          const currentTime = new Date().getTime();

          if (currentTime - $this.mouseDownTime > 500) {
            $this.holdFlag = true;
            $this.initChangeStatusPopover(e.target.textContent);
            if (this.androidFlg || this.iosFlg) {
              $this.changeStatusDialogVisible = true;
            } else {
              $this.popoverTarget = e.target;
              $this.changeStatusPopoverVisible = true;
            }
          }
        }, 500);
      };
      const mouseUpFunc = () => ownerWindow?.clearTimeout?.($this.holdTimeOut);

      //mod #9523 患者連携情報の表示内容について zrx start
      const bindHeaderHold = (el) => {
        if (!el) {
          return;
        }
        if (el.onmousedown === null) {
          el.onmousedown = mouseDownFunc;
          el.addEventListener("touchstart", mouseDownFunc);
        }
        if (el.onmouseup === null) {
          el.onmouseup = mouseUpFunc;
          el.addEventListener("touchend", mouseUpFunc);
        }
      };

      bindHeaderHold(coopResultElem);
      bindHeaderHold(anaResultElem);
      //mod #9523 患者連携情報の表示内容について zrx end
    },
    changeStatusPopoverShow() {
      getScopedWindow(this.$el || this)?.clearTimeout?.(this.holdTimeOut);
      this.holdFlag = false;
      this.$nextTick(() => this.clearChangeStatusDestDropDownAutoPick());
    },
    clearChangeStatusDestDropDownAutoPick() {
      const selected = this.changeStatusResult?.dest?.selected;
      if (selected !== undefined && selected !== null && selected !== "") {
        return;
      }
      const refs = [
        this.$refs.changeStatusDestDropDown,
        this.$refs.changeStatusDestDropDownCon
      ];
      refs.forEach((ddl) => {
        if (!ddl?.widget) {
          return;
        }
        const items = typeof ddl.resolveDataItems === "function"
          ? ddl.resolveDataItems()
          : (ddl.widget.dataItems?.() || []);
        if (!items.length) {
          return;
        }
        const field = ddl.dataValueField || "value";
        const firstItem = items[0];
        const firstValue = firstItem && typeof firstItem === "object"
          ? firstItem[field]
          : firstItem;
        const current = ddl.widget.value?.();
        if (current === undefined || current === null || current === "") {
          return;
        }
        if (current === firstValue || String(current) === String(firstValue)) {
          ddl.widget.value(null);
          if (ddl.widget.vm) {
            ddl.widget.vm.value = null;
          }
          ddl.lastValue = null;
          ddl.syncSenderState?.(null, ddl.widget);
          this.changeStatusResult.dest.selected = null;
        }
      });
    },
    initChangeStatusPopover(type) {
      this.changeStatusFormDirty = false;

      if (type === "通信結果") {
        this.changeStatusType = "coopResult";
        this.changeStatusResult.source = {
          label: "通信ステータス元",
          data: this.coopResults.filter(item1 => getKendoDataSourceItems(this.gridData)
            .map(item2 => item2.coopResult)
            .includes(item1.value)
          ),
          selected: []
        };
        this.changeStatusResult.dest = {
          label: "通信ステータス先",
          data: this.coopResults,
          selected: null
        };
      } else {
        this.changeStatusType = "anaResult";
        this.changeStatusResult.source = {
          label: "交換ステータス元",
          data: this.anaResults.filter(item1 => getKendoDataSourceItems(this.gridData)
            .map(item2 => item2.anaResult)
            .includes(item1.value)
          ),
          selected: []
        };
        this.changeStatusResult.dest = {
          label: "交換ステータス先",
          data: this.anaResults,
          selected: null
        };
      }
    },
    closeChangeStatusPopover() {
      if (this.androidFlg || this.iosFlg) {
        this.changeStatusDialogVisible = false;
      } else {
        this.popoverTarget = null;
        this.changeStatusPopoverVisible = false;
      }
    },
    doChangeStatusResult() {
      // delete start #9516共通ローダが実装されていない。
      // this.getExternalCoopList.map(item => item.ctlNo).forEach(ctlNo => {
      //   const dataItem = this.gridDataSource.get(ctlNo);
      //   if (
      //     this.changeStatusResult.direction.includes(dataItem.direction)
      //     && this.changeStatusResult.source.selected.includes(
      //       dataItem[this.changeStatusType]
      //     )
      //   ) {
      //     dataItem.set(this.changeStatusType, this.changeStatusResult.dest.selected);
      //   }
      // });
      // delete end #9516共通ローダが実装されていない。
      // add start #9516共通ローダが実装されていない。
      const tempList = _.cloneDeep(getKendoDataSourcePlainItems(this.gridData));
      tempList.forEach((item) => {
        if (this.changeStatusResult.direction.includes(item.direction)
          && this.changeStatusResult.source.selected.includes(item[this.changeStatusType])
        ) {
          item[this.changeStatusType] = this.changeStatusResult.dest.selected;
          item.dirty = true;
          item.dirtyFields[this.changeStatusType] = true;
        }
      });
      setKendoDataSourceItems(this.gridData, tempList);
      // add end #9516共通ローダが実装されていない。
      this.onCellClose();
      this.closeChangeStatusPopover();
    },
    // add  #5984 連携稼働ビューア コンテンツを追加する 孟堅 start　
    requestrReportParams(param) {
      // 機能コード判定
      var fromDateTemp;
      var toDateTemp;
      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      // if((this.getCondition==null || this.getCondition.FromBaseDate==null ||this.getCondition.FromBaseDate=="")&&(this.getCondition==null ||this.getCondition.toBaseDate==null ||this.getCondition.toBaseDate=="")){
      //   fromDateTemp=dayjs(Date.now()).format("YYYYMMDD");
      //   toDateTemp=dayjs(Date.now()).format("YYYYMMDD");
      // }else{
      //   if(this.getCondition!=null&&this.getCondition.FromBaseDate!=null&&this.getCondition.FromBaseDate!=""){
      //     fromDateTemp=dayjs(this.getCondition.FromBaseDate).format("YYYYMMDD");
      //   }else{
      //     fromDateTemp="";
      //   }
      //
      //   if(this.getCondition!=null&&this.getCondition.toBaseDate!=null&&this.getCondition.toBaseDate!=""){
      //     toDateTemp=dayjs(this.getCondition.toBaseDate).format("YYYYMMDD")
      //   }else{
      //     toDateTemp="";
      //   }
      // }
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // if(this.getCondition!=null){
      //   if(this.getCondition.baseDate.from.date != null) {
      //     fromDateTemp = this.getCondition.baseDate.from.date;
      //   }
      //   else if(this.getCondition.regDate.from.date != null) {
      //     fromDateTemp = this.getCondition.regDate.from.date;
      //   }
      //   else if(this.getCondition.date.from.date != null) {
      //     fromDateTemp = this.getCondition.date.from.date;
      //   }
      //   else{
      //     fromDateTemp = "";
      //   }
      //   if(this.getCondition.baseDate.to.date != null) {
      //     toDateTemp = this.getCondition.baseDate.to.date;
      //   }
      //   else if(this.getCondition.regDate.to.date != null) {
      //     toDateTemp = this.getCondition.regDate.to.date;
      //   }
      //   else if(this.getCondition.date.to.date != null) {
      //     toDateTemp = this.getCondition.date.to.date;
      //   }
      //   else{
      //     fromDateTemp = dayjs(Date.now()).format("YYYYMMDD");
      //     toDateTemp = dayjs(Date.now()).format("YYYYMMDD");
      //   }
      // }
      // else{
      //   fromDateTemp = "";
      //   toDateTemp = "";
      // }
      if(this.getCondition!=null){
        if(this.getCondition.baseDate.from.date != null) {
          fromDateTemp = dayjs(this.getCondition.baseDate.from.date).format("YYYYMMDD");
        }
        else if(this.getCondition.regDate.from.date != null) {
          fromDateTemp = dayjs(this.getCondition.regDate.from.date).format("YYYYMMDD");
        }
        else if(this.getCondition.date.from.date != null) {
          fromDateTemp = dayjs(this.getCondition.date.from.date).format("YYYYMMDD");
        }
        if(this.getCondition.baseDate.to.date != null) {
          toDateTemp = dayjs(this.getCondition.baseDate.to.date).format("YYYYMMDD");
        }
        else if(this.getCondition.regDate.to.date != null) {
          toDateTemp = dayjs(this.getCondition.regDate.to.date).format("YYYYMMDD");
        }
        else if(this.getCondition.date.to.date != null) {
          toDateTemp = dayjs(this.getCondition.date.to.date).format("YYYYMMDD");
        }
      }
      if(fromDateTemp == null && toDateTemp == null){
        fromDateTemp = dayjs(Date.now()).format("YYYYMMDD");
        toDateTemp = dayjs(Date.now()).format("YYYYMMDD");
      } else if(fromDateTemp == null){
        fromDateTemp = toDateTemp;
      } else if(toDateTemp == null){
        toDateTemp = fromDateTemp;
      }
      // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        // 印刷パラメータを応答
        const param1 = {
          facilityCd: this.selectedFacilityCd,
          functionCd:"03101",
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          // date:this.getCondition!=null&&this.getCondition.FromBaseDate!=null&&this.getCondition.FromBaseDate!=""?dayjs(this.getCondition.FromBaseDate).format("YYYYMMDD"):dayjs(Date.now()).format("YYYYMMDD"),
          // fromDate: fromDateTemp==null&&fromDateTemp==""?"":fromDateTemp,
          // toDate: toDateTemp==null&&toDateTemp==""?"":toDateTemp,
          date:fromDateTemp,
          fromDate: fromDateTemp,
          toDate: toDateTemp,
          // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
          // mod #11256 機能帳票の印刷情報対応① limingzhe start
          //patIds:Array.from(new Set(this.gridDataSource.data().map(({ patId }) => patId))),
          patIds:Array.from(new Set(getKendoDataSourceItems(this.gridData).filter(item=>item.patId != "0" && item.patId != "").map(({ patId }) => patId))),
          // mod #11256 機能帳票の印刷情報対応① limingzhe end
          examineCoopOrdNo:Array.from(new Set(getKendoDataSourceItems(this.gridData).filter(item=>item.coopCd=="exam_rst"||item.coopCd=="exam_ord").map(({ coopOrdNo }) => coopOrdNo))),  // exam_rst :検査結果   exam_ord: 检查依赖
          angiographyCoopOrdNo:Array.from(new Set(getKendoDataSourceItems(this.gridData).filter(item=>item.coopCd=="rad_ord").map(({ coopOrdNo }) => coopOrdNo))),// rad_ord : 放射線依頼
          coopOrdNo:Array.from(new Set(getKendoDataSourceItems(this.gridData).filter(item=>item!="exam_rst"&&item.coopCd!="rad_ord"&&item.coopCd!="exam_ord").map(({ coopOrdNo }) => coopOrdNo))),
        };
        EventBus.$emit("sendReportParams", param1);
      }
    },
    // add  #5984 連携稼働ビューア コンテンツを追加する 孟堅 end
    // add 5615 IFエッジコマンド実行 関 start
    Processing() {
      this.popoverData.popoverVisible = true;
    },
    closePopover() {
        this.popoverData.popoverVisible = false;
      },
    // add 5615 IFエッジコマンド実行 関 end
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    async handleRefreshChange() {
      await this.sendRequestGetEdgeState({
        facilityCd:this.getToFacilityCd,
      });
    },
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a 
     * @param {*} b 
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;
      // nkknkk施設でサインインの場合、顧客施設を表示の際は患者名はマスクされた値でソート
      let opsions = {};
      if (this.isNkkStaff && this.selectedFacilityCd !== "nkknkk" &&
          this.currentSort.field === "patName") {
        opsions.notUseSortKeyMap = true;
      }
      // 共通関数でソート      
      return sortableCompare(a, b, this.currentSort.field, true, opsions);
    },
    /* 現在のブラウザのウィンドウ幅 */
    handleResize() {
      this.windowWidth = getViewportWidth(this.$el || this);
    },
    hasVisibleAlertDialog() {
      return getScopedAlertDialogs(this.$el || this).some((dialog) => {
        if (!dialog) {
          return false;
        }
        if (dialog.visible === true || dialog.hasAttribute?.("visible")) {
          return true;
        }
        const computedStyle = getScopedWindow(this.$el || this)?.getComputedStyle?.(dialog);
        if (
          !computedStyle ||
          computedStyle.display === "none" ||
          computedStyle.visibility === "hidden" ||
          Number(computedStyle.opacity) === 0
        ) {
          return false;
        }
        const rect = dialog.getBoundingClientRect?.();
        return !!rect && rect.width > 0 && rect.height > 0;
      });
    },
  },
  watch: {
    // 編集状態監視
    hasChanges(newVal) {
      // NOTE: 編集状態をヘッダへ伝播させる
      EventBus.$emit("hasChangesUpdated", newVal);
    }
  },
  updated() {
    // mod bug 8342 修正 chen Start
    // if (this.isMasterUser) {
    //   this.setMouseEvent();
    // }
    this.setMouseEvent();
    // mod bug 8342 修正 chen end
  },
  async created() {
    //add 共通ローダー設定 張岩 start
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    //add 共通ローダー設定 張岩 end
    // add 性能改善メモリ不足 shan start
    EventBus.$off("dumpPath-event", this.dumpPathHandler);
    EventBus.$off("requestReportParams", this.requestrReportParams);

    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    EventBus.$off("IfEdgeConnStatus", this.getIfEdgeConnStatus);
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end
    EventBus.$off("generateDataSource", this.generateDataSource);
    EventBus.$on("generateDataSource", this.generateDataSource);

    // add 性能改善メモリ不足 shan end
    EventBus.$on("dumpPath-event", this.dumpPathHandler);
    EventBus.$on("requestReportParams", this.requestrReportParams);

    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    EventBus.$on("IfEdgeConnStatus", this.getIfEdgeConnStatus);
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end

    this.selfScreenName = this.$route.name;
    this.nowDate = dayjs(new Date()).format("YYYY/MM/DD HH:mm:ss");
    // 端末判別
    const ua = getScopedWindow(this.$el || this)?.navigator?.userAgent || "";
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }

    await this.sendRequestGetEdgeState({
      facilityCd: this.selectedFacilityCd
    });
    await this.searchExternalCoopList({
      facilityCd: this.selectedFacilityCd,
      param: this.condition
    });
    //add 共通ローダー設定 張岩 start
    this.setLoadingScreenVisible(false);
    //add 共通ローダー設定 張岩 end
    // add 5615 IFエッジコマンド実行 関 start
    await this.sendRequestGetEdgeCommandState();
    // add 5615 IFエッジコマンド実行 関 end
    //add 6085 施設がIFエッジある施設であるかの判断 ljx start
    await this.sendRequestGetHasIfEdge({
      facilityCd:this.selectedFacilityCd,
    });
    //add 6085 施設がIFエッジある施設であるかの判断 ljx end
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
    EventBus.$off("dumpPath-event", this.dumpPathHandler);
    EventBus.$off("refresh",this.refresh);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);

    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi start
    EventBus.$off("IfEdgeConnStatus", this.getIfEdgeConnStatus);
    //add #9490 電子カルテアイコンの連携先情報について 20240117 zhaoqi end
    EventBus.$off("generateDataSource", this.generateDataSource);

    //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    if(this.blowTimer >0){
      clearTimeout(this.blowTimer);
    }
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    //add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    getScopedWindow(this.$el || this)?.removeEventListener?.('resize', this.handleResize);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style>
/* add #9523 患者連携情報の表示内容について zrx start */
/* 連携情報 Popover：v-ons-popover がポータル表示のため scoped 外でキー／値列を白に固定 */
.pop-up-con.con-intelligence-popover-body table tr td.con-intelligence-key-cell,
.pop-up-con.con-intelligence-popover-body table tr td.con-intelligence-value-cell {
  background-color: #ffffff !important;
  color: #333333 !important;
  text-align: left !important;
}
.pop-up-con.con-intelligence-popover-body table td.con-intelligence-section-head {
  background-color: #333333 !important;
  color: #ffffff !important;
}
.pop-up-con.con-intelligence-popover-body table thead tr td.con-intelligence-table-head-cell {
  background-color: #333333 !important;
  color: #ffffff !important;
  text-align: left !important;
}
/*
 * 連携情報 Popover：vue-onsenui の portal で ons-popover が document.body 直下へ移るため、
 * 親コンポーネントの scoped からは .popover__content の上書きが効かず Onsen 既定の overflow:auto だけが残り、横スクロールが出ることがある。
 * ここはグローバル（unscoped）で ons-popover 起点に確実に抑える。
 */
ons-popover.change-status-popover-con .popover__content {
  box-sizing: border-box;
  width: 500px;
  max-width: min(500px, 100vw);
  max-height: 394px;
  overflow-x: hidden !important;
  overflow-y: auto;
}
ons-popover.change-status-popover-con .pop-up-con.con-intelligence-popover-body,
ons-popover.change-status-popover-con ons-list.list,
ons-popover.change-status-popover-con .list {
  max-width: 100%;
  box-sizing: border-box;
  overflow-x: hidden;
}
ons-popover.change-status-popover-con ons-list-item.list-item--expandable {
  max-width: 100%;
  min-width: 0;
  box-sizing: border-box;
  overflow-x: hidden;
}
ons-popover.change-status-popover-con .list-item__top,
ons-popover.change-status-popover-con .list-item__center,
ons-popover.change-status-popover-con .list-item__expandable-content {
  max-width: 100%;
  min-width: 0;
  box-sizing: border-box;
  overflow-x: hidden;
}
ons-popover.change-status-popover-con .list-item__expandable-content {
  padding: 4px 4px 4px 0;
}
/* add #9523 患者連携情報の表示内容について zrx end */

.visibility-hidden {
  visibility: hidden;
}
.edited-bgColor {
  td {
    color: #003300 !important;
    background-color: #ccffcc !important;
  }
}
</style>

<style lang="scss" scoped>
.main-content-area {
  color: var(--ntss-base-color);
  /* 親が flex 列のとき、子の flex-1 / height:% が効くよう高さを伝播する */
  min-height: 0;
  flex: 1 1 auto;
}

.main-content-area > .d-flex.flex-column.flex-1 {
  min-height: 0;
  flex: 1 1 auto;
}

.grid {
  min-height: 0;
}

.icon-row {
  align-items: center;
}

div.note > span {
  margin-top: 10px;
}
img.icon {
  max-width: 10em;
}
.first-connection {
  width: 100%;
  height: 1.5em;
  margin-right: 20px;
  margin-left: 20px;
  align-self: center;
  &.ok {
    background-color: #2CA06F;
  }
  &.ng {
    background-color: #AAAAAA;
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  &.no {
    background-color: #6A5ACD;
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
}
.connection {
  width: 100%;
  height: 1.5em;
  margin-right: 20px;
  margin-left: 20px;
  align-self: center;
  &.ok {
    background-color: #2CA06F;
  }
  &.ng {
    // mod FNSI6858-IFエッジと正しく接続されていない場合でも正常と表示される 周 start
    //background-color: #FF6699;
    background-color: #ff0000;
    // mod FNSI6858-IFエッジと正しく接続されていない場合でも正常と表示される 周 end
  }
}
.pop-up {
  font-size: 1.7em;
  padding: 5px;
  .text {
    text-align: center;
    background-color: #333333;
    color: #ffffff;
    padding: 5px 0;
  }
  table {
    width: 100%;
    height: 100%;
    border-collapse: collapse;
    border: 1px solid #a5a5a5;
    tr {
      text-align: center;
      border-collapse: collapse;
      border: 1px solid #a5a5a5;
      td {
        width: 50%;
        border-collapse: collapse;
        border: 1px solid #a5a5a5;
        &:first-child {
          background-color: #333333;
          color: #ffffff;
        }
      }
    }
  }
}
/** add FNSI-連携情報を追加 李 start */
/* mod #9523 患者連携情報の表示内容について zrx start */
.pop-up-con {
  padding: 5px;
  /* スクロールは Onsen .popover__content のみ（二重スクロール防止） */
  table {
    width: 100%;
    height: 100%;
    border-collapse: collapse;
    border: 1px solid #a5a5a5;
    tr {
      text-align: left;
      border-collapse: collapse;
      border: 1px solid #a5a5a5;
      td {
        width: auto;
        max-width: 100%;
        box-sizing: border-box;
        border-collapse: collapse;
        border: 1px solid #a5a5a5;
      }
    }
    td.con-intelligence-section-head {
      background-color: #333333;
      color: #ffffff;
    }
    tr td.con-intelligence-key-cell,
    tr td.con-intelligence-value-cell {
      text-align: left;
      padding: 4px 6px;
      word-break: break-all;
      vertical-align: top;
      background-color: #ffffff;
      color: #333333;
    }
  }
}

/* 連携情報アコーディオン内テーブル */
.pop-up-con.con-intelligence-popover-body .con-intelligence-expandable-panel {
  background-color: #fafafa;
  /* 見出し～表の余白を約70%縮小（旧 2px 4px 3px の約30%） */
  padding: 1px 1px 1px;
  box-sizing: border-box;
  max-width: 100%;
  overflow-x: hidden;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table {
  width: 100%;
  max-width: 100%;
  border-collapse: collapse;
  border: 1px solid #dddddd;
  background-color: #ffffff;
  table-layout: fixed;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table thead tr td.con-intelligence-table-head-cell {
  padding: 4px 6px;
  border: 1px solid #dddddd;
  vertical-align: middle;
  background-color: #333333 !important;
  color: #ffffff !important;
  text-align: left;
  box-sizing: border-box;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table thead tr td.con-intelligence-table-head-cell:not(.con-intelligence-table-head-cell--value) {
  width: 38%;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table thead tr td.con-intelligence-table-head-cell--value {
  width: 62%;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table tbody tr td {
  width: auto;
  border: 1px solid #dddddd;
  text-align: left;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table td.con-intelligence-key-cell {
  width: 38%;
  min-width: 0;
  max-width: 45%;
  text-align: left;
  background-color: #ffffff !important;
  color: #333333 !important;
}
.pop-up-con.con-intelligence-popover-body .con-intelligence-inner-table td.con-intelligence-value-cell {
  width: 62%;
  text-align: left;
  background-color: #ffffff !important;
  color: #333333 !important;
}
/** add FNSI-連携情報を追加 李 end */
/* 連携情報アコーディオン：見出しは従来のセクション見出しと同様に左寄せ */
.external-coop-con-intel-body .con-intelligence-section-label {
  display: block;
  text-align: left;
  padding-left: 20px;
  margin: 0;
  font-weight: normal;
}
/* mod #9523 患者連携情報の表示内容について zrx end*/
ons-button {
  &.cancel {
    color: #fff;
    background-color: #add8e6;
    margin-right: 5px;
  }
}
.grid {
  margin-top: 10px;
  .actions {
    margin-top: 5px;
  }
}

.table-status thead tr th:first-child,
.table-status tbody tr td:first-child {
  width: 5em;
  min-width: 5em;
  max-width: 5em;
  word-break: break-all;
}
</style>

<style scoped>
.change-status-popover :deep(.popover__content) {
  width: 35rem;
}
 
/** add FNSI-連携情報を追加 李 start */
/* mod #9523 患者連携情報の表示内容について zrx start */
.change-status-popover-con :deep(.popover__content) {
  width: 500px;
  max-width: min(500px, 100vw);
  max-height: 394px;
  overflow-x: hidden;
  overflow-y: auto;
  box-sizing: border-box;
}
/* 連携情報アコーディオン：内側がはみ出して横スクロールバーが出ないよう抑える */
.change-status-popover-con :deep(.pop-up-con.con-intelligence-popover-body) {
  max-width: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
}
.change-status-popover-con :deep(.list-item__expandable-content) {
  max-width: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
}
.change-status-popover-con :deep(ons-list.list) {
  max-width: 100%;
  overflow-x: hidden;
  box-sizing: border-box;
}
.change-status-popover-con :deep(ons-list-item) {
  max-width: 100%;
  box-sizing: border-box;
}
/* mod #9523 患者連携情報の表示内容について zrx end */
/** add FNSI-連携情報を追加 李 end */
.content-popover.note :deep(.popover__content) {
  width: 350px;
}
 
/** #10453 mod 死活監視が動作していない 2024-05-11 卓 start*/
.content-popover.modem :deep(.popover__content) {
  width: 290px;
}
 
/** #10453 mod 死活監視が動作していない 2024-05-11 卓 end*/
.content-popover.cloud :deep(.popover__content) {
  width: 310px;
}
.backgroud-white :deep(.k-dropdown-wrap:hover) {
  background-color: rgb(214, 213, 213);
}

.backgroud-white :deep(.k-picker:hover),
.backgroud-white :deep(.k-input-inner:hover) {
  background-color: rgb(214, 213, 213);
}
.change-status-dialog :deep(.dialog-container) {
  font-size: 1.5em;
  background-color: var(--popover-area-background-color);
  color: var(--all-label-color)!important;
}
.grid :deep(.k-grid) {
  background-color: var(--main-background-color);
}
.grid :deep(.k-grid tr) {
  color: var(--ntss-base-color);
}
.grid :deep(.k-grid a.k-button) {
  color: #050505;
}
.grid :deep(table th) {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
}

/* No 列前の 1px 隙間: master-maintenance 全局 th/td の border-left を先頭列だけ除去（Vue2 同様に左端を揃える） */
.grid :deep(.k-grid-header th:first-child),
.grid :deep(.k-grid-header .k-table-th:first-child),
.grid :deep(.k-grid-content tbody tr td:first-child),
.grid :deep(.k-grid-content tbody tr .k-table-td:first-child) {
  border-left-width: 0 !important;
}

/* 横スクロールバー直下の余計な横線: Kendo .k-grid 外枠下 border + 最終行 td 下 border */
.grid :deep(.external-coop-direct-grid.k-grid) {
  border-bottom-width: 0 !important;
}
.grid :deep(.k-grid-content tbody tr:last-child td),
.grid :deep(.k-grid-content tbody tr:last-child .k-table-td) {
  border-bottom-width: 0 !important;
}

/* Vue2 同様の行高 (2em≈31.5px): content-box td への padding 二重計上と .k-table-md padding-block を抑える */
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy) {
  --kendo-line-height: 2em;
  --kendo-line-height-md: 2em;
  line-height: 2em;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-table-md .k-table-th),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-table-md .k-table-td),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy th),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-table-th),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy td),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-table-td) {
  padding-block: 0 !important;
  padding-inline: 0.75rem !important;
  line-height: 2em !important;
  box-sizing: border-box !important;
  vertical-align: middle !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy tr),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-table-row) {
  height: 2em !important;
  max-height: 2em !important;
}

/* 表体のみ Vue2 比 +0.5px（表头 2em はそのまま） */
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-content tbody tr),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-content tbody .k-table-row) {
  height: calc(2em + 0.5px) !important;
  max-height: calc(2em + 0.5px) !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-content tbody td),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-content tbody .k-table-td) {
  height: auto !important;
  max-height: calc(2em + 0.5px) !important;
  line-height: calc(2em + 0.5px) !important;
  overflow: hidden !important;
}

/* 表头も Vue2 同様 2em: .k-cell-inner / .k-link / ソートアイコンの余白を抑える */
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header tr),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-table-row) {
  height: 2em !important;
  max-height: 2em !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header th),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-table-th) {
  height: auto !important;
  max-height: 2em !important;
  overflow: hidden !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-cell-inner) {
  display: flex !important;
  align-items: center !important;
  padding: 0 !important;
  margin: 0 !important;
  min-height: 0 !important;
  max-height: 100% !important;
  height: 100% !important;
  line-height: inherit !important;
  box-sizing: border-box !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-column-title) {
  padding: 0 !important;
  margin: 0 !important;
  min-height: 0 !important;
  line-height: inherit !important;
}

/* 連携 Grid 表头排序图标（Vue2 实心 ▲/▼、16px、translateY(1px)） */
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-cell-inner > .k-link) {
  align-items: center;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-cell-inner > .k-link > .k-sort-icon),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link > .k-sort-icon) {
  display: inline-flex;
  align-items: center;
  align-self: center;
  flex-shrink: 0;
  margin-top: 0;
  line-height: 1;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-sm),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-small),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-sm),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-small),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-icon.k-i-sort-asc-sm),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-icon.k-i-sort-desc-sm) {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  font-size: 16px;
  line-height: 1;
  flex-shrink: 0;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-sm > svg),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-small > svg),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-sm > svg),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-small > svg) {
  display: none;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-sm::before),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-asc-small::before),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-icon.k-i-sort-asc-sm::before) {
  content: "▲";
  color: #ffffff;
  display: block;
  font-size: 16px;
  line-height: 1;
  transform: translateY(1px);
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-sm::before),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-svg-icon.k-svg-i-sort-desc-small::before),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-link .k-icon.k-i-sort-desc-sm::before) {
  content: "▼";
  color: #ffffff;
  display: block;
  font-size: 16px;
  line-height: 1;
  transform: translateY(1px);
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-sort-icon),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-icon),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-grid-header .k-svg-icon) {
  line-height: 1 !important;
  margin-top: 0 !important;
  vertical-align: middle !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy .k-cell-inner) {
  padding: 0 !important;
  margin: 0 !important;
  min-height: 0 !important;
  max-height: 100% !important;
  height: 100% !important;
  line-height: inherit !important;
  box-sizing: border-box !important;
}

.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy a.k-button),
.grid :deep(.external-coop-direct-grid.ntss-kendo-grid-legacy button.k-button) {
  min-height: 0 !important;
  max-height: calc(2em - 1px) !important;
  height: auto !important;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
  box-sizing: border-box !important;
  vertical-align: middle !important;
}

.grid :deep(.k-grid a.k-link) {
  color: #fff;
}
.grid :deep(.k-grid-content td.k-dirty-cell),
.grid :deep(.k-grid-content .k-table-td.k-dirty-cell) {
  font-weight: bold !important;
  color: #003300 !important;
}

/* Vue2 同様: 原値と不一致（k-dirty-cell）のときだけ DropDown 表示も太字 */
.grid :deep(.k-grid-content td.k-dirty-cell.k-edit-cell .k-dropdownlist .k-input-value-text),
.grid :deep(.k-grid-content td.k-dirty-cell.k-edit-cell .k-legacy-dropdownlist .k-input-value-text),
.grid :deep(.k-grid-content td.k-dirty-cell.k-edit-cell .k-dropdown-wrap .k-input),
.grid :deep(.k-grid-content .k-table-td.k-dirty-cell.k-edit-cell .k-dropdownlist .k-input-value-text),
.grid :deep(.k-grid-content .k-table-td.k-dirty-cell.k-edit-cell .k-legacy-dropdownlist .k-input-value-text),
.grid :deep(.k-grid-content .k-table-td.k-dirty-cell.k-edit-cell .k-dropdown-wrap .k-input) {
  font-weight: bold !important;
  color: #003300 !important;
}

/* Vue2 同様: 編集中かつ dirty セルの DropDown 下拉选项のみ太字 */
:global(body:has(.external-coop-direct-grid .k-grid-content td.k-dirty-cell.k-edit-cell) .k-animation-container .k-list-item),
:global(body:has(.external-coop-direct-grid .k-grid-content td.k-dirty-cell.k-edit-cell) .k-animation-container .k-list-item-text),
:global(body:has(.external-coop-direct-grid .k-grid-content td.k-dirty-cell.k-edit-cell) .k-animation-container .k-item),
:global(body:has(.external-coop-direct-grid .k-grid-content .k-table-td.k-dirty-cell.k-edit-cell) .k-animation-container .k-list-item),
:global(body:has(.external-coop-direct-grid .k-grid-content .k-table-td.k-dirty-cell.k-edit-cell) .k-animation-container .k-list-item-text),
:global(body:has(.external-coop-direct-grid .k-grid-content .k-table-td.k-dirty-cell.k-edit-cell) .k-animation-container .k-item) {
  font-weight: bold !important;
}

.grid :deep(tr.edited-bgColor > td),
.grid :deep(tr.edited-bgColor > .k-table-td) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}

.grid :deep(.grid-column-message) {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.ons-col-wrap :deep(.k-dropdown) {
  width: 100%;
}

.popoverLabel {
  white-space: nowrap;
}

@media screen and (max-width: 740px) {
  .icon-group {
    padding: 0 4px;
  }
  .icon-group :deep(img.icon) {
    width: 3.5em;
  }
}

/* add FNSI zhuhongrui ボタンがデザインに変更 start — a タグのコマンド（画面上の btn3-normal と同色） */
:deep(.grid .k-grid a.k-button){
  color: #ffffff !important;
  background-color: var(--btn3-normal-color) !important;
  background-image: linear-gradient(var(--btn3-normal-color), var(--btn3-normal-color)) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}

/* 連携情報：互換層が button.k-button — 更新ボタン（btn3-normal）と同系色 */
.grid :deep(.grid-column-con-intelligence button.k-button),
.grid :deep(.grid-column-con-intelligence a.k-button),
:deep(.grid .k-grid .grid-column-con-intelligence .k-button) {
  color: #ffffff !important;
  background-color: var(--btn3-normal-color) !important;
  background-image: linear-gradient(var(--btn3-normal-color), var(--btn3-normal-color)) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
ons-popover :deep(.popover__arrow) {
  width: 0px !important;
}

/* add FNSI zhuhongrui ボタンがデザインに変更 end */
.content-popover :deep(.popover__arrow),
.change-status-popover :deep(.popover__arrow),
.change-status-popover-con :deep(.popover__arrow) {
  width: 0px !important;
}
.popover-style :deep(.popover--top) {
  position: absolute!important;
   top: calc(50% + 80px)!important;
   left: 50%!important;
   right: unset!important;
   bottom: unset!important;
   transform: translateY(-50%) translateX(-50%)!important;
}
:deep(.k-legacy-multiselect > .k-input-values.k-multiselect-wrap),
:deep(.k-legacy-multiselect > .k-multiselect-wrap),
:deep(.k-legacy-multiselect .k-input-values.k-multiselect-wrap) {
  background: #fff !important;
}

.master-maintenance-page :deep(.k-grid-header) {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

@media print {
  /* スクロールコンテナ */
  .grid :deep(.k-grid-header-wrap),
  .grid :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }
  /* ヘッダのズレ原因を除去 */
  .grid :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  /* スクロール要素の幅 */
  .grid :deep(.k-grid) {
    width: 100vw !important;
  }
  /* 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  .grid :deep(table.scroll-rightmost) {
    position: relative !important;
    float: right;
  }
  /* フッターボタン非表示 */
  .grid :deep(.actions) {
    display: none;
  }
}
</style>
