create database hotel_reservation_db;
use hotel_reservation_db;

CREATE TABLE hotels (
hotel_id varchar(20) primary key,
hotel_name varchar(50) not null,
city varchar(20),
star_rating int ,
total_rooms int ,
opened_date date 
);
select * from hotels;

CREATE TABLE guests(
guest_id varchar(20) primary key,
guest_name varchar(30)not null,
city varchar(40),
guest_type varchar(30),
preferred_room_type varchar(40),
loyalty_tier varchar(30),
account_since date 
);
select * from guests;


CREATE TABLE bookings (
booking_id varchar(20) primary key ,
guest_id varchar(20),
hotel_id varchar(20),
booking_date date ,
room_type_requested varchar(20),
booking_channel varchar(30),
nights_booked int ,
total_amount decimal(10,2) ,
constraint fk_bookings_guests foreign key(guest_id) references guests(guest_id),
constraint fk_bookings_hotels foreign key(hotel_id) references hotels(hotel_id)
 );
 
 select * from bookings;

CREATE TABLE rooms  (
room_id varchar(20) primary key ,
hotel_id varchar(20),
room_type varchar(30),
floor_number int ,
max_occupancy int ,
price_per_night decimal(10,2) not null,
is_active varchar(5)not null,
constraint fk_rooms_hotels foreign key(hotel_id) references hotels(hotel_id)
);
select * from rooms;


CREATE TABLE staff(
staff_id varchar(20) primary key ,
staff_name varchar(30)not null,
hire_date date ,
rating decimal(3,2),
department varchar(30),
is_active varchar(10)not null
);
select * from staff;


CREATE TABLE stays (
stay_id varchar(20)primary key,
booking_id varchar(20),
room_id varchar(20),
staff_id varchar(20) ,
check_in_date date ,
check_out_date date ,
status varchar(30),
nights_stayed int,
service_requests int,
stay_duration_hrs int,
constraint fk_stays_bookings foreign key(booking_id) references bookings(booking_id),
constraint fk_stays_rooms foreign key(room_id) references rooms(room_id),
constraint fk_stays_staff foreign key(staff_id ) references staff(staff_id )
);
select * from stays;

-- 1. What is the total number of guests?
select count(*) as total_num_of_guests from guests ;

-- 2. What is the total number of bookings?
select count(*) total_num_of_bookings from bookings;

-- 3. What is the total number of stays?
select count(*) total_num_of_stays from stays ;

-- 4. What are the different room types available?
select distinct room_type as room_types from rooms;

-- 5. How many staff members are currently active?
select count(*)as num_of_saff_active  from staff
where is_active = "Yes";

-- 6. What are the different booking channels?
select distinct booking_channel from bookings ;

-- 7. What is the total booking amount across all bookings?
select sum(total_amount) as total_amount_of_all_bookings from bookings ;

-- 8. What is the average nights booked per booking?
select avg(nights_booked) as avg_nights_booked  from bookings;



-- 4.1 Understand Booking Demand 
-- Which hotel receives the highest number of bookings?
select b.hotel_id ,hotel_name,count(*) as highest_num_of_bookings 
from bookings b
join hotels h 
on b.hotel_id=h.hotel_id
group by hotel_id 
order by highest_num_of_bookings desc
limit 1;

-- 2. Which booking channel generates the most bookings?
select booking_channel,count(*) as most_bookings from bookings
group by booking_channel
order by most_bookings desc
limit 1;

-- 3.Which room type has the highest booking demand?
select room_type_requested,count(*) as highest_booking_demand from bookings
group by room_type_requested
order by highest_booking_demand desc
limit 1;

-- 4.How does booking demand change over time (month/year)?
select monthNAME(booking_date),count(*) as demand from bookings
group by monthNAME(booking_date)
order by  demand desc ;

-- 5.Which hotel, booking channel, or room type generates the highest total booking amount?
select h.hotel_name,b.booking_channel,b.room_type_requested,
sum(b.total_amount ) as highest_total_booking_amount
from bookings b
join hotels h 
on b.hotel_id=h.hotel_id
 group by  h.hotel_name,b.booking_channel,b.room_type_requested
order by highest_total_booking_amount desc;


-- 4.2 Understand Guest Booking Behaviour
-- 1.Which guests have made the highest number of bookings?
select b.guest_id,guest_name,count(*) as highest_number_of_bookings 
from bookings b
join guests g 
on b.guest_id=g.guest_id
group by guest_id
order by highest_number_of_bookings desc limit 1;

-- 2 . Which guests have generated the highest total booking amount?
select b.guest_id ,guest_name ,sum(total_amount) as booking_amount from bookings b
join guests g on b.guest_id = g.guest_id 
group by b.guest_id
order by  booking_amount desc limit 1;

