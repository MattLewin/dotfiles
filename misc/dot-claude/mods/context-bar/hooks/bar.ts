import type { Category, CategoryKind } from '../types'

export type Segment = {
  cells: number
  color: string
  kind: CategoryKind
  name: string
}

const GLYPH: Record<CategoryKind, string> = {
  buffer: '▒',
  deferred: '',
  free: '░',
  used: '█',
}

export const glyph = (kind: CategoryKind) => GLYPH[kind]

// Splits `width` cells across the window's categories by token share (largest
// remainder), then makes sure every non-empty `used` category shows at least
// one cell, taking it from free space first.
export const layout = (
  categories: readonly Category[],
  maxTokens: number,
  width: number,
): Segment[] => {
  const rows = categories.filter(c => c.kind !== 'deferred' && c.tokens > 0)
  const total = Math.max(
    maxTokens,
    rows.reduce((sum, c) => sum + c.tokens, 0),
  )
  if (total <= 0 || width <= 0) {
    return []
  }

  const segments = rows.map(c => {
    const exact = (c.tokens / total) * width

    return {
      cells: Math.floor(exact),
      color: c.color,
      kind: c.kind,
      name: c.name,
      rest: exact - Math.floor(exact),
    }
  })
  let left = width - segments.reduce((sum, s) => sum + s.cells, 0)
  for (const s of [...segments].sort((a, b) => b.rest - a.rest)) {
    if (left <= 0) {
      break
    }
    s.cells += 1
    left -= 1
  }

  for (const s of segments) {
    if (s.kind !== 'used' || s.cells > 0) {
      continue
    }
    const donor = pickDonor(segments)
    if (donor) {
      donor.cells -= 1
      s.cells = 1
    }
  }

  return segments
    .filter(s => s.cells > 0)
    .map(({ cells, color, kind, name }) => ({ cells, color, kind, name }))
}

const pickDonor = (segments: readonly Segment[]) => {
  const free = segments.find(s => s.kind === 'free' && s.cells > 0)
  if (free) {
    return free
  }

  return segments
    .filter(s => s.cells > 1)
    .reduce<Segment | undefined>((best, s) => (!best || s.cells > best.cells ? s : best), undefined)
}

export const compact = (tokens: number) =>
  tokens >= 1_000_000
    ? `${(tokens / 1_000_000).toFixed(1).replace(/\.0$/, '')}M`
    : tokens >= 1000
      ? `${Math.round(tokens / 1000)}k`
      : `${tokens}`

export type Detail = {
  color: string
  kind: CategoryKind
  name: string
  percent: string
  tokens: string
}

// One row per category the bar draws: its share of the window and its tokens.
export const details = (
  categories: readonly Category[],
  maxTokens: number,
): Detail[] => {
  const rows = categories.filter(c => c.kind !== 'deferred' && c.tokens > 0)
  const total = Math.max(
    maxTokens,
    rows.reduce((sum, c) => sum + c.tokens, 0),
  )

  return rows.map(c => ({
    color: c.color,
    kind: c.kind,
    name: c.name,
    percent: `${total > 0 ? ((c.tokens / total) * 100).toFixed(1) : '0.0'}%`,
    tokens: grouped(c.tokens),
  }))
}

export const grouped = (n: number) =>
  String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
