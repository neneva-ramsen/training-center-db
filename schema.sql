---------- Gym ----------
CREATE TABLE gyms (
    id INT NOT NULL,
    street_address TEXT NOT NULL,
    gym_name TEXT NOT NULL,
    gym_type TEXT CHECK(gym_type IN ('regular', 'spinning')),
    staffed BOOLEAN NOT NULL,
    PRIMARY KEY (id)
);

---------- Facilities and relationship to gym ----------
CREATE TABLE facilities (
    id INT NOT NULL,
    facility_name TEXT NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE gym_facilities (
    gym_id INT,
    facility_id INT,
    PRIMARY KEY (gym_id, facility_id),
    FOREIGN KEY (gym_id) REFERENCES gyms(id),
    FOREIGN KEY (facility_id) REFERENCES facilities(id)
);

---------- Opening hours ----------

CREATE TABLE opening_hours (
    gym_id INT,
    weekday TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    PRIMARY KEY (gym_id, weekday),
    FOREIGN KEY (gym_id) REFERENCES gyms(id)
);

---------- Staff hours ----------
CREATE TABLE staff_hours (
    gym_id INT,
    weekday TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    PRIMARY KEY (gym_id, weekday),
    FOREIGN KEY (gym_id) REFERENCES gyms(id)
);

---------- Halls (changed name from rooms) ----------
CREATE TABLE halls (
    id INT NOT NULL,
    gym_id INT NOT NULL,
    capacity INT NOT NULL, --this determines capacity in group sessions so have to be not null
    PRIMARY KEY (id),
    FOREIGN KEY (gym_id) REFERENCES gyms(id)
);

---------- Treadmills ----------
CREATE TABLE Treadmills (
    id INT NOT NULL,
    hall_id INT NOT NULL,
    treadmill_number INT NOT NULL, -- see assumptions in text
    manufacturer TEXT,
    max_speed REAL,
    max_incline REAL,
    PRIMARY KEY (id),
    FOREIGN KEY (hall_id) REFERENCES halls(id)
);
---------- Spinning bikes ----------
CREATE TABLE spinning_bikes (
    id INT NOT NULL,
    hall_id INT NOT NULL,
    bike_number INT NOT NULL, -- see assumptions in text
    bluetooth_body_bike BOOLEAN,
    PRIMARY KEY (id),
    FOREIGN KEY (hall_id) REFERENCES halls(id)
);

---------- Activity ----------
CREATE TABLE activities (
    id INT,
    name TEXT NOT NULL,
    description TEXT,
    PRIMARY KEY (id)
);

---------- Users ----------
CREATE TABLE users (
    id INT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    -- TODO prefix_phone
    phone_number VARCHAR(8), -- allowed to not have phone number?
    student BOOLEAN, -- can be sports team member if student
    PRIMARY KEY (id)
);

---------- Group sessions ----------
CREATE TABLE group_sessions (
    -- capacity is given by hall capacity, not this table
    id INT NOT NULL,
    activity_id INT NOT NULL,
    hall_id INT NOT NULL,
    instructor_id INT,
    start_time TEXT NOT NULL, -- ('HH:MM:SS)
    end_time TEXT NOT NULL,
    signup_deadline TEXT NOT NULL,
    sessiondate TEXT NOT NULL, -- ('YYYY-MM-DD')
    PRIMARY KEY (id),
    FOREIGN KEY (activity_id) REFERENCES activities(id),
    FOREIGN KEY (hall_id) REFERENCES halls(id),
    FOREIGN KEY (instructor_id) REFERENCES users(id)
);


---------- Booking ----------
CREATE TABLE session_bookings (
    --id INT AUTO_INCREMENT PRIMARY KEY, -- auto increment from user bookings
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- auto increment from user bookings
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    --booking_time TEXT NOT NULL,
    booking_time TEXT NOT NULL, --(YYYY-MM-DD HH:MM:SS)
    UNIQUE(user_id, session_id), -- only unique bookings
    --PRIMARY KEY (id),
    FOREIGN KEY (session_id) REFERENCES group_sessions(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

---------- Attendance ----------
CREATE TABLE attendances (
    session_booking_id INT NOT NULL,
    timestamp TEXT NOT NULL, --ex '2026-03-09 08:28'
    attended BOOLEAN,
    PRIMARY KEY (session_booking_id, timestamp),
    FOREIGN KEY (session_booking_id) REFERENCES session_bookings(id)
);

---------- Arrivals ----------
CREATE TABLE arrivals (
    user_id INT NOT NULL,
    gym_id INT NOT NULL,
    timestamp TEXT NOT NULL, --ex '2026-03-09 08:28'
    PRIMARY KEY (user_id, gym_id, timestamp),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (gym_id) REFERENCES gyms(id)
);

---------- Sports teams ----------
CREATE TABLE sports_teams (
    id INT NOT NULL,
    team_name TEXT NOT NULL,
    PRIMARY KEY (id)
);

---------- Sports team member ----------
CREATE TABLE sports_team_members (
    team_id INT NOT NULL,
    user_id INT NOT NULL,
    PRIMARY KEY (team_id, user_id),
    FOREIGN KEY (team_id) REFERENCES sports_teams(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

---------- Hall booking ----------
CREATE TABLE hall_booking (
    id INT NOT NULL,
    hall_id INT NOT NULL,
    session_id INT,
    team_id INT,
    start_time TEXT,
    end_time TEXT,
    CHECK (
        (session_id IS NOT NULL AND team_id IS NULL) 
        OR (session_id IS NULL AND team_id IS NOT NULL)
    ), -- so that a booking can belong to either of the two but not both
    PRIMARY KEY (id),
    FOREIGN KEY (hall_id) REFERENCES halls(id),
    FOREIGN KEY (session_id) REFERENCES group_sessions(id),
    FOREIGN KEY (team_id) REFERENCES sports_teams(id)
);

---------- Dot system ----------
CREATE TABLE dot_system (
    id INT NOT NULL,
    session_booking_id INT NOT NULL, -- session identifies user
    date_given TEXT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (session_booking_id) REFERENCES session_bookings(id)
);