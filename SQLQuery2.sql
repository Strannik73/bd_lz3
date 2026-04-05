CREATE DATABASE STBD


USE master;
ALTER DATABASE STBD 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
DROP DATABASE STBD;

USE STBD
CREATE TABLE stud(
    id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(20),
    f_name NVARCHAR(20),
    s_name NVARCHAR(20),
    dr_date DATE,
    in_date DATE,
    exm INT
) 

CREATE TABLE faculty(
    id INT IDENTITY(1,1) PRIMARY KEY,
    faculty_name NVARCHAR(50)
)

CREATE TABLE form(
    id INT IDENTITY(1,1) PRIMARY KEY,
    form_name NVARCHAR(25)
) 

CREATE TABLE [hours](
    id INT IDENTITY(1,1) PRIMARY KEY,
    course INT,
    faculty_id INT,
    form_id INT,
    all_h INT,
    inclass_h INT
)
    
CREATE TABLE process(
    stud_id INT,
    hours_id INT,
    PRIMARY KEY(stud_id, hours_id)
) 
--============
CREATE TABLE work(
    teach_id INT,
    subj_id INT,
    hours_id INT,
    PRIMARY KEY(teach_id, subj_id, hours_id)
) 

CREATE TABLE teach(
    id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(20),
    f_name NVARCHAR(20),
    s_name NVARCHAR(20),
    dr_date DATE,
    start_work_date DATE
)

CREATE TABLE subj(
    id INT IDENTITY(1,1) PRIMARY KEY,
    subj NVARCHAR(25),
    hourss NVARCHAR(25)
) 


ALTER  TABLE process ADD CONSTRAINT FK_process_stud FOREIGN KEY (stud_id) REFERENCES stud(id);
ALTER  TABLE process ADD CONSTRAINT FK_process_hours FOREIGN KEY (hours_id) REFERENCES [hours](id);
ALTER  TABLE [hours] ADD CONSTRAINT FK_hours_faculty FOREIGN KEY (faculty_id) REFERENCES faculty(id);
ALTER  TABLE [hours] ADD CONSTRAINT FK_hours_form FOREIGN KEY (form_id) REFERENCES form(id)

ALTER  TABLE work ADD CONSTRAINT FK_work_hours FOREIGN KEY (hours_id) REFERENCES [hours](id);
ALTER  TABLE work ADD CONSTRAINT FK_work_subj FOREIGN KEY (subj_id) REFERENCES subj(id);
ALTER  TABLE work ADD CONSTRAINT FK_work_teach FOREIGN KEY (teach_id) REFERENCES teach(id);

--=================================заполнение==========================================     
INSERT INTO stud (last_name, f_name, s_name, dr_date, in_date, exm) VALUES
(N'Иванов', N'Иван', N'Иванович', '2000-01-01', '2018-09-01', 7),
(N'Петров', N'Петр', N'Петрович', '2001-02-02', '2019-09-01', 8),
(N'Сидоров', N'Сидор', N'Сидорович', '2000-03-03', '2018-09-01', 4),
(N'Кузнецов', N'Алексей', N'Игоревич', '2002-04-04', '2020-09-01', 9),
(N'Смирнов', N'Дмитрий', N'Олегович', '2001-05-05', '2019-09-01', 6);

INSERT INTO faculty (faculty_name) VALUES
(N'ФИТ'),
(N'ФПК');

INSERT INTO form (form_name) VALUES
(N'очная'),
(N'заочная');

INSERT INTO [hours] (course, faculty_id, form_id, all_h, inclass_h) VALUES
(1, 1, 1, 210, 50), 
(2, 1, 2, 120, 60),
(3, 2, 2, 110, 55), 
(1, 2, 1, 90, 45); 

