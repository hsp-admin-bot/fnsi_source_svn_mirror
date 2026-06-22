function getScopedDocument(root = null) {
  if (root?.ownerDocument) {
    return root.ownerDocument;
  }
  if (root?.$el?.ownerDocument) {
    return root.$el.ownerDocument;
  }
  return document;
}

export function queryHeadElement(selector, root = null) {
  const scopedDocument = getScopedDocument(root);
  return scopedDocument.head?.querySelector?.(selector) || null;
}

export function ensureHeadLink({ id = null, rel = null, sizes = null, href = null, media = null, root = null } = {}) {
  const scopedDocument = getScopedDocument(root);
  const selector = id
    ? `#${id}`
    : `link${rel ? `[rel="${rel}"]` : ''}${sizes ? `[sizes="${sizes}"]` : ''}`;
  let link = scopedDocument.head?.querySelector?.(selector) || null;
  if (!link) {
    link = scopedDocument.createElement('link');
    if (id) {
      link.id = id;
    }
    if (rel) {
      link.rel = rel;
    }
    if (sizes) {
      link.sizes = sizes;
    }
    scopedDocument.head?.appendChild(link);
  }
  if (rel) {
    link.rel = rel;
  }
  if (sizes) {
    link.sizes = sizes;
  }
  if (media) {
    link.media = media;
  } else if (media === null) {
    link.removeAttribute?.('media');
  }
  if (href) {
    link.href = href;
  }
  return link;
}

export function ensureStylesheetLink(id, hrefOrCandidates, media = null, root = null) {
  const link = ensureHeadLink({ id, rel: 'stylesheet', media, root });
  const candidates = Array.isArray(hrefOrCandidates) ? hrefOrCandidates : [hrefOrCandidates];
  link.dataset.candidates = JSON.stringify(candidates);
  link.dataset.candidateIndex = '0';
  link.onerror = () => {
    const nextIndex = Number(link.dataset.candidateIndex || '0') + 1;
    if (nextIndex >= candidates.length) {
      return;
    }
    link.dataset.candidateIndex = String(nextIndex);
    link.href = candidates[nextIndex];
  };
  if (link.href !== candidates[0]) {
    link.href = candidates[0];
  }
  return link;
}

export function ensureViewportContent(content, root = null) {
  const scopedDocument = getScopedDocument(root);
  const viewport = scopedDocument.head?.querySelector?.('meta[name="viewport"]') || null;
  viewport?.setAttribute?.('content', content);
  return viewport;
}
