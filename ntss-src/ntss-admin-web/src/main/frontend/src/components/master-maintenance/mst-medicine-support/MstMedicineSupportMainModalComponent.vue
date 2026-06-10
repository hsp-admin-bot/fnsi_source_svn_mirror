/**
* 投薬支援マスタモーダル
*/
<template>
  <div class="main-area">

    <div style="height: auto">
      <v-ons-row>
        <v-ons-col width="30%" class="cond-td-style">
          セット名
        </v-ons-col>
        <v-ons-col>
          <input
            :value="getEditRecord.name"
            class="k-textbox input-required"
            :class="{ activeInputBorder: isNameModified }"
            @input="setCss($event.target.value)"
            @blur="setLayoutName($event.target.value)"
          />
        </v-ons-col>
      </v-ons-row>

      <v-ons-row>
        <v-ons-col width="30%" class="cond-td-style">
          目標検査値
          <!--add 鞠  目標検査値の単位(検査項目) start -->
          <span v-for=" item in examItemCycling" :key="item.unit">
            <input
              type="text"
              width="5%"
              :value="item.unit"
              style="text-align:left;height: 90%;width: 15%"
              disabled
              :class="{
                activeInputBorder:
                  !(
                    item.unit == undefined && oldExamItemCycling[0].unit == null
                  ) && item.unit !== oldTargetUnit,
              }"
            />
          </span>
          <!--add 鞠  目標検査値の単位(検査項目) end -->
        </v-ons-col>
        <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
        <!-- <v-ons-col>
          <input
            type="number"
            :value="getEditRecord.targetInspection"
            class="k-textbox"
            style="text-align:left;height: 90%"
            :max="99999999"
            @blur="setTargetInspection($event.target.value)"
          />
        </v-ons-col> -->
        <v-ons-col>
          <input
            @change="inputNumber($event)"
            type="number"
            step="1"
            :value="getEditRecord.targetInspection"
            class="k-textbox"
            :class="{ activeInputBorder: isTargetModified }"
            style="text-align:right;height: 90%"
            @focus="handleFocus"
            @blur="setTargetInspection($event)"
            @mousewheel.prevent="handleMouseWheel($event)"
          />
        </v-ons-col>
        <!-- mod mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
      </v-ons-row>

    </div>

    <div class="disp-item-content-area print-height-auto" style=" overflow-x: auto;">

      <!-- mod redmine 5083 スマホ、タブレット表示の際の詳細モーダルのレイアウト不正 start -->
      <v-ons-row style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" style="min-width: 310px" class="cond-title-style cond-td-style">
        </v-ons-col>
        <v-ons-col width="70%" style="min-width: 480px" class="cond-title-style cond-td-style">
          項目名
        </v-ons-col>
      </v-ons-row>
      <!-- mod redmine 5083 スマホ、タブレット表示の際の詳細モーダルのレイアウト不正 end -->

      <v-ons-row style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style">
          <span class="item-height-style">
            検査項目(cycling・予測値)
          </span>
          <!-- mod 画面デザイン 對應 王 start-->
          <!--          <v-ons-button-->
          <!--            ref="popoverButtonExamItemCycling"-->
          <!--            class="common-style-select-button"-->
          <!--            @click="createPopoverDataExamItemCycling()"-->
          <!--            style="float: right"-->
          <!--          >-->
          <v-ons-button
            ref="popoverButtonExamItemCycling"
            class="common-style-select-button btn3-normal"
            @click="createPopoverDataExamItemCycling()"
            style="float: right"
          >
          <!-- mod 画面デザイン 對應 王 end-->

          <!-- mod redmine 5006 追加の代わりに選択 宋qy start -->
            選択
          <!-- mod redmine 5006 追加の代わりに選択 宋qy end -->

          </v-ons-button>
        </v-ons-col>
        <v-ons-col
          style="min-width: 480px"
          name="cond-transition"
          class="cond-td-style cond-transition"
          tag="ons-col"
        >
          <v-ons-row v-for="(item, index) in examItemCycling" :key="item.value">

            <v-ons-col class="equipment-column">検査項目</v-ons-col>
            <v-ons-col class="equipment-data-column">
              <input
                v-model="item.text"
                style="background-color: #ebebe4 !important; color: #000"
                class="equipment-input-style common-input-style"
                :class="{
                  activeInputBorder:
                    (oldExamItemCycling[0] &&
                      item.text !== oldExamItemCycling[0].text) ||
                    oldExamItemCycling[index] == undefined,
                }"
                type="text"
                readonly
                 tabindex="-1"
                disabled
                @keydown.prevent
              />
              <!-- del redmine 5006 選択なくなる 宋qy start -->