-- 3 Which hotels have the highest number of unique guests?
select hotel_id ,count(distinct guest_id) as num_of_unique_guest from bookings 
group by hotel_id 
order by num_of_unique_guest desc  limit 1;

-- 4. How does the average booking amount differ between Individual and Corporate guests?
select avg(case when guest_type="Individual" then total_amount end) 
as individual_avg,
avg(case when guest_type="Corporate" then total_amount end) as corporate_avg,
abs(avg(case when guest_type="Individual" then total_amount end)-
avg(case when guest_type="Corporate" then total_amount end)) as difference 
from bookings b
join guests g 
on b.guest_id=g.guest_id;

-- 5.Which guest type generates the highest total booking revenue?

select guest_type,count(*) as highest_total_booking_revenue
 from bookings b
 join guests g 
 on b.guest_id=g.guest_id
 group by guest_type
 order by highest_total_booking_revenue desc
 limit 1;

-- 6.Which guests have made bookings at multiple hotels?
select guest_name,b.guest_id,count(distinct b.hotel_id) as multiple_hotels
from guests g 
join bookings b 
on g.guest_id=b.guest_id
join hotels h
on b.hotel_id=h.hotel_id
group by b.guest_id
order by multiple_hotels desc;

-- 7.What is the monthly booking trend based on the booking data ?
select  monthname(booking_date) as booking_month ,count(*)as num_of_bookings from bookings
group by monthname(booking_date);

-- 4.3 Evaluate Stay Performance
--  1. How many stays are there for each stay status?
select status,count(*) as total_stays from stays group by status;

-- 2. What is the average stay duration for each stay status?
select status,avg(stay_duration_hrs) as average_duration from stays group by status;
select * from stays;

-- 3.how do stay outcomes compare across different
 select status, COUNT(*) AS total_stays from stays GROUP BY status
ORDER BY total_stays DESC;

-- 4.Which hotels have the highest number of completed and unsuccessful stays?
select h.hotel_name,s.status,COUNT(*) AS total_stays
FROM stays s
JOIN bookings b
    ON s.booking_id = b.booking_id
JOIN hotels h
    ON b.hotel_id = h.hotel_id
WHERE s.status IN ('Checked-out', 'Cancelled', 'No-show')
GROUP BY h.hotel_name, s.status
ORDER BY total_stays DESC;

-- 5.How does stay performance change over time?
SELECT
    YEAR(check_in_date) AS year,
    status,
    COUNT(*) AS total_stays
FROM stays
GROUP BY YEAR(check_in_date), status
ORDER BY year, status;


-- 4.4 Understand Staff and Room Performance

-- 1.How many stays are handled by each staff member?
select staff_id,count(*) as total_stays from stays group by staff_id order by total_stays desc;

-- 2.How do stay outcomes vary across different staff members?
-- (Checked-out, No-show, Cancelled, In-progress)
select staff_id,status,count(*) as total_stays from stays group by staff_id,status order by 
staff_id,total_stays desc;

-- 3.What is the average stay duration handled by each staff member?
select staff_id,avg(stay_duration_hrs) as avg_stay_duration from stays
group by staff_id order by  avg_stay_duration desc;

-- 4.How is room usage distributed across different room types?
select r.room_type,count(*) as total_stays from stays s join rooms r 
on s.room_id=r.room_id group by r.room_type order by total_stays desc;

-- 5.How do stay outcomes vary across different room types?
select r.room_type,s.status,count(*) as total_stays from stays s join rooms r 
on s.room_id=r.room_id group by r.room_type,s.status order by r.room_type,total_stays desc;


-- 4.5 Identify Booking and Stay Problems
-- 1. How many bookings resulted in each stay outcome?
select status,count(*) as total_stays from stays group by status order by total_stays desc;

-- 2. How many bookings resulted in cancellations or no-shows?
select status,count(*) as total_problem_bookings from stays where status in ('cancelled','No-show') 
group by status order by total_problem_bookings desc;

-- 3. Which bookings resulted in cancellations or no-shows?
select booking_id,status from stays where status in ('cancelled','No-show') order by status,booking_id;

-- 4. Do bookings with more service requests have more stay problems?
select service_requests,status,count(*) AS total_stays FROM stays
group by service_requests, status order by service_requests, status;

-- 5. How do stay outcomes differ between low and high service-request bookings?
select
    case
        when service_requests = 0 then 'No requests'
        when service_requests between 1 and 2 then 'Low requests'
        else 'High requests'
    end as request_level,
    status,
    count(*) AS total_stays
from stays
group by request_level, status
order by request_level, total_stays DESC;