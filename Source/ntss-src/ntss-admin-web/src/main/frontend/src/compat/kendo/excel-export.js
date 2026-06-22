import { workbookOptions, toDataURL } from "@progress/kendo-vue-excel-export";
import { saveAs } from "@progress/kendo-file-saver";

const ExcelExport = {
  name: "KendoCompatExcelExport",
  render() {
    return null;
  }
};

const workbook = {
  workbookOptions,
  toDataURL
};

const kendoFileSaver = {
  saveAs
};

export {
  ExcelExport,
  workbookOptions,
  toDataURL,
  saveAs,
  workbook,
  kendoFileSaver
};

export default ExcelExport;
