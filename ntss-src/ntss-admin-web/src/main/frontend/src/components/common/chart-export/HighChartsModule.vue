<template>
  <div>
    <div id="highcharts-config" v-show="false">
    </div>
  </div>
</template>

<script>
import VueHighcharts from "vue-highcharts";
import Highcharts from "highcharts";
import Boost from "highcharts/modules/boost";
import Vue from "vue";
import {ApiHelper} from "@/apis/AxiosHelper";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import {sendRequestCreatingReportByFromData} from "@/apis/report";
import {
  extractFontsFromSVG,
  isFontAvailable,
  replaceUnavailableFonts,
  findFirstAvailableFont
} from "@/stores/fontUtils";
import ons from "onsenui";

Vue.use(VueHighcharts);
Boost(Highcharts);

export default {
  name: "HighChartsModule",
  props: {

  },
  data() {
    return {
      maxSize: 10485760 //upload最大限
    }
  },
  methods: {
    // mod #11737 グラフがセルサイズにフィットしないときがある 房 start
    async getReportJsonInfos(inputData, pageIndex) {
      // let tempInputData = JSON.parse(JSON.stringify(inputData));
      let imageResponse = [];
      // if(tempInputData.patIds) {
      //   tempInputData.patIds = tempInputData.patIds.slice(0, pageCnt);
      // }
      // let imageInputData = JSON.parse(JSON.stringify(inputData));
      inputData.pageIndex = pageIndex;
      // if(pageIndex > 1) {
      //   let fromCount = (pageIndex - 1) * 2 - 1;
      //   imageInputData.patIds = tempInputData.patIds.slice(fromCount, pageCnt);
      // } else {
      //   imageInputData.patIds = tempInputData.patIds.slice(0, pageCnt);
      // }
      if(inputData.reportClass == 1) {
        imageResponse = await ApiHelper.post(
          "/report_menu/getReportImage/",
          inputData
        );
      }
      return imageResponse;
    },
    // mod #11737 グラフがセルサイズにフィットしないときがある 房 end
    async printSelectedReport(inputData, imageResponse) {
      const formData = new FormData();
      let patFileInfos = [];
      let totalSize = 0;
      if (imageResponse.data && imageResponse.data.length > 0) {
        for(let i = 0; i < imageResponse.data.length; i++) {
          totalSize = totalSize + await this.pngBlobEdit(imageResponse.data[i], formData, patFileInfos);
        }
      }
      if(totalSize > this.maxSize) {
        return "limitOver";
      }
      formData.append("patFileInfos", JSON.stringify(patFileInfos));
      formData.append("payload", JSON.stringify(inputData));
      return ApiHelper
        .post("/report_menu/printSelectedReport", formData);
    },
    async downloadReportFile(inputData, imageResponse, selectedExport) {
      const formData = new FormData();
      let patFileInfos = [];
      let totalSize = 0;
      if (imageResponse.data && imageResponse.data.length > 0) {
        for(let i = 0; i < imageResponse.data.length; i++) {
          totalSize = totalSize + await this.pngBlobEdit(imageResponse.data[i], formData, patFileInfos);
        }
      }
      if(totalSize > this.maxSize) {
        return "limitOver";
      }
      formData.append("patFileInfos", JSON.stringify(patFileInfos));
      formData.append("payload", JSON.stringify(inputData));
      return ApiHelper
        .configPost(
          "/report_menu/downloadReportFileByType/" + selectedExport,
          formData, {
            responseType: "blob"
          });
    },
    async printReport(inputData, imageResponse, option) {
      const formData = new FormData();
      let patFileInfos = [];
      let totalSize = 0;
      if (imageResponse.data && imageResponse.data.length > 0) {
        for(let i = 0; i < imageResponse.data.length; i++) {
          totalSize = totalSize + await this.pngBlobEdit(imageResponse.data[i], formData, patFileInfos);
        }
      }
      if(totalSize > this.maxSize) {
        return "limitOver";
      }
      formData.append("patFileInfos", JSON.stringify(patFileInfos));
      formData.append("payload", JSON.stringify(inputData));
      return ApiHelper.post(
        "/report_menu/printSelectedReportInfo/" + option,
        formData
      );
    },
    async pngBlobEdit(patImage, formData, patFileInfos) {
      // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 start
      let responseFonts = await ApiHelper.post("/report_menu/getSysFontsConfig");
      const fontFallbackRules = responseFonts.data;
      // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 end
      let reg = /\\/g;
      let filesSize = 0;
      let imageInfos = patImage.models;
      for (let index = 0; index < imageInfos.length; index++) {
        let imageJsonStr = imageInfos[index].jsonStr;
        imageJsonStr = imageJsonStr.replace(reg, '');
        let chartOptions = JSON.parse(imageJsonStr);
        // add #10633 【たくしん会】帳票のフォント問題 吉 start
        chartOptions.chart = chartOptions.chart || {};
        // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 start
        if (!isFontAvailable(patImage.fontType) && fontFallbackRules[patImage.fontType]) {
          const fallbackFont = findFirstAvailableFont(fontFallbackRules[patImage.fontType])
          if (fallbackFont) {
            chartOptions.chart.style = {
              fontFamily: fallbackFont,
            };
          }
        }else{
        // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 end
          chartOptions.chart.style = {
            fontFamily: patImage.fontType+',helvetica, arial, "hiragino kaku gothic pro", meiryo,"ms pgothic", sans-serif',
          };
        // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 start
        }
        // add #10633 【たくしん会】帳票のフォント問題 limingzhe 20250516 end
        // add #10633 【たくしん会】帳票のフォント問題 吉 end
        chartOptions.xAxis.labels.formatter = (valueObj) => {
          return Highcharts.dateFormat("%H:%M", (valueObj.value + Number(imageInfos[index].offsetValue)));
        };
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
        // const chartObj = Highcharts.chart('highcharts-config', chartOptions, () => {
        // });
        const container = document.getElementById('highcharts-config');
        const scale = 1 / window.devicePixelRatio;
        container.style.transform = `scale(${scale})`;
        container.style.transformOrigin = 'top left';
        const chartObj = Highcharts.chart('highcharts-config', chartOptions);
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
        const svgObj = chartObj.getSVG({
          chart: {
            width: imageInfos[index].width,
            height: imageInfos[index].height
          }
        });
        let svgHtmlElement = new DOMParser().parseFromString(svgObj, 'text/html').body.childNodes[0];
        let canvas = document.createElement('canvas');
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
        // canvas.width = imageInfos[index].width;
        // let tempHeight = 0;
        // if(imageInfos[index].height) {
        //   tempHeight = imageInfos[index].height;
        // } else {
        //   tempHeight = svgHtmlElement.height.baseVal.value;
        // }
        // canvas.height = tempHeight;
        // // Canvas作成
        // let ctx = canvas.getContext('2d');
        const width = imageInfos[index].width;
        const height = imageInfos[index].height || svgHtmlElement.height.baseVal.value;
        const dpr = window.devicePixelRatio;
        canvas.width = width * dpr;
        canvas.height = height * dpr;
        canvas.style.width = `${width}px`;
        canvas.style.height = `${height}px`;
        const ctx = canvas.getContext('2d');
        ctx.scale(dpr, dpr);
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
        let data = new XMLSerializer().serializeToString(svgHtmlElement);
        let svgBlob = new Blob([data], {type: 'image/svg+xml;charset=utf-8'});
        let url = URL.createObjectURL(svgBlob);
        let image = new Image();
        image.src = url;
        let pngBlob;
        await new Promise(resolve => {
          image.onload = async function () {
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
        // ctx.drawImage(image, 0, 0, imageInfos[index].width, tempHeight);
            ctx.drawImage(image, 0, 0, width, height);
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
            URL.revokeObjectURL(url);
            await new Promise(resolve1 => {
          // mod #11737 グラフがセルサイズにフィットしないときがある 吉 start
          //  canvas.toBlob(blob => {
            //     resolve1(blob);
            //   });
            // }).then(blob => {
            //  resolve(blob);
            // });
            // }
              canvas.toBlob(blob => resolve1(blob));
            }).then(blob => resolve(blob));
          };
        // mod #11737 グラフがセルサイズにフィットしないときがある 吉 end
        }).then(result => {
          pngBlob = result;
          filesSize += pngBlob.size;
        });
        let pngFileName = patImage.patId + "_" + index + ".png";
        formData.append('files', pngBlob, pngFileName);
        patFileInfos.push({
          patId: patImage.patId,
          fileName: pngFileName,
          fileIndex: index,
          ordNo: imageInfos[index].ordNo
        });
      }
      return filesSize;
    },
    async getReportImageForOtherReport(reportCd, params) {
      return ApiHelper.post(`/report/getReportImageForOtherReport/${reportCd}`, params);
    },
    async getReportHTMLByReportCd(reportCd, params, imageResponse) {
      const formData = new FormData();
      let patFileInfos = [];
      let totalSize = 0;
      if (imageResponse.data && imageResponse.data.length > 0) {
        for(let i = 0; i < imageResponse.data.length; i++) {
          totalSize = totalSize + await this.pngBlobEdit(imageResponse.data[i], formData, patFileInfos);
        }
      }
      if(totalSize > this.maxSize) {
        return "limitOver";
      }
      formData.append("patFileInfos", JSON.stringify(patFileInfos));
      formData.append("payload", JSON.stringify(params));
      return sendRequestCreatingReportByFromData(
        reportCd,
        formData
      )
      // add #12107 帳票印刷失敗通知が行われない limingzhe start
      .catch(error => {
        if (error.response.status === 400) {
          ons.notification.alert({
            title: DIALOG_MESSAGES[12000207].title,
            message: DIALOG_MESSAGES[12000207].message
          });
        }
        return Promise.reject(error);
      })
      // add #12107 帳票印刷失敗通知が行われない limingzhe end
      ;
    }
  }
}
</script>
