<template>
<!-- eslint-disable -->
  <div class="ind-plan-create">
    <v-ons-row class="cond-row-style">
      <v-ons-col class="indInfo-style-label-position">
        <label>予定内容</label>
      </v-ons-col>
      <!-- mod 画面デザイン改善対応 李 start -->
      <!-- <v-ons-col>
        <v-ons-select
          id="testId"
          v-model="selectedSet"
          style="width: 100%;"
          class="common-style-input"
          :disabled="updateDisable"
        >
          <option
            v-for="treatset in TreatSetList"
            :key="treatset.cd"
            :value="treatset"
          >
            {{ treatset.label }}
          </option>
        </v-ons-select>
      </v-ons-col> -->
      <v-ons-col>
        <!-- add FNSI 373,374修正対応 陳 start -->
        <div v-if="selOrdNo === 'selOrdNo'">
        <!-- add FNSI 373,374修正対応 陳 end -->

        <!-- mod bug 8003 修正 chen start -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-select -->
        <!--   id="v-ons-select-id" -->
        <!--   v-model="selectedSet.cd" -->
        <!--   style="width: 60%;" -->
        <!--   class="common-style-input" -->
        <!--   :disabled="updateDisable" -->
        <!--   @change="changeSelectedSet($event);changeInterval" -->
        <!-- > -->
        <v-ons-select
          id="v-ons-select-id"
          v-model="selectedSet.cd"
          style="width: 60%;"
          class="common-style-input"
          :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
          @change="changeSelectedSet($event);changeInterval"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <option
            v-for="treatset in TreatSetList"
            :key="treatset.cd"
            :value="treatset.cd"
          >
            {{ treatset.label }}
          </option>
        </v-ons-select>
        <!-- add FNSI 373,374修正対応 陳 start -->
        </div>
        <div v-if="selOrdNo !== 'selOrdNo'">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   id="v-ons-select-id" -->
          <!--   v-model="selectedSet.cd" -->
          <!--   style="width: 100%;" -->
          <!--   class="common-style-input" -->
          <!--   :disabled="updateDisable" -->
          <!--   @change="changeSelectedSet($event)" -->
          <!-- > -->
          <v-ons-select
          id="v-ons-select-id"
          v-model="selectedSet.cd"
          style="width: 100%;"
          class="common-style-input"
            :disabled="updateDisable || !getItemAuthorized('Indication', 'default_authority')"
          @change="changeSelectedSet($event)"
        >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod bug 8003 修正 chen end -->
          <option
            v-for="treatset in TreatSetList"
            :key="treatset.cd"
            :value="treatset.cd"
          >
            {{ treatset.label }}
          </option>
        </v-ons-select>
        </div>
        <!-- mod FNSI 373,374修正対応 陳 start -->
      </v-ons-col>
      <!-- mod 画面デザイン改善対応 李 end -->
    </v-ons-row>
    <div v-if="showPastInd">
      <v-ons-row class="cond-row-style">
        <v-ons-col class="indInfo-style-label-position" style="white-space: nowrap;">
          <label></label>
        </v-ons-col>
        <v-ons-col>
          <label>{{ selectedTreatDate }}</label>
          <!-- mod 9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start -->
          <!-- <v-ons-select
            v-model="selectedOrdMain"
            style="width: 60%;"
            class="common-style-input d-inline-flex"
          >
            <option
              v-for="ordMain in ordMainList"
              :key="ordMain.ordNo"
              :value="ordMain"
            > -->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-select -->
          <!--   v-model="selectedOrdMain.ordNo" -->
          <!--   style="width: 60%;" -->
          <!--   class="common-style-input d-inline-flex" -->
          <!-- > -->
          <v-ons-select
            v-model="selectedOrdMain.ordNo"
            style="width: 60%;"
            class="common-style-input d-inline-flex"
            :disabled="!getItemAuthorized('Indication', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <option
              v-for="ordMain in ordMainList"
              :key="ordMain.ordNo"
              :value="ordMain.ordNo"
            >
          <!-- mod 9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end -->
              {{ ordMain.label }}
            </option>
          </v-ons-select>
          <custom-calendar
            v-model="selectedDialDate"
            :selected-dates="selectedDates"
            @input="setOrdMainList"
          />
        </v-ons-col>
      </v-ons-row>
    </div>
    <div class="cond-table-style">
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style cond-td-style" id="treatment-width"
          >治療方法</v-ons-col
        >
        <v-ons-col class="cond-item-style cond-td-style">{{
          treatName
        }}</v-ons-col>
      </v-ons-row>
      <!-- mod FNSI 373,374修正対応 陳 start -->
      <v-ons-row class="ons-row list-content-row" v-if="selOrdNo == 'selOrdNo'">
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >スケジュール</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row class="ons-row" v-for="sch in schInfo" :key="sch.cd">
            <v-ons-col
              class="cond-title-style cond-td-style column-size"
              style="height: 100%;"
              >{{ sch.label }}</v-ons-col
            >
            <v-ons-col class="cond-item-style cond-td-style" v-if="sch.label == 'クール'">
              <v-ons-select
                style="width: 100%;"
                class="common-style-input"
                :disabled="updateDisable"
                v-model="kurInfo"
              >
                <!-- mod #8347 【デグレ】????患者治療割り当てができない dou start-->
                <!--mod FNSI redMine #5116 陳 start-->
                  <!-- <option
                    v-for="mstKur in mstKurInfo"
                    :key="mstKur.kurCd"
                    :value="mstKur"
                    :selected="sch.value == mstKur.kurName"
                  > -->
                <!-- <option-->
                <!--   v-for="mstKur in mstKurInfoBack"-->
                <!--   :key="mstKur.kurCd"-->
                <!--   :value="mstKur"-->
                <!--   :selected="sch.value == mstKur.kurName"-->
                <!-- >-->
                <!--mod FNSI redMine #5116 陳 end-->
                <option
                  v-for="mstKur in mstKurInfo"
                  :key="mstKur.kurCd"
                  :value="mstKur"
                  :selected="sch.value == mstKur.kurName"
                >
                <!-- mod #8347 【デグレ】????患者治療割り当てができない dou end-->
                  {{ mstKur.kurName }}
                </option>
              </v-ons-select>
            </v-ons-col>
            <v-ons-col class="cond-item-style cond-td-style" v-else-if="sch.label == '治療開始時刻'">
              {{ standardStartTime }}
            </v-ons-col>
            <v-ons-col class="cond-item-style cond-td-style" v-else>
              {{ dataBedName }}
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
       <!-- del 8117 治療方法編集画面から治療方法セットを適用すると既に設定しているクール・ベッド・治療開始時刻がすべて未登録となる 張 start -->
      <!-- <v-ons-row class="ons-row" v-else>
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >スケジュール</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row class="ons-row" v-for="sch in schInfo" :key="sch.cd">
            <v-ons-col
              class="cond-title-style cond-td-style column-size"
              style="height: 100%;"
              >{{ sch.label }}</v-ons-col
            >
            <v-ons-col class="cond-item-style cond-td-style">{{
              sch.value
            }}</v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row> -->
      <!-- del 8117 治療方法編集画面から治療方法セットを適用すると既に設定しているクール・ベッド・治療開始時刻がすべて未登録となる 張 end -->
      <!-- mod FNSI 373,374修正対応 陳 end -->
      <v-ons-row class="ons-row list-content-row">
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >治療条件</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row
            class="ons-row"
            v-for="cond in tblCondInfo"
            :key="cond.cond"
          >
            <v-ons-col
              v-show="cond.show"
              class="cond-title-style cond-td-style column-size"
              >{{ cond.label }}</v-ons-col
            >
            <v-ons-col v-show="cond.show" class="cond-item-style cond-td-style" :class="[{ 'cell-disabled': cond.isDisabled }, { 'taboo-allergy': cond.isTabooAllergy }]"
              >{{ cond.value }}{{ cond.unit }}</v-ons-col
            >
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="medishow && mediInfoRow" :class="{ 'list-content-row': medishow && mediInfoRow }">
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >投与薬剤</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row
            class="cond-td-style ons-row"
            :class="{ 'taboo-allergy': medi.isTabooAllergy }"
            v-for="medi in tblMediInfo"
            :key="medi.key"
          >
            <v-ons-col>
              <v-ons-row class="ons-row">
                <v-ons-col class="cond-title-style column-size">薬剤</v-ons-col>
                <v-ons-col class="cond-item-style">{{
                  medi.medicine
                }}</v-ons-col>
              </v-ons-row>
              <v-ons-row class="ons-row">
                <v-ons-col class="cond-title-style column-size"
                  >投与間隔</v-ons-col
                >
                <v-ons-col class="cond-item-style">{{
                  medi.interval
                }}</v-ons-col>
              </v-ons-row>
              <v-ons-row class="ons-row">
                <v-ons-col class="cond-title-style column-size">数量</v-ons-col>
                <v-ons-col class="cond-item-style">{{ medi.amount }}</v-ons-col>
              </v-ons-row>
              <v-ons-row class="ons-row">
                <v-ons-col class="cond-title-style column-size">手技</v-ons-col>
                <v-ons-col class="cond-item-style">{{
                  medi.procedure
                }}</v-ons-col>
              </v-ons-row>
              <v-ons-row class="ons-row">
                <v-ons-col class="cond-title-style column-size"
                  >投与タイミング</v-ons-col
                >
                <v-ons-col class="cond-item-style">{{ medi.timing }}</v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="!medishow && mediInfoRow">
        <v-ons-col width="185px" class="cond-title-style cond-td-style medi-title-style"
          >投与薬剤</v-ons-col
        >
        <v-ons-col class="cond-td-style"></v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="equipshow" :class="{ 'list-content-row': equipshow}">
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >医療材料</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row
            class="cond-td-style ons-row"
            :class="{ 'taboo-allergy': equip.isTabooAllergy }"
            v-for="equip in tblEquipInfo"
            :key="equip.key"
          >
            <v-ons-col>
               <!-- 1件の時は高さが足りなくなるので補正 -->
              <v-ons-row class="ons-row" :style="{ 'height': tblEquipInfo.length === 1 ? '50%' : 'auto' }">
                <v-ons-col class="cond-title-style column-size" id="sub-equip"
                  >医療材料</v-ons-col
                >
                <v-ons-col class="cond-item-style">{{
                  equip.equipment
                }}</v-ons-col>
              </v-ons-row>
              <v-ons-row class="ons-row" :style="{ 'height': tblEquipInfo.length === 1 ? '50%' : 'auto' }">
                <v-ons-col class="cond-title-style column-size">数量</v-ons-col>
                <v-ons-col class="cond-item-style">{{
                  equip.amount
                }}</v-ons-col>
              </v-ons-row>
              <!-- 治療方法セットには項目が存在しない為、非表示とする -->
              <v-ons-row class="ons-row" style="display: none;">
                <v-ons-col class="cond-title-style column-size"
                  >穿刺針区分</v-ons-col
                >
                <v-ons-col class="cond-item-style">{{
                  equip.needle
                }}</v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="!equipshow">
        <v-ons-col width="185px" class="cond-title-style cond-td-style equip-title-style" id="equip-title"
          >医療材料</v-ons-col
        >
        <v-ons-col class="cond-td-style"></v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="commentshow" :class="{ 'list-content-row': commentshow}">
        <v-ons-col width="30px" class="cond-header-style cond-td-style"
          >指示コメント</v-ons-col
        >
        <v-ons-col class="cond-item-main-style">
          <v-ons-row
            class="cond-td-style ons-row"
            v-for="comment in tblCommentInfo"
            :key="comment.key"
          >
            <v-ons-col>
              <v-ons-row class="comment-content">
                <v-ons-col class="cond-title-style column-size"
                  >コメント</v-ons-col
                >
                <v-ons-col class="cond-item-style">{{
                  comment.content
                }}</v-ons-col>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row class="ons-row" v-show="!commentshow">
        <v-ons-col width="185px" class="cond-title-style cond-td-style comment-title-style"
          >指示コメント</v-ons-col
        >
        <v-ons-col class="cond-td-style"></v-ons-col>
      </v-ons-row>

      <!-- 除水プログラム -->
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          <!-- mod FNSI-UFRプログラムの修正 楊 start -->
          <!-- UFRプログラム -->
          除水プログラム
          <!-- mod FNSI-UFRプログラムの修正 楊 end -->
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          {{ getDeviceSetMode(DEVICE_TYPE_UFR) }}
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          <!-- mod FNSI-UFRプログラムの修正 楊 start -->
          <!-- UFRプログラム -->
          除水プログラム
          <!-- mod FNSI-UFRプログラムの修正 楊 end -->
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="getDeviceSetMode(DEVICE_TYPE_UFR) === 'ON'"
            :data="getDeviceSetData(DEVICE_TYPE_UFR)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
          <div v-else-if="getDeviceSetMode(DEVICE_TYPE_UFR) === 'OFF'">OFF</div>
        </v-ons-col>
      </v-ons-row>

      <!-- Na注入プログラム -->
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          Na注入プログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          {{ getDeviceSetMode(DEVICE_TYPE_NA) }}
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          Na注入プログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="getDeviceSetMode(DEVICE_TYPE_NA) === 'ON'"
            :data="getDeviceSetData(DEVICE_TYPE_NA)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
          <div v-else-if="getDeviceSetMode(DEVICE_TYPE_NA) === 'OFF'">OFF</div>
        </v-ons-col>
      </v-ons-row>

      <!-- 透析液濃度プログラム -->
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          透析液濃度プログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          {{ getDeviceSetMode(DEVICE_TYPE_DC) }}
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          B液濃度プログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="getDeviceSetMode(DEVICE_TYPE_DC) === 'ON'"
            :data="getDeviceSetData(DEVICE_TYPE_DC, 0)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
          <div v-else-if="getDeviceSetMode(DEVICE_TYPE_DC) === 'OFF'">OFF</div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row>
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          透析液濃度プログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="getDeviceSetMode(DEVICE_TYPE_DC) === 'ON'"
            :data="getDeviceSetData(DEVICE_TYPE_DC, 1)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
          <div v-else-if="getDeviceSetMode(DEVICE_TYPE_DC) === 'OFF'">OFF</div>
        </v-ons-col>
      </v-ons-row>

      <!-- QB・QDプログラム -->
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          QB・QDプログラム
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="getDeviceSetMode(DEVICE_TYPE_QBQD) === 'ON'"
            :data="getDeviceSetData(DEVICE_TYPE_QBQD)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
          <div v-else-if="getDeviceSetMode(DEVICE_TYPE_QBQD) === 'OFF'">OFF</div>
        </v-ons-col>
      </v-ons-row>

      <!-- I-HDF設定 -->
      <v-ons-row class="ons-row">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          I-HDF設定
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <device-program-chart
            v-if="selectedTreatMethod === 10"
            :data="getDeviceSetData(DEVICE_TYPE_IHDF)"
            :show-tick-label="false"
            :height="100"
            :width="250"
          />
        </v-ons-col>
      </v-ons-row>

      <!-- BV-UFC -->
      <v-ons-row class="ons-row" v-if="isDispBvUfc">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          BV-UFC
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          {{ getDeviceSetMode(DEVICE_TYPE_BVUFC) }}
        </v-ons-col>
      </v-ons-row>

      <!-- 透析量プログラム -->
      <v-ons-row class="ons-row" v-if="isDispDialysisAmountProgram">
        <v-ons-col width="40%" class="cond-title-style-device-set cond-td-style">
          <div>透析量プログラム</div>
          <div class="cond-sub-title-style">目標Kt/V</div>
        </v-ons-col>
        <v-ons-col class="cond-item-style cond-td-style">
          <template v-if="getDeviceSetMode(DEVICE_TYPE_DIA) === 'ON'">
            <div>ON</div>
            <div>{{ getDeviceSetSrc(DEVICE_TYPE_DIA)["dev"]["A"][288].toFixed(2) }}</div>
          </template>
          <template v-else-if="getDeviceSetMode(DEVICE_TYPE_DIA) === 'OFF'">
            OFF
          </template>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import _ from "underscore";
import { ApiHelper } from "@/apis/AxiosHelper";
import { treatmentDel, treatmentSet } from "@/functions/mst/MstGetters.js";
import { dateFormat, fitTermCheckForUpdate } from "@/functions/common/DateTimeUtils";
import moment from "moment";
import CustomCalendar from "@/components/common/custom-calendar/CustomCalendar";
import { mapGetters, mapActions } from "vuex";
import $ from "jquery";
import BigNumber from "bignumber.js";
import DeviceProgramChart from "@/components/pat-info/device-set-info/DeviceProgramChart";
import {
  getDeviceSetInfoMst,
  getChartMode,
  createChartData
} from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
import * as DeviceSetInfoDef from "@/components/deviceset-info/base-modules/DeviceSetInfoDefinitions.js";
import { EventBus } from "@/eventBus.js";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
//add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 start
import { DEVICEMODE } from "@/constants/mstTreatmentDefine.js";
import { getDeviceSetInfoPat } from "@/components/deviceset-info/base-modules/DeviceSetInfoFunctions.js";
//add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 end
// add FNSI-FutreNetWeb+SI課題管理No.4705 李 start
import { ANTICOAGULANT_DEFAULT_SETTING } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import {deepCopy} from "@/functions/common/CommonFunctions";
// add FNSI-FutreNetWeb+SI課題管理No.4705 李 end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import router from "@/router";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

