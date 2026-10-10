import { describe, expect, it } from 'vitest'
import { detectBrowser, isBot, isSupportedBrowser } from '../../lib/browser-support'

describe('browser support policy', () => {
  it('recognizes supported desktop browsers', () => {
    expect(detectBrowser('Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36')).toEqual({
      name: 'chrome',
      version: 120,
    })
    expect(isSupportedBrowser({ name: 'edge', version: 120 })).toBe(true)
  })

  it('uses the iOS operating-system version for iOS Safari', () => {
    const browser = detectBrowser(
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 Version/18.5 Mobile/15E148 Safari/604.1',
    )

    expect(browser).toEqual({ name: 'ios_saf', version: 18 })
    expect(isSupportedBrowser(browser)).toBe(true)
  })

  it('blocks unsupported browsers while allowing unknown user agents', () => {
    expect(isSupportedBrowser({ name: 'chrome', version: 79 })).toBe(false)
    expect(isSupportedBrowser({ name: 'ie', version: 11 })).toBe(false)
    expect(isSupportedBrowser({ name: 'opera_mini', version: 0 })).toBe(false)
    expect(isSupportedBrowser({ name: 'unknown', version: 0 })).toBe(true)
  })

  it('classifies Opera before Chrome', () => {
    const browser = detectBrowser('Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36 OPR/106.0.0.0')

    expect(browser).toEqual({ name: 'opera', version: 106 })
    expect(isSupportedBrowser(browser)).toBe(true)
  })

  it('exempts bots from browser gating', () => {
    expect(isBot('Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)')).toBe(true)
    expect(isBot('Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36')).toBe(false)
  })
})
