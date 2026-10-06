-- BUS RESERVATION & FLEET SCHEDULING SYSTEM
-- Complete MySQL database and sample data

DROP DATABASE IF EXISTS bus_reservation_db;
CREATE DATABASE bus_reservation_db;
USE bus_reservation_db;

CREATE TABLE Routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    distance_km DECIMAL(8,2) NOT NULL,
    CHECK (distance_km > 0)
);

CREATE TABLE Stops (
    stop_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    stop_name VARCHAR(100) NOT NULL,
    stop_order INT NOT NULL,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    CHECK (stop_order > 0)
);

CREATE TABLE Buses (
    bus_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_number VARCHAR(20) NOT NULL UNIQUE,
    bus_type VARCHAR(50) NOT NULL,
    total_seats INT NOT NULL,
    CHECK (total_seats > 0)
);

CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type VARCHAR(30) DEFAULT 'Regular',
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id),
    UNIQUE (bus_id, seat_number)
);

CREATE TABLE Employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL,
    salary DECIMAL(10,2),
    CHECK (role IN ('Driver', 'Conductor'))
);

CREATE TABLE Schedules (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    bus_id INT NOT NULL,
    trip_date DATE NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    base_fare DECIMAL(8,2) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'Scheduled',
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id),
    CHECK (base_fare > 0),
    CHECK (status IN ('Scheduled','Departed','Completed','Cancelled')),
    CHECK (arrival_time > departure_time)
);

CREATE TABLE Crew_Assignment (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    emp_id INT NOT NULL,
    duty_role VARCHAR(20) NOT NULL,
    FOREIGN KEY (trip_id) REFERENCES Schedules(trip_id),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    CHECK (duty_role IN ('Driver','Conductor')),
    UNIQUE (trip_id, duty_role)
);

CREATE TABLE Passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    date_of_birth DATE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    CHECK (gender IN ('Male','Female','Other'))
);

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    seat_id INT NOT NULL,
    passenger_id INT NOT NULL,
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    fare_amount DECIMAL(8,2) NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'Confirmed',
    FOREIGN KEY (trip_id) REFERENCES Schedules(trip_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
    CHECK (fare_amount > 0),
    CHECK (status IN ('Confirmed','Cancelled'))
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(8,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Paid',
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CHECK (amount > 0),
    CHECK (payment_method IN ('UPI','Card','Cash','Net Banking')),
    CHECK (payment_status IN ('Paid','Pending','Failed','Refunded'))
);

CREATE TABLE Cancellations (
    cancellation_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    cancellation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255),
    refund_amount DECIMAL(8,2) DEFAULT 0,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    CHECK (refund_amount >= 0)
);

INSERT INTO Routes (source,destination,distance_km) VALUES
('Hyderabad','Vijayawada',275),('Hyderabad','Bengaluru',570),
('Hyderabad','Chennai',630),('Vijayawada','Chennai',430),
('Hyderabad','Warangal',150);

INSERT INTO Stops (route_id,stop_name,stop_order) VALUES
(1,'LB Nagar',1),(1,'Suryapet',2),(1,'Vijayawada',3),
(2,'LB Nagar',1),(2,'Kurnool',2),(2,'Bengaluru',3),
(3,'LB Nagar',1),(3,'Nellore',2),(3,'Chennai',3),
(4,'Vijayawada',1),(4,'Nellore',2),(4,'Chennai',3),
(5,'Uppal',1),(5,'Jangaon',2),(5,'Warangal',3);

INSERT INTO Buses (bus_number,bus_type,total_seats) VALUES
('TS09AB1234','AC Sleeper',40),('TS09CD5678','Volvo AC',40),
('TS09EF9012','AC Seater',40),('TS09GH3456','Volvo Sleeper',40),
('TS09JK7890','AC Seater',40);

INSERT INTO Seats (bus_id,seat_number,seat_type)
SELECT b.bus_id,
       CONCAT(CHAR(65 + FLOOR((n.num-1)/4)),((n.num-1)%4)+1),
       CASE WHEN n.num <= 8 THEN 'Premium' ELSE 'Regular' END
FROM Buses b
CROSS JOIN (
SELECT 1 num UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24
UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28
UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31 UNION ALL SELECT 32
UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36
UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40
) n;

INSERT INTO Employees (emp_name,phone,role,salary) VALUES
('Ravi Kumar','9000000001','Driver',32000),
('Suresh Reddy','9000000002','Driver',34000),
('Vikram Singh','9000000003','Driver',33000),
('Arun Kumar','9000000004','Driver',31000),
('Mahesh Rao','9000000005','Driver',35000),
('Anitha Rao','9000000011','Conductor',22000),
('Kiran Babu','9000000012','Conductor',23000),
('Swathi Reddy','9000000013','Conductor',21000),
('Priya Nair','9000000014','Conductor',22500),
('Deepak Sharma','9000000015','Conductor',24000);

