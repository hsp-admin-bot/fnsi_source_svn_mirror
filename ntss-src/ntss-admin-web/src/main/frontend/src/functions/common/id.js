const counters = new Map();

export function nextId(prefix = "id") {
  const current = counters.get(prefix) ?? 0;
  const next = current + 1;
  counters.set(prefix, next);
  return `${prefix}${next}`;
}

export function resetNextId(prefix) {
  if (typeof prefix === "undefined") {
    counters.clear();
    return;
  }
  counters.delete(prefix);
}