$(window).resize(function() {
  // 項目名列の横幅を設定
  columnWidthSet();
});

const columnWidthSet = () => {
  if ($(".cond-table-style").length === 0) {
    return;
  }
  const horizontalTitleW = $(".cond-header-style").width();
  const setWidth = $($("#treatment-width")[0]).width();
  $(".cond-title-style").each((index, elment) => {
    const width = `${setWidth - horizontalTitleW + 1}px`;
    switch ($(elment)[0].innerHTML) {
      case "治療方法":
        break;

      case "投与薬剤":
      case "指示コメント":
        $(elment)[0].style.minWidth = `${setWidth + 5.5}px`;
        $(elment)[0].style.maxWidth = `${setWidth + 5.5}px`;
        break;

      case "薬剤":
      case "投与間隔":
      case "数量":
      case "手技":
      case "投与タイミング":
      case "穿刺針区分":
      case "コメント":
          $(elment)[0].style.minWidth = `${setWidth - horizontalTitleW }px`;
          $(elment)[0].style.maxWidth = `${setWidth - horizontalTitleW }px`;
          break;

      default:
        if ($("#equip-title").length === 0) {
          $(elment)[0].style.minWidth = width;
          $(elment)[0].style.maxWidth = width;
        } else {
          if ($(elment)[0].innerHTML === "医療材料") {
            if ($(elment)[0].id !== "sub-equip") {
              $(elment)[0].style.minWidth = `${setWidth + 5.5}px`;
              $(elment)[0].style.maxWidth = `${setWidth + 5.5}px`;
            } else {
              $(elment)[0].style.minWidth = `${setWidth - horizontalTitleW }px`;
              $(elment)[0].style.maxWidth = `${setWidth - horizontalTitleW }px`;
            }
          } else {
            $(elment)[0].style.minWidth = width;
            $(elment)[0].style.maxWidth = width;
          }
        }
        break;
    }
  });
};

