const formatUuid = (bytes) => {
  const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0"));
  return [
    `${hex[0]}${hex[1]}${hex[2]}${hex[3]}`,
    `${hex[4]}${hex[5]}`,
    `${hex[6]}${hex[7]}`,
    `${hex[8]}${hex[9]}`,
    `${hex[10]}${hex[11]}${hex[12]}${hex[13]}${hex[14]}${hex[15]}`
  ].join("-");
};

export function createUuid() {
  const cryptoObject = globalThis?.crypto;
  if (cryptoObject?.randomUUID) {
    return cryptoObject.randomUUID();
  }

  if (cryptoObject?.getRandomValues) {
    const bytes = cryptoObject.getRandomValues(new Uint8Array(16));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return formatUuid(bytes);
  }

  const fallback = `${Date.now()}-${Math.random()}-${Math.random()}`;
  return `fallback-${fallback.replace(/[^0-9a-zA-Z]/g, "")}`;
}

export default createUuid;
