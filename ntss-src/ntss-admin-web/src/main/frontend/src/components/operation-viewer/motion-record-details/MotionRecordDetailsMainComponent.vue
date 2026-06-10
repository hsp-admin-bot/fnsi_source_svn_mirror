/**
 * 装置記録詳細 MainContent
 */
<template>
  <div class='main-content-area'>
    <!-- dataType=1(装置記録)またはdataType=3(予防保守/故障予知)の画面 -->
    <div v-if="motionRecordDetail.dataType === dataTypeItem.machineRecord.dataType || motionRecordDetail.dataType === dataTypeItem.preventive.dataType"
          class="machine-record-detail-base data-type">
      <div class="machine-record-detail-message">
        <div v-if="motionRecordDetail.dataType === dataTypeItem.machineRecord.dataType" class='div-title'>{{ dataTypeItem.machineRecord.name }}</div>
        <div v-else class='div-title'>{{ dataTypeItem.preventive.name }}</div>
        <div class='div-title'>{{ motionRecordDetail.eventRegDate }} {{ motionRecordDetail.eventRegTime }}</div>
        <div class='div-title'>{{ motionRecordDetail.machineRecordCd }}</div>
        <div class='div-content'>{{ motionRecordDetail.machineRecordMessage }}</div>
        <div class='div-title'>{{ detailInfoTitle }}</div>
        <div class='div-content'>{{ motionRecordDetail.detailInfo }}</div>
      </div>
      <!-- 対処情報 -->
      <div class="correction-button-area" v-if="motionRecordDetail.dataType === dataTypeItem.preventive.dataType">
        <button v-show="motionRecordDetail.isCorrection == 1" class="correction-button deal-already"
                @click='updateIsCorrection(motionRecordDetail.motionRecordNo, motionRecordDetail.isCorrection)'>実施済</button>
        <button v-show="motionRecordDetail.isCorrection != 1" class="correction-button unexecuted-not"
                @click='updateIsCorrection(motionRecordDetail.motionRecordNo, motionRecordDetail.isCorrection)'>未実施</button>
        <label v-show="motionRecordDetail.isCorrection == 1" class="correction-label">{{ motionRecordDetail.userName }}</label>
        <label
          v-show="motionRecordDetail.isCorrection == 1"
          class="correction-label">{{ getFormatDate(motionRecordDetail.isCorrectionUpDate) }}</label>
      </div>
    </div>
    <!-- dataType=2(緊急発報)の画面 -->
    <div v-if="motionRecordDetail.dataType === dataTypeItem.mNotice.dataType" class="machine-record-detail-base data-type">
      <div class="machine-record-detail-message">
        <div class='div-title'>{{ dataTypeItem.mNotice.name }}</div>
        <div class='div-title'>{{ motionRecordDetail.eventRegDate }}&emsp;{{ motionRecordDetail.eventRegTime }}</div>
        <div class='div-title'>{{ motionRecordDetail.machineRecordCd }}</div>
        <div class='div-content'>{{ motionRecordDetail.machineRecordMessage }}</div>
        <div class='div-title'>{{ detailInfoTitle }}</div>
        <div class='div-content'>{{ motionRecordDetail.detailInfo }}</div>
        <div class='div-title'>{{ emailNameTitle }}</div>
        <div class='div-content'>{{ motionRecordDetail.destinationName }}</div>
        <div class='div-title'>{{ emailTextTitle }}</div>
        <pre class='div-content pre-content'>{{ motionRecordDetail.emailText }}</pre>
      </div>
      <!-- 対処情報 -->
      <div class="correction-button-area">
        <!-- mod #11065 【03】編集権限バグ修正 関 start -->
        <button v-show="motionRecordDetail.isCorrection == 1" class="correction-button deal-already button"
       :disabled="!getItemAuthorized('MotionRecord', 'default_authority')" 
                @click='updateIsCorrection(motionRecordDetail.motionRecordNo, motionRecordDetail.isCorrection
                )' 
               >対処済</button>
        <button v-show="motionRecordDetail.isCorrection == 2" class="correction-button deal-not button"
        :disabled="!getItemAuthorized('MotionRecord', 'default_authority')" 
                @click='updateIsCorrection(motionRecordDetail.motionRecordNo, motionRecordDetail.isCorrection)'
                >対応中</button>
        <button v-show="motionRecordDetail.isCorrection == 0" class="correction-button deal-not button"
         :disabled="!getItemAuthorized('MotionRecord', 'default_authority')"
                @click='updateIsCorrection(motionRecordDetail.motionRecordNo, motionRecordDetail.isCorrection)'
               >未対処</button>
        <!-- mod #11065 【03】編集権限バグ修正 関 end -->
        <label v-show="motionRecordDetail.isCorrection != 0" class="correction-label">{{ motionRecordDetail.userName }}</label>
        <label
          v-show="motionRecordDetail.isCorrection != 0"
          class="correction-label">{{ getFormatDate(motionRecordDetail.isCorrectionUpDate) }}</label>
      </div>
      <!-- 日機装施設の場合 -->
      <div v-if="isNkkFacility" class="correction-button-area">
        <button
          class="correction-button"
          :class="getServiceSupportButtonInfo(motionRecordDetail).class"
          @click='changeServiceSupport(motionRecordDetail)'
        >{{getServiceSupportButtonInfo(motionRecordDetail).text}}</button>
        <label
          v-show="getServiceSupportButtonInfo(motionRecordDetail).dispName"
          class="correction-label">{{ motionRecordDetail.serviceSupportUserName }}</label>
        <label
          v-show="getServiceSupportButtonInfo(motionRecordDetail).dispName"
          class="correction-label">{{ getFormatDate(motionRecordDetail.serviceSupportUpDate) }}</label>
      </div>
    </div>
    <!-- dataType=4(自己診断)の画面 -->
    <v-ons-row v-if="motionRecordDetail.dataType === dataTypeItem.testResults.dataType"  class='ntss-list'>
      <v-ons-col class="machine-record-detail-base data-type" style="height: calc(100% - 2px);">
        <div style="height:2.3em;">
          <div class='div-title' style="float:left;">{{ dataTypeItem.testResults.name }}</div>
          <div style="float:right;">
            <input type="radio" class="icon-tacle" id="icon-tacle" name="icon" @click='switchViewMode(true)' :checked="isTable">
            <label for="icon-tacle" style="display:block;float:left;">
              <v-ons-icon icon="fa-th-list" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
            <input type="radio" class="icon-draph" style="padding-left:5px;" id="icon-draph" name="icon" @click='switchViewMode(false)' :checked="!isTable">
            <label for="icon-draph" style="display:block;float:left;margin-left:15px;">
              <v-ons-icon icon="fa-chart-line" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
          </div>
        </div>
        <!-- 自己診断（表形式） -->
        <div v-if="isTable" style="height:calc(100% - 2.3em);">
          <div v-if="!isDab" class='div-self-diagnosis-type-area'>
            <input type="radio" class="ufrc" id="ufrc" name="self"
                   @click='setTestType(selfDiagnosisItem.ufrc.testType);' :checked="testType===selfDiagnosisItem.ufrc.testType">
            <label for="ufrc" class="filterLabel" style="width:3em;">{{ selfDiagnosisItem.ufrc.name }}</label>
            <input type="radio" class="bloodLeakage" id="bloodLeakage" name="self"
                   @click='setTestType(selfDiagnosisItem.bloodLeakage.testType);' :checked="testType===selfDiagnosisItem.bloodLeakage.testType">
            <label for="bloodLeakage" class="filterLabel" style="width:3em;">{{ selfDiagnosisItem.bloodLeakage.name }}</label>
            <input type="radio" class="DialysateFlowRate" id="DialysateFlowRate" name="self"
                   @click='setTestType(selfDiagnosisItem.dialysateFlowRate.testType);' :checked="testType===selfDiagnosisItem.dialysateFlowRate.testType">
            <label for="DialysateFlowRate" class="filterLabel" style="width:6em;">{{ selfDiagnosisItem.dialysateFlowRate.name }}</label>
            <input type="radio" class="Concentration" id="Concentration" name="self"
                   @click='setTestType(selfDiagnosisItem.concentration.testType);' :checked="testType===selfDiagnosisItem.concentration.testType">
            <label for="Concentration" class="filterLabel" style="width:3em;">{{ selfDiagnosisItem.concentration.name }}</label>
          </div>
          <div v-else class='div-self-diagnosis-type-area'>
            <input type="radio" class="pipingTest" id="pipingTest" name="self"
                   @click='setTestType(selfDiagnosisItem.piping.testType);' :checked="testType===selfDiagnosisItem.piping.testType">
            <label for="pipingTest" class="filterLabel" style="width:5.3em;">{{ selfDiagnosisItem.piping.name }}</label>
            <input type="radio" class="hemodilutionTest" id="hemodilutionTest" name="self"
                   @click='setTestType(selfDiagnosisItem.hemodilution.testType);' :checked="testType===selfDiagnosisItem.hemodilution.testType">
            <label for="hemodilutionTest" class="filterLabel" style="width:5.3em;">{{ selfDiagnosisItem.hemodilution.name }}</label>
          </div>
          <div style="position:relative;overflow-y:auto;height:calc(100% - 25px);">
            <table class="table-self-diagnosis" style="position:absolute;top:0;left:0;border-collapse:collapse;z-index:200;" area-hidden="true">
              <thead style="display:table-caption;">
                <tr class='ntss-list-header-tr'>
                  <th id="eventRegTimeHeader" class="ntss-list-header-th" rowspan="2" style="height:54px;padding-left:8px;padding-right:8px;visibility:visible">{{ ufrcItem.dataTime.name }}</th>
                </tr>
              </thead>
            </table>
            <div v-if="!isDab" :id="dataTypeItem.testResults.tableId" :onscroll="setOnScroll(dataTypeItem.testResults.tableId)"
                style="height:100%;overflow-y:auto;width:fit-content;max-width:100%;">
              <!-- testType=1(配管)のレイアウト -->
              <!-- // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong start -->
              <table v-if="testType === selfDiagnosisItem.ufrc.testType" class="table-self-diagnosis" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, ufrcItemKey) in ufrcItem' :key='ufrcItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(ufrcItemKey)" class="ntss-list-header-th"
                        :id="ufrcItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}<br />{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, ufrcKey) in ufrc' :key='ufrcKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="ufrcItem.dataTime.className"
                        style="text-align:center" :style="{ width:ufrcItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[ufrcItem.result.jsonAddress], arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                    <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start -->
                    <!-- <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.result.className, ufrcItem.result.jsonAddress, convertSelfDiagnosisResult(testType, content.result[ufrcItem.result.jsonAddress]))"
                        style="text-align:right" :style="{ width:ufrcItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[ufrcItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[ufrcItem.result.jsonAddress]) }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.negativePipeLeakage.className, ufrcItem.negativePipeLeakage.jsonAddress, content.result[ufrcItem.negativePipeLeakage.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.negativePipeLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.negativePipeLeakage.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.positivePipeLeakage.className, ufrcItem.positivePipeLeakage.jsonAddress, content.result[ufrcItem.positivePipeLeakage.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.positivePipeLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.positivePipeLeakage.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.cfLeakage.className, ufrcItem.cfLeakage.jsonAddress, content.result[ufrcItem.cfLeakage.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.cfLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.cfLeakage.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.cf2Leakage.className, ufrcItem.cf2Leakage.jsonAddress, content.result[ufrcItem.cf2Leakage.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.cf2Leakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.cf2Leakage.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.removal.className, ufrcItem.removal.jsonAddress, content.result[ufrcItem.removal.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.removal.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.removal.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcItem.balance.className, ufrcItem.balance.jsonAddress, content.result[ufrcItem.balance.jsonAddress])"
                        style="text-align:right" :style="{ width:ufrcItem.balance.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.balance.jsonAddress] }}</td> -->
                    <!-- mod #9241 by zhangruixue 2023-08-01 --start  -->
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.result.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.result.className, ufrcItem.result.jsonAddress, convertSelfDiagnosisResult(testType, content.result[ufrcItem.result.jsonAddress]), content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[ufrcItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[ufrcItem.result.jsonAddress]) }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.negativePipeLeakage.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.negativePipeLeakage.className, ufrcItem.negativePipeLeakage.jsonAddress, content.result[ufrcItem.negativePipeLeakage.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.negativePipeLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.negativePipeLeakage.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.positivePipeLeakage.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.positivePipeLeakage.className, ufrcItem.positivePipeLeakage.jsonAddress, content.result[ufrcItem.positivePipeLeakage.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.positivePipeLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.positivePipeLeakage.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.cfLeakage.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.cfLeakage.className, ufrcItem.cfLeakage.jsonAddress, content.result[ufrcItem.cfLeakage.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.cfLeakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.cfLeakage.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.cf2Leakage.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.cf2Leakage.className, ufrcItem.cf2Leakage.jsonAddress, content.result[ufrcItem.cf2Leakage.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.cf2Leakage.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.cf2Leakage.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.removal.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.removal.className, ufrcItem.removal.jsonAddress, content.result[ufrcItem.removal.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.removal.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.removal.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(ufrcItem.balance.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(ufrcKey,ufrcItem.balance.className, ufrcItem.balance.jsonAddress, content.result[ufrcItem.balance.jsonAddress], content.recordNo, content.testResultData)"
                        style="text-align:right" :style="{ width:ufrcItem.balance.bodyWidth + 'px'}">
                        {{ content.result[ufrcItem.balance.jsonAddress] }}</td>
                    <!-- mod #9241 by zhangruixue 2023-08-01 --end  -->
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end -->
                  </tr>
                </tbody>
              </table>
              <!-- testType=2(漏血)のレイアウト -->
              <table class="table-self-diagnosis" v-if="testType === selfDiagnosisItem.bloodLeakage.testType" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, bloodLeakageItemKey) in bloodLeakageItem' :key='bloodLeakageItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(bloodLeakageItemKey)" class="ntss-list-header-th"
                        :id="bloodLeakageItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}{{ column.space }}{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, bloodLeakageKey) in bloodLeakage' :key='bloodLeakageKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="bloodLeakageItem.dataTime.className"
                        style="text-align:center" :style="{ width:bloodLeakageItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, "", arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start -->
                     <!-- <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(bloodLeakageItem.voltageRed.className, bloodLeakageItem.voltageRed.jsonAddress, content.result[bloodLeakageItem.voltageRed.jsonAddress])"
                        style="text-align:right" :style="{ width:bloodLeakageItem.voltageRed.bodyWidth + 'px'}">
                        {{ content.result[bloodLeakageItem.voltageRed.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(bloodLeakageItem.voltageGreen.className, bloodLeakageItem.voltageGreen.jsonAddress, content.result[bloodLeakageItem.voltageGreen.jsonAddress])"
                        style="text-align:right" :style="{ width:bloodLeakageItem.voltageGreen.bodyWidth + 'px'}">
                        {{ content.result[bloodLeakageItem.voltageGreen.jsonAddress] }}</td> -->
                    <!-- mod #9241 by zhangruixue 2023-08-01 --start  -->
                    <td v-if="isSelfMeasureItemVisible(bloodLeakageItem.voltageRed.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(bloodLeakageKey,bloodLeakageItem.voltageRed.className, bloodLeakageItem.voltageRed.jsonAddress, content.result[bloodLeakageItem.voltageRed.jsonAddress], content.recordNo)"
                        style="text-align:right" :style="{ width:bloodLeakageItem.voltageRed.bodyWidth + 'px'}">
                        {{ content.result[bloodLeakageItem.voltageRed.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(bloodLeakageItem.voltageGreen.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(bloodLeakageKey,bloodLeakageItem.voltageGreen.className, bloodLeakageItem.voltageGreen.jsonAddress, content.result[bloodLeakageItem.voltageGreen.jsonAddress], content.recordNo)"
                        style="text-align:right" :style="{ width:bloodLeakageItem.voltageGreen.bodyWidth + 'px'}">
                        {{ content.result[bloodLeakageItem.voltageGreen.jsonAddress] }}</td>
                    <!-- mod #9241 by zhangruixue 2023-08-01 --end  -->
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end -->
                  </tr>
                </tbody>
              </table>
              <!-- testType=3(透析液流量)のレイアウト -->
              <table class="table-self-diagnosis" v-if="testType === selfDiagnosisItem.dialysateFlowRate.testType" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, dialysateFlowRateItemKey) in dialysateFlowRateItem' :key='dialysateFlowRateItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(dialysateFlowRateItemKey)" class="ntss-list-header-th"
                        :id="dialysateFlowRateItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}{{ column.space }}{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, dialysateFlowRateKey) in dialysateFlowRate' :key='dialysateFlowRateKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="dialysateFlowRateItem.dataTime.className"
                        style="text-align:center" :style="{ width:dialysateFlowRateItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, "", arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start -->
                     <!-- <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(dialysateFlowRateItem.dialysateFlowRate.className, dialysateFlowRateItem.dialysateFlowRate.jsonAddress, content.result[dialysateFlowRateItem.dialysateFlowRate.jsonAddress])"
                        style="text-align:right" :style="{ width:dialysateFlowRateItem.dialysateFlowRate.bodyWidth + 'px'}">
                        {{ content.result[dialysateFlowRateItem.dialysateFlowRate.jsonAddress] }}</td> -->
                    <!-- mod #9241 by zhangruixue 2023-08-01 --start  -->
                    <td v-if="isSelfMeasureItemVisible(dialysateFlowRateItem.dialysateFlowRate.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(dialysateFlowRateKey,dialysateFlowRateItem.dialysateFlowRate.className, dialysateFlowRateItem.dialysateFlowRate.jsonAddress, content.result[dialysateFlowRateItem.dialysateFlowRate.jsonAddress], content.recordNo)"
                        style="text-align:right" :style="{ width:dialysateFlowRateItem.dialysateFlowRate.bodyWidth + 'px'}">
                        {{ content.result[dialysateFlowRateItem.dialysateFlowRate.jsonAddress] }}</td>
                    <!-- mod #9241 by zhangruixue 2023-08-01 --end  -->
                    <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end -->
                  </tr>
                </tbody>
              </table>
              <!-- testType=4(濃度)のレイアウト -->
              <table class="table-self-diagnosis" v-if="testType === selfDiagnosisItem.concentration.testType" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, concentrationItemKey) in concentrationItem' :key='concentrationItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(concentrationItemKey)" class="ntss-list-header-th"
                        :id="concentrationItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}{{ column.space }}{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, concentrationKey) in concentration' :key='concentrationKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="concentrationItem.dataTime.className"
                        style="text-align:center" :style="{ width:concentrationItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[concentrationItem.result.jsonAddress], arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start -->
                        <!-- <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationItem.result.className, concentrationItem.result.jsonAddress, convertSelfDiagnosisResult(testType, content.result[concentrationItem.result.jsonAddress]))"
                        style="text-align:right" :style="{ width:concentrationItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[concentrationItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[concentrationItem.result.jsonAddress]) }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationItem.dialysateB.className, concentrationItem.dialysateB.jsonAddress, content.result[concentrationItem.dialysateB.jsonAddress])"
                        style="text-align:right" :style="{ width:concentrationItem.dialysateB.bodyWidth + 'px'}">
                        {{ content.result[concentrationItem.dialysateB.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationItem.dialysateA.className, concentrationItem.dialysateA.jsonAddress, content.result[concentrationItem.dialysateA.jsonAddress])"
                        style="text-align:right" :style="{ width:concentrationItem.dialysateA.bodyWidth + 'px'}">
                        {{ content.result[concentrationItem.dialysateA.jsonAddress] }}</td> -->
                    <!-- mod #9241 by zhangruixue 2023-08-01 --start  -->
                    <td v-if="isSelfMeasureItemVisible(concentrationItem.result.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationKey,concentrationItem.result.className, concentrationItem.result.jsonAddress, convertSelfDiagnosisResult(testType, content.result[concentrationItem.result.jsonAddress]), content.recordNo)"
                        style="text-align:right" :style="{ width:concentrationItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[concentrationItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[concentrationItem.result.jsonAddress]) }}</td>
                    <td v-if="isSelfMeasureItemVisible(concentrationItem.dialysateB.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationKey,concentrationItem.dialysateB.className, concentrationItem.dialysateB.jsonAddress, content.result[concentrationItem.dialysateB.jsonAddress], content.recordNo)"
                        style="text-align:right" :style="{ width:concentrationItem.dialysateB.bodyWidth + 'px'}">
                        {{ content.result[concentrationItem.dialysateB.jsonAddress]}}</td>
                    <td v-if="isSelfMeasureItemVisible(concentrationItem.dialysateA.jsonAddress)" class='ntss-list-body-td' :class="chkSelfMeasureResultInfo(concentrationKey,concentrationItem.dialysateA.className, concentrationItem.dialysateA.jsonAddress, content.result[concentrationItem.dialysateA.jsonAddress], content.recordNo)"
                        style="text-align:right" :style="{ width:concentrationItem.dialysateA.bodyWidth + 'px'}">
                        {{ content.result[concentrationItem.dialysateA.jsonAddress] }}</td>
                    <!-- mod #9241 by zhangruixue 2023-08-01 --end  -->
                        <!-- mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end -->
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else :id="dataTypeItem.testResults.tableId" :onscroll="setOnScroll(dataTypeItem.testResults.tableId)"
                 style="height:100%;overflow-y:auto;width:fit-content;max-width:100%;">
              <!-- testType=5(配管テスト)のレイアウト -->
              <table class="table-self-diagnosis" v-if="testType === selfDiagnosisItem.piping.testType" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, pipingTestItemKey) in pipingTestItem' :key='pipingTestItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(pipingTestItemKey)" class="ntss-list-header-th"
                        :id="pipingTestItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}<br />{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, pipingKey) in piping' :key='pipingKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="pipingTestItem.dataTime.className"
                        style="text-align:center" :style="{ width:pipingTestItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[pipingTestItem.result.jsonAddress], arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.result.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.result.className"
                        style="text-align:right" :style="{ width:pipingTestItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[pipingTestItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[pipingTestItem.result.jsonAddress]) }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.supplyPressure.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.supplyPressure.className"
                        style="text-align:right" :style="{ width:pipingTestItem.supplyPressure.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.supplyPressure.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.dialysateFlowPressureLow.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.dialysateFlowPressureLow.className"
                        style="text-align:right" :style="{ width:pipingTestItem.dialysateFlowPressureLow.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.dialysateFlowPressureLow.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.dialysateFlowPressureHigh.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.dialysateFlowPressureHigh.className"
                        style="text-align:right" :style="{ width:pipingTestItem.dialysateFlowPressureHigh.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.dialysateFlowPressureHigh.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.concentrationCell3.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.concentrationCell3.className"
                        style="text-align:right" :style="{ width:pipingTestItem.concentrationCell3.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.concentrationCell3.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.concentrationCell4.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.concentrationCell4.className"
                        style="text-align:right" :style="{ width:pipingTestItem.concentrationCell4.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.concentrationCell4.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.judgementTermInjection.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.judgementTermInjection.className"
                        style="text-align:right" :style="{ width:pipingTestItem.judgementTermInjection.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.judgementTermInjection.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(pipingTestItem.judgementTermDrainage.jsonAddress)" class='ntss-list-body-td' :class="pipingTestItem.judgementTermDrainage.className"
                        style="text-align:right" :style="{ width:pipingTestItem.judgementTermDrainage.bodyWidth + 'px'}">
                        {{ content.result[pipingTestItem.judgementTermDrainage.jsonAddress] }}</td>
                  </tr>
                </tbody>
              </table>
              <!-- testType=6(希釈テスト)のレイアウト -->
              <table class="table-self-diagnosis" v-if="testType === selfDiagnosisItem.hemodilution.testType" style="position:inherit;">
                <thead class="header-sticky" style="display:block;z-index:100;">
                  <tr class='ntss-list-header-tr' style="display:block;">
                    <th v-for='(column, hemodilutionTestItemKey) in hemodilutionTestItem' :key='hemodilutionTestItemKey'
                        v-if="!column.jsonAddress || isSelfMeasureItemVisible(column.jsonAddress)"
                        :class="setDataTimeClass(hemodilutionTestItemKey)" class="ntss-list-header-th"
                        :id="hemodilutionTestItemKey"
                        style="padding-left:8px;padding-right:8px;">{{ column.name }}<br />{{ column.unit }}</th>
                  </tr>
                </thead>
                <tbody style="display:block;word-break:break-word;">
                  <tr v-for='(content, hemodilutionKey) in hemodilution' :key='hemodilutionKey'
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="hemodilutionTestItem.dataTime.className"
                        style="text-align:center" :style="{ width:hemodilutionTestItem.dataTime.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[hemodilutionTestItem.result.jsonAddress], arguments[0])'>
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                    <td v-if="isSelfMeasureItemVisible(hemodilutionTestItem.result.jsonAddress)" class='ntss-list-body-td' :class="hemodilutionTestItem.result.className"
                        style="text-align:right" :style="{ width:hemodilutionTestItem.result.bodyWidth + 'px'}"
                        @click='clickResultCol(testType, content.eventRegDate, content.eventRegTime, content.result[hemodilutionTestItem.result.jsonAddress], arguments[0])'>
                        {{ convertSelfDiagnosisResult(testType, content.result[hemodilutionTestItem.result.jsonAddress]) }}</td>
                    <td v-if="isSelfMeasureItemVisible(hemodilutionTestItem.concentrationB.jsonAddress)" class='ntss-list-body-td' :class="hemodilutionTestItem.concentrationB.className"
                        style="text-align:right" :style="{ width:hemodilutionTestItem.concentrationB.bodyWidth + 'px'}">
                        {{ content.result[hemodilutionTestItem.concentrationB.jsonAddress] }}</td>
                    <td v-if="isSelfMeasureItemVisible(hemodilutionTestItem.concentrationDialysate.jsonAddress)" class='ntss-list-body-td' :class="hemodilutionTestItem.concentrationDialysate.className"
                        style="text-align:right" :style="{ width:hemodilutionTestItem.concentrationDialysate.bodyWidth + 'px'}">
                        {{ content.result[hemodilutionTestItem.concentrationDialysate.jsonAddress] }}</td>
                  </tr>
                  <!-- // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong end -->
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <!-- 自己診断（グラフ） -->
        <div v-else style="height:calc(100% - 2.3em);">
          <div>
            <div class='div-self-diagnosis-type-area'>
              <input type="radio" class="threeMonths" id="threeMonths" name="period"
                     @click='switchPeriod(12, "self")' :checked="displayPeriod===12">
              <label for="threeMonths" class="filterLabel" style="width:4em;">３ヶ月</label>
              <input type="radio" class="sixMonths" id="sixMonths" name="period"
                     @click='switchPeriod(24, "self")' :checked="displayPeriod===24">
              <label for="sixMonths" class="filterLabel" style="width:4em;">６ヶ月</label>
              <input type="radio" class="oneYear" id="oneYear" name="period"
                     @click='switchPeriod(48, "self")' :checked="displayPeriod===48">
              <label for="oneYear" class="filterLabel" style="width:4em;">１&emsp;年</label>
            </div>
          </div>
          <div v-if='testType===selfDiagnosisItem.ufrc.testType || testType===selfDiagnosisItem.bloodLeakage.testType ||
                     testType===selfDiagnosisItem.dialysateFlowRate.testType || testType===selfDiagnosisItem.concentration.testType'
               class="div-scroll">
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="ufrcLeakageGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="otherUfrcGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="bloodLeakageGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="dialysateFlowRateGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="selfDiagnosisConcentrationGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
          </div>
          <div v-else class="div-scroll">
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="pipingTestPressureGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="pipingTestConcentrationCellGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="judgementTermGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.testResults.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.testResults.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="hemodilutionTestGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
          </div>
        </div>
      </v-ons-col>
    </v-ons-row>
    <!-- dataType=5(溶解記録)の画面 -->
    <v-ons-row v-if="motionRecordDetail.dataType === dataTypeItem.dissolutions.dataType && !isDry50A"  class='ntss-list'>
      <v-ons-col class="machine-record-detail-base data-type" style="height: calc(100% - 2px);">
        <!-- タイトル と表、グラフの切替ボタンのエリア -->
        <div style="height:2.3em;">
          <div class='div-title' style="float:left">{{ dataTypeItem.dissolutions.name }}</div>
          <div style="float:right;">
            <input type="radio" class="icon-tacle" id="icon-tacle" name="icon" @click='switchViewMode(true)' :checked="isTable">
            <label for="icon-tacle" style="display:block;float:left;">
              <v-ons-icon icon="fa-th-list" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
            <input type="radio" class="icon-draph" style="padding-left:5px;" id="icon-draph" name="icon" @click='switchViewMode(false)' :checked="!isTable">
            <label for="icon-draph" style="display:block;float:left;margin-left:15px;">
              <v-ons-icon icon="fa-chart-line" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
          </div>
        </div>
        <!-- 溶解記録（表形式） -->
        <div v-if="isTable" style="height:calc(100% - 2.3em);">
          <div style="position:relative;height:100%;width:100%;">
            <div :id="dataTypeItem.dissolutions.tableId" class='main-content-area' style="-webkit-overflow-scrolling:touch;width:fit-content;max-width:100%;"
                 @scroll="setOnScroll(dataTypeItem.dissolutions.tableId)">
              <table class="table-self-diagnosis" style="position:static;">
                <thead>
                  <tr id="sticky-position-base">
                    <th v-for='(column, dissolutionItemKey) in dissolutionItem'
                        :key='dissolutionItemKey'
                        :class="setDataTimeClass(dissolutionItemKey)"
                        class="ntss-list-header-th-sticky"
                        :rowspan="column.rowspan"
                        :colspan="column.colspan"
                        style="text-align:center;">{{ displayDissolutionHeaderName(column) }}</th>
                  </tr>
                  <tr>
                    <th v-for='(column, dissolutionItemKey) in displayDissolutionSecondHeaderName(dissolutionItem)'
                        :key='dissolutionItemKey'
                        class="ntss-list-header-th-sticky"
                        style="text-align:center;" :style="stickyPositionSize">{{ column.name }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for='(content, dissolutionsKey) in dissolutions' :key='dissolutionsKey'
                      v-if="convertDissolutionResult(content.result[dissolutionItem.result.jsonAddressB]) !== ''"
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="dissolutionItem.dataTime.className"
                        style="text-align:center;" :style="{ width:dissolutionItem.dataTime.bodyWidth + 'px'}">
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.dissolutionCnt.className"
                        style="text-align:center;white-space:nowrap" :style="{ width:dissolutionItem.dissolutionCnt.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.dissolutionCnt.jsonAddress] }}回目</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.result.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.result.bodyWidth + 'px'}">
                        {{ convertDissolutionResult(content.result[dissolutionItem.result.jsonAddressB]) }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.result.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.result.bodyWidth + 'px'}">
                        {{ convertDissolutionResult(content.result[dissolutionItem.result.jsonAddressA]) }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.concentration.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.concentration.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.concentration.jsonAddressB] }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.concentration.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.concentration.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.concentration.jsonAddressA] }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.temperature.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.temperature.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.temperature.jsonAddressB] }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.temperature.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.temperature.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.temperature.jsonAddressA] }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.dissolutionTime.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.dissolutionTime.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.dissolutionTime.jsonAddressB] }}</td>
                    <td class='ntss-list-body-td' :class="dissolutionItem.dissolutionTime.className"
                        style="text-align:right;" :style="{ width:dissolutionItem.dissolutionTime.bodyWidth + 'px'}">
                        {{ content.result[dissolutionItem.dissolutionTime.jsonAddressA] }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <!-- 溶解記録（グラフ） -->
        <div v-else style="height:calc(100% - 2.3em);">
          <div class='div-self-diagnosis-type-area'>
            <ol class='ol-self-diagnosis-type'>
              <li>
                <input type="radio" class="tweWeeks" id="tweWeeks" name="self"
                       @click='switchPeriod(2, "dissolution")' :checked="displayPeriod===2">
                <label for="tweWeeks" class="filterLabel" style="width:4em;">２週間</label>
                <input type="radio" class="oneMonths" id="oneMonths" name="self"
                       @click='switchPeriod(4, "dissolution")' :checked="displayPeriod===4">
                <label for="oneMonths" class="filterLabel" style="width:4em;">１ヶ月</label>
              </li>
            </ol>
          </div>
          <div class="div-scroll">
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.dissolutions.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.dissolutions.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="concentrationGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.dissolutions.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.dissolutions.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="temperatureGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.dissolutions.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.dissolutions.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="dissolutionTimeGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
          </div>
        </div>
      </v-ons-col>
    </v-ons-row>
    <!-- DRY-50A溶解記録の画面 -->
    <v-ons-row v-if="motionRecordDetail.dataType === dataTypeItem.dissolutions.dataType && isDry50A"  class='ntss-list'>
      <v-ons-col class="machine-record-detail-base data-type" style="height: calc(100% - 2px);">
        <!-- タイトル と表、グラフの切替ボタンのエリア -->
        <div style="height:2.3em;">
          <div class='div-title' style="float:left">{{ "DRY-50A" + dataTypeItem.dissolutions.name }}</div>
          <div style="float:right;">
            <input type="radio" class="icon-tacle" id="icon-tacle" name="icon" @click='switchViewMode(true)' :checked="isTable">
            <label for="icon-tacle" style="display:block;float:left;">
              <v-ons-icon icon="fa-th-list" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
            <input type="radio" class="icon-draph" style="padding-left:5px;" id="icon-draph" name="icon" @click='switchViewMode(false)' :checked="!isTable">
            <label for="icon-draph" style="display:block;float:left;margin-left:15px;">
              <v-ons-icon icon="fa-chart-line" size='2.0em' class='list-chart-icon' style="pointer-events: none;" />
            </label>
          </div>
        </div>
        <!-- 溶解記録（表形式） -->
        <div v-if="isTable" style="height:calc(100% - 2.3em);">
          <div style="position:relative;height:100%;width:100%;">
            <div :id="dataTypeItem.dissolutions.tableId" class='main-content-area' style="-webkit-overflow-scrolling:touch;width:fit-content;max-width:100%;"
                 @scroll="setOnScroll(dataTypeItem.dissolutions.tableId)">
              <table class="table-self-diagnosis" style="position:static;">
                <thead>
                  <tr id="sticky-position-base">
                    <th v-for='(column, dissolutionItemKey) in dry50ADissolutionItem'
                        :key='dissolutionItemKey'
                        :class="setDataTimeClass(dissolutionItemKey)"
                        class="ntss-list-header-th-sticky"
                        style="text-align:center;">{{ displayDissolutionHeaderName(column) }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for='(content, dissolutionsKey) in dissolutions' :key='dissolutionsKey'
                      v-if="convertDissolutionResult(content.result[dry50ADissolutionItem.result.jsonAddress]) !== ''"
                      class="ntss-list-body-tr">
                    <td class='ntss-list-body-td col-sticky' :class="dry50ADissolutionItem.dataTime.className"
                        style="text-align:center;" :style="{ width:dry50ADissolutionItem.dataTime.bodyWidth + 'px'}">
                        {{ convertDateFormat(content.eventRegDate) }}<br />{{ convertDateFormat(content.eventRegTime) }}</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.dissolutionCnt.className"
                        style="text-align:center;white-space:nowrap" :style="{ width:dry50ADissolutionItem.dissolutionCnt.bodyWidth + 'px'}">
                        {{ content.result[dry50ADissolutionItem.dissolutionCnt.jsonAddress] }}回目</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.result.className"
                        style="text-align:right;" :style="{ width:dry50ADissolutionItem.result.bodyWidth + 'px'}">
                        {{ convertDissolutionResult(content.result[dry50ADissolutionItem.result.jsonAddress]) }}</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.tareCnt.className"
                        style="text-align:right;" :style="{ width:dry50ADissolutionItem.tareCnt.bodyWidth + 'px'}">
                        {{ content.result[dry50ADissolutionItem.tareCnt.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.concentration.className"
                        style="text-align:right;" :style="{ width:dry50ADissolutionItem.concentration.bodyWidth + 'px'}">
                        {{ content.result[dry50ADissolutionItem.concentration.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.temperature.className"
                        style="text-align:right;" :style="{ width:dry50ADissolutionItem.temperature.bodyWidth + 'px'}">
                        {{ content.result[dry50ADissolutionItem.temperature.jsonAddress] }}</td>
                    <td class='ntss-list-body-td' :class="dry50ADissolutionItem.waterFlowRate.className"
                        style="text-align:right;" :style="{ width:dry50ADissolutionItem.waterFlowRate.bodyWidth + 'px'}">
                        {{ content.result[dry50ADissolutionItem.waterFlowRate.jsonAddress] }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <!-- 溶解記録（グラフ） -->
        <div v-else style="height:calc(100% - 2.3em);">
          <div class='div-self-diagnosis-type-area'>
            <ol class='ol-self-diagnosis-type'>
              <li>
                <input type="radio" class="tweWeeks" id="tweWeeks" name="self"
                       @click='switchPeriod(2, "dissolution")' :checked="displayPeriod===2">
                <label for="tweWeeks" class="filterLabel" style="width:4em;">２週間</label>
                <input type="radio" class="oneMonths" id="oneMonths" name="self"
                       @click='switchPeriod(4, "dissolution")' :checked="displayPeriod===4">
                <label for="oneMonths" class="filterLabel" style="width:4em;">１ヶ月</label>
              </li>
            </ol>
          </div>
          <div class="div-scroll">
            <div class="cont" id="cont">
              <v-touch v-on:swiperight="onSwipeRight(dataTypeItem.dissolutions.dataType)"
                        v-on:swipeleft="onSwipeLeft(dataTypeItem.dissolutions.dataType)"
                       v-bind:swipe-options="{ direction:'horizontal', threshold:50 }">
                <highcharts :options="dry50AGraphData" ref="lineCharts"></highcharts>
              </v-touch>
            </div>
          </div>
        </div>
      </v-ons-col>
    </v-ons-row>
    <!-- dataType=6(データファイル収集)の画面 -->
    <div v-if="motionRecordDetail.dataType === dataTypeItem.dataCollection.dataType" class="machine-record-detail-base data-type">
      <div style="overflow:hidden;height:95%;overflow-y:auto;">
        <div class='div-title'>{{ dataTypeItem.dataCollection.name }}</div>
        <div class='div-title'>{{ motionRecordDetail.eventRegDate }}&emsp;{{ motionRecordDetail.eventRegTime }}</div>
        <div class='div-title'>実行者：{{ motionRecordDetail.userName }}</div>
        <div class='div-content'>{{ motionRecordDetail.machineRecordMessage }}</div>
        <div v-if='motionRecordDetail.fileData' class='div-title'>{{ motionRecordDetail.fileData.filename }}</div>
        <div v-if='motionRecordDetail.fileData' class='div-title' @click='setDownloadData' style="margin:5px;">
          <v-ons-icon icon="fa-download" size='1.5em'>ダウンロード</v-ons-icon>
        </div>
      </div>
    </div>
    <v-ons-popover cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target="false"
                   :class="[fontSizeSet, 'mrd-self-measure-result-popover']"
                   >
      <div style='margin:5px;'>
        <div style="font-size:2.0em">
          <div>{{ popoverEventDate }}</div>
          {{ getResultMessage(popoverTestType, popoverResultCd) }}
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import Vue from "vue";
import VueHighcharts from "vue-highcharts";
import VueTouch from "vue-touch";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import {
  SERVICE_SUPPORT
} from "@/constants/operationViewerCommon";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
// add #11065 【03】編集権限バグ修正 関 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #11065 【03】編集権限バグ修正 関 end

Vue.use(VueHighcharts);
Vue.use(VueTouch);
Boost(Highcharts);

// jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）
const $$ = require("jquery");

export default {
  mixins: [PopoverMixin],
  components: {
    VueHighcharts,
    VueTouch
  },
  title: "装置記録詳細",
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down up",
      popoverTestType: 1,
      popoverEventDate: "",
      popoverResultCd: "",
      detailInfoTitle: "詳細情報",
      emailNameTitle: "メール送付先",
      emailTextTitle: "メール本文",
      isUpdating: false,
      // 対処ボタン表示名
      correctionButtonName: {
        0: "未実施",
        1: "実施済"
      },
      // dataType項目名
      dataTypeItem: {
        machineRecord: {
          name: "装置記録",
          dataType: 1
        },
        mNotice: {
          name: "警報通知",
          dataType: 2
        },
        preventive: {
          name: "予防保全/故障予知",
          dataType: 3
        },
        testResults: {
          name: "自己診断",
          dataType: 4,
          tableId: "testResultsTableId"
        },
        dissolutions: {
          name: "溶解記録",
          dataType: 5,
          tableId: "dissolutionsTableId"
        },
        dataCollection: {
          name: "データファイル収集",
          dataType: 6
        }
      },
      // 自己診断項目名
      selfDiagnosisItem: {
        ufrc: {
          name: "配管",
          testType: 1
        },
        bloodLeakage: {
          name: "漏血",
          testType: 2
        },
        dialysateFlowRate: {
          name: "透析液流量",
          testType: 3
        },
        concentration: {
          name: "濃度",
          testType: 4
        },
        piping: {
          name: "配管テスト",
          testType: 5
        },
        hemodilution: {
          name: "希釈テスト",
          testType: 6
        }
      },
      // 配管自己診断結果アイテム
      ufrcItem: {
        dataTime: {
          name: "  日時  ",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        result: {
          name: " 結果 ",
          jsonAddress: "47",
          className: "resultBody",
          bodyWidth: ""
        },
        negativePipeLeakage: {
          name: "配管漏れ(陰圧)",
          unit: "mmHg",
          jsonAddress: "43",
          className: "negativePipeLeakageBody",
          bodyWidth: ""
        },
        positivePipeLeakage: {
          name: "配管漏れ(陽圧)",
          unit: "mmHg",
          jsonAddress: "44",
          className: "positivePipeLeakageBody",
          bodyWidth: ""
        },
        cfLeakage: {
          name: "ＣＦ漏れ",
          unit: "mmHg",
          jsonAddress: "45",
          className: "cfLeakageBody",
          bodyWidth: ""
        },
        cf2Leakage: {
          name: "ＣＦ２漏れ",
          unit: "mmHg",
          jsonAddress: "49",
          className: "cf2LeakageBody",
          bodyWidth: ""
        },
        removal: {
          name: "除水",
          unit: "mmHg",
          jsonAddress: "48",
          className: "removalBody",
          bodyWidth: ""
        },
        balance: {
          name: "バランス",
          unit: "mmHg",
          jsonAddress: "46",
          className: "balanceBody",
          bodyWidth: ""
        }
      },
      // 漏血自己診断結果アイテム
      bloodLeakageItem: {
        dataTime: {
          name: "  日時  ",
          space: "",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        voltageRed: {
          name: "赤電圧",
          unit: "V",
          space: "　",
          jsonAddress: "53",
          className: "voltageRedBody",
          bodyWidth: ""
        },
        voltageGreen: {
          name: "緑電圧",
          unit: "V",
          space: "　",
          jsonAddress: "54",
          className: "voltageGreenBody",
          bodyWidth: ""
        }
      },
      // 透析液流量自己診断結果アイテム
      dialysateFlowRateItem: {
        dataTime: {
          name: "  日時  ",
          space: "",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        dialysateFlowRate: {
          name: "透析液流量",
          unit: "mL/min",
          space: "　",
          jsonAddress: "58",
          className: "dialysateFlowRateBody",
          bodyWidth: ""
        }
      },
      // 濃度自己診断結果アイテム
      concentrationItem: {
        dataTime: {
          name: "  日時  ",
          space: "",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        result: {
          name: " 結果 ",
          space: "",
          jsonAddress: "65",
          className: "resultBody",
          bodyWidth: ""
        },
        dialysateB: {
          name: "Ｂ原液",
          unit: "％",
          space: "　",
          jsonAddress: "63",
          className: "dialysateBBody",
          bodyWidth: ""
        },
        dialysateA: {
          name: "透析液",
          unit: "％",
          space: "　",
          jsonAddress: "64",
          className: "dialysateABody",
          bodyWidth: ""
        }
      },
      // 配管テスト結果アイテム
      pipingTestItem: {
        dataTime: {
          name: "  日時  ",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        result: {
          name: " 結果 ",
          jsonAddress: "6",
          className: "resultBody",
          bodyWidth: ""
        },
        supplyPressure: {
          name: "給水圧",
          unit: "kPa",
          jsonAddress: "7",
          className: "supplyPressureBody",
          bodyWidth: ""
        },
        dialysateFlowPressureLow: {
          name: "送液圧低",
          unit: "kPa",
          jsonAddress: "8",
          className: "dialysateFlowPressureLowBody",
          bodyWidth: ""
        },
        dialysateFlowPressureHigh: {
          name: "送液圧高",
          unit: "kPa",
          jsonAddress: "9",
          className: "dialysateFlowPressureHighBody",
          bodyWidth: ""
        },
        concentrationCell3: {
          name: "濃度セル３",
          unit: "mS/cm",
          jsonAddress: "10",
          className: "concentrationCell3Body",
          bodyWidth: ""
        },
        concentrationCell4: {
          name: "濃度セル４",
          unit: "mS/cm",
          jsonAddress: "11",
          className: "concentrationCell4Body",
          bodyWidth: ""
        },
        judgementTermInjection: {
          name: "注水判定時間",
          unit: "秒",
          jsonAddress: "1",
          className: "judgementTermInjectionBody",
          bodyWidth: ""
        },
        judgementTermDrainage: {
          name: "排液判定時間",
          unit: "秒",
          jsonAddress: "5",
          className: "judgementTermDrainageBody",
          bodyWidth: ""
        }
      },
      // 希釈テスト結果アイテム
      hemodilutionTestItem: {
        dataTime: {
          name: "  日時  ",
          className: "dataTimeBody",
          bodyWidth: ""
        },
        result: {
          name: " 結果 ",
          jsonAddress: "6",
          className: "resultBody",
          bodyWidth: ""
        },
        concentrationB: {
          name: "Ｂ液濃度",
          unit: "mS/cm",
          jsonAddress: "4",
          className: "concentrationBBody",
          bodyWidth: ""
        },
        concentrationDialysate: {
          name: "透析液濃度",
          unit: "mS/cm",
          jsonAddress: "5",
          className: "concentrationDialysateBody",
          bodyWidth: ""
        }
      },
      // 溶解記録アイテム
      dissolutionItem: {
        dataTime: {
          name: "日時",
          unit: "",
          rowspan: 2,
          colspan: 1,
          className: "dissolutionItemBody",
          bodyWidth: ""
        },
        dissolutionCnt: {
          name: "溶解",
          unit: "回数",
          rowspan: 2,
          colspan: 1,
          address: 5,
          jsonAddress: 5,
          className: "dissolutionCntBody",
          bodyWidth: ""
        },
        result: {
          name: "溶解判定",
          unit: "",
          rowspan: 1,
          colspan: 2,
          jsonAddressB: 12,
          jsonAddressA: 13,
          className: "resultBody",
          bodyWidth: ""
        },
        concentration: {
          name: "液濃度",
          unit: "mS/cm",
          rowspan: 1,
          colspan: 2,
          jsonAddressB: 8,
          jsonAddressA: 9,
          className: "concentrationBody",
          bodyWidth: ""
        },
        temperature: {
          name: "液温度",
          unit: "℃",
          rowspan: 1,
          colspan: 2,
          jsonAddressB: 10,
          jsonAddressA: 11,
          className: "temperatureBody",
          bodyWidth: ""
        },
        dissolutionTime: {
          name: "溶解時間",
          unit: "秒",
          rowspan: 1,
          colspan: 2,
          jsonAddressB: 6,
          jsonAddressA: 7,
          className: "dissolutionTimeBody",
          bodyWidth: ""
        }
      },
      // DRY-50A溶解記録アイテム
      dry50ADissolutionItem: {
        dataTime: {
          name: "日時",
          unit: "",
          className: "dissolutionItemBody",
          bodyWidth: ""
        },
        dissolutionCnt: {
          name: "溶解",
          unit: "回数",
          jsonAddress: 5,
          className: "dissolutionCntBody",
          bodyWidth: ""
        },
        result: {
          name: "濃度判定",
          unit: "",
          jsonAddress: 9,
          className: "resultBody",
          bodyWidth: ""
        },
        tareCnt: {
          name: "袋数",
          unit: "",
          jsonAddress: 6,
          className: "tareCntBody",
          bodyWidth: ""
        },
        concentration: {
          name: "濃度",
          unit: "mS/cm",
          jsonAddress: 7,
          className: "concentrationBody",
          bodyWidth: ""
        },
        temperature: {
          name: "液温度",
          unit: "℃",
          jsonAddress: 8,
          className: "temperatureBody",
          bodyWidth: ""
        },
        waterFlowRate: {
          name: "給水流量",
          unit: "L/min",
          jsonAddress: 10,
          className: "waterFlowRateBody",
          bodyWidth: ""
        }
      },
      // 液名
      liquidName: {
        nameB: "Ｂ原液",
        nameA: "Ａ原液"
      },
      // メッセージ一覧
      messageList: {
        // mod #10157 配管自己診断結果メッセージ追加 宮崎 start
        ufrc: {
          "0001": "配管自己診断正常終了",
          "0002": "配管漏れ異常",
          "0003": "脱ガス器フロートＳＷ異常",
          "0004": "配管漏れ異常＆脱ガス器フロートＳＷ異常",
          "0005": "カスケードポンプ異常、またはＳＶ５閉寒",
          "0006": "配管漏れ異常＆カスケードポンプ異常、またはＳＶ５閉塞",
          "0007":
            "脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞",
          "0008":
            "配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞",
          "0009": "ＳＶ４異常",
          "000A": "透析液圧センサ異常",
          "000B": "バランス異常（－）",
          "000C": "バランス異常（＋）",
          "000D": "バランス温度異常",
          "000E": "除水異常",
          "000F": "バランス異常（－）＆除水異常",
          "0010": "バランス異常（＋）＆除水異常",
          "0011": "バランス温度異常＆除水異常",
          "0012": "給液圧センサ異常",
          "0013": "ＳＶ１２異常",
          "0014": "微粒子除去フィルター漏れ異常",
          "0015": "ＳＶ１０異常",
          "0016": "ＳＶ３異常",
          "0102": "配管漏れ異常",
          "0103": "脱ガス器フロートＳＷ異常",
          "0104": "配管漏れ異常＆脱ガス器フロートＳＷ異常",
          "0105": "カスケードポンプ異常、またはＳＶ３閉寒",
          "0106": "配管漏れ異常＆カスケードポンプ異常、またはＳＶ３閉塞",
          "0107":
            "脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ３閉塞",
          "0108":
            "配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ３閉塞",
          "0109": "ＳＶ２異常",
          "010A": "透析液圧センサ異常",
          "010B": "バランス異常（－）",
          "010C": "バランス異常（＋）",
          "010D": "バランス温度異常",
          "010E": "除水異常",
          "010F": "バランス異常（－）＆除水異常",
          "0110": "バランス異常（＋）＆除水異常",
          "0111": "バランス温度異常＆除水異常",
          "0112": "給液圧センサ異常",
          "0113": "ＳＶ７異常",
          "0114": "微粒子除去フィルター漏れ異常",
          "0115": "ＳＶ４異常",
          "0116": "ＳＶ５異常",
          "0201": "配管自己診断正常終了",
          "0202": "配管漏れ異常",
          "0203": "脱ガス器フロートＳＷ異常",
          "0204": "配管漏れ異常＆脱ガス器フロートＳＷ異常",
          "0205": "カスケードポンプ異常、またはＳＶ５閉寒",
          "0206": "配管漏れ異常＆カスケードポンプ異常、またはＳＶ３閉塞",
          "0207":
            "脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞",
          "0208":
            "配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞",
          "0209": "ＳＶ４異常",
          "020A": "透析液圧センサ異常",
          "020B": "バランス異常（－）",
          "020C": "バランス異常（＋）",
          "020D": "バランス温度異常",
          "020E": "除水異常",
          "020F": "バランス異常（－）＆除水異常",
          "0210": "バランス異常（＋）＆除水異常",
          "0211": "バランス温度異常＆除水異常",
          "0212": "給液圧センサ異常",
          "0213": "ＳＶ７異常",
          "0214": "微粒子除去フィルター漏れ異常",
          "0215": "ＳＶ７異常 and 除水異常",
          "0216": "微粒子除去フィルター漏れ異常 and 除水漏れ",
          "0217": "ＳＶ２異常",
          "0218": "ＳＶ３異常",
          "0301": "配管自己診断正常終了",
          "0302": "透析液圧センサ テスト不合格",
          "0303": "減圧テスト不合格",
          "0307": "フロートスイッチテスト不合格",
          "0308": "ＳＶ７異常",
          "0309": "配管漏れ テスト（陰圧方式）不合格",
          "030A": "給水圧センサ テスト不合格",
          "030B": "熱交換器漏れテスト不合格",
          "030C": "配管漏れ テスト（陽圧方式）不合格",
          "030D": "除水ポンプ テスト不合格",
          "030E": "除水ポンプ リレーテスト不合格",
          "030F": "ＳＶ４１ テスト不合格",
          "0310": "ＣＦ漏れテスト不合格",
          "0311": "ヒータ電源遮断テスト不合格",
          "0312": "ＳＶ４締め切り検出器テスト不合格",
          "0313": "ＳＶ５締め切り検出器テスト不合格",
          "0314": "ＳＶ６締め切り検出器テスト不合格",
          "0315": "ＳＶ７締め切り検出器テスト不合格",
          "0316": "ＳＶ８締め切り検出器テスト不合格",
          "0317": "ＳＶ９締め切り検出器テスト不合格",
          "0318": "バランステスト不合格（－）",
          "0319": "バランステスト不合格（＋）",
          "031A": "バランステスト中の温度変化異常",
          "031B": "ＳＶ10締め切り検出器テスト不合格",
          "031C": "ＣＦ1漏れテスト不合格",
          "031D": "ＣＦ2漏れテスト不合格",
          "031E": "給液圧／透析液圧センサ比較テスト不合格",
          "031F": "ＳＶ３１締め切り検出器テスト不合格",
          "0320": "ＳＶ３１/３２リレーテスト不合格",
          "0321": "ＳＶ３２締め切り検出器テスト不合格",
          "0322": "ＣＶ３２テスト不合格",
          "0323": "ＳＶ４３，５５，５６テスト不合格"
        },
        // mod #10157 配管自己診断結果メッセージ追加 宮崎 end
        concentration: {
          3001: "濃度自己診断結果（正常）",
          3002: "濃度自己診断結果（バイカーボ濃度ー１０％高異常）",
          3003: "濃度自己診断結果（バイカーボ濃度ー１０％低異常）",
          3004: "濃度自己診断結果（バイカーボ濃度０％高異常）",
          3005: "濃度自己診断結果（バイカーボ濃度０％低異常）",
          3006: "濃度自己診断結果（透析液濃度ー１０％高異常）",
          3007: "濃度自己診断結果（透析液濃度ー１０％低異常）",
          3008: "濃度自己診断結果（透析液濃度０％高異常）",
          3009: "濃度自己診断結果（透析液濃度０％低異常）",
          3101: "正常",
          3102: "バイカーボ検量線警報（下限）",
          3103: "バイカーボ検量線警報（上限）",
          3104: "透析液検量線警報（下限）",
          3105: "透析液検量線警報（上限）",
          3106: "透析液検量線測定不可",
          3107: "濃度自己診断警報（バイカーボ下限） ＋ 濃度自己診断警報（透析液下限）",
          3108: "濃度自己診断警報（バイカーボ下限） ＋ 濃度自己診断警報（透析液上限）",
          3109: "濃度自己診断警報（バイカーボ上限） ＋ 濃度自己診断警報（透析液下限）",
          "310A":
            "濃度自己診断警報（バイカーボ上限） ＋ 濃度自己診断警報（透析液上限）",
          "310B":
            "濃度自己診断警報（バイカーボ下限） ＋ 濃度自己診断　測定不可",
          "310C": "濃度自己診断警報（バイカーボ上限） ＋ 濃度自己診断　測定不可"
        },
        piping: {
          "0001": "配管テスト正常",
          "0002": "TFD321配管テスト注水異常",
          "0003": "TFD322配管テストＬＶＳ１異常",
          "0004": "TFD322配管テストＬＶＳ２異常",
          "0005": "TFD323配管テスト排液異常",
          "0006": "TFD322配管テストＬＶＳ３異常",
          "0007": "TFD324配管テスト給水圧力センサ異常",
          "0008": "TFD325配管テスト送液圧力センサ異常",
          "000A": "TFD326配管テストＭＶ１７漏れ異常",
          "000B": "TFD327配管テストＭＶ１７漏れ未確認",
          "000C": "TFD327配管テスト ヒータ遮断回路異常",
          "000D": "TFD281 貯槽液濃度セル異常（CEL3）",
          "000E": "TFD282 貯槽液濃度セル異常（CEL4）"
        },
        hemodilution: {
          3001: "希釈テスト正常",
          3002: "TFD301希釈テストＢ液濃度ー１０％異常下限",
          3003: "TFD302希釈テストＢ液濃度ー１０％異常上限",
          3004: "TFD311希釈テスト透析液濃度ー１０％異常下限",
          3005: "TFD312希釈テスト透析液濃度ー１０％異常上限",
          3006: "TFD303希釈テストＢ濃度０％異常下限",
          3007: "TFD304希釈テストＢ濃度０％異常上限",
          3008: "TFD313希釈テスト透析液濃度０％異常下限",
          3009: "TFD314希釈テスト透析液濃度０％異常上限"
        }
      },
      stickyPositionSize: { top: "0px" },
      /**
       * 日付フォーマット
       */
      DATE_LONG_TIME_FORMAT: "YYYY/MM/DD HH:mm:ss",
      selfScreenName: "",
      scrollTop: 0
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isNkkFacility",
      "getFontSize",
    ]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"

    }),
    ...mapGetters("operation-viewer/machine", [
      "getSelfMeasureResultInfo"
    ]),
    ...mapGetters("operation-viewer/motion-record", [
      "getHeaderInfo",
      "getMachineTypeCd",
      "isGatheringOk",
      "getPartsRunningResult"
    ]),
    ...mapGetters("operation-viewer/motion-record-detail", [
      "getMotionRecordDetail",
      "getUfrc",
      "getBloodLeakage",
      "getDialysateFlowRate",
      "getConcentration",
      "getPiping",
      "getHemodilution",
      "getDissolutions",
      "getTestType",
      "isTable",
      "getUfrcLeakageGraphData",
      "getOtherUfrcGraphData",
      "getBloodLeakageGraphData",
      "getDialysateFlowRateGraphData",
      "getSelfDiagnosisConcentrationGraphData",
      "getPipingTestPressureGraphData",
      "getPipingTestConcentrationCellGraphData",
      "getJudgementTermGraphData",
      "getHemodilutionTestGraphData",
      "getConcentrationGraphData",
      "getTemperatureGraphData",
      "getDissolutionTimeGraphData",
      "getDry50AGraphData",
      "getDisplayPeriod",
      "isDab",
      "getMotionRecord",
      "getEventRegDate",
      "getEndGraphDate",
      "getOffset",
      // add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
      "getSelftList"
      // add 7801【デグレ】自己診断結果の集計が不正_再発 関 end
    ]),
    motionRecordDetail() {
      return this.getMotionRecordDetail;
    },
    ufrc() {
      return this.getUfrc;
    },
    bloodLeakage() {
      return this.getBloodLeakage;
    },
    dialysateFlowRate() {
      return this.getDialysateFlowRate;
    },
    concentration() {
      return this.getConcentration;
    },
    piping() {
      return this.getPiping;
    },
    hemodilution() {
      return this.getHemodilution;
    },
    dissolutions() {
      return this.getDissolutions;
    },
    testType() {
      // 自己診断結果のタイプ 1:配管、2:漏血、3:透析液流量、4:濃度、5:配管テスト、6:希釈テスト
      return this.getTestType;
    },
    ufrcLeakageGraphData() {
      return this.getUfrcLeakageGraphData;
    },
    otherUfrcGraphData() {
      return this.getOtherUfrcGraphData;
    },
    bloodLeakageGraphData() {
      return this.getBloodLeakageGraphData;
    },
    dialysateFlowRateGraphData() {
      return this.getDialysateFlowRateGraphData;
    },
    selfDiagnosisConcentrationGraphData() {
      return this.getSelfDiagnosisConcentrationGraphData;
    },
    pipingTestPressureGraphData() {
      return this.getPipingTestPressureGraphData;
    },
    pipingTestConcentrationCellGraphData() {
      return this.getPipingTestConcentrationCellGraphData;
    },
    judgementTermGraphData() {
      return this.getJudgementTermGraphData;
    },
    hemodilutionTestGraphData() {
      return this.getHemodilutionTestGraphData;
    },
    concentrationGraphData() {
      return this.getConcentrationGraphData;
    },
    temperatureGraphData() {
      return this.getTemperatureGraphData;
    },
    dissolutionTimeGraphData() {
      return this.getDissolutionTimeGraphData;
    },
    displayPeriod() {
      return this.getDisplayPeriod;
    },
    isDry50A() {
      return this.getPartsRunningResult.comType === 2 && this.getPartsRunningResult.comFormatCd === 'I';
    },
    dry50AGraphData() {
      return this.getDry50AGraphData;
      }
    },
  watch: {
    getFontSize() {
      // フォントサイズ変更に合わせて調整処理を発火
      this.setTableBodyWidth();
      // 表のTopサイズの補正
      if (document.getElementById("sticky-position-base") != null) {
        this.stickyPositionSize.top = document.getElementById("sticky-position-base").offsetHeight + "px";
      }
      // 明細部の高さを調整する.
      this.setDetailHeight();
    },
    /**
     * 画面高さ変更の監視
     */
    windowHeight() {
      // 明細部の高さを調整する.
      this.setDetailHeight();
    },
    /**
     * 画面幅変更の監視
     * 画面幅変更に伴い、ボタンエリアで折り返しが発生する場合がある為、
     * 幅調整を行っている.
     */
    windowWidth() {
      // 明細部の高さを調整する.
      this.setDetailHeight();
    }
  },
  methods: {
    ...mapGetters("user", ["getUserType"]),
    ...mapGetters("operation-viewer/motion-record-detail", ["getDownloadData"]),
    ...mapActions("operation-viewer/motion-record-detail", [
      "fetchMotionRecordDetail",
      "setDisplayPeriod",
      "setDissolutionGraphData",
      "setSelfDiagnosisGraphData",
      "changeIsTable",
      "changeIsCorrection",
      "setTestType",
      "updateServiceSupport",
      "resetOffset"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("operation-viewer/motion-record-detail", {
      setStoreDownloadData: "setDownloadData"
    }),
    ...mapActions("operation-viewer/motion-record", [
      "getPartsRunning"
    ]),
        // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong start
        ...mapActions("operation-viewer/machine", {
      fetchSelfMeasureResultInfo: "getSelfMeasureResultInfo"
    }),
    async reloadSelfMeasureResultInfo() {
      const headerInfo = this.getHeaderInfo || {};
      if (!headerInfo.machineSerial || !this.getMachineTypeCd) {
        return;
      }
      await this.fetchSelfMeasureResultInfo({
        facilityCd: headerInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: headerInfo.machineSerial,
        version: headerInfo.version
      });
    },
    // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong end
    /**
     * サービス対応ボタンに関する情報を取得する.
     *
     * @param {*} motionRecord 装置記録情報
     * @returns サービス対応区分に該当するボタンの情報
     */
    getServiceSupportButtonInfo(motionRecord) {
      const serviceSupportType = motionRecord.serviceSupportType;
      switch (serviceSupportType) {
        case SERVICE_SUPPORT.NOT_ACCEPTED.cd:
          return SERVICE_SUPPORT.NOT_ACCEPTED;
        case SERVICE_SUPPORT.FIRST_ORDER_SUPPORTED.cd:
          return SERVICE_SUPPORT.FIRST_ORDER_SUPPORTED
        case SERVICE_SUPPORT.SERVICE_SUPPORTED.cd:
          return SERVICE_SUPPORT.SERVICE_SUPPORTED;
        case SERVICE_SUPPORT.OUT_OF_SERVICE.cd:
          return SERVICE_SUPPORT.OUT_OF_SERVICE;
        default:
          return SERVICE_SUPPORT.NOT_ACCEPTED;
      }
    },
    /**
     * 対処日時、サービス対応日時のフォーマットを行う.
     *
     * @param 日時
     * @returns フォーマットした日付
     *          フォーマット形式は[DATE_LONG_TIME_FORMAT]を参照
     */
    getFormatDate(targetDate) {
      // フォーマット対象の日時がnull若しくは空の場合
      if (!targetDate) {
        return;
      }
      return moment(targetDate).format(this.DATE_LONG_TIME_FORMAT);
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh(isMainContent, autoRefreshFlag) {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.reloadSelfMeasureResultInfo().catch(() => {});
      // スキップ行数を初期化する
      this.resetOffset();
      // リフレッシュ前にスクロール位置保存
      this.saveScrollTop();

      const info = [];
      info.push({
        motionRecordNo: this.getMotionRecord.motionRecordNo,
        dataType: this.getMotionRecord.dataType,
        testType: this.testType,
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        baseDate: this.getMotionRecord.eventRegDate.replace(/\//g, ""),
        isClear: true,
        offset: this.getOffset,
        autoRefreshFlag
      });

      // 表示内容を初期化
      const dataType = this.getMotionRecord.dataType;
      if (dataType === 5) {
        this.setDisplayPeriod(this.displayPeriod).then(() => {
          info[0].weeks = this.displayPeriod;
          this.setDissolutionGraphData(info);
        });
        // 部品の運転/交換時間を取得
        this.getPartsRunning({
          facilityCd: this.getHeaderInfo.facilityCd,
          machineTypeCd: this.getMachineTypeCd,
          machineSerial: this.getHeaderInfo.machineSerial,
          autoRefreshFlag
        }).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'refresh', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
      } else if (dataType === 4) {
        this.setDisplayPeriod(this.displayPeriod).then(() => {
          info[0].weeks = this.displayPeriod;
          this.setSelfDiagnosisGraphData(info);
        });
      }

      this.fetchMotionRecordDetail(info)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'refresh', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    fetchMotionRecordsDetail() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // スキップ行数を初期化する
      this.resetOffset();

      const info = [];
      info.push({
        motionRecordNo: this.getMotionRecord.motionRecordNo,
        dataType: this.getMotionRecord.dataType,
        testType: this.getMotionRecord.testType,
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        baseDate: this.getMotionRecord.eventRegDate.replace(/\//g, ""),
        isClear: true,
        offset: this.getOffset
      });
      this.fetchMotionRecordDetail(info)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'fetchMotionRecordsDetail', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    updateMotionRecordsDetail() {
      const info = [];
      info.push({
        motionRecordNo: this.getMotionRecord.motionRecordNo,
        dataType: this.getMotionRecord.dataType,
        testType: this.getMotionRecord.testType,
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        baseDate: this.dateFormat(this.getEventRegDate),
        isClear: false,
        offset: this.getOffset
      });
      this.fetchMotionRecordDetail(info)
        .then(() => {
          this.isUpdating = false;
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'updateMotionRecordsDetail', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    // 受け取った日付データをyyyyMMdd形式で返す
    dateFormat(date) {
      const year = date.getFullYear();
      const month = `${"00"}${date.getMonth() + 1}`.slice(-2);
      const day = `${"00"}${date.getDate()}`.slice(-2);
      return `${year.toString()}${month.toString()}${day.toString()}`;
    },
    /**
     * サービス対応区分を更新する.
     *
     * @param {*} motionRecord 更新する装置記録詳細
     */
    changeServiceSupport(motionRecordDetail) {
      // 共通ローダ表示
      this.setLoadingScreenVisible(true);
      const currentServiceSupportType = motionRecordDetail.serviceSupportType;
      // 今のサービス対応区分が取得できなかった場合は何もしない
      if (!currentServiceSupportType) {
        this.setLoadingScreenVisible(false);
        return;
      }
      let updateServiceSupportType = Number(currentServiceSupportType) + 1;
      if (updateServiceSupportType > Number(SERVICE_SUPPORT.OUT_OF_SERVICE.cd)) {
        updateServiceSupportType = Number(SERVICE_SUPPORT.NOT_ACCEPTED.cd);
      }
      // パラメータ生成
      const param = {
        motionRecordNo: motionRecordDetail.motionRecordNo,
        serviceSupportType: String(updateServiceSupportType)
      };
      // API呼出
      this.updateServiceSupport(param).then(() =>{
        // 画面再描画
        // ※遠隔監視画面等、他の画面の更新も行う為、emitで再描画している.
        // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
        // EventBus.$emit("refresh");
        EventBus.$emit("refresh", false);
        // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end
      }).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('MotionRecordDetailsMainComponent.vue', 'changeServiceSupport', err);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw err;
      }).finally(() => {
        // 共通ローダ表示終了
        this.setLoadingScreenVisible(false);
      });
    },
    // 緊急発報、予防保守の対処、未対処の切替処理
    // 更新終了後、に装置記録一覧を更新する
    // 引数：_motionRecordNo 装置状態管理番号
    //      _isCorrection 現在の対処状況('0':未実施、'1':実施済)※予防保守
    //      _isCorrection 現在の対処状況('0':未対処、'1':対処済、'2':対応中)※緊急発報
    updateIsCorrection(_motionRecordNo, _isCorrection) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      const dataType = this.getMotionRecord.dataType;
      if (dataType === this.dataTypeItem.mNotice.dataType) {
        // 緊急発報
        if (_isCorrection === "0") {
          _isCorrection = "2";
        } else if (_isCorrection === "2") {
          _isCorrection = "1";
        } else {
          _isCorrection = "0";
        }
      } else {
        // 予防保守
        if (_isCorrection === "0") {
          _isCorrection = "1";
        } else {
          _isCorrection = "0";
        }
      }
      // 対処済、未対処、対応中のフラグを更新する為に必要な情報を作成
      const correctionUpdateInfo = {
        userId: this.getStateUserAccountInfo.userId,
        motionRecordNo: _motionRecordNo,
        isCorrection: _isCorrection
      };
      // 緊急発報、予防保守の対処、未対処、対応中の更新処理
      this.changeIsCorrection(correctionUpdateInfo)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          // 更新処理
          // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
          // EventBus.$emit("refresh");
          EventBus.$emit("refresh", false);
          // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'updateIsCorrection', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });

    },
    setDataTimeClass(key) {
      return key === "dataTime" ? "event-reg-time-header-sticky" : "";
    },
    // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong start
    isSelfMeasureItemVisible(jsonAddress) {
      const selfMeasureResultInfo = this.getSelfMeasureResultInfo || [];
      if (selfMeasureResultInfo.length === 0) {
        return true;
      }
      const targetInfo = selfMeasureResultInfo.find((item) => String(item.key) === String(jsonAddress));
      if (!targetInfo) {
        return true;
      }
      return targetInfo.judge === "1" || targetInfo.judge === 1 || targetInfo.judge === true;
    },
    // add/ #9291 自己診断判定の対象でない項目の値が表示される tianqidong end
    // 溶解記録のヘッダー名を編集して返す
    displayDissolutionHeaderName(dissolution) {
      let displayName = dissolution.name;
      if (dissolution.rowspan === 1) {
        displayName += "　";
      } else {
        displayName += "\r\n";
      }
      displayName += dissolution.unit;
      return displayName;
    },
    // 溶解記録２列目のヘッダー名の配列を返す
    displayDissolutionSecondHeaderName(dissolution) {
      const displayNames = [];
      Object.keys(dissolution).forEach(key => {
        if (dissolution[key].rowspan === 1) {
          displayNames.push({
            name: this.liquidName.nameB
          });
          displayNames.push({
            name: this.liquidName.nameA
          });
        }
      }, dissolution);
      return displayNames;
    },
    // 溶解記録の日時のフォーマットを編集して返す
    convertDateFormat(value) {
      if (value.length === 10) {
        value = value.slice(5);
      } else if (value.length === 8) {
        value = value.slice(0, 5);
      }
      return value;
    },
    // 自己診断の判定結果を編集して返す
    convertSelfDiagnosisResult(testType, resultCd) {
      if (testType === 1 || testType === 4) {
        if (
          resultCd === "0001" ||
          resultCd === "0201" ||
          resultCd === "0301" ||
          resultCd === "3001" ||
          resultCd === "3101"
        ) {
          return "正常";
        }
        return "異常";
      } else if (testType === 5) {
        if (resultCd === "0001") {
          return "正常";
        }
        return "異常";
      } else if (testType === 6) {
        if (resultCd === "3001") {
          return "正常";
        }
        return "異常";
      }
      return "";
    },
    // 溶解記録の判定結果を編集して返す
    convertDissolutionResult(resultCd) {
      if (resultCd === "0") {
        return "正常";
      } else if (resultCd === "1") {
        return "異常";
      }
      return "";
    },
    // 自己診断結果グラフデータを設定する
    setSelfDiagnosisGraphDataByPeriod(displayPeriod) {
      this.setDisplayPeriod(displayPeriod).then(() => {
        const info = [];
        info.push({
          facilityCd: this.getHeaderInfo.facilityCd,
          machineTypeCd: this.getMachineTypeCd,
          machineSerial: this.getHeaderInfo.machineSerial,
          baseDate: this.getMotionRecord.eventRegDate.replace(/\//g, ""),
          weeks: displayPeriod
        });
        this.setSelfDiagnosisGraphData(info);
      });
    },
    // 溶解記録グラフデータを設定する
    setDissolutionGraphDataByPeriod(displayPeriod) {
      this.setDisplayPeriod(displayPeriod).then(() => {
        const info = [];
        info.push({
          facilityCd: this.getHeaderInfo.facilityCd,
          machineTypeCd: this.getMachineTypeCd,
          machineSerial: this.getHeaderInfo.machineSerial,
          baseDate: this.getMotionRecord.eventRegDate.replace(/\//g, ""),
          weeks: displayPeriod
        });
        this.setDissolutionGraphData(info);
      });
    },
    // 自己診断結果グラフデータを更新する
    updateSelfDiagnosisGraphData(isReturn) {
      const displayPeriod = this.getDisplayPeriod;
      const endGraphDate = new Date(
        this.getEndGraphDate.slice(0, 4),
        this.getEndGraphDate.slice(4, 6) - 1,
        this.getEndGraphDate.slice(6)
      );
      if (isReturn) {
        endGraphDate.setDate(endGraphDate.getDate() - (displayPeriod / 2) * 7);
      } else {
        endGraphDate.setDate(endGraphDate.getDate() + (displayPeriod / 2) * 7);
      }
      let baseDate = endGraphDate.getFullYear().toString();
      let month = "00";
      month += (endGraphDate.getMonth() + 1).toString();
      baseDate += month.slice(-2);
      let date = "00";
      date += endGraphDate.getDate().toString();
      baseDate += date.slice(-2);

      const info = [];
      info.push({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        baseDate,
        weeks: displayPeriod
      });
      this.setSelfDiagnosisGraphData(info);
    },
    // 溶解記録グラフデータを更新する
    updateDissolutionGraphData(isReturn) {
      const displayPeriod = this.getDisplayPeriod;
      const endGraphDate = new Date(
        this.getEndGraphDate.slice(0, 4),
        this.getEndGraphDate.slice(4, 6) - 1,
        this.getEndGraphDate.slice(6)
      );
      if (isReturn) {
        endGraphDate.setDate(endGraphDate.getDate() - (displayPeriod / 2) * 7);
      } else {
        endGraphDate.setDate(endGraphDate.getDate() + (displayPeriod / 2) * 7);
      }
      let baseDate = endGraphDate.getFullYear().toString();
      let month = "00";
      month += (endGraphDate.getMonth() + 1).toString();
      baseDate += month.slice(-2);
      let date = "00";
      date += endGraphDate.getDate().toString();
      baseDate += date.slice(-2);

      const info = [];
      info.push({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        baseDate,
        weeks: displayPeriod
      });
      this.setDissolutionGraphData(info);
    },
    setDownloadData() {
      this.setStoreDownloadData({
        bucket: this.getMotionRecordDetail.fileData.path,
        filename: this.getMotionRecordDetail.fileData.filename
      })
        .then(() => {
          this.downloadFile();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordDetailsMainComponent.vue', 'setDownloadData', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    downloadFile() {
      const downloadData = this.getDownloadData();
      const fileName = this.getMotionRecordDetail.fileData.filename;
      const blob = new Blob([this.hexStringToArrayBuffer(downloadData)], {
        type: "application/zip"
      });
      if (window.navigator.msSaveBlob) {
        window.navigator.msSaveBlob(blob, fileName);
      } else {
        const downloadUrl = (window.URL || window.webkitURL).createObjectURL(
          blob
        );
        const link = document.createElement("a");
        link.href = downloadUrl;
        link.download = fileName;
        link.click();
        (window.URL || window.webkitURL).revokeObjectURL(blob);
      }
    },
    // 16進文字列をバイト配列に変換
    hexStringToArrayBuffer(hexStr) {
      const bytes = [];
      // 受け取った16進数文字列を符号付バイト配列に変換
      for (let i = 0; i < hexStr.length; i += 2) {
        bytes.push(this.hexToDecimalNumber(hexStr.substr(i, 2)));
      }
      // バイト配列をArrayBuffer型に変換
      const arrayBuffer = new Uint8Array(bytes);
      return arrayBuffer;
    },
    // 16進文字列をバイト値に変換
    hexToDecimalNumber(hexStr) {
      let decimalNumber = "";
      // 受け取った16進数値を2進数値に変換
      const binaryNumber = parseInt(hexStr, 16).toString(2);
      // 変換した2進数値のサイズが8未満の場合、正数であるため10進数値に変換
      if (binaryNumber.length < 8) {
        decimalNumber = parseInt(hexStr, 16);
        // 変換した2進数値のサイズが8の場合、負数であるため符号付10進数値に独自変換
      } else {
        // 2進数値のサイズ分(8サイズ)回り、ビット値を入れ替える
        const binaryNumberStr = binaryNumber.toString();
        for (let i = 0; i < binaryNumberStr.length; i++) {
          if (parseInt(binaryNumberStr.substr(i, 1), 10) === 0) {
            decimalNumber += "1";
          } else if (parseInt(binaryNumberStr.substr(i, 1), 10) === 1) {
            decimalNumber += "0";
          }
        }
        // ビット値を入れ替えた2進数値を10進数値に変換し、1を足して負数に変換する
        decimalNumber = -(parseInt(decimalNumber, 2) + 1);
      }
      return decimalNumber;
    },
    // 右から左にスワイプした際の処理
    onSwipeRight(dataType) {
      if (dataType === this.dataTypeItem.testResults.dataType) {
        this.updateSelfDiagnosisGraphData(true);
      } else if (dataType === this.dataTypeItem.dissolutions.dataType) {
        this.updateDissolutionGraphData(true);
      }
    },
    // 左から右にスワイプした際の処理
    onSwipeLeft(dataType) {
      if (dataType === this.dataTypeItem.testResults.dataType) {
        this.updateSelfDiagnosisGraphData(false);
      } else if (dataType === this.dataTypeItem.dissolutions.dataType) {
        this.updateDissolutionGraphData(false);
      }
    },
    // 結果カラムクリック時の処理
    clickResultCol(testType, eventRegDate, eventRegTime, resultCd, event) {
      this.popoverTestType = testType;
      this.popoverEventDate = `${eventRegDate} ${eventRegTime}`;
      this.popoverResultCd = resultCd;
      this.showPopover(event);
    },
    // ポップアップメニューを表示
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // 結果コードから、メッセージを取得
    // 引数 testType - 自己診断区分
    //      resultCd - 結果コード
    getResultMessage(testType, resultCd) {
      let keyName = "";
      if (testType === this.selfDiagnosisItem.ufrc.testType) {
        keyName = "ufrc";
      } else if (testType === this.selfDiagnosisItem.concentration.testType) {
        keyName = "concentration";
      } else if (testType === this.selfDiagnosisItem.piping.testType) {
        keyName = "piping";
      } else if (testType === this.selfDiagnosisItem.hemodilution.testType) {
        keyName = "hemodilution";
      }
      let resultMessage = "";
      // 結果コードが空文字の場合
      if (resultCd === "") {
        return "";
      }
      Object.keys(this.messageList[keyName]).forEach(key => {
        if (key === resultCd) {
          resultMessage += this.messageList[keyName][key];
        }
      }, this.messageList[keyName]);
      if (resultMessage !== "") {
        return resultMessage;
      }
      resultMessage = "一致するメッセージが見つかりませんでした。resultCd:";
      resultMessage += resultCd;
      return resultMessage;
    },
    // tableのbodyサイズをヘッダーのサイズに揃える
    setTableBodyWidth() {
      // 日時ヘッダのサイズを再計算
      $$("#eventRegTimeHeader").height($$("#dataTime").height());
      // 自己診断画面-配管のtableBodyのサイズを再計算
      this.ufrcItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.ufrcItem.result.bodyWidth = $$("#result").width();
      this.ufrcItem.negativePipeLeakage.bodyWidth = $$(
        "#negativePipeLeakage"
      ).width();
      this.ufrcItem.positivePipeLeakage.bodyWidth = $$(
        "#positivePipeLeakage"
      ).width();
      this.ufrcItem.cfLeakage.bodyWidth = $$("#cfLeakage").width();
      this.ufrcItem.cf2Leakage.bodyWidth = $$("#cf2Leakage").width();
      this.ufrcItem.removal.bodyWidth = $$("#removal").width();
      this.ufrcItem.balance.bodyWidth = $$("#balance").width();
      // 自己診断画面-漏血のtableBodyのサイズを再計算
      this.bloodLeakageItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.bloodLeakageItem.voltageRed.bodyWidth = $$("#voltageRed").width();
      this.bloodLeakageItem.voltageGreen.bodyWidth = $$(
        "#voltageGreen"
      ).width();
      // 自己診断画面-透析液流量のtableBodyのサイズを再計算
      this.dialysateFlowRateItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.dialysateFlowRateItem.dialysateFlowRate.bodyWidth = $$(
        "#dialysateFlowRate"
      ).width();
      // 自己診断画面-濃度のtableBodyのサイズを再計算
      this.concentrationItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.concentrationItem.result.bodyWidth = $$("#result").width();
      this.concentrationItem.dialysateB.bodyWidth = $$("#dialysateB").width();
      this.concentrationItem.dialysateA.bodyWidth = $$("#dialysateA").width();
      // 自己診断画面-配管テストのtableBodyのサイズを再計算
      this.pipingTestItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.pipingTestItem.result.bodyWidth = $$("#result").width();
      this.pipingTestItem.supplyPressure.bodyWidth = $$(
        "#supplyPressure"
      ).width();
      this.pipingTestItem.dialysateFlowPressureLow.bodyWidth = $$(
        "#dialysateFlowPressureLow"
      ).width();
      this.pipingTestItem.dialysateFlowPressureHigh.bodyWidth = $$(
        "#dialysateFlowPressureHigh"
      ).width();
      this.pipingTestItem.concentrationCell3.bodyWidth = $$(
        "#concentrationCell3"
      ).width();
      this.pipingTestItem.concentrationCell4.bodyWidth = $$(
        "#concentrationCell4"
      ).width();
      this.pipingTestItem.judgementTermInjection.bodyWidth = $$(
        "#judgementTermInjection"
      ).width();
      this.pipingTestItem.judgementTermDrainage.bodyWidth = $$(
        "#judgementTermDrainage"
      ).width();
      // 自己診断画面-希釈テストのtableBodyのサイズを再計算
      this.hemodilutionTestItem.dataTime.bodyWidth = $$("#dataTime").width();
      this.hemodilutionTestItem.result.bodyWidth = $$("#result").width();
      this.hemodilutionTestItem.concentrationB.bodyWidth = $$(
        "#concentrationB"
      ).width();
      this.hemodilutionTestItem.concentrationDialysate.bodyWidth = $$(
        "#concentrationDialysate"
      ).width();
    },
    // スクロール時の動作設定
    setOnScroll(tableId) {
      const scrollArea = $$(`#${tableId}`);

      scrollArea.on("scroll", () => {
        const scrollAreaHeight = scrollArea.get(0).clientHeight;
        const scrollHeight = scrollArea.get(0).scrollHeight;
        const bottom = scrollHeight - scrollAreaHeight;

        // スクロール位置がマイナスになった場合に「日付」ヘッダを非表示にする
        if (scrollArea.scrollTop() < 0 || scrollArea.scrollLeft() < 0) {
          $$("#eventRegTimeHeader").css("visibility", "hidden");
        } else {
          $$("#eventRegTimeHeader").css("visibility", "visible");
        }

        // スクロールが最後尾に達した時に追加読み込みを行う
        if (bottom <= scrollArea.scrollTop()) {
          if (!this.isUpdating) {
            this.isUpdating = true;
            if (
              tableId === this.dataTypeItem.testResults.tableId ||
              tableId === this.dataTypeItem.dissolutions.tableId
            ) {
              this.updateMotionRecordsDetail();
            } else {
              this.isUpdating = false;
            }
          }
        }
      });
    },
    /**
     * 明細表示部の高さを設定する.
     * ※対象は警報通知及び予防保守のみとする.
     *   上記以外のデータタイプの場合は何もしない.
     *
     * 高さの調整は画面下部にあるボタン群(未対応や未受付)のdiv要素の高さを算出し、明細の高さ(100%)から
     * 引き算した高さを設定する.
     */
    setDetailHeight() {
      // 装置記録、警報通知及び予防保守の場合
      if (this.getMotionRecord.dataType === this.dataTypeItem.machineRecord.dataType ||
          this.getMotionRecord.dataType === this.dataTypeItem.mNotice.dataType ||
          this.getMotionRecord.dataType === this.dataTypeItem.preventive.dataType
      ) {
        // 高さ調整する要素
        const elements = document.getElementsByClassName("machine-record-detail-message");
        if (elements.length <= 0) {
          return;
        }
        const buttonAreaElments = document.getElementsByClassName("correction-button-area");
        let offset = 0;
        // 日機装施設の場合、ボタンが2個ある為、マージ分を考慮し、初期値を5とする.
        if (buttonAreaElments && buttonAreaElments.length > 1) {
          offset += 5;
        }
        Array.prototype.forEach.call(buttonAreaElments, function(element){
          offset += element.clientHeight;
        });
        elements[0].style.height = `calc(100% - ${offset}px)`;
      }
    },

    /**
     * 診断結果が正常・注意・不合格か判定して、文字色変更用のクラスを返却する
     */
    // mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
    //  chkSelfMeasureResultInfo(addClassName, jsonAddress, value) {
    //   // JSONキーアドレスで自己診断判定マスタを検索
    //   const selfMeasureResultInfo = this.getSelfMeasureResultInfo.find(resInf =>
    //     resInf.key === jsonAddress && resInf.judge === "1"
    //   );

    //   if (selfMeasureResultInfo) {
    //     // 不合格・注意点のチェック処理
    //     if (jsonAddress === this.ufrcItem.result.jsonAddress || jsonAddress === this.concentrationItem.result.jsonAddress) {
    //       // "正常"・"異常"の判定のみ実施
    //       if (value === "正常") {
    //         return addClassName;
    //       } else {
    //         return addClassName + " td-result-failure";
    //       }
    //     } else {
    //       // 不合格(上限/下限)・注意点(上限/下限)を判定
    //       const numValue = Number(value);
    //       if (!Number.isNaN(numValue)) {
    //         if (!Number.isNaN(parseFloat(selfMeasureResultInfo.failure_low)) && numValue <= Number(selfMeasureResultInfo.failure_low)) {
    //           // 不合格下限以下
    //           return addClassName + " td-result-failure";
    //         } else if (!Number.isNaN(parseFloat(selfMeasureResultInfo.failure_up)) && Number(selfMeasureResultInfo.failure_up) <= numValue) {
    //           // 不合格上限以上
    //           return addClassName + " td-result-failure";
    //         } else if (!Number.isNaN(parseFloat(selfMeasureResultInfo.caution_low)) && numValue <= Number(selfMeasureResultInfo.caution_low)) {
    //           // 注意点下限以下
    //           return addClassName + " td-result-caution";
    //         } else if (!Number.isNaN(parseFloat(selfMeasureResultInfo.caution_up)) && Number(selfMeasureResultInfo.caution_up) <= numValue) {
    //           // 注意点上限以上
    //           return addClassName + " td-result-caution";
    //         } else {
    //           // 正常範囲
    //           return addClassName;
    //         }
    //       }
    //     }
    //   } else {
    //     // 自己診断情報なし、または判定しない場合
    //     return addClassName;
    //   }
    // }
    chkSelfMeasureResultInfo(index,addClassName, jsonAddress, value, recordNo, testResultData) {
      // JSONキーアドレスで自己診断判定マスタを検索
      const existFlg = testResultData ? true : false;

      // 自己診断判定データがあるかどうか
      if (existFlg && testResultData.length > 0) {
        const selfInfoList = testResultData.find(
          (resInf) => resInf.key === jsonAddress && resInf.judge === "1"
        );
        if (selfInfoList) {
          // 不合格・注意点のチェック処理
          if (
            jsonAddress === this.ufrcItem.result.jsonAddress ||
            jsonAddress === this.concentrationItem.result.jsonAddress
          ) {
            // "正常"・"異常"の判定のみ実施
            if (value === "正常") {
              return addClassName;
            } else {
              return addClassName + " td-result-failure";
            }
          } else {
            // 不合格(上限/下限)・注意点(上限/下限)を判定
            const numValue = Number(value);
            if (!Number.isNaN(numValue)) {
              if (
                !Number.isNaN(parseFloat(selfInfoList.failure_low)) &&
                numValue <= Number(selfInfoList.failure_low)
              ) {
                // 不合格下限以下
                return addClassName + " td-result-failure";
              } else if (
                !Number.isNaN(parseFloat(selfInfoList.failure_up)) &&
                Number(selfInfoList.failure_up) <= numValue
              ) {
                // 不合格上限以上
                return addClassName + " td-result-failure";
              } else if (
                !Number.isNaN(parseFloat(selfInfoList.caution_low)) &&
                numValue <= Number(selfInfoList.caution_low)
              ) {
                // 注意点下限以下
                return addClassName + " td-result-caution";
              } else if (
                !Number.isNaN(parseFloat(selfInfoList.caution_up)) &&
                Number(selfInfoList.caution_up) <= numValue
              ) {
                // 注意点上限以上
                return addClassName + " td-result-caution";
              } else {
                // 正常範囲
                return addClassName;
              }
            }
          }
        } else {
          // 自己診断情報なし、または判定しない場合
          return addClassName;
        }
      } else {
        /* mod #9241 by zhangruixue 2023-08-01 --start */
        // const selfMeasureResultInfoList = this.getSelfMeasureResultInfo.find(
        //   (resInf) => resInf.key === jsonAddress && resInf.judge === "1"
        // );
        let selfMeasureResultInfoList;
        if (this.getUfrc && ["47", "43", "44", "45", "49", "48", "46"].includes(jsonAddress)) {
          selfMeasureResultInfoList = this.getUfrc[index]?.result[999]?.filter((item)=>{
            return item.key === jsonAddress && item.judge === "1"
          })
        }
        if (this.getBloodLeakage && ["53", "54"].includes(jsonAddress)) {
          selfMeasureResultInfoList = this.getBloodLeakage[index]?.result[999]?.filter((item)=>{
            return item.key === jsonAddress && item.judge === "1"
          })
        }
        if (this.getDialysateFlowRate && ["58"].includes(jsonAddress)) {
          selfMeasureResultInfoList = this.getDialysateFlowRate[index]?.result[999]?.filter((item)=>{
            return item.key === jsonAddress && item.judge === "1"
          })
        }
        if (this.getConcentration && ["65", "63", "64"].includes(jsonAddress))  {
          selfMeasureResultInfoList = this.getConcentration[index]?.result[999]?.filter((item)=>{
            return item.key === jsonAddress && item.judge === "1"
          })
        }
        if (selfMeasureResultInfoList) {
          // 不合格・注意点のチェック処理
          if (
            jsonAddress === this.ufrcItem.result.jsonAddress ||
            jsonAddress === this.concentrationItem.result.jsonAddress
          ) {
            // "正常"・"異常"の判定のみ実施
            if (value === "正常") {
              return addClassName;
            } else {
              return addClassName + " td-result-failure";
            }
          } else {
            // 不合格(上限/下限)・注意点(上限/下限)を判定
            const numValue = Number(value);
            if (!Number.isNaN(numValue)) {
              if (
                !Number.isNaN(
                  parseFloat(selfMeasureResultInfoList[0]?.failure_low)
                ) &&
                numValue <= Number(selfMeasureResultInfoList[0]?.failure_low)
              ) {
                // 不合格下限以下
                return addClassName + " td-result-failure";
              } else if (
                !Number.isNaN(
                  parseFloat(selfMeasureResultInfoList[0]?.failure_up)
                ) &&
                Number(selfMeasureResultInfoList[0]?.failure_up) <= numValue
              ) {
                // 不合格上限以上
                return addClassName + " td-result-failure";
              } else if (
                !Number.isNaN(
                  parseFloat(selfMeasureResultInfoList[0]?.caution_low)
                ) &&
                numValue <= Number(selfMeasureResultInfoList[0]?.caution_low)
              ) {
                // 注意点下限以下
                return addClassName + " td-result-caution";
              } else if (
                !Number.isNaN(
                  parseFloat(selfMeasureResultInfoList[0]?.caution_up)
                ) &&
                Number(selfMeasureResultInfoList[0]?.caution_up) <= numValue
              ) {
                // 注意点上限以上
                return addClassName + " td-result-caution";
              } else {
                // 正常範囲
                return addClassName;
              }
            }
          }
        } else {
          // 自己診断情報なし、または判定しない場合
          return addClassName;
        }
        /* mod #9241 by zhangruixue 2023-08-01 --end */
      }
    },
    // mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
    /**
     * 縦スクロール位置保存
     */
    saveScrollTop() {
      const dataType = this.getMotionRecord.dataType;
      let element = null;

      const isMachineRecord = dataType === this.dataTypeItem.machineRecord.dataType;
      const isMNotice = dataType === this.dataTypeItem.mNotice.dataType;
      const isPreventive = dataType === this.dataTypeItem.preventive.dataType;
      const isTestResults = dataType === this.dataTypeItem.testResults.dataType;
      const isDissolutions = dataType === this.dataTypeItem.dissolutions.dataType;

      if (isMachineRecord || isMNotice || isPreventive) {
        // 装置記録、予防保守/故障予知、緊急発報 表示時の要素
        element = document.getElementsByClassName('machine-record-detail-message')[0];
      } else if (isTestResults || isDissolutions) {
        // 自己診断（グラフ）、溶解記録（グラフ） 表示時の要素
        element = document.getElementsByClassName('div-scroll')[0];
      }

      if (element) {
        this.scrollTop = element.scrollTop;
      }
    },
    /**
     * スクロール位置復帰
     */
    restoreScrollTop() {
      setTimeout(() => {
        const dataType = this.getMotionRecord.dataType;
        let element = null;

        const isMachineRecord = dataType === this.dataTypeItem.machineRecord.dataType;
        const isMNotice = dataType === this.dataTypeItem.mNotice.dataType;
        const isPreventive = dataType === this.dataTypeItem.preventive.dataType;
        const isTestResults = dataType === this.dataTypeItem.testResults.dataType;
        const isDissolutions = dataType === this.dataTypeItem.dissolutions.dataType;

        if (isMachineRecord || isMNotice || isPreventive) {
          // 装置記録、予防保守/故障予知、緊急発報 表示時の要素
          element = document.getElementsByClassName('machine-record-detail-message')[0];
        } else if (isTestResults || isDissolutions) {
          // 自己診断（グラフ）、溶解記録（グラフ） 表示時の要素
          element = document.getElementsByClassName('div-scroll')[0];
        }

        if (element) {
          element.scrollTop = this.scrollTop;
        }
      }, 100);
    },
    /**
     * 表/グラフの表示切替
     */
    switchViewMode(isTable) {
      if (isTable) {
        // 表に切り替えるタイミングで、グラフの表示位置をリセット
        this.scrollTop = 0;
      }
      this.changeIsTable(isTable);
    },
    /**
     * 期間切替
     */
    switchPeriod(period, dataType) {
      this.scrollTop = 0;
      switch (dataType) {
        case "self":
          this.setSelfDiagnosisGraphDataByPeriod(period);
          break;
        case "dissolution":
          this.setDissolutionGraphDataByPeriod(period);
          break;
        default:
          console.log(`Unknown dataType: ${dataType}`);
      }
    },
    // add #11065 【03】編集権限バグ修正 関 start
    getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
    },
    // add #11065 【03】編集権限バグ修正 関 end
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 共通ローダー:表示開始
    this.setLoadingScreenVisible(true);
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    // 表/グラフの表示切替の初期化
    this.changeIsTable(true);
    this.reloadSelfMeasureResultInfo().catch(() => {});

    /* del by chamaojia 2023-07-06 遠隔監視画面：装置中でUFRC自己診断結果を送信し、遠隔監視画面に2回結果を表示する  --start */
    // this.fetchMotionRecordsDetail();
    /* del by chamaojia 2023-07-06 遠隔監視画面：装置中でUFRC自己診断結果を送信し、遠隔監視画面に2回結果を表示する  --end */


    // 自己診断と溶解記録の場合のみ実行する
    const dataType = this.getMotionRecord.dataType;
    if (dataType === 5) {
      this.setDissolutionGraphDataByPeriod(2);
      // 部品の運転/交換時間を取得
      this.getPartsRunning({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('MotionRecordDetailsMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        if (error.response.status === 400) {
          // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        }
      });
    } else if (dataType === 4) {
      this.setSelfDiagnosisGraphDataByPeriod(12);
      // NOTE: 装置記録画面側で選択された「表示項目切替」を設定
      this.setTestType(this.getMotionRecord.testType);
    }
    //del 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao start
    // this.changeIsTable(true);
    //del 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao end
    // 表の2列目の高さ初期値設定
    if (this.getFontSize == 2) {
      this.stickyPositionSize.top = "calc(1.5em + 7px)";
    } else {
      this.stickyPositionSize.top = "calc(1.6em + 7px)";
    }
    // リサイズ時にtableBodyのサイズを再計算
    $$(window).resize(() => {
      this.setTableBodyWidth();
    });

    // 共通ローダー:表示終了
    //add 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao start
    this.refresh();
    //add 8341自己診断の値がnullの時にグラフ表示が「0」で描画される zhao end
    this.setLoadingScreenVisible(false);
  },
  updated() {
    this.setTableBodyWidth();
    // 明細部の高さを調整する.
    // ※mountedで行ったが、期待通りのタイミングで処理が行われなった.
    this.setDetailHeight();
    // 表の2列目の高さの補正
    if (document.getElementById("sticky-position-base") != null) {
      this.stickyPositionSize.top = (document.getElementById("sticky-position-base").offsetHeight -1) + "px";
    }
    this.restoreScrollTop();
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
/* 装置記録詳細の項目タイトル */
.div-title {
  font-size: 1.0em;
}

/* 装置記録詳細の内容 */
.div-content {
  font-size: 1.2em;
  padding: 0px 0px 5px 5px;
}

/*
 * 緊急発報のメール本文部のスタイル
 * ※改行を含む為、preタグで囲っています。
 */
.pre-content {
  font-size: 1.15em;
  white-space: pre-wrap;
}

/* メッセージ表示系(1.装置記録、2.予防保守・故障予知、3.緊急発報) */
.machine-record-detail-message {
  overflow: hidden;
  overflow-y: auto;
}

/* ボタンスタイル（共通） */
.correction-button-area {
  margin-top: 0px;
  margin-bottom: 5px;
}
.correction-button {
  position: relative;
  display: inline-block;
  border-radius: 4px;
  font-size: 100%;
  padding: 0.2em 2em 0.2em 2em;
  bottom: 0;
  border-top: 0px;
  border-left: 0px;
  border-right: 0px;
  border-bottom: solid 3px #4974a0;
  box-shadow: unset;
}

/* 未対処時のボタンスタイル */
.deal-not {
  background-color: var(--btn4-alert-color);
  color: #fff;
  background-image: linear-gradient(var(--btn4-alert-color), var(--btn4-alert-color));
}

/* 対処済のボタンスタイル */
.deal-already {
  background-color: #ccffcc;
  color: #000;
  background-image: linear-gradient(#ccffcc, #ccffcc);
}

/* サービス対象外 */
.out-of-support {
  background-color: #999999;
  color: #000;
  background-image: linear-gradient(#999999, #999999);
}

/* 未実施のボタンスタイル */
.unexecuted-not {
  background-color: #ccff00;
  color: #fff;
  background-image: linear-gradient(#ccff00, #ccff00);
}

/* 対処者のスタイル */
.correction-label {
  font-size: 1.0em;
  margin-left: 5px;
}
.download-label {
  font-size: 0.75em;
  margin-bottom: 40px;
  vertical-align: middle;
  display: inline-table;
}
/* 自己診断種別切替エリアのスタイル定義 */
.div-self-diagnosis-type-area {
  width: 100%;
  height: 1.7em;
  line-height: 1.7em;
  white-space: nowrap;
  overflow-y: hidden;
  overflow-x: auto;
  text-overflow: ellipsis;
  /* margin: 0px 5px; */
}
/* 自己診断種別切替のスタイル定義 */
.ol-self-diagnosis-type {
  padding-left: 0;
  margin-left: 0;
  margin-top: 0;
  font-size: 0.7em;
  /* padding-left: 15px; */
}
.ol-self-diagnosis-type li {
  display: inline; /*横に並ぶように*/
  list-style: none;
}
.table-self-diagnosis {
  border-collapse: collapse;
  white-space: nowrap;
}
input[type="radio"] {
  /* ラジオボタンを非表示にする */
  display: none;
}
input[type="radio"]:checked + label {
  background: #ffcc66; /* マウス選択時の背景色を指定する */
  color: #333333;
}
.filterLabel {
  /* margin-right: 20px; */
  display: -webkit-inline-box;
}

/* 列タイトルを中央寄せにする為のスタイル */
.ntss-list-header-th {
  text-align: center;
}

/* vue highcharts確認用 */
.cont {
  margin: 0 auto;
}

/* スクロールエリアのスタイル */
.div-scroll {
  height: -webkit-fill-available;
  overflow-y: scroll;
  height: calc(100% - 25px);
}

/* .div-scroll::-webkit-scrollbar {
  display: none;
} */

/* 印刷用スタイル */
@media print {
  .machine-record-detail-message {
    height: auto !important;
  }

  .machine-record-detail-base {
    border: unset;
  }
}

/* 自己診断結果表の文字色に関するスタイル */
.td-result-failure {
  color: red;
}
.td-result-caution {
  color: orange;
}

/* 自己診断結果表の結果吹き出しに関するスタイル */
.mrd-self-measure-result-popover >>> .popover--bottom {
  width: 300px;
}
.mrd-self-measure-result-popover >>> .popover--bottom__content {
  width: 100%;
}
/* 溶解記録の1列目と2列目の間の横線 */
.ntss-list-header-th-sticky::before {
  content : "";
  position : absolute;
  top : 0;
  width : 100%;
  height : 100%;
  border-bottom : 1px solid var(--main-background-color);
}
/* add #11065 【03】編集権限バグ修正 関 start */
.button {
 display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 10px 20px;
}
/* add #11065 【03】編集権限バグ修正 関 end */
</style>