<!--              <v-ons-button-->
<!--                ref="popoverButtonExamItemCyclingE"-->
<!--                class="common-style-select-button"-->
<!--                @click="createPopoverDataExamItemCycling()"-->
<!--              >選択-->
<!--              </v-ons-button>-->
              <!-- del redmine 5006 選択なくなる 宋qy end -->
            </v-ons-col>

          <v-ons-col width="3%" vertical-align="center" v-if="item.examflg">
            <v-ons-checkbox
            v-model="item.examflg[0]"
            @change="item.examflg[0] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析前</label>
          </v-ons-col>

            <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
            v-model="item.examflg[1]"
            @change="item.examflg[1] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析後</label>
          </v-ons-col>

          <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
             v-model="item.examflg[2]"
             @change="item.examflg[2] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>その他</label>
          </v-ons-col>

            <v-ons-col class="cond-del-style">
              <button class="ntss-btn-outset" @click="deleteItem('examItemCycling', index)">
                <v-ons-icon icon="fa-trash"/>
              </button>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%"  class="cond-td-style">
          <span class="item-height-style">
            検査項目(検査平均値)
          </span>
          <!-- mod 画面デザイン 對應 王 start-->
          <!--          <v-ons-button-->
          <!--            ref="popoverButtonExamItemAverage"-->
          <!--            class="common-style-select-button"-->
          <!--            @click="createPopoverDataExamItemAverage()"-->
          <!--            style="float: right"-->
          <!--          >-->
          <v-ons-button
            ref="popoverButtonExamItemAverage"
            class="common-style-select-button btn3-normal"
            @click="createPopoverDataExamItemAverage()"
            style="float: right"
          >
          <!-- mod 画面デザイン 對應 王 end-->
            追加
          </v-ons-button>
        </v-ons-col>
        <ons-col
          style="min-width: 480px"
          name="cond-transition"
          class="cond-td-style cond-transition"
        >
          <!--add 検査平均値項目の順番変更 宋qy start -->
          <draggable v-model="examItemAverage"
                     force-fallback="true"
                     animation="250"
                     @start="onStart"
                     @end="onEnd">
            <v-ons-row class="darg-item" v-for="(item, index) in examItemAverage" :key="item.value">
          <!--add 検査平均値項目の順番変更 宋qy end -->
              <v-ons-col class="equipment-column">検査項目</v-ons-col>
              <v-ons-col class="equipment-data-column">
                <input
                  v-model="item.text"
                  class="equipment-input-style common-input-style"
                  type="text"
                  readonly
                   @keydown.prevent
                  style="background-color: #ebebe4 !important; color: #000"
                  :class="{
                    activeInputBorder:
                      (oldExamItemAverage.length > 0 &&
                        oldExamItemAverage[index] &&
                        item.text !== oldExamItemAverage[index].text) ||
                      oldExamItemAverage[index] == undefined,
                  }"
                />
                <v-ons-button
                  :ref="'ExamItemAverage' + item.value"
                  class="common-style-select-button"
                  @click="createPopoverDataExamItemAverageItem(item.value)"
                >選択
                </v-ons-button>
              </v-ons-col>
          <v-ons-col width="3%" vertical-align="center" v-if="item.examflg">
           <v-ons-checkbox
            v-model="item.examflg[0]"
            @change="item.examflg[0] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析前</label>
          </v-ons-col>

            <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
            v-model="item.examflg[1]"
            @change="item.examflg[1] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析後</label>
          </v-ons-col>

          <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
             v-model="item.examflg[2]"
             @change="item.examflg[2] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>その他</label>
          </v-ons-col>

              <v-ons-col class="cond-del-style">
                <button class="ntss-btn-outset" @click="deleteItem('examItemAverage', index)">
                  <v-ons-icon icon="fa-trash"/>
                </button>
              </v-ons-col>
            </v-ons-row>
          </draggable>
        </ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style">
          <span class="item-height-style">
            検査項目(回帰直線)
          </span>
          <!-- mod 画面デザイン 對應 王 start-->
          <!--          <v-ons-button-->
          <!--            ref="popoverButtonExamItemRegression"-->
          <!--            class="common-style-select-button"-->
          <!--            @click="createPopoverDataExamItemRegression()"-->
          <!--            style="float: right"-->
          <!--          >-->
          <v-ons-button
            ref="popoverButtonExamItemRegression"
            class="common-style-select-button btn3-normal"
            @click="createPopoverDataExamItemRegression()"
            style="float: right"
          >
          <!-- mod 画面デザイン 對應 王 end-->
          <!-- mod redmine 5006 追加の代わりに選択 宋qy start -->
          選択
          <!-- mod redmine 5006 追加の代わりに選択 宋qy end -->
          </v-ons-button>
        </v-ons-col>
        <v-ons-col
          style="min-width: 480px"
          name="cond-transition"
          class="cond-td-style cond-transition"
          tag="ons-col"
        >
          <v-ons-row v-for="(item, index) in examItemRegression" :key="item.value">

            <v-ons-col class="equipment-column">検査項目</v-ons-col>
            <v-ons-col class="equipment-data-column">
              <input
                v-model="item.text"
                class="equipment-input-style common-input-style"
                type="text"
                 :class="{
                  activeInputBorder:
                    (oldExamItemRegression.length > 0 &&
                      oldExamItemRegression[index] &&
                      item.text !== oldExamItemRegression[index].text) ||
                    oldExamItemRegression[index] == undefined,
                }"
                readonly
                  tabindex="-1"
                @keydown.prevent
                disabled
                style="background-color: #ebebe4 !important; color: #000"
              />
              <!-- del redmine 5006 選択なくなる 宋qy start -->
<!--              <v-ons-button-->
<!--                ref="popoverButtonExamItemRegressionE"-->
<!--                class="common-style-select-button"-->
<!--                @click="createPopoverDataExamItemRegression()"-->
<!--              >選択-->
<!--              </v-ons-button>-->
              <!-- del redmine 5006 選択なくなる 宋qy end -->
            </v-ons-col>

            <v-ons-col width="3%" vertical-align="center" v-if="item.examflg">
            <v-ons-checkbox
            v-model="item.examflg[0]"
            @change="item.examflg[0] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析前</label>
          </v-ons-col>

            <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
            v-model="item.examflg[1]"
            @change="item.examflg[1] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>透析後</label>
          </v-ons-col>

          <v-ons-col width="3%" vertical-align="center">
            <v-ons-checkbox
             v-model="item.examflg[2]"
             @change="item.examflg[2] = $event.target.checked;setDetailInfo()"
            />
          </v-ons-col>
          <v-ons-col width="7%" vertical-align="center">
            <label>その他</label>
          </v-ons-col>

            <v-ons-col class="cond-del-style">
              <button class="ntss-btn-outset" @click="deleteItem('examItemRegression', index)">
                <v-ons-icon icon="fa-trash"/>
              </button>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style">
          <span class="item-height-style">
            薬剤（薬剤平均値）
          </span>
          <!-- mod 画面デザイン 對應 王 start-->
          <!--          <v-ons-button-->
          <!--            ref="popoverButtonMedicineAverage"-->
          <!--            class="common-style-select-button"-->
          <!--            @click="createPopoverDataMedicineAverage()"-->
          <!--            style="float: right"-->
          <!--          >-->
          <v-ons-button
            ref="popoverButtonMedicineAverage"
            class="common-style-select-button btn3-normal"
            @click="createPopoverDataMedicineAverage()"
            style="float: right"
          >
          <!-- mod 画面デザイン 對應 王 end-->
            追加
          </v-ons-button>
        </v-ons-col>
        <ons-col
          style="min-width: 480px"
          name="cond-transition"
          class="cond-td-style cond-transition"
        >
          <!--add 薬剤平均値項目の順番変更 宋qy start -->
          <draggable v-model="medicineAverage"
                     force-fallback="true"
                     animation="250"
                     @start="onStart"
                     @end="onEnd">
            <v-ons-row  class="darg-item" v-for="(item, index) in medicineAverage" :key="item.value">
          <!--add 薬剤平均値項目の順番変更 宋qy end -->
              <v-ons-col class="equipment-column">薬剤</v-ons-col>
              <v-ons-col class="equipment-data-column">
                <input
                  v-model="item.text"
                  class="equipment-input-style common-input-style"
                  type="text"
                  readonly
                   @keydown.prevent
                  style="background-color: #ebebe4 !important; color: #000"
                  :class="{
                    activeInputBorder:
                      (oldMedicineAverage.length > 0 &&
                        oldMedicineAverage[index] &&
                        item.text !== oldMedicineAverage[index].text) ||
                      oldMedicineAverage[index] == undefined,
                  }"
                />
                <v-ons-button
                  :ref="'MedicineAverage' + item.value"
                  class="common-style-select-button"
                  @click="createPopoverDataMedicineAverageItem(item.value)"
                >選択
                </v-ons-button>
              </v-ons-col>

              <v-ons-col class="cond-del-style">
                <button class="ntss-btn-outset" @click="deleteItem('medicineAverage', index)">
                  <v-ons-icon icon="fa-trash"/>
                </button>
              </v-ons-col>
            </v-ons-row>
          </draggable>
        </ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style">
        <span class="item-height-style">
          薬剤（ESA投与支援）
        </span>
          <!-- mod 画面デザイン 對應 王 start-->
          <!--          <v-ons-button-->
          <!--            ref="popoverButtonMedicineESA"-->
          <!--            class="common-style-select-button"-->
          <!--            @click="createPopoverDataMedicineESA()"-->
          <!--            style="float: right"-->
          <!--          >-->
          <v-ons-button
            ref="popoverButtonMedicineESA"
            class="common-style-select-button btn3-normal"
            @click="createPopoverDataMedicineESA()"
            style="float: right"
          >
          <!-- mod 画面デザイン 對應 王 end-->
          <!-- mod redmine 5006 追加の代わりに選択 宋qy start -->
            選択
          <!-- mod redmine 5006 追加の代わりに選択 宋qy end -->
          </v-ons-button>
        </v-ons-col>
        <v-ons-col
          style="min-width: 480px"
          name="cond-transition"
          class="cond-td-style cond-transition"
        >
          <v-ons-row v-for="(item, index) in medicineESA" :key="item.value">
            <v-ons-col class="equipment-column">薬剤</v-ons-col>
            <v-ons-col class="equipment-data-column">
              <input
                v-model="item.text"
                class="equipment-input-style common-input-style"
                type="text"
                readonly
                  disabled
                tabindex="-1"
                @keydown.prevent
                style="background-color: #ebebe4 !important; color: #000"
                :class="{
                  activeInputBorder:
                    (oldMedicineESA.length > 0 &&
                      oldMedicineESA[index] &&
                      item.text !== oldMedicineESA[index].text) ||
                    oldMedicineESA[index] == undefined,
                }"
              />
