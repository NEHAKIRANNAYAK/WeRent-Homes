-- =====================================================================
-- File: real_estate_phase2_fixed.sql
-- CS425 FINAL PROJECT - REAL ESTATE
-- Phase 2: FIXED relational schema + sample data (PostgreSQL)
-- Normalization fixes:
--   - surrogate keys (user_id, renter_id, agent_id, etc.)
--   - separate ADDRESS table (no repeated address columns)
--   - CARD_DETAILS.Card_no as VARCHAR
--   - PROPERTY_TYPE replaced by PROPERTY_CATEGORY + PROPERTY_DETAILS (3NF)
-- =====================================================================

-- Drop tables in dependency order
DROP TABLE IF EXISTS REWARD CASCADE;
DROP TABLE IF EXISTS BOOKING CASCADE;
DROP TABLE IF EXISTS CARD_DETAILS CASCADE;
DROP TABLE IF EXISTS PROPERTY_DETAILS CASCADE;
DROP TABLE IF EXISTS PROPERTY CASCADE;
DROP TABLE IF EXISTS PROPERTY_CATEGORY CASCADE;
DROP TABLE IF EXISTS RENTER CASCADE;
DROP TABLE IF EXISTS AGENT CASCADE;
DROP TABLE IF EXISTS ADDRESS CASCADE;
DROP TABLE IF EXISTS "USER" CASCADE;

-- =====================================================================
-- TABLE DEFINITIONS
-- =====================================================================

-- USER: all people in the system, identified by surrogate key user_id
CREATE TABLE "USER" (
    user_id      SERIAL PRIMARY KEY,
    Email        VARCHAR(50) UNIQUE NOT NULL,
    Phone_number VARCHAR(15) UNIQUE NOT NULL,
    first_name   VARCHAR(50) NOT NULL,
    middle_name  VARCHAR(50),
    last_name    VARCHAR(50) NOT NULL
);

-- ADDRESS: reusable addresses referenced by agents, renters, properties, cards
CREATE TABLE ADDRESS (
    address_id SERIAL PRIMARY KEY,
    line_1     VARCHAR(200) NOT NULL,
    city       VARCHAR(50),
    state_     VARCHAR(50),
    zip_code   VARCHAR(20)
);

-- AGENT: one-to-one with USER where they are an agent
CREATE TABLE AGENT (
    agent_id    SERIAL PRIMARY KEY,
    user_id     INT UNIQUE NOT NULL REFERENCES "USER"(user_id) ON DELETE CASCADE,
    Job_title   VARCHAR(50),
    Agency      VARCHAR(50),
    address_id  INT REFERENCES ADDRESS(address_id) ON DELETE SET NULL,
    Lang_spoken VARCHAR(100)
);

-- RENTER: one-to-one with USER where they are a renter
CREATE TABLE RENTER (
    renter_id     SERIAL PRIMARY KEY,
    user_id       INT UNIQUE NOT NULL REFERENCES "USER"(user_id) ON DELETE CASCADE,
    address_id    INT REFERENCES ADDRESS(address_id) ON DELETE SET NULL,
    Move_in_date  DATE,
    Budget        NUMERIC(10,2),
    Pref_location VARCHAR(100),
    Referral_code VARCHAR(50)
);

-- PROPERTY_CATEGORY: normalized categories (HOUSE, APARTMENT, etc.)
CREATE TABLE PROPERTY_CATEGORY (
    property_category_id SERIAL PRIMARY KEY,
    category_name        VARCHAR(50) UNIQUE NOT NULL
);

-- PROPERTY: physical units managed by an agent, with address
CREATE TABLE PROPERTY (
    Prop_ID              SERIAL PRIMARY KEY,
    agent_id             INT NOT NULL REFERENCES AGENT(agent_id) ON DELETE CASCADE,
    address_id           INT NOT NULL REFERENCES ADDRESS(address_id) ON DELETE CASCADE,
    Sq_ft                INT NOT NULL,
    Price                NUMERIC(10,2),
    Date_of_availability DATE,
    Utilities            BOOLEAN,
    Parking              BOOLEAN DEFAULT FALSE
);