INSERT INTO process (stud_id, hours_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(3, 3),
(4, 4),
(5, 3);

INSERT INTO teach (last_name, f_name, s_name, dr_date, start_work_date) VALUES
(N'Смирнов', N'Иван', N'Андреевич', '1980-05-15', '2005-09-01'),
(N'Крылов', N'Олег', N'Петрович', '1975-08-20', '2000-09-01'),
(N'Бортников', N'Дмитрий', N'Сергеевич', '1988-11-10', '2010-09-01'),
(N'Енмильоо', N'Дмитрий', N'', '1981-11-10', '2010-09-06');

INSERT INTO subj (subj, hourss) VALUES
(N'Математика', N'2 час(а)'),
(N'Физика', N'3 час(а)'),
(N'Информатика', N'2 час(а)'),
(N'История', N'2 час(а)');


INSERT INTO work (teach_id, subj_id, hours_id) VALUES
(1, 1, 1), 
(1, 3, 3); 

INSERT INTO work (teach_id, subj_id, hours_id) VALUES
(2, 2, 2); 

INSERT INTO work (teach_id, subj_id, hours_id) VALUES
(3, 4, 4), 
(3, 1, 1);

INSERT INTO work (teach_id, subj_id, hours_id) VALUES
(4, 2, 1);

--======================================================================
--1S
SELECT 
    f.faculty_name,
    AVG(s.exm) AS СреднийБалл
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN form fo ON h.form_id = fo.id
WHERE fo.form_name = N'заочная'
GROUP BY f.faculty_name;

--2 
SELECT 
    t.faculty_name,
    t.course,
    MAX(t.СреднийБалл) AS МаксимальныйСреднийБалл
FROM (
    SELECT 
        f.faculty_name,
        h.course,
        AVG(s.exm) AS СреднийБалл
    FROM stud s
    JOIN process p ON s.id = p.stud_id
    JOIN [hours] h ON p.hours_id = h.id
    JOIN faculty f ON h.faculty_id = f.id
    GROUP BY f.faculty_name, h.course
) t
GROUP BY t.faculty_name, t.course;

--3
SELECT 
    f.faculty_name AS Факультет,
    AVG(CAST(s.exm AS FLOAT)) AS СреднийБалл
FROM 
    stud s, 
    faculty f,
    [hours] h, 
    process p
WHERE 
    s.id = p.stud_id               
    AND p.hours_id = h.id           
    AND h.faculty_id = f.id         
GROUP BY 
    f.faculty_name
HAVING 
    AVG(CAST(s.exm AS FLOAT)) > 7;  

--4
SELECT 
    h.course,
    f.faculty_name,
    fo.form_name,
    AVG(s.exm) AS СреднийБалл
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN form fo ON h.form_id = fo.id
GROUP BY h.course, f.faculty_name, fo.form_name
HAVING AVG(s.exm) > 7.5
ORDER BY f.faculty_name, h.course;

--5
SELECT 
    f.faculty_name AS Факультет,
    h.course AS Курс,
    MIN(s.exm) AS МинСрБалл
FROM 
    stud s, 
    faculty f,
    [hours] h, 
    process p
WHERE 
    s.id = p.stud_id                
    AND p.hours_id = h.id           
    AND h.faculty_id = f.id         
GROUP BY 
    f.faculty_name, h.course
ORDER BY 
    f.faculty_name, h.course;

--6
SELECT 
    f.faculty_name AS Факультет,
    fm.form_name AS ФормаОбуч,
    MIN(s.exm) AS МинСрБалл
FROM 
    stud s, 
    faculty f,
    form fm,
    [hours] h, 
    process p
WHERE 
    s.id = p.stud_id                
    AND p.hours_id = h.id           
    AND h.faculty_id = f.id
    AND h.form_id = fm.id
GROUP BY 
    f.faculty_name, fm.form_name
HAVING 
    MIN(s.exm) > 6
ORDER BY 
    f.faculty_name, fm.form_name;

--7

SELECT 
    (h.all_h - h.inclass_h) AS СампоЧасы
FROM 
    faculty f, 
    form fm,
    [hours] h 
WHERE 
    h.faculty_id = f.id           
    AND h.form_id = fm.id         
    AND f.faculty_name = N'ФПК'    
    AND h.course = 3               
    AND fm.form_name = N'заочная';

--8
SELECT
    f.faculty_name,
    h.course,
    fo.form_name,
    (h.all_h - h.inclass_h) AS СампоЧасы
FROM [hours] h
JOIN faculty f ON h.faculty_id = f.id
JOIN form fo ON h.form_id = fo.id
WHERE (h.all_h - h.inclass_h) > 150
ORDER BY f.faculty_name, h.course;

--9
SELECT 
    f.faculty_name,
    COUNT(h.id) AS Количество_предметов
FROM [hours] h, faculty f
WHERE h.faculty_id = f.id
GROUP BY f.faculty_name
ORDER BY f.faculty_name;

--10
SELECT 
    f.faculty_name,
    COUNT(DISTINCT w.teach_id) AS Кол_воПрепод
FROM faculty f
JOIN [hours] h ON f.id = h.faculty_id
JOIN [work] w ON h.id = w.hours_id
GROUP BY f.faculty_name;

--11
WITH MaxHoursPerTeacher AS (
    SELECT 
        w.teach_id,
        MAX(h.all_h) AS max_hours
    FROM work w
    JOIN hours h ON w.hours_id = h.id
    GROUP BY w.teach_id
)
SELECT 
    t.id AS teach_id,
    t.last_name,
    t.f_name,
    s.subj,
    h.all_h
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN subj s ON w.subj_id = s.id
JOIN hours h ON w.hours_id = h.id
JOIN MaxHoursPerTeacher m ON t.id = m.teach_id AND h.all_h = m.max_hours
ORDER BY t.id;

--12
SELECT 
    t.id,
    t.last_name,
    t.f_name,
    t.s_name,
    COUNT(DISTINCT w.subj_id) AS Кол_воПредметов
FROM teach t
JOIN work w ON t.id = w.teach_id
GROUP BY t.id, t.last_name, t.f_name, t.s_name
HAVING COUNT(DISTINCT w.subj_id) > 1;

--13
SELECT 
    h.course,
    f.faculty_name,
    SUM(h.all_h) AS СуммаЧасов
FROM hours h
JOIN faculty f ON h.faculty_id = f.id
GROUP BY h.course, f.faculty_name
ORDER BY h.course;

--14
SELECT 
    f.faculty_name,
    h.course,
    COUNT(DISTINCT s.id) AS Кол_воПредметов
FROM hours h
JOIN faculty f ON h.faculty_id = f.id
JOIN work w ON h.id = w.hours_id
JOIN subj s ON w.subj_id = s.id
WHERE h.course = 2
GROUP BY f.faculty_name, h.course
ORDER BY 
    f.faculty_name DESC, 
    h.course ASC;
    
--15
SELECT 
    f.faculty_name,
    COUNT(DISTINCT s.id) AS кол_воПредметтов
FROM 
    faculty f
JOIN 
    [hours] h ON f.id = h.faculty_id
JOIN 
    work w ON h.id = w.hours_id
JOIN 
    subj s ON w.subj_id = s.id
JOIN 
    teach t ON w.teach_id = t.id
WHERE 
    t.s_name = ''
GROUP BY 
    f.faculty_name;

    SELECT * FROM teach WHERE s_name = '';