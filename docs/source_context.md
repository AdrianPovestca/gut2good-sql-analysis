# Source Context — Original Deck Figures

This dataset is **simulated**, not real transactional data. It was built to
be analytically consistent with the figures presented in the original
Gut2Good "US Market Expansion Strategy" deck, so that the SQL queries in
this repo answer real business questions instead of arbitrary ones.

Original figures referenced from the deck:

| Metric                                   | Deck figure        |
|-------------------------------------------|---------------------|
| US Digestive Health market size (2025)    | $15.8 Billion       |
| US shoppers prioritizing "clean-label"    | 81%                 |
| Pinterest conversion rate (search intent) | 2.2%                |
| Facebook conversion rate (interruption)   | 1.2%                |
| Revenue mix — 7-Day Reset Guide           | 60%                 |
| Revenue mix — 15-Min Recipe Guide         | 30%                 |
| Revenue mix — Upsells / Custom Plans      | 10%                 |

The simulated dataset (`generate_data.py`) was calibrated to land close to
these figures so the SQL analysis tests whether the *underlying day-by-day
data* supports the deck's headline claims — which is exactly the kind of
sanity-check a Data Analyst would be asked to run before a strategy deck
goes to investors or leadership.

No real customer, order, or payment data is included in this repository.
