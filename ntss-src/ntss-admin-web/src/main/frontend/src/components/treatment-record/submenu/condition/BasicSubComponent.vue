/**
 * 治療記録の子機能 治療条件（基本条件）
 */
<template>
  <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 start -->
  <!-- <div class="expandable-content"> -->
  <div class="expandable-content" style="align-self: baseline;">
  <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 end -->
    <div>
      <v-ons-row>
        <v-ons-col class="title">
          <label class="theme">治療時間</label>
        </v-ons-col>
        <!-- add FNSI-改修内容timeの配置 徐 start -->
        <!-- <v-ons-col> -->
        <v-ons-col class="action-condition-data-column treat-time" style="display: flex; align-items:Center;">
          <!-- add FNSI-改修内容timeの配置 徐 end -->
          <!-- mod FNSI-共有を追加 王 20200921 start -->
          <!-- add 6668 治療時間が72時間まで入力できない 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <custom-input-time-special
            :value="displayInputValue"
            :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
            font-color="#333333"
            class="action-condition-input ntss-custom-input-cond"
          />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- add 6668 治療時間が72時間まで入力できない 房 end -->
          <!-- del 6668 治療時間が72時間まで入力できない 房 start -->
          <!--
          <v-ons-input
            type="time"
            model-event="change"
            input-id="treat-start-time"
            name="treat-start-time"
            :disabled="!isShared"
            id="edit-treatStartTime"
            v-model="inputModel.treatStartTime" />
            -->
          <!-- del 6668 治療時間が72時間まで入力できない 房 end -->
          <!-- mod FNSI-共有を追加 王 20200921 end -->
        </v-ons-col>
      </v-ons-row>
      <!-- mod FNSI-改修内容背景色 房 start -->
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod FNSI-redmine3855 徐 start -->
      <!--
      <com-master-selector labelName="VA" :readMasterData="requestApis.va" :masterDefine="masterDefs.va" v-model="inputModel.va" :disabled="!isShared" :class="styleFlg.flag1?'column-ground-color':null"/>
      <com-number-display labelName="DW" unitName="kg" :digits="2" v-model="inputModel.dw" :required="false"/>
      <com-number-input labelName="除水量制限" unitName="L" :step=0.01 :min=0.00 :max=39.99 v-model="inputModel.waterRemovalAmountLimit" :disabled="!isShared" :class="styleFlg.flag2?'column-ground-color':null"/>
      <com-number-input labelName="目標体重" unitName="kg" :step=0.01 :min=0.00 :max=300.00 v-model="inputModel.targetWeight" :disabled="!isShared" :class="styleFlg.flag3?'column-ground-color':null"/>
      <com-master-selector labelName="ダイアライザ" :readMasterData="requestApis.dialyzer" :masterDefine="masterDefs.dialyzer" v-model="inputModel.dialyzer" :class="styleFlg.flag4?'column-ground-color':null"/>
      <com-master-selector labelName="吸着カラム" :readMasterData="requestApis.equipmentAdsorptionColumn" :masterDefine="masterDefs.equipmentAdsorptionColumn" v-model="inputModel.adsorptionColumn" :class="styleFlg.flag5?'column-ground-color':null"/>
      <com-master-selector labelName="1次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" :class="styleFlg.flag6?'column-ground-color':null"/>
      <com-master-selector labelName="2次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" :class="styleFlg.flag7?'column-ground-color':null"/>
      <com-radio name="single-needle" labelName="シングルニードル使用" :radioItems=radioItems.singleNeedle v-model="inputModel.singleNeedle" :disabled="!isShared" :class="styleFlg.flag8?'column-ground-color':null"/>
      <com-master-selector labelName="穿刺針(A針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA" :class="[!isUseSingleNeedle ? null : 'display-none', styleFlg.flag9?'column-ground-color':null]" />
      <com-master-selector labelName="穿刺針(V針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" :class="[!isUseSingleNeedle ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" />
      <com-master-selector labelName="穿刺針(SN)" :readMasterData="requestApis.equipmentPunctureNeedleSN" :masterDefine="masterDefs.equipmentPunctureNeedleSN" v-model="inputModel.punctureNeedleSn" :class="[isUseSingleNeedle ? null : 'display-none', styleFlg.flag11?'column-ground-color':null]" />
      <com-master-selector labelName="血液回路" :readMasterData="requestApis.equipmentBloodCircuit" :masterDefine="masterDefs.equipmentBloodCircuit" v-model="inputModel.bloodCircuit" :class="styleFlg.flag12?'column-ground-color':null"/>
      -->
      <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 start -->
      <v-ons-row :class="[styleFlg.flag1?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            VA
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.va.name"
            :propEditValue="inputModel.va.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.va" :masterDefine="masterDefs.va" v-model="inputModel.va" :isDisabled="!isShared || styleFlg.flag1"/>-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <com-master-selector :readMasterData="requestApis.va" :masterDefine="masterDefs.va" v-model="inputModel.va" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="VA" :readMasterData="requestApis.va" :masterDefine="masterDefs.va" v-model="inputModel.va" :disabled="!isShared" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag1?'column-ground-color':null]"/>
      <com-master-selector labelName="VA" :readMasterData="requestApis.va" :masterDefine="masterDefs.va" v-model="inputModel.va" :disabled="!isShared" v-show="isMobileBrowser" :class="[styleFlg.flag1?'column-ground-color':null]"/> -->
      <com-number-display class="basic-sub-com-display-dw" labelName="DW" unitName="kg" :digits="2" v-model="inputModel.dw" :class="styleFlg.flag14?'column-ground-color':null" :required="false"/>
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input
        labelName="目標体重"
        unitName="kg"
        input-min-width="10em"
        :step=0.01
        :inputMin=0.00
        :inputMax=300.00
        :inputType='"number"'
        v-model="inputModel.targetWeight"
        :initValue="initModel.targetWeight"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared"
        :class="styleFlg.flag3?'column-ground-color':null"/>
      <com-number-input
        labelName="除水量制限"
        unitName="L"
        input-min-width="10em"
        :step=0.01
        :inputMin=0.00
        :inputMax=39.99
        :inputType='"number"'
        v-model="inputModel.waterRemovalAmountLimit"
        :initValue="initModel.waterRemovalAmountLimit"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared"
        :class="styleFlg.flag2?'column-ground-color':null"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
       <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
      <v-ons-row :class="[styleFlg.flag4?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            ダイアライザ
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.dialyzer.name"
            :propEditValue="inputModel.dialyzer.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector labelName="ダイアライザ" :readMasterData="requestApis.dialyzer" :masterDefine="masterDefs.dialyzer" v-model="inputModel.dialyzer" :isDisabled="styleFlg.flag4" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <com-master-selector labelName="ダイアライザ" :readMasterData="requestApis.dialyzer" :masterDefine="masterDefs.dialyzer" v-model="inputModel.dialyzer" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="ダイアライザ" :readMasterData="requestApis.dialyzer" :masterDefine="masterDefs.dialyzer" v-model="inputModel.dialyzer" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag4?'column-ground-color':null]"/> -->
      <!-- <com-master-selector labelName="ダイアライザ" :readMasterData="requestApis.dialyzer" :masterDefine="masterDefs.dialyzer" v-model="inputModel.dialyzer" v-show="isMobileBrowser" :class="[styleFlg.flag4?'column-ground-color':null]"/> -->
      <v-ons-row :class="[styleFlg.flag5?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            吸着カラム
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.adsorptionColumn.name"
            :propEditValue="inputModel.adsorptionColumn.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.equipmentAdsorptionColumn" :masterDefine="masterDefs.equipmentAdsorptionColumn" v-model="inputModel.adsorptionColumn" v-show="!isMobileBrowser" :isDisabled="styleFlg.flag5" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <com-master-selector :readMasterData="requestApis.equipmentAdsorptionColumn" :masterDefine="masterDefs.equipmentAdsorptionColumn" v-model="inputModel.adsorptionColumn" v-show="!isMobileBrowser" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="吸着カラム" :readMasterData="requestApis.equipmentAdsorptionColumn" :masterDefine="masterDefs.equipmentAdsorptionColumn" v-model="inputModel.adsorptionColumn" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag5?'column-ground-color':null]"/> -->
      <v-ons-row :class="[styleFlg.flag6?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            1次膜
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.primaryFilm.name"
            :propEditValue="inputModel.primaryFilm.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" v-show="!isMobileBrowser" :isDisabled="styleFlg.flag6" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start -->
          <!-- <com-master-selector :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" v-show="!isMobileBrowser" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"/> -->
          <com-master-selector :readMasterData="requestApis.equipmentFilmFirst" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" v-show="!isMobileBrowser" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="1次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag6?'column-ground-color':null]"/> -->
      <!-- <com-master-selector labelName="1次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.primaryFilm" v-show="isMobileBrowser" :class="[styleFlg.flag6?'column-ground-color':null]"/> -->
      <v-ons-row :class="[styleFlg.flag7?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            2次膜
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.secondaryFilm.name"
            :propEditValue="inputModel.secondaryFilm.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" :class="[styleFlg.flag7?'column-ground-color':null]" :isDisabled="styleFlg.flag7" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start -->
          <!-- <com-master-selector :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" :class="[styleFlg.flag7?'column-ground-color':null]" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"/> -->
          <com-master-selector :readMasterData="requestApis.equipmentFilmSecond" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" :class="[styleFlg.flag7?'column-ground-color':null]" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="2次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag7?'column-ground-color':null]"/> -->
      <!-- <com-master-selector labelName="2次膜" :readMasterData="requestApis.equipmentFilm" :masterDefine="masterDefs.equipmentFilm" v-model="inputModel.secondaryFilm" v-show="isMobileBrowser" :class="[styleFlg.flag7?'column-ground-color':null]"/> -->
      <!-- mod #9342 start ljx -->
      <!--<com-radio name="single-needle" labelName="シングルニードル使用" :radioItems=radioItems.singleNeedle v-model="inputModel.singleNeedle" :disabled="!isShared || styleFlg.flag8" :class="[styleFlg.flag8?'column-ground-color':null]"/>-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-radio name="single-needle" labelName="シングルニードル使用" :radioItems=radioItems.singleNeedle v-model="inputModel.singleNeedle" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared" :class="[styleFlg.flag8?'column-ground-color':null]"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod #9342 end ljx -->
      <v-ons-row :class="[ isAVDisplay ? null : 'display-none', styleFlg.flag9?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            穿刺針(A針)
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.punctureNeedleA.name"
            :propEditValue="inputModel.punctureNeedleA.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA" :isDisabled="styleFlg.flag9" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start -->
          <!-- <com-master-selector :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA"  :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')" /> -->
          <com-master-selector :readMasterData="requestApis.equipmentPunctureNeedleA" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA"  :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared" />
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="穿刺針(A針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA" v-show="!isMobileBrowser" :class="['isClass', !isUseSingleNeedle ? null : 'display-none', styleFlg.flag9?'column-ground-color':null]" />
      <com-master-selector labelName="穿刺針(A針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleA" v-show="isMobileBrowser" :class="[!isUseSingleNeedle ? null : 'display-none', styleFlg.flag9?'column-ground-color':null]" /> -->
      <v-ons-row :class="[ isAVDisplay ? null : 'display-none', styleFlg.flag10?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            穿刺針(V針)
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.punctureNeedleV.name"
            :propEditValue="inputModel.punctureNeedleV.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector  :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" :class="[ isAVDisplay ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" :isDisabled="styleFlg.flag9" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start -->
          <!-- <com-master-selector  :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" :class="[ isAVDisplay ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"/> -->
          <com-master-selector  :readMasterData="requestApis.equipmentPunctureNeedleV" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" :class="[ isAVDisplay ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
          <!-- #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="穿刺針(V針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" v-show="!isMobileBrowser" :class="['isClass', !isUseSingleNeedle ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" />
      <com-master-selector labelName="穿刺針(V針)" :readMasterData="requestApis.equipmentPunctureNeedle" :masterDefine="masterDefs.equipmentPunctureNeedle" v-model="inputModel.punctureNeedleV" v-show="isMobileBrowser" :class="[!isUseSingleNeedle ? null : 'display-none',styleFlg.flag10?'column-ground-color':null]" /> -->
      <v-ons-row :class="[ isSNDisplay ? null : 'display-none', styleFlg.flag11?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            穿刺針(SN)
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.punctureNeedleSn.name"
            :propEditValue="inputModel.punctureNeedleSn.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector labelName="穿刺針(SN)" :readMasterData="requestApis.equipmentPunctureNeedleSN" :masterDefine="masterDefs.equipmentPunctureNeedleSN" v-model="inputModel.punctureNeedleSn" :isDisabled="styleFlg.flag9" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <com-master-selector labelName="穿刺針(SN)" :readMasterData="requestApis.equipmentPunctureNeedleSN" :masterDefine="masterDefs.equipmentPunctureNeedleSN" v-model="inputModel.punctureNeedleSn" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"/>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="穿刺針(SN)" :readMasterData="requestApis.equipmentPunctureNeedleSN" :masterDefine="masterDefs.equipmentPunctureNeedleSN" v-model="inputModel.punctureNeedleSn" v-show="!isMobileBrowser" :class="['isClass', isUseSingleNeedle ? null : 'display-none', styleFlg.flag11?'column-ground-color':null]" />
      <com-master-selector labelName="穿刺針(SN)" :readMasterData="requestApis.equipmentPunctureNeedleSN" :masterDefine="masterDefs.equipmentPunctureNeedleSN" v-model="inputModel.punctureNeedleSn" v-show="isMobileBrowser" :class="[isUseSingleNeedle ? null : 'display-none', styleFlg.flag11?'column-ground-color':null]" /> -->
      <v-ons-row :class="[styleFlg.flag12?'column-ground-color':null]">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            血液回路
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.bloodCircuit.name"
            :propEditValue="inputModel.bloodCircuit.name"
            propBackgroundColor="#f7f7f7"
            class="basic-sub-input"
          />
          <!-- mod #9342 start ljx -->
          <!--<com-master-selector :readMasterData="requestApis.equipmentBloodCircuit" :masterDefine="masterDefs.equipmentBloodCircuit" v-model="inputModel.bloodCircuit" :isDisabled="styleFlg.flag12" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
          <com-master-selector :readMasterData="requestApis.equipmentBloodCircuit" :masterDefine="masterDefs.equipmentBloodCircuit" v-model="inputModel.bloodCircuit" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod #9342 end ljx -->
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector labelName="血液回路" :readMasterData="requestApis.equipmentBloodCircuit" :masterDefine="masterDefs.equipmentBloodCircuit" v-model="inputModel.bloodCircuit" v-show="isMobileBrowser" :class="[styleFlg.flag12?'column-ground-color':null]"/>
      <com-master-selector labelName="血液回路" :readMasterData="requestApis.equipmentBloodCircuit" :masterDefine="masterDefs.equipmentBloodCircuit" v-model="inputModel.bloodCircuit" v-show="!isMobileBrowser" :class="['isClass', styleFlg.flag12?'column-ground-color':null]"/> -->
      <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 end -->
      <!-- mod FNSI-redmine3855 徐 end -->
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input labelName="血流量" unitName="mL/min" input-min-width="10em" :step=1 :min=0 :max=600 v-model="inputModel.bloodFlow" :initValue="initModel.bloodFlow" :disabled="!isShared || styleFlg.flag13" :class="styleFlg.flag13?'column-ground-color':null"/> -->
      <!-- mod #9342 start ljx -->
      <!--      <com-number-input
            labelName="血流量"
            unitName="mL/min"
            input-min-width="10em"
            :step=1
            :inputMin=0
            :inputMax=600
            :inputType='"number"'
            v-model="inputModel.bloodFlow"
            :initValue="initModel.bloodFlow"
            :disabled="!isShared || styleFlg.flag13"
            :class="styleFlg.flag13?'column-ground-color':null"
            />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input
        labelName="血流量"
        unitName="mL/min"
        input-min-width="10em"
        :step=1
        :inputMin=0
        :inputMax=600
        :inputType='"number"'
        v-model="inputModel.bloodFlow"
        :initValue="initModel.bloodFlow"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared"
        :class="styleFlg.flag13?'column-ground-color':null"
      />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod #9342 end ljx -->
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <!-- mod FNSI-改修内容背景色 房 end -->
    </div>
  </div>
</template>

<script>
import {mapGetters} from "vuex";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
//mod FutreNetWeb+SI課題管理 no.5531 劉全航 start
// import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
//mod FutreNetWeb+SI課題管理 no.5531 劉全航 end
import CommonNumberDisplayComponent from "@/components/treatment-record/submenu/common/CommonNumberDisplayComponent";
// ラジオボタンの共通コンポーネント
//mod FNSI-redmine5848 fang start
// import CommonRadio from "@/components/treatment-record/submenu/common/CommonRadioComponent";
import CommonRadio from "@/components/treatment-record/submenu/common/CommonRadioOffComponent";
//mod FNSI-redmine5848 fang end
// add 6668 治療時間が72時間まで入力できない 房 start
import customInputTimeSpecial from "@/components/common/custom-form-tags/CustomInputTimeSpecial";
// add 6668 治療時間が72時間まで入力できない 房 end
import {
  sendRequestGetMstVa,
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
  sendRequestGetMstDialyzerTabooAllergyNoexpire,
  sendRequestGetMstEquipmentTabooAllergyByClassNoexpire,
  //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
  sendRequestGetMstEquipmentClass
} from "@/apis/treatment-record";
import {
  va,
  dialyzer,
  equipmentAdsorptionColumn,
  equipmentFilm,
  equipmentPunctureNeedle,
  equipmentPunctureNeedleSN,
  equipmentBloodCircuit
} from "@/components/common/master-selector/MasterSelectorDefinitions";
import { Promise } from "q";
import { Basic } from "@/models/treatment-record/condition/Basic";
import { CODES } from "@/constants/TreatmentRecord";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { dialyzerTabooAllergyDeleted, equipmentAllergy } from "@/functions/mst/MstGetters.js";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export default {
  components: {
    "com-number-input": CommonNumberInputComponent,
    "com-master-selector": CommonMasterSelectorComponent,
    "com-radio": CommonRadio,
    "com-number-display": CommonNumberDisplayComponent,
    "show-selected-item": CustomDivShowSelectedItem,
    // add 6668 治療時間が72時間まで入力できない 房 start
    "custom-input-time-special":customInputTimeSpecial,
    // add 6668 治療時間が72時間まで入力できない 房 end
  },
  props: {
    value: {
      type: Basic
    },
    comboList: {
      type: Array
    },
    //mod FNSI-改修内容背景色 房 start
    columnList: {
      type: Array
    },
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // hasAuthority: {
    //   type: Boolean
    // },
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    //mod FNSI-改修内容背景色 房 end
    // add 6668 治療時間が72時間まで入力できない 房 start
    displayInputValue: {
      type: Object
    },
    // add 6668 治療時間が72時間まで入力できない 房 end
  },
  data() {
    return {
      inputModel: new Basic(),
      // ラジオボタンアイテム
      radioItems: {
        singleNeedle: CODES.SINGLE_NEEDLE
      },
      masterDefs: {
        va: va,
        dialyzer: dialyzer,
        equipmentAdsorptionColumn: equipmentAdsorptionColumn,
        equipmentFilm: equipmentFilm,
        equipmentPunctureNeedle: equipmentPunctureNeedle,
        equipmentPunctureNeedleSN: equipmentPunctureNeedleSN,
        // 血液回路のマスタ情報
        equipmentBloodCircuit: equipmentBloodCircuit
      },
      requestApis: {
        va: sendRequestGetMstVa,
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        dialyzer: this.getDialyzerTabooAllergyNoexpire,
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        equipmentAdsorptionColumn: this.getEquipmentMasterAdsorptionColumn,
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // equipmentFilm: this.getEquipmentMasterFilm,
        equipmentFilmFirst: this.getEquipmentMasterFilmFirst,
        equipmentFilmSecond: this.getEquipmentMasterFilmSecond,
        // equipmentPunctureNeedle: this.getEquipmentMasterNeedle,
        equipmentPunctureNeedleA: this.getEquipmentMasterNeedleA,
        equipmentPunctureNeedleV: this.getEquipmentMasterNeedleV,
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        equipmentPunctureNeedleSN: this.getEquipmentMasterNeedleSN,
        // 血液回路取得API
        equipmentBloodCircuit: this.getEquipmentMasterBloodCircuit
      },
      //mod FNSI-改修内容背景色 房 start
      styleFlg: {
        flag1: false,
        flag2: false,
        flag3: false,
        flag4: false,
        flag5: false,
        flag6: false,
        flag7: false,
        flag8: false,
        flag9: false,
        flag10: false,
        flag11: false,
        flag12: false,
        flag13: false,
        flag14: false,
      },
      //mod FNSI-改修内容背景色 房 end
      initModel: new Basic(),
      initFlag: 1,
    };
  },
  watch: {
    value(val) {
      this.inputModel = this.value;
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      Object.assign(this.initModel, this.value);
      // if (this.initFlag == 1) {
      //   Object.assign(this.initModel, this.value);
      //   this.initFlag = 2;
      // }
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    },
    // del 6668 治療時間が72時間まで入力できない 房 start
    // inputModel: {
    //   handler: function(val) {
    //     let element = document.getElementById("edit-treatStartTime");
    //     if (this.initModel.treatStartTime == null && this.inputModel.treatStartTime == "") {
    //       if(element.classList.contains("custom-input-edited")){
    //         element.classList.remove("custom-input-edited")
    //       }
    //     } else if (this.initModel.treatStartTime != this.inputModel.treatStartTime) {
    //       element?.classList?.add("custom-input-edited");
    //     } else {
    //       if(element != null && element != undefined && element.classList.contains("custom-input-edited")){
    //         element.classList.remove("custom-input-edited")
    //       }
    //     }
    //     this.$emit("input", val);
    //   },
    //   deep: true
    // },
    // del 6668 治療時間が72時間まで入力できない 房 end
    //mod FNSI-改修内容背景色 房 start
    columnList() {
      //add FNSI-9369 ljx start
      if(this.columnList == null){
        return;
      }
      //add FNSI-9369 ljx end
      const baseItems = this.columnList.filter(e => e.category_no === 1);
      baseItems[0].items.forEach(el => {
        switch (el.ctl_no) {
          case "2":
            this.styleFlg.flag1 = el.is_use === "1" ? false : true;
            break;
          case "5":
            this.styleFlg.flag4 = el.is_use === "1" ? false : true;
            break;
          case "6":
            this.styleFlg.flag5 = el.is_use === "1" ? false : true;
            break;
          case "7":
            this.styleFlg.flag6 = el.is_use === "1" ? false : true;
            break;
          case "8":
            this.styleFlg.flag7 = el.is_use === "1" ? false : true;
            break;
          case "13":
            this.styleFlg.flag12 = el.is_use === "1" ? false : true;
            break;
          case "14":
            this.styleFlg.flag13 = el.is_use === "1" ? false : true;
            break;
        }
      });

      const weightItems = this.columnList.filter(e => e.category_no === 2);
      weightItems[0].items.forEach(el => {
        switch (el.ctl_no) {
          case "4":
            this.styleFlg.flag2 = el.is_use === "1" ? false : true;
            break;
          case "3":
            this.styleFlg.flag3 = el.is_use === "1" ? false : true;
            break;
          case "39":
            this.styleFlg.flag14 = el.is_use === "1" ? false : true;
            break;
        }
      });

      const needleItems = this.columnList.filter(e => e.category_no === 7);
      needleItems[0].items.forEach(el => {
        switch (el.ctl_no) {
          case "12":
            this.styleFlg.flag8 = el.is_use === "1" ? false : true;
            break;
          case "9":
            this.styleFlg.flag9 = el.is_use === "1" ? false : true;
            break;
          case "10":
            this.styleFlg.flag10 = el.is_use === "1" ? false : true;
            break;
          case "11":
            this.styleFlg.flag11 = el.is_use === "1" ? false : true;
            break;
        }
      });
    },
    //mod FNSI-改修内容背景色 房 end
    // add 6668 治療時間が72時間まで入力できない 房 start
    displayInputValue: {
      handler(data) {
        if  (data && data.editValue) {
          this.inputModel.treatStartTime = this.formatTimeValue((data.editValue / 60) | 0) + ":" +
            this.formatTimeValue(data.editValue % 60 | 0);
        } else {
          this.inputModel.treatStartTime = "00:00";
        }
      },
      deep: true
    }
    // add 6668 治療時間が72時間まで入力できない 房 end
  },
  methods: {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    /**
     * 医療材料マスタ 吸着カラム 取得API.
     */
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentMasterAdsorptionColumn() {
      // return Promise.all([
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      //   sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
      //     this.selectedPatId,
      //     [CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType],
      //     this.getTreatDate
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //   ),
      //   sendRequestGetMstEquipmentClass()
      // ]);
      let equipmentList = Promise.all([
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
          this.selectedPatId,
          [CODES.EQUIPMENT_CLASS.ADSORPTION_COLUMN.classType],
          this.getTreatDate
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        ),
        sendRequestGetMstEquipmentClass()
      ]);
      let cd = this.initModel.adsorptionColumn.cd;
      let name = this.initModel.adsorptionColumn.name;
      await equipmentList.then(async (response)=>{
        return await this.getEquipmentPopover(response[0].data, cd, name);
      })
      return equipmentList;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    },
    /**
     * 医療材料マスタ 1次膜/2次膜 取得API.
     */
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentMasterFilm(num) {
      // return Promise.all([
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      //   sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
      //     this.selectedPatId,
      //     [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
      //     this.getTreatDate
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //   ),
      //   sendRequestGetMstEquipmentClass()
      // ]);
      let equipmentList = Promise.all([
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
          this.selectedPatId,
          [CODES.EQUIPMENT_CLASS.ADSORBER.classType, CODES.EQUIPMENT_CLASS.SEPARATOR.classType],
          this.getTreatDate
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        ),
        sendRequestGetMstEquipmentClass()
      ]);
      let cd = num == 1 ? this.initModel.primaryFilm.cd : this.initModel.secondaryFilm.cd;
      let name = num == 1 ? this.initModel.primaryFilm.name : this.initModel.secondaryFilm.name;
      await equipmentList.then(async (response)=>{
        return await this.getEquipmentPopover(response[0].data, cd, name);
      })
      return equipmentList;
    },
    getEquipmentMasterFilmFirst() {
      return this.getEquipmentMasterFilm(1);
    },
    getEquipmentMasterFilmSecond() {
      return this.getEquipmentMasterFilm(2);
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    /**
     * 医療材料マスタ 穿刺針(SN以外)取得API.
     */
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentMasterNeedle(type) {
      // return Promise.all([
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      //   sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
      //     this.selectedPatId,
      //     [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType],
      //     this.getTreatDate
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //   ),
      //   sendRequestGetMstEquipmentClass()
      // ]);
      let equipmentList = Promise.all([
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
          this.selectedPatId,
          [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE.classType],
          this.getTreatDate
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        ),
        sendRequestGetMstEquipmentClass()
      ]);
      let cd = type == "A" ? this.initModel.punctureNeedleA.cd : this.initModel.punctureNeedleV.cd;
      let name = type == "A" ? this.initModel.punctureNeedleA.name : this.initModel.punctureNeedleV.name;
      await equipmentList.then(async (response)=>{
        return await this.getEquipmentPopover(response[0].data, cd, name);
      })
      return equipmentList;
    },
    getEquipmentMasterNeedleA() {
      return this.getEquipmentMasterNeedle('A');
    },
    getEquipmentMasterNeedleV() {
      return this.getEquipmentMasterNeedle('V');
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    /**
     * 医療材料マスタ 穿刺針(SN)取得API.
     */
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentMasterNeedleSN() {
      // return Promise.all([
      // //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      // sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
      //     this.selectedPatId,
      //     [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType],
      //     this.getTreatDate
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //   ),
      //   sendRequestGetMstEquipmentClass()
      // ]);
      let equipmentList = Promise.all([
      //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
          this.selectedPatId,
          [CODES.EQUIPMENT_CLASS.PUNCTURE_NEEDLE_SN.classType],
          this.getTreatDate
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        ),
        sendRequestGetMstEquipmentClass()
      ]);
      let cd = this.initModel.punctureNeedleSn.cd;
      let name = this.initModel.punctureNeedleSn.name;
      await equipmentList.then(async (response)=>{
        return await this.getEquipmentPopover(response[0].data, cd, name);
      })
      return equipmentList;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    /**
     * 禁忌・アレルギー情報を含めたダイアライザ一覧を取得.
     */
    //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getDialyzerTabooAllergyNoexpire() {
      // return Promise.resolve(
      //   sendRequestGetMstDialyzerTabooAllergyNoexpire(this.selectedPatId, this.getTreatDate)
      // );
      let dialyzerList = Promise.resolve(
        sendRequestGetMstDialyzerTabooAllergyNoexpire(this.selectedPatId, this.getTreatDate)
      );
      await dialyzerList.then(async (response)=>{
        let dialyzerPopover = response.data;
        dialyzerPopover.forEach((item) => {
          item.modelNumber = getPrefix(item) + item.modelNumber;
        })
        let dialyzerPopoverCd = dialyzerPopover.map(item => item.dialyzerCd)
        if (!this.initModel.dialyzer.cd) {
          return dialyzerPopover;
        }
        if (!dialyzerPopoverCd.includes(Number(this.initModel.dialyzer.cd))) {
          let dialyzerAll = await dialyzerTabooAllergyDeleted(this.selectedPatId);
          let dialyzerAllObj = dialyzerAll.find(item => item.dialyzerCd == this.initModel.dialyzer.cd);
          let obj = {
            isDisp: "1",
            dialyzerCd: this.initModel.dialyzer.cd,
            modelNumber: this.initModel.dialyzer.name,
            maker: dialyzerAllObj.maker,
            dialyzerType: dialyzerAllObj.dialyzerType,
            functionClass: dialyzerAllObj.functionClass,
          }
          dialyzerPopover.push(obj)
        } else {
          dialyzerPopover.forEach((item) => {
            if (item.dialyzerCd == this.initModel.dialyzer.cd) {
              item.modelNumber = this.initModel.dialyzer.name;
              item.dialyzerCd = this.initModel.dialyzer.cd;
            }
          })
        }
        return dialyzerPopover;
      })
      return dialyzerList;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    },
    //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
    /**
     * 医療材料マスタ 血液回路取得API.
     */
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentMasterBloodCircuit() {
      // return Promise.all([
      //   //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
      //   sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
      //     this.selectedPatId,
      //     [CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType],
      //     this.getTreatDate
      //     //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
      //   ),
      //   sendRequestGetMstEquipmentClass()
      // ]);
      let equipmentList = Promise.all([
        //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
        sendRequestGetMstEquipmentTabooAllergyByClassNoexpire(
          this.selectedPatId,
          [CODES.EQUIPMENT_CLASS.BLOOD_CIRCUIT.classType],
          this.getTreatDate
          //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
        ),
        sendRequestGetMstEquipmentClass()
      ]);
      let cd = this.initModel.bloodCircuit.cd;
      let name = this.initModel.bloodCircuit.name;
      await equipmentList.then(async (response)=>{
        return await this.getEquipmentPopover(response[0].data, cd, name);
      })
      return equipmentList;
    },
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getEquipmentPopover(data, cd, name) {
      let equipmentPopover = data;
      equipmentPopover.forEach((item) => {
        item.equipmentName = getPrefix(item) + item.equipmentName;
      })
      if (!cd) {
        return equipmentPopover;
      }
      let equipmentPopoverCd = equipmentPopover.map(item => item.equipmentCd)
      if (!equipmentPopoverCd.includes(Number(cd))) {
        let equipmentAll = await equipmentAllergy(this.selectedPatId, true);
        let equipmentAllObj = equipmentAll.find(item => item.equipmentCd == cd);
        let obj = {
          isDisp: "1",
          equipmentCd: cd,
          equipmentName: name,
          classCd: equipmentAllObj.classCd,
        }
        equipmentPopover.push(obj)
      } else {
        equipmentPopover.forEach((item) => {
          if (item.equipmentCd == cd) {
            item.equipmentName = name;
            item.equipmentCd = cd;
          }
        })
      }
      return equipmentPopover;
    },
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    initValueEdit(){
      Object.assign(this.initModel, this.inputModel);
    },
    // add 6668 治療時間が72時間まで入力できない 房 start
    formatTimeValue(value = 0) {
      return value.toString().padStart(2, "0");
    },
    // add 6668 治療時間が72時間まで入力できない 房 end
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", [
      "getSharedFacilityCd",
       //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　Start
       "getTreatDate"
       //#8484:医療材料選択IFのリスト不正(再修正) 期限切れ非表示対応　End
    ]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-redmine3855 徐 start
    isMobileBrowser() {
      return /android|iphone|ipad/i.test(navigator.userAgent);
    },
    // add FNSI-redmine3855 徐 end
    // add FNSI-共有を追加 王 20200921 end
    /**
     * シングルニードル使用有無
     * true：使用する
     * false：使用しない
     */
    isAVDisplay() {
      return this.inputModel.singleNeedle === CODES.CHECK.OFF.cd ? true : false;
    },
    isSNDisplay(){
      return this.inputModel.singleNeedle === CODES.CHECK.ON.cd ? true : false;
    }
  },
};
</script>

