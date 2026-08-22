export type BrowserName =
  | 'chrome'
  | 'edge'
  | 'firefox'
  | 'ios_saf'
  | 'opera'
  | 'opera_mini'
  | 'safari'
  | 'ie'
  | 'unknown'

export type BrowserInfo = { name: BrowserName; version: number }

export const MIN_SUPPORTED_BROWSER_VERSIONS = {
  chrome: 80,
  edge: 80,
  firefox: 78,
  ios_saf: 13,
  opera: 80,
  safari: 13,
} as const

export function isBot(userAgent: string) {
  return /bot|crawl|spider|crawler|preview|headless|facebookexternalhit|twitterbot/i.test(userAgent)
}

export function detectBrowser(userAgent: string): BrowserInfo {
  if (!userAgent) return { name: 'unknown', version: 0 }

  let match = userAgent.match(/Edg\/(\d+)/i)
  if (match) return { name: 'edge', version: Number.parseInt(match[1], 10) }
  if (/Opera Mini|Opera Mobi/i.test(userAgent)) return { name: 'opera_mini', version: 0 }

  match = userAgent.match(/OPR\/(\d+)/i)
  if (match) return { name: 'opera', version: Number.parseInt(match[1], 10) }
  if (/Trident\//i.test(userAgent) || /MSIE\s\d+/i.test(userAgent)) return { name: 'ie', version: 11 }

  match = userAgent.match(/Firefox\/(\d+)/i)
  if (match) return { name: 'firefox', version: Number.parseInt(match[1], 10) }

  if (/iP(?:hone|ad|od)/i.test(userAgent) && /Safari\//i.test(userAgent)) {
    match = userAgent.match(/OS (\d+)_/i)
    if (match) return { name: 'ios_saf', version: Number.parseInt(match[1], 10) }
  }

  match = userAgent.match(/Chrome\/(\d+)/i) || userAgent.match(/CriOS\/(\d+)/i)
  if (match) return { name: 'chrome', version: Number.parseInt(match[1], 10) }

  if (/Safari\//i.test(userAgent)) {
    match = userAgent.match(/Version\/(\d+)/i)
    if (match) return { name: 'safari', version: Number.parseInt(match[1], 10) }
  }

  return { name: 'unknown', version: 0 }
}

export function isSupportedBrowser(browser: BrowserInfo) {
  if (browser.name === 'unknown') return true
  if (browser.name === 'ie' || browser.name === 'opera_mini') return false

  const minimum = MIN_SUPPORTED_BROWSER_VERSIONS[browser.name as keyof typeof MIN_SUPPORTED_BROWSER_VERSIONS]
  return typeof minimum !== 'number' || browser.version >= minimum
}
