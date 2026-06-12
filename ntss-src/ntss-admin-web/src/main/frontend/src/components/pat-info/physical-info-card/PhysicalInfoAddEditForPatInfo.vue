<template>
  <modal-base @onClose="hideModal_plus">
    <!--
      モーダルの中身はモーダルと一緒に描画しないとCSSが正常に適用されないのでv-if
    -->
    <template #body>
      <div class="physical-edit-area">
      <div class="edit-area">
<!-- add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start       -->
<!-- v-show="false" add by maxueqiang-->
        <v-ons-row v-show="false">
          <v-ons-col class="date-area">
            <label>検査日</label>
          </v-ons-col>
          <v-ons-col>
            <custom-input-date
              class="custom-date"
              :value="getPatDataJsonArray(physicalInfoData, 'inspect_date')"
              :disableDatesAfter="todayStr"
              :is-required="true"
              :disabled="isEditDw"
              @focus="moveCss($event)"
            />
          </v-ons-col>
        </v-ons-row>
<!--        add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end-->
        <v-ons-row>
          <v-ons-col class="order-area">
            <label>検査日時</label>
          </v-ons-col>
          <div>
            <v-ons-row>
              <v-ons-col class="input-area">
                <!--mod   7778 limingyang start-->
                <custom-input-date
                  class="custom-date change_date"
                  :value="getPatDataJsonArray(physicalInfoData, 'exam_day')"
                  :cardDiff="cardDiff"
                  ref = "examDate_id"
                  :is-show-clear="false"
                  :is-required="true"
                  :disabled="examDateEditable || isOtherFacilityRow()"
                />
                <!--mod   7778 limingyang end-->
              </v-ons-col>

              <v-ons-col class="unit">
                <!-- #5590 2023/04/24 ×を常に表示するように修正 林峻峰 start -->
                <!-- <custom-input-time :value="getPatDataJsonArray(physicalInfoData, 'exam_time')" ref = "examTime_id"/> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <custom-input-time :value="getPatDataJsonArray(physicalInfoData, 'exam_time')" ref = "examTime_id" :is-show-clear="true" /> -->
                <custom-input-time
                  :value="getPatDataJsonArray(physicalInfoData, 'exam_time')"
                  ref = "examTime_id"
                  :is-show-clear="true"
                  :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
                  @change="onOrderItemChange(); setDwPreviousInfo()"
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <!-- #5590 2023/04/24 ×を常に表示するように修正 林峻峰 end -->
              </v-ons-col>
            </v-ons-row>
          </div>

        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="order-area">
            <label>検査タイミング</label>
          </v-ons-col>
          <v-ons-col class="item-data">
            <custom-select
              class="ntss-custom-select custom-select-physical custom-input-half"
              :value="getPatDataJsonArray(physicalInfoData, 'order_class')"
              :options="orderClass"
              @change="onOrderItemChange()"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            />
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="height-area">
            <label>身長</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="300"
              :digits="4"
              :decimal-digits="1"
              :value="getPatDataJsonArray(physicalInfoData, 'height')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'height').editValue"
              :step="0.1"
              :min="0"
              :max="300"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'height').editValue = val }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            cm
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="weight-area">
            <label>検査時体重</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="300"
              :digits="5"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'ctr_weight')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              ref="ctr_weight"
              :value="getPatDataJsonArray(physicalInfoData, 'ctr_weight').editValue"
              :step="0.01"
              :min="0"
              :max="300"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'ctr_weight').editValue = val }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            kg
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="breast-area">
            <label>心横径</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="9999.99"
              :digits="6"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'breast_dia')"
              @blur="
                setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia)
              "
              @wheel.prevent="
                setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia)
              "
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'breast_dia').editValue"
              :step="0.01"
              :min="0"
              :max="9999.99"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'breast_dia').editValue = val; setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia) }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="chest-area">
            <label>胸郭横径</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="9999.99"
              :digits="6"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'chest_dia')"
              @blur="
                setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia)
              "
              @wheel.prevent="
                setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia)
              "
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'chest_dia').editValue"
              :step="0.01"
              :min="0"
              :max="9999.99"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'chest_dia').editValue = val; setCtr(physicalInfoData.breast_dia, physicalInfoData.chest_dia) }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="ctr-area">
            <label>CTR</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="100"
              :digits="5"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'ctr')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'ctr').editValue"
              :step="0.01"
              :min="0"
              :max="100"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'ctr').editValue = val }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            %
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="dw-area">
            <label :rowspan="isUpdateOrd ? 2 : false">DW</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :is-required="isValidate"
              :min-value="0"
              :max-value="300"
              :digits="5"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'dw')"
              @input="dwValue($event.target.value)"
              @wheel.prevent="dwValue($event.target.value)"
              ref = "ref_dw"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :required="isRequiredDw"
              :value="getPatDataJsonArray(physicalInfoData, 'dw').editValue"
              :step="0.01"
              :min="0"
              :max="300"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'dw').editValue = val;dwValue(val) }"
              @wheel.prevent="dwValue($event.target.value)"
              ref="ref_dw"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit dw-kg-area">
            kg
          </v-ons-col>
          <v-ons-col class="unit dw-kg-previous-area nowrap">
            kg&emsp;{{dwPreviousInfoDispData}}
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="dw-previous-area">
          <v-ons-col class="dw-area">
            <label></label>
          </v-ons-col>
          <v-ons-col class="input-area nowrap">
            <label>{{dwPreviousInfoDispData}}</label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row v-if="isUpdateOrd">
          <v-ons-col class="chest-area">
            <label>指示発行</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <input
              v-model="isUpdateOrd"
              type="checkbox"
              :disabled="
                getPatDataJsonArray(physicalInfoData, 'dw').editValue === null ||
                !getItemAuthorized('PatInfo', 'item_physical_info_card') ||
                isOtherFacilityRow()
              "
            />
          </v-ons-col>
        </v-ons-row>

        <v-ons-row v-if="selectedPhysicalInfoData.addEditC === '1'">
          <v-ons-col class="area-checkbox">
            <label></label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <custom-checkbox
              :value="isChangeTargetWeight"
              checked-value="1"
              unchecked-value="0"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
            >目標体重を変更する</custom-checkbox>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row v-if="selectedPhysicalInfoData.addEditC === '1' && isChangeTargetWeight.editValue === '1'">
          <v-ons-col class="target-weight-area">
            <label>目標体重</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="300"
              :digits="5"
              :decimal-digits="2"
              placeholder="DWと同じ"
              :value="getPatDataJsonArray(physicalInfoData, 'target_weight')"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              placeholder="DWと同じ"
              :value="getPatDataJsonArray(physicalInfoData, 'target_weight').editValue"
              :step="0.01"
              :min="0"
              :max="300"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'target_weight').editValue = val; }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            kg
          </v-ons-col>
        </v-ons-row>

         <!--  -->
        <v-ons-row v-if="selectedPhysicalInfoData.addEditC === '1' && isChangeTargetWeight.editValue === '1'">
          <v-ons-col class="indicator_date">
            <label>目標体重指示開始日</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!--mod じょはく start-->
            <!--mod   7778 limingyang start-->
            <!--#10715：日付IF修正20240910検証NG対応：村上Start-->
            <custom-input-date
              class="custom-date"
              :disableDatesBefore="todayStr"
              :value="
                getPatDataJsonArray(physicalInfoData, 'indicator_start_date')
              "
              :cardDiff="cardDiff"
              :is-required="true"
              :is-show-clear="false"
              @focus="moveCss($event)"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
            />
            <!--#10715：日付IF修正20240910検証NG対応：村上End-->
            <!--mod   7778 limingyang end-->
            <!--mod じょはく end-->
          </v-ons-col>
        </v-ons-row>

        <!-- v-if="selectedPhysicalInfoData.addEditC === '1' && isChangeTargetWeight.editValue === '1'" -->
         <v-ons-row >
          <v-ons-col class="indicator-area">
            <label>指示者</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- mod 画面デザイン改善対応 李 start -->
            <!-- <kendo-dropdownlist
              class="ntss-custom-kendo custom-select-physical"
              v-model="physicalInfoData.indicator_cd.editValue"
              :data-source="isOtherFacilityRow() ? otherFacilitySingleList : indUserList"
              :data-text-field="'fullName'"
              :data-value-field="'user_id'"
              style="margin-left: -1px;"
            /> -->
            <kendo-dropdownlist
              id="kendo-dropdownlist-select-id"
              class="ntss-custom-kendo custom-select-physical custom-input-full"
              :class="{ 'input-style-required': isValidate || isRequiredDw || getPatDataJsonArray(physicalInfoData, 'dw').editValue !== null,'isChangeStyle':selectedPhysicalInfoData.addEditC == 2 }"
              v-model="physicalInfoData.indicator_cd.editValue"
              :data-source="isOtherFacilityRow() ? otherFacilitySingleList : indUserList"
              :data-text-field="'fullName'"
              :data-value-field="'user_id'"
              style="margin-left: -1px;"
              :disabled="!getItemAuthorized('PatInfo', 'item_physical_info_card') || isOtherFacilityRow()"
            />
            <!-- mod 画面デザイン改善対応 李 end -->
          </v-ons-col>
          <v-ons-col class="unit">
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="target-weight-area">
            <label>前体重許容上限</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="999.99"
              :digits="5"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'pre_scale_upper')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'pre_scale_upper').editValue"
              :step="0.01"
              :min="0"
              :max="999.99"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'pre_scale_upper').editValue = val; }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            kg
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="target-weight-area">
            <label>前体重許容下限</label>
          </v-ons-col>
          <v-ons-col class="input-area">
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start -->
            <!-- <custom-input-number
              :min-value="0"
              :max-value="999.99"
              :digits="5"
              :decimal-digits="2"
              :value="getPatDataJsonArray(physicalInfoData, 'pre_scale_lower')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            /> -->
            <custom-input-number-pro
              :value="getPatDataJsonArray(physicalInfoData, 'pre_scale_lower').editValue"
              :step="0.01"
              :min="0"
              :max="999.99"
              :emptyVal="null"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
              @handlerInput="(val) =>{ getPatDataJsonArray(physicalInfoData, 'pre_scale_lower').editValue = val; }"
            />
            <!-- #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end -->
          </v-ons-col>
          <v-ons-col class="unit">
            kg
          </v-ons-col>
        </v-ons-row>

        <v-ons-row>
          <v-ons-col class="memo-area">
            <label>メモ</label>
          </v-ons-col>
          <v-ons-col>
            <!-- mod FNSI-input -> textarea変更 江 start -->
            <!-- <custom-input :value="getPatDataJsonArray(physicalInfoData, 'memo')" /> -->
            <custom-input v-show="false" :value="getPatDataJsonArray(physicalInfoData, 'memo')" />
            <com-textarea
              :content="getPatDataJsonArray(physicalInfoData, 'memo')"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              idTextarea="com-textarea-memo"
              class="comTextarea"
              @set-content-data="setContentDataMemo"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || isOtherFacilityRow()"
            />
            <!-- mod FNSI-input -> textarea変更 江 end -->
          </v-ons-col>
        </v-ons-row>
      </div>
      <message-dialog
        v-if="isDeleteConfirmation"
        v-model:visible="isDeleteConfirmation"
        :message-cd="11010001"
        type="2"
        @confirm="confirmSave"
      />
      <message-dialog
        v-if="isLatestDWFlg"
        v-model:visible="isLatestDWFlg"
        :message-cd="21010001"
        type="1"
      />
      <message-dialog
        v-if="notSave"
        v-model:visible="notSave"
        :message-cd="22010001"
        :string-params="messageParams"
        type="1"
      />
      <message-dialog
        v-if="isPasteLastRstWeight"
        v-model:visible="isPasteLastRstWeight"
        :message-cd="21010003"
        type="1"
      />
      <message-dialog
        v-if="isIndicatorStartDateOld"
        v-model:visible="isIndicatorStartDateOld"
        :message-cd="21010004"
        type="1"
      />
      <!-- 排他エラー -->
      <message-dialog
        v-model:visible="isHaitaErrDialogVisible"
        :message-cd="22020006"
        type="1"
      />
    </div>
    </template>
    <template #footer>
      <div class="button-area">
      <span>
        <v-ons-button class="btn2-cancel" style="width: 100px; margin-right: 0.5em;" @click="hideModal_plus">キャンセル</v-ons-button>
        <!-- mod FNSI-患者情報共有よりの改修 江 start -->
        <!-- <v-ons-button
          v-if="selectedPhysicalInfoData.addEditC === '2'"
          class="common-style-cancel-button"
          @click="deleteEditInfo()"
        >削除</v-ons-button> -->
        <!--mod 編集権限の適用 じょはく start-->
        <!--add FNSI zhuhongrui ボタンがデザインに変更 start-->
        <!--mod FutreNetWeb+SI課題管理No5632 趙 start-->
        <!--<v-ons-button-->
        <!--  v-if="selectedPhysicalInfoData.addEditC === '2'"-->
        <!--  class="btn4-alert"-->
        <!--  style="width: 100px;"-->
        <!--  @click="deleteEditInfo()"-->
        <!--  :disabled="editFlag"-->
        <!-- >削除</v-ons-button>-->
        <v-ons-button
          v-if="selectedPhysicalInfoData.addEditC === '2'"
          class="btn4-alert"
          style="width: 100px;"
          @click="remove()"
          :disabled="editFlag || !recordRemovable || isOtherFacilityRow()"
        >削除</v-ons-button>
        <!--mod FutreNetWeb+SI課題管理No5632 趙 end-->
        <!--mod 編集権限の適用 じょはく end-->
        <!-- mod FNSI-患者情報共有よりの改修 江 end -->
      </span>
      <span>
        <!-- mod FNSI-患者情報共有よりの改修 江 start -->
        <!-- <v-ons-button class="common-style-ok-button" @click="save()">保存</v-ons-button> -->
        <!--mod 編集権限の適用 じょはく start-->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button class="btn1-execute" style="width: 100px;" @click="save()" :disabled="editFlag || !isChanged">保存</v-ons-button> -->
        <v-ons-button class="btn1-execute" style="width: 100px;" @click="save()" :disabled="editFlag || !getItemAuthorized('PatInfo', 'default_authority') || !isChanged || isOtherFacilityRow()">保存</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!--add FNSI zhuhongrui ボタンがデザインに変更 end-->
        <!--mod 編集権限の適用 じょはく end-->
        <!-- mod FNSI-患者情報共有よりの改修 江 end -->
      </span>
          </div>
    </template>
  </modal-base>
