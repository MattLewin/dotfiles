import type { On, SessionUsage } from 'claude-code'
import { expect, mock, test } from 'claude-code/testing'

import type { Category } from '../types'
import { details, layout } from './bar'

const CATEGORIES: Category[] = [
  { color: 'promptBorder', kind: 'used', name: 'System prompt', tokens: 3_000 },
  { color: 'inactive', kind: 'used', name: 'System tools', tokens: 15_000 },
  { color: 'permission', kind: 'used', name: 'Memory files', tokens: 200 },
  { color: 'claude', kind: 'used', name: 'Messages', tokens: 40_000 },
  { color: 'inactive', kind: 'deferred', name: 'MCP tools (deferred)', tokens: 9_000 },
  { color: 'inactive', kind: 'free', name: 'Free space', tokens: 96_800 },
  { color: 'inactive', kind: 'buffer', name: 'Autocompact buffer', tokens: 45_000 },
]

const USAGE = {
  context: {
    breakdown: {
      autocompactSource: 'model-default',
      categories: CATEGORIES.map(c => ({ ...c, isDeferred: c.kind === 'deferred' })),
      gridRows: [],
      maxTokens: 200_000,
      percentage: 29,
      rawMaxTokens: 200_000,
      totalTokens: 58_200,
    },
    percent: 29,
    tokens: 58_200,
    window: 200_000,
  },
  rateLimits: [],
  startedAt: 0,
} as unknown as SessionUsage

test('layout fills the width and keeps every used category visible', () => {
  for (const width of [10, 37, 80, 200]) {
    const segments = layout(CATEGORIES, 200_000, width)
    expect(segments.reduce((sum, s) => sum + s.cells, 0)).toBe(width)
    expect(segments.some(s => s.kind === 'deferred')).toBe(false)
    expect(segments.find(s => s.name === 'Memory files')?.cells).toBe(1)
  }
})

test('details lists each drawn category with its tokens and share', () => {
  const rows = details(CATEGORIES, 200_000)
  expect(rows.map(r => r.name)).not.toContain('MCP tools (deferred)')
  expect(rows.find(r => r.name === 'System prompt')).toMatchObject({
    percent: '1.5%',
    tokens: '3,000',
  })
  expect(rows.find(r => r.name === 'Free space')?.percent).toBe('48.4%')
})

const PROPS = {
  bodyColumns: 80,
  hasSurvey: false,
  isWorking: false,
  maxRows: 12,
  scroll: { bodyRows: 12, offset: 0 },
  view: {},
}

// Stands in for the engine: usage, the command list, the store and its own band.
const engine = (on: On, saved: Record<string, unknown>) => {
  on('session.usage', () => ({ value: USAGE }))
  on('command.register', () => ({ value: { command: 'context-bar' } }))
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('store.get', ($, e) => ({ value: saved[e.key] }))
  on('store.set', ($, e) => {
    saved[e.key] = e.value

    return { value: undefined }
  })
  on('ui.render', ($, e) => {
    const { Box } = $.ui.resolve(e)

    return <Box key="engine" />
  })
}

for (const surface of ['terminal', 'desktop'] as const) {
  test(`cycles on, full, off on ${surface}`, async ($, on) => {
    const saved: Record<string, unknown> = {}
    engine(on, saved)
    await $.session.start({ cwd: '/tmp', isInteractive: true, surface })
    const ui = await $.ui.mount({
      component: 'AbovePrompt',
      plugin: 'context-bar',
      props: PROPS,
      surface,
    })
    const drawn = async () => JSON.stringify(await ui.drawn())

    expect(await drawn()).toContain('29% 58k/200k')
    expect(await drawn()).not.toContain('System prompt')

    const full = await $.command.run({ command: 'context-bar', args: '' } as never)
    expect(full.text).toBe('Context bar full.')
    expect(saved.mode).toBe('full')
    expect(await drawn()).toContain('29% 58k/200k')
    expect(await drawn()).toContain('System prompt')
    expect(await drawn()).toContain('48.4%')

    const off = await $.command.run({ command: 'context-bar', args: '' } as never)
    expect(off.text).toBe('Context bar off.')
    expect(await drawn()).not.toContain('29%')
  })
}

test('sets a mode by argument and rejects an unknown one', async ($, on) => {
  const saved: Record<string, unknown> = {}
  engine(on, saved)
  await $.session.start({ cwd: '/tmp', isInteractive: true, surface: 'terminal' })

  const bad = await $.command.run({ command: 'context-bar', args: 'big' } as never)
  expect(bad.text).toBe('Usage: /context-bar [off|on|full]')
  expect(saved.mode).toBe(undefined)

  const off = await $.command.run({ command: 'context-bar', args: ' OFF ' } as never)
  expect(off.text).toBe('Context bar off.')
  expect(saved.mode).toBe('off')
})

test('carries over the boolean an older version saved', async ($, on) => {
  const saved: Record<string, unknown> = { isShown: false }
  engine(on, saved)
  await $.session.start({ cwd: '/tmp', isInteractive: true, surface: 'terminal' })
  const ui = await $.ui.mount({
    component: 'AbovePrompt',
    plugin: 'context-bar',
    props: PROPS,
    surface: 'terminal',
  })
  expect(JSON.stringify(await ui.drawn())).not.toContain('29%')

  const shown = await $.command.run({ command: 'context-bar', args: '' } as never)
  expect(shown.text).toBe('Context bar on.')
  expect(saved.mode).toBe('on')
  expect(JSON.stringify(await ui.drawn())).toContain('29% 58k/200k')
})