<style scoped>
ons-select {
  width: 50%;
  font-size: 1.5em;
}
.display-none {
  display:none;
}
.column-ground-color {
  background-color: #D3D3D3;
  min-width: fit-content;
}
/* mod FutreNetWeb+SI課題管理 no.5531 劉全航 start */
/* add FNSI-redmine3855 徐 start */
/* .isClass >>> ons-button {
  margin-right:30em
} */
/* column-ground-color をあてた場合、黒背景だと文字が見えなくなる為、文字色(白)を解除する */
.column-ground-color >>> label {
  color: unset !important;
}
/* add FNSI-redmine3855 徐 end */
.basic-sub-com-display-dw >>> .title {
  height: 1.6em;
}
.text-color {
  color:var(--treatment-record-text-color);
}
.basic-sub-input {
  min-width: 11em;
  width: 100%;
  max-width: 13em;
}
/* mod FutreNetWeb+SI課題管理 no.5531 劉全航 end */
.custom-input-edited >>> input {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
}

/* add 6668 治療時間が72時間まで入力できない 房 start */
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}

.treat-time {
  margin-left: -9px;
}

.treat-time > .ntss-custom-input-cond {
  margin: 0;
}

.treat-time > .ntss-custom-input-cond > input[type="number"] {
  width: 40px;
  border: none !important;
}

.treat-time > .ntss-custom-input-cond > .time-span {
  width: 50px;
  padding: 2px;
}

.action-condition-data-column >>> input[type="number"] {
  min-width: 1.4em;
  height: fit-content !important;
}

.action-condition-data-column >>> .time-span {
  min-width: fit-content;
  height: 2em;
  box-sizing: border-box;
}
/* add 6668 治療時間が72時間まで入力できない 房 end */
</style>
