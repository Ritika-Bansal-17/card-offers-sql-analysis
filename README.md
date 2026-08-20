# Card Offers & Merchant Engagement Analysis (SQL Project)

## What is this project about?

I built this project to practice SQL by analyzing a card-linked offers system — the kind of setup where a bank/card company partners with merchants (restaurants, retail stores, travel companies, etc.) to give card members personalized cashback/discount offers.

I made up a fictional platform called **SpendBack Rewards** for this, and generated realistic sample data around it — 50 card members, 15 merchants, 40 offers, and 360 redemption records. I picked this topic because it's close to what analytics teams in fintech/card companies (like credit card offer platforms) actually work on, and I wanted to practice answering real business questions with SQL instead of just doing random practice queries.

I'm not claiming this is real company data — it's all synthetic/sample data made up to simulate realistic patterns (like some merchants being more popular than others, or high-spend customers redeeming offers more often).

## What I was trying to figure out

I wrote a set of queries, each answering a specific business question:

1. Which merchants get the most redemptions and revenue?
2. Do card members redeem more offers depending on their spend tier (Low/Medium/High)?
3. How engaged are card members overall — are most of them one-time users or repeat users?
4. Which merchant category (Dining, Retail, Travel, Grocery, Entertainment) performs best?
5. Who is the top merchant *within* each category (not just overall)?
6. Is revenue growing steadily over time, or is it random spikes?
7. If I combine spend tier + engagement level, which customer segment is most valuable?
8. Which specific offers are getting redeemed the most?
9. Do bigger discounts actually lead to more redemptions, or not really?

## Tools used

- MySQL Workbench (wrote and ran all queries here)

## Files in this repo

- `schema.sql` — creates the database and 4 tables
- `data/` — the 4 CSV files (card_members, merchants, offers, redemptions) to import
- `analysis_queries.sql` — all 9 queries with comments explaining what each one does
- This README

## How the data is structured

Four tables, connected like this:

```
card_members ----\
                   > redemptions <---- offers ---- merchants
```

- `card_members` — the customers (id, name, signup date, spend tier, city)
- `merchants` — the businesses running offers (id, name, category, city)
- `offers` — the actual deals, linked to a merchant
- `redemptions` — every time a member used an offer (this is the main table that connects everyone)

## SQL concepts I used

- Multi-table JOINs (up to 4 tables at once)
- GROUP BY and aggregate functions (COUNT, SUM, AVG)
- CASE statements (to bucket things into Low/Medium/High categories)
- Window functions — RANK() and a running SUM() using OVER()
- A CTE (WITH clause) to break a complex query into readable steps
- LEFT JOIN (to make sure offers with zero redemptions still show up, instead of disappearing)

## What I found (key insights)

**1. Redemption count and revenue don't always match up.**
StyleHub Fashion had the most redemptions, but Café Mocha generated the most total revenue — because Café Mocha's average transaction value was higher, even though both had the same number of offers running. This taught me that "most popular" and "most profitable" can be two different merchants.

**2. Spend tier is a strong predictor of engagement.**
High spend-tier members redeemed offers at almost 3x the rate of Low spend-tier members (around 11 redemptions per person vs. around 3.5). This makes sense, but it was good to actually see it confirmed in the data.

**3. Most members are decently engaged, not just a few power users.**
Only 1 out of 49 members fell into the "low engagement" bucket. Most people were in the medium-to-high engagement range, which is a good sign for a platform like this — it means offers are working for most people, not just a small group.

**4. Dining generated the most revenue, but Travel had the most merchants and redemptions.**
This one surprised me a bit — I expected Travel to have higher transaction values overall since real travel purchases are usually bigger. It's possible this is partly because of how I randomly generated the discount values, so I noted this as something worth double-checking if this were real data.

**5. The most valuable customer segment is High spend-tier + High engagement.**
This group averaged about ₹1,600 in total spend, compared to only about ₹256 for Low spend-tier + Low engagement members. That's a huge gap, and if this were a real business, I'd say this group deserves the most attention (better offers, loyalty perks, etc.), while low-engagement members across all tiers might need some kind of re-engagement push.

**6. Bigger discounts don't automatically mean more redemptions.**
I expected "the bigger the discount, the more people use it" — but Medium-sized discounts actually got redeemed more often per offer than High discounts did. This was probably the most interesting finding for me because it went against what I assumed before running the query.

## What I'd do differently / next steps

- I'd like to eventually connect this to a Power BI dashboard so the insights are visual, not just query output.
- The dataset is fairly small (360 redemptions), so some patterns (like the Dining vs Travel one) might look different with a bigger, more realistic dataset.

## About me

I'm an MA Economics Postgraduate currently learning SQL, Excel, and Power BI to move into a data/business analyst role. This project was built as hands-on practice, combining my economics background with the technical skills I've been picking up.
