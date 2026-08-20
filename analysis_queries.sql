---ANALYSIS QUERIES: SpendBack Rewards - Card Offers Analytics

USE offers_analytics;

--- ===============================================================
--- QUERY 0: Quick check that all 4 tables join correctly
--- ===============================================================

select r.redemption_id, c.member_name, m.merchant_name, o.offer_description, r.transaction_amount
from card_members c
join redemptions r
on c.member_id = r.member_id
join offers o
on r.offer_id = o.offer_id
join merchants m
on o.merchant_id = m.merchant_id
limit 10;

--- ==============================================================
--- QUERY 1: Top-performing merchants (redemptions + revenue)
--- Business question: Which merchants are driving the most
--- engagement and revenue through the offers platform?
--- ==============================================================

select 
	  m.merchant_id, m.merchant_name, m.category,
      count(r.redemption_id) as total_redemptions,
      sum(r.transaction_amount) as total_revenue,
      round(avg(r.transaction_amount),2) as avg_transaction_value
 from merchants m 
 join offers o 
 on m.merchant_id = o.merchant_id
 join redemptions r
 on o.offer_id = r.offer_id
 group by m.merchant_id, m.merchant_name, m.category
 order by total_redemptions desc;
 
 use offers_analytics;

--- Follow-up check: does a merchant revenue lead come from
--- having more offers, or genuinely higher engagement/value?

 select m.merchant_name, count(o.offer_id) as total_offers
 from merchants m
 join offers o
 on m.merchant_id = o.merchant_id
 group by merchant_name 
 order by total_offers desc;
 
--- ============================================================== 
--- QUERY 2: Redemptions by spend tier
--- Business question: Which spend tier (Low/Medium/High) is
--- redeeming the most offers?
--- ==============================================================
 

 select c.spend_tier,
 count(distinct c.member_id) as total_members,
 count(r.redemption_id) as total_redemption
 from card_members c
 join redemptions r
 on c.member_id = r.member_id
 group by c.spend_tier;
 
--- =============================================================
--- QUERY 3: Member engagement level (Low / Medium / High)
--- Business question: How engaged are card members overall,
--- based on how many times they redeem offers?
--- ============================================================== 
  
 select engagement_type,
 count(*) as total_members
 from (select r.member_id,
       case
       when count(r.redemption_id) <= 1 then 'Low Engagement (1-3)'
       when count(r.redemption_id) <=8 then 'Medium Engagement (4-8)'
       else 'High Engagement (9+)'
end as engagement_type
from redemptions r 
group by r.member_id) as member_engagement
group by engagement_type;

--- ==============================================================
--- QUERY 4: Merchant category performance
--- Business question: Which category (Dining, Retail, Travel,
--- Grocery, Entertainment) drives the most engagement/revenue?
--- ==============================================================

SELECT m.category,
count(m.merchant_id) as num_merchants,
count(r.redemption_id) as total_redemptions,
sum(r.transaction_amount) as total_revenue,
round(sum(r.transaction_amount)/count(m.merchant_id),2) as avg_transaction_value
from merchants m
join offers o
on m.merchant_id = o.merchant_id
join redemptions r
on r.offer_id = o.offer_id
group by m.category
order by total_revenue desc;

--- ==============================================================
---  QUERY 5: Rank merchants within their own category
---  Uses a WINDOW FUNCTION (RANK) to find the top merchant
---  in each category, not just overall.
--- ==============================================================

select category,
	   merchant_name,
       total_redemptions,
       rank() over (partition by category order by total_redemptions desc) 
       as rank_in_category
from (
      select m.merchant_name,
             m.category,
             count(r.redemption_id) as total_redemptions
	  from merchants m
	  join offers o
      on m.merchant_id = o.merchant_id
      join redemptions r
      on o.offer_id = r.offer_id
      group by m.category, m.merchant_name)
      as merchant_totals
order by category, rank_in_category;

--- ==============================================================
--- QUERY 6: Running total of revenue over time
--- Uses a WINDOW FUNCTION (cumulative SUM) to check if
--- revenue is growing steadily or spiking on specific dates.
--- ==============================================================

select redemption_date,
       daily_revenue,
       sum(daily_revenue) over (order by redemption_date) as running_total_revenue
from (
      select redemption_date,
      sum(transaction_amount) as daily_revenue
      from redemptions
      group by redemption_date)
      as daily_totals
order by redemption_date;

--- ==============================================================
--- QUERY 7: Member segmentation - spend tier x engagement level
--- Uses a CTE (WITH clause) to combine spend tier, engagement
--- level, and average spend into one summary table.
--- This ties the whole analysis together.
--- ==============================================================

with member_engagement as (
     select 
           r.member_id,
           count(r.redemption_id) as total_redemptions,
           sum(r.transaction_amount) as total_spend,
           case
               when count(r.redemption_id) <=3 then 'Low Engagement'
               when count(r.redemption_id) <=8 then 'Medium Engagement'
               else 'High Engagement'
			end as engagement_level
            from redemptions r
            group by r.member_id
            )
select 
      c.spend_tier,
      me.engagement_level,
      count(*) as number_of_members,
      round(avg(me.total_spend),2) as avg_spend_per_member
from member_engagement me
join card_members c 
on me.member_id = c.member_id
group by c.spend_tier, me.engagement_level
order by c.spend_tier, me.engagement_level;

--- ==============================================================
---QUERY 8: Offer-level performance
--- Business question: Which specific offers are getting
--- redeemed the most, and how much revenue do they bring in?
--- Uses LEFT JOIN so offers with zero redemptions still show up
--- ==============================================================

select 
      o.offer_id,
      m.merchant_name,
      o.offer_description,
      o.discount_value,
      count(r.redemption_id) as offers_redeemed,
      round(sum(r.transaction_amount),2) as total_revenue
from offers o
left join redemptions r 
on o.offer_id = r.offer_id
join merchants m 
on o.merchant_id = m.merchant_id
group by o.offer_id,
      m.merchant_name,
      o.offer_description,
      o.discount_value
order by offers_redeemed desc
limit 10;

--- ==============================================================
--- QUERY 9: Offer performance by discount size
--- Business question: Do bigger discounts actually lead to
--- more redemptions?
--- ===============================================================

select 
      case 
          when discount_value <=10 then 'Low Discount'
          when discount_value <=40 then 'Medium Discount'
          else 'High Discount'
	  end discount_tier,
      count(distinct o.offer_id) number_of_offers,
      count(r.redemption_id) as offers_redeemed,
      round(count(r.redemption_id)/count(distinct o.offer_id),2) as avg_redemption_per_offer
from offers o
left join redemptions r 
on o.offer_id = r.offer_id
group by discount_tier
order by avg_redemption_per_offer desc;