</template>

<script>
import { setKendoDropDownListEditedState } from "@/functions/common/KendoFunctions";
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { mapGetters, mapActions, mapMutations, mapState } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS } from "@/constants/PatInfo";
import {
  encodeEditableRecord,
  decodeEditableRecord,
  extractChangesRecord
} from "@/functions/PatInfoFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { deepCopy } from "@/functions/common/CommonFunctions.js";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
// add 編集権限の適用 じょはく start
// del #10359 編集権限の動作不正 dengshen start
// import { FUNC_PAT_INFO } from "@/constants/function-code";
// del #10359 編集権限の動作不正 dengshen end
// add 編集権限の適用 じょはく end
// add 画面デザイン改善対応 李 start

// add 画面デザイン改善対応 李 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
//add FNSI-input -> textarea変更 江 start
import CommonTextArea from "@/components/common/CommonTextArea";
//add FNSI-input -> textarea変更 江 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
import BigNumber from "@/compat/number/bignumber";
// add #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
import { parseDate, dateFormat ,DATE_FORMAT_NORMAL} from "@/functions/common/DateTimeUtils.js";
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
export default {
  components: {
    "message-dialog": messageDialog,
    ModalBase,
    //add FNSI-input -> textarea変更 江 start
    "com-textarea": CommonTextArea,
    //add FNSI-input -> textarea変更 江 end
    // add #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
  },

  mixins: [baseCardContent, MultiModalMixin, IndUserSelectMixin],

  props: {
    // 設定しない
    patRecord: {
      type: Object,
      default: null,
      required: false
    },
    // add 編集権限の適用 じょはく start
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
    // add 編集権限の適用 じょはく end
  },

  data() {
    return {
      // add 7778 limingyang start
      cardDiff:true,
      // add 7778 limingyang end
      // add 編集権限の適用 じょはく start
      isPatViewAuthorized: null,
      isPatEditAuthorized: null,
      editFlag: null,
      // add 編集権限の適用 じょはく end
      addItem: encodeEditableRecord({
        ctl_no: 0,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
        inspect_date:null,
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end
        exam_date: dayjs().format("YYYYMMDD"),
        exam_day: null,
        exam_time: null,
        order_class: null,
        height: null,
        ctr_weight: null,
        breast_dia: null,
        chest_dia: null,
        ctr: null,
        dw: null,
        pre_scale_upper: null,
        pre_scale_lower: null,
        target_weight: null,
        indicator_cd: null,
        indicator_start_date: dayjs().format("YYYYMMDD"),
        memo: null,
        facility_cd: null,
        changer_cd: null
      }),
      isDeleteConfirmation: false,
      isLatestDWFlg: false,
      orderClass: PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS,
      isValidate: false,
      notSave: false,
      isIndicatorStartDateOld: false,
      messageParams: [],
      isPasteLastRstWeight: false,
      previousWeightSourceClass: null,
      isUpdateOrd: false,
      isChangeTargetWeight: { initValue: "0", editValue: "0" },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
      initIsChangeTargetWeight: { initValue: "0", editValue: "0" },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      // add FNSI-排他処理 劉 start
      isHaitaErrDialogVisible: false,
      // add FNSI-排他処理 劉 end
      // add #2856：DWの指示履歴登録対応 韓 start
      isDwNotChangeDialogVisible: false,
      initDw: null,
      // add #2856：DWの指示履歴登録対応 韓 end
      jsonKeyArray: [
        "ctl_no",
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
        "inspect_date",
        // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end
        "exam_date",
        "order_class",
        "height",
        "ctr_weight",
        "breast_dia",
        "chest_dia",
        "ctr",
        "dw",
        "pre_scale_upper",
        "pre_scale_lower",
        "indicator_cd",
        "indicator_start_date",
        "target_weight",
        "memo",
        "facility_cd",
        "changer_cd"
      ],
      // 指示者リスト
      indUserList: [],
      otherFacilitySingleList: [],
      //add dw Mongodb log を加入します顔 start
      dw_log_info: {
        is_delete : false,
        is_change : false,
        examTime_pre : null,
        examTime_aft : null,
        dw_pre : "未登録",
        dw_aft : "未登録",
        operation_order : null,
        creater : null,
        is_add : 0
      },
      //add dw Mongodb log を加入します顔 start
      iniSelectedId : null, // add #6512 患者情報画面-身体情報の分の修正 劉
      // add #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs start
      dwAddedFlg: false,
      // add #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs end
      // add 画面デザイン改善対応 李 start
      callsNumberFlg: false,
      firValue: null,
      // add 画面デザイン改善対応 李 end
      // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
      isRequiredDw: false,
      // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
      dwPreviousInfo: {
        dw: null,
        examDate: null
      }
    };
  },

  computed: {
    ...mapState("pat-info", [ "physicalInfoUpDate"]),
    ...mapState("multi-modal", ["modalName"]),
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // del 9929 使われず削除されました ljg start
    // add FINS zhuhongrui start
    // ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    // add FINS zhuhongrui end
    // del 9929 使われず削除されました ljg end
    ...mapGetters("pat-info", [
      "getIsUpdate",
      "getIsAdd",
      "getOperation",
      "selectedPatId",
      "selectedPat",
      "selectedPhysicalInfoData"
      // add FNSI-患者情報共有よりの改修 江 start
      ,"isOwnFacility"
      ,"getIsOtherFacility"
      ,"getOtherFacilityCd"
      // add FNSI-患者情報共有よりの改修 江 end
    ]),

    /**
     * @description 編集する身体情報データ
     * @returns { Object }
     */
    physicalInfoData() {
      if (this.selectedPhysicalInfoData.physicalInfo === null) {
        return this.addItem;
      }
      return this.selectedPhysicalInfoData.physicalInfo;
    },

    /**
     * @description dw編集フラグ
     * @returns { Boolean } true: 編集不可, false: 編集可
     */
    isEditDw() {
      // 「新規登録： "1"」
      return !(this.selectedPhysicalInfoData.addEditC === "1");
    },

    /**
     * @description 目標体重編集フラグ
     * @returns { Boolean } true: 編集済み, false: 編集未
     */
    isEditedTargetWeight() {
      if (!Object.prototype.hasOwnProperty.call(this.physicalInfoData, "target_weight")) {
        return false;
      }

      const targetWeight = this.getPatDataJsonArray(
        this.physicalInfoData,
        "target_weight").editValue;
      if (targetWeight === null || targetWeight === "") {
        return false;
      }
      return true;
    },

    // add #6512 患者情報画面-身体情報の分の修正 劉 start
    /**
     *@description レコード編集フラグ
     * @return { Boolean } true: 編集済み, false: 編集未
     */
    isChanged() {
      const changedPhysicalInfo = extractChangesRecord(this.physicalInfoData);
      const isChange = Object.values(changedPhysicalInfo).find((data, index) => {
        if (data !== undefined) {
          // 指示者は登録している医師の場合、編集未とする
          // メモは未編集（initValue=null:editValue=""）される場合を最適化する
          // inspect_dateを対象外とする
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
          if ((index === 14 && data.editValue == this.iniSelectedId)
              || (index === 15 && (data.editValue == data.initValue || data.initValue == -1 && data.editValue === ''))
              || (index === 16 && data.initValue === null && data.editValue === "")
              || (index === 17 && data.initValue === null && data.editValue === "")
              || (index === 1)) {
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
            return false
          }
          return true
        }
        return false
      })
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
      if(JSON.stringify(this.initIsChangeTargetWeight) !== JSON.stringify(this.isChangeTargetWeight)){
        return true
      }
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
      if (isChange === undefined) {
        return false
      }
      return true
    },
    // add #6512 患者情報画面-身体情報の分の修正 劉 end

    /**
     * カスタムカレンダーの入力制限のための本日の日付文字列
     */
    todayStr() {
      return dayjs().format("YYYYMMDD");
    },

    // #10443 DW編集権限-検査日時 編集 Start
    /**
     * 編集権限-検査日時
     * @returns {boolean} true: 編集不可, false: 編集可
     */
    examDateEditable() {
      if (this.isEditDw) {
        return false;
      }
      return !this.getItemAuthorized('PatInfo', 'default_authority');
    },

    /** Does record can be removed? */
    recordRemovable() {
      // 編集パターン
      if (this.selectedPhysicalInfoData.addEditC === "2") {
        if (Object.prototype.hasOwnProperty.call(this.physicalInfoData, "dw")) {

          // DWを含むレコード → 患者情報権限あり、指示権限/指示代行権限あり
          if (this.physicalInfoData.dw.initValue) {
            return this.getItemAuthorized('PatInfo', 'item_physical_info_card');
          }
          // DWを含む無し → 患者情報権限あり
          else {
            return this.getItemAuthorized('PatInfo', 'default_authority');
          }
        }
      }

      return false;
    },

    // #10443 DW編集権限 End
    /**
     * 表示する直近DW情報
     * @returns { String }
     */
    dwPreviousInfoDispData() {
      if (this.dwPreviousInfo.dw === null) {
        return "";
      }
      return `(${this.dwPreviousInfo.examDate}：${this.dwPreviousInfo.dw}kg)`;
    },
  },

  // add 画面デザイン改善対応 李 start
  watch: {
    "physicalInfoData.indicator_cd.editValue"(val) {
      // 初回ロード時、初期状態が記録され、初期値が保存される
      //mod 6982 ini_dial連携で受信したDW登録 張 start
      // if (!this.callsNumberFlg){
      if (!this.callsNumberFlg&&val!="") {
      //mod 6982 ini_dial連携で受信したDW登録 張 end
        this.callsNumberFlg = true;
        this.firValue = val;
      }

      // 選択した値と初期値が異なる場合
      if (val != this.firValue) {
        setKendoDropDownListEditedState(this.$el || this, { enabled: true });
      } else {
        setKendoDropDownListEditedState(this.$el || this, { enabled: false });
      }
    },
    // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
    "isChangeTargetWeight.editValue"(val) {
      this.isRequiredDw = val == 1 ? true : false
    },
    // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end

    /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */
    "physicalInfoData.exam_day.editValue"() {
      this.$nextTick(() => {
        this.onOrderItemChange();
        this.setDwPreviousInfo();
      })
    }
    /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする End */
  },
  // add 画面デザイン改善対応 李 end

  async created() {
    // add 編集権限の適用 じょはく start
    // mod #10359 編集権限の動作不正 dengshen start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    // this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    // // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    // this.editFlag = !(this.isOwnFacility && this.isPatViewAuthorized && this.isPatEditAuthorized);
    this.editFlag = !this.isOwnFacility;
    // mod #10359 編集権限の動作不正 dengshen end
    if (this.isOtherFacilityRow()) {
      const id = this.physicalInfoData?.indicator_cd?.editValue;
      const name = this.physicalInfoData?.indicator_name?.editValue;

      if (id == null || name == null) {
        this.otherFacilitySingleList = [];
      } else {
        this.otherFacilitySingleList = [{
          user_id: id,
          fullName: name
        }];
      }
    }
    // add bug 7980 修正 chen start
    const res = await ApiHelper.get("/mstInfo/mstPersonalUser", {
      facility_cd: this.facilityCd,
      selectedPatId: this.selectedPatId
    });
    res.data.forEach(user => {
      user.userFullName = `${user.userLastName} ${user.userFirstName}`;
    });
    // add bug 7980 修正 chen end
    // add 編集権限の適用 じょはく end
    // 指示者ドロップダウンの設定
    // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
    // this.getIndUserList(
    this.getIndUserListIncludeDel(
      AUTHORITY_CODES.IND_EDIT,
      AUTHORITY_CODES.IND_PEDIT).then(response => {
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
      this.indUserList = response.doctorList.filter(item => {
        return item.is_disp == '1' || item.user_id == this.physicalInfoData.indicator_cd.editValue
      });
      // mod #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end
      // 臨床工学技士无法获取执行者问题处理，modify by maxueqiang
      let existFlg = false;
      // 医師リストとデフォルト指示者のundefinedを-1に置換する
      // 理由：
      //  - undefinedだと追加でデフォルト指示者なしの場合、空欄ではなくリスト一番上の医師が選択されてしまう
      //  - 後続処理で指示者未選択は-1を設定するため、undefinedのままだと同じ空欄でも内部の値がundefinedと-1で異なるため、編集状態あり(緑枠)表示となる
      let iniSelectId = response.iniSelectId === undefined ? -1 : response.iniSelectId;
      if (this.indUserList.length > 0 && this.indUserList[0].user_id === undefined) {
        this.indUserList[0].user_id = -1;
      }
      this.indUserList.forEach(item =>{
        if(null != item.user_id && item.user_id == iniSelectId){
          existFlg = true;
        }
      })
      if (!existFlg){
        let filterUserList = this.indUserList.filter(item =>{
          return null != item.user_id;
        })
        if (Array.isArray(filterUserList) && filterUserList.length > 0){
          iniSelectId = filterUserList[0].user_id;
        }
      }
      // 臨床工学技士无法获取执行者问题处理，modify by maxueqiang
      this.$nextTick(() => {
        // mod bug 7904 修正 chen start
        // mod bug 7980 修正 chen start
        if (!this.physicalInfoData.indicator_cd.editValue) {
          if (this.selectedPhysicalInfoData.addEditC === "1") {
            this.physicalInfoData.indicator_cd.editValue = Number(iniSelectId + "");
            this.physicalInfoData.indicator_cd.initValue = Number(iniSelectId + "");
            this.iniSelectedId = Number(iniSelectId + "");
          } else {
            this.iniSelectedId = -1;
          }
        } else {
          this.physicalInfoData.indicator_cd.editValue = Number(this.physicalInfoData.indicator_cd.editValue + "");
          this.physicalInfoData.indicator_cd.initValue = Number(this.physicalInfoData.indicator_cd.editValue + "");
          this.iniSelectedId = Number(this.physicalInfoData.indicator_cd.editValue + "");
        }
        // mod bug 7980 修正 chen end
        // this.iniSelectedId = iniSelectId; // add #6512 患者情報画面-身体情報の分の修正 劉
        // mod bug 7904 修正 chen end
        // add bug 7980 修正 chen start
        existFlg = false;
        this.indUserList.forEach(item =>{
          if((item.user_id && item.user_id + "" === this.iniSelectedId + "") || this.iniSelectedId === -1){
            existFlg = true;
          }
        })
        if (!existFlg) {
          res.data.forEach(user => {
            if (user.userId + "" === this.iniSelectedId + "") {
              let uesr = {
                fullName:user.userFullName,
                is_del:user.isDel,
                user_first_name:user.userFirstName,
                user_id:user.userId,
                user_last_name:user.userLastName
              };
              this.indUserList.push(uesr);
      //mod 6982 ini_dial連携で受信したDW登録 張 end
            }
          });
        }
              this.$nextTick(() => {
                this.physicalInfoData.indicator_cd.editValue = "";
                this.physicalInfoData.indicator_cd.initValue = "";
                this.$nextTick(() => {
                this.physicalInfoData.indicator_cd.editValue = Number(this.iniSelectedId+ "");
                this.physicalInfoData.indicator_cd.initValue = Number(this.iniSelectedId+ "");
                });
              });
        //mod 6982 ini_dial連携で受信したDW登録 張 end
        // add bug 7980 修正 chen end
      });
    });
    // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
    let ExamDay = this.getPatDataJsonArray(this.physicalInfoData, 'exam_day').initValue;
    if (ExamDay === null){
      this.setPatDataJsonArray(this.physicalInfoData,'exam_day',this.todayStr);
    }

    let StartDate = this.getPatDataJsonArray(this.physicalInfoData, 'indicator_start_date').initValue;
    if (StartDate === null){
      this.setPatDataJsonArray(this.physicalInfoData,'indicator_start_date',this.todayStr);
    }

    let OrderClass = this.getPatDataJsonArray(this.physicalInfoData, 'order_class').initValue
    if (OrderClass === null){
      this.setPatDataJsonArray(this.physicalInfoData,'order_class',this.orderClass[0].value);
    }

    let inspectDate = this.getPatDataJsonArray(this.physicalInfoData, 'inspect_date').initValue
    if (inspectDate === null){
      this.setPatDataJsonArray(this.physicalInfoData,'inspect_date',this.todayStr);
    }
    // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
    // add #2856：DWの指示履歴登録対応 韓 start
    // 前回のDW値を取得
    this.initDw = this.maxDateDW();
    // add #2856：DWの指示履歴登録対応 韓 end
    // 患者経過総合ビューア呼び出し時、各値を設定
    // mod #2856：DWの指示履歴登録対応 韓 start
    if (this.selectedPhysicalInfoData.jsonArray === null || this.selectedPhysicalInfoData.jsonArray.length === 0) {
      // mod #2856：DWの指示履歴登録対応 韓 end
      this.setUpdateDW();
      // DEL By #10704 Useless method Start
      /* mod EOL対応内部#6926 by ztc 2023-07-07 --start */
      // if(!!this.selectedPhysicalInfoData.physicalInfo){
      //   this.setTargetWeight();
      // }
      /* mod EOL対応内部#6926 by ztc 2023-07-07 --start */
      // DEL By #10704 Useless method End
      // this.setIndicatorStartDate();
    }
    let val_dw_pre = JSON.parse(JSON.stringify(this.physicalInfoData)).dw.initValue;
    this.dw_log_info.dw_pre = val_dw_pre ? val_dw_pre : "未登録";
    let val_time = JSON.parse(JSON.stringify(this.physicalInfoData)).exam_date.initValue;
    this.dw_log_info.examTime_pre = val_time;
    this.dw_log_info.operation_order = this.getOperation;
    // 患者情報:身体情報「+」btn押下,保存ボタンは不活性を表示すべきです
    this.physicalInfoData.exam_day.initValue = this.physicalInfoData.exam_day.editValue;
    this.physicalInfoData.order_class.initValue = this.physicalInfoData.order_class.editValue;
    this.physicalInfoData.indicator_start_date.initValue = this.physicalInfoData.indicator_start_date.editValue;
    this.physicalInfoData.inspect_date.initValue = this.physicalInfoData.inspect_date.editValue;
    this.physicalInfoData.breast_dia.editValue = this.physicalInfoData.breast_dia.initValue;
    this.physicalInfoData.chest_dia.editValue = this.physicalInfoData.chest_dia.initValue;
    this.physicalInfoData.ctr.editValue = this.physicalInfoData.ctr.initValue;
    this.physicalInfoData.ctr_weight.editValue = this.physicalInfoData.ctr_weight.initValue;
    this.physicalInfoData.dw.editValue = this.physicalInfoData.dw.initValue;
    this.physicalInfoData.exam_time.editValue = this.physicalInfoData.exam_time.initValue;
    this.physicalInfoData.facility_cd.editValue = this.physicalInfoData.facility_cd.initValue;
    this.physicalInfoData.height.editValue = this.physicalInfoData.height.initValue;
    this.physicalInfoData.indicator_start_date.editValue = this.physicalInfoData.indicator_start_date.initValue;
    this.physicalInfoData.memo.editValue = this.physicalInfoData.memo.initValue;
    this.physicalInfoData.order_class.editValue = this.physicalInfoData.order_class.initValue;
    this.physicalInfoData.pre_scale_lower.editValue = this.physicalInfoData.pre_scale_lower.initValue;
    this.physicalInfoData.pre_scale_upper.editValue = this.physicalInfoData.pre_scale_upper.initValue;
    this.physicalInfoData.target_weight.editValue = this.physicalInfoData.target_weight.initValue;
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    this.initIsChangeTargetWeight = JSON.parse(JSON.stringify(this.isChangeTargetWeight))
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
    await this.setDwPreviousInfo();
  },

  methods: {
    getPhysicalInfoElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || this);
    },
    // add getUserId  zhuhongrui start
    ...mapGetters("account-edit", ["getUserId"]),
    // add getUserId  zhuhongrui end
    ...mapActions("send-condition/scale", ["getWeightByTreatDateAndOrdClass"]),
    ...mapMutations("pat-info", [
      "setIsUpdate",
      "setIsAdd",
      "setOperation",
      "setSelectedPat",
      "setSelectedPhysicalInfoData",
      "setPhysicalInfoUpDate"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage"
    }),
    transformData(data) {
      return data.map(item => {
          let transformedItem = {};
          for (let key in item) {
              transformedItem[key] = item[key].editValue;
          }
          return transformedItem;
      });
    },
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // add じょはく start
    moveCss(e) {
      let s = e.target;
      s.classList.remove("custom-input-date-invalid");
    },
    // add じょはく end
    /**
     * @description dw編集フラグ設定
     */
    dwValue(value) {
      if (value === null || value === "") {
        this.isValidate = false;
      } else {
        this.isValidate = true;
      }
    },

    // mod bug 7778 修正 chen start
    hideModal_plus() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.dw_log_info.is_change = false;
            this.dw_log_info.is_add = 0;
            this.dw_log_info.is_delete = false;
      //add 6982 ini_dial連携で受信したDW登録 張 start
            this.physicalInfoData.indicator_cd.editValue=this.physicalInfoData.indicator_cd.initValue
      //add 6982 ini_dial連携で受信したDW登録 張 end
          // add nikkiso-fnsi不具合 No5 関 start
            this.physicalInfoData.breast_dia.editValue = this.physicalInfoData.breast_dia.initValue;
            this.physicalInfoData.chest_dia.editValue = this.physicalInfoData.chest_dia.initValue;
            this.physicalInfoData.ctr.editValue = this.physicalInfoData.ctr.initValue;
            this.physicalInfoData.ctr_weight.editValue = this.physicalInfoData.ctr_weight.initValue;
            this.physicalInfoData.dw.editValue = this.physicalInfoData.dw.initValue;
            this.physicalInfoData.exam_time.editValue = this.physicalInfoData.exam_time.initValue;
            this.physicalInfoData.facility_cd.editValue = this.physicalInfoData.facility_cd.initValue;
            this.physicalInfoData.height.editValue = this.physicalInfoData.height.initValue;
            this.physicalInfoData.indicator_start_date.editValue = this.physicalInfoData.indicator_start_date.initValue;
            this.physicalInfoData.inspect_date.editValue = this.physicalInfoData.inspect_date.initValue;
            this.physicalInfoData.memo.editValue = this.physicalInfoData.memo.initValue;
            this.physicalInfoData.order_class.editValue = this.physicalInfoData.order_class.initValue;
            this.physicalInfoData.pre_scale_lower.editValue = this.physicalInfoData.pre_scale_lower.initValue;
            this.physicalInfoData.pre_scale_upper.editValue = this.physicalInfoData.pre_scale_upper.initValue;
            this.physicalInfoData.target_weight.editValue = this.physicalInfoData.target_weight.initValue;
          // add nikkiso-fnsi不具合 No5 関  end
            this.hideModal();
          }
        }
      });
      } else {
        this.hideModal()
      }
    },
    // mod bug 7778 修正 chen end

    confirmSave(answer) {
      // メッセージ閉じる
      this.isDeleteConfirmation = false;
      if (answer === "OK") {
        this.deletePhysical();
      }
    },
    //add FNSI-input -> textarea変更 江 start
    setContentDataMemo(e){
      this.setPatDataJsonArray(this.physicalInfoData, "memo", e);
    },
    //add FNSI-input -> textarea変更 江 end
    /**
     * @description バリデーションチェック
     */
    validate() {
      let validate = false;
      // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
      // const inspect_date = this.physicalInfoData.inspect_date.editValue;
      // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end
      // 内部 患者情報:身体情報が入っていない場合保存ページをクリックするとエラーが発生します。start
      // const changedPhysicalInfo = extractChangesRecord(this.physicalInfoData)
      const exam_day = (null != this.physicalInfoData.exam_day) ? this.physicalInfoData.exam_day.editValue : null;
      const indicator_start_date = this.physicalInfoData.indicator_start_date.editValue
      const indicator_cd = (this.physicalInfoData && this.physicalInfoData.indicator_cd && this.physicalInfoData.indicator_cd.editValue)
        ? this.physicalInfoData.indicator_cd.editValue : null
      // 内部 患者情報:身体情報が入っていない場合保存ページをクリックするとエラーが発生します。end

      let dwValue = this.physicalInfoData.dw.editValue;
      let messageArray = [];

      let examDate;
      try {
        examDate = this.formatDate(exam_day);
      } catch (e) {
        validate = true;
        messageArray.push("検査日時");
      }

      // mod FNSI-障害票一覧_身体情報.xlsxのNo.1対応 韓 start
      //if (exam_day === null) {
      if (!examDate) {
        // mod FNSI-障害票一覧_身体情報.xlsxのNo.1対応 韓 end
        // 測定日時必須
        validate = true;
        messageArray.push("検査日時");
      }
      // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang start
      //  if (inspect_date === null || !dayjs(inspect_date, "YYYYMMDD", true).isValid()){
      //    validate = true;
      //    messageArray.push("検査日");
      //  }
      // add FNSI-改修内容身体情報でのDW追加・変更時の対応  指示履歴追加   指示受け指示承認更新   連携イベント登録 liang end

      // 以下のいずれかのデータが存在しない場合は保存操作不可。
      // 身長、心横径、胸郭横径、CTR、DW、前体重許容上限、下限、メモ
      let height = (null != this.physicalInfoData.height) ? this.physicalInfoData.height.editValue : null;
      let breast_dia = (null != this.physicalInfoData.breast_dia) ? this.physicalInfoData.breast_dia.editValue : null;
      let chest_dia = (null != this.physicalInfoData.chest_dia) ? this.physicalInfoData.chest_dia.editValue : null;
      let ctr = (null != this.physicalInfoData.ctr) ? this.physicalInfoData.ctr.editValue : null;
      let pre_scale_upper = (null != this.physicalInfoData.pre_scale_upper) ? this.physicalInfoData.pre_scale_upper.editValue : null;
      let pre_scale_lower = (null != this.physicalInfoData.pre_scale_lower) ? this.physicalInfoData.pre_scale_lower.editValue : null;
      let memo = (null != this.physicalInfoData.memo) ? this.physicalInfoData.memo.editValue : null;

      if (!height && !breast_dia && !chest_dia && !ctr && !pre_scale_upper && !pre_scale_lower && !memo && !dwValue) {
        validate = true;
        if (!height) messageArray.push("身長");
        if (!breast_dia) messageArray.push("心横径");
        if (!chest_dia) messageArray.push("胸郭横径");
        if (!ctr) messageArray.push("CTR");
        if (!pre_scale_upper) messageArray.push("前体重許容上限");
        if (!pre_scale_lower) messageArray.push("前体重許容下限");
        if (!memo) messageArray.push("メモ");
        if (!dwValue) messageArray.push("DW");
        // this.messageParams = [messageArray.join("、")];
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['23030006'].title,
          message: messageFormat(DIALOG_MESSAGES[23030006].message, messageArray.join('、')),
        });
        return validate;
      }

      // dw入力時の必須
      if (dwValue) {
        // 指示者が必須入力
        if (!indicator_cd || String(indicator_cd) === "-1") {
          messageArray.push("指示者");
          validate = true;
          this.messageParams = [messageArray.join("、")];
          return validate;
        }
      }

      // 身体情報目標体重変更時、目標体重と指示開始日必要入力検査
      if (this.isChangeTargetWeight.editValue === "1") {
        // dwが必須入力
        if (!dwValue) {
          messageArray.push("DW");
          validate = true;
        }

        // 指示者が必須入力
        if (!indicator_cd || String(indicator_cd) === "-1") {
          messageArray.push("指示者");
          validate = true;
        }

        let indicatorStartDate;
        try {
          indicatorStartDate = this.formatDate(indicator_start_date);
        } catch (e) {
          messageArray.push("目標体重指示開始日");
          validate = true;
        }
        // 指示開始日が必須入力
        if (!indicatorStartDate) {
          // mod FNSI-障害票一覧_身体情報.xlsxのNo.1対応 韓 end
          messageArray.push("目標体重指示開始日");
          validate = true;
        }
      }

      this.messageParams = [messageArray.join("、")];
      return validate;
    },
    /**
     * @description 指示開始日有効チェック
     */
    validateIndicatorDate() {
      let validate = false;

      let indicatorStartDate;
      try {
        indicatorStartDate = this.formatDate(this.physicalInfoData.indicator_start_date.editValue);
      } catch (e) {
        validate = true;
      }

      if (this.isChangeTargetWeight.editValue === "1") {
        validate = dayjs(indicatorStartDate, "YYYY-MM-DD").format("YYYYMMDD") < this.todayStr;
      }
      return validate;
    },

    cancel() {
      this.isValidate = false;
      this.clearAddItem();
      // モーダル閉じる
      this.hideModal();
    },

    // add FutreNetWeb+SI課題管理No5632 趙 start
    remove() {
      this.$ons.notification
        .confirm({
          title: "削除確認",
          message: "削除すると二度と元に戻せません。削除してもよろしいですか？"
        })
        .then((ok) => {
          if (ok) {
            this.deleteEditInfo()
          }
        });
    },
    // add FutreNetWeb+SI課題管理No5632 趙 end

    /**
     * @description 削除
     */
    deleteEditInfo() {
      //add dw Mongodb log を加入します顔 start
      this.dw_log_info.dw_aft = "未登録";
      this.dw_log_info.is_delete = true;
      this.dw_log_info.is_change = false;
      this.dw_log_info.creater = this.physicalInfoData.indicator_cd.editValue;
      //add dw Mongodb log を加入します顔 end

      // #10443 DEL 有効なデータを含むため削除できない処理は不要、0件になる削除でも削除可能とする。 START
      // if (this.selectedPhysicalInfoData.isLatestDW) {
      //   // 最新の測定日時は削除させない
      //   this.isLatestDWFlg = true;
      // } else
      // #10443 DEL END

      if (this.physicalInfoData.dw.initValue !== null) {
        // DWが設定されている場合
        // メッセージで削除有無確認
        this.isDeleteConfirmation = true;
      } else {
        this.deletePhysical();
      }
      //del #9929  dw削除の場合は連携修正をトリガーします ljg start
      /* add データバックアップ  馬宇婷 start */
      // const params = {
      //   ope_cd:"007006",
      //   crud: "U",
      //   facility_cd: this.facilityCd,
      //   /* add FNSI zhuhongrui start */
      //   pat_id:this.selectedPat.pat_personal_main.pat_id,
      //   /* add FNSI zhuhongrui end */
      //   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //   ord_no: "",
      //   base_date:dayjs().format("YYYYMMDD"),
      //   user_id: this.getUserId()
      // };
      // createJournal(params);

      /* add データバックアップ  馬宇婷 end */
      //del #9929  dw削除の場合は連携修正をトリガーします ljg end
    },

    /**
     * @description 身体情報削除
     */
    async deletePhysical() {
      // add/ #12489 身体情報削除時にローダ画面が表示されない tianqidong start
      await this.setLoadingScreenMessage("処理中・・・");
      await this.setLoadingScreenVisible(true);
      await this.deletedPhysicalInfo();
      // モーダル閉じる
      this.hideModal();
      await this.setLoadingScreenVisible(false)
      // add/ #12489 身体情報削除時にローダ画面が表示されない tianqidong end
      //add  #9929  dw削除の場合は連携修正をトリガーします ljg start
      // const startDate = dayjs(this.physicalInfoData.exam_day.editValue).format("YYYYMMDD");
      // const responsetest = await ApiHelper.get(`/mainData/getAllStateIsNotZero/${this.selectedPatId}/${startDate}`);
      // let journalList = [];
      // if(responsetest.data){
      //   responsetest.data.forEach(item => {
      //   journalList.push({
      //   facility_cd:this.facilityCd,
      //   crud: "U",
      //   pat_id: this.selectedPatId,
      //   hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
      //   ord_no: item,
      //   base_date:dayjs().format("YYYYMMDD"),
      //   ope_cd:"007006",
      //   user_id: this.getUserId()
      //     })
      //   });
      //   createJournalList(journalList);
      //   }
       //add #9929  dw削除の場合は連携修正をトリガーします ljg end
    },

    onOrderItemChange() {
      const exam_day = this.physicalInfoData.exam_day.editValue;
      const exam_time = this.physicalInfoData.exam_time.editValue;

      // const target_weight = this.physicalInfoData.target_weight.editValue;
      //測定タイミング
      let order_class = this.physicalInfoData.order_class.editValue;

      let changeFlg = (this.physicalInfoData.exam_day.initValue !== this.physicalInfoData.exam_day.editValue)
        || (this.physicalInfoData.exam_time.initValue !== this.physicalInfoData.exam_time.editValue)
        || (this.physicalInfoData.order_class.initValue !== this.physicalInfoData.order_class.editValue)

      //編集済みの場合、処理対象外
      if (this.selectedPhysicalInfoData.addEditC === "2" && !changeFlg) {
        this.physicalInfoData.ctr_weight.editValue = this.physicalInfoData.ctr_weight.initValue;
        return;
      }

      // #10443 Mod Start
      //測定タイミングが"その他"の場合は処理対象外
      if (order_class === PAT_UNIQUE_COL_PHYSICAL_INFO_ORDER_CLASS[2].value) {
        this.physicalInfoData.ctr_weight.editValue = null;
        return;
      }

      let dayParam = null;
      try {
        dayParam = this.formatDate(exam_day).replaceAll("-", "");
      } catch (e) {
        dayParam = null;
      }

      let that = this;
      if (order_class && dayParam) {
        that.getWeightByTreatDateAndOrdClass({
        facilityCd: that.facilityCd,
        patId: that.selectedPatId,
        ordClass: order_class,
        treatDate: dayParam,
        treatTime: exam_time
      })
        .then(r => {
          if (r.status === 200) {
            let ctrWeight = r.data;
            that.physicalInfoData.ctr_weight.editValue = ctrWeight ? BigNumber(ctrWeight).toFixed(2) : null;
          }
        })
        .catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PhysicalInfoAddEditForPatInfo.vue',
            'onOrderItemChange',
            "getWeightByTreatDateAndOrdClass");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
      }
    },

    /**
     * @description 心横径と胸郭横径からCTRを自動計算
     * @param {Number} breastDia 心横径
     * @param {Number} chestDia 胸郭横径
     * @returns {Number}
     */
    setCtr(breastDia, chestDia) {
      // ゼロ除算は計算を行わない
      // mod 「胸郭横径」は「0」の場合、「CTR」表示不正について、対応する。 dengshen start
      // if (chestDia.editValue !== 0) {
      if (chestDia.editValue != 0) {
      // mod 「胸郭横径」は「0」の場合、「CTR」表示不正について、対応する。 dengshen end
        if (breastDia.editValue !== null && chestDia.editValue !== null) {
          const ctrValue = (breastDia.editValue / chestDia.editValue) * 100;
          // 100%を超える場合は100%を設定
          if (ctrValue >= 100) {
            // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
            // this.setPatDataJsonArray(this.physicalInfoData, "ctr", 100);
            this.setPatDataJsonArray(this.physicalInfoData, "ctr", "100.00");
            // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
            // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
          } else if (ctrValue <= 0) {
            this.setPatDataJsonArray(this.physicalInfoData, "ctr", "0.00");
            // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
          } else {
            // 四捨五入
            this.setPatDataJsonArray(
              this.physicalInfoData,
              "ctr",
              // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
              // Math.round(ctrValue * 100) / 100
              (Math.round(ctrValue * 100) / 100).toFixed(2)
              // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
              );
          }
        }
      } else {
        this.setPatDataJsonArray(this.physicalInfoData, "ctr", null);
      }
    },

    /**
     * @description 新規登録データクリア
     */
    clearAddItem() {
      this.addItem = encodeEditableRecord({
        ctl_no: 0,
        exam_date: null,
        exam_day: null,
        exam_time: null,
        order_class: null,
        height: null,
        ctr_weight: null,
        breast_dia: null,
        chest_dia: null,
        ctr: null,
        dw: null,
        pre_scale_upper: null,
        pre_scale_lower: null,
        target_weight: null,
        indicator_cd: null,
        indicator_start_date: null,
        memo: null,
        facility_cd: null
      });
    },

    /**
     * @description 身体情報登録・更新
     */
    async save() {

      //add dw Mongodb log を加入します顔 start
      let time_covern_init = this.$refs.examDate_id.value.editValue;
      // 内部 患者情報:身体情報が入っていない場合保存ページをクリックするとエラーが発生します。 start
      let time_covern_change = time_covern_init ? (time_covern_init.substring(0,4)+"-"+time_covern_init.substring(4,6)+"-"+time_covern_init.substring(6,8)) : null;
      // 内部 患者情報:身体情報が入っていない場合保存ページをクリックするとエラーが発生します。 end
      this.dw_log_info.examTime_aft = time_covern_change;
      time_covern_init = this.$refs.examTime_id.value.editValue;
      let val = JSON.parse(JSON.stringify(this.physicalInfoData)).exam_date.editValue;
      if(!(_.isEmpty(time_covern_init))) {
        time_covern_change = time_covern_init.substring(0, 2) + ":" + time_covern_init.substring(2, 4);
        val = this.dw_log_info.examTime_aft + "T" + time_covern_change +":00.000"+ dayjs().format().substring(19,40);
        this.dw_log_info.examTime_aft = val;
      }
      // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng start
      // this.dw_log_info.dw_aft = this.$refs.ref_dw.value.editValue == null ? "未登録" : this.$refs.ref_dw.value.editValue;
      this.dw_log_info.dw_aft = this.$refs.ref_dw.value == null ? "未登録" : this.$refs.ref_dw.value;
      // #10435 患者情報>身体情報にて入力欄にフォーカスを当てた時点で自動で0が入力される linjunfeng end
      // add bug 7904 修正 chen start
      this.physicalInfoData.indicator_cd.editValue = this.physicalInfoData.indicator_cd.editValue + "";
      // add bug 7904 修正 chen end
      this.dw_log_info.creater = this.physicalInfoData.indicator_cd.editValue;
      this.dw_log_info.is_add = this.getIsAdd;
      this.dw_log_info.is_change = this.getIsUpdate;
      //add dw Mongodb log を加入します顔 end
      if (this.validate()) {
        // add じょはく start
        let arr = this.getPhysicalInfoElementsByClassName("custom-input-date-required");
        if ( arr[0].value == "") {
          arr[0]?.classList?.add("custom-input-date-invalid");
        }
        if (arr.length >= 2 && arr[1].value == "") {
          arr[1]?.classList?.add("custom-input-date-invalid");
        }
        // add じょはく end
        if (this.messageParams.length) this.notSave = true;
        return;
      }
      if (this.validateIndicatorDate()) {
        this.isIndicatorStartDateOld = true;
        return;
      }

      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);

      this.isValidate = false;

      const patInfo = deepCopy(this.selectedPat);
      let savePhysicalInfo;
      if (this.selectedPhysicalInfoData.jsonArray.length === 0 && this.selectedPhysicalInfoData.addEditC === '1') {
        savePhysicalInfo = JSON.parse(patInfo.pat_unique.physical_info);
      } else {
        savePhysicalInfo = this.transformData(this.selectedPhysicalInfoData.jsonArray);
      }
      // 目標体重キーがない場合は追加する
      for (let info of savePhysicalInfo) {
        if (info.target_weight === undefined) {
          info.target_weight = null;
        }
      }

      const editPhysicalInfo = decodeEditableRecord(this.physicalInfoData);

      // 必要なキーのみに変換
      const physicalInfo = this.changeGenerateDate(editPhysicalInfo);

      // 変更点のみ抽出
      const changedPhysicalInfo = extractChangesRecord(this.physicalInfoData);

      // 登録施設キーを追加する。
      if (
        physicalInfo.facility_cd === null ||
        physicalInfo.facility_cd === undefined
      ) {
        physicalInfo.facility_cd = this.facilityCd;
      }

      // DWを含むレコードを追加したか
      let hasBeenAdded = false;
      if (changedPhysicalInfo.dw && changedPhysicalInfo.dw.editValue) {
        hasBeenAdded = true;
      }
      // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 start
      // 検査日時を含むレコードを追加したか
      if(changedPhysicalInfo.exam_day && changedPhysicalInfo.exam_day.initValue != changedPhysicalInfo.exam_day.editValue) {
        hasBeenAdded = true;
      }
      // 目標体重を含むレコードを追加したか
      let targetWeightFlag = false;
      if(changedPhysicalInfo.target_weight && changedPhysicalInfo.target_weight.initValue != changedPhysicalInfo.target_weight.editValue) {
        targetWeightFlag = true;
      }
      // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 end

      // 新規のパターン
      if (this.selectedPhysicalInfoData.addEditC === "1") {
        // 新規追加
        physicalInfo.ctl_no = this.maxCtlNo(physicalInfo, savePhysicalInfo);
        physicalInfo.target_weight = this.targetWeightValue(physicalInfo);
        // mod 8669 【デグレ】患者情報画面内の感染症リストがマスタと一致していない 関 start
        // savePhysicalInfo = [physicalInfo, ...savePhysicalInfo];
        this.dw_log_info.is_add = 1;
        let sameDayFlg = savePhysicalInfo.filter(
          r => r.exam_date === physicalInfo.exam_date && r.ctl_no !== physicalInfo.ctl_no
        );
        if (sameDayFlg.length > 0) {
          this.$ons.notification.alert({
            title: "検査日時重複エラー",
            message: "既に登録済みの身体情報と検査日時が重複しています。"
          }).then(() => {
            this.setLoadingScreenVisible(false);
          });

          return;
        }

        if (!physicalInfo.indicator_cd) physicalInfo.indicator_cd = null;

        let physicalInfoSort = [physicalInfo, ...savePhysicalInfo];

        savePhysicalInfo = physicalInfoSort.sort(
          (a, b) => dayjs(b.exam_date) - dayjs(a.exam_date));
        await this.saveRecord(savePhysicalInfo, hasBeenAdded, this.physicalInfoUpDate || patInfo.pat_unique.old_up_date_unique
          , physicalInfo, "I", targetWeightFlag);
      }
      // 変更のパターン
      else {
        let sameDayFlg = this.updateSave(physicalInfo, savePhysicalInfo);
        if (!sameDayFlg) {
          this.$ons.notification.alert({
            title: "検査日時重複エラー",
            message: "既に登録済みの身体情報と検査日時が重複しています。"
          }).then(() => {
            this.setLoadingScreenVisible(false);
          });
          return;
        }
        this.dw_log_info.is_change = true;
        await this.saveRecord(savePhysicalInfo, hasBeenAdded, this.physicalInfoUpDate || patInfo.pat_unique.old_up_date_unique
          , physicalInfo, "U", targetWeightFlag);
      }

      if(this.modalName === "PhysicalInfoAddEdit"){
	    EventBus.$emit("isRefresh");
      }
      // モーダル閉じる
      this.hideModal();
      this.setLoadingScreenVisible(false);
    },

    /**
     * @description 次患者更新実行フラグ
     * @summary どこかのDWに変更がある場合（遥か未来が固定だと検出できないため、最新だけ確認ではNG）
     */
    isChangedNextPatInfo(savePhysicalInfo) {
      const basePhysicalInfo = this.transformData(this.selectedPhysicalInfoData.jsonArray);
      const basePhysicalInfoList = basePhysicalInfo.sort(
        // 登録日が新しいもの順にソートする
        // @ts-ignore
        (a, b) => dayjs(b.exam_date) - dayjs(a.exam_date));
      let baseDwMax = null;
      let baseDwList = [];
      for (const physicalInfo of basePhysicalInfoList) {
        // DW[患者情報(身体情報)から]
        if (
          physicalInfo !== null &&
          physicalInfo.dw !== undefined &&
          physicalInfo.dw !== null
        ) {
          if (baseDwMax === null) {
            baseDwMax = physicalInfo.dw;
          }
          baseDwList.push({
            dw: physicalInfo.dw,
            examDate: physicalInfo.exam_date
          });
        }
      }
      const savePhysicalInfoList = savePhysicalInfo.sort(
        // 登録日が新しいもの順にソートする
        // @ts-ignore
        (a, b) => dayjs(b.exam_date) - dayjs(a.exam_date));
      let saveDwMax = null;
      let saveDwList = [];
      for (const physicalInfo of savePhysicalInfoList) {
        // DW[患者情報(身体情報)から]
        if (
          physicalInfo !== null &&
          physicalInfo.dw !== undefined &&
          physicalInfo.dw !== null
        ) {
          if (saveDwMax === null) {
            saveDwMax = physicalInfo.dw;
          }
          saveDwList.push({
            dw: physicalInfo.dw,
            examDate: physicalInfo.exam_date
          });
        }
      }

      if (baseDwMax !== saveDwMax) {
        // 最新のDWが異なる
        return true;
      }
      if (baseDwList.length !== saveDwList.length) {
        // DW保存件数が異なる
        return true;
      }
      for (let i = 0; i < saveDwList.length; i++) {
        if (
          baseDwList[i].dw !== saveDwList[i].dw ||
          baseDwList[i].examDate !== saveDwList[i].examDate
        ) {
          // 途中のDWに何か変更有り
          return true;
        }
      }
      return false;
    },
    /**
     * @description 身体情報更新
     * @param {Object} savePhysicalInfo 身体情報カラム
     * @param {Boolean} hasBeenAdded DWを含むレコードを追加したか
     * @param {String} old_up_date_unique 更新時間を追加したか
     * @param {Object} savePhysicalItem 変更なレコード
     * @param {Object} editMod 変更モデル
     * @param {Boolean} targetWeightFlag 目標体重を含むレコードを追加したか
     */
    // mod FNSI-排他処理 劉 start
    // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 start
    // async saveRecord(savePhysicalInfo, hasBeenAdded, old_up_date_unique, savePhysicalItem, editMod) {
    async saveRecord(savePhysicalInfo, hasBeenAdded, old_up_date_unique, savePhysicalItem, editMod, targetWeightFlag) {
    // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 end
      // mod FNSI-排他処理 劉 end
      const up_date = dayjs().format("YYYY-MM-DD HH:mm:ss");
      const physicalInfoJson = {
        pat_unique: JSON.stringify({
          physical_info: JSON.stringify(savePhysicalInfo),
          up_date,
          // add FNSI-排他処理 劉 start
          old_up_date_unique
          // add FNSI-排他処理 劉 end
        }),
        is_changed_next_pat_info: (await this.isChangedNextPatInfo(savePhysicalInfo)) ? "1" : "0",
        has_been_added: hasBeenAdded ? "1" : "0",
        dw_log_info: JSON.stringify(this.dw_log_info),

        // #10443 Added necessary params.
        facility_cd: this.facilityCd,
        save_physical_item: JSON.stringify(savePhysicalItem),
        edit_mod: editMod,
        // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 start
        target_weight_flag: targetWeightFlag ? "1" : "0",
        // #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 end
      };

      const uri = "/patInfo/updatePhysicalInfoById";
      this.setOperation(null);
      this.setIsAdd(0);
      this.setIsUpdate(false);
      // TODO: 一時的に保留:新規患者登録の保存処理時、患者IDが参照できない
      await ApiHelper.put(
        `${uri}/${this.selectedPatId}`,
        physicalInfoJson
      ).catch(error => {
          // mod FNSI-排他処理 劉 start
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PhysicalInfoAddEditForPatInfo.vue', 'saveRecord', "身体情報更新失敗");
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.setLoadingScreenVisible(false);
          if (error.response.data == '22020006') {
            this.isHaitaErrDialogVisible = true;
            throw new Error("身体情報更新失敗");
          }
          // mod FNSI-排他処理 劉 end
          throw new Error("身体情報更新失敗");
        });
        if (this.selectedPhysicalInfoData.jsonArray !== null) {
          const jsonArray = savePhysicalInfo.map(json => {
            return encodeEditableRecord(json);
          });
          this.selectedPhysicalInfoData.jsonArray = jsonArray;
          this.$emit("update:jsonArray", jsonArray);
        }

      // 選択患者の身体情報を更新する
      // const selectedPatCopy = deepCopy(this.selectedPat);
      // selectedPatCopy.pat_unique.physical_info = JSON.stringify(
      //   savePhysicalInfo
      // );
      // // add FNSI-排他処理 劉 start
      // selectedPatCopy.pat_unique.up_date = up_date;
      // selectedPatCopy.pat_unique.old_up_date_unique = up_date;
      // // add FNSI-排他処理 劉 end
      // this.setSelectedPat(selectedPatCopy);
      this.setPhysicalInfoUpDate(up_date);

      this.clearAddItem();
    },

    /**
     * @description 最大コントロール番号
     * @param {Object} editedPhysical 編集json
     * @param {Object} physicalInfo 身体情報レコード
     */
    maxCtlNo(physicalInfo, savePhysicalInfo) {
      // コントロール番号の最大値を設定
      const ctlNoList = [physicalInfo, ...savePhysicalInfo].map(
        info => info.ctl_no);
      const maxCtlNo = _.maxBy(ctlNoList, el => el);

      // コントロール番号追加
      return maxCtlNo + 1;
    },

    /**
     * @description 目標体重設定(患者経過総合ビューア用)
     * @param {Object} editedPhysical 編集json
     */
    targetWeightValue(editedPhysical) {
      // 目標体重がDWと同じなら-1を設定※患者経過総合ビューア仕様
      // add FNSI-障害票一覧_身体情報.xlsxのNo.2対応 韓 start
      if (this.isChangeTargetWeight.editValue === "0") {
        return null;
      }
      // add FNSI-障害票一覧_身体情報.xlsxのNo.2対応 韓 end
      const targetWeight = editedPhysical.target_weight;
      const DW = editedPhysical.dw;
      const targetWeightValue = targetWeight === DW ? "-1" : targetWeight;
      return targetWeightValue ? targetWeightValue : "-1";
    },

    /**
     * @description 身体情報更新
     * @param {Object} editedPhysical 編集json
     * @param {Object} physicalInfo 身体情報レコード
     */
    updateSave(editedPhysical, physicalInfo) {
      // #10443 ADD 同検査日時日時のデータは作成不可とする Start
      let sameDayFlg = physicalInfo.filter(
        r => r.exam_date === editedPhysical.exam_date && r.ctl_no !== editedPhysical.ctl_no
      );
      if (sameDayFlg.length > 0) {
        return false;
      }

      if (!editedPhysical.indicator_cd) editedPhysical.indicator_cd = null;
      // #10443 ADD 同検査日時日時のデータは作成不可とする End

      // 既存のデータを書換え
      for (const json of physicalInfo) {
        if (json.ctl_no === editedPhysical.ctl_no) {
          // コントロール番号一致
          const keys = Object.keys(json);
          // 各キーに更新値を代入
          for (const key of keys) {
            json[key] = editedPhysical[key];
          }
        }
      }
      return true;
    },

    /**
     * @description json削除
     * @param {Object} editPhysicalValue 編集json
     */
    async deletedPhysicalInfo() {
      const patInfo = deepCopy(this.selectedPat);

      const savePhysicalInfo = this.transformData(this.selectedPhysicalInfoData.jsonArray);

      const deletePhysical = this.changeGenerateDate(this.physicalInfoData);

      const editedPhysical = decodeEditableRecord(deletePhysical);
      // DWを含むレコードを追加したか
      let hasBeenAdded = false;
      // mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-25 start
      // if (editedPhysical.dw && editedPhysical.dw.editValue) {
      if (editedPhysical.dw) {
      // mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-25 end
        hasBeenAdded = true;
      }

      const deletedPhysicalInfo = savePhysicalInfo.filter(
        json => json.ctl_no !== editedPhysical.ctl_no
      );
      // mod FNSI-排他処理 劉 start
      // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 start
      // await this.saveRecord(deletedPhysicalInfo, hasBeenAdded, patInfo.pat_unique.old_up_date_unique
      //   , editedPhysical, "D");
      await this.saveRecord(deletedPhysicalInfo, hasBeenAdded, this.physicalInfoUpDate || patInfo.pat_unique.old_up_date_unique
        , editedPhysical, "D", false);
      // #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-07-01 end
      // mod FNSI-排他処理 劉 end
    },

    /**
     * @description 測定日時DB登録用に変換
     * @param {Object} pahysicalInfo 更新用身体情報レコード({ physical_info })
     * @returns {Object} jsonkey day,timeを削除したObject
     */
    changeGenerateDate(editPhysical) {
      const day = editPhysical.exam_day;
      const timeValue = editPhysical.exam_time;
      const time = timeValue === "" ? null : timeValue;
      let date = null;

      if (day !== null) {
        date = dayjs(`${day}T${time}`, "YYYYMMDDTHHmm").format(
          "YYYY-MM-DDTHH:mm:ss.SSSZ");
        if (time === null) {
          date = dayjs(`${day}`, "YYYYMMDD").format("YYYY-MM-DD");
        }
      }

      editPhysical.exam_date = date;
      const physical = _.pick(editPhysical, this.jsonKeyArray);

      // #10443 Added a col: login account as changer_cd
      physical.changer_cd = this.$store.getters["account-edit/getStateUserAccountInfo"].userId;

      return physical;
    },

    /**
     * @description 最大測定日時フラグ
     * @param {Object} record 身体情報レコード
     * @returns { Boolean }
     */
    isMaxExamDate(record, savePhysicalInfo) {
      if (this.selectedPhysicalInfoData.jsonArray === null) {
        // 患者経過総合ビューアからは指示発行しない
        return false;
      }

      const json = _.maxBy(savePhysicalInfo, el => {
        return this.formatterDay(el) + this.formatterTime(el);
      });

      return json.exam_date === record.exam_date;
    },

    /**
     * @description 指示リスト取得
     * @param {String} indStartDate 治療開始日
     * @returns
     */
    async ordMainList(indStartDate) {
      // 一年後
      const indEndDate = dayjs(indStartDate, "YYYYMMDD")
        .add(1, "y")
        .subtract(1, "days")
        .format("YYYY-MM-DD");

      // データ取得条件の格納
      const paramJson = {
        // 施設コード
        facility_cd: this.facilityCd,
        // 患者ID
        pat_id: this.selectedPatId,
        // 治療開始日
        ind_start_date: dayjs(indStartDate, "YYYYMMDD").format("YYYY-MM-DD"),
        // 治療終了日
        ind_end_date: indEndDate,
        // 曜日パターン
        week_pattern: "[{'text': '全','done': false,'value': 0}]"
      };
      // データの取得
      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson).catch(error => {
        throw error;
      });
      return response.data.length === 0 ? null : response.data;
    },

    /**
     * @description 指示更新
     * @param {Object} record 更新用身体情報レコード
     * @param {String} targetWeight 更新前目標体重
     */
    // mod #2856：DWの指示履歴登録対応 韓 start
    async updateOrdMain(record, indCondInfo, physicalInfo) {
      // mod #2856：DWの指示履歴登録対応 韓 end
      // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zhou start
      //const targetWeight = indCondInfo["3"].value;
      const targetWeight = indCondInfo["3"] ? indCondInfo["3"].value : null;
      // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zhou end
      // add #2856：DWの指示履歴登録対応 韓 start
      const initValueDw = this.initDw;
      // add #2856：DWの指示履歴登録対応 韓 end
      const indInfo = {
        "3": {
          // 設定値
          // mod FNSi6740目標体重をDWと同じと設定したとき、以降の治療のord_main.ind_conf_infoの目標体重がnullとなる start
          //value: record.target_weight,
          value: physicalInfo.target_weight,
          // mod FNSi6740目標体重をDWと同じと設定したとき、以降の治療のord_main.ind_conf_infoの目標体重がnullとなる end

          // #10196 modified by z / Del for now , no need to fill in these records in this monent.
          // add #2856：DWの指示履歴登録対応 韓 start
          // 変更前の設定値(指示履歴用)
          // init_value: targetWeight,
          // 変更前の設定値(DW指示履歴用)
          // init_value_dw: initValueDw,
          // 設定値_DW
          // value_dw: record.dw,
          // 指示開始日
          // indicator_start_date: physicalInfo.indicator_start_date,
          // add #2856：DWの指示履歴登録対応 韓 end
          // #10196 modified by z

          // 指示者コード
          ind_user_id: record.indicator_cd,
          // 指示者_姓
          ind_user_last_name: null,
          // 指示者_名
          ind_user_first_name: null,
          // 更新者コード
          // mod #2856：DWの指示履歴登録対応 韓 start
          upd_user_id: record.indicator_cd,
          // mod #2856：DWの指示履歴登録対応 韓 end
          // 更新者_姓
          upd_user_last_name: null,
          // 更新者_名
          upd_user_first_name: null
        }
      };
      const indStartDate = record.indicator_start_date;

      // 一年後
      const indEndDate = dayjs(indStartDate, "YYYYMMDD")
        .add(1, "y")
        .subtract(1, "days")
        .format("YYYYMMDD");

      const sendJson = {
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 start
        // OK/Cancel
        answer_Flg: false,
        quantity_before: 0,
        quantity_after: 0,
        // 表示計算項目Cd
        accountItem_Cd: 7,
        // チェックボックス
        checkBox_Flg: false,
        // add FNSI-改修内容 患者経過総合ビューアレイアウトマスタにて非表示とした場合の変更点 穆 end
        // 施設コード
        facility_cd: this.facilityCd,
        // 患者ID
        pat_id: this.selectedPatId,
        // 治療開始日
        ind_start_date: indStartDate,
        // 治療終了日
        ind_end_date: indEndDate,
        // 曜日パターン
        week_pattern: "[{'text': '全','done': false,'value': 0}]",
        // 変更対象クールコード
        ind_kur_cd: JSON.stringify([]),
        // 変更対象治療方法コード
        ind_treatment_cd: JSON.stringify([]),
        // 変更対象データ
        ind_cond_info: JSON.stringify(indInfo),
        // 終了日存在フラグ
        is_deadline: false,
        // 条件送信前のみを対象とする
        target_dialysis_state: "0",
        // add #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs start
        hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
        user_id: this.getStateUserAccountInfo.userId,
        header_title: this.dwAddedFlg ? "身体情報" : ""
        // add #7627 患者経過総合ビューアで治療方法・治療条件を変更して新規イベントが作成されることがある zs end
      };

      // TODO: 指示履歴残すか精査中※現在は残る挙動
      await ApiHelper.post("/mainData/updateOrdMainInfo", sendJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('PhysicalInfoAddEditForPatInfo.vue', 'updateOrdMain', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          throw error;
        }
      );
    },

    /**
     * @description 日付フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterDay(json) {
      return dayjs(json.exam_date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format(
        "YYYYMMDD");
    },

    /**
     * @description 時間フォーマット
     * @param {Object} json
     * @returns {String}
     */
    formatterTime(json) {
      return dayjs(json.exam_date, "YYYY-MM-DDTHH:mm:ss.SSSZ").format("HHmm");
    },

    /**
     * @description 最新のDWを設定する
     * @summary 患者経過総合ビューアから呼び出しのみ
     */
    setUpdateDW() {
      this.addItem.dw.initValue = this.maxDateDW();
      this.addItem.dw.editValue = this.maxDateDW();
      this.dwValue(this.addItem.dw.editValue);
    },

    /**
     * @description 選択された目標体重を設定する
     * @summary 患者経過総合ビューアから呼び出しのみ
     */
    // DEL By #10704 Useless method Start
    // async setTargetWeight() {
    //   const ordMainList = await this.ordMainList(
    //     // mod #2856：DWの指示履歴登録対応 韓 start
    //     this.selectedPhysicalInfoData.physicalInfo.exam_day.editValue
    //     // mod #2856：DWの指示履歴登録対応 韓 end
    //   );
    //   const indCondInfo = JSON.parse(ordMainList[0].indCondInfo);
    //   // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zhou start
    //   //const targetWeight = indCondInfo["3"].value;
    //   const targetWeight = indCondInfo["3"] ? indCondInfo["3"].value : null;
    //   // mod 9372 患者情報から身体情報(DW，目標体重)を登録して保存すると処理中のままになる zhou end
    //
    //   this.addItem.target_weight.initValue =
    //     targetWeight == '-1' ? null : targetWeight; // mod #9973 value Number→文字列  shiyw
    //   this.addItem.target_weight.editValue =
    //     targetWeight == '-1' ? null : targetWeight; // mod #9973 value Number→文字列  shiyw
    // },
    // DEL By #10704 Useless method End

    /**
     * @description 選択された治療開始日を設定する
     * @summary 患者経過総合ビューアから呼び出しのみ
     */
    setIndicatorStartDate() {
      // mod #2856：DWの指示履歴登録対応 韓 start
      this.addItem.indicator_start_date.initValue = (null != this.selectedPhysicalInfoData.physicalInfo && undefined != this.selectedPhysicalInfoData.physicalInfo.exam_day)
                                                  ? this.selectedPhysicalInfoData.physicalInfo.exam_day.initValue : null;
      this.addItem.indicator_start_date.editValue = (null != this.selectedPhysicalInfoData.physicalInfo && undefined != this.selectedPhysicalInfoData.physicalInfo.exam_day)
                                                  ? this.selectedPhysicalInfoData.physicalInfo.exam_day.editValue : null;
      // mod #2856：DWの指示履歴登録対応 韓 end
    },

    /**
     * @description 一覧から最新DWを返す
     * @returns { Number }
     */
    maxDateDW() {
      const physicalInfo = this.transformData(this.selectedPhysicalInfoData.jsonArray);
      if (physicalInfo === 0) {
        return null;
      }

      const dwList = physicalInfo.filter(json => json.dw !== null);
      if (dwList.length === 0) {
        return null;
      }

      const json = _.maxBy(dwList, el => {
        return this.formatterDay(el) + this.formatterTime(el);
      });
      return json.dw;
    },

    /**
     * Format date String in case of Custom_input_date's value doesn't format itself.
     *
     * @param dateStr Custom_input_date's value
     * @returns {string|null}  formatted date String
     */
    formatDate(dateStr) {
      let date;
      /* Because of this parameter came form Custom_input_date, so that we can trust its rationality. */
      // 'yyyymmdd'
      if (/^\d{8}$/.test(dateStr)) {
        date = new Date(dateStr.slice(0, 4), parseInt(dateStr.slice(4, 6)) - 1, dateStr.slice(6, 8));
      }
      // 'yyyy-mm-dd'
      else if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
        date = new Date(dateStr);
      }
      // 'yyyy/mm/dd'
      else if (/^\d{4}\/\d{2}\/\d{2}$/.test(dateStr)) {
        date = new Date(dateStr);
      }
      // unknown format
      else if (dateStr) {
        throw new Error("Invalid date format")
      } else {
        return dateStr;
      }

      return date.getFullYear() + "-"
        + ("0" + (date.getMonth() + 1)).slice(-2) + "-"
        + ("0" + date.getDate()).slice(-2);
    },

    /**
     * 検査日時から見た直近過去のDW情報を設定
     */
    async setDwPreviousInfo() {
      // 初期値
      const defaultVal = {
        dw: null,
        examDate: null
      }

      // 無効な日付判定関数
      const isInvalidDate = (date,examDay) => {
        return Number.isNaN(date.getTime()) || examDay !== dayjs(date).format(DATE_FORMAT_NORMAL);
      }
      // 検査日時欄入力値より日付を取得
      const examDay = dateFormat.normalDateWithCheck(this.physicalInfoData.exam_day.editValue);
      const examTime = !this.physicalInfoData.exam_time.editValue ? null : dateFormat.char2time(this.physicalInfoData.exam_time.editValue)
      const examDate = this.getDateVal(examDay, examTime)
      // 未設定or変換できない日付の場合は初期値を設定して終了
      if(!examDate || isInvalidDate(examDate,examDay)){
        this.dwPreviousInfo = defaultVal;
        return;
      }

      // 患者固有情報_身体情報を取得
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      const response = await ApiHelper.get(`/patInfo/getPatInfoById/${this.selectedPatId}`).catch(
        error => {
          getErrorMessage('PhysicalInfoAddEditForPatInfo.vue', 'setDwPreviousInfo', error);
          throw error;
        }).finally(() =>
        this.setLoadingScreenVisible(false));
      // 取得できない場合は初期値を設定して終了
      if(!response?.data[0]?.physical_info){
        this.dwPreviousInfo = defaultVal;
        return;
      }

      // 検査日時より前のデータを抽出
      const physical_info = JSON.parse(response.data[0].physical_info);
      const dwList = physical_info.filter(data => data.dw !== null
              && dayjs(data.exam_date) < dayjs(examDate))
      // 検査日時より前のデータがない場合は初期値を設定して終了
      if (dwList.length === 0) {
        this.dwPreviousInfo = defaultVal;
        return;
      }

      // リストの中で最新の検査日時のDWと日時を設定
      const maxData = _.maxBy(dwList, el => {
        return dayjs(el.exam_date);
      });
      this.dwPreviousInfo = {
        dw: maxData.dw,
        examDate: dayjs(maxData.exam_date).format(DATE_FORMAT_NORMAL)
      }
    },
    /**
     * 日時の入力値を日付型で返す
     * @param {string|null} date 日付文字列(yyyy-MM-dd or yyyy/MM/dd)
     * @param {string|null} time 時刻文字列(HH:mm)
     * @returns {Date|null} 入力日時
     */
    getDateVal(date,time) {
      let dateVal = null;
      if (time) {
        // 日付＋時刻を設定
        dateVal =
          date && time
            ? parseDate(date, time)
            : null;
      } else {
        // 日付のみを設定
        dateVal = date
          ? parseDate(date, "00:00")
          : null;
      }
      return dateVal;
    },
    isOtherFacilityRow() {
      const facilityCd = this.physicalInfoData?.facility_cd?.initValue;
      if (!facilityCd) {
        return false;
      }
      return facilityCd !== this.facilityCd;
    },
  }
};
</script>

