export const GRID_SCHEMA = {
  model: {
    id: "ctlNo",
    fields: {
      ctlNo: {
        type: "number"
      },
      coopCd: {
        type: "string"
      },
      coopCdIndex: {
        type: "string",
        validation: {
          "maxlength" : "10"
        }
      },
      direction: {
        type: "string"
      },
      crud: {
        type: "string"
      },
      anaResult: {
        type: "string"
      },
      coopResult: {
        type: "string"
      },
      hospPatId: {
        type: "string"
      },
      patId: {
        type: "number"
      },
      ordNo: {
        type: "number"
      },
      coopOrdNo: {
        type: "string"
      },
      inAnaDate: {
        type: "datetime"
      },
      outAnaDate: {
        type: "datetime"
      },
      inRegDate: {
        type: "datetime"
      },
      outRegDate: {
        type: "datetime"
      },
      patName: {
        type: "string"
      },
      dump: {
        type: "string"
      },
      dumpPath: {
        type: "string"
      }
    }
  }
};
