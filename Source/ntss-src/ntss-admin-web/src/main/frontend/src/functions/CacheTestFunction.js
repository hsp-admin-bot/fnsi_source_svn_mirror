// 桁埋め処理
export const paddingInput = input => {
  if (input !== "") {
    const output = input.padStart(12, "Z");
    return output;
  }
}