export default {
  components: {
    "custom-calendar": CustomCalendar,
    DeviceProgramChart
  },
  props: {
    /**
     * 患者ID
     */
    patId: {
      type: String,
      default: null
    },
    /**
     * 治療開始日
     */
    startDate: {
      type: String,
      default: null
    },
    /**
     * 治療終了日
     */
    endDate: {
      type: String,
      default: null
    },
    /**
     * 施設コード
     */
    facilityCd: {
      type: String,
      default: null
    },
    /**
     * 治療方法情報
     */
    isMediInfo: {
      type: Boolean,
      default: true
    },
    /**
     * 治療方法変更フラグ
     * trueの場合治療方法リストから過去日選択を失くす
     */
    isUpdateMethod: {
      type: Boolean,
      default: false
    },
    /**
     * クール名
     */
    indKurName: {
      type: String,
      default: "未登録"
    },
    /**
     * 治療開始時刻
     */
    indTreatStartTime: {
      type: String,
      default: "未登録"
    },
    /**
     * ベッド名
     */
    indBedName: {
      type: String,
      default: "未登録"
    },

    /**
     * 予定日
     */
    indStartDate: {
      type: String,
      default: null
    }
  },

  data() {
    return {
      ...DeviceSetInfoDef,
      selectedSet: { cd: "", upDate: "", treatmentCd: "", isTreatSet: true },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
      initSelectedSet: { cd: "", upDate: "", treatmentCd: "", isTreatSet: true },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      TreatSetList: [
        {
        }
      ],
      selectedOrdMain: { label: "", ordNo: "", upDate: "" },
      ordMainList: [
        {
        }
      ],
      treatInfo: { cd: "", name: "" },
      schInfo: [
        { cd: "1", label: "クール", value: "" },
        { cd: "2", label: "治療開始時刻", value: "" },
        { cd: "3", label: "ベッド", value: "" }
      ],
      condInfo: [
        { cond: "1", label: "治療時間", value: "", unit: "", show: true },
        { cond: "2", label: "VA", value: "", unit: "", show: true },
        // add 10443 身体情報・DW・目標体重バグ 関  start
        { cond: "39", label: "DW", value: "", unit: "", show: true },
        // add 10443 身体情報・DW・目標体重バグ 関  end
        { cond: "3", label: "目標体重", value: "", unit: "", show: true },
        { cond: "4", label: "除水量制限", value: "", unit: "", show: true },
        { cond: "5", label: "ダイアライザ", value: "", unit: "", show: true },
        { cond: "6", label: "吸着カラム", value: "", unit: "", show: true },
        { cond: "7", label: "1次膜", value: "", unit: "", show: true },
        { cond: "8", label: "2次膜", value: "", unit: "", show: true },
        { cond: "9", label: "穿刺針(A針)", value: "", unit: "", show: true },
        { cond: "10", label: "穿刺針(V針)", value: "", unit: "", show: true },
        { cond: "11", label: "穿刺針(SN)", value: "", unit: "", show: true },
        {
          cond: "12",
          label: "シングルニードル使用",
          value: "",
          unit: "",
          show: true
        },
        { cond: "13", label: "血液回路", value: "", unit: "", show: true },
        { cond: "14", label: "血流量", value: "", unit: "", show: true },
        { cond: "15", label: "透析液", value: "", unit: "", show: true },
        { cond: "16", label: "透析液流量", value: "", unit: "", show: true },
        { cond: "17", label: "透析液使用数", value: "", unit: "", show: true },
        { cond: "18", label: "透析液温度", value: "", unit: "", show: true },
        { cond: "19", label: "補液", value: "", unit: "", show: true },
        { cond: "20", label: "補液量", value: "", unit: "", show: true },
        { cond: "21", label: "補液選択", value: "", unit: "", show: true },
        { cond: "22", label: "補液使用数", value: "", unit: "", show: true },
        { cond: "23", label: "補液温度", value: "", unit: "", show: true },
        { cond: "24", label: "補液速度", value: "", unit: "", show: true },
        { cond: "25", label: "抗凝固剤", value: "", unit: "", show: true },
        {
          cond: "26",
          label: "抗凝固剤ワンショット量",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "27",
          label: "抗凝固剤持続速度",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "28",
          label: "抗凝固剤持続総量",
          value: "",
          unit: "",
          show: true
        },
        { cond: "29", label: "IP使用選択", value: "", unit: "", show: true },
        { cond: "30", label: "IPスタート", value: "", unit: "", show: true },
        { cond: "32", label: "IP速度", value: "", unit: "", show: true },
        { cond: "33", label: "IP速度最大値", value: "", unit: "", show: true },
        {
          cond: "34",
          label: "IPワンショットスタート",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "31",
          label: "IPワンショット量",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "35",
          label: "IP電源自動切り",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "36",
          label: "IP電源自動切り時間",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "37",
          label: "IP電源OKモニタ切り",
          value: "",
          unit: "",
          show: true
        },
        {
          cond: "38",
          label: "IP電源OKモニタ切り時間",
          value: "",
          unit: "",
          show: true
        },
      ],
      mediInfo: [
        {
          key: "キー",
          label: "ラベル",
          value: "値",
          medicine: "薬剤",
          interval: "投与間隔",
          amount: "数量",
          procedure: "手技",
          timing: "投与タイミング"
        }
      ],
      equipInfo: [
        {
          key: "キー",
          label: "ラベル",
          value: "値",
          needle: "穿刺針区分",
          equipment: "医療材料",
          amount: "数量"
        }
      ],
      commentInfo: [
        {
          key: "キー",
          label: "ラベル",
          ctlno: "管理番号",
          content: "コメント"
        }
      ],
      mstTreatSetInfo: null,
      selectedDialDate: "",
      selectedDates: [],
      selectedTreatDate: "",
      ordMainInfo: "",
      showPastInd: false,
      mstKurInfo: null,
      // add FNSI redMine #5116 陳 start
      mstKurInfoBack: [],
      // add FNSI redMine #5116 陳 end
      mstTreatmentInfo: null,
      mstVaInfo: null,
      mstDialyzerInfo: null,
      mstMedicineInfo: null,
      mstMedicineMixInfo: null,
      mstProcedureInfo: null,
      mstMedicateTimingInfo: null,
      mstEquipmentInfo: null,
      mstDeviceSetInfo: null,
      mstDialyzerTabooAllergyInfo: null,
      mstMedicineTabooAllergyInfo: null,
      mstMedicineMixTabooAllergyInfo: null,
      mstEquipmentTabooAllergyInfo: null,
      isWarnTabooAllergyFlag: false,
      isDispDialysisAmountProgram: false,
      isDispBvUfc: false,
      planStartDate: null,

      // add FNSI 373,374修正対応 陳 start
      updateDisable: false,
      // add FNSI 373,374修正対応 陳 end
      //    add FNSI redmine 劉祥霖 5923 start
      bedCd:"",
      //    add FNSI redmine 劉祥霖 5923 end
      // 期限切れの項目警告メッセージ
      expiredMsg: "",
      // add FNSI 373,374修正対応 陳 start
      kurInfo: '',
      standardStartTime: '',
      structDataBedName: '',
      dataBedName: '',
      selOrdNo: '',
      // add FNSI 373,374修正対応 陳 end
      // add 画面デザイン改善対応 李 start
      callsNumberFlg: false,
      firValue: null,
      // add 画面デザイン改善対応 李 end
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
      mstTreatDel: null,
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
      // add 10443 身体情報・DW・目標体重バグ 関  start
      dwOfDate: null,
      // add 10443 身体情報・DW・目標体重バグ 関  end
      // add 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  start
      targetWeightOfDate: null,
      // add 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  end
    };
  },
  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd","getAdvancedSettings"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    //患者ID取得用
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-info", ["selectedPat"]),

    // mod 10443 身体情報・DW・目標体重バグ 関  start
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 start
    ...mapGetters("pat-viewer", ["getMstTreatmentData","getPhysicalInfo"]),
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 end
    // mod 10443 身体情報・DW・目標体重バグ 関  end

    // add FNSI-FutreNetWeb+SI課題管理No.4705 李 start
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
    //mod 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
   // ...mapGetters("pat-viewer", ["getDispLayoutItemListData", "getSelectedCondition", "getIndPlanCreateDate"]),
   ...mapGetters("pat-viewer", ["getDispLayoutItemListData", "getSelectedCondition", "getIndPlanCreateDate","getSelectedLayout"]),
    //mod 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
    // add FNSI-FutreNetWeb+SI課題管理No.4705 李 end
    ...mapGetters("pat-viewer", ["getDispLayoutItemListData", "getSelectedCondition", "getIndPlanCreateDate","getSelectedLayout","getMstTreatmentDataIsDel"]),
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

    selectedTreatSet() {
      if (!this.selectedSet || !this.mstTreatSetInfo) {
        return null;
      } else if (this.selectedSet.isTreatSet) {
        return this.mstTreatSetInfo.find(
          ({ treatmentSetCd }) => treatmentSetCd === this.selectedSet.cd
        );
      } else {
        const ordMain = this.ordMainInfo.find(
          ({ ordNo }) => ordNo === this.selectedOrdMain.ordNo
        );

        return (
          ordMain && {
            treatmentCd: ordMain.indTreatmentCd,
            indCondInfo: ordMain.indCondInfo,
            indDeviceSetInfo: ordMain.indDeviceSetInfo
          }
        );
      }
    },

    selectedTreatMethod() {
      if (!this.mstTreatmentInfo || !this.selectedTreatSet) {
        return null;
      }

      const treat = this.mstTreatmentInfo.find(
        ({ treatmentCd }) => treatmentCd === this.selectedTreatSet.treatmentCd
      );
      return treat && treat.deviceMode;
    },

    selectedDeviceSetInfo() {
      return (
        this.selectedTreatSet &&
        this.selectedTreatSet.indDeviceSetInfo &&
        JSON.parse(this.selectedTreatSet.indDeviceSetInfo)
      );
    },

    medishow() {
      if (0 < Object.keys(this.mediInfo).length) {
        return true;
      } else {
        return false;
      }
    },

    equipshow() {
      if (0 < Object.keys(this.equipInfo).length) {
        return true;
      } else {
        return false;
      }
    },

    commentshow() {
      if (0 < Object.keys(this.commentInfo).length) {
        return true;
      } else {
        return false;
      }
    },

    treatName() {
      if (
        null === this.mstTreatSetInfo ||
        "" === this.selectedSet.cd ||
        null === this.mstTreatmentInfo
      ) {
        return this.treatInfo.name;
      }
      this.setTreatName();
      return this.treatInfo.name;
    },

    tblCondInfo() {
      if (null === this.mstTreatSetInfo) {
        return this.condInfo;
      }
      // 治療条件の更新
      this.setCondInfo();

      return this.condInfo;
    },

    tblMediInfo() {
      if (
        null === this.mstTreatSetInfo ||
        null === this.mstMedicineInfo ||
        null === this.mstMedicineMixInfo ||
        null === this.mstProcedureInfo ||
        null === this.mstMedicateTimingInfo
      ) {
        return [];
      }
      // 投与薬剤情報の更新
      this.setMediInfo();
      return this.mediInfo;
    },

    tblEquipInfo() {
      if (null === this.mstTreatSetInfo || null === this.mstEquipmentTabooAllergyInfo) {
        return [];
      }
      // 医療材料情報の更新
      this.setEuquipInfo();
      return this.equipInfo;
    },

    tblCommentInfo() {
      if (null === this.mstTreatSetInfo) {
        return [];
      }
      // 指示コメントの更新
      this.setCommentInfo();
      return this.commentInfo;
    },

    mediInfoRow() {
      if (!this.isMediInfo) {
        return false;
      } else {
        return true;
      }
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isChanged(){
      return this.initSelectedSet !== JSON.stringify(this.selectedSet)
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
  },

  watch: {
    //add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
    "selectedOrdMain.ordNo"() {
        var ordMainInfo = this.ordMainList.find(
          obj => obj.ordNo === this.selectedOrdMain.ordNo
        );
        this.selectedOrdMain = deepCopy(ordMainInfo);
    },
    //add #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
    /**
     * スケジュール情報の更新
     */
    // del FNSI-FutreNetWeb+SI課題管理の3822対応 韓 start
    // selectedSet() {
    //   this.schInfo[0].value = this.indKurName;
    //   this.schInfo[1].value = this.indTreatStartTime;
    //   this.schInfo[2].value = this.indBedName;

    //   this.setOrdMainList();
    //   setTimeout(() => {
    //     columnWidthSet();
    //   }, 500);
    // },
    // del FNSI-FutreNetWeb+SI課題管理の3822対応 韓 end

    // add FNSI 373,374修正対応 陳 start
    kurInfo() {
      this.mstKurInfo.forEach(e => {
        if (e.kurName == this.kurInfo.kurName) {
          this.standardStartTime = moment(e.kurStandardStartTime, "HHmm").format("HH:mm");
        }
      });
      this.dataBedName = this.structDataBedName;
    },
    // add FNSI 373,374修正対応 陳 end

    // add 画面デザイン改善対応 李 start
    selectedSet(val, oldVal) {
      // add FNSI-FutreNetWeb+SI課題管理の3822対応 韓 start
      this.schInfo[0].value = this.indKurName;
      this.schInfo[1].value = this.indTreatStartTime;
      this.schInfo[2].value = this.indBedName;

      this.setOrdMainList();
      setTimeout(() => {
        columnWidthSet();
      }, 500);
      // add FNSI-FutreNetWeb+SI課題管理の3822対応 韓 end
      // 初回ロード時、初期状態が記録され、初期値が保存される
      if (!this.callsNumberFlg) {
        this.callsNumberFlg = true;
        this.firValue = oldVal;
      }

      // 選択した値と初期値が異なる場合
      if (val.cd != this.firValue.cd) {
        $('#v-ons-select-id').addClass('custom-select-edited');
      } else {
        $('#v-ons-select-id').removeClass('custom-select-edited');
      }
    },
    // add 画面デザイン改善対応 李 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    isChanged(newValue){
      this.$emit('computedValueChanged',newValue);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
    // mod 10443 身体情報・DW・目標体重バグ 関  start
    'selectedSet.cd': function() {
      this.condInfo.forEach(item => {
        // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  start
        // if (item.cond === "39" && item.label === "DW") {
        //     item.value = this.dwOfDate;
        //     return;
        //   }
        if (item.cond === "39" && item.label === "DW") {
            item.value = this.dwOfDate;
          }
          if (item.cond === "3" && item.label === "目標体重" && this.targetWeightOfDate) {
            item.value = this.targetWeightOfDate;
          }
          // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  end
      })
    },
    // mod 10443 身体情報・DW・目標体重バグ 関  end
  },

  async created() {
    // IndEditBaseの変更イベント発火フラグをtrueに設定
    // add bug 8162 修正 chen start
    this.setLoadingScreenVisible(true);
    // add #8347 【デグレ】????患者治療割り当てができない dou start
    this.setLoadingScreenVisible(true);
    this.selOrdNo = this.$parent.selOrdNo;
    // add #8347 【デグレ】????患者治療割り当てができない dou end
    // add bug 8162 修正 chen end
    this.$parent.$parent.isWatchParentIndStartDate = true;
    this.planStartDate = this.indStartDate;

    if(!this.getAdvancedSettings.func_advcds) {
      this.getAdvancedSettings.func_advcds = [];
    }
    columnWidthSet();
    // 治療方法セットマスタの取得
    this.mstTreatSetInfo = await treatmentSet(this.getFacilityCd);
    // 治療情報の取得
    await this.getOrdmain();
    // 予定内容リストの更新
    await this.setTreatSetList();
    // クールマスタ取得
    await this.getMstKur();
    // 治療方法マスタの取得
    // mod 8003 投与薬剤を含む治療方法セットで治療予定の作成ができない 張 start
    // this.getMstTreatment();
    // // VAマスタの取得
    // this.getMstVa();
    // // ダイアライザマスタの取得
    // this.getMstDialyzer();
    // // 薬剤マスタの取得
    // this.getMstMedicine();
    // // 調製薬剤マスタの取得
    // this.getMstMedicineMix();
    // // 手技マスタの取得
    // this.getMstProcedure();
    // // 投与タイミングマスタの取得
    // this.getMstMedicateTiming();
    // // 医療材料マスタの取得
    // this.getMstEquipment();
    // // 装置設定デフォルトマスタの取得
    // this.getmstDeviceSetInfo();
    // // ダイアライザマスタの取得(禁忌・アレルギー込み)
    // this.getMstDialyzerTabooAllergy();
    // // 薬剤マスタの取得(禁忌・アレルギー込み)
    // this.getMstMedicineTabooAllergy();
    // // 調製薬剤マスタの取得(禁忌・アレルギー込み)
    // this.getMstMedicineMixTabooAllergy();
    // // 医療材料マスタの取得(禁忌・アレルギー込み)
    // this.getMstEquipmentTabooAllergy();
    await this.getMstTreatment();
    // VAマスタの取得
    await this.getMstVa();
    // ダイアライザマスタの取得
    await this.getMstDialyzer();
    // 薬剤マスタの取得
    await this.getMstMedicine();
    // 調製薬剤マスタの取得
    await this.getMstMedicineMix();
    // 手技マスタの取得
    await this.getMstProcedure();
    // 投与タイミングマスタの取得
    await this.getMstMedicateTiming();
    // 医療材料マスタの取得
    await this.getMstEquipment();
    // 装置設定デフォルトマスタの取得
    await this.getmstDeviceSetInfo();
    // ダイアライザマスタの取得(禁忌・アレルギー込み)
    await this.getMstDialyzerTabooAllergy();
    // 薬剤マスタの取得(禁忌・アレルギー込み)
    await this.getMstMedicineTabooAllergy();
    // 調製薬剤マスタの取得(禁忌・アレルギー込み)
    await this.getMstMedicineMixTabooAllergy();
    // 医療材料マスタの取得(禁忌・アレルギー込み)
    await this.getMstEquipmentTabooAllergy();
    // mod 8003 投与薬剤を含む治療方法セットで治療予定の作成ができない 張 end
    this.mediInfo = [];
    this.equipInfo = [];
    this.commentInfo = [];
    columnWidthSet();
    // add FNSI 373,374修正対応 陳 start
    this.structDataBedName = this.schInfo[2].value;
    // del #8347 【デグレ】????患者治療割り当てができない dou start
    // this.selOrdNo = this.$parent.selOrdNo;
    // del #8347 【デグレ】????患者治療割り当てができない dou end
    // add FNSI 373,374修正対応 陳 end
    //施設拡張設定項目表示制御
    this.viewAdvancedSettingsParam();
    // add bug 8162 修正 chen start
    this.setLoadingScreenVisible(false);
    // add #8347 【デグレ】????患者治療割り当てができない dou start
    this.setLoadingScreenVisible(false);
    // add #8347 【デグレ】????患者治療割り当てができない dou end
    // add bug 8162 修正 chen end
    // add bug 8003 修正 chen start
    this.firValue = deepCopy(this.selectedSet);
    // add bug 8003 修正 chen end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
    this.initSelectedSet = JSON.stringify(this.selectedSet);
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end

    // add 10443 身体情報・DW・目標体重バグ 関  start
    // 予定作成
    if (this.$parent.indStartDate != undefined) {
      this.changeDw(this.$parent.indStartDate, null);
      this.$watch(
        () => this.$parent.indStartDate,
        () => {
          this.changeDw(this.$parent.indStartDate, null);
        }
      );
    } else {

    // 予定作成
    if (this.$parent.$parent.structData != undefined) {
      this.changeDw(this.$parent.$parent.structData.indStartDate, this.$parent.$parent.structData.indWeeks);
      this.$watch(
        () => this.$parent.$parent.structData.indStartDate,
        () => {
          this.changeDw(this.$parent.$parent.structData.indStartDate, this.$parent.$parent.structData.indWeeks);
        }
      );
      this.$watch(
        () => this.$parent.$parent.structData.indWeeks,
        () => {
          this.changeDw(this.$parent.$parent.structData.indStartDate, this.$parent.$parent.structData.indWeeks);
        }, { deep: true }
      );
    }

    // 治療方法変更
    if (this.$parent.structData != undefined) {
      this.searchTreatDateDw();
      this.$watch(
        () => this.$parent.structData.indStartDate,
        (newValue) => {
        }
      );
      this.$watch(
        () => this.$parent.structData.indWeeks,
        (newValue) => {
        }, { deep: true }
      );
      this.$watch(
        () => this.$parent.structData.selectedTreat,
        (newValue) => {
          this.searchTreatDateDw();
        }
      );
      this.$watch(
        () => this.$parent.structData.selectedKur,
        (newValue) => {
          this.searchTreatDateDw();
        }
      );
    }

    }

    // add 10443 身体情報・DW・目標体重バグ 関  end
  },

  methods: {
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),

    // add bug 8003 修正 chen start
    ...mapActions('loading-screen', [
      'setLoadingScreenVisible',
      'setLoadingScreenMessage',
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // add bug 8003 修正 chen end
    // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
    ...mapActions('pat-viewer', [
      'setMstTreatmentDataIsDel',
    ]),
    // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    hideModal() {
      /* モーダル閉じる */
      this.$parent.$parent.$emit("hide-modal");
    },

    // add bug 8003 修正 chen start
    async changeSelectedSet(item) {
      this.selectedSet.upDate = this.TreatSetList[item.currentTarget.selectedIndex].upDate;
      this.selectedSet.treatmentCd = this.TreatSetList[item.currentTarget.selectedIndex].treatmentCd;
      this.selectedSet.isTreatSet = this.TreatSetList[item.currentTarget.selectedIndex].isTreatSet;
      this.selectedSet.label = this.TreatSetList[item.currentTarget.selectedIndex].label;
      this.schInfo[0].value = this.indKurName;
      this.schInfo[1].value = this.indTreatStartTime;
      this.schInfo[2].value = this.indBedName;

      this.setOrdMainList();
      setTimeout(() => {
        columnWidthSet();
      }, 500);
      if (!this.callsNumberFlg) {
        this.callsNumberFlg = true;
      }

      // 選択した値と初期値が異なる場合
      if (this.selectedSet.cd !== this.firValue.cd) {
        $('#v-ons-select-id').addClass('custom-select-edited');
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        this.$parent.$parent.editSelectIdFlg = true;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      } else {
        $('#v-ons-select-id').removeClass('custom-select-edited');
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc start
        this.$parent.$parent.editSelectIdFlg = false;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20231214 ztc end
      }
    },
    // add FNSI redMine #5116 陳 start
    async changeInterval() {

      //データの収集
      const sendJson = {};
      // 治療方法セットコード
      sendJson.treatment_set_cd = this.selectedSet.cd;
      // 治療日
      sendJson.treatDays = moment(this.$parent.indStartDate).format('YYYY-MM-DD');
//    add FNSI redmine 劉祥霖 5923 start
      sendJson.ind_bed_cd=this.bedCd;
//    add FNSI redmine 劉祥霖 5923 end
      //データの送信
      const response = await ApiHelper.post(
        "/mainData/getKurInfo/",
        sendJson
      ).catch(error => {

        getErrorMessage('IndPlanCreate.vue', 'createIndPlan', error);

        throw error;
      });

      if(response.status == 200 ){

        this.mstKurInfoBack = new Array();
        this.mstKurInfoBack = JSON.parse(JSON.stringify(this.mstKurInfo));
        //    mod FNSI redmine 劉祥霖 5923 start
        for (let i =0;i<this.mstKurInfoBack.length;i++) {
          for(let j=0;j<response.data.listInfo.length;j++){

            if(this.mstKurInfoBack[i].kurCd == response.data.listInfo[j]){

              // if (i == 2){
              //   this.mstKurInfoBack.splice(0,1);
              // } else {
              this.mstKurInfoBack.splice(i,1);
              i--;
              break;
              // }
            }
          }
        }
        // add #8347 【デグレ】????患者治療割り当てができない dou start
        this.mstKurInfo = this.mstKurInfoBack;
        // add #8347 【デグレ】????患者治療割り当てができない dou end
        //    mod FNSI redmine 劉祥霖 5923 end
      }
    },
    // add bug 8003 修正 chen end
    // add FNSI redMine #5116 陳 end

    /**
     * 治療情報の治療方法を更新する
     */
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
    //  setTreatName() {
    //   if (this.selectedSet.isTreatSet) {
    //     // 治療方法セットから取得
    //     const mstTreatSet = this.mstTreatSetInfo.filter(
    //       obj => obj.treatmentSetCd === this.selectedSet.cd
    //     );
    //     if (null === mstTreatSet || 1 > mstTreatSet.length) {
    //       return this.treatInfo.name;
    //     }
    //     this.treatInfo.cd = mstTreatSet[0].treatmentCd;
    //     const mstTreatment = this.mstTreatmentInfo.filter(
    //       obj => obj.treatmentCd === mstTreatSet[0].treatmentCd
    //     );
    //     if (0 < mstTreatment.length) {
    //       // 治療方法名
    //       this.treatInfo.name = mstTreatment[0].treatmentName;
    //     }
    async setTreatName() {
      if (this.selectedSet.isTreatSet) {
        // 治療方法セットから取得
        const mstTreatSet = this.mstTreatSetInfo.filter(
          obj => obj.treatmentSetCd === this.selectedSet.cd
        );
        if (null === mstTreatSet || 1 > mstTreatSet.length) {
          return this.treatInfo.name;
        }
        this.treatInfo.cd = mstTreatSet[0].treatmentCd;
        const mstTreatment = this.mstTreatmentInfo.filter(
          obj => obj.treatmentCd === mstTreatSet[0].treatmentCd
        );
        if (0 < mstTreatment.length) {
          // 治療方法名
          this.treatInfo.name = mstTreatment[0].treatmentName;
        }else {
          if (!this.getMstTreatmentDataIsDel) {
            // 治療方法マスタの削除データ取得
            this.mstTreatDel = await treatmentDel(this.getFacilityCd);
            this.setMstTreatmentDataIsDel(this.mstTreatDel);
          }
          const mstTreatmentDel = this.getMstTreatmentDataIsDel.filter(
          obj => obj.treatmentCd === mstTreatSet[0].treatmentCd
          );
          if (0 < mstTreatmentDel.length) {
            // 治療方法名
            this.treatInfo.name = `【削除済み】${mstTreatmentDel[0].treatmentName}`;
          }
        }
        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
      } else {
        // 治療情報から取得
        const ordmain = this.ordMainInfo.filter(
          obj => obj.ordNo === this.selectedOrdMain.ordNo
        );
        if (0 < ordmain.length) {
          this.treatInfo.cd = ordmain[0].indTreatmentCd;
          const mstTreatment = this.mstTreatmentInfo.filter(
            obj => obj.treatmentCd === ordmain[0].indTreatmentCd
          );
          if (0 < mstTreatment.length) {
            // 治療方法名
            this.treatInfo.name = mstTreatment[0].treatmentName;
          }
        }
      }
    },

    /**
     * 治療情報の治療条件情報を更新する
     */
    setCondInfo() {
      let mstTreatSet = null;
      if (this.selectedSet.isTreatSet) {
        // 治療方法セットから取得
        mstTreatSet = this.mstTreatSetInfo.filter(
          obj => obj.treatmentSetCd === this.selectedSet.cd
        );
      } else {
        // 治療情報から取得
        mstTreatSet = this.ordMainInfo.filter(
          obj => obj.ordNo === this.selectedOrdMain.ordNo
        );
      }
      if (null === mstTreatSet || 1 > mstTreatSet.length) {
        return this.condInfo;
      }

      const mstCondInfo = JSON.parse(mstTreatSet[0].indCondInfo);
      this.isWarnTabooAllergyFlag = false;
      var numbers = null;
      var decPoint = null;

      for (const key in mstCondInfo) {
        const cond = this.condInfo.filter(obj => obj.cond === key);

        // mod FNSI-障害票一覧_患者経過総合ビューアNo.48 李 start
        // cond[0].isTabooAllergy = false;
        if (cond[0]) cond[0].isTabooAllergy = false;
        // mod FNSI-障害票一覧_患者経過総合ビューアNo.48 李 end

        if (1 > cond.length) {
          continue;
        }

        // 治療方法セットマスタ/ord_mainに登録されている治療条件(JSONキーあり)の場合はisDisabledをfalseに設定
        cond[0].isDisabled = false;

        // value=nullの場合は"未登録"を表示
        if (mstCondInfo[key].value === null) {
          cond[0].value = "未登録";
          cond[0].unit = "";
          continue;
        }

        if ("1" === key) {
          // 治療時間
          cond[0].value = `${Math.floor(
            mstCondInfo[key].value / 60
          )}:${`00${mstCondInfo[key].value % 60}`.slice(-2)}`;
        } else if ("2" === key) {
          // VA
          const vaCd = mstCondInfo[key].value;
          if (null === vaCd || "" === vaCd) {
            cond[0].value = "";
          } else if (null !== this.mstVaInfo) {
            const mstVa = this.mstVaInfo.filter(obj => obj.vaCd == vaCd); // #9973 value Number→文字列
            if (0 < mstVa.length) {
              cond[0].value = mstVa[0].vaName;
            } else {
              cond[0].value = "削除済み";
            }
          }
        } else if ("3" === key) {
          // 目標体重
          // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  start
          // if (
          //   mstCondInfo[key].value == '-1' || // mod #9973 value Number→文字列  shiyw
          //   mstCondInfo[key].value === null
          // ) {
          //   cond[0].value = "DWと同じ";
          //   cond[0].unit = null;
          // } else {
          //   cond[0].value = (1 * mstCondInfo[key].value).toFixed(2);
          //   cond[0].unit = " kg";
          // }
          if (this.targetWeightOfDate === null) {
            if (
            mstCondInfo[key].value == '-1' || // mod #9973 value Number→文字列  shiyw
            mstCondInfo[key].value === null
          ) {
            cond[0].value = "DWと同じ";
            cond[0].unit = null;
          } else {
            cond[0].value = (1 * mstCondInfo[key].value).toFixed(2);
            cond[0].unit = " kg";
            }
          }
          // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  end
        } else if ("4" === key) {
          // 除水制限
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(2);
          cond[0].unit = " L";
        } else if ("5" === key) {
          // ダイアライザ
          const dialyzerCd = mstCondInfo[key].value;
          if (null === dialyzerCd || "" === dialyzerCd) {
            cond[0].value = "";
          } else if (null !== this.mstDialyzerTabooAllergyInfo) {
            const mstDialyzer = this.mstDialyzerTabooAllergyInfo.filter(
              obj => obj.dialyzerCd == dialyzerCd // mod #9973 value Number→文字列  shiyw
            );
            const mstDialyzerSub = this.mstDialyzerInfo.filter(
              obj => obj.dialyzerCd == dialyzerCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstDialyzer.length) {
              if (mstDialyzer[0].modelNumber !== mstDialyzerSub[0].modelNumber) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstDialyzer[0].modelNumber;
            } else {
              cond[0].value = "削除済み";
            }
          }
        } else if ("6" === key || "7" === key || "8" === key || "13" === key) {
          // 吸着カラム(6)
          // 1次膜(7)
          // 2次膜(8)
          // 血液回路(13)
          const equipmentCd = mstCondInfo[key].value;
          if (null === equipmentCd || "" === equipmentCd) {
            cond[0].value = "";
          } else if (null !== this.mstEquipmentTabooAllergyInfo) {
            const mstEquipment = this.mstEquipmentTabooAllergyInfo.filter(
              obj => obj.equipmentCd == equipmentCd // mod #9973 value Number→文字列  shiyw
            );
            const mstEquipmentSub = this.mstEquipmentInfo.filter(
              obj => obj.equipmentCd == equipmentCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstEquipment.length) {
              if (mstEquipment[0].equipmentName !== mstEquipmentSub[0].equipmentName) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstEquipment[0].equipmentName;
            } else {
              cond[0].value = "削除済み";
            }
          }
        } else if ("9" === key || "10" === key || "11" === key) {
          // 穿刺針(A)(9)
          // 穿刺針(V)(10)
          // 穿刺針(SN)(11)
          const equipmentCd = mstCondInfo[key].value;
          if (null === equipmentCd || "" === equipmentCd) {
            cond[0].value = "";
          } else if (null !== this.mstEquipmentTabooAllergyInfo) {
            const mstEquipment = this.mstEquipmentTabooAllergyInfo.filter(
              obj => obj.equipmentCd == equipmentCd // mod #9973 value Number→文字列  shiyw
            );
            const mstEquipmentSub = this.mstEquipmentInfo.filter(
              obj => obj.equipmentCd == equipmentCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstEquipment.length) {
              if (mstEquipment[0].equipmentName !== mstEquipmentSub[0].equipmentName) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstEquipment[0].equipmentName;
            } else {
              cond[0].value = "削除済み";
            }
          }
        } else if ("12" === key) {
          // SN使用(12)
          if ('0' == mstCondInfo[key].value) {// mod #9973 value Number→文字列  shiyw
            cond[0].value = "使用しない";
            this.condInfo.filter(obj => obj.cond === "9")[0].show = true;
            this.condInfo.filter(obj => obj.cond === "10")[0].show = true;
            this.condInfo.filter(obj => obj.cond === "11")[0].show = false;
          } else {
            cond[0].value = "使用する";
            this.condInfo.filter(obj => obj.cond === "9")[0].show = false;
            this.condInfo.filter(obj => obj.cond === "10")[0].show = false;
            this.condInfo.filter(obj => obj.cond === "11")[0].show = true;
          }
        } else if ("14" === key) {
          // 血流量(14)
          cond[0].value = mstCondInfo[key].value;
          cond[0].unit = " mL/min";
        } else if ("15" === key) {
          // 透析液(15)
          const medicineCd = mstCondInfo[key].value;
          if (null === medicineCd || "" === medicineCd) {
            cond[0].value = "";
            this.condInfo.filter(obj => obj.cond === "17")[0].unit = "";
          } else if (
            null !== this.mstMedicineTabooAllergyInfo &&
            null !== this.mstMedicineMixTabooAllergyInfo
          ) {
            let mstDataInfo = this.mstMedicineTabooAllergyInfo;
            let mstDataInfoSub = this.mstMedicineInfo;
            let mstCd = "medicineCd";
            let mstName = "medicineName";

            const medicineType = mstCondInfo[key].medicine_type;
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //if (medicineType === "2") {
            if (medicineType == 2) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              // 調製薬剤なら
              mstDataInfo = this.mstMedicineMixTabooAllergyInfo;
              mstDataInfoSub = this.mstMedicineMixInfo;
              mstCd = "medicineMixCd";
              mstName = "medicineMixName";
            }

            const mstMedicine = mstDataInfo.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            const mstMedicineSub = mstDataInfoSub.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstMedicine.length) {
              if (mstMedicine[0][mstName] !== mstMedicineSub[0][mstName]) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstMedicine[0][mstName];
              // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
              if (undefined !== mstMedicine[0].unitSecond && "" !== mstMedicine[0].unitSecond) {
              // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
                // 透析液使用数(17)の単位
                // #10196 数値IFのスタイル全不正 linjunfeng start
                // this.condInfo.filter(obj => obj.cond === "17")[0].unit = ` ${mstMedicine[0].unitSecond}`;
                this.condInfo.filter(obj => obj.cond === "17")[0].unit = ` ${mstMedicine[0].unitSecond ?? ""}`;
                // #10196 数値IFのスタイル全不正 linjunfeng end
              } else {
                this.condInfo.filter(obj => obj.cond === "17")[0].unit = "";
              }
              this.condInfo.filter(obj => obj.cond === "17")[0].decPoint = mstMedicine[0].unitDecimalPointSecond;
            }
          }
        } else if ("16" === key) {
          // 透析液流量(16)
          cond[0].value = mstCondInfo[key].value;
          cond[0].unit = " mL/min";
        } else if ("17" === key) {
          // 透析液使用数(17)
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          numbers = String(BigNumber(mstCondInfo[key].value).toFixed()).split('.');
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
          decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > cond[0].decPoint){
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed();
          }else{
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed(cond[0].decPoint);
          }
        } else if ("18" === key) {
          // 透析液温度(18)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(1);
          cond[0].unit = " ℃";
        } else if ("19" === key) {
          // 補液(19)
          const medicineCd = mstCondInfo[key].value;
          if (null === medicineCd || "" === medicineCd) {
            cond[0].value = "";
            this.condInfo.filter(obj => obj.cond === "22")[0].unit = "";
          } else if (
            null !== this.mstMedicineTabooAllergyInfo &&
            null !== this.mstMedicineMixTabooAllergyInfo
          ) {
            let mstDataInfo = this.mstMedicineTabooAllergyInfo;
            let mstDataInfoSub = this.mstMedicineInfo;
            let mstCd = "medicineCd";
            let mstName = "medicineName";

            const medicineType = mstCondInfo[key].medicine_type;
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //if (medicineType === "2") {
            if (medicineType == 2) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              // 調製薬剤なら
              mstDataInfo = this.mstMedicineMixTabooAllergyInfo;
              mstDataInfoSub = this.mstMedicineMixInfo;
              mstCd = "medicineMixCd";
              mstName = "medicineMixName";
            }

            const mstMedicine = mstDataInfo.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            const mstMedicineSub = mstDataInfoSub.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstMedicine.length) {
              if (mstMedicine[0][mstName] !== mstMedicineSub[0][mstName]) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstMedicine[0][mstName];
              // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
              if (undefined !== mstMedicine[0].unitSecond && "" !== mstMedicine[0].unitSecond) {
              // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
                // 補液使用数(22)の単位
                // #10196 数値IFのスタイル全不正 linjunfeng start
                // this.condInfo.filter(obj => obj.cond === "22")[0].unit = ` ${mstMedicine[0].unitSecond}`;
                this.condInfo.filter(obj => obj.cond === "22")[0].unit = ` ${mstMedicine[0].unitSecond ?? ""}`;
                // #10196 数値IFのスタイル全不正 linjunfeng end
              } else {
                this.condInfo.filter(obj => obj.cond === "22")[0].unit = "";
              }
              this.condInfo.filter(obj => obj.cond === "22")[0].decPoint = mstMedicine[0].unitDecimalPointSecond;
            }
          }
        } else if ("20" === key) {
          // 補液量(20)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(1);
          cond[0].unit = " L";
        } else if ("21" === key) {
          // 補液選択(21)
          if ('1' == mstCondInfo[key].value) { // mod #9973 value Number→文字列  shiyw
            cond[0].value = "前補液";
          } else {
            cond[0].value = "後補液";
          }
        } else if ("22" === key) {
          // 補液使用数(22)
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          numbers = String(BigNumber(mstCondInfo[key].value).toFixed()).split('.');
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
          decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > cond[0].decPoint){
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed();
          }else{
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed(cond[0].decPoint);
          }
        } else if ("23" === key) {
          // 補液温度(23)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(1);
          cond[0].unit = " ℃";
        } else if ("24" === key) {
          // 補液速度(24)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(2);
          cond[0].unit = " L/h";
        } else if ("25" === key) {
          // 抗凝固剤(25)
          const medicineCd = mstCondInfo[key].value;
          if (null === medicineCd || "" === medicineCd) {
            cond[0].value = "";
            // 抗凝固剤ワンショット量(26)の単位
            this.condInfo.filter(obj => obj.cond === "26")[0].unit = "";
            // 抗凝固剤持続速度(27)の単位
            this.condInfo.filter(obj => obj.cond === "27")[0].unit = "";
            // 抗凝固剤持続総量(28)の単位
            this.condInfo.filter(obj => obj.cond === "28")[0].unit = "";
          } else if (
            null !== this.mstMedicineTabooAllergyInfo &&
            null !== this.mstMedicineMixTabooAllergyInfo
          ) {
            let mstDataInfo = this.mstMedicineTabooAllergyInfo;
            let mstDataInfoSub = this.mstMedicineInfo;
            let mstCd = "medicineCd";
            let mstName = "medicineName";

            const medicineType = mstCondInfo[key].medicine_type;
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //if (medicineType === "2") {
            if (medicineType == 2) {
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              // 調製薬剤なら
              mstDataInfo = this.mstMedicineMixTabooAllergyInfo;
              mstDataInfoSub = this.mstMedicineMixInfo;
              mstCd = "medicineMixCd";
              mstName = "medicineMixName";
            }

            const mstMedicine = mstDataInfo.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            const mstMedicineSub = mstDataInfoSub.filter(
              obj => obj[mstCd] == medicineCd // mod #9973 value Number→文字列  shiyw
            );
            if (0 < mstMedicine.length) {
              if (mstMedicine[0][mstName] !== mstMedicineSub[0][mstName]) {
                cond[0].isTabooAllergy = true;
                this.isWarnTabooAllergyFlag = true;
              }
              cond[0].value = mstMedicine[0][mstName];
              if (null !== mstMedicine[0].unit && "" !== mstMedicine[0].unit) {
                // 抗凝固剤ワンショット量(26)の単位
                this.condInfo.filter(
                  obj => obj.cond === "26"
                )[0].unit = ` ${mstMedicine[0].unit}`;
                // 抗凝固剤持続速度(27)の単位
                this.condInfo.filter(
                  obj => obj.cond === "27"
                )[0].unit = ` ${mstMedicine[0].unit}/h`;
                // 抗凝固剤持続総量(28)の単位
                this.condInfo.filter(
                  obj => obj.cond === "28"
                )[0].unit = ` ${mstMedicine[0].unit}`;
              } else {
                // 抗凝固剤ワンショット量(26)の単位
                this.condInfo.filter(obj => obj.cond === "26")[0].unit = "";
                // 抗凝固剤持続速度(27)の単位
                this.condInfo.filter(obj => obj.cond === "27")[0].unit = "";
                // 抗凝固剤持続総量(28)の単位
                this.condInfo.filter(obj => obj.cond === "28")[0].unit = "";
              }
              // 抗凝固剤小数点の桁数
              this.condInfo.filter(obj => obj.cond === "26")[0].decPoint = mstMedicine[0].unitDecimalPoint;
              this.condInfo.filter(obj => obj.cond === "27")[0].decPoint = mstMedicine[0].unitDecimalPoint;
              this.condInfo.filter(obj => obj.cond === "28")[0].decPoint = mstMedicine[0].unitDecimalPoint;
            }
          }
        } else if ("26" === key || "27" === key || "28" === key) {
          // 抗凝固剤ワンショット量(26)
          // 抗凝固剤持続速度(27)
          // 抗凝固剤持続総量(28)
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
          numbers = String(BigNumber(mstCondInfo[key].value).toFixed()).split('.');
          // mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
          decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > cond[0].decPoint){
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed();
          }else{
            cond[0].value = BigNumber(1 * mstCondInfo[key].value).toFixed(cond[0].decPoint);
          }

          // add FNSI-FutreNetWeb+SI課題管理No.4705 李 start
          // 患者経過総合ビューアレイアウトマスタがあるの場合
          if (this.getDispLayoutItemListData && this.getSelectedCondition && this.getSelectedCondition.setSelectedLayoutCd) {
            // 画面選択したレイアウトを取得する
            const layout = this.getDispLayoutItemListData.find(ele => {
              return this.getSelectedCondition.setSelectedLayoutCd === ele.layoutCd;
            });

            // 画面選択したレイアウトがあるの場合
            if (layout && layout.dispItemInfo && layout.dispItemInfo[0] && layout.dispItemInfo[0].categoryItem) {
              const layoutCategoryItem = layout.dispItemInfo[0].categoryItem;
              if (layoutCategoryItem) {
                // 治療条件項目を取得する
                const treatCondList = layoutCategoryItem.find(item => item.component == 'treat-cond');
                if (treatCondList && treatCondList.subCategoryItem) {
                  // 抗凝固剤ワンショット量(26)、抗凝固剤持続速度(27)、抗凝固剤持続総量(28)の値を取得する
                  const treatCondSubCategoryItem = treatCondList.subCategoryItem.find(item => item.itemNo == key);
                  if (!treatCondSubCategoryItem) {
                    getMstFacilitySettingValue(this.getFacilityCd, ANTICOAGULANT_DEFAULT_SETTING)
                      .then(response => {
                        // 施設設定マスタ、115_患者経過総合ビューア_抗凝固剤がONの場合
                        if (response && response.data == '1') {
                          // 設定値を「0」とする
                          cond[0].value = '0';
                        }
                    });
                  }
                }
              }
            }
          }
          // add FNSI-FutreNetWeb+SI課題管理No.4705 李 end

        } else if ("29" === key) {
          // IP使用選択(29)  文字列  1: 使用する、0: 使用しない　デフォルト値：1
          if ('0' == mstCondInfo[key].value) { // mod #9973 value Number→文字列  shiyw
            cond[0].value = "使用しない";
          } else {
            cond[0].value = "使用する";
          }
        } else if ("30" === key) {
          // IPスタート(30)  文字列  0: 手動、1:自動　デフォルト値：1　
          if ('0' == mstCondInfo[key].value) { // mod #9973 value Number→文字列  shiyw
            cond[0].value = "手動";
          } else {
            cond[0].value = "自動";
          }
        } else if ("31" === key) {
          // IPワンショット量(31)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(1);
          cond[0].unit = " mL";
        } else if ("32" === key || "33" === key) {
          // IP速度(32)
          // IP速度最大値(33)
          cond[0].value = (1 * mstCondInfo[key].value).toFixed(1);
          cond[0].unit = " mL/h";
        } else if ("34" === key) {
          // IPワンショットスタート(34)  文字列  1: 自動、0: 手動　デフォルト値：0
          if ('0' == mstCondInfo[key].value) { // mod #9973 value Number→文字列  shiyw
            cond[0].value = "手動";
          } else {
            cond[0].value = "自動";
          }
        } else if ("35" === key || "37" === key) {
          // IP電源自動切り(35)   文字列  0: 切、1:入　デフォルト値：0
          // IP電源OKモニタ切り(37)  文字列  0: 切、1:入　デフォルト値：0
          if ('0' == mstCondInfo[key].value) { // mod #9973 value Number→文字列  shiyw
            cond[0].value = "切";
          } else {
            cond[0].value = "入";
          }
        } else if ("36" === key || "38" === key) {
          // IP電源自動切り時間(36)
          // IP電源OKモニタ切り時間(38)
          cond[0].value = mstCondInfo[key].value;
          cond[0].unit = " 分前";
        }
      }

      // 治療方法セットマスタ/ord_mainに登録されていない治療条件(JSONキーなし)の場合はisDisabledをtrueに設定。セルをグレーアウトする
      // mod 10443 身体情報・DW・目標体重バグ 関  start
      // const notInOrdMain = this.condInfo.filter(item => !(item.cond in mstCondInfo));
      // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 start
      const notInOrdMain = this.condInfo.filter(item => !(item.cond in mstCondInfo) && item.cond !== "39");
      // mod 10443 身体情報・DW・目標体重バグ 関  end
      notInOrdMain.forEach(item => {
        item.isDisabled = true;
        item.value = ""; // 値クリア
        item.unit = "";
      });
      if (notInOrdMain.findIndex(item => item.cond === "3") > -1) {
        this.condInfo.find(item => item.cond === "39").isDisabled = notInOrdMain[notInOrdMain.findIndex(item => item.cond === "3")].isDisabled;
        this.condInfo.find(item => item.cond === "39").value = ""
        this.condInfo.find(item => item.cond === "39").unit = ""
      } else {
        this.condInfo.find(item => item.cond === "39").isDisabled = false;
      }
      // mod 10705 【身体情報関連】②指示履歴、指示受け指示承認、治療状況リストマップ＞指示変更 張玲 end
    },

    /**
     * 治療情報の投与薬剤情報を更新する
     */
    setMediInfo() {
      this.mediInfo = [];
      if (false === this.selectedSet.isTreatSet) {
        // 治療情報のベースが直近の過去指示の場合、投薬はコピーしない
        return;
      }
      const mstTreatSet = this.mstTreatSetInfo.filter(
        obj => obj.treatmentSetCd === this.selectedSet.cd
      );
      if (null === mstTreatSet || 1 > mstTreatSet.length) {
        return;
      }

      const mediInfo = JSON.parse(mstTreatSet[0].indMediInfo);
      for (const key in mediInfo) {
        let mstMedi = this.mstMedicineTabooAllergyInfo; // 禁忌・アレルギー込みの薬剤マスタ
        let mstMediSub = this.mstMedicineInfo;  // 通常の薬剤マスタ（↑との比較用）
        let mstMediCd = "medicineCd";
        let mstMediName = "medicineName";
        if (mediInfo[key].medicine_type == 2) {
        // if (mediInfo[key].medicine_type === "2") {
          // 調製薬剤なら
          mstMedi = this.mstMedicineMixTabooAllergyInfo;  // 禁忌・アレルギー込みの調製薬剤マスタ
          mstMediSub = this.mstMedicineMixInfo; // 通常の調製薬剤マスタ（↑との比較用）
          mstMediCd = "medicineMixCd";
          mstMediName = "medicineMixName";
        }
        const mstMedicine = mstMedi.filter(
          obj => obj[mstMediCd] === mediInfo[key].cd
        );
        const mstMedicineSub = mstMediSub.filter(
          obj => obj[mstMediCd] === mediInfo[key].cd
        );
        let medicineName = "";
        let unit = "";
        let isTabooAllergy = false;
        if (0 < mstMedicine.length) {
          if (mstMedicine[0][mstMediName] !== mstMedicineSub[0][mstMediName]) {
            isTabooAllergy = true;
            if (this.isMediInfo) {
              this.isWarnTabooAllergyFlag = true;
            }
          }
          medicineName = mstMedicine[0][mstMediName];
          if (null !== mstMedicine[0].unit && "" !== mstMedicine[0].unit) {
            unit = ` ${mstMedicine[0].unit}`;
          }
          // 数値項目への小数点対応
          //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 start
          var numbers = String(BigNumber(mediInfo[key].amount).toFixed()).split('.');
          //mod #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240424 end
          var decPoint = (numbers[1]) ? numbers[1].length : 0;
          if(decPoint > mstMedicine[0].unitDecimalPoint){
            mediInfo[key].amount = BigNumber(1 * mediInfo[key].amount).toFixed();
          }else{
            mediInfo[key].amount = BigNumber(1 * mediInfo[key].amount).toFixed(mstMedicine[0].unitDecimalPoint);
          }
        }
        let procedureName = "";
        const mstProcedure = this.mstProcedureInfo.filter(
          obj => obj.procedureCd === mediInfo[key].procedure_cd
        );
        if (0 < mstProcedure.length) {
          procedureName = mstProcedure[0].pricedureName;
        }
        let timingName = "";
        const mstTiming = this.mstMedicateTimingInfo.filter(
          obj => obj.medicateTimingCd === mediInfo[key].timing_cd
        );
        if (0 < mstTiming.length) {
          timingName = mstTiming[0].medicateTimingName;
        }
        // リスト追加
        this.mediInfo.push({
          key,
          medicine: medicineName,
          interval: "毎回",
          amount: mediInfo[key].amount ? mediInfo[key].amount + unit : unit,
          procedure: procedureName,
          timing: timingName,
          isTabooAllergy: isTabooAllergy
        });
      }
    },

    /**
     * 治療情報の医療材料情報を更新する
     */
    setEuquipInfo() {
      this.equipInfo = [];
      let mstTreatSet = null;
      if (this.selectedSet.isTreatSet) {
        // 治療方法セットから取得
        mstTreatSet = this.mstTreatSetInfo.filter(
          obj => obj.treatmentSetCd === this.selectedSet.cd
        );
      } else {
        // 治療情報から取得
        mstTreatSet = this.ordMainInfo.filter(
          obj => obj.ordNo === this.selectedOrdMain.ordNo
        );
      }
      if (null === mstTreatSet || 1 > mstTreatSet.length) {
        return;
      }

      this.equipInfo = [];
      const equipInfo = JSON.parse(mstTreatSet[0].indEquipInfo);

      for (const key in equipInfo) {
        // #10196 add ダイアライザ's case
        let equipType = equipInfo[key].equip_type;

        const mstEquipment = this.mstEquipmentTabooAllergyInfo.filter(
          obj => obj.equipmentCd === equipInfo[key].cd
        );

        let mstEquipmentSub;
        let equipmentName = "";
        let unit = "";
        let isTabooAllergy = false;
        if (equipType == 0) {
          mstEquipmentSub = this.mstEquipmentInfo.filter(
            obj => obj.equipmentCd === equipInfo[key].cd
          );
          if (0 < mstEquipment.length) {
            if (mstEquipment[0].equipmentName !== mstEquipmentSub[0].equipmentName) {
              isTabooAllergy = true;
              this.isWarnTabooAllergyFlag = true;
            }
            equipmentName = mstEquipment[0].equipmentName;
            if (null !== mstEquipment[0].unit && "" !== mstEquipment[0].unit) {
              unit = ` ${mstEquipment[0].unit}`;
            }
          }
          // リスト追加(needleはマスタに存在しない為画面に表示はしないが、ordMainに登録時の既存処理の為、定義は残しておく)
          this.equipInfo.push({
            key,
            equipment: equipmentName,
            needle: equipInfo[key].needle_type,
            amount: equipInfo[key].amount + unit,
            isTabooAllergy: isTabooAllergy
          });
        }
        // 10196  add ダイアライザ's case
        else if (equipType == 1) {

          let mstDialyzer = this.mstDialyzerTabooAllergyInfo.filter(
            obj => obj.dialyzerCd == equipInfo[key].cd // mod #9973 value Number→文字列  shiyw
          );
          let mstDialyzerSub = this.mstDialyzerInfo.filter(
            obj => obj.dialyzerCd == equipInfo[key].cd // mod #9973 value Number→文字列  shiyw
          );
          if (0 < mstDialyzer.length) {
            if (mstDialyzer[0].modelNumber !== mstDialyzerSub[0].modelNumber) {
              isTabooAllergy = true;
              this.isWarnTabooAllergyFlag = true;
            }
            equipmentName = mstDialyzer[0].modelNumber;
          } else {
            equipmentName = "削除済み";
          }

          // リスト追加(needleはマスタに存在しない為画面に表示はしないが、ordMainに登録時の既存処理の為、定義は残しておく)
          this.equipInfo.push({
            key,
            equipment: equipmentName,
            amount: equipInfo[key].amount,
            isTabooAllergy: isTabooAllergy
          });

        }
      }
    },

    /**
     * 治療情報の指示コメント情報を更新する
     */
    setCommentInfo() {
      this.commentInfo = [];
      let mstTreatSet = null;
      if (this.selectedSet.isTreatSet) {
        // 治療方法セットから取得
        mstTreatSet = this.mstTreatSetInfo.filter(
          obj => obj.treatmentSetCd === this.selectedSet.cd
        );
      } else {
        // 治療情報から取得
        mstTreatSet = this.ordMainInfo.filter(
          obj => obj.ordNo === this.selectedOrdMain.ordNo
        );
      }
      if (null === mstTreatSet || 1 > mstTreatSet.length) {
        return;
      }
      const commentInfo = JSON.parse(mstTreatSet[0].indIndCommentInfo);
      for (const key in commentInfo) {
        // リスト追加
        this.commentInfo.push({
          key,
          content: commentInfo[key].content
        });
      }
    },

  //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 start
  async showConfirmDialog(mCd,mTitle) {
      let rtn = false;
      let msg = this.messageInfo(mCd);
      await this.$ons.notification.confirm({
        title: mTitle,
        message: msg,
        callback: answer => {
          if (answer === 1) {
            rtn = true;
          }
        }
      });
      return rtn;
    },

  async itemCheck(structData) {
    const deviceSetInfo = await getDeviceSetInfoPat(structData.patId).catch(
      error => {
        getErrorMessage('IndPlanCreate.vue', 'itemCheck', error);
          throw new Error(error);
      }
    );
    if (!deviceSetInfo) {
      return false;
    }

    //血流量
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
    // const itemValue_14 = this.condInfo[13].value;
    const itemValue_14 = this.condInfo.find(item => item.cond === "14").value;
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
    //透析温度
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
    // const itemValue_18 = this.condInfo[17].value;
    const itemValue_18 = this.condInfo.find(item => item.cond === "18").value;
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
    //補液量
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
    // const itemValue_20 = this.condInfo[19].value;
    const itemValue_20 = this.condInfo.find(item => item.cond === "20").value;
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
    //補液選択（前補液・後補液）
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
    // const itemValue_21 = this.condInfo[20].value;
    const itemValue_21 = this.condInfo.find(item => item.cond === "21").value;
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
    //補液速度
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
    // const itemValue_24 = this.condInfo[23].value;
    const itemValue_24 = this.condInfo.find(item => item.cond === "24").value;
    // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end

    const healthmonFacilityConn = Object.assign(deviceSetInfo.ope.dev.A,deviceSetInfo.ope.dev.B);
    //後補液 補液速度操作範囲上限（OHDF）
    const itemOHDF_24_Max = healthmonFacilityConn['34'];
    //後補液 補液速度操作範囲上限（OHF）
    const itemOHF_24_Max = healthmonFacilityConn['35'];
    //血流量操作範囲上限
    const itemName_14_Max = healthmonFacilityConn['179'];
    //透析液温度操作範囲上限
    const itemName_18_Max = healthmonFacilityConn['182'];
    //補液量設定値制限（OHDF・OHF用）
    const itemName_20_Max = healthmonFacilityConn['383'];
    //補液計算優先項目（OHDF・OHF用）(0:補液速度算出,1:補液量設定算出,2:補液比率,3:濾過率から算出)
    const itemValue = healthmonFacilityConn['389'];
    //前補液 補液速度操作範囲上限（OHDF）
    const itemOHDF_24_Max_A = healthmonFacilityConn['396'];
    //前補液 補液速度操作範囲上限（OHF）
    const itemOHF_24_Max_A = healthmonFacilityConn['397'];

    if (itemValue_14 > itemName_14_Max){
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      // if (!await this.showConfirmDialog('10400011','血流量上限チェック')) {
        if (!await this.showConfirmDialog('10400011',DIALOG_MESSAGES[10400011].title)) {
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        return true;
      }
    }

    if (itemValue_18 > itemName_18_Max){
      // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
      // if (!await this.showConfirmDialog('10400012','透析液温度上限チェック')) {
        if (!await this.showConfirmDialog('10400012',DIALOG_MESSAGES[10400012].title)) {
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
        return true;
      }
    }
    const mstDevRecord = this.getMstTreatmentData.find(mstData => {
      return mstData.treatmentCd === this.treatInfo.cd;
    });
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 陳 start
    if (mstDevRecord !== undefined){
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 陳 end
      const deviceMode = mstDevRecord.deviceMode;

      // 治療法：HDF、HF、AFBFの場合
      if (deviceMode === DEVICEMODE.HDF || deviceMode === DEVICEMODE.HF || deviceMode === DEVICEMODE.AFBF) {
        if (itemValue_20 > 30.0) {
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // if (!await this.showConfirmDialog('10400008','補液量上限チェック')) {
           // mod #10196 2024/02/05 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 張玲 start
            //if (!await this.showConfirmDialog('10400008',DIALOG_MESSAGES[10400008].title)) {
              if (!await this.showConfirmDialog('10400013','補液量上限チェック')) {
            // mod #10196 2024/02/05 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 張玲 end
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            return true;
          }
        }

      // 治療法：OHDF、OHFの場合
      } else if(deviceMode === DEVICEMODE.OHDF || deviceMode === DEVICEMODE.OHF) {
        if (itemValue === '0') {
          //補液速度算出の場合
          if (itemValue_20 > itemName_20_Max){
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // if (!await this.showConfirmDialog('10400009','補液量上限チェック')) {
              if (!await this.showConfirmDialog('10400009',DIALOG_MESSAGES[10400009].title)) {
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
              return true;
            }
          }
        } else if (itemValue === '1') {
          //補液量設定算出の場合
          if ((deviceMode === DEVICEMODE.OHDF && itemValue_24 > itemOHDF_24_Max && itemValue_21 === '後補液') ||
          (deviceMode === DEVICEMODE.OHF && itemValue_24 > itemOHF_24_Max && itemValue_21 === '後補液') ||
          (deviceMode === DEVICEMODE.OHDF && itemValue_24 > itemOHDF_24_Max_A && itemValue_21 === '前補液') ||
          (deviceMode === DEVICEMODE.OHF && itemValue_24 > itemOHF_24_Max_A && itemValue_21 === '前補液') ) {
            if (itemValue_24 > itemOHDF_24_Max){
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
              // if (!await this.showConfirmDialog('10400010','補液速度上限チェック')) {
              if (!await this.showConfirmDialog('10400010',DIALOG_MESSAGES[10400010].title)) {
                // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
                return true;
              }
            }
          }
        }
      }
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 陳 start
    }
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 陳 end
    return false;
  },
  //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 end

    /**
     * 予約作成の登録
     * @param {object} 指示ベース画面の指示情報
     */
    async updateIndInfo(structData) {
      console.log("IndPlanCreate.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      let stringParams = "";
      // 予定内容のチェック
      if ("" === this.selectedSet.cd) {
        stringParams = "予定内容";
      }

      if ("" !== stringParams) {
        // add FNSI 373,374修正対応 陳 start
        if(this.$parent.$parent.messageDialogInfo !== undefined){
        // add FNSI 373,374修正対応 陳 end

          this.$parent.$parent.messageDialogInfo.messageCd = 22010001;
          this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.stringParams = [stringParams];
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        }
      } else {
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 start
      if (await this.itemCheck(structData)) {
          this.$parent.$parent.isUpdating = false;
          this.$parent.$parent.updateDisable = false;
        console.log("IndPlanCreate.vue return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.99(外結)対応 韓 end
        let datelist = [];
        if ("1" === structData.cycleWeek) {
          // 隔日透析の治療日を取得
          datelist = await this.getKakujituTreatDateList(structData);
        } else if ("2" === structData.cycleWeek) {
          // 隔週透析の治療日を取得
          datelist = await this.getKakusyuTreatDateList(structData);
        } else {
          // 通常透析の治療日を取得
          datelist = await this.getTreatDateList(structData);
        }

        if (null === datelist) {
          console.log("IndPlanCreate.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        } else if (true === datelist && !structData.isSkipFlag) {
          // add FNSI 373,374修正対応 陳 start
          if(this.$parent.$parent.messageDialogInfo !== undefined){
          // add FNSI 373,374修正対応 陳 end

            // 治療日リストに重複があり、かつスキップフラグがtureでない場合
            this.$parent.$parent.messageDialogInfo.messageCd = this.$parent
              .$parent.weekEdit
              ? 22010004
              : 12010001;
            this.$parent.$parent.messageDialogInfo.type = this.$parent.$parent
              .weekEdit
              ? "1"
              : "2";
            this.$parent.$parent.messageDialogInfo.stringParams = [
              "<br>予定が重ならない日のみ登録しますか？"
            ];
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            // mod 8347 【デグレ】????患者治療割り当てができない dou start
            // return;
          } else {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "",
              // message: "同日に、同じ治療方法・クールが存在する治療予定は登録できません。"
              title: DIALOG_MESSAGES[22010004].title,
              message: messageFormat(DIALOG_MESSAGES[22010004].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          console.log("IndPlanCreate.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
          // mod 8347 【デグレ】????患者治療割り当てができない dou end
        } else if (this.isWarnTabooAllergyFlag && !structData.acceptWarnFlag) {
          // add FNSI 373,374修正対応 陳 start
          if(this.$parent.$parent.messageDialogInfo !== undefined) {
          // add FNSI 373,374修正対応 陳 end

            // 禁忌・アレルギー警告フラグがtrueの場合、かつ警告受け入れフラグがfalseの場合
            this.$parent.$parent.messageDialogInfo.messageCd = 12010004;
            this.$parent.$parent.messageDialogInfo.type = "2";
            this.$parent.$parent.messageDialogInfo.stringParams = [
              "<br>登録を行いますか？"
            ];
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            // mod 8347 【デグレ】????患者治療割り当てができない dou start
            // return;
          }
          console.log("IndPlanCreate.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
          // mod 8347 【デグレ】????患者治療割り当てができない dou end
        }

        // 治療日リストをソートする
        datelist.sort(function(a, b) {
          return Number(a) < Number(b) ? -1 : Number(a) > Number(b) ? 1 : 0;
        });
        structData.treatDateList = datelist;

        // 予定作成元の治療方法/直近の過去指示を取得
        let treatSetObj;
        if (this.selectedSet.treatmentCd === "ordmain") {
          // 直近の過去指示の場合
          treatSetObj = this.ordMainInfo.filter(ordMain => ordMain.ordNo === this.selectedOrdMain.ordNo)[0];

        } else {
          // modify 10196 by kangjie 20240415 start query only treatmentSet data
          // treatSetObj = this.mstTreatSetInfo.filter(set => set.treatmentCd === this.selectedSet.treatmentCd)[0];
          treatSetObj = this.mstTreatSetInfo.filter(set => set.treatmentCd === this.selectedSet.treatmentCd && set.treatmentSetCd === this.selectedSet.cd)[0];
          // modify 10196 by kangjie 20240415 end
        }
        // 使用期限のチェック
        if (!structData.chkExpiredFlag  && !await this.chkInExpiryDate(treatSetObj, structData.treatDateList[0], structData.treatDateList[structData.treatDateList.length - 1])) {
          // add FNSI 373,374修正対応 陳 start
          if(this.$parent.$parent.messageDialogInfo !== undefined){
          // add FNSI 373,374修正対応 陳 end

            // 期限切れがあったらダイアログを表示
            this.$parent.$parent.messageDialogInfo.messageCd = 12010008;
            this.$parent.$parent.messageDialogInfo.type = "2";
            this.$parent.$parent.messageDialogInfo.stringParams = [
              this.expiredMsg + "<br>登録してよろしいですか？"
            ];
            this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            console.log("IndPlanCreate.vue updateIndInfo return; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            return;
          }
        }

        // add FNSI redMine #5116 陳 start
        this.treatDays = JSON.stringify(structData.treatDateList);
        // add FNSI redMine #5116 陳 end

        if (this.selectedSet.isTreatSet) {
          // 治療予定作成(by治療方法セットコード)

          // 治療種別を設定
          structData.cycleWeek = this.getTreatType(structData);


          // mod FNSI 373,374修正対応 陳 start
          // await this.createIndPlan(structData);
          let retObj = await this.createIndPlan(structData);
          console.log("IndPlanCreate.vue updateIndInfo return await this.createIndPlan(structData); this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return retObj
          // mod FNSI 373,374修正対応 陳 start
        } else {
          // 治療予定作成(byオーダ番号)
          await this.createIndPlanByOrdNo(structData);
        }
      }
      console.log("IndPlanCreate.vue updateIndInfo this.finishLoadingScreen();");
      this.finishLoadingScreen();
    },

    // 使用期限のチェック
    async chkInExpiryDate(treatSetObj, indStartDate, indEndDate) {
      this.expiredMsg = "";
      let isExpiredFlg = true;
      // 治療条件
      const condObj = JSON.parse(treatSetObj.indCondInfo);
      const keyList = Object.keys(condObj);
      keyList.forEach(key => {
        switch (Number(key)) {
          case 5: {
            // ダイアライザマスタ.dialyzer_cd ※null(未登録)可    文字列
            const tmpDialyzerObj = this.mstDialyzerInfo.filter(dialyzer => dialyzer.dialyzerCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpDialyzerObj.length === 0) {
              break;
            }
            const dialyzerObj = tmpDialyzerObj[0];
            if (!fitTermCheckForUpdate(dialyzerObj.useStartDate, dialyzerObj.useEndDate, indStartDate, indEndDate)) {
              isExpiredFlg = false;
              this.expiredMsg += "</br>" + dialyzerObj.modelNumber + "："
                              + dateFormat.normalDateWithCheck(dialyzerObj.useStartDate)
                              + "～" + dateFormat.normalDateWithCheck(dialyzerObj.useEndDate);
            }
            break;
          }
          case 6:
          case 7:
          case 8:
          case 9:
          case 10:
          case 11:
          case 13: {
            // 吸着カラム/1次膜/2次膜/穿刺針(A/V/SN)/血液回路
            if (!condObj[key].value) {
              // シングルニードル使用の有無により、A/V、SNのいずれかがnullになる
              break;
            }
            // 医療材料マスタ.equipment_cd(number) ==  condObj[13].value(文字列)
            const tmpEquipmentObj = this.mstEquipmentInfo.filter(equipment => equipment.equipmentCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
            if (tmpEquipmentObj.length === 0) {
              break;
            }
            const equipmentObj = tmpEquipmentObj[0];
            if (!fitTermCheckForUpdate(equipmentObj.useStartDate, equipmentObj.useEndDate, indStartDate, indEndDate)) {
              isExpiredFlg = false;
              this.expiredMsg += "</br>" + equipmentObj.equipmentName + "："
                              + dateFormat.normalDateWithCheck(equipmentObj.useStartDate)
                              + "～" + dateFormat.normalDateWithCheck(equipmentObj.useEndDate);
            }
            break;
          }
          case 15:
          case 19:
          case 25: {
            // 透析液/補液/抗凝固剤
            // if (condObj[key].medicine_type === "1") {
            if (condObj[key].medicine_type == 1) {
              // 薬剤の場合, medi.medicineCd(number) == condObj[25].value(文字列)
              const tmpMediObj = this.mstMedicineInfo.filter(medi => medi.medicineCd == condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, indStartDate, indEndDate)) {
                isExpiredFlg = false;
                this.expiredMsg += "</br>" + mediObj.medicineName + "："
                                + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                                + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
              }
            // } else if (condObj[key].medicine_type === "2") {
            } else if (condObj[key].medicine_type == 2) {
              // 調製薬剤の場合, medi.medicineCd(number) == condObj[25].value(文字列)
              const tmpMediObj = this.mstMedicineMixTabooAllergyInfo.filter(medi => medi.medicineMixCd === condObj[key].value); // mod #9973 value Number→文字列  shiyw
              if (tmpMediObj.length === 0) {
                break;
              }
              const mediObj = tmpMediObj[0];
              if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, indStartDate, indEndDate)) {
                isExpiredFlg = false;
                this.expiredMsg += "</br>" + mediObj.medicineMixName + "："
                                + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                                + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
              }
            }
            break;
          }
        }
      });

      // 投与薬剤
      if (!treatSetObj.ordNo) {
        // ordNo が存在する場合は直近の過去指示(投与薬剤を含まない)なので処理をしない
        const mediInfoObj = JSON.parse(treatSetObj.indMediInfo);
        for (const key in mediInfoObj) {
          // if (mediInfoObj[key].medicine_type === "1") {
          if (mediInfoObj[key].medicine_type == 1) {
            // 薬剤の場合
            const tmpMediObj = this.mstMedicineInfo.filter(medi => medi.medicineCd === mediInfoObj[key].cd);
            if (tmpMediObj.length === 0) {
              continue;
            }
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.useStartDate, mediObj.useEndDate, indStartDate, indEndDate)) {
              isExpiredFlg = false;
              this.expiredMsg += "</br>" + mediObj.medicineName + "："
                              + dateFormat.normalDateWithCheck(mediObj.useStartDate)
                              + "～" + dateFormat.normalDateWithCheck(mediObj.useEndDate);
            }
          } else {
            // 調製薬剤の場合
            const tmpMediObj = this.mstMedicineMixTabooAllergyInfo.filter(medi => medi.medicineMixCd === mediInfoObj[key].cd);
            if (tmpMediObj.length === 0) {
              continue;
            }
            const mediObj = tmpMediObj[0];
            if (!fitTermCheckForUpdate(mediObj.maxUseStartDate, mediObj.minUseEndDate, indStartDate, indEndDate)) {
              isExpiredFlg = false;
              this.expiredMsg += "</br>" + mediObj.medicineMixName + "："
                              + dateFormat.normalDateWithCheck(mediObj.maxUseStartDate)
                              + "～" + dateFormat.normalDateWithCheck(mediObj.minUseEndDate);
            }
          }
        }
      }

      // 医療材料
      const equipInfoObj = JSON.parse(treatSetObj.indEquipInfo);
      for (const key in equipInfoObj) {
        // ダイアライザは治療方法では設定できない為、医療材料のみチェックする
        const tmpEquipObj = this.mstEquipmentInfo.filter(equipment => equipment.equipmentCd === equipInfoObj[key].cd);
        if (tmpEquipObj.length === 0) {
          continue;
        }
        const equipObj = tmpEquipObj[0];
        if (!fitTermCheckForUpdate(equipObj.useStartDate, equipObj.useEndDate, indStartDate, indEndDate)) {
          isExpiredFlg = false;
          this.expiredMsg += "</br>" + equipObj.equipmentName + "："
                          + dateFormat.normalDateWithCheck(equipObj.useStartDate)
                          + "～" + dateFormat.normalDateWithCheck(equipObj.useEndDate);
        }
      }
      return isExpiredFlg;
    },

    /**
     * 通常透析用の治療日リストを取得する
     * @param {object} 指示ベース情報
     */
    async getTreatDateList(structData) {
      const paramJson = {};
      paramJson.facility_cd = structData.facilityCd;
      paramJson.pat_id = structData.patId;
      paramJson.ind_start_date = structData.indStartDate;
      paramJson.ind_end_date = structData.indEndDate;
      paramJson.week_pattern = JSON.stringify(structData.indWeeks);
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getTreatDateList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }

      const treatDateList = [];

      const startDate = moment(structData.indStartDate);
      const endDate = moment(structData.indEndDate);
      while (startDate <= endDate) {
        let buf = startDate.day();
        if (0 === buf) buf = 7;
        const week = structData.indWeeks.filter(obj => obj.value === buf);
        if (0 < week.length) {
          if (true === week[0].done) {

            // mod FNSI-FutreNetWeb+SI課題管理No.3896 李 start
            let ordMian = null;
            // 直近の過去指示の場合
            if (this.selectedSet.treatmentCd === "ordmain") {
              const treatSetObj = this.ordMainInfo.filter(ordMain => ordMain.ordNo === this.selectedOrdMain.ordNo)[0];
              if (treatSetObj) {
                ordMian = response.data.filter(
                  obj =>
                    obj.indTreatmentCd === treatSetObj.indTreatmentCd &&
                    obj.indKurCd === 0 &&
                    obj.treatDate === startDate.format("YYYYMMDD").toString()
                );
              }

            // 直近の過去指示以外の場合
            } else {
              ordMian = response.data.filter(
                obj =>
                  obj.indTreatmentCd === this.selectedSet.treatmentCd &&
                  // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
                  // obj.indKurCd === 0 &&
                  (this.selOrdNo == 'selOrdNo' ? this.kurInfo.kurCd === obj.indKurCd : obj.indKurCd === 0) &&
                  // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
                  obj.treatDate === startDate.format("YYYYMMDD").toString()
              );
            }

            // const ordMian = response.data.filter(
            //   obj =>
            //     obj.indTreatmentCd === this.selectedSet.treatmentCd &&
            //     obj.indKurCd === 0 &&
            //     obj.treatDate === startDate.format("YYYYMMDD").toString()
            // );
            // mod FNSI-FutreNetWeb+SI課題管理No.3896 李 end
            if (0 === ordMian.length) {
              treatDateList.push(startDate.format("YYYYMMDD").toString());
              // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
            // } else if (structData.hasOwnProperty("isSkipFlag") && !structData.isSkipFlag) {
            } else if (!structData.isSkipFlag) {
              // mod #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
              return true;
            }
          }
        }
        startDate.add(1, "days");
      }
      return treatDateList;
    },

    /**
     * 隔日透析用の治療日リストを取得する
     * @param {object} 指示ベース情報
     */
    async getKakujituTreatDateList(structData) {
      const paramJson = {};
      paramJson.facility_cd = structData.facilityCd;
      paramJson.pat_id = structData.patId;
      paramJson.ind_start_date = structData.indStartDate;
      paramJson.ind_end_date = structData.indEndDate;
      paramJson.week_pattern = JSON.stringify(structData.indWeeks);
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getKakujituTreatDateList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }

      const treatDateList = [];

      const startDate = moment(structData.indStartDate);
      const endDate = moment(structData.indEndDate);
      while (startDate <= endDate) {
        let buf = startDate.day();
        switch (buf) {
          case 0:
            buf = 4;
            break;
          case 1:
          case 2:
            buf = 1;
            break;
          case 3:
          case 4:
            buf = 2;
            break;
          case 5:
          case 6:
            buf = 3;
            break;
          default:
            break;
        }
        const week = structData.kakujituWeeks.filter(obj => obj.value === buf);
        if (0 < week.length) {
          if (true === week[0].done) {
            const ordMian = response.data.filter(
              obj =>
                obj.indTreatmentCd === this.selectedSet.treatmentCd &&
                obj.indKurCd === 0 &&
                obj.treatDate === startDate.format("YYYYMMDD").toString()
            );
            if (0 === ordMian.length) {
              treatDateList.push(startDate.format("YYYYMMDD").toString());
            } else if (!structData.isSkipFlag) {
              return true;
            }
          }
        }
        startDate.add(2, "days");
      }
      return treatDateList;
    },

    /**
     * 隔週透析用の治療日リストを取得する
     * @param {object} 指示ベース情報
     */
    async getKakusyuTreatDateList(structData) {
      const paramJson = {};
      paramJson.facility_cd = structData.facilityCd;
      paramJson.pat_id = structData.patId;
      paramJson.ind_start_date = structData.indStartDate;
      paramJson.ind_end_date = structData.indEndDate;
      paramJson.week_pattern = JSON.stringify(structData.indWeeks);
      const response = await ApiHelper.post(
        "/mainData/TreatDateList",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getKakusyuTreatDateList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }

      const treatDateList = [];

      const startDate = moment(structData.indStartDate);
      const endDate = moment(structData.indEndDate);
      while (startDate <= endDate) {
        let buf = startDate.day();
        if (0 === buf) buf = 7;
        const week = structData.indWeeks.filter(obj => obj.value === buf);
        if (0 < week.length) {
          if (true === week[0].done) {
            const ordMian = response.data.filter(
              obj =>
                obj.indTreatmentCd === this.selectedSet.treatmentCd &&
                obj.indKurCd === 0 &&
                obj.treatDate === startDate.format("YYYYMMDD").toString()
            );
            if (0 === ordMian.length) {
              treatDateList.push(startDate.format("YYYYMMDD").toString());
            } else if (!structData.isSkipFlag) {
              return true;
            }
          }
        }
        if (7 === buf) {
          // 日曜の場合は次週の月曜まで日付を進める
          startDate.add(8, "days");
        } else {
          startDate.add(1, "days");
        }
      }
      return treatDateList;
    },

    /**
     * 治療方法セットを基にオーダ情報を登録する
     * @param {object} 指示ベース情報
     */
    async createIndPlan(structData) {
      console.log("IndPlanCreate.vue createIndPlan this.startLoadingScreen();");
      this.startLoadingScreen();
      //データの収集
      const sendJson = {};
      // 治療方法セットコード
      sendJson.treatment_set_cd = this.selectedSet.cd;
      // 更新日時
      sendJson.up_date = this.selectedSet.upDate;
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 開始日
      sendJson.start_date = structData.indStartDate;
      // 終了日
      sendJson.end_date = structData.indEndDate;
      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
      // 曜日パターン
      sendJson.week_pattern = JSON.stringify(structData.indWeeks);
      // 治療種別
      sendJson.treat_type = structData.cycleWeek;
      // 登録対象治療方法
      sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 登録対象クール
      sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 治療日リスト
      sendJson.treatDays = JSON.stringify(structData.treatDateList);
      // 指示者コード
      sendJson.ind_user_id = structData.indUser;
      // 指示者コード
      sendJson.upd_user_id = structData.updUser;

      // FNSI 373,374修正対応 陳 start
      if (this.selOrdNo == 'selOrdNo') {
        // 登録対象クール
        sendJson.ind_kur_cd = this.kurInfo.kurCd;
        // 治療開始時刻
        sendJson.ind_treat_start_time = this.standardStartTime;
        // ベッドコード
        sendJson.ind_bed_cd = structData.bedCd;
      }
      // FNSI 373,374修正対応 陳 end

      // add #10553 #10125 ????患者予定作成元識別parm追加 piao start
      let path = router.currentRoute.path;
      sendJson.screan_string = "PAT_VIEWER";
      if (path && /status-list/.test(path)){
        sendJson.screan_string = "STATUS_LIST";
      } else if (path && /status-map/.test(path)){
        sendJson.screan_string = "STATUS_MAP";
      }
      // add #10553 #10125 ????患者予定作成元識別parm追加 piao end

      //データの送信
      // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
      let response;
      if (structData.type && '' === structData.type) {
        // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
        response = await ApiHelper.post(
          "/mainData/insertByTreatSetCd/",
          sendJson
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndPlanCreate.vue', 'createIndPlan', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndPlanCreate.vue createIndPlan throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
        // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm start
      } else {
        response = await ApiHelper.post(
          "/patients/ord/createByTreatSetCd/",
          sendJson
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndPlanCreate.vue', 'createIndPlan', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndPlanCreate.vue createIndPlan throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
      }
      // add #12465 同患者同日同治療方法同クールの使用制限をしてもメッセージがでない zkm end
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      if (200 === response.status && undefined !== response.data.msglist && response.data.msglist.length > 0) {
        let msgList = response.data.msglist;
        let messages = "";
        msgList.forEach(item => {
          messages = messages + this.messageInfo(item) + "<br>";
        })
        this.$ons.notification.alert({
          title: "注意",
          message: messages,
          callback: answer => {
          if (answer == 0) {
            //OK
            console.log("IndPlanCreate.vue createIndPlan throw error; this.finishLoadingScreen();");
            this.finishLoadingScreen();
             // モーダルを閉じる
             this.hideModal();
          }
        }
        });
      }
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      if (200 === response.status && undefined !== response.data.msgCd) {
        this.$parent.$parent.messageDialogInfo.messageCd = response.data.msgCd;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("IndPlanCreate.vue createIndPlan return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }

      // add FNSI 373,374修正対応 陳 start
      if(response.status == 200 && response.data.errorMessage !== undefined　&& response.data.errorMessage !== ""){
        console.log("IndPlanCreate.vue createIndPlan return { result: true , message: response.data.errorMessage }; this.finishLoadingScreen();");
        this.finishLoadingScreen();

        return { result: true , message: response.data.errorMessage };
      }

      if(this.$parent.selOrdNo=="selOrdNo"){

        // mod FNSI-指示値・装置設定・装置プログラムの相関チェック 陳 start
        // this.$parent.selOrdNo = response.data[0];
        this.$parent.selOrdNo = JSON.parse(response.data.ordNoList)[0];
        console.log("IndPlanCreate.vue createIndPlan return { result: true , message:  }; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return { result: true , message: "" };
        // mod FNSI-指示値・装置設定・装置プログラムの相関チェック 陳 end
      }
      // end FNSI 373,374修正対応 陳 end

      EventBus.$emit("isRefresh");
      // 予実リストの更新
      this.setResultUpdate(new Date());
      console.log("IndPlanCreate.vue createIndPlan this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.hideModal();
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
    /**
     * 定義ファイルから対応するメッセージコードの文字列を取得
     * @param {object} メッセージコード
     */
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
    //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
    /**
     * 治療方法セットを基にオーダ情報を登録する
     * @param {object} 指示ベース情報
     */
    async createIndPlanByOrdNo(structData) {
      console.log("IndPlanCreate.vue createIndPlanByOrdNo this.startLoadingScreen();");
      this.startLoadingScreen();
      //データの収集
      const sendJson = {};
      //治療方法セットコード
      sendJson.ord_no = this.selectedOrdMain.ordNo;
      //更新日時
      sendJson.up_date = this.selectedOrdMain.upDate;
      //患者ID
      sendJson.pat_id = structData.patId;
      //施設コード
      sendJson.facility_cd = structData.facilityCd;
      //曜日Jsonデータ
      sendJson.treatDays = JSON.stringify(structData.treatDateList);
      //指示者コード
      sendJson.ind_user_id = structData.indUser;
      //指示者コード
      sendJson.upd_user_id = structData.indUser;
      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
      // 治療種別
      sendJson.treat_type = structData.cycleWeek;

      //データの送信
      const response = await ApiHelper.post(
        "/mainData/insertByOrdNo/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'createIndPlanByOrdNo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log("IndPlanCreate.vue createIndPlanByOrdNo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });

      if (200 === response.status && undefined !== response.data.msgCd) {
        this.$parent.$parent.messageDialogInfo.messageCd = response.data.msgCd;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("IndPlanCreate.vue createIndPlanByOrdNo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }

      // add FNSI 373,374修正対応 陳 start
      if(this.$parent.selOrdNo=="selOrdNo"){

        this.$parent.selOrdNo = response.data[0];
      }
      // end FNSI 373,374修正対応 陳 end

      EventBus.$emit("isRefresh");
      console.log("IndPlanCreate.vue createIndPlanByOrdNo this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.hideModal();
    },

    /**
     * オーダ情報を取得する
     * 指定患者のすべての期間に存在するオーダ情報
     */
    async getOrdmain() {
      const paramJson = {};
      paramJson.facility_cd = this.getFacilityCd;
      paramJson.pat_id = this.selectedPatId;
      // mod FNSI-予定内容遅延問題対応 李 start
      if (this.getIndPlanCreateDate && this.getIndPlanCreateDate[0] && this.getIndPlanCreateDate[1]) {
        paramJson.ind_start_date = moment(this.getIndPlanCreateDate[0]).add(-7, "days").format("YYYY-MM-DD");
        paramJson.ind_end_date = moment(this.getIndPlanCreateDate[1]).add(7, "days").format("YYYY-MM-DD");
      } else {
        paramJson.ind_start_date = "0001-01-01";
        paramJson.ind_end_date = "9999-12-31";
      }
      // mod FNSI-予定内容遅延問題対応 李 end
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";

      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getOrdmain', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }

      this.ordMainInfo = response.data;
      this.selectedDates = [];

      for (const key in this.ordMainInfo) {
        // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
        if (this.ordMainInfo[key].isDel !== "1") {
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
          this.selectedDates.push(this.ordMainInfo[key].treatDate);
          // add FNSI-改修内容 論理削除したの治療情報を修正 楊 start
        }
        // add FNSI-改修内容 論理削除したの治療情報を修正 楊 end
      }
    },

    /**
     * 予定内容リストを更新する
     */
    setTreatSetList() {
      this.TreatSetList = [];

      // 治療方法セットのリストを追加
      for (const key in this.mstTreatSetInfo) {
        // リスト追加
        this.TreatSetList.push({
          label: this.mstTreatSetInfo[key].treatmentSetName,
          cd: this.mstTreatSetInfo[key].treatmentSetCd,
          upDate: this.mstTreatSetInfo[key].upDate,
          treatmentCd: this.mstTreatSetInfo[key].treatmentCd,
          isTreatSet: true
        });
      }

      // 治療方法モーダルから呼び出されている場合、ここで処理終了
      if (this.isUpdateMethod) {
        return;
      }

      if (!this.planStartDate) {
        if (!this.selectedSet.isTreatSet) {
          this.selectedSet = this.TreatSetList[0];
        }
        return;
      }

      // 直近過去指示のリストを追加
      // 直近日の取得
      const planDate = moment(this.planStartDate).format("YYYYMMDD");
      const treatDate = this.getMostRecentDay(planDate);
      if (treatDate) {
        this.selectedDialDate = moment(treatDate).format("YYYY-MM-DD");
      }
      // 治療情報の取得
      const ordmain = this.ordMainInfo.filter(
        obj => obj.treatDate === treatDate
      );
      if (0 < ordmain.length) {
        // del FNSI-予定内容遅延問題対応 李 start
        // const ordNoInfo = [];
        // for (const key in ordmain) {
        //   ordNoInfo.push(ordmain[key].ordNo);
        // }
        // del FNSI-予定内容遅延問題対応 李 end
        // リスト追加
        this.TreatSetList.push({
          label: "直近の過去指示(投与薬剤を含まない)",
          cd: "ordmain",
          upDate: "",
          treatmentCd: "ordmain",
          isTreatSet: false
        });
      }
    },

    /**
     * 直近過去指示のリストを更新する
     */
    setOrdMainList() {
      if (true === this.selectedSet.isTreatSet) {
        this.ordMainList = [];
        this.showPastInd = false;
      } else {
        this.ordMainList = [];
        this.showPastInd = true;
        const findDate = moment(this.selectedDialDate).format("YYYYMMDD");
        const treatDate = this.getMostRecentDay(findDate);
        const ordmain = this.ordMainInfo.filter(
          obj => obj.treatDate === treatDate
        );
        if (0 < ordmain.length) {
          for (const key in ordmain) {
            const mstTreatment = this.mstTreatmentInfo.find(
              obj => obj.treatmentCd === ordmain[key].indTreatmentCd
            );
            const treatmentName = mstTreatment ? mstTreatment.treatmentName : "削除済み";
            let kurName = "未登録";
            let kurStartTime = "";
            if (ordmain[key].indKurCd) {
              const mstKur = this.mstKurInfo.find(
                obj => obj.kurCd === ordmain[key].indKurCd
              );
              kurName = "削除済み";
              if (mstKur) {
                kurName = mstKur.kurName;
                kurStartTime = mstKur.kurStartTime;
              }
            }

            this.ordMainList.push({
              label: `${treatmentName}、${kurName}`,
              ordNo: ordmain[key].ordNo,
              upDate: ordmain[key].upDate,
              kurStartTime
            });
          }
          if (0 < this.ordMainList.length) {
            this.ordMainList.sort((a,b) => b.kurStartTime.localeCompare(a.kurStartTime));
            //mod #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy start
            // this.selectedOrdMain = this.ordMainList[0];
            this.selectedOrdMain = deepCopy(this.ordMainList[0]);
            //mod #9289 直近の過去指示(投与薬剤を含まない)を使った治療予定作成時にエラー発生 zy end
          }
        }
      }
    },

    /**
     * 指定日の直近治療予定日を取得する
     * @param {String} 検索基準日
     */
    getMostRecentDay(findDay = moment(this.planStartDate).format("YYYYMMDD")) {
      const upper = this.selectedDates.find(date => date >= findDay);
      const lower = [...this.selectedDates].reverse().find(date => date <= findDay);
      const treatDate = lower || upper;

      if (treatDate) {
        this.selectedTreatDate = moment(treatDate).format("YYYY/MM/DD");
      }

      return treatDate;
    },

    /**
     * クールマスタを取得する
     */
    async getMstKur() {
      // del #8347 【デグレ】????患者治療割り当てができない dou start
      // add bug 8162 修正 chen start
      // this.setLoadingScreenVisible(true);
      // add bug 8162 修正 chen end
      // del #8347 【デグレ】????患者治療割り当てができない dou end
      const paramJson = {};
      paramJson.facility_cd = this.getFacilityCd;
      paramJson.is_del = 0;
      const response = await ApiHelper.get("/mstInfo/mstKur", paramJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndPlanCreate.vue', 'getMstKur', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        }
      );

      if (200 !== response.status) {
        return null;
      }
      this.mstKurInfo = response.data;
    },

    /**
     * 治療方法マスタを取得する
     */
    async getMstTreatment() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstTreatmentInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstTreatment",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstTreatment', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstTreatmentInfo = response.data;
    },

    /**
     * VAマスタを取得する
     */
    async getMstVa() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstVaInfo = null;
      const response = await ApiHelper.get("/mstInfo/mstVa", paramJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndPlanCreate.vue', 'getMstVa', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        }
      );

      if (200 !== response.status) {
        return null;
      }
      this.mstVaInfo = response.data;
    },

    /**
     * ダイアライザマスタを取得する
     */
    async getMstDialyzer() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstDialyzerInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstDialyzer",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstDialyzer', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstDialyzerInfo = response.data;
    },

    /**
     * ダイアライザマスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstDialyzerTabooAllergy() {
      this.mstDialyzerTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstDialyzer/${this.selectedPatId}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstDialyzerTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstDialyzerTabooAllergyInfo = response.data;
    },

    /**
     * 薬剤マスタを取得する
     */
    async getMstMedicine() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstMedicineInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicine",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstMedicine', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstMedicineInfo = response.data;
    },

    /**
     * 薬剤マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstMedicineTabooAllergy() {
      this.mstMedicineTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstMedicine/${this.selectedPatId}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstMedicineTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstMedicineTabooAllergyInfo = response.data;
    },

    /**
     * 調製薬剤マスタを取得する
     */
    async getMstMedicineMix() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstMedicineMixInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicineMix",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstMedicineMix', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstMedicineMixInfo = response.data;
    },

    /**
     * 調製薬剤マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstMedicineMixTabooAllergy() {
      this.mstMedicineMixTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstMedicineMix/${this.selectedPatId}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstMedicineMixTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstMedicineMixTabooAllergyInfo = response.data;
    },

    /**
     * 手技マスタを取得する
     */
    async getMstProcedure() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstProcedureInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstProcedure",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstProcedure', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstProcedureInfo = response.data;
    },

    /**
     * 投与タイミングマスタを取得する
     */
    async getMstMedicateTiming() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstMedicateTimingInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstMedicateTiming",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstMedicateTiming', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      if (200 !== response.status) {
        return null;
      }
      this.mstMedicateTimingInfo = response.data;
    },

    /**
     * 医療材料マスタを取得する
     */
    async getMstEquipment() {
      const paramJson = {};
      paramJson.facilityCd = this.getFacilityCd;
      this.mstEquipmentInfo = null;
      const response = await ApiHelper.get(
        "/mstInfo/mstEquipment",
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstEquipment', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstEquipmentInfo = response.data;
    },

    /**
     * 医療材料マスタ(禁忌・アレルギー込み)を取得する
     */
    async getMstEquipmentTabooAllergy() {
      this.mstEquipmentTabooAllergyInfo = null;
      const response = await ApiHelper.get(
        `/mstInfo/mstEquipment/${this.selectedPatId}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getMstEquipmentTabooAllergy', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      if (200 !== response.status) {
        return null;
      }
      this.mstEquipmentTabooAllergyInfo = response.data;
    },

    /**
     * 装置設定デフォルトマスタを取得する
     */
    async getmstDeviceSetInfo() {
      this.mstDeviceSetInfo = await getDeviceSetInfoMst(
        this.getFacilityCd
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'getmstDeviceSetInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw new Error(error);
      });
    },

    /**
     * 治療方法編集時の更新処理
     */
    async updateTreatMethod(structData) {
      console.log("IndPlanCreate.vue updateTreatMethod this.startLoadingScreen();");
      this.startLoadingScreen();
      const treatDateList = await this.getTreatDateList(structData);
      const sendJson = {};
      // 治療方法セットコード
      sendJson.treatment_set_cd = this.selectedSet.cd;
      // 更新日時
      sendJson.up_date = this.selectedSet.upDate;
      // 患者ID
      sendJson.pat_id = structData.patId;
      // 開始日
      sendJson.start_date = structData.indStartDate;
      // 終了日
      sendJson.end_date = structData.indEndDate;
      // 施設コード
      sendJson.facility_cd = structData.facilityCd;
      // 治療日リスト
      sendJson.treatDays = JSON.stringify(treatDateList);
      // 曜日パターン
      sendJson.week_pattern = JSON.stringify(structData.indWeeks);
      // 登録対象治療方法
      sendJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 登録対象クール
      sendJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 指示者コード
      sendJson.ind_user_id = structData.indUser;
      // 指示者コード
      sendJson.upd_user_id = structData.updUser;
      // 治療方法変更フラグ
      sendJson.treat_method_flag = structData.treatMethodFlag;
      // 終了日格納有無
      sendJson.is_deadline = structData.isDeadline;
      // 治療種別
      sendJson.treat_type = 0;
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 strat
      // オーダー番号
      sendJson.startsFlg = structData.ordNo ? "0123456" : "0";
      if (structData.rstDialysisState != "0" && structData.ordNo) {
        await this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000050].title,
        message: messageFormat(DIALOG_MESSAGES[13000050].message),
        callback: answer => {
          if (answer === 1) {
            // 更新実績フラグ:1～6
            sendJson.rst_flag = true;
            }else{
              // 更新実績フラグ:0
              sendJson.rst_flag = false;
            }
          }
        });
      }else {
        // 更新実績フラグ:0
        sendJson.rst_flag = false;
      }
      // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
      // スキップ更新フラグ
      sendJson.is_skip_update = structData.isSkipFlag
        ? structData.isSkipFlag
        : null;
      if (this.isWarnTabooAllergyFlag && !structData.acceptWarnFlag) {
        // 禁忌・アレルギー警告フラグがtrueの場合、かつ警告受け入れフラグがfalseの場合
        this.$parent.$parent.$parent.messageDialogInfo.messageCd = 12010004;
        this.$parent.$parent.$parent.messageDialogInfo.type = "2";
        this.$parent.$parent.$parent.messageDialogInfo.stringParams = [
          "<br>登録を行いますか？"
        ];
        this.$parent.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("IndPlanCreate.vue updateTreatMethod return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // API呼び出し
      sendJson.hosp_pat_id = this.selectedPat.pat_personal_main.hosp_pat_id;
      sendJson.user_id = this.getStateUserAccountInfo.userId;
      // add FNSI-7325 劉全航 start
      sendJson.invoke_page_name = "pat-viewer";
      sendJson.creat = true;
      // add FNSI-7325 劉全航 end
      const response = await ApiHelper.post(
        "/mainData/updatetByTreatSetCd2/",
        sendJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndPlanCreate.vue', 'updateTreatMethod', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log("IndPlanCreate.vue updateTreatMethod throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
      let duplicatedOrdInfo = [];
      if (200 === response.status && response.data.duplicatedOrdNoList
          && response.data.duplicatedOrdNoList.length > 0) {
        // 同日予定でベッド未登録となったオーダー情報を取得
        const responseDuplicatedOrdInfo = await ApiHelper.post(
          `/mainData/getDuplicatedOrdList/${structData.facilityCd}`,
          response.data.duplicatedOrdNoList
        ).catch(error => {
          getErrorMessage('IndPlanCreate.vue', 'updateTreatMethod', error);
          console.log("IndPlanCreate.vue updateTreatMethod throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });

        duplicatedOrdInfo = responseDuplicatedOrdInfo.data;
      }
      // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end
      //add 8117 治療方法編集画面から治療方法セットを適用すると既に設定しているクール・ベッド・治療開始時刻がすべて未登録となる 張 start
      // ベッド未登録となった予定が存在する場合メッセージ表示
      if (response.data.updateIndSchedule!=null) {
          let BedUnregistSchInfo = [];
        if (200 === response.status && response.data.updateIndSchedule
            && response.data.updateIndSchedule.length > 0) {
          // ベッド未登録となったオーダー情報を取得
          const responseScheduleInfo = await ApiHelper.post(
            `/mainData/getProcessOrdSchedule/${structData.facilityCd}/1`,
            response.data.updateIndSchedule
          ).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            console.log("IndPlanCreate.vue updateTreatMethod throw error; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            throw error;
          });
          BedUnregistSchInfo = responseScheduleInfo.data;
        }
            if (BedUnregistSchInfo.length > 0) {
          let infoList = "<br>"
          if (BedUnregistSchInfo && BedUnregistSchInfo.length > 0) {
            BedUnregistSchInfo.forEach((item) => {
              infoList = infoList + item + "<br>"
            })
          }
           this.$ons.notification.alert({
             // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "警告",
              title: DIALOG_MESSAGES["00300018"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: this.messageInfo(12010006).replace("{$1}",infoList),
              callback: answer => {
              if (answer == 0) {
                //OK
                // モーダルを閉じる
                this.hideModal();
              }
            }
            });
        }
      }
      //add 8117 治療方法編集画面から治療方法セットを適用すると既に設定しているクール・ベッド・治療開始時刻がすべて未登録となる 張 end
      let isHideModal = true;
      if (200 === response.status && undefined !== response.data.msgCd) {
        if (_.has(this.$parent.$parent, "showMessage")) {
          this.$parent.$parent.showMessage(response.data.msgCd);
        } else {
          this.$parent.showMessage(response.data.msgCd);
        }
        isHideModal = false;
      }
      //add 6623 HD→HDF，HF，OHDF，OHF，I-HDFへ切り替えたときに表示されるメッセージが意味不明 張 start
      //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
      let layouts=[]
      if (this.getSelectedLayout) {
      this.getSelectedLayout[0].categoryItem.forEach(ele=> {
          if(ele.subCategoryNo==10||ele.subCategoryNo==11||ele.subCategoryNo==12||
          ele.subCategoryNo==13||ele.subCategoryNo==15||ele.subCategoryNo==16){
            layouts.push(ele.subCategoryNo)
          }
      })
      }
      //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
        // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou start
        // if (200 === response.status && undefined !== response.data.msglist) {
        if (200 === response.status && undefined !== response.data.msglist && response.data.msglist.length > 0) {
        // mod #8420 【IES起票】【画面】【患者経過総合ビューア】治療方法変更にエラーが発生 dou end
          let msgList = response.data.msglist;
          let messages = "";
          let showMessage = false;
          //add 8485 2023-03-21透析治療で治療時間を10時間より大きい数値を入力しても注意喚起メッセージが表示されない 張 start
          //add 6146 2023-03-31 治療方法変更時のメッセージが不正 張 start
          if (msgList.includes("12000021")) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000021].title,
            message: this.messageInfo(12000021),
            callback: answer => {
            if (answer == 0) {
              this.hideModal();
            }
          }
          });
        }
        //add 6146 2023-03-31 治療方法変更時のメッセージが不正 張 end
          if (msgList.includes("12000020")) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/25 メッセージボックス全調整 林峻峰 start
              // title: "治療時間上限",
              title: DIALOG_MESSAGES[12000020].title,
              // mod #6107 2023/03/25 メッセージボックス全調整 林峻峰 end
              message: this.messageInfo(12000020),
              callback: answer => {
              if (answer == 0) {
                //OK
                // モーダルを閉じる
                this.hideModal();
              }
            }
            });
          }
          //add 8485 2023-03-21透析治療で治療時間を10時間より大きい数値を入力しても注意喚起メッセージが表示されない 張 end
          if (msgList.includes("12000074")) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "除水プログラム設定変更通知",
              title: DIALOG_MESSAGES[12000074].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: this.messageInfo(12000074),
              callback: answer => {
              if (answer == 0) {
                //OK
                // モーダルを閉じる
                this.hideModal();
              }
            }
            });
          }
          if (msgList.includes("12000019")) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "TMP監視モード設定変更通知",
              title: DIALOG_MESSAGES[12000019].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: this.messageInfo(12000019),
              callback: answer => {
                if (answer == 0) {
                  //OK
                  // モーダルを閉じる
                  this.hideModal();
                }
              }
            });
          }
          //mod FNSI-6623 劉全航 start
          if (msgList.includes("12000024")) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "",
            title: DIALOG_MESSAGES[12000024].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: this.messageInfo(12000024),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        //mod FNSI-6623 劉全航 end
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
        if (msgList.includes("16010001")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(16010001),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        if (msgList.includes("22010011")) {
          this.$ons.notification.alert({
            title: "",
            message: this.messageInfo(22010011),
            callback: answer => {
            if (answer == 0) {
              //OK
              // モーダルを閉じる
              this.hideModal();
            }
          }
          });
        }
        // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 start
        if (msgList.includes("12010007")) {
          if (duplicatedOrdInfo.length > 0) {
            const params = {
              DuplicatedOrdInfo: duplicatedOrdInfo}
              EventBus.$emit("isDuplicated", params);
            }
        }
        // add 11061 治療方法変更治療時間が長すぎて他の予定と衝突する 関 end
        // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end
          messages = messageFormat(DIALOG_MESSAGES[12000334].message);
          msgList.forEach(item => {
            if ("12000074"!=item && "12000019"!=item) {
              //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 start
              if (("12000075"==item&&layouts.includes(10))||("12000076"==item&&layouts.includes(12))||
              ("12000077"==item&&layouts.includes(13))||("12000078"==item&&layouts.includes(15))||
              ("12000079"==item&&layouts.includes(16))||("12000080"==item&&layouts.includes(11))) {
              //add 6925治療モードを変更した際の制限事項，注意メッセージについて 張岩 end
                showMessage = true;
                messages = messages + this.messageInfo(item) + "<br>";
              }
            }
          })
          if (showMessage) {
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "プログラム設定変更通知",
                title: DIALOG_MESSAGES[12000334].title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: messages,
              callback: answer => {
                if (answer == 0) {
                  //OK
                // モーダルを閉じる
                this.hideModal();
              }
            }
            });
          }

          // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
          if (msgList.includes("22020004")) {
            this.$parent.$parent.$parent.messageDialogInfo.messageCd = 22020004;
            this.$parent.$parent.$parent.messageDialogInfo.type = "1";
            this.$parent.$parent.$parent.messageDialogInfo.isDialogVisible = true;
            console.log("IndTreatMethod.vue updateIndInfo return; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            // 処理終了
            return;
          }
          // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end
        }
        //add 6623 HD→HDF，HF，OHDF，OHF，I-HDFへ切り替えたときに表示されるメッセージが意味不明 張 end

      console.log("IndPlanCreate.vue updateTreatMethod this.finishLoadingScreen();");
      this.finishLoadingScreen();
      return isHideModal;
    },

    /**
     * チェック処理
     */
    checkEdit(num) {
      // キャンセル時チェックなら処理終了
      if (1 === num) {
        return;
      }
      // 予定内容が選択されていなければメッセージ表示
      if ("" === this.selectedSet.cd) {
        if (this.isUpdateMethod) {
          return true;
        } else {
          this.$parent.$parent.messageDialogInfo.messageCd = 22010001;
          this.$parent.$parent.messageDialogInfo.stringParams = ["予定内容"];
          this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        }
      }
    },

    // add FNSI-濃度プログラムチェックの追加 楊 start
    /**
     * 治療方法を取得
     */
    getTreatmentCd() {
      // キャンセル時チェックなら処理終了
      return this.selectedSet.treatmentCd;
    },
    // add FNSI-濃度プログラムチェックの追加 楊 end

    getTreatType(structData) {
      // TODO: 治療種別「1日・通常・隔日・隔週」差異あり。「画面："3", "0", "1", "2"」「サーバー：0, 1, 2, 3」
      // １日
      let treatType = "3";
      if (structData.isShowTreatType) {
        // 治療種別が特殊(1日)以外の場合

        treatType = structData.cycleWeek;
      }
      return treatType;
    },

    /**
     * 装置設定の取得元を返す
     * @returns {Object} 装置設定デフォルトマスタまたは治療方法セットマスタ
     */
    getDeviceSetSrc(devType) {
      // 選択中治療方法セットの装置設定が未登録の場合、装置設定デフォルトマスタを展開
      if (!this.selectedDeviceSetInfo) {
        return this.mstDeviceSetInfo.ord[devType];
      } else {
        const devMode = getChartMode(
          devType,
          this.selectedDeviceSetInfo[devType]
        );
        const devData =
          devMode === null
            ? this.mstDeviceSetInfo.ord[devType]
            : this.selectedDeviceSetInfo[devType];
        return devData;
      }
    },

    /**
     * 装置設定のスイッチを取得する
     * @returns {String} OFF・ON
     */
    getDeviceSetMode(devType) {
      if (!this.selectedTreatSet) {
        return null;
      }

      const retVal = getChartMode(devType, this.getDeviceSetSrc(devType));

      if (retVal === null) {
        return null;
      } else if (retVal === "off") {
        return "OFF";
      } else {
        return "ON";
      }
    },

    /**
     * チャート表示用データを取得する
     * @returns {Object} チャートデータ
     */
    getDeviceSetData(devType, subType) {
      if (!this.selectedTreatSet) {
        return {};
      }

      const condInfo = this.selectedTreatSet
        ? JSON.parse(this.selectedTreatSet.indCondInfo)
        : this.condInfo;
      const retVal = createChartData(
        devType,
        this.getDeviceSetSrc(devType),
        condInfo
      );

      return subType === undefined ? retVal : retVal[subType];
    },

    // 拡張設定項目表示制御
    viewAdvancedSettingsParam(){
      // 透析量プログラム項目の表示フラグ更新
      this.isDispDialysisAmountProgram = this.getAdvancedSettings.func_advcds.some(
        setting =>
          setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
      );
      // BV-UFC項目の表示フラグ更新
      this.isDispBvUfc = this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
      );
    },

    /**
     * IndEditBaseのwatch対象コントロールで変更が行われた際の制御
     */
    changeParentStartDate(value) {
      this.planStartDate = value;
      this.setTreatSetList();
    },
    // add 10443 身体情報・DW・目標体重バグ 関  start
    changeDw(indStartDate, indWeeks) {
      if (this.selectedSet.isTreatSet) {
        // 目標日計算
        let targetDate = "";
        // 取得開始日は何曜日ですか
        const startDay = new Date(indStartDate);
        const startDayOfWeek = startDay.getDay();
        let weekFlg = false;
        if (indWeeks) {
          indWeeks.forEach(item=> {
          if (item.done) {
            let calculationDate = new Date(startDay);
            let offset = item.value - startDayOfWeek;
            if (item.value < startDayOfWeek && item.value != 0) {
              calculationDate.setDate(startDay.getDate() + 7+offset);
            }else {
              calculationDate.setDate(startDay.getDate() + offset);
            }
            if (moment(calculationDate).isSameOrAfter(startDay)
              && (targetDate === "" || moment(calculationDate).isBefore(targetDate))) {
              targetDate = calculationDate;
            }
            weekFlg = true;
          }
          });
        }
        if (!weekFlg) {
          targetDate = startDay;
        }
        // 目標日最近の日付DW取得
        const tDate = moment(targetDate, "YYYYMMDD").add(1,"day");
        let examDate = "";
        let ctlNo = "";
        let indValue = "";
        this.getPhysicalInfo.forEach(pInfo => {
          if (pInfo.exam_date && moment(pInfo.exam_date).isBefore(moment(tDate).format("YYYY-MM-DD"))
            &&pInfo.dw !== undefined && pInfo.dw !== null) {
            if (examDate === "" || moment(pInfo.exam_date).isAfter(examDate)) {
              examDate = pInfo.exam_date;
              indValue = pInfo.dw;
              ctlNo = pInfo.ctl_no;
            }else if(moment(pInfo.exam_date).isSame(examDate)){
              if (ctlNo && pInfo.ctl_no > ctlNo) {
                examDate = pInfo.exam_date;
                indValue = pInfo.dw;
                ctlNo = pInfo.ctl_no;
              }
            }
          }
        });

        // DW
        if (indValue != "") {
          this.dwOfDate = indValue + " kg";
        }else{
          this.dwOfDate = "未登録"
        }
        if (this.selectedSet.cd) {
          this.condInfo.forEach(item => {
          if (item.cond === "39" && item.label === "DW") {
            item.value = this.dwOfDate;
            return;
          }
         })
        }
      }
    },
    async searchTreatDateDw(){
      const paramJson = {
            ind_start_date: this.$parent.structData.indStartDate,
            facility_cd: this.$parent.structData.facilityCd,
            week_pattern: JSON.stringify(this.$parent.structData.indWeeks),
            ind_kur_cd: JSON.stringify(this.$parent.structData.selectedKur),
            ind_treatment_cd: JSON.stringify(this.$parent.structData.selectedTreat),
            pat_id: this.$parent.structData.patId,
            ord_no: this.$parent.structData.ordNo
      }
      const response = await ApiHelper.post(
            "/mainData/getTreatDateDw",
            paramJson
          ).catch(error => {
            getErrorMessage('IndPlanCreate.vue', 'searchTreatDateDw', error);
            throw error;
        });
        // DW
        if (response.data.dw != "") {
          this.dwOfDate = response.data.dw + " kg";
        }else{
          this.dwOfDate = "未登録"
        }
        // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  start
        // 目標体重
        if (response.data.targetWeight != "" && response.data.targetWeight != "-1") {
          this.targetWeightOfDate = response.data.targetWeight + " kg";
        }else{
          this.targetWeightOfDate = "DWと同じ";
        }
        if (this.selectedSet.cd) {
          this.condInfo.forEach(item => {
          if (item.cond === "39" && item.label === "DW") {
            item.value = this.dwOfDate;
          }
          if (item.cond === "3" && item.label === "目標体重" && this.targetWeightOfDate) {
            item.value = this.targetWeightOfDate;
          }
          // mod 10742 治療方法変更時に治療方法セットを使うと、DWと同じに変更されてしまう 関  end
      })
        }
    }
    // add 10443 身体情報・DW・目標体重バグ 関  end
  }
};
</script>

<style scoped>
.cond-table-style {
  border-top: 0.5px solid #cccccc;
  border-bottom: 0.5px solid #cccccc;
}

.cond-row-style {
  padding: 5px 0px;
  font-size:1.0em;
}

.cond-title-style,
.cond-title-style-device-set {
  color: #fafafa;
  background-color: #333333;
  text-align: center;
  padding: 3px 5px 3px 0px;
  word-break: break-all;
}

.cond-sub-title-style {
  margin-left: 2em;
}

.cond-item-style {
  display: flex;
  flex-flow: column;
  align-content: center;
  text-align: center;
  word-break: break-all;
}

.cond-item-style > div {
  flex: 1;
}

.cond-item-style >>> .highcharts-container {
  margin: 0 auto;
}

.cond-td-style {
  border-bottom: 0.5px solid #cccccc;
  border-right: 0.5px solid #cccccc;
}

.cond-header-style {
  -webkit-writing-mode: vertical-lr;
  -ms-writing-mode: vertical-lr;
  writing-mode: vertical-lr;
  color: #fafafa;
  background-color: #333333;
  text-align: left;
  align-items: center;
  padding: 5px 2px 5px 2px;
}

.cond-item-main-style {
  display: grid;
}

.ons-row {
  height: auto;
}

.column-size {
  flex: 0 0 160px;
  max-width: 160px;
}

.comment-content {
  height: 100% !important;
}

.taboo-allergy {
  color: red;
}

.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
  @media print {
  .cond-item-main-style >>> .cond-title-style {
    min-width:0 !important;
    max-width: none !important;
    flex-basis: calc(40% - 18px) !important;
  }

  .medi-title-style, .equip-title-style ,.comment-title-style {
    flex-basis: 40% !important;
    min-width:0 !important;
    max-width: none !important;
  }
}
</style>
