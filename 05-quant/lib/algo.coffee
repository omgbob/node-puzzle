Decimal = require 'decimal.js'

###*
 * This is heart of our trading bot. Function below is called
 * for every candle from the history. As a result an order is
 * expected, however not mandatory.
 *
 * Our dummy algorithm works as following:
 *  - in 1/3 of cases we sell $1
 *  - in 1/3 of cases we buy $1
 *  - in 1/3 of cases we do nothing
 *
 * @param {float}   [price]   Average (weighted) price
 * @param {Object}  [candle]  Candle data with `time`, `open`, `high`, `low`, `close`,
 *                            `volume` values for given `time` interval.
 * @param {Object}  [account] Your account information. It has _realtime_ balance of USD and BTC
 * @returns {object}          An order to be executed, can be null
###
exports.tick = (price, candle, account) ->

  # convert candle Float values into Decimal objects
  candleOpen = new Decimal candle.open
  candleHigh = new Decimal candle.high
  candleLow = new Decimal candle.low
  candleClose = new Decimal candle.close

  # start analysing the candle
  analysis =
    trend: '??'
    direction: '??'
    height: (candleOpen.minus candleClose).toNumber()

  if analysis.height > 0
    analysis.direction = 'down'
    analysis.trend = 'bearish'
    analysis.topWick = (candleHigh.minus candleOpen).toNumber()
    analysis.bottomWick = (candleClose.minus candleLow).toNumber()
  else
    analysis.height = Math.abs analysis.height
    analysis.direction = 'up'
    analysis.trend = 'bullish'
    analysis.topWick = (candleHigh.minus candleClose).toNumber()
    analysis.bottomWick = (candleOpen.minus candleLow).toNumber()

  # bullish, rising
  # bearish, falling

  accountMin = 1000
  accountWorth = account.USD + (account.BTC * price)

  if analysis.trend is 'bearish'
    # sell BTC if we have any available
    if account.BTC > 1
      return buy: (account.BTC - 0.001) * price
  else
    # buy as many BTC as we can and stay above $1000 total worth
    # if accountWorth > accountMin
    #   availableUSD = accountWorth - accountMin - (account.BTC * price)
    #   if availableUSD > 0
    #     return sell: availableUSD
    # buy BTC if we have enough USD
    if account.USD > price
      return sell: account.USD

  return null # do nothing

