-- =========================================================
-- Sample Data for WeRent Homes
-- Group 16
-- =========================================================

-- =========================
-- USER TABLE
-- =========================
INSERT INTO "USER" (Email, Phone_number, first_name, middle_name, last_name) VALUES
('rajesh.sharma@realty.com', '312-555-0101', 'Rajesh', 'Kumar', 'Sharma'),
('priya.singh@properties.com', '312-555-0102', 'Priya', NULL, 'Singh'),
('amit.patel@homes.com', '312-555-0103', 'Amit', 'Bhai', 'Patel'),
('aishwarya.reddy@email.com', '312-555-0201', 'Aishwarya', NULL, 'Reddy'),
('vikram.mehta@email.com', '312-555-0202', 'Vikram', 'Singh', 'Mehta'),
('kavya.iyer@email.com', '312-555-0203', 'Kavya', 'Lakshmi', 'Iyer'),
('arjun.desai@email.com', '312-555-0204', 'Arjun', NULL, 'Desai'),
('neha.gupta@email.com', '312-555-0205', 'Neha', 'Priya', 'Gupta'),
('rohit.joshi@email.com', '312-555-0206', 'Rohit', 'Kumar', 'Joshi'),
('sanjay.nair@email.com', '312-555-0207', 'Sanjay', 'Ramesh', 'Nair'),
('divya.krishnan@email.com', '312-555-0208', 'Divya', NULL, 'Krishnan');

-- =========================
-- AGENT TABLE
-- =========================
INSERT INTO AGENT (Email, Job_title, Agency, line_1, city, state_, Lang_spoken) VALUES
('rajesh.sharma@realty.com', 'Senior Agent', 'Dream Realty',
 '1250 N Michigan Ave, Suite 500', 'Chicago', 'Illinois', 'English, Hindi'),
('priya.singh@properties.com', 'Property Manager', 'Elite Properties',
 '555 W Lake Street, Floor 12', 'Chicago', 'Illinois', 'English, Hindi'),
('amit.patel@homes.com', 'Real Estate Consultant', 'Premium Homes',
 '890 Commons Drive', 'Aurora', 'Illinois', 'English, Gujarati');

-- =========================
-- RENTER TABLE
-- =========================
INSERT INTO RENTER (Email, line_1, city, state_, Move_in_date, Budget, Pref_location, Referral_code) VALUES
('aishwarya.reddy@email.com', '234 E Ohio Street', 'Chicago', 'Illinois',
 '2025-12-01', 2800, 'River North', 'REWARD2025A'),
('vikram.mehta@email.com', '678 N Clark Street', 'Chicago', 'Illinois',
 '2025-11-15', 2200, 'Gold Coast', 'REWARD2025B'),
('kavya.iyer@email.com', '456 Indian Trail', 'Aurora', 'Illinois',
 '2025-12-10', 1900, 'Fox Valley', NULL),
('arjun.desai@email.com', '789 S State Street', 'Chicago', 'Illinois',
 '2026-01-05', 3500, 'South Loop', 'REWARD2025C'),
('neha.gupta@email.com', '321 E Wacker Drive', 'Chicago', 'Illinois',
 '2025-11-20', 2500, 'Streeterville', NULL),
('rohit.joshi@email.com', '987 Prairie Avenue', 'Aurora', 'Illinois',
 '2025-12-15', 1750, 'Downtown Aurora', 'REWARD2025D'),
('sanjay.nair@email.com', '432 Maple Street', 'Schaumburg', 'Illinois',
 '2025-12-20', 2100, 'Schaumburg', 'REWARD2025E'),
('divya.krishnan@email.com', '567 Oak Lane', 'Naperville', 'Illinois',
 '2026-01-10', 2300, 'Naperville', NULL);

-- =========================
-- CARD DETAILS
-- =========================
INSERT INTO CARD_DETAILS (Card_no, Email, Billing_address, Name_on_card) VALUES
(123456780, 'aishwarya.reddy@email.com', '234 E Ohio Street, Chicago, IL', 'Aishwarya Reddy'),
(234567901, 'vikram.mehta@email.com', '678 N Clark Street, Chicago, IL', 'Vikram Mehta'),
(345679012, 'kavya.iyer@email.com', '456 Indian Trail, Aurora, IL', 'Kavya Iyer'),
(456790123, 'arjun.desai@email.com', '789 S State Street, Chicago, IL', 'Arjun Desai'),
(578901234, 'neha.gupta@email.com', '321 E Wacker Drive, Chicago, IL', 'Neha Gupta'),
(789012345, 'rohit.joshi@email.com', '987 Prairie Avenue, Aurora, IL', 'Rohit Joshi'),
(890123456, 'sanjay.nair@email.com', '432 Maple Street, Schaumburg, IL', 'Sanjay Nair'),
(901234567, 'divya.krishnan@email.com', '567 Oak Lane, Naperville, IL', 'Divya Krishnan');

-- =========================
-- PROPERTY TABLE
-- =========================
INSERT INTO PROPERTY (Email, Location_, City, state_, Sq_ft, Price,
                      Date_of_availability, Utilities, Parking) VALUES
('rajesh.sharma@realty.com', '1000 N Lake Shore Drive', 'Chicago', 'Illinois',
 2500, 3500, '2025-11-15', TRUE, TRUE),
('amit.patel@homes.com', '250 River Street', 'Aurora', 'Illinois',
 2200, 2800, '2025-12-10', TRUE, TRUE),
('priya.singh@properties.com', '350 E Ohio Street', 'Chicago', 'Illinois',
 1500, 3200, '2025-11-20', TRUE, TRUE);

-- =========================
-- PROPERTY TYPE
-- =========================
INSERT INTO PROPERTY_TYPE (Prop_ID, Description_, Rooms, Crime_rate, business_type) VALUES
(1, 'Luxury lakefront house', 4, 'Low', NULL),
(2, 'Spacious family home', 3, 'Low', NULL),
(3, 'High-rise apartment', 3, 'Very Low', NULL);

-- =========================
-- BOOKING
-- =========================
INSERT INTO BOOKING (Prop_ID, Email, Card_no, Booking_date) VALUES
(1, 'aishwarya.reddy@email.com', 123456780, '2025-11-01'),
(2, 'vikram.mehta@email.com', 234567901, '2025-11-03'),
(3, 'arjun.desai@email.com', 456790123, '2025-11-02');

-- =========================
-- REWARD
-- =========================
INSERT INTO REWARD (Booking_ID, Email, Points) VALUES
(1, 'aishwarya.reddy@email.com', 3500),
(2, 'vikram.mehta@email.com', 2800),
(3, 'arjun.desai@email.com', 3200);