<style scoped>
ons-row {
  align-items: center;
  margin-bottom: 3px;
}
.physical-edit-area {
  vertical-align: middle;
  text-align: center;
}
.physical-edit-area :deep(.ntss-custom-kendo),
ons-select :deep(.select-input) {
  font-size: 1em;
  line-height: unset
}
.physical-edit-area :deep(button.calender),
.physical-edit-area :deep(input.custom-input-time) {
  font-size: 1em;
  /* add FNSI-input -> textarea変更 江 start */
  color: black !important;
  /* add FNSI-input -> textarea変更 江 end */
}

.edit-area {
  display: inline-block;
  text-align: left;
  width: 655px;
}

.physical-title,
.physical-data {
  display: block;
}

.order-area,
.height-area,
.weight-area,
.breast-area,
.chest-area,
.ctr-area,
.dw-area,
.target-weight-area,
.memo-area,
.indicator-area,
.indicator_date,
.area-checkbox {
  min-width: 10em;
  max-width: 10em;
  margin-right: 41px;
}
.date-area{
  min-width: 8em;
  max-width: 8em;
  margin-right: 72px;
}
.button-area {
  display: flex;
  justify-content: space-between;
  padding: 10px;
}

.custom-select-physical,
.custom-date {
  width: 13em;
}