<!--              <v-ons-button-->
<!--                ref="popoverButtonMedicineESAE"-->
<!--                class="common-style-select-button"-->
<!--                @click="createPopoverDataMedicineESA()"-->
<!--              >選択-->
<!--              </v-ons-button>-->
              <!-- mod 鞠 start ESA自分のポップを選択するために-->
              <!-- del redmine 5006 選択なくなる 宋qy start -->
<!--              <v-ons-button-->
<!--                :ref="'MedicineESA' + item.value"-->
<!--                class="common-style-select-button"-->
<!--                @click="createPopoverDataMedicineESAItem(item.value)"-->
<!--              >選択-->
<!--              </v-ons-button>-->
              <!-- del redmine 5006 選択なくなる 宋qy end -->
              <!-- mod end ESA自分のポップを選択するために -->
            </v-ons-col>
            <v-ons-col class="cond-del-style">
              <button class="ntss-btn-outset" @click="deleteItem('medicineESA', index)">
                <v-ons-icon icon="fa-trash"/>
              </button>
            </v-ons-col>
          </v-ons-row>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style item-height-style">
          初期レンジ（検査平均値）
        </v-ons-col>
        <v-ons-col  style="min-width: 480px" class="cond-td-style">
          <select
            v-model="initialRangeExam"
              style="width: 100%"
            :class="{
              activeInputBorder: initialRangeExam !== oldInitialRangeExam,
            }"
            name="mstModalTreatSetSelect"
            @change="setDetailInfo"
          >
            <option
              v-for="item in InitialRange"
              :key="item.value"
              :value="item.value"
            >
              {{ item.text }}
            </option>
          </select>
        </v-ons-col>
      </v-ons-row>

      <v-ons-row  style="flex-wrap: nowrap; min-width: 780px;">
        <v-ons-col width="30%" class="cond-td-style item-height-style">
          初期レンジ（薬剤平均投与量）
        </v-ons-col>
        <v-ons-col  style="min-width: 480px" class="cond-td-style">
          <select
            v-model="initialRangeMedicine"
            style="width: 100%"
            :class="{
              activeInputBorder:
                initialRangeMedicine !== oldInitialRangeMedicine,
            }"
            name="mstModalTreatSetSelect"
            @change="setDetailInfo"
          >
            <option
              v-for="item in InitialRange"
              :key="item.value"
              :value="item.value"
            >
              {{ item.text }}
            </option>
          </select>
        </v-ons-col>
      </v-ons-row>

      <!--検査項目(cycling・予測値)-->
      <pop-over
        v-bind="popoverDataExamItemCycling"
        :target-position-element="$refs.popoverButtonExamItemCycling"
        @popover-close="closePopoverExamItemCycling"
        @popover-return="updateExamItemCycling"
      />

      <!--検査項目(検査平均値)-->
      <pop-over-multiple
        v-bind="popoverDataExamItemAverage"
        :target-position-element="$refs.popoverButtonExamItemAverage"
        @popover-close="closePopoverExamItemAverage"
        @popover-return="updateExamItemAverage"
      />

      <!--検査項目(検査平均値)項目-->
      <pop-over
        v-bind="popoverDataExamItemAverageItem"
        :target-position-element='popoverTargetElementExamItem()'
        @popover-close="closePopoverExamItem"
        @popover-return="updateExamItem"
      />

      <!--検査項目(回帰直線)-->
      <pop-over
        v-bind="popoverDataExamItemRegression"
        :target-position-element="$refs.popoverButtonExamItemRegression"
        @popover-close="closePopoverExamItemRegression"
        @popover-return="updateExamItemRegression"
      />

      <!--薬剤（薬剤平均値）-->
      <pop-over-multiple
        v-bind="popoverDataMedicineAverage"
        :target-position-element="$refs.popoverButtonMedicineAverage"
        @popover-close="closePopoverMedicineAverage"
        @popover-return="updateMedicineAverage"
      />

      <!--薬剤（薬剤平均値）項目-->
      <pop-over
        v-bind="popoverDataMedicineAverageItem"
        :target-position-element='popoverTargetElementMedicineItem()'
        @popover-close="closePopoverMedicine"
        @popover-return="updateMedicine"
      />

      <!--薬剤（ESA投与支援）-->
      <pop-over
        v-bind="popoverDataMedicineESA"
        :target-position-element="$refs.popoverButtonMedicineESA"
        @popover-close="closePopoverMedicineESA"
        @popover-return="updateMedicineESA"
      />
      <!--薬剤（ESA投与支援）項目 add start 鞠 選択のポップを追加-->
      <pop-over
        v-bind="popoverDataMedicineESAItem"
        :target-position-element="popoverTargetElementMedicineESAItem()"
        @popover-close="closePopoverMedicineESAItem"
        @popover-return="updateMedicineESAItem"
      />
      <!--  add end    -->
    </div>
  </div>
</template>

<script>
import {mapGetters, mapActions} from "vuex";
import { medicine, medicineClass, medicineMix } from "@/functions/mst/MstGetters.js";
import baseDeviceSetInfoList from "@/components/deviceset-info/base-modules/BaseDeviceSetInfoList.vue";
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import MasterSelectorMultiple from "@/components/common/master-selector/MasterSelectorMultiple";
import {ApiHelper} from "@/apis/AxiosHelper";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {EventBus} from "@/eventBus";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
// FNSI-修正 マスタ削除の対応 楊 add end
import { isEqual } from 'lodash';

import vuedraggable from "vuedraggable";

export default {
  components: {
    "pop-over": MasterSelector,
    "pop-over-multiple": MasterSelectorMultiple,
    draggable: vuedraggable
  },
  mixins: [baseDeviceSetInfoList],

  data() {
    return {
       isNameModified: false,
      isTargetModified: false,
      isFirstItemModify: false,
      isRangeChanged: false,
      isRangeChangedSecond: false,
      examItemCycling: [],
      examItemAverage: [],
      examItemRegression: [],
      medicineAverage: [],
      medicineESA: [],
     initialRangeExam: 0,
      initialRangeMedicine: 0,
      // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 start
      min:-99999999,
      max:99999999,
      blurFlg:false,
      focusFlg:false,
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      oldName:"",
      oldTargetInspection:0,
      oldTargetUnit:null,
      oldExamItemCycling: [],
      oldExamItemAverage: [],
      oldExamItemRegression: [],
      oldMedicineAverage: [],
      oldMedicineESA: [],
      oldInitialRangeExam: 0,
      oldInitialRangeMedicine: 0,
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
      // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 end

      // mod 投薬支援マスタ 初期レンジの選択肢が間違っている。 孔 start
      // InitialRange: [
      //   {text: "", value: 0},
      //   {text: "３か月", value: 1},
      //   {text: "６か月", value: 2},
      //   {text: "１年", value: 3},
      //   {text: "２年", value: 4},
      // ],
      InitialRange: [
        {text: "", value: 0},
        {text: "12週", value: 1},
        {text: "6ヶ月", value: 2},
        {text: "1年", value: 3},
        {text: "3年", value: 4},
      ],
      // mod 初期レンジ（検査平均値）の選択肢が間違っている。 孔 end

      /**
       * 検査項目(cycling・予測値)選択吹き出し用データセット
       */
      popoverDataExamItemCycling: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      /**
       * 検査項目(検査平均値)選択吹き出し用データセット
       */
      popoverDataExamItemAverage: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        maxSelectedItems: 5
      },
      /**
       * 検査項目(検査平均値)項目選択吹き出し用データセット
       */
      popoverDataExamItemAverageItem: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        itemNo: null
      },
      /**
       * 検査項目(回帰直線)選択吹き出し用データセット
       */
      popoverDataExamItemRegression: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false
      },
      /**
       * 薬剤（薬剤平均値）選択吹き出し用データセット
       */
      popoverDataMedicineAverage: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        maxSelectedItems: 5,
        mstMachineSupportFlg: true
      },/**
       * 薬剤（薬剤平均値）項目選択吹き出し用データセット
       */
      popoverDataMedicineAverageItem: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        mstMachineSupportFlg: true
      },
      /**
       * 薬剤（ESA投与支援）選択吹き出し用データセット
       */
      popoverDataMedicineESA: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        mstMachineSupportFlg: true
      },
      /**
       * 薬剤（ESA投与支援）項目 選択吹き出し用データセット 鞠 add start
       */
      popoverDataMedicineESAItem: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        mstMachineSupportFlg: true
      },
      // add end
    };
  },

  computed: {
    // add マスタ一覧 施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 施設切替を可能とする 王 end
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    ...mapGetters("master-maintenance", [
      "getColumns",
      "getEditRecord",
      "getMasterRecordList"
    ]),
    ...mapGetters("user", ["getAdvancedSettings"]),
    targetUnit(){
      return {
        targetUnit: this.examItemCycling.length == 0 ? null:this.examItemCycling[0].unit
      }
    }
  },

  watch: {
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    // getEditRecord:{
    //   handler(){
    //     if (this.getEditRecord.name !== this.oldName ||
    //       this.getEditRecord.targetInspection !== this.oldTargetInspection ||
    //       this.getEditRecord.targetUnit !== this.oldTargetUnit ||
    //       !isEqual(this.examItemCycling, this.oldExamItemCycling) ||
    //       !isEqual(this.examItemAverage, this.oldExamItemAverage) ||
    //       !isEqual(this.examItemRegression, this.oldExamItemRegression) ||
    //       !isEqual(this.medicineAverage, this.oldMedicineAverage) ||
    //       !isEqual(this.medicineESA, this.oldMedicineESA) ||
    //       this.initialRangeExam !== this.oldInitialRangeExam ||
    //       this.initialRangeMedicine !== this.oldInitialRangeMedicine
    //     ) {
    //       this.changeButton();
    //     } else {
    //       EventBus.$emit("mstHolidayRegistered", true);
    //     }
    //   },
    //   deep:true
    // }
      getEditRecord: {
      handler() {
        const checks = [
          ["name", this.getEditRecord.name, this.oldName],
          [
            "targetInspection",
            this.getEditRecord.targetInspection,
            this.oldTargetInspection,
          ],
          ["targetUnit", this.getEditRecord.targetUnit, this.oldTargetUnit],
          ["examItemCycling", this.examItemCycling, this.oldExamItemCycling],
          ["examItemAverage", this.examItemAverage, this.oldExamItemAverage],
          [
            "examItemRegression",
            this.examItemRegression,
            this.oldExamItemRegression,
          ],
          ["medicineAverage", this.medicineAverage, this.oldMedicineAverage],
          ["medicineESA", this.medicineESA, this.oldMedicineESA],
          ["initialRangeExam", this.initialRangeExam, this.oldInitialRangeExam],
          [
            "initialRangeMedicine",
            this.initialRangeMedicine,
            this.oldInitialRangeMedicine,
          ],
        ];
        //9246 zhaojinzhao start
        // let changed = false;

        // checks.forEach(([key, now, old]) => {
        //   const equal = isEqual(now, old);
        //   if (!equal) {
        //     if (key == "targetUnit" && now == null && old == "") {
        //       return;
        //     } else {
        //       changed = true;
        //     }
        //   }
        // });
        const changed = checks.some(([key, now, old]) => {
          if (isEqual(now, old)) return false;
          if (key === "targetUnit" && now == null && old === "") return false;
          return true;
        });
        //9246 zhaojinzhao end

        if (changed) {
          this.changeButton();
        } else {
          EventBus.$emit("mstHolidayRegistered", true);
        }
      },
      deep: true,
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
  },

  async created() {
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    this.oldName = this.getEditRecord.name;
    this.oldTargetInspection = this.getEditRecord.targetInspection;
    this.oldTargetUnit = this.getEditRecord.targetUnit;
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    if (this.getEditRecord && this.getEditRecord.detailInfo) {
      const detailInfo = JSON.parse(this.getEditRecord.detailInfo)
        const respExamItem = await ApiHelper.get("mstInfo/mstExamItem/", {
        facilityCd: this.getFacilitySwitch,
      }).catch((error) => {
        throw error;
      });
      let mstExamItemData = [];
      if (respExamItem.data && respExamItem.data.length) {
        mstExamItemData = respExamItem.data;
      }
      const changeExamItemName = (item) => {
        const examItem = mstExamItemData.find(
          (exam) => exam.examItemCd === item.value
        );
        if (examItem) {
          item.text =
            examItem.isDel === "1" || examItem.isDisp === "0"
              ? MASTER_DELETE_DISPLAY.DELETED + examItem.examItemName
              : examItem.examItemName;
        }
      };

      if (detailInfo.examItemCycling) {
          this.examItemCycling = detailInfo.examItemCycling;

          this.examItemCycling.forEach(item => {
            if (!Array.isArray(item.examflg)) {
              item.examflg = [true, true, true];
            }
          });
        this.examItemCycling.forEach(changeExamItemName);

          this.oldExamItemCycling = JSON.parse(JSON.stringify(this.examItemCycling));
      }
      if (detailInfo.examItemAverage) {
        // this.examItemAverage = detailInfo.examItemAverage;
        // this.oldExamItemAverage = [...detailInfo.examItemAverage];

         this.examItemAverage = detailInfo.examItemAverage;

          this.examItemAverage.forEach(item => {
            if (!Array.isArray(item.examflg)) {
              item.examflg = [true, true, true];
            }
          });
        this.examItemAverage.forEach(changeExamItemName);
          this.oldExamItemAverage = JSON.parse(JSON.stringify(this.examItemAverage));
      }
      if (detailInfo.examItemRegression) {
        // this.examItemRegression = detailInfo.examItemRegression;
        // this.oldExamItemRegression = [...detailInfo.examItemRegression];

         this.examItemRegression = detailInfo.examItemRegression;

          this.examItemRegression.forEach(item => {
            if (!Array.isArray(item.examflg)) {
              item.examflg = [true, true, true];
            }
          });
        this.examItemRegression.forEach(changeExamItemName);
          this.oldExamItemRegression = JSON.parse(JSON.stringify(this.examItemRegression));
      }
      if (detailInfo.medicineAverage) {
        this.medicineAverage = detailInfo.medicineAverage;
        this.oldMedicineAverage = [...detailInfo.medicineAverage];
      }
      if (detailInfo.medicineESA) {
        this.medicineESA = detailInfo.medicineESA;
        this.oldMedicineESA = [...detailInfo.medicineESA];
      }
      if (detailInfo.initialRangeExam) {
        this.initialRangeExam = detailInfo.initialRangeExam;
        this.oldInitialRangeExam = detailInfo.initialRangeExam;
      }
      if (detailInfo.initialRangeMedicine) {
        this.initialRangeMedicine = detailInfo.initialRangeMedicine;
        this.oldInitialRangeMedicine = detailInfo.initialRangeMedicine;
      }

      const medicineRes = await ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", {facilityCd: this.getFacilitySwitch})
        .catch(error => {
          throw error;
        });
      let medicineData = [];
      if (medicineRes.data && medicineRes.data.length) {
        medicineData = medicineRes.data
      }

      const medicineMixRes = await ApiHelper.get("/mstInfo/mstMedicineMixIncludeDeleted", {facilityCd: this.getFacilitySwitch})
        .catch(error => {
          throw error;
        });
      let medicineMixData = [];
      if (medicineMixRes.data && medicineMixRes.data.length) {
        medicineMixData = medicineMixRes.data
      }

      const medicineGroupRes = await ApiHelper.get("/mstInfo/mstMedicineGroupIncludeDeleted", {facilityCd: this.getFacilitySwitch})
        .catch(error => {
          throw error;
        });
      let medicineGroupData = [];
      if (medicineGroupRes.data && medicineGroupRes.data.length) {
        medicineGroupData = medicineGroupRes.data
      }

    const changemedicineItemName = (item) => {
        let medicineItem;
        let key;
        switch (item.type) {
          case 1:
            key = "medicineName";
            medicineItem = medicineData.find(
              (medicine) => medicine.medicineCd === item.value
            );
            break;
          case 2:
            key = "medicineMixName";
            medicineItem = medicineMixData.find(
              (medicine) => medicine.medicineMixCd === item.value
            );
            break;
          case 3:
            key = "medicineGroupName";
            medicineItem = medicineGroupData.find(
              (medicine) => medicine.medicineGroupCd === item.value
            );
            break;
          default:
            key = "medicineGroupName";
            medicineItem = medicineGroupData.find(
              (medicine) => medicine.medicineGroupCd === item.value
            );
            break;
        }
        if (medicineItem) {
          item.text =
            medicineItem.isDel === "1" || medicineItem.isDisp === "0"
              ? MASTER_DELETE_DISPLAY.DELETED + medicineItem[key]
              : medicineItem[key];
        }
      };
   
      this.medicineAverage.forEach(changemedicineItemName)
      this.medicineESA.forEach(changemedicineItemName)
      // add 投薬支援マスタ 削除されたデータの処理 孔 end
    }
    this.medicineValueFormat(this.medicineAverage)
    // mod 薬剤(ESA投与支援)の対象が間違っている。孔 start
    // this.medicineValueFormat(this.medicineESA)
    this.medicineValueFormat(this.medicineESA)
    // mod 薬剤(ESA投与支援)の対象が間違っている。孔 end
  },

  async mounted() {
    this.$el.parentElement.style.height = "100%";
     //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },

  methods: {
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "edit",
      "setMasterRecordList",
      "editRecordBeEmpty",
    ]),

    // add redmine 5006 薬剤平均値項目の順番変更 宋qy start
    /**
     * @description ドラッグを始めた際と終えた際の処理
     */
    onStart() {
      this.drag = true;
    },
    onEnd() {
      this.drag = false;
      this.setDetailInfo();
    },
    // add redmine 5006 薬剤平均値項目の順番変更 宋qy end

    popoverTargetElementExamItem() {
      const elementName = "ExamItemAverage" + this.popoverDataExamItemAverageItem.itemNo;
      const element = this.$refs[elementName];
      if (!element || !element.length || !element.length > 0) return null
      return element[0]
    },
    popoverTargetElementMedicineItem() {
      const elementName = "MedicineAverage" + this.popoverDataMedicineAverageItem.itemNo;
      const element = this.$refs[elementName];
      if (!element || !element.length || !element.length > 0) return null
      return element[0]
    },
    // add start 鞠 :target-position-elementのメゾット
    popoverTargetElementMedicineESAItem() {
      const elementName = "MedicineESA" + this.popoverDataMedicineESAItem.itemNo;
      const element = this.$refs[elementName];
      if (!element || !element.length || !element.length > 0) return null
      return element[0]
    },
    // add end

    /**
     * @description 薬剤の値の初期化
     */
    medicineValueFormat(item) {
      const medicineType = type => {
        switch (type) {
          case 1:
            return "A"
          case 2:
            return "B"
          case 3:
            return "C"
        }
      }
      const medicineValueAddType = item => {
        item.value = item.value + "" + medicineType(item.type)
      }
      item.forEach(medicineValueAddType)
    },
    //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start
    inputNumber(e) {
        // 数値範囲内かどうかの確認
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            e.target.value = this.min;
            this.blurFlg=true;
          } else if (e.target.value < this.min) {
            e.target.value = this.max;
            this.blurFlg=true;
          }else{
            this.blurFlg=false;
          }
        }
          this.getEditRecord.targetInspection = Number(e.target.value)
    },
    //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 end
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    handleMouseWheel(e) {
      if (!this.focusFlg) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > this.max) {
        value = this.min;
      }
      if(value < this.min) {
        value = this.max;
      }
      this.getEditRecord.targetInspection = value
      this.changeButton()
    },
    handleFocus(){
      this.focusFlg=true;
    },
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
    /**
     * @description editRecordに更新
     */
    setDetailInfo() {
      const medicineValueChange = item => {
        item.value = item.value.replace("A", "")
        item.value = item.value.replace("B", "")
        item.value = item.value.replace("C", "")
        item.value = Number(item.value)
      }

      const medicineAverageDeepCopy = deepCopy(this.medicineAverage)
      medicineAverageDeepCopy.forEach(medicineValueChange)
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 start
      // const medicineESADeepCopy = deepCopy(this.medicineESA)
      // medicineESADeepCopy.forEach(medicineValueChange)
      const medicineESADeepCopy = deepCopy(this.medicineESA)
      medicineESADeepCopy.forEach(medicineValueChange)
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 start

      const detailInfoObj = {
        examItemCycling: this.examItemCycling,
        examItemAverage: this.examItemAverage,
        examItemRegression: this.examItemRegression,
        medicineAverage: medicineAverageDeepCopy,
        medicineESA: medicineESADeepCopy,
        // medicineESA: this.medicineESA,
        initialRangeExam: this.initialRangeExam,
        initialRangeMedicine: this.initialRangeMedicine,
      }
      const detailInfo = JSON.stringify(detailInfoObj)
      this.setEditRecord({...this.getEditRecord, detailInfo,...this.targetUnit});
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    /**
     * @description 投薬支援パターン名更新
     */
    setLayoutName(value) {
       this.isNameModified = value !== this.oldName;
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({...this.getEditRecord, name});
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    setCss(value) {
      if(value && document.getElementsByClassName("input-invalid")[0]) {
        document.getElementsByClassName("input-invalid")[0].classList.remove("input-invalid");
      }
    },

    /**
     * @description 目標検査値更新
     */
    // mod #5589 2023/04/12 数値IFのスタイル全不正 張博 start
    setTargetInspection(event) {
         // 限界値判定
      let value = event.target.value;
      if (value == this.max && this.blurFlg) {
        event.target.value = this.min;
        this.blurFlg = false;
      }else if (value == this.min && this.blurFlg) {
        event.target.value = this.max;
        this.blurFlg = false;
      }
      // const targetInspection = value;
      // 編集中マスタを更新
      // this.setEditRecord({...this.getEditRecord, targetInspection});
      this.focusFlg=false;
      this.isTargetModified = value != this.oldTargetInspection;

    },
// mod #5589 2023/04/12 数値IFのスタイル全不正 張博 end
    /**
     * @description 項目を配列から削除
     * @param type  削除項目の種類
     * @param index 要素番号
     */
    deleteItem(type, index) {
      switch (type) {
        case "examItemCycling":
          this.examItemCycling.splice(index, 1);
          break;
        case "examItemAverage":
          this.examItemAverage.splice(index, 1);
          break;
        case "examItemRegression":
          this.examItemRegression.splice(index, 1);
          break;
        case "medicineAverage":
          this.medicineAverage.splice(index, 1);
          break;
        case "medicineESA":
          this.medicineESA.splice(index, 1);
          break;
        default:
          break;
      }
      this.setDetailInfo()
    },

    /**
     * @description バリデーションチェック
     * @summary 確定ボタン押下でイベント発火
     * @returns 「true: 編集内容設定&閉じる」, 「false: メッセージ表示」
     */
    validateOnRegistration() {
      if (this.getEditRecord.name === null || this.getEditRecord.name === "") {
        document.getElementsByClassName("input-required")[0]?.classList?.add("input-invalid");
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000015].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 start
          // message: "投薬支援パターン名を設定して下さい"
          message: DIALOG_MESSAGES[12000015].message
          // add 全マスタメッセージ調整 王 start
        });
        return false;
      }
      return true
    },

    /**
     * @description ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     *              (薬剤)
     */
    async createPopoverDataMedicine(popoverData) {
      // add マスタ一覧 施設切替を可能とする 王 start
      // const medicineData = await medicine(this.facilityCd).catch(error => {
      const medicineData = await medicine(this.getFacilitySwitch).catch(error => {
        throw error;
      });
      // const medicineMixData = await medicineMix(this.facilityCd).catch(
      const medicineMixData = await medicineMix(this.getFacilitySwitch).catch(
        error => {
          throw error;
        }
      );
      // const classData = await medicineClass(this.facilityCd).catch(
      const classData = await medicineClass(this.getFacilitySwitch).catch(
        error => {
          throw error;
        }
      );

      const medicineGroupRes = await ApiHelper.get("/mstInfo/mstMedicineGroup", {
        // facilityCd: this.facilityCd
        facilityCd: this.getFacilitySwitch
      }).catch(error => {
        throw error;
      });
      // add マスタ一覧 施設切替を可能とする 王 end
      const medicineGroupData = medicineGroupRes.data !== null ? medicineGroupRes.data : []
      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd
        };
      };
      let filterArr = [];
      filterArr = classData.map(filterMapping);
      filterArr.unshift({text: "すべて", value: 0});

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      const contentParamIsDisp = item => {
        return item.isDisp === "1";
      };
      const contentMapping = (item, cdKey, nameKey, category) => {
        let value
        switch (category) {
          case 1:
            value = `${item[cdKey]}A`
            break;
          case 2:
            value = `${item[cdKey]}B`
            break;
          case 3:
            // item.classCd = null
            value = `${item[cdKey]}C`
            break;
        }
        return {
          value: value,
          fnValue: {
            薬剤区分: category,
            薬剤分類: item.classCd
          },
          text: item[nameKey]
        };
      };
      const medicineList = medicineData
        .filter(contentParamIsDisp)
        .map(item => contentMapping(item, "medicineCd", "medicineName", 1));
      const medicineMixList = medicineMixData
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineMixCd", "medicineMixName", 2)
        );
      const medicineGroup = medicineGroupData
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineGroupCd", "medicineGroupName", 3)
        );

      // mod redmine 5006 薬剤（ESA投与支援）欄は薬効換算のみ選択できるはずだが、薬剤（薬剤平均値）の薬剤選択画面の表示順は薬効換算を先頭にすること 宋qy start
      let contentArr;
      if (popoverData.flagESA === "ESA") {
        contentArr = [...medicineGroup];
      } else {
        contentArr = [ ...medicineGroup, ...medicineList, ...medicineMixList];
      }
      // mod redmine 5006 薬剤（ESA投与支援）欄は薬効換算のみ選択できるはずだが、薬剤（薬剤平均値）の薬剤選択画面の表示順は薬効換算を先頭にすること 宋qy end

      // if (popoverData.itemNo) contentArr = contentArr.filter(item => !this.medicineAverage.some(e => e.value === item.value))
      // mod start 鞠 (4992フィルター不正) 選択したデータが必要 medicineESAとthis.medicineAverage
      if (popoverData.flagESAItem === 'ESAItem') {
        if (popoverData.itemNo) contentArr = contentArr.filter(item => !this.medicineESA.some(e => e.value === item.value && popoverData.itemNo !== e.value))
      }else{
        if (popoverData.itemNo) contentArr = contentArr.filter(item => !this.medicineAverage.some(e => e.value === item.value && popoverData.itemNo !== e.value))
      }
      // mod end
      popoverData.popoverFilter = [
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            {text: "すべて", value: 0},
            {text: "通常薬剤", value: 1},
            {text: "調製薬剤", value: 2},
            {text: "薬効換算", value: 3}
          ]
        },
        {
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: filterArr
        }
      ];

      popoverData.popoverTitleHeader = "薬剤";
      popoverData.popoverContentLabel = "薬剤名";
      popoverData.popoverContentDataset = contentArr;
      popoverData.popoverVisible = true;
    },

    async createPopoverDataMedicineMedicineGroup(popoverData) {
      const medicineGroupRes = await ApiHelper.get("/mstInfo/mstMedicineGroup", {
        facilityCd: this.getFacilitySwitch
      }).catch(error => {
        throw error;
      });
      const medicineGroupData = medicineGroupRes.data !== null ? medicineGroupRes.data : []

      // ポップオーバのコンテンツデータ(フィルターしたデータ)を取りまとめる
      const contentParamIsDisp = item => {
        return item.isDisp === "1";
      };
      const contentMapping = (item, cdKey, nameKey) => {
        return {
          value: item[cdKey],
          text: item[nameKey]
        };
      };
      const medicineGroup = medicineGroupData
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineGroupCd", "medicineGroupName")
        );
      let contentArr = [...medicineGroup];

      popoverData.popoverTitleHeader = "薬剤";
      popoverData.popoverContentLabel = "薬剤名";
      popoverData.popoverContentDataset = contentArr;
      popoverData.popoverVisible = true;
    },

    /**
     * @description ポップオーバーを表示する前に、必要なデータを取得して、
     *              ポップオーバー用フォーマットをコンバートする
     *              (検査項目)
     */
    async createPopoverDataExamItem(popoverData) {
      // 検査項目一覧を取得
      // add マスタ一覧 施設切替を可能とする 王 start
      // const respExamItem = await ApiHelper.get("mstInfo/mstExamItem/", {facilityCd: this.facilityCd})
      const respExamItem = await ApiHelper.get("mstInfo/mstExamItem/", {facilityCd: this.getFacilitySwitch})
      // add マスタ一覧 施設切替を可能とする 王 end
        .catch(error => {
          throw error;
        });
      let mstExamItem = [];
      if (respExamItem.data && respExamItem.data.length) {
        mstExamItem = respExamItem.data
      }
      mstExamItem = mstExamItem.filter(item => item.isDisp === "1" && item.isDel === "0");

      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.examItemName,
          value: item.examItemCd,
          unit: item.unit // add 鞠 目標検査値(検査項目)の単位
        };
      };

      const contentArr = mstExamItem.map(filterMapping);

      popoverData.popoverTitleHeader = "検査項目";
      popoverData.popoverContentLabel = "検査項目名";
      popoverData.popoverContentDataset = contentArr;
      popoverData.popoverVisible = true;
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    async createPopoverDataExamItemNoDuplication(popoverData) {
      // 検査項目一覧を取得
      // add マスタ一覧 施設切替を可能とする 王 start
      // const respExamItem = await ApiHelper.get("mstInfo/mstExamItem/", {facilityCd: this.facilityCd})
      const respExamItem = await ApiHelper.get("mstInfo/mstExamItem/", {facilityCd: this.getFacilitySwitch})
      // add マスタ一覧 施設切替を可能とする 王 end
        .catch(error => {
          throw error;
        });
      let mstExamItem = [];
      if (respExamItem.data && respExamItem.data.length) {
        mstExamItem = respExamItem.data
      }
      mstExamItem = mstExamItem.filter(item => item.isDisp === "1" && item.isDel === "0");

      mstExamItem = mstExamItem.filter(item => !this.examItemAverage.some(e => e.value === item.examItemCd));

      // ポップオーバのフィルタデータを取りまとめる
      const filterMapping = item => {
        return {
          text: item.examItemName,
          value: item.examItemCd
        };
      };

      const contentArr = mstExamItem.map(filterMapping);

      popoverData.popoverTitleHeader = "検査項目";
      popoverData.popoverContentLabel = "検査項目名";
      popoverData.popoverContentDataset = contentArr;
      popoverData.popoverVisible = true;
    },

    async createPopoverDataExamItemCycling() {
      await this.createPopoverDataExamItem(this.popoverDataExamItemCycling);
    },
    async createPopoverDataExamItemAverage() {
      this.popoverDataExamItemAverage.popoverContentSelected.value = this.examItemAverage.map(item => {
        return item.value
      })
      await this.createPopoverDataExamItem(this.popoverDataExamItemAverage);
    },
    async createPopoverDataExamItemAverageItem(itemNo) {
      this.popoverDataExamItemAverageItem.itemNo = itemNo
      await this.createPopoverDataExamItemNoDuplication(this.popoverDataExamItemAverageItem);
    },
    async createPopoverDataExamItemRegression() {
      await this.createPopoverDataExamItem(this.popoverDataExamItemRegression);
    },
    async createPopoverDataMedicineAverage() {
      this.popoverDataMedicineAverage.popoverContentSelected.value = this.medicineAverage.map(item => {
        return item.value
      })
      await this.createPopoverDataMedicine(this.popoverDataMedicineAverage);
    },
    async createPopoverDataMedicineAverageItem(itemNo) {
      this.popoverDataMedicineAverageItem.itemNo = itemNo
      // add start 薬剤 平均 選択したもの 鞠
      this.popoverDataMedicineAverageItem.popoverContentSelected.value = itemNo
      // add end 薬剤 平均 選択したもの
      await this.createPopoverDataMedicine(this.popoverDataMedicineAverageItem);
    },
    async createPopoverDataMedicineESA() {
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 start

      // add redmine 5006 薬剤（ESA投与支援）欄は薬効換算のみ選択できるはずだが 宋qy start
      this.popoverDataMedicineESA.flagESA = 'ESA';
      // add redmine 5006 薬剤（ESA投与支援）欄は薬効換算のみ選択できるはずだが 宋qy end
      await this.createPopoverDataMedicine(this.popoverDataMedicineESA);
      // await this.createPopoverDataMedicineMedicineGroup(this.popoverDataMedicineESA);
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 end
    },
    // add 薬剤(ESA投与支援) 選択の項目 鞠 start
    async createPopoverDataMedicineESAItem(itemNo) {
      this.popoverDataMedicineESAItem.itemNo = itemNo
      this.popoverDataMedicineESAItem.popoverContentSelected.value = itemNo
      this.popoverDataMedicineESAItem.flagESAItem = 'ESAItem'
      await this.createPopoverDataMedicine(this.popoverDataMedicineESAItem);
    },
    // add end

    /**
     * @description 検査項目(cycling・予測値)ー選択を非表示
     */
    closePopoverExamItemCycling() {
      this.popoverDataExamItemCycling.popoverVisible = false;
    },

    /**
     * @description 検査項目(検査平均値)ー選択を非表示
     */
    closePopoverExamItemAverage() {
      this.popoverDataExamItemAverage.popoverVisible = false;
    },

    /**
     * @description 検査項目(検査平均値)項目ー選択を非表示
     */
    closePopoverExamItem() {
      this.popoverDataExamItemAverageItem.popoverVisible = false;
    },

    /**
     * @description 検査項目(回帰直線)ー選択を非表示
     */
    closePopoverExamItemRegression() {
      this.popoverDataExamItemRegression.popoverVisible = false;
    },

    /**
     * @description 薬剤（薬剤平均値）ー選択を非表示
     */
    closePopoverMedicineAverage() {
      this.popoverDataMedicineAverage.popoverVisible = false;
    },

    /**
     * @description 薬剤（薬剤平均値）項目ー選択を非表示
     */
    closePopoverMedicine() {
      this.popoverDataMedicineAverageItem.popoverVisible = false;
    },

    /**
     * @description 薬剤（ESA投与支援）ー選択を非表示
     */
    closePopoverMedicineESA() {
      this.popoverDataMedicineESA.popoverVisible = false;
    },

    /** add start 鞠 選択の項目
     * @description 薬剤（ESA投与支援）ー選択を非表示
     */
    closePopoverMedicineESAItem() {
      this.popoverDataMedicineESAItem.popoverVisible = false;
    },
    // add end

    /**
     * @description 検査項目(cycling・予測値)更新
     */
    updateExamItemCycling(data) {
      let temp = [{
        text: data.text,
        value: data.value,
        unit: data.unit, // add 鞠 単位
        examflg: [false, false, false]
      }]
      this.examItemCycling = temp
      this.setDetailInfo()
    },

    /**
     * @description 検査項目(検査平均値)更新
     */
    updateExamItemAverage(data) {
      this.examItemAverage = [];
      data.forEach(item => {
        if (item) {
          let temp = {
            text: item.text,
            value: item.value,
            examflg: [false, false, false]
          }
          this.examItemAverage.push(temp)
        }
      })
      this.setDetailInfo()
    },

    /**
     * @description 検査項目(検査平均値)項目更新
     */
    updateExamItem(data) {
      let temp = {
        text: data.text,
        value: data.value,
        examflg: [false, false, false]
      }
      const itemNo = this.popoverDataExamItemAverageItem.itemNo
      const index = this.examItemAverage.findIndex(e => e.value === itemNo)
      this.examItemAverage.splice(index, 1, temp)
      this.setDetailInfo()
    },

    /**
     * @description 検査項目(回帰直線)更新
     */
    updateExamItemRegression(data) {
      let temp = [{
        text: data.text,
        value: data.value,
        examflg: [false, false, false]
      }]
      this.examItemRegression = temp
      this.setDetailInfo()
    },

    /**
     * @description 薬剤（薬剤平均値）更新
     */
    updateMedicineAverage(data) {
      // add redmine 5006 【削除済み】と表示される 宋qy start
      if (this.medicineAverage) {
        for (let i = 0; i < this.medicineAverage.length; i++) {
          if(this.medicineAverage[i].text.indexOf('削除済み') !== -1) {
            for (let j = 0; j < data.length; j++) {
              if (data[j] === undefined) {
                data[j] = this.medicineAverage[i];
                break;
              }
            }
          }
        }
      }
      // add redmine 5006 【削除済み】と表示される 宋qy end
      this.medicineAverage = [];
      data.forEach(item => {
        if (item) {
          let temp = {
            text: item.text,
            value: item.value,
            type: item.fnValue !== undefined ? item.fnValue.薬剤区分:item.type // mod redmine 5006 【削除済み】と表示される 宋qy
          }
          this.medicineAverage.push(temp)
        }
      })
      this.setDetailInfo()
    },

    /**
     * @description 薬剤（薬剤平均値）項目更新
     */
    updateMedicine(data) {
      let temp = {
        text: data.text,
        value: data.value,
        type: data.fnValue.薬剤区分
      }
      const itemNo = this.popoverDataMedicineAverageItem.itemNo
      const index = this.medicineAverage.findIndex(e => e.value === itemNo)
      this.medicineAverage.splice(index, 1, temp)
      this.setDetailInfo()
    },

    /**
     * @description 薬剤（ESA投与支援）更新
     */
    updateMedicineESA(data) {
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 start
      let temp = [{
        text: data.text,
        value: data.value,
        type: data.fnValue.薬剤区分
      }]
      // let temp = [{
      //   text: data.text,
      //   value: data.value
      // }]
      // mod 薬剤(ESA投与支援)の対象が間違っている。孔 end
      this.medicineESA = temp
      this.setDetailInfo()
    },
    /**
     * add 項目 鞠
     * @description 薬剤（ESA投与支援）更新
     */
    updateMedicineESAItem(data) {
      let temp = [{
        text: data.text,
        value: data.value,
        type: data.fnValue.薬剤区分
      }]
      this.medicineESA = temp
      this.setDetailInfo()
    },
       getActiveClass(item, index) {
      const old = this.oldExamItemAverage;

      return {
        activeInputBorder:
          (old.length > 0 && old[index] && item.text !== old[index].text) ||
          this.oldExamItemAverage[index] == undefined,
      };
    },
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
.item-height-style {
  min-height: 30px;
  line-height: 30px;
}

.k-textbox {
  width: 100%;
}

/*add redmine 4999 プルダウンリストスタイル不正 孔 start*/
.k-textbox >>> select {
  height: 100%;
}
/*add redmine 4999 プルダウンリストスタイル不正 孔 end*/

.disp-item-content-area {
  /*max-height: 100%;*/
  width: 100%;
  overflow-x: auto;
}

.disp-item-content-area ons-row {
  height: auto;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr td:first-child {
  border: 1px solid lightgray;
  text-align: left;
  width: 15%;
}

.disp-item-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}

.cond-title-style {
  color: #fafafa;
  background-color: #333333;
  text-align: left;
  padding: 5px;
}

.cond-td-style {
  padding: 8px;
  border-bottom: 0.5px solid var(--ntss-border-color);
  border-right: 0.5px solid var(--ntss-border-color);
}

.cond-td-style > ons-row {
  padding: 10px;
  border: 1px solid var(--ntss-border-color);
}

.cond-del-style {
  max-width: 25px;
}

.cond-del-style > * {
  height: 100%;
}

.cond-disabled * {
  opacity: 0.5;
  pointer-events: none;
}

.cond-transition {
  padding: 0 !important;
}

@media screen and (max-width: 869px) {
  .cond-title-style {
    flex: 0 0 100% !important;
  }

  select[name="mstModalTreatSetSelect"] {
    padding: 0;
  }

  .common-style-select-button {
    width: 25% !important;
    box-sizing: border-box;
    min-width: 3.5em !important;
    float: right;
  }
}

.p-0 {
  padding: 0;
}

.custom-disp-item-area .k-textbox {
  font-size: unset;
}

.equipment-input-style {
  width: 70%;
  margin: 0px 5px 0px 0px;
}
.equipment-input-style >>> input {
  background-color: #ebebe4;
}

.equipment-column {
  flex: 0 0 5.4em;
  max-width: 20%;
  white-space: normal;
  margin: auto;
}

.equipment-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}

.input-disabled input[disabled] {
  color: #fff;
  opacity: 1
}

.input-required {
  color: black;
  background-color: #ffff99;
}

.input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

/* add 検査平均値項目、薬剤平均値項目の順番変更 宋qy start */
.darg-item {
  padding: 10px;
  border: 1px solid var(--ntss-border-color);
  cursor: move;
}

.darg-item:hover {
  cursor: move;
}
.activeInputBorder {
  border: 2px solid green !important;
  border-radius: 5px; /* 或者写具体值 */
  /* box-shadow: 0 0 2px #4caf50; */
}

select:hover {
  border-color: none !important;
  /* background-color: #ebebe4 !important; */
  outline: none !important;
}
.k-textbox:hover,
.k-textbox.k-state-hover,
.k-textarea:hover,
.k-textarea.k-state-hover,
.k-input.k-textbox:hover,
.k-input.k-textbox.k-state-hover {
  border-color: none !important;
  outline: none !important;
}

/* add 検査平均値項目、薬剤平均値項目の順番変更 宋qy end */
</style>
