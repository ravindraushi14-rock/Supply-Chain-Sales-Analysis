# 06 · Insights and Recommendations

Scope: 2015–2017, 178,396 order lines. Delivery metrics use shipped lines.

## 1. Executive scorecard
| Year | Sales | Profit | Margin | Orders | Customers | AOV | Late % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2015 | $12.34M | $1.32M | 10.69% | 20,904 | 10,131 | $590 | 57.3% |
| 2016 | $12.30M | $1.31M | 10.65% | 20,859 | 10,222 | $590 | 57.5% |
| 2017 | $11.81M | $1.30M | 11.04% | 21,866 | 15,156 | $540 | 57.0% |

## 2. Delivery: a promise problem
| Mode | Promised | Actual | Late % | Sales |
| --- | ---: | ---: | ---: | ---: |
| First Class | 1.0 d | 2.0 d | **100%** | $5.35M |
| Second Class | 2.0 d | 4.0 d | **79.8%** | $6.79M |
| Same Day | 0.0 d | 0.5 d | 48.0% | $1.84M |
| Standard Class | 4.0 d | 4.0 d | 39.8% | $20.91M |

- Lateness is **systemic, not regional**: every market sits between 56.8% and 57.7%.
- **$19.9M of sales** were delivered late. Premium customers pay for speed they don't receive.
- Second Class actual days are spread evenly from 2 to 6, which points to a variable process with no time-definite routing.

## 3. Growth: read 2017 like-for-like
| | Full year 2017 vs 2016 | Jan–Sep 2017 vs 2016 |
| --- | ---: | ---: |
| Sales | −4.0% | **+4.7%** |
| Profit | −0.5% | **+8.0%** |
| Customers | +48.3% | −0.2% |
| AOV | −8.4% | **+4.8%** |

The decline comes from Q4-2017, when orders become single-item and every customer is new. The underlying business **grew**.

## 4. Products and margin
- **8 of 118 products = 85.5% of sales.** Field & Stream Gun Safe ($6.93M), Perfect Fitness Rip Deck ($4.42M) and the Diamondback bike ($4.12M) lead.
- Margins are tight everywhere (≈10–11%), so **discounting is the main margin lever**: 11.8% margin at 0–4% discount vs 9.0% at 20–25%.

## 5. Customers and risk
- **3,660 loss-making customers** (19.8%) generate $7.05M of sales but **−$1.04M profit**, equal to 26.6% of total profit.
- **Suspected fraud: 1,447 orders ($0.82M), all paid by TRANSFER** (~8% of transfer orders in every market).
- Only 33% of orders are complete. **22% are pending payment**, which is a cash-flow risk.

## Recommendations
| # | Action | Expected impact | Owner | Priority |
| --- | --- | --- | --- | --- |
| 1 | Reset First Class SLA to 2 days and Second Class to 4 days (or fix routing to meet the current promise) | Late % for premium modes from 80–100% toward ~40%. Restores customer trust | Logistics | High |
| 2 | Time-definite routing for Second Class (2–6 day spread) | Predictable deliveries | Operations | High |
| 3 | A-class inventory policy for the top 8 products | Protects 85% of revenue from stock-outs | Supply planning | High |
| 4 | Cap discounts above 15% outside A-class products | Margin +1–2 points on affected lines | Sales / Pricing | Medium |
| 5 | Review the 3,660 loss-making accounts (pricing, discount, shipping mode) | Recover part of the $1.04M lost profit | Finance | Medium |
| 6 | Verify transfer payments above a threshold | Cut fraud exposure ($0.82M) | Risk | Medium |
| 7 | Chase pending-payment orders within 48 hours | Faster cash conversion | Finance | Medium |
| 8 | Investigate the Q4-2017 data change before using 2017 for forecasting | Avoids wrong conclusions | Analytics | High |

## Next steps
- A late-delivery prediction model (Python, logistic regression on mode, region and day of week).
- A daily scheduled pipeline, with the dashboard published to the Power BI Service.