-- PROPERTY_DETAILS: per-property descriptive attributes
CREATE TABLE PROPERTY_DETAILS (
    Prop_ID              INT PRIMARY KEY REFERENCES PROPERTY(Prop_ID) ON DELETE CASCADE,
    property_category_id INT NOT NULL REFERENCES PROPERTY_CATEGORY(property_category_id),
    Description_         VARCHAR(300),
    Rooms                INT,
    Crime_rate           VARCHAR(50),
    business_type        VARCHAR(100)
);

-- CARD_DETAILS: normalized card info (multiple per renter, with billing address)
CREATE TABLE CARD_DETAILS (
    card_id            SERIAL PRIMARY KEY,
    renter_id          INT NOT NULL REFERENCES RENTER(renter_id) ON DELETE CASCADE,
    Card_no            VARCHAR(19) UNIQUE NOT NULL,  -- FIX: no INT, avoid loss of leading zeros
    billing_address_id INT NOT NULL REFERENCES ADDRESS(address_id) ON DELETE CASCADE,
    Name_on_card       VARCHAR(50) NOT NULL
);

-- BOOKING: who booked what, with which card, and when
CREATE TABLE BOOKING (
    Booking_ID   SERIAL PRIMARY KEY,
    Prop_ID      INT NOT NULL REFERENCES PROPERTY(Prop_ID) ON DELETE CASCADE,
    renter_id    INT NOT NULL REFERENCES RENTER(renter_id) ON DELETE CASCADE,
    card_id      INT NOT NULL REFERENCES CARD_DETAILS(card_id) ON DELETE CASCADE,
    Booking_date DATE NOT NULL
);

-- REWARD: reward points per booking and renter
CREATE TABLE REWARD (
    Reward_ID  SERIAL PRIMARY KEY,
    Booking_ID INT NOT NULL REFERENCES BOOKING(Booking_ID) ON DELETE CASCADE,
    renter_id  INT NOT NULL REFERENCES RENTER(renter_id) ON DELETE CASCADE,
    Points     INT
);

-- =====================================================================
-- SAMPLE DATA INSERTION
-- =====================================================================

-- USERS (same people as your original data)
INSERT INTO "USER" (Email, Phone_number, first_name, middle_name, last_name) VALUES
('rajesh.sharma@realty.com',   '312-555-0101', 'Rajesh',     'Kumar',   'Sharma'),
('priya.singh@properties.com', '312-555-0102', 'Priya',      NULL,      'Singh'),
('amit.patel@homes.com',       '312-555-0103', 'Amit',       'Bhai',    'Patel'),
('aishwarya.reddy@email.com',  '312-555-0201', 'Aishwarya',  NULL,      'Reddy'),
('vikram.mehta@email.com',     '312-555-0202', 'Vikram',     'Singh',   'Mehta'),
('kavya.iyer@email.com',       '312-555-0203', 'Kavya',      'Lakshmi', 'Iyer'),
('arjun.desai@email.com',      '312-555-0204', 'Arjun',      NULL,      'Desai'),
('neha.gupta@email.com',       '312-555-0205', 'Neha',       'Priya',   'Gupta'),
('rohit.joshi@email.com',      '312-555-0206', 'Rohit',      'Kumar',   'Joshi'),
('sanjay.nair@email.com',      '312-555-0207', 'Sanjay',     'Ramesh',  'Nair'),
('divya.krishnan@email.com',   '312-555-0208', 'Divya',      NULL,      'Krishnan');

-- =====================================================================
-- AGENTS + their office addresses
-- =====================================================================

