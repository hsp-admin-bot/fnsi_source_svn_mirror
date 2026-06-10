/**
 * マスタ編集（愁訴処置マスタ）メインコンポーネント
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" style="display: inherit;">
      <div class="grid-toolbar" :style="heightStyles">
        <div class="header-btn-area right">
          <v-ons-row width="100%">
            <!-- mod 鞠 4564処置追加ボタンの位置の不正 30% =>> 26.8%  -->
            <v-ons-col class="complaint-button">
              <v-ons-button
                modifier="outline"
                class="toolbar-btn btn3-normal"
                v-show="!isSortMode"
                style="float: left;"
                @click="addMstComplaintRow()"
              >愁訴追加</v-ons-button>
            </v-ons-col>
            <v-ons-col class="treatment-button">
              <v-ons-button
                modifier="outline"
                class="toolbar-btn btn3-normal"
                v-show="!isSortMode"
                style="float: left;"
                @click="addMstCompTreatmentRow()"
              >処置追加</v-ons-button>
            </v-ons-col>
            <!-- mod 鞠 4564処置追加ボタンの位置の不正 40% =>> 43.2%  -->
            <v-ons-col class="csv-rank-group-button">
              <v-ons-button
                modifier="outline"
                class="toolbar-btn csv-btn btn3-normal"
                style="margin-right: 10px;"
                v-show="!isSortMode"
                @click="importCsv()"
              >CSV取込</v-ons-button>
              <v-ons-button
                modifier="outline"
                class="toolbar-btn btn3-normal"
                v-show="!isSortMode"
                @click="toRankEditBtnClick()"
              >並び順表示</v-ons-button>
              <v-ons-button
                modifier="outline"
                class="toolbar-btn btn3-normal"
                v-show="isSortMode"
                @click="sortBtnClick()"
              >反映</v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
        <div class="scroll-table" :style="gridHeightStyle">
          <table class="grid-record-list">
            <colgroup>
              <!-- mod 愁訴処置マスタ 画面修正 孔 start -->
              <!-- <col style="width: 20px">
              <col style="width: 10px">
              <col style="width: 14em">
              <col style="width: 14em">
              <col style="width: 8em">
              <col style="width: 10px">
              <col style="width: 14em">
              <col style="width: 14em">
              <col style="width: 14em">
              <col style="width: 14em">
              <col style="width: 8em"> -->
              <col style="width: 20px">
              <col style="width: 10px">
              <col style="width: 16em">
              <!-- del 愁訴処置マスタ 処置の並び順表示エリアが小さくなっていない 孔s start -->
              <!-- <col style="width: 14em"> -->
              <!-- del 愁訴処置マスタ 処置の並び順表示エリアが小さくなっていない 孔s end -->
              <col style="width: 9em">
              <col style="width: 9em">
              <col style="width: 10px">
              <col style="width: 16em">
              <col style="width: 9em">
              <col style="width: 16em">
              <col style="width: 9em">
              <col style="width: 8em">
              <!-- add 愁訴処置マスタ 処置の並び順表示エリアが小さくなっていない 孔s start -->
              <col style="width: 14em">
              <!-- add 愁訴処置マスタ 処置の並び順表示エリアが小さくなっていない 孔s end -->
              <col style="width: 9em">
              <!-- mod 愁訴処置マスタ 画面修正 孔 end -->
            </colgroup>
            <thead>
              <!-- mod 愁訴処置マスタ 画面修正 孔 start -->
              <!-- <tr>
                <th class="ntss-list-header-th-sticky"></th>
                <th class="ntss-list-header-th-sticky dummy-sort-column" v-show="!isSortMode"></th>
                <th class="ntss-list-header-th-sticky" v-show="isSortMode">並び順</th>
                <th class="ntss-list-header-th-sticky">愁訴名</th>
                <th class="ntss-list-header-th-sticky">削除</th>
                <th class="ntss-list-header-th-sticky dummy-sort-column" v-show="!isSortMode"></th>
                <th class="ntss-list-header-th-sticky" v-show="isSortMode">並び順</th>
                <th class="ntss-list-header-th-sticky">処置内容</th>
                <th class="ntss-list-header-th-sticky">処置薬剤</th>
                <th class="ntss-list-header-th-sticky">数量</th>
                <th class="ntss-list-header-th-sticky">単位</th>
                <th class="ntss-list-header-th-sticky">手技</th>
                <th class="ntss-list-header-th-sticky">削除</th>
              </tr>
              <tr v-if="!isShortScreen">
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;">
                  <v-ons-button
                    modifier="outline"
                    class="toolbar-btn btn3-normal"
                    v-show="!isSortMode"
                    style="float: left;"
                    @click="addMstComplaintRow()"
                  >愁訴追加</v-ons-button>
                </th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;">
                  <v-ons-button
                    modifier="outline"
                    class="toolbar-btn btn3-normal"
                    v-show="!isSortMode"
                    style="float: left;"
                    @click="addMstCompTreatmentRow()"
                  >処置追加</v-ons-button>
                </th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;">
                  <v-ons-button
                    modifier="outline"
                    class="toolbar-btn csv-btn btn3-normal"
                    style="margin-right: 10px;"
                    v-show="!isSortMode"
                    @click="importCsv()"
                  >CSV取込</v-ons-button>
                </th>
                <th style="position: sticky;top: 0px;z-index: 1;">
                  <v-ons-button
                    modifier="outline"
                    class="toolbar-btn btn3-normal"
                    v-show="!isSortMode"
                    @click="toRankEditBtnClick()"
                  >並び順表示</v-ons-button>
                  <v-ons-button
                    modifier="outline"
                    class="toolbar-btn btn3-normal"
                    v-show="isSortMode"
                    @click="sortBtnClick()"
                  >反映</v-ons-button>
                </th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
                <th style="position: sticky;top: 0px;z-index: 1;"></th>
              </tr> -->
              <tr>
                <th class="ntss-list-header-th-sticky"></th>
                <th class="ntss-list-header-th-sticky" v-show="!isSortMode"></th>
                <th class="ntss-list-header-th-sticky" style="min-width: 95px" v-show="isSortMode">並び順</th>
                <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 start -->
                <!-- <th class="ntss-list-header-th-sticky">愁訴名</th> -->
                <th class="ntss-list-header-th-sticky" style="min-width: 210px">愁訴</th>
                <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 end -->
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">詳細</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">削除</th>
                <th class="ntss-list-header-th-sticky" v-show="!isSortMode"></th>
                <th class="ntss-list-header-th-sticky" style="min-width: 95px" v-show="isSortMode">並び順</th>
                <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 start -->
                <!--<th class="ntss-list-header-th-sticky" style="min-width: 210px">処置内容</th>-->
                <th class="ntss-list-header-th-sticky" style="min-width: 210px">処置</th>
                <!-- mod 愁訴処置マスタ 4・愁訴名→愁訴 処置名→処置に文言修正 孔 end -->
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">詳細</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 210px">処置薬剤</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">数量</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">単位</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 180px">手技</th>
                <th class="ntss-list-header-th-sticky" style="min-width: 90px">削除</th>
              </tr>
              <!-- mod 愁訴処置マスタ 画面修正 孔 end -->
            </thead>
            <tbody>
              <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start -->
              <!-- <tr v-for="index in dataSource.length" :key="index" class="ntss-list-body-tr grid-line"> -->
              <tr v-for="index in dataSource.length" :key="index" class="ntss-list-body-tr"
                  :class="{'grid-line-B': ((index-1)%perPage === 0 && (index-1) < notDelLenght) || ((index-1)%perPage - (notDelLenght % 8) === 0 && index >= notDelLenght)}">
              <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start -->
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start -->
                <!-- <td -->
                <!--   class="ntss-list-body-td-text-center grid-line-page" -->
                <!--   rowspan="8" -->
                <!--   v-if="(index-1)%perPage === 0" -->
                <!-- >{{ Math.floor(index / perPage + 1)}}</td> -->
                <td
                  class="ntss-list-body-td-text-center grid-line-page"
                  rowspan="8"
                  v-if="(index-1)%perPage - (notDelLenght % 8) === 0 && index > notDelLenght"
                >－</td>
                <td
                  class="ntss-list-body-td-text-center grid-line-page"
                  :rowspan="Math.floor(index / perPage) != Math.floor(notDelLenght / 8) ? 8 : notDelLenght % 8"
                  v-else-if="(index-1)%perPage === 0 && (index-1) < notDelLenght"
                >{{ Math.floor(index / perPage + 1)}}</td>
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen end -->
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start -->
                <!-- <template v-if="dataSource.mstComplaints.length < index"> -->
                <template v-if="dataSource.mstComplaints.length < index || dataSource.mstComplaints[index-1].code == ''">
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen end -->
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                </template>
                <template v-else>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassSort(dataSource.mstComplaints[index-1])"
                    v-show="!isSortMode"
                  ></td>
                  <!-- mod 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる。孔 start -->
                  <!-- <td
                    class="ntss-list-body-td sort-rank"
                    :class="getRowStyleClassSort(dataSource.mstComplaints[index-1])"
                    v-show="isSortMode">
                    <com-number-input
                      class="number-input"
                      input-id="sortRankFirstComplaint"
                      v-model="dataSource.mstComplaints[index-1].sortRankFirst"
                      name="sortRankFirstComplaint"
                      :step=1
                      :min=0
                      :max=9999999999
                      @blur="setSortRankSecondComplaint(index)"
                    /></td> -->
                  <td
                    class="ntss-list-body-td sort-rank"
                    :class="getRowStyleClassSort(dataSource.mstComplaints[index-1])"
                    @click="addInput(index,'mstComplaintsSort')"
                    v-show="isSortMode"
                  ><span>{{dataSource.mstComplaints[index-1].sortRankFirst}}</span></td>
                  <!-- mod 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる。孔 end -->
                  <!-- mod 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする 孔 start -->
                  <!-- <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstComplaints[index-1])"
                    @click="showMstComplaintEditModal(dataSource.mstComplaints[index-1])"
                  >
                  {{dataSource.mstComplaints[index-1].name}}</td>-->
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstComplaints[index-1])"
                    @click="addInput(index,'mstComplaints')"
                  ><span>{{dataSource.mstComplaints[index-1].name}}</span></td>
                  <!-- mod 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする 孔 end -->
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstComplaints[index-1])"
                  >
                    <v-ons-button
                      class="common-style-select-button btn3-normal"
                      @click="showMstComplaintEditModal(dataSource.mstComplaints[index-1])"
                    >
                      詳細
                    </v-ons-button>
                  </td>
                  <td
                    class="ntss-list-body-td disp-select-box"
                    :class="getRowStyleClassEdit(dataSource.mstComplaints[index-1])"
                  ><v-ons-select
                      class="selectbox"
                      v-model="dataSource.mstComplaints[index-1].isDisp"
                      name="complaint-cd"
                      model-event="change"
                      :disabled="isSortMode"
                      @change="editMstComplaint(dataSource.mstComplaints[index-1])">
                      <option v-for="(item, id) in dispComboList" :key="id" :value="item.cd" :hidden="item.hidden" :disabled="item.hidden">
                        {{ item.name }}
                      </option>
                    </v-ons-select>
                  </td>
                </template>
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start -->
                <!-- <template v-if="dataSource.mstCompTreatments.length < index"> -->
                <template v-if="dataSource.mstCompTreatments.length < index || dataSource.mstCompTreatments[index-1].code == '' ">
                <!-- mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen end -->
                  <td class="ntss-list-body-td grid-line-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row-none"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                  <td class="ntss-list-body-td dummy-row"></td>
                </template>
                <template v-else>
                  <td
                    class="ntss-list-body-td grid-line-td"
                    :class="getRowStyleClassSort(dataSource.mstCompTreatments[index-1])"
                    v-show="!isSortMode"
                  ></td>
                  <!-- mod 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる。孔 start -->
                  <!-- <td
                    class="ntss-list-body-td grid-line-td sort-rank"
                    :class="getRowStyleClassSort(dataSource.mstCompTreatments[index-1])"
                    v-show="isSortMode">
                    <com-number-input
                      input-id="sortRankFirstCompTreatment"
                      v-model="dataSource.mstCompTreatments[index-1].sortRankFirst"
                      name="sortRankFirstCompTreatment"
                      :step=1
                      :min=0
                      :max=9999999999
                      @blur="setSortRankSecondCompTreatment(index)"
                    /></td> -->
                  <td
                    class="ntss-list-body-td grid-line-td sort-rank"
                    :class="getRowStyleClassSort(dataSource.mstCompTreatments[index-1])"
                    @click="addInput(index,'mstCompTreatmentsSort')"
                    v-show="isSortMode"
                  ><span>{{dataSource.mstCompTreatments[index-1].sortRankFirst}}</span></td>
                  <!-- mod 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる。孔 end -->
                  <!-- mod 愁訴処置マスタ 処置のクリックでモーダルを起動しないでテキストボックスでの入力を可能とする 孔 start -->
                  <!-- <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                    @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].treatment}}</td> -->
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                    @click="addInput(index,'mstCompTreatments')"
                  ><span>{{dataSource.mstCompTreatments[index-1].treatment}}</span></td>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                  >
                    <v-ons-button
                      class="common-style-select-button btn3-normal"
                      @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                    >
                      詳細
                    </v-ons-button>
                  </td>
                  <!-- mod 愁訴処置マスタ 処置のクリックでモーダルを起動しないでテキストボックスでの入力を可能とする 孔 start -->
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1], dataSource.mstCompTreatments[index-1].isTreatMedicineDeleted())"
                    @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].treatMedicine.name}}</td>
                  <!-- mod 愁訴処置マスタ 処置薬剤、数量、単位、手技クリック→モーダル起動のまま 孔 start -->
                  <!-- <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].amount ? dataSource.mstCompTreatments[index-1].amount : ""}}</td>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].treatMedicine.unit}}</td>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1], dataSource.mstCompTreatments[index-1].isProcedureDeleted())"
                  >{{dataSource.mstCompTreatments[index-1].procedure.name}}</td> -->
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                    @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].amount ? dataSource.mstCompTreatments[index-1].amount : ""}}</td>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                    @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].treatMedicine.unit}}</td>
                  <td
                    class="ntss-list-body-td"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1], dataSource.mstCompTreatments[index-1].isProcedureDeleted())"
                    @click="showMstCompTreatmentEditModal(dataSource.mstCompTreatments[index-1])"
                  >{{dataSource.mstCompTreatments[index-1].procedure.name}}</td>
                  <!-- mod 愁訴処置マスタ 処置薬剤、数量、単位、手技クリック→モーダル起動のまま 孔 end -->
                  <td
                    class="ntss-list-body-td disp-select-box"
                    :class="getRowStyleClassEdit(dataSource.mstCompTreatments[index-1])"
                  ><v-ons-select
                      class="selectbox"
                      v-model="dataSource.mstCompTreatments[index-1].isDisp"
                      name="comp-treatment-cd"
                      model-event="change"
                      :disabled="isSortMode"
                      @click="editMstCompTreatment(dataSource.mstCompTreatments[index-1])">
                      <option v-for="(item, id) in dispComboList" :key="id" :value="item.cd" :hidden="item.hidden" :disabled="item.hidden">
                        {{ item.name }}
                      </option>
                    </v-ons-select>
                  </td>
                </template>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button class="button denial-btn btn2-cancel" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="button registration-btn btn1-execute"
              style="width: auto;"
              @click="saveRecord"
              :disabled="!isChanged"
            >保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import MstComplaintComponentMixin from "@/components/master-maintenance/mst-complaint/MstComplaintComponentMixin";
import { MstComplaint } from "@/models/master-maintenance/mst-complaint/MstComplaint";
import { MstCompTreatment } from "@/models/master-maintenance/mst-complaint/MstCompTreatment";
// del 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる 孔s start
// import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
// del 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる 孔s end
import { EventBus } from "@/eventBus.js";
import { CODES,MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import BigNumber from "bignumber.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
const CLASS_MISMATCH_LABEL = "【分類不一致】";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export default {
  components: {
    "master-csv": MasterCsvComponent
  },
  mixins: [
    NextTransitionMixin,
    MasterMaintenanceMixin,
    MstComplaintComponentMixin
  ],
  // del 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる 孔s start
  // components: {
  //   "com-number-input": CommonNumberInputComponent
  // },
  // del 愁訴処置マスタ 6・並び順制御を他のマスタに合わせる 孔s end
  data() {
    return {
      isSortMode: false,
      gridToolbarHeight: 630,
      gridHeight: 300,
      dispComboList: [
        { cd: null, name: null, hidden: true },
        { cd: "1", name: "", hidden: false },
        { cd: "0", name: "削除　", hidden: false }
      ],
      newRecordCdComplaint: -1,
      newRecordCdCompTreatment: -1,
      // add 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする 孔s start
      isEditing:false,
      // add 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする 孔s end
      lastScrollTop:0,
      lastScrollLeft:0,
      masterCsvVisible: false,
      masterCsvTarget: null,
      isShortScreen: true,
      errorMessage: "",
      selfScreenName: ""
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      , notDelLenght: this.getNotDelLenght,
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    };
  },
  methods: {
    ...mapActions("multi-modal", [
      "showMstComplaintEdit",
      "showMstCompTreatmentEdit"
    ]),
    ...mapGetters("mst-complaint", [
      "getAllMstComplaints",
      "getAllMstCompTreatments"
    ]),
    ...mapActions("mst-complaint", [
      "setMstComplaintEdit",
      "setMstCompTreatmentEdit",
      "setMstComplaints",
      "setMstCompTreatments",
      "setCondition",
      "addMstComplaint",
      "addMstCompTreatment",
      "sort",
      "editMstComplaint",
      "editMstCompTreatment",
      "updateMstComplaint",
      "updateMstCompTreatment",
      "getDeviceEdgeNoListByFacilityCd",
      "mstSyncDeviceEdge"
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      , "setChangeFlg",
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    ]),
    // add 愁訴処置マスタ CSVファイル取込失敗 商 start
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCdWithSql",
      "findColumnInfo",
    ]),
    // add 愁訴処置マスタ CSVファイル取込失敗 商 end
    ...mapActions("loading-screen", [
      //add 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 start
      "resetLoadingScreenVisibleCount",
      //add 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 end
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    // add 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする。 孔 start
    addInput(index,dataSourceType){
      if(this.isEditing) return
      var evtTarget = event.target || event.srcElement;
      // add 愁訴処置マスタ 障害対応 No236 項目「愁訴」を一定桁数文字で更新→ほか場所をクリック→再び編集できない 孔 start
      if (evtTarget.tagName === "SPAN") evtTarget = evtTarget.parentNode;
      // add 愁訴処置マスタ 障害対応 No236 項目「愁訴」を一定桁数文字で更新→ほか場所をクリック→再び編集できない 孔 end
      const oldValue = evtTarget.innerText;
      const that = this;
      if (dataSourceType=="mstComplaints" || dataSourceType=="mstCompTreatments") {
        if(this.isSortMode) return;
        this.isEditing = true;
        // evtTarget.innerText="";
        const span = evtTarget.getElementsByTagName("span")[0];
        span.style.display='none';
        // del #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng start
        // #8745 は必須入力です。追加 林峻峰 start
        // const name = dataSourceType=="mstComplaints" ? '愁訴' : '処置';
        // #8745 は必須入力です。追加 林峻峰 end
        // del #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng end
        // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng start
        // $(
        //   `<input type="text" class="k-input k-textbox k-valid" name="list_name" maxlength="256" title="" required validationMessage="${name}は必須入力です。">`
        // ).appendTo(evtTarget)
        $(
          `<input type="text" class="k-input k-textbox" name="list_name" maxlength="256" title="" >`
        ).appendTo(evtTarget)
        // .blur(function(event){
        .blur(function(){

          // #8745 は必須入力です。追加 林峻峰 start
          // if (!event.target.value) {
          //   const width = document.getElementsByClassName('k-textbox')[0].clientWidth;
          //   $('.k-textbox').after(`<div class="tooltip-wrapper" style="position:relative"><div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg" style="margin:0.5em;width: ${width}px;position:absolute;" ><span class="k-icon k-i-warning"> </span>${name}は必須入力です。<div class="k-callout k-callout-n"></div></div></div>`)
          //   document.getElementsByClassName('k-textbox')[0].style.border = '1px solid red';
          // } else {
          //   $('.tooltip-wrapper').detach();
          //   $(this).remove();span.style.display='inline';that.isEditing=false
          // }
          // $('.tooltip-wrapper').detach();
          $(this).remove();span.style.display='inline';that.isEditing=false
          // #8745 は必須入力です。追加 林峻峰 end
          // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng end
        })
        .change((e)=>{this.setContentData(e.target.value,index,dataSourceType)})
        .val(oldValue)
        .focus();
      }
      if (dataSourceType=="mstComplaintsSort" || dataSourceType=="mstCompTreatmentsSort") {
        if(!this.isSortMode) return;
        this.isEditing = true;
        // evtTarget.innerText="";
        const spanSort = evtTarget.getElementsByTagName("span")[0];
        spanSort.style.display='none';
        $(
          `<input name="list_name" >`
        ).appendTo(evtTarget)
        .kendoNumericTextBox({
          format: "n0",
          min: 0,
          max: 9999999999,
          setp: 1,
          value: oldValue
        })
        .blur(function(){$(this.parentNode.parentNode).remove();spanSort.style.display='inline';that.isEditing=false})
        .change((e)=>{this.setContentData(e.target.value,index,dataSourceType)});

        $(evtTarget).find("input").get(0).focus();
      }
    },
    setContentData(newValue, index, type){
      if (type == "mstComplaints") {
        this.dataSource.mstComplaints[index-1].name=newValue;
        this.dataSource.mstComplaints[index-1].up_date=null;
      }
      if (type == "mstCompTreatments") {
        this.dataSource.mstCompTreatments[index-1].treatment=newValue;
        this.dataSource.mstCompTreatments[index-1].up_date=null;
      }
      if (type == "mstComplaintsSort") {
        this.dataSource.mstComplaints[index-1].sortRankFirst=newValue;
        this.setSortRankSecondComplaint(index);
      }
      if (type == "mstCompTreatmentsSort") {
        this.dataSource.mstCompTreatments[index-1].sortRankFirst=newValue;
        this.setSortRankSecondCompTreatment(index);
      }
    },
    // add 愁訴処置マスタ 愁訴クリックでモーダルを起動せずに直接テキストボックスでの入力を可能とする。 孔 end
    /**
     * 愁訴マスタ追加ボタン押下時イベント処理.
     */
    addMstComplaintRow() {

      /* mod 並び順修正 楊 start */
      // const numberOfComplaint = this.getFilteredDataSource.mstComplaints.length;
      const numberOfComplaint = this.allMstComplaints.filter(e => (e.isDel === false && e.code != 0)).length;
      /* mod 並び順修正 楊 end */

      this.addMstComplaint(new MstComplaint(null, numberOfComplaint, this.newRecordCdComplaint));
      this.newRecordCdComplaint--;
      // dataSource()プロパティが再評価されるようにするためthis.getFilteredDataSourceで使用しているchangeFlgを初期化する
      this.setChangeFlg(false);
      this.$nextTick(() => {
        if(numberOfComplaint > 2) {
          document.querySelector('.scroll-table').scrollTop = document.querySelector('.scroll-table').lastChild.tBodies[0].querySelector(`tr:nth-child(${numberOfComplaint-2})`)?.offsetTop;
        } else {
          document.querySelector('.scroll-table').scrollTop = document.querySelector('.scroll-table').lastChild.tBodies[0].querySelector(`tr:nth-child(${numberOfComplaint})`)?.offsetTop;
        }
      });
    },
    /**
     * 処置マスタ追加ボタン押下時イベント処理.
     */
    addMstCompTreatmentRow() {

      /* mod 並び順修正 楊 start */
      // const numberOfCompTreatment = this.getFilteredDataSource.mstCompTreatments.length;
      const numberOfCompTreatment = this.allMstCompTreatments.filter(e => (e.isDel === false && e.code != 0)).length;
      /* mod 並び順修正 楊 end */

      this.addMstCompTreatment(new MstCompTreatment(null, numberOfCompTreatment, this.newRecordCdCompTreatment));
      this.newRecordCdCompTreatment--;
      // dataSource()プロパティが再評価されるようにするためthis.getFilteredDataSourceで使用しているchangeFlgを初期化する
      this.setChangeFlg(false);
      this.$nextTick(() => {
        if(numberOfCompTreatment > 2) {
          document.querySelector('.scroll-table').scrollTop = document.querySelector('.scroll-table').lastChild.tBodies[0].querySelector(`tr:nth-child(${numberOfCompTreatment-2})`)?.offsetTop;
        } else {
          document.querySelector('.scroll-table').scrollTop = document.querySelector('.scroll-table').lastChild.tBodies[0].querySelector(`tr:nth-child(${numberOfCompTreatment})`)?.offsetTop;
        }
      });
    },
    /**
     * 並び順表示ボタン押下時イベント処理
     */
    toRankEditBtnClick() {
      this.isSortMode = true;
      this.calculateRankSortEventGridFooterAreaHeight();
      EventBus.$emit("setSortModeComplaint", this.isSortMode);
    },
    /**
     * 反映ボタン押下時イベント処理
     */
    sortBtnClick() {
      this.isSortMode = false;
      this.calculateRankSortEventGridFooterAreaHeight();
      // ソートする
      this.sort();
      EventBus.$emit("setSortModeComplaint", this.isSortMode);
    },
    /**
     * 愁訴マスタダイアログを表示する.
     * @param e 愁訴マスタ
     */
    showMstComplaintEditModal(e) {
      // 並び順モード時はモーダルを表示させない
      if(this.isSortMode) return;
      this.setMstComplaintEdit(e);
      this.showMstComplaintEdit();
    },
    /**
     * 処置マスタダイアログを表示する.
     * @param e 処置マスタ
     */
    showMstCompTreatmentEditModal(e) {
      if(this.isSortMode) return;
      this.setMstCompTreatmentEdit(e);
      this.showMstCompTreatmentEdit();
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      this.$router.go(-1);
    },
    /**
     * バリデーション処理
     */
    validate() {
      // 削除済の処置薬剤マスタ/手技マスタを参照しているか確認
      const data = this.getAllMstCompTreatments();
      const errorFields = [];

      if (data.some(e => e.isTreatMedicineDeleted())) {
        errorFields.push("処置薬剤");
      }
      if (data.some(e => e.isProcedureDeleted())) {
        errorFields.push("手技");
      }

      if (errorFields.length > 0) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000006].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' +
                  // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                  //  "以下の列の選択を見直してください。" +
                   messageFormat(DIALOG_MESSAGES[12000006].message) +
                   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
                   errorFields.map(e => "<br>&nbsp;&nbsp;・" + e).join("") +
                   "</div"
        });
        return false;
      }

      return true;
    },
    // マスタ同期
    syncMaster() {
      /* mod 楊 start */
      // this.setLoadingScreenVisible(true);
      /* mod 楊 end */
      this.getDeviceEdgeNoListByFacilityCd(this.getFacilitySwitch).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array = array.sort(r => r.deviceEdgeNo)
          this.synchroMstToDeviceEdge(array, 0);
        }
      })
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "愁訴処置マスタ同期";
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, '愁訴処置マスタ');
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + info.deviceName + "</br></br>";
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
      this.setLoadingScreenVisible(true);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
      // マスタ同期
      this.mstSyncDeviceEdge({
        // add マスタ一覧 施設切替を可能とする 王 start
        // facilityCd: this.getFacilityCd,
        facilityCd: this.getFacilitySwitch,
        // add マスタ一覧 施設切替を可能とする 王 end
        deviceEdgeNo: info.deviceEdgeNo
      })
        .then(() => {
          if (infos.length === idx + 1) {
            name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
            // 共通ローダー：表示終了
            //mod 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 start
            // this.setLoadingScreenVisible(false);
            this.resetLoadingScreenVisibleCount();
            //mod 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 end
            if (this.errorMessage === "") {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message,name),
              });
              this.errorMessage = "";
            }
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (this.errorMessage === "") {
            this.errorMessage += "</br>" + info.deviceName + "</br>";
          } else {
            this.errorMessage += info.deviceName + "</br>";
          }
          this.synchroMstToDeviceEdge(list, idx + 1);
            //mod 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 start
            // this.setLoadingScreenVisible(false);
            this.resetLoadingScreenVisibleCount();
            //mod 8625 【デグレ】愁訴処置マスタで保存すると処理中のまま固まる 張 end
          if (infos.length === idx + 1) {
            if (error.response.status === 400) {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('MstComplaintMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000332].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorMessage = "";
            } else {
              getErrorMessage('MstComplaintMainComponent.vue', 'synchroMstToDeviceEdge', error);
            }
          }
        });
    },
    /**
     * 保存ボタン押下時イベント処理
     */
    saveRecord() {
      // バリデーション
      if (!this.validate()) {
        return;
      }

      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.lastScrollTop = document.getElementsByClassName('scroll-table')[0].scrollTop;
      this.lastScrollLeft= document.getElementsByClassName('scroll-table')[0].scrollLeft;
      /* add スクロールの位置を維持 楊 end */

      // 愁訴マスタと処置マスタを更新する
      // mod 愁訴マスタ 愁訴が空値でも保存してデータが残ること 孔s start
      // const mstComplaints = this.getAllMstComplaints()
      //   .filter(e => e.code > 0 || e.isEditedAtThisTime())
      //   .map(e => e.entity);
      // const mstCompTreatments = this.getAllMstCompTreatments()
      //   .filter(e => e.code > 0 || e.isEditedAtThisTime())
      //   .map(e => e.entity);
      const mstComplaints = this.getAllMstComplaints()
        .filter(e => e.code > 0 || !e.up_date && e.isDisp == "1")
        .map(e => e.entity);
      const mstCompTreatments = this.getAllMstCompTreatments()
        .filter(e => e.code > 0 || !e.up_date && e.isDisp == "1")
        .map(e => e.entity);
      // mod 愁訴マスタ 愁訴が空値でも保存してデータが残ること 孔s end

      // add マスタ一覧 1･施設切替を可能とする 王
      Promise.all([
        // this.updateMstComplaint(mstComplaints),
        // this.updateMstCompTreatment(mstCompTreatments)
        ApiHelper.put(`/complaint/mst-complaint/update/${this.getFacilitySwitch}`, mstComplaints),
        ApiHelper.put(`/complaint/mst-comp-treatment/update/${this.getFacilitySwitch}`, mstCompTreatments)
      ])
      .then(async response => {
        this.updateResponse = response.data;
        // this.$ons.notification.alert({
        //     title: "更新完了",
        //     message: "マスタ更新が完了しました。"
        //   });

        await this.syncMaster();

        // データ再取得
        this.findList();
        // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
        // this.getFilteredDataSource;
        this.notDelLenght = this.getNotDelLenght;
        // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MstComplaintMainComponent.vue', 'saveRecord', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        if (error.response.status === 400) {
          this.$ons.notification
            .alert({
              title: "更新に失敗しました。",
              message: error.response.data.errorMessage
            })
            .then(() => this.findList());
        }
      })
      // 共通ローダー：表示終了
      .finally(() => this.setLoadingScreenVisible(false));
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      this.setChangeFlg(false);
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    },
    /**
     * 愁訴マスタと処置マスタを取得
     */
    async findMasterRecords() {
      let mstComplaints = [];
      let mstCompTreatments = [];
      {
        // 愁訴マスタ取得
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // const response = await this.getMstComplaint;
        const response = await ApiHelper.get(`/complaint/mst-complaint/data/${this.getFacilitySwitch}`);
        // add マスタ一覧 1･施設切替を可能とする 王 end
        mstComplaints = response.data.map(
          (e, index) => new MstComplaint(e, index, null)
        );
      }
      {
        // 処置マスタ取得
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // const response = await this.getMstCompTreatment;
        const response = await ApiHelper.get(`/complaint/mst-comp-treatment/data/${this.getFacilitySwitch}`);
        // add マスタ一覧 1･施設切替を可能とする 王 end
        mstCompTreatments = response.data.map(
          (e, index) => new MstCompTreatment(e, index, null)
        );
      }
      // 外部参照マスタの情報を設定
      await this.setRefMaster(mstCompTreatments);
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      this.setMstComplaints(mstComplaints);
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
      this.setMstCompTreatments(mstCompTreatments);

      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      this.setChangeFlg(false);
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
      // del #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      // this.setMstComplaints(mstComplaints);
      // this.setMstCompTreatments(mstCompTreatments);
      // del #9176 愁訴処置マスタが正しくコンバートできていない dengshen end

      // 一覧の高さ調整
      this.$nextTick(() => {
        this.calculateGridHeight();
        /* add スクロールの位置を維持 楊 start */
        document.getElementsByClassName('scroll-table')[0].scrollTop = this.lastScrollTop;
        document.getElementsByClassName('scroll-table')[0].scrollLeft = this.lastScrollLeft;
        setTimeout(() => {
          this.lastScrollTop = 0;
          this.lastScrollLeft = 0;
        }, 1000);
        /* add スクロールの位置を維持 楊 end */
      });
    },
    /**
     * 処置マスタの外部参照マスタの情報を設定します.
     */
    async setRefMaster(mstCompTreatments) {
      // 薬剤マスタと手技マスタを取得
      const treatMedicines = await this.readMedicineItems();
      const procedures = await this.readProcedureItems();
      const proceduresAll = await this.readProcedureItemsIncludeDeleted();

      // 処置薬剤の名称等を設定
      mstCompTreatments.forEach(e => {
        if (e.treatMedicine.code) {
          let medicine = null;
          if (e.isPreparationMedicine) {
            // TODO 調整薬剤マスタがないのでとりあえず薬剤セットとしておく
            medicine = treatMedicines.medicinesMix.find(
              m => m.code === e.treatMedicine.code
            );
            if (medicine) {
              Object.assign(e.treatMedicine, medicine);
            }
          } else if (e.isMedicine) {
            // 処置区分が薬剤
            medicine = treatMedicines.medicines.find(
              m => m.code === e.treatMedicine.code
            );
            if (medicine) {
              Object.assign(e.treatMedicine, medicine);
            }
          }
          let numbers = String(e.amount).split('.');
          let decPoint = (numbers[1]) ? numbers[1].length : 0;
          // mod FNSI- typeofの使い方が違います。 徐博 start
          // if(typeof(medicine === "undefined")){
          if ( typeof medicine === "undefined" ){
            // mod FNSI- typeofの使い方が違います。 徐博 end
            e.amount = BigNumber(1 * e.amount).toFixed();
          }else
          if(decPoint > medicine.decPoint){
            e.amount = BigNumber(1 * e.amount).toFixed();
          }else{
            e.amount = BigNumber(1 * e.amount).toFixed(medicine.decPoint);
          }
        }

        // 手技マスタの情報を設定
        if (e.procedure.code) {
          const procedure = procedures.find(m => m.code === e.procedure.code);
          if (procedure) {
            Object.assign(e.procedure, procedure);
          }else{
            Object.assign(e.procedure, proceduresAll.find(m => m.code === e.procedure.code));
          }
        }
      });
    },
    /**
     * 薬剤マスタと薬剤セットマスタの取得.
     */
    async readMedicineItems() {
      const requestParam = {
        // add マスタ一覧 施設切替を可能とする 王 start
        // facilityCd: this.getFacilityCd
        facilityCd: this.getFacilitySwitch
        // add マスタ一覧 施設切替を可能とする 王 end
      };
      const arr = await ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam);
      const response = await this.fetchMedicineAll(this.getFacilitySwitch);
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      const resData = response[2].data.lists.list3.items.filter(item => item.isDisp == 1 && item.isDel == 0);
      const normalMedicines = resData.filter(e =>{
        return e.key_type == CODES.MEDICINE_TYPE.NORMAL.cd
      });
      const mixMedicines = resData.filter(e =>{
        return e.key_type == CODES.MEDICINE_TYPE.MIX.cd
      }); 
      /*const normalMedicines = response[0].data.filter(e =>{
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return e.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd
        return e.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      });
      const mixMedicines = response[0].data.filter(e =>{
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        //return e.medicineType === CODES.MEDICINE_TYPE.MIX.cd
        return e.medicineType == CODES.MEDICINE_TYPE.MIX.cd
        // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      });*/
      // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      // mod FNSI- 変数tempArrは未使用，ideaでスタートの時は失敗しました。 徐博 start
      // let tempArr = [];
      // mod FNSI- 変数tempArrは未使用，ideaでスタートの時は失敗しました。 徐博 end
      for(let i = 0 ; i < arr.data.length ; i++){
        let temp = 0;
        for(let j = 0 ; j < normalMedicines.length ; j++){
          if(normalMedicines[j].medicineCd != arr.data[i].medicineCd){
            temp ++;
          }
          if(temp == normalMedicines.length){
            let tempObj = {
              "medicineType": "1",
              "medicineCd": arr.data[i].medicineCd,
              "medicineName": arr.data[i].medicineName,
              "unit": arr.data[i].unit,
              "unitSecond": arr.data[i].unitSecond,
              "isDisp": arr.data[i].isDisp,
              "classCd": arr.data[i].classCd,
              "unitDecimalPoint": arr.data[i].unitDecimalPoint,
              "unitDecimalPointSecond": arr.data[i].unitDecimalPointSecond
            }
            normalMedicines.push(tempObj)
          }
        }
      }

      return {
        // 薬剤マスタ
        medicines: normalMedicines.map(e => {
          return {
            code: e.medicineCd,
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
            //name: e.medicineName,
            name: (e.key_type == 2 && e.key_class == -1 ? CLASS_MISMATCH_LABEL : '') + e.tabooAllergy + e.expired + e.deleted + e.includeDeleted + e.medicineName,
            // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
            unit: e.unit,
            decPoint: e.unitDecimalPoint
          };
        }),
        // 調整薬剤マスタ
        medicinesMix: mixMedicines.map(e => {
          return {
            // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
            //code: e.medicineCd,
            code: e.medicineMixCd,
            //name: e.medicineName,
            name: (e.key_type == 2 && e.key_class == -1 ? CLASS_MISMATCH_LABEL : '') + e.tabooAllergy + e.expired + e.deleted + e.includeDeleted + e.medicineMixName,
            // mod/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
            unit: e.unit,
            decPoint: e.unitDecimalPoint
          };
        })
      };
    },
    /**
     * 手技マスタの取得.
     */
    async readProcedureItems() {
      const response = await this.fetchProcedureAll(this.getFacilitySwitch);

      return response.data.map(e => {
        return {
          code: e.procedureCd,
          name: e.pricedureName
        };
      });
    },
    /**
     * 手技マスタの取得（削除済み含む）.
     */
    async readProcedureItemsIncludeDeleted() {
      const response = await this.fetchProcedureAllIncludeDeleted(this.getFacilitySwitch);

      return response.data.map(e => {
        return {
          code: e.procedureCd,
          name: e.isDel == "1" || e.isDisp == "0"? MASTER_DELETE_DISPLAY.DELETED+e.pricedureName:e.pricedureName
        };
      });
    },
    /**
     * 一覧の領域（高さ）を再計算します.
     */
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hh = Array.prototype.slice
        .call(document.getElementsByClassName("header"))
        .pop().clientHeight;
      const fmh =
        (this.isDispMenu === 1
          ? document.getElementById("footer-menu").clientHeight
          : 0) + 5;
      this.gridToolbarHeight = wh - hh - fmh;
      this.gridToolbarHeight =
        this.gridToolbarHeight < 340 ? 340 : this.gridToolbarHeight;

      this.calculateGridFooterAreaHeight();
    },
    /**
     * 一覧の領域（高さ）の再計算時のフッターエリアの情報を取得し計算
     */
     calculateGridFooterAreaHeight() {

      const gfh = document.getElementById("grid-footer").clientHeight;

      // 反映ボタンのみの場合、CSV取込・並び順表示ボタンの改行分の考慮不要
      switch (this.getFontSize) {
        case 0:
          if(this.isSortMode || this.windowWidth > 637) {
            this.gridHeight = this.gridToolbarHeight - (gfh + 24);
          } else {
            this.gridHeight = this.gridToolbarHeight - (gfh + 48);
          }
          break;
        case 1:
          if(this.isSortMode || this.windowWidth > 676) {
            this.gridHeight = this.gridToolbarHeight - (gfh + 32);
          } else {
            this.gridHeight = this.gridToolbarHeight - (gfh + 63);
          }
          break;
        case 2:
          if(this.isSortMode || this.windowWidth > 696) {
            this.gridHeight = this.gridToolbarHeight - (gfh + 34);
          } else {
            this.gridHeight = this.gridToolbarHeight - (gfh + 67);
          }
          break;
        case 3:
          if(this.isSortMode || this.windowWidth > 735) {
            this.gridHeight = this.gridToolbarHeight - (gfh + 41);
          } else {
            this.gridHeight = this.gridToolbarHeight - (gfh + 79);
          }
          break;
        }
    },
    /**
     * 並び順表示・反映ボタン押下時のフッターエリアの高さ調整
     */
     calculateRankSortEventGridFooterAreaHeight() {
      if(this.isSortMode) {
        switch (this.getFontSize) {
          case 0:
            if(this.windowWidth > 637) {
              this.gridHeight = this.gridHeight + 24;
            } else {
              this.gridHeight = this.gridHeight + 48;
            }
            break;
          case 1:
            if(this.windowWidth > 676) {
              this.gridHeight = this.gridHeight + 29;
            } else {
              this.gridHeight = this.gridHeight + 58;
            }
            break;
          case 2:
            if(this.windowWidth > 696) {
              this.gridHeight = this.gridHeight + 35;
            } else {
              this.gridHeight = this.gridHeight + 66;
            }
            break;
          case 3:
            if(this.windowWidth > 735) {
              this.gridHeight = this.gridHeight + 39;
            } else {
              this.gridHeight = this.gridHeight + 81;
            }
            break;
        }
      } else {
        switch (this.getFontSize) {
          case 0:
            if(this.windowWidth > 637) {
              this.gridHeight = this.gridHeight - 24;
            } else {
              this.gridHeight = this.gridHeight - 48;
            }
            break;
          case 1:
            if(this.windowWidth > 676) {
              this.gridHeight = this.gridHeight - 29;
            } else {
              this.gridHeight = this.gridHeight - 58;
            }
            break;
          case 2:
            if(this.windowWidth > 696) {
              this.gridHeight = this.gridHeight - 35;
            } else {
              this.gridHeight = this.gridHeight - 66;
            }
            break;
          case 3:
            if(this.windowWidth > 735) {
              this.gridHeight = this.gridHeight - 39;
            } else {
              this.gridHeight = this.gridHeight - 81;
            }
            break;
        }
      }
    },
    /**
     * 愁訴マスタの第2ソートキーを設定します.
     */
    setSortRankSecondComplaint(index) {
      if(this.dataSource.mstComplaints[index-1].initSortRankFirst != this.dataSource.mstComplaints[index-1].sortRankFirst) {
        this.dataSource.mstComplaints[index-1].setSortRankSecond();
      }
      this.editMstComplaint(this.dataSource.mstComplaints[index-1])
    },
    /**
     * 処置マスタの第2ソートキーを設定します.
     */
    setSortRankSecondCompTreatment(index) {
      // #9863 Cannot read properties of undefined (reading 'initSortRankFirst') 横展開2 linjunfeng start
      // if(this.dataSource.mstComplaints[index-1].initSortRankFirst != this.dataSource.mstCompTreatments[index-1].sortRankFirst) {
      if(this.dataSource.mstComplaints[index-1]?.initSortRankFirst != this.dataSource.mstCompTreatments[index-1]?.sortRankFirst) {
      // #9863 Cannot read properties of undefined (reading 'initSortRankFirst') 横展開2 linjunfeng send 
        this.dataSource.mstCompTreatments[index-1].setSortRankSecond();
      }
      this.editMstCompTreatment(this.dataSource.mstCompTreatments[index-1])
    },
    /**
     * ソートのスタイルを定義する.
     */
    getRowStyleClassSort(data) {
      // 削除エリアで「削除」選択時 -> "master-deleted-row"
      // 並び順変更時 -> "sort-edited"
      return data.initData?.is_disp === "0" && data.isDel ? "master-deleted-row" : data.sortRankSecond !== 0 ? "sort-edited" : ""
    },
    /**
     * 編集状態のスタイルを定義する.
     */
    getRowStyleClassEdit(data, isColumnDeleted) {
      return [
        // 削除エリアで「削除」選択時 -> "master-deleted-row"
        // 有効エリアで編集 or「削除」選択時 -> "master-edited-row"
        data.initData?.is_disp === "0" && data.isDel ? "master-deleted-row" : !data.up_date || data.isDel ? "master-edited-row" : "",
        isColumnDeleted ? "master-deleted-combo" : ""
      ];
    },
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            // add 全マスタメッセージ調整 王 start
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: DIALOG_MESSAGES[12000014].message,
            // add 全マスタメッセージ調整 王 end
            callback: answer => {
              if (answer === 1) {
                this.findList();
              }
            }
          });
        } else {
          this.findList();
        }
      }
    },
    // add start #9590
    async findList () {
      this.setLoadingScreenVisible(true);
      await this.findMasterRecords();
      await this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch);
      // カラム定義情報を取得 ※CSV取込の際のvalidationで使用
      this.findColumnInfo();
      this.setLoadingScreenVisible(false);
    },
    // add end #9590
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start

    accordingToScreenWidth() {
      this.calculateGridHeight();
    }
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize"
    }),
    ...mapGetters("mst-complaint", {
      getFilteredDataSource: "getFilteredDataSource",
      isChanged: "isChanged",
      allMstComplaints: "getAllMstComplaints",
      allMstCompTreatments: "getAllMstCompTreatments"
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      , getNotDelLenght: "getNotDelLenght",
      // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    }),
    ...mapActions("mst-complaint", {
      getMstComplaint: "getMstComplaint",
      getMstCompTreatment: "getMstCompTreatment"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    isChanged(){
      if (this.allMstComplaints.some(e => !e.up_date || (e.initData!=null && e.isSortedOrChangeDisp()))) return true;
      if (this.allMstCompTreatments.some(e => !e.up_date || (e.initData!=null &&e.isSortedOrChangeDisp()))) return true;
      return false;
    },
    /**
     * 愁訴処置マスタを取得する.
     */
    dataSource() {
      // mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
      // return this.getFilteredDataSource;
      const dataSource = this.getFilteredDataSource;
      this.notDelLenght = this.getNotDelLenght;
      return dataSource;
      // mod #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
    },
    /**
     * main部の高さをCSS変数を利用して書き換える.
     */
    heightStyles() {
      return { "--height": `${this.gridToolbarHeight}px` };
    },
    /**
     * グリッドの高さをCSS変数を利用して書き換える.
     */
    gridHeightStyle() {
      return { "--height": `${this.gridHeight}px` };
    }
  },
  watch: {
    /**
     * ウィンドウの高さが変化した時のイベント処理
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    /**
     * メニュー表示が変化した時のイベント処理
     */
    isDispMenu() {
      this.calculateGridHeight();
    },
    /**
     * フォントサイズが変化した時のイベント処理
     */
    getFontSize() {
      this.calculateGridHeight();
    },

    windowWidth: {
      handler() {
       this.accordingToScreenWidth();
      }
    }
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    this.setLoadingScreenVisible(true);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 検索条件のクリア
    this.setCondition({
      freeWord: "",
      includeDeleted: false
    });
    // 初期データ取得
    // add #9590 start
    this.findList();
    // add #9590 end
    this.$nextTick(function(){
      this.setLoadingScreenVisible(false);
      this.accordingToScreenWidth();
    });
    // add 愁訴処置マスタ CSVファイル取込失敗 商 start   del #9590 start
    // this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
    //     .then(response => {});
    // add 愁訴処置マスタ CSVファイル取込失敗 商 end  del #9590 end
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start
    this.getFilteredDataSource;
    this.notDelLenght = this.getNotDelLenght;
    // add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start
    EventBus.$on("refresh", this.refresh);
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start
  },
  beforeDestroy() {
    // ストアクリア
    this.setMstComplaints([]);
    this.setMstCompTreatments([]);
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start
    EventBus.$off("refresh", this.refresh);
    // add 愁訴処置マスタ 障害対応 No235 データを更新→マスタ一覧リンクを押下→メッセージが表示されない 孔 start
  }
};
</script>

<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.grid-toolbar {
  padding: 0.1em 0.3em;
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 0.8em 0em 0.8em;
  line-height: 2em;
  width: auto;
}
.scroll-table {
  width: 100%;
  --height: 500px;
  height: var(--height);
  overflow: auto;
  overflow-x: auto;
  overflow-y: scroll;
}
.grid-record-list {
  border-collapse: collapse;
  margin: 0;
  /* add 鞠 4564処置追加ボタンの位置の影響に長さの修正 start*/
  width:100%;
  /* add 鞠 4564処置追加ボタンの位置の影響に長さの修正 end*/
  background-color: var(--ntss-list-background-color);
}
.grid-record-list tr:nth-child(2n){
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
.grid-record-list >>> ons-input .text-input  {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-item-background-color);
}
.ntss-list-header-th-sticky {
  z-index: 1;
}
.grid-line:nth-child(8n+1):not(:nth-child(1)) {
  border-top: solid 2px var(--master-maintenance-complaint-per-page-border);
}
/* add #9176 愁訴処置マスタが正しくコンバートできていない dengshen start */
.grid-line-B {
  border-top: solid 2px var(--master-maintenance-complaint-per-page-border);
}
/* add #9176 愁訴処置マスタが正しくコンバートできていない dengshen end */
.grid-line-page {
  background-color: var(--master-maintenance-complaint-per-page-background-color);
  width: 18px;
}
.grid-line-td {
  border-left: solid 2px var(--master-maintenance-complaint-treatment-border);
}
td.disp-select-box {
  width: 5em;
}
.selectbox >>> .select-input {
  font-size: 1.0em;
  font-weight: bold;
}
.sort-rank {
  /* font-size: 0.7em; */
  width: 6em;
  padding: 0px;
  padding-left: 0.3em;
}
/* .sort-rank >>> ons-input {
  width: 8em;
  border: none;
} */
.dummy-sort-column {
  /* padding: 0.5em; */
}
.sort-edited {
  background-color: #ffff66;
  color: #333333;
}
.sort-edited >>> ons-input .text-input {
  background-color: #ffff66;
}
.dummy-row {
  background-color: var(--master-maintenance-complaint-dummy-row-background-color);
}
.dummy-row-none {
  background-color: var(--master-maintenance-complaint-dummy-row-background-color);
  display: none;
}
.sort-rank >>> .k-numerictextbox {
  width: 100%;
}
.ntss-list-body-td {
  padding: 0.25rem 0.75rem !important
}
.ntss-list-body-td >>> input.k-textbox {
  width: 100%;
}
.complaint-button{
  max-width: 30.2%;
  min-width: 442px;
  margin-bottom: 0.1em;
}
.treatment-button {
  max-width: 30%;
  min-width: 109px;
}
.csv-rank-group-button {
  flex: fit-content;
  margin-left: auto;
}
</style>
<style>
/* del #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng start */
/* #8745 は必須入力です。追加 林峻峰 start */
/* .k-tooltip-validation {
    border-color: none;
    color: white;
    background-color: black;
}
.k-tooltip-validation .k-callout{
  display: block;
}
.grid-record-list
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation {
  bottom: 30px !important;
}
.grid-record-list
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
} */
/* #8745 は必須入力です。追加 林峻峰 end */
/* del #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。linjunfeng end */
.master-deleted-row {
    background-color: #9d9d9d !important;
    color: #333333;
}
/* 削除となっている偶数行 */
.grid-record-list tr:nth-child(2n) td.master-deleted-row {
    background-color: #aaaaaa !important;
}
</style>