INSERT INTO Schedules
(route_id,bus_id,trip_date,departure_time,arrival_time,base_fare,status) VALUES
(1,1,'2026-10-10','2026-10-10 06:00:00','2026-10-10 10:30:00',450,'Scheduled'),
(2,2,'2026-10-10','2026-10-10 20:00:00','2026-10-11 06:00:00',900,'Scheduled'),
(3,3,'2026-10-11','2026-10-11 07:00:00','2026-10-11 18:00:00',1000,'Scheduled'),
(4,4,'2026-10-11','2026-10-11 21:00:00','2026-10-12 06:00:00',650,'Scheduled'),
(5,5,'2026-10-12','2026-10-12 08:00:00','2026-10-12 11:00:00',300,'Scheduled'),
(1,1,'2026-10-12','2026-10-12 14:00:00','2026-10-12 18:30:00',450,'Scheduled'),
(2,2,'2026-10-13','2026-10-13 20:00:00','2026-10-14 06:00:00',900,'Scheduled'),
(3,3,'2026-10-14','2026-10-14 07:00:00','2026-10-14 18:00:00',1000,'Scheduled'),
(4,4,'2026-10-15','2026-10-15 21:00:00','2026-10-16 06:00:00',650,'Scheduled'),
(5,5,'2026-10-16','2026-10-16 08:00:00','2026-10-16 11:00:00',300,'Scheduled');

INSERT INTO Crew_Assignment (trip_id,emp_id,duty_role) VALUES
(1,1,'Driver'),(1,6,'Conductor'),(2,2,'Driver'),(2,7,'Conductor'),
(3,3,'Driver'),(3,8,'Conductor'),(4,4,'Driver'),(4,9,'Conductor'),
(5,5,'Driver'),(5,10,'Conductor'),(6,1,'Driver'),(6,6,'Conductor'),
(7,2,'Driver'),(7,7,'Conductor'),(8,3,'Driver'),(8,8,'Conductor'),
(9,4,'Driver'),(9,9,'Conductor'),(10,5,'Driver'),(10,10,'Conductor');

INSERT INTO Passengers
(first_name,last_name,gender,date_of_birth,phone,email,address) VALUES
('Rahul','Sharma','Male','2002-05-14','9876543210','rahul.sharma@gmail.com','Hyderabad, Telangana'),
('Priya','Reddy','Female','2001-08-21','9876543211','priya.reddy@gmail.com','Secunderabad, Telangana'),
('Arjun','Kumar','Male','2003-01-10','9876543212','arjun.kumar@gmail.com','Vijayawada, Andhra Pradesh'),
('Sneha','Patel','Female','2002-11-05','9876543213','sneha.patel@gmail.com','Bengaluru, Karnataka'),
('Vikram','Rao','Male','1999-07-18','9876543214','vikram.rao@gmail.com','Hyderabad, Telangana'),
('Ananya','Iyer','Female','2003-03-25','9876543215','ananya.iyer@gmail.com','Chennai, Tamil Nadu'),
('Karthik','Reddy','Male','2001-12-09','9876543216','karthik.reddy@gmail.com','Warangal, Telangana'),
('Meghana','Sharma','Female','2002-06-30','9876543217','meghana.sharma@gmail.com','Pune, Maharashtra'),
('Rohan','Verma','Male','2000-09-17','9876543218','rohan.verma@gmail.com','Mumbai, Maharashtra'),
('Aishwarya','Nair','Female','2003-02-14','9876543219','aishwarya.nair@gmail.com','Kochi, Kerala'),
('Aditya','Singh','Male','2001-04-28','9876543220','aditya.singh@gmail.com','Delhi, India'),
('Pooja','Krishna','Female','2000-10-12','9876543221','pooja.krishna@gmail.com','Hyderabad, Telangana'),
('Sanjay','Reddy','Male','1998-05-22','9876543222','sanjay.reddy@gmail.com','Guntur, Andhra Pradesh'),
('Divya','Menon','Female','2002-01-19','9876543223','divya.menon@gmail.com','Bengaluru, Karnataka'),
('Manish','Gupta','Male','1999-11-11','9876543224','manish.gupta@gmail.com','Nagpur, Maharashtra'),
('Kavya','Rao','Female','2003-07-07','9876543225','kavya.rao@gmail.com','Hyderabad, Telangana'),
('Nikhil','Reddy','Male','2001-09-03','9876543226','nikhil.reddy@gmail.com','Nizamabad, Telangana'),
('Swathi','Naidu','Female','2000-02-26','9876543227','swathi.naidu@gmail.com','Visakhapatnam, Andhra Pradesh'),
('Varun','Chandra','Male','1999-12-15','9876543228','varun.chandra@gmail.com','Chennai, Tamil Nadu'),
('Harini','Das','Female','2002-04-06','9876543229','harini.das@gmail.com','Bhubaneswar, Odisha');

