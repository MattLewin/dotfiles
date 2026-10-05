import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Mode, Snapshot } from '../types'
import { compact, details, glyph, layout } from './bar'

const MODES: readonly Mode[] = ['off', 'on', 'full']
const NEXT: Record<Mode, Mode> = { full: 'off', off: 'on', on: 'full' }

const mode = atom({ plugin: 'context-bar', key: 'mode' } as const, 'on')
const snapshot = atom({ plugin: 'context-bar', key: 'snapshot' } as const, null)

let isRefreshing = false

const isMode = (value: unknown): value is Mode =>
  MODES.includes(value as Mode)

// Reads the saved mode, carrying over the boolean `isShown` older versions saved.
async function storedMode($: EngineInterface): Promise<Mode | undefined> {
  const saved = await $.store.get('mode')
  if (isMode(saved)) {
    return saved
  }
  const legacy = await $.store.get('isShown')
  if (typeof legacy === 'boolean') {
    return legacy ? 'on' : 'off'
  }

  return undefined
}

async function refresh($: EngineInterface) {
  if (isRefreshing) {
    return
  }
  isRefreshing = true
  try {
    const { context } = await $.session.usage({ breakdown: 'summary' })
    const b = context.breakdown
    if (!b) {
      return
    }
    const next: Snapshot = {
      categories: b.categories.map(c => ({
        color: c.color,
        kind: c.kind,
        name: c.name,
        tokens: c.tokens,
      })),
      maxTokens: b.rawMaxTokens,
      percentage: b.percentage,
      totalTokens: b.totalTokens,
    }
    await update($, snapshot, () => next)
  } finally {
    isRefreshing = false
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'context-bar',
      description: 'Context window bar above the prompt: cycles on, full, off',
      argumentHint: '[off|on|full]',
    })
    const stored = await storedMode($)
    if (stored) {
      await update($, mode, () => stored)
    }
    void refresh($)

    return next(e)
  })

  on('command.run', { command: 'context-bar' }, async ($, e) => {
    const arg = e.args.trim().toLowerCase()
    if (arg && !isMode(arg)) {
      return { text: 'Usage: /context-bar [off|on|full]' }
    }
    const now = await update($, mode, m => (arg ? (arg as Mode) : NEXT[m]))
    await $.store.set('mode', now)
    if (now !== 'off') {
      await refresh($)
    }

    return { text: `Context bar ${now}.` }
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('context') && (await read($, mode)) !== 'off') {
      void refresh($)
    }

    return next(e)
  })

  on('session.compact', async ($, e, next) => {
    const done = await next(e)
    void refresh($)

    return done
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const shown = await read($, mode)
    if (e.props.hasSurvey || shown === 'off') {
      return next(e)
    }
    const snap = await read($, snapshot)
    if (!snap) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const label = ` ${snap.percentage}% ${compact(snap.totalTokens)}/${compact(snap.maxTokens)}`
    const width = Math.max(10, e.props.bodyColumns - label.length - 1)
    const segments = layout(snap.categories, snap.maxTokens, width)
    const bar = (
      <Box key="bar" flexDirection="row">
        {segments.map(s => (
          <Text
            key={s.name}
            color={s.color}
            dimColor={s.kind === 'free'}
          >
            {glyph(s.kind).repeat(s.cells)}
          </Text>
        ))}
        <Text dimColor>{label}</Text>
      </Box>
    )
    if (shown === 'on') {
      return bar
    }

    const rows = details(snap.categories, snap.maxTokens)
    const nameWidth = Math.max(...rows.map(r => r.name.length))
    const tokenWidth = Math.max(...rows.map(r => r.tokens.length))

    return (
      <Box flexDirection="column">
        {bar}
        {rows.map(r => (
          <Box key={r.name} flexDirection="row">
            <Text color={r.color} dimColor={r.kind === 'free'}>
              {glyph(r.kind).repeat(2)}{' '}
            </Text>
            <Text>{r.name.padEnd(nameWidth)}  </Text>
            <Text dimColor>{r.tokens.padStart(tokenWidth)} tokens  </Text>
            <Text>{r.percent.padStart(6)}</Text>
          </Box>
        ))}
      </Box>
    )
  })
}
