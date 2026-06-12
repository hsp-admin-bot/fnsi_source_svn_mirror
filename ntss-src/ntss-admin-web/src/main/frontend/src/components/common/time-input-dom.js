export function syncLegacyTimeInputDom(input, { required = false } = {}) {
  if (!input) {
    return;
  }

  input.setAttribute("aria-invalid", "false");
  input.setAttribute("aria-required", required ? "true" : "false");
  input.removeAttribute("value");
}
