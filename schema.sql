--- SCHEMA: SpendBack Rewards - Card Offers Analytics


create database offers_analytics;
use offers_analytics;

CREATE TABLE card_members
(member_id int primary key,
 member_name varchar(50), 
 signup_date date, 
 spend_tier varchar(10),
 city varchar(50));
 
 create table merchants (
 merchant_id int primary key,
 merchant_name varchar(100),
 category varchar(50),
 city varchar(50));

create table offers (
offer_id int primary key,
merchant_id int,
offer_description varchar(200),
start_date date,
end_date date,
foreign key (merchant_id) references merchants(merchant_id));

create table redemptions(
redemption_id int primary key,
member_id int,
offer_id int,
redemption_date date,
transaction_amount decimal(10,2),
foreign key (member_id) references card_members(member_id),
foreign key (offer_id) references offers(offer_id));

--- added discount column after creating the tables

alter table offers add column discount_value decimal(10,2) after offer_description;

--- Imported CSV files using MySQL WorkBench's table data import wizard


--- Quick checks after importing.

select count(*) from card_members;
select count(*) from merchants;
select count(*) from offers;
select count(*) from redemptions;