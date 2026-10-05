export type Mode = 'off' | 'on' | 'full'

export type CategoryKind = 'used' | 'free' | 'buffer' | 'deferred'

export type Category = {
  color: string
  kind: CategoryKind
  name: string
  tokens: number
}

export type Snapshot = {
  categories: Category[]
  maxTokens: number
  percentage: number
  totalTokens: number
}

declare module 'claude-code' {
  interface PluginState {
    'context-bar': { mode: Mode; snapshot: Snapshot | null }
  }
}
