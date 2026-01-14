-- Assessment Table
CREATE TABLE assessment_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Assessment Details Table
CREATE TABLE assessment_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    total_marks INT NOT NULL,
    is_comment ENUM('yes', 'no') DEFAULT 'no',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assessment_id) REFERENCES assessment_table(id) ON DELETE CASCADE
);

-- Student Table
CREATE TABLE student (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    rollno VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Student Assessment Detail Table
CREATE TABLE student_assessment_detail (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    assessment_detail_id INT NOT NULL,
    obtained_marks INT,
    comments TEXT,
    evaluation VARCHAR(100),
    submitted_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
    FOREIGN KEY (assessment_detail_id) REFERENCES assessment_details(id) ON DELETE CASCADE
);

-- Sample Data for Testing
INSERT INTO assessment_table (assessment_title) VALUES 
('English Assessment'),
('Mathematics Assessment'),
('Science Assessment');

INSERT INTO assessment_details (assessment_id, description, total_marks, is_comment) VALUES 
(1, 'Grammar and Vocabulary', 50, 'yes'),
(1, 'Reading Comprehension', 40, 'no'),
(2, 'Algebra Problems', 60, 'yes'),
(2, 'Geometry Questions', 40, 'no'),
(3, 'Biology Concepts', 50, 'yes'),
(3, 'Chemistry Reactions', 50, 'no');

INSERT INTO student (name, rollno) VALUES 
('John Doe', 'A001'),
('Jane Smith', 'A002'),
('Robert Johnson', 'A003'),
('Emily Brown', 'A004');
