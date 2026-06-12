export function getProcResult(data) {
  return data?.PROC_RESULT ?? data?.proc_RESULT;
}

export function isProcSuccess(data) {
  return getProcResult(data) === "SUCCESS";
}