INSERT INTO Bookings (trip_id,seat_id,passenger_id,fare_amount,status) VALUES
(1,(SELECT seat_id FROM Seats WHERE bus_id=1 AND seat_number='A1'),1,450,'Confirmed'),
(1,(SELECT seat_id FROM Seats WHERE bus_id=1 AND seat_number='A2'),2,450,'Cancelled'),
(2,(SELECT seat_id FROM Seats WHERE bus_id=2 AND seat_number='A1'),3,900,'Confirmed'),
(2,(SELECT seat_id FROM Seats WHERE bus_id=2 AND seat_number='A2'),4,900,'Confirmed'),
(3,(SELECT seat_id FROM Seats WHERE bus_id=3 AND seat_number='A1'),5,1000,'Cancelled'),
(3,(SELECT seat_id FROM Seats WHERE bus_id=3 AND seat_number='A2'),6,1000,'Confirmed'),
(4,(SELECT seat_id FROM Seats WHERE bus_id=4 AND seat_number='A1'),7,650,'Confirmed'),
(4,(SELECT seat_id FROM Seats WHERE bus_id=4 AND seat_number='A2'),8,650,'Cancelled'),
(5,(SELECT seat_id FROM Seats WHERE bus_id=5 AND seat_number='A1'),9,300,'Confirmed'),
(5,(SELECT seat_id FROM Seats WHERE bus_id=5 AND seat_number='A2'),10,300,'Confirmed'),
(6,(SELECT seat_id FROM Seats WHERE bus_id=1 AND seat_number='B1'),11,450,'Cancelled'),
(6,(SELECT seat_id FROM Seats WHERE bus_id=1 AND seat_number='B2'),12,450,'Confirmed'),
(7,(SELECT seat_id FROM Seats WHERE bus_id=2 AND seat_number='B1'),13,900,'Confirmed'),
(7,(SELECT seat_id FROM Seats WHERE bus_id=2 AND seat_number='B2'),14,900,'Confirmed'),
(8,(SELECT seat_id FROM Seats WHERE bus_id=3 AND seat_number='B1'),15,1000,'Cancelled'),
(8,(SELECT seat_id FROM Seats WHERE bus_id=3 AND seat_number='B2'),16,1000,'Confirmed'),
(9,(SELECT seat_id FROM Seats WHERE bus_id=4 AND seat_number='B1'),17,650,'Confirmed'),
(9,(SELECT seat_id FROM Seats WHERE bus_id=4 AND seat_number='B2'),18,650,'Confirmed'),
(10,(SELECT seat_id FROM Seats WHERE bus_id=5 AND seat_number='B1'),19,300,'Confirmed'),
(10,(SELECT seat_id FROM Seats WHERE bus_id=5 AND seat_number='B2'),20,300,'Confirmed');

INSERT INTO Payments (booking_id,amount,payment_method,payment_status) VALUES
(1,450,'UPI','Paid'),(2,450,'Card','Refunded'),
(3,900,'UPI','Paid'),(4,900,'Card','Paid'),
(5,1000,'Net Banking','Refunded'),(6,1000,'UPI','Paid'),
(7,650,'Card','Paid'),(8,650,'UPI','Refunded'),
(9,300,'Cash','Paid'),(10,300,'UPI','Paid'),
(11,450,'Card','Refunded'),(12,450,'UPI','Paid'),
(13,900,'Net Banking','Paid'),(14,900,'UPI','Paid'),
(15,1000,'Card','Refunded'),(16,1000,'UPI','Paid'),
(17,650,'Cash','Paid'),(18,650,'UPI','Paid'),
(19,300,'Card','Paid'),(20,300,'UPI','Paid');

INSERT INTO Cancellations (booking_id,reason,refund_amount) VALUES
(2,'Personal reasons',450),
(5,'Change of travel plans',1000),
(8,'Emergency situation',650),
(11,'Travel date changed',450),
(15,'Personal reasons',1000);

-- Verification
SELECT COUNT(*) AS total_routes FROM Routes;
SELECT COUNT(*) AS total_stops FROM Stops;
SELECT COUNT(*) AS total_buses FROM Buses;
SELECT COUNT(*) AS total_seats FROM Seats;
SELECT COUNT(*) AS total_employees FROM Employees;
SELECT COUNT(*) AS total_trips FROM Schedules;
SELECT COUNT(*) AS total_crew_assignments FROM Crew_Assignment;
SELECT COUNT(*) AS total_passengers FROM Passengers;
SELECT COUNT(*) AS total_bookings FROM Bookings;
SELECT COUNT(*) AS total_payments FROM Payments;
SELECT COUNT(*) AS total_cancellations FROM Cancellations;

-- Complete relationship verification
SELECT
    b.booking_id,
    CONCAT(p.first_name,' ',p.last_name) AS passenger,
    CONCAT(r.source,' → ',r.destination) AS route,
    s.trip_date,
    bus.bus_number,
    seat.seat_number,
    b.fare_amount,
    b.status AS booking_status,
    pay.payment_status,
    c.cancellation_id
FROM Bookings b
JOIN Passengers p ON b.passenger_id=p.passenger_id
JOIN Schedules s ON b.trip_id=s.trip_id
JOIN Routes r ON s.route_id=r.route_id
JOIN Buses bus ON s.bus_id=bus.bus_id
JOIN Seats seat ON b.seat_id=seat.seat_id
LEFT JOIN Payments pay ON b.booking_id=pay.booking_id
LEFT JOIN Cancellations c ON b.booking_id=c.booking_id
ORDER BY b.booking_id;