.unit {
  margin-left: 5px;;
}

/* TODO: 共通スタイル(modal.css)に定義 */
div :deep(.modal-header .toolbar) {
  background-color: var(--ntss-header-background-color);
}

div :deep(.modal-header .toolbar__title.toolbar__left) {
  color: var(--ntss-header-color) !important;
}

div :deep(.modal-search),
div :deep(.modal-body),
div :deep(.modal-footer),
div :deep(.modal-footer .bottom-bar) {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}

ons-button.cancel {
  margin-right: 7.5px;
}

div :deep(.modal-container) {
  background-color: var(--ntss-base-background-color);
}

/* add FNSI-input -> textarea変更 江 start */
.physical-edit-area :deep(textarea.custom-textarea) {
  color: black !important;
}
/* add FNSI-input -> textarea変更 江 end */
.dw-kg-area{
  display: none;
}
.dw-previous-area {
  display: none;
}
.nowrap {
  white-space: nowrap;
}
@media print {
  .comTextarea {
    width: 90%;
  }
  .edit-area {
    display: block;
    margin: 0 auto;
  }
}

@media screen and (max-width: 540px) {

  .order-area,
  .height-area,
  .weight-area,
  .breast-area,
  .chest-area,
  .ctr-area,
  .dw-area,
  .target-weight-area,
  .indicator-area,
  .indicator_date {
    min-width: 10em;
    margin-bottom: 5px;
    margin-right: 15px;
  }
  .date-area {
    min-width: 8em;
    margin-right: 45px;
  }
  .memo-area {
    min-width: 95%;
  }
  .area-checkbox {
    display: none;
  }
  .edit-area {
    margin-left: 10px;
    width: 95%;
  }
  .physical-edit-area :deep(.calender) {
    width: 2em;
  }
  .custom-date {
    max-width: 9em;
  }
  .physical-edit-area :deep(textarea.custom-textarea) {
    width: 83%;
  }
  .custom-input-half {
    width: 65%;
  }
  .physical-edit-area :deep(.custom-input-full) {
    width: 95%;
  }
  .input-area {
    flex-grow: 2;
  }
  .custom-input-time {
    margin-left: 50%;
  }
  ons-row {
    margin-bottom: 10px;
  }
  .dw-kg-previous-area{
    display: none;
  }
  .dw-kg-area{
    display: flex;
  }
  .dw-previous-area {
    display: flex;
    min-width: 10em;
    margin-bottom: 5px;
    margin-right: 15px;
  }
}
:deep(.change_date){
  width: 11.05em !important;
}
:deep(.isChangeStyle.k-dropdownlist),:deep(.isChangeStyle.k-dropdown .k-dropdown-wrap){
  background-color: #ffff99 !important;
}
</style>
<style>
/* add 画面デザイン改善対応 李 start */
.kendo-dropdownlist-select-edited {
  color: green !important;
  font-weight: bold;
  border: 2px green solid !important;
}
.kendo-dropdownlist-select-edited > span {
  color: green !important;
}

.kendo-dropdownlist-listbox > .k-item {
  color: green !important;
  font-weight: normal;
}
/* add 画面デザイン改善対応 李 end */
</style>