-- Rajesh Sharma (agent)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('1250 N Michigan Ave, Suite 500', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO AGENT (user_id, Job_title, Agency, address_id, Lang_spoken)
SELECT u.user_id, 'Senior Agent', 'Dream Realty', addr.address_id, 'English, Hindi, Kannada'
FROM "USER" u, addr
WHERE u.Email = 'rajesh.sharma@realty.com';

-- Priya Singh (agent)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('555 W Lake Street, Floor 12', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO AGENT (user_id, Job_title, Agency, address_id, Lang_spoken)
SELECT u.user_id, 'Property Manager', 'Elite Properties', addr.address_id, 'English, Hindi, Bengali'
FROM "USER" u, addr
WHERE u.Email = 'priya.singh@properties.com';

-- Amit Patel (agent)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('890 Commons Drive', 'Aurora', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO AGENT (user_id, Job_title, Agency, address_id, Lang_spoken)
SELECT u.user_id, 'Real Estate Consultant', 'Premium Homes', addr.address_id, 'English, Hindi, Gujarati'
FROM "USER" u, addr
WHERE u.Email = 'amit.patel@homes.com';

-- =====================================================================
-- RENTERS + their home addresses
-- =====================================================================

-- Aishwarya Reddy
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('234 E Ohio Street, Apt 1205', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-12-01', 2800.00, 'River North', 'REWARD2025A'
FROM "USER" u, addr
WHERE u.Email = 'aishwarya.reddy@email.com';

-- Vikram Mehta
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('678 N Clark Street, Unit 3B', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-11-15', 2200.00, 'Gold Coast', 'REWARD2025B'
FROM "USER" u, addr
WHERE u.Email = 'vikram.mehta@email.com';

-- Kavya Iyer
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('456 Indian Trail', 'Aurora', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-12-10', 1900.00, 'Fox Valley', NULL
FROM "USER" u, addr
WHERE u.Email = 'kavya.iyer@email.com';

-- Arjun Desai
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('789 S State Street, Apt 2201', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2026-01-05', 3500.00, 'South Loop', 'REWARD2025C'
FROM "USER" u, addr
WHERE u.Email = 'arjun.desai@email.com';

-- Neha Gupta
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('321 E Wacker Drive, Unit 1501', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-11-20', 2500.00, 'Streeterville', NULL
FROM "USER" u, addr
WHERE u.Email = 'neha.gupta@email.com';

-- Rohit Joshi
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('987 Prairie Avenue', 'Aurora', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-12-15', 1750.00, 'Downtown Aurora', 'REWARD2025D'
FROM "USER" u, addr
WHERE u.Email = 'rohit.joshi@email.com';

-- Sanjay Nair
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('432 Maple Street, Apt 5C', 'Schaumburg', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2025-12-20', 2100.00, 'Schaumburg', 'REWARD2025E'
FROM "USER" u, addr
WHERE u.Email = 'sanjay.nair@email.com';

-- Divya Krishnan
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('567 Oak Lane', 'Naperville', 'Illinois', NULL)
    RETURNING address_id
)
INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
SELECT u.user_id, addr.address_id, DATE '2026-01-10', 2300.00, 'Naperville', NULL
FROM "USER" u, addr
WHERE u.Email = 'divya.krishnan@email.com';

-- =====================================================================
-- PROPERTY CATEGORIES
-- =====================================================================

INSERT INTO PROPERTY_CATEGORY (category_name) VALUES
('HOUSE'),
('APARTMENT'),
('COMMERCIAL_BUILDING'),
('VACATION_HOME'),
('LAND');

-- =====================================================================
-- PROPERTIES + PROPERTY_DETAILS
-- Each block:
--   - insert property address
--   - insert PROPERTY row (agent + address + base attributes)
--   - insert PROPERTY_DETAILS row with category & description
-- =====================================================================

-- 1: HOUSE - 1000 N Lake Shore Drive (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('1000 N Lake Shore Drive', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 2500, 3500.00, DATE '2025-11-15', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'HOUSE- Beautiful lakefront house with modern amenities and stunning lake views, Near Aurora Central School (0.8 mi)',
       4, 'Low (2.5/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'HOUSE';

-- 2: HOUSE - 250 River Street (Amit)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('250 River Street', 'Aurora', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 2200, 2800.00, DATE '2025-12-10', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'amit.patel@homes.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'HOUSE- Spacious family home with large backyard, perfect for families',
       3, 'Low (3.2/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'HOUSE';

-- 3: HOUSE - 450 Oak Park Avenue (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('450 Oak Park Avenue', 'Oak Park', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 1800, 2600.00, DATE '2025-12-05', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'HOUSE- Charming Victorian house in historic Oak Park neighborhood, Near Oakpark Central School (0.3 mi)',
       3, 'Very Low (1.8/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'HOUSE';

-- 4: APARTMENT - 500 W Superior Street (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('500 W Superior Street', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 850, 2100.00, DATE '2025-12-01', TRUE, FALSE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'APARTMENT- Modern studio in prime River North location, high-rise building',
       1, 'Low (3.0/10))', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'APARTMENT';

-- 5: APARTMENT - 350 E Ohio Street (Priya)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('350 E Ohio Street', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 1500, 3200.00, DATE '2025-11-20', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'priya.singh@properties.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'APARTMENT- Luxury 3-bedroom condo in high-rise with amenities and doorman',
       3, 'Very Low (1.5/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'APARTMENT';

-- 6: APARTMENT - 725 N Dearborn Street (Priya)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('725 N Dearborn Street', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 750, 1850.00, DATE '2025-12-05', FALSE, FALSE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'priya.singh@properties.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'APARTMENT- Affordable studio apartment in mid-rise building near downtown, Near Dearborn Central School (0.9 mi)',
       1, 'Medium (5.5/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'APARTMENT';

-- 7: APARTMENT - 880 N Michigan Avenue (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('880 N Michigan Avenue', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 1800, 4200.00, DATE '2025-12-15', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'APARTMENT- Premium penthouse with panoramic city views, luxury high-rise, Near Michigan High school (0.4 mi)',
       3, 'Very Low (1.2/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'APARTMENT';

-- 8: APARTMENT - 600 S Dearborn Street (Amit)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('600 S Dearborn Street', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 900, 1950.00, DATE '2025-11-25', TRUE, FALSE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'amit.patel@homes.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'APARTMENT- Cozy 2-bedroom apartment in modern mid-rise building',
       2, 'Low (2.8/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'APARTMENT';

-- 9: COMMERCIAL_BUILDING - 600 N Fairbanks Court (Priya)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('600 N Fairbanks Court', 'Chicago', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 3000, 5500.00, DATE '2025-11-28', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'priya.singh@properties.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'COMMERCIAL BUILDING- Modern office space in premier business district with amenities',
       15, 'Low (2.0/10)', 'Office Space'
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'COMMERCIAL_BUILDING';

-- 10: COMMERCIAL_BUILDING - 400 Commons Drive (Amit)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('400 Commons Drive', 'Aurora', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 2000, 4000.00, DATE '2025-11-25', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'amit.patel@homes.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'COMMERCIAL BUILDING- Prime retail space in busy shopping center with high foot traffic',
       8, 'Low (2.5/10)', 'Retail'
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'COMMERCIAL_BUILDING';

-- 11: VACATION_HOME - 789 Lake View Road (Amit)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('789 Lake View Road', 'Lake Geneva', 'Wisconsin', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 1200, 2500.00, DATE '2025-12-01', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'amit.patel@homes.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'VACATION HOME- Cozy cabin by the lake, perfect for weekend getaways and relaxation',
       2, 'Very Low (0.8/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'VACATION_HOME';

-- 12: VACATION_HOME - 321 Mountain Trail (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('321 Mountain Trail', 'Galena', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 1400, 2700.00, DATE '2025-12-20', TRUE, TRUE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'VACATION HOME- Rustic mountain retreat with scenic views and hiking trails nearby',
       3, 'Very Low (1.0/10)', NULL
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'VACATION_HOME';

-- 13: LAND - Highway 59 and Route 30 (Rajesh)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('Highway 59 and Route 30', 'Plainfield', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 43560, 8000.00, DATE '2025-11-30', FALSE, FALSE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'rajesh.sharma@realty.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'LAND- Prime commercial land for development, near major highways',
       NULL, 'Low (2.2/10)', 'Commercial/Mixed Use Development'
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'LAND';

-- 14: LAND - County Road 15, Plot 42 (Priya)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('County Road 15, Plot 42', 'Oswego', 'Illinois', NULL)
    RETURNING address_id
), prop AS (
    INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
    SELECT a.agent_id, addr.address_id, 87120, 12000.00, DATE '2025-12-15', FALSE, FALSE
    FROM AGENT a
    JOIN "USER" u ON a.user_id = u.user_id, addr
    WHERE u.Email = 'priya.singh@properties.com'
    RETURNING Prop_ID
)
INSERT INTO PROPERTY_DETAILS (Prop_ID, property_category_id, Description_, Rooms, Crime_rate, business_type)
SELECT prop.Prop_ID, pc.property_category_id,
       'LAND- Large agricultural/residential land parcel with development potential, Near Oswego Central School (1.2 mi)',
       NULL, 'Very Low (1.5/10)', 'Agricultural/Residential Development'
FROM prop, PROPERTY_CATEGORY pc
WHERE pc.category_name = 'LAND';

-- =====================================================================
-- CARD_DETAILS (billing addresses normalized)
-- =====================================================================

-- For each card: create billing address row (line_1 = full string), link to renter

-- Aishwarya (2 cards)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('234 E Ohio Street, Apt 1205, Chicago, IL 60611', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '123456780', addr.address_id, 'Aishwarya Reddy'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'aishwarya.reddy@email.com';

WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('234 E Ohio Street, Apt 1205, Chicago, IL 60611', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '123456791', addr.address_id, 'Aishwarya Reddy'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'aishwarya.reddy@email.com';

-- Vikram
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('678 N Clark Street, Unit 3B, Chicago, IL 60654', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '234567901', addr.address_id, 'Vikram S Mehta'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'vikram.mehta@email.com';

-- Kavya
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('456 Indian Trail, Aurora, IL 60506', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '345679012', addr.address_id, 'Kavya L Iyer'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'kavya.iyer@email.com';

-- Arjun (3 cards)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('789 S State Street, Apt 2201, Chicago, IL 60605', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '456790123', addr.address_id, 'Arjun Desai'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'arjun.desai@email.com';

WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('789 S State Street, Apt 2201, Chicago, IL 60605', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '456890124', addr.address_id, 'Arjun Desai'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'arjun.desai@email.com';

WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('789 S State Street, Apt 2201, Chicago, IL 60605', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '457890125', addr.address_id, 'Arjun Desai'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'arjun.desai@email.com';

-- Neha
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('321 E Wacker Drive, Unit 1501, Chicago, IL 60601', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '578901234', addr.address_id, 'Neha P Gupta'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'neha.gupta@email.com';

-- Rohit (2 cards)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('987 Prairie Avenue, Aurora, IL 60505', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '789012345', addr.address_id, 'Rohit K Joshi'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'rohit.joshi@email.com';

WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('987 Prairie Avenue, Aurora, IL 60505', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '789012346', addr.address_id, 'Rohit K Joshi'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'rohit.joshi@email.com';

-- Sanjay (2 cards)
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('432 Maple Street, Apt 5C, Schaumburg, IL 60173', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '890123456', addr.address_id, 'Sanjay R Nair'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'sanjay.nair@email.com';

WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('432 Maple Street, Apt 5C, Schaumburg, IL 60173', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '890123457', addr.address_id, 'Sanjay R Nair'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'sanjay.nair@email.com';

-- Divya
WITH addr AS (
    INSERT INTO ADDRESS (line_1, city, state_, zip_code)
    VALUES ('567 Oak Lane, Naperville, IL 60540', NULL, NULL, NULL)
    RETURNING address_id
)
INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
SELECT r.renter_id, '901234567', addr.address_id, 'Divya Krishnan'
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id, addr
WHERE u.Email = 'divya.krishnan@email.com';

-- =====================================================================
-- BOOKINGS (using normalized renter_id and card_id)
--   Mapping your original:
--     Prop_ID, renter email, card_no, booking_date
-- =====================================================================

-- 1: (1, 'aishwarya...', 123456780, '2025-11-01')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-01'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 1
  AND r.user_id = u.user_id AND u.Email = 'aishwarya.reddy@email.com'
  AND c.Card_no = '123456780';

-- 2: (5, 'arjun...', 456790123, '2025-11-02')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-02'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 5
  AND r.user_id = u.user_id AND u.Email = 'arjun.desai@email.com'
  AND c.Card_no = '456790123';

-- 3: (2, 'vikram...', 234567901, '2025-11-03')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-03'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 2
  AND r.user_id = u.user_id AND u.Email = 'vikram.mehta@email.com'
  AND c.Card_no = '234567901';

-- 4: (4, 'neha...', 578901234, '2025-11-04')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-04'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 4
  AND r.user_id = u.user_id AND u.Email = 'neha.gupta@email.com'
  AND c.Card_no = '578901234';

-- 5: (11, 'sanjay...', 890123456, '2025-11-05')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-05'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 11
  AND r.user_id = u.user_id AND u.Email = 'sanjay.nair@email.com'
  AND c.Card_no = '890123456';

-- 6: (8, 'rohit...', 789012345, '2025-11-06')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-06'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 8
  AND r.user_id = u.user_id AND u.Email = 'rohit.joshi@email.com'
  AND c.Card_no = '789012345';

-- 7: (7, 'arjun...', 456890124, '2025-11-07')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-07'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 7
  AND r.user_id = u.user_id AND u.Email = 'arjun.desai@email.com'
  AND c.Card_no = '456890124';

-- 8: (3, 'divya...', 901234567, '2025-11-08')
INSERT INTO BOOKING (Prop_ID, renter_id, card_id, Booking_date)
SELECT p.Prop_ID, r.renter_id, c.card_id, DATE '2025-11-08'
FROM PROPERTY p, RENTER r, "USER" u, CARD_DETAILS c
WHERE p.Prop_ID = 3
  AND r.user_id = u.user_id AND u.Email = 'divya.krishnan@email.com'
  AND c.Card_no = '901234567';

-- =====================================================================
-- REWARDS (points equal to rental price for each booking, as in your data)
--   Using the same points as your original REWARD table
-- =====================================================================

-- Booking 1: 3500 (Aishwarya)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 1, r.renter_id, 3500
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'aishwarya.reddy@email.com';

-- Booking 2: 3200 (Arjun)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 2, r.renter_id, 3200
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'arjun.desai@email.com';

-- Booking 3: 2800 (Vikram)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 3, r.renter_id, 2800
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'vikram.mehta@email.com';

-- Booking 5: 2500 (Sanjay)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 5, r.renter_id, 2500
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'sanjay.nair@email.com';

-- Booking 6: 1950 (Rohit)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 6, r.renter_id, 1950
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'rohit.joshi@email.com';

-- Booking 7: 4200 (Arjun)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 7, r.renter_id, 4200
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'arjun.desai@email.com';

-- Booking 8: 2600 (Divya)
INSERT INTO REWARD (Booking_ID, renter_id, Points)
SELECT 8, r.renter_id, 2600
FROM RENTER r
JOIN "USER" u ON r.user_id = u.user_id
WHERE u.Email = 'divya.krishnan@email.com';

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================