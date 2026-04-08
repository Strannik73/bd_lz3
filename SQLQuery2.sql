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
(N'Зингель', N'Иван', N'Иванович', '1980-01-01', '2018-09-01', 7),
(N'Петров', N'Петр', N'Петрович', '2001-02-02', '2015-09-01', 8),
(N'Зайцева', N'Мария', N'Валильевна', '2000-03-03', '2018-09-01', 4),
(N'Кузнецов', N'Алексей', N'Игоревич', '2002-04-04', '2014-09-01', 9),
(N'Смирнов', N'Дмитрий', N'Олегович', '2001-05-05', '2019-09-01', 6),
(N'Аграар', N'Джордан', N'', '2001-05-05', '2019-09-01', 9),
(N'Ботяновский', N'Альберт', N'', '2001-05-05', '2019-09-01', 7);


INSERT INTO faculty (faculty_name) VALUES
(N'ФПМ'),
(N'ФПК');

INSERT INTO form (form_name) VALUES
(N'очная'),
(N'заочная');

INSERT INTO [hours] (course, faculty_id, form_id, all_h, inclass_h) VALUES
(1, 1, 1, 210, 50), 
(2, 1, 2, 120, 60),
(3, 2, 2, 110, 55), 
(1, 2, 1, 90, 45),
(1, 1, 1, 100, 50);

INSERT INTO process (stud_id, hours_id) VALUES
(1, 2),
(2, 2),
(3, 1),
(4, 4),
(5, 3),
(6, 2),
(7, 2);



INSERT INTO teach (last_name, f_name, s_name, dr_date, start_work_date) VALUES
(N'Смирнов', N'Иван', N'Андреевич', '1980-05-15', '2005-09-01'),
(N'Крылов', N'Олег', N'Петрович', '1975-08-20', '2000-09-01'),
(N'Бортников', N'Дмитрий', N'Сергеевич', '1988-11-10', '2010-09-01'),
(N'Енмильоо', N'Дмитрий', N'', '1981-11-10', '2010-09-06'),
(N'Иванов', N'Алексей', N'Петрович', '1985-07-12', '2023-09-01');

INSERT INTO subj (subj, hourss) VALUES
(N'Математика', N'2 час(а)'),
(N'Физика', N'3 час(а)'),
(N'Информатика', N'2 час(а)'),
(N'История', N'2 час(а)'),
(N'Химия', N'2 час(а)');


INSERT INTO work (teach_id, subj_id, hours_id) VALUES
(1, 1, 1), 
(1, 3, 3), 
(2, 2, 2), 
(3, 4, 4), 
(3, 1, 1),
(4, 2, 1),
(5, 5, 5);

--======================================================================
--1.1
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
FROM faculty f
JOIN [hours] h ON f.id = h.faculty_id
JOIN work w ON h.id = w.hours_id
JOIN subj s ON w.subj_id = s.id
JOIN teach t ON w.teach_id = t.id
WHERE t.s_name = ''
GROUP BY f.faculty_name;

SELECT * FROM teach WHERE s_name = '';

--2.1
SELECT
    s.last_name,
    s.f_name,
    s.s_name,
    f.faculty_name,
    h.course
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN [form] fo ON h.form_id = fo.id
WHERE
    fo.form_name = N'заочная'
    AND DATEDIFF(year, s.dr_date, GETDATE()) < 37;

--2
SELECT
    f.faculty_name,
    COUNT(DISTINCT s.id) AS Кол_воСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
GROUP BY f.faculty_name;

--3
SELECT
    f.form_name,
    COUNT(DISTINCT s.id) AS Кол_воСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN form f ON h.form_id = f.id
GROUP BY f.form_name;

--4
SELECT
    f.faculty_name,
    AVG(DATEDIFF(year, s.dr_date, DATEFROMPARTS(2023, 12, 31))) AS СреднийВозраст
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
GROUP BY f.faculty_name;

--5
SELECT
    s.last_name,
    s.f_name,
    s.dr_date,
    s.in_date,
    f.faculty_name,
    h.course,
    forms.form_name
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN [form] forms ON h.form_id = forms.id
WHERE s.s_name = '';

SELECT * FROM stud WHERE s_name = '';

--6
SELECT TOP 1
    f.faculty_name,
    COUNT(*) AS ПоступСтуденты
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE YEAR(s.in_date) = 2015
GROUP BY f.faculty_name
ORDER BY ПоступСтуденты DESC;

--7
SELECT 
    f.faculty_name,
    fr.form_name,
    COUNT(DISTINCT s.id) AS ЧислоСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN form fr ON h.form_id = fr.id
WHERE YEAR(s.in_date) = 2014
GROUP BY 
    f.faculty_name,
    fr.form_name
ORDER BY
    f.faculty_name,
    fr.form_name;

--8
SELECT DISTINCT f.faculty_name
FROM faculty f
JOIN hours h ON f.id = h.faculty_id
JOIN form fr ON h.form_id = fr.id
WHERE fr.form_name = N'заочная';

--9
SELECT 
    f.faculty_name,
    fr.form_name,
    h.course
FROM faculty f
JOIN hours h ON f.id = h.faculty_id
JOIN form fr ON h.form_id = fr.id
ORDER BY 
    f.faculty_name,
    fr.form_name,
    h.course;

--10
SELECT 
    f.faculty_name,
    fr.form_name,
    COUNT(DISTINCT s.id) AS ЧислоСтудентов
FROM faculty f
JOIN hours h ON f.id = h.faculty_id
JOIN form fr ON h.form_id = fr.id
JOIN process p ON h.id = p.hours_id
JOIN stud s ON p.stud_id = s.id
GROUP BY 
    f.faculty_name,
    fr.form_name
ORDER BY 
    f.faculty_name,
    fr.form_name;

--11
SELECT 
    COUNT(DISTINCT s.id) AS ОбщееЧислоСтудентов13к
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
WHERE h.course IN (1, 3);

--12
SELECT 
    f.faculty_name,
    h.course,
    COUNT(DISTINCT s.id) AS ЧислоИностранныхСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE s.s_name IS NULL OR s.s_name = ''
GROUP BY 
    f.faculty_name,
    h.course
ORDER BY 
    f.faculty_name,
    h.course;

--13
SELECT 
    f.faculty_name,
    h.course,
    COUNT(DISTINCT s.id) AS ЧислоСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE s.exm > 7.5
GROUP BY 
    f.faculty_name,
    h.course
ORDER BY 
    f.faculty_name,
    h.course;

--14
SELECT 
    f.faculty_name,
    fr.form_name,
    COUNT(DISTINCT s.id) AS ЧислоСтудентовсСтарше45лет
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN form fr ON h.form_id = fr.id
WHERE DATEDIFF(year, s.dr_date, GETDATE()) > 45
GROUP BY 
    f.faculty_name,
    fr.form_name
ORDER BY 
    f.faculty_name,
    fr.form_name;

--15
SELECT 
    f.faculty_name,
    fr.form_name,
    h.course,
    COUNT(DISTINCT s.id) AS ЧислоСтудентовМладше27лет
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
JOIN form fr ON h.form_id = fr.id
WHERE DATEDIFF(year, s.dr_date, GETDATE()) < 27
GROUP BY 
    f.faculty_name,
    fr.form_name,
    h.course
ORDER BY 
    f.faculty_name,
    fr.form_name,
    h.course;

--16
SELECT 
    f.faculty_name,
    COUNT(DISTINCT s.id) AS СтудентыФамилияНаС
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE s.last_name LIKE 'С%' OR s.last_name LIKE 'с%'
GROUP BY 
    f.faculty_name
ORDER BY 
    f.faculty_name;

-------- 3 ---------------
--1
WITH MaxAvgExm AS (
    SELECT MAX(avgexm) AS maxexm
    FROM (
        SELECT AVG(exm) AS avgexm
        FROM stud
        GROUP BY id
    ) AS AvgStud
)
SELECT s.last_name, s.f_name, s.s_name, s.exm
FROM stud s
CROSS JOIN MaxAvgExm
WHERE s.exm < (0.8 * MaxAvgExm.maxexm);

--2
SELECT last_name, f_name, s_name, exm
FROM stud
WHERE exm = (
    SELECT MAX(exm)
    FROM stud
)

--3
WITH Facult AS (
    SELECT h.faculty_id, COUNT(*) AS StudCount
    FROM process p
    JOIN hours h ON p.hours_id = h.id
    GROUP BY h.faculty_id
),
MaxFaculty AS (
    SELECT TOP 1 faculty_id
    FROM Facult
    ORDER BY StudCount DESC
)
SELECT s.last_name
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
WHERE h.faculty_id = (SELECT faculty_id FROM MaxFaculty)

--4
SELECT s.*
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
JOIN form f ON h.form_id = f.id
JOIN faculty fc ON h.faculty_id = fc.id
WHERE NOT EXISTS (
    SELECT 1
    FROM stud s2
    JOIN process p2 ON s2.id = p2.stud_id
    JOIN hours h2 ON p2.hours_id = h2.id
    WHERE h2.form_id = h.form_id 
      AND h2.course = h.course 
      AND h2.faculty_id = h.faculty_id
      AND (s2.s_name IS NULL OR s2.s_name = '')
)

--5
SELECT s2.*
FROM stud s2
JOIN process p2 ON s2.id = p2.stud_id
JOIN hours h2 ON p2.hours_id = h2.id
WHERE h2.course = (
    SELECT h1.course
    FROM process p1
    JOIN hours h1 ON p1.hours_id = h1.id
    JOIN stud s1 ON p1.stud_id = s1.id
    WHERE s1.last_name = N'Ботяновский'
)
AND s2.last_name <> N'Ботяновский';

--6
SELECT DISTINCT s3.*
FROM stud s3
JOIN process p3 ON s3.id = p3.stud_id
JOIN hours h3 ON p3.hours_id = h3.id
WHERE h3.course IN (

    SELECT h1.course
    FROM stud s1
    JOIN process p1 ON s1.id = p1.stud_id
    JOIN hours h1 ON p1.hours_id = h1.id
    WHERE s1.last_name = N'Зингель'
    UNION

    SELECT h2.course
    FROM stud s2
    JOIN process p2 ON s2.id = p2.stud_id
    JOIN hours h2 ON p2.hours_id = h2.id
    WHERE s2.last_name = N'Зайцева'
)
AND s3.last_name NOT IN (N'Зингель', N'Зайцева');

--7
SELECT s.*
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
WHERE EXISTS (
    SELECT 1
    FROM stud s2
    JOIN process p2 ON s2.id = p2.stud_id
    JOIN hours h2 ON p2.hours_id = h2.id
    WHERE (s2.s_name IS NULL OR s2.s_name = N'') 
    AND h2.faculty_id = h.faculty_id
    AND h2.course = h.course
    AND h2.form_id = h.form_id
)
AND (s.s_name IS NOT NULL AND s.s_name <> N'');

--8
SELECT 
    s.*,
    COUNT(*) OVER (PARTITION BY h.faculty_id, h.course) AS ОбщееЧислоСтудентов
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN hours h ON p.hours_id = h.id
WHERE (s.s_name IS NULL OR s.s_name = N'')
AND s.last_name IS NOT NULL

--------- 4 ----------
--1
CREATE PROCEDURE StudForm
    @facultyName NVARCHAR(50),
    @formName NVARCHAR(25)
AS
BEGIN
    DECLARE @studentCount INT;

    SELECT @studentCount = COUNT(*)
    FROM stud s
    INNER JOIN [hours] h ON s.exm = h.id 
    INNER JOIN faculty f ON h.faculty_id = f.id
    INNER JOIN form fr ON h.form_id = fr.id
    WHERE f.faculty_name = @facultyName
      AND fr.form_name = @formName;

    PRINT 'Количество студентов на факультете "' + @facultyName + 
          '" и форме обучения "' + @formName + '" равно: ' + CAST(@studentCount AS NVARCHAR(10));
END;

EXEC StudForm @facultyName = N'ФПМ', @formName = N'Очная';

--2
CREATE PROCEDURE Subj_inf
AS
BEGIN
    DECLARE @TotalSubjects INT = 0;
    DECLARE @TotalDuplicates INT = 0;

    CREATE TABLE #FacCounts (
        faculty_name NVARCHAR(50),
        unique_subjects INT,
        total_subjects INT,
        duplicates INT
    );

    INSERT INTO #FacCounts (faculty_name, unique_subjects, total_subjects, duplicates)
    SELECT
        f.faculty_name,
        COUNT(DISTINCT s.id) AS unique_subjects,
        COUNT(w.subj_id) AS total_subjects,
        SUM(CASE WHEN cnt > 1 THEN 1 ELSE 0 END) AS duplicates
    FROM
        faculty f
        LEFT JOIN [hours] h ON f.id = h.faculty_id
        LEFT JOIN work w ON h.id = w.hours_id
        LEFT JOIN subj s ON w.subj_id = s.id
        LEFT JOIN (
            SELECT 
                subj_id,
                COUNT(*) AS cnt
            FROM work
            GROUP BY subj_id
        ) AS subj_counts ON s.id = subj_counts.subj_id
    GROUP BY
        f.faculty_name;

    SELECT
        @TotalSubjects = SUM(unique_subjects),
        @TotalDuplicates = SUM(duplicates)
    FROM #FacCounts;

    DECLARE @final_report NVARCHAR(MAX);

    DECLARE @f NVARCHAR(50), @u INT, @t INT, @d INT;

    DECLARE cur CURSOR FOR SELECT faculty_name, unique_subjects, total_subjects, duplicates FROM #FacCounts;

    OPEN cur;
    FETCH NEXT FROM cur INTO @f, @u, @t, @d;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Для ' + @f + ' читается ' + CAST(@u AS NVARCHAR(10)) + ' предметов, всего ' + CAST(@t AS NVARCHAR(10)) + ' предметов (' + CAST(@d AS NVARCHAR(10)) + ' из которых идентичны)';
        FETCH NEXT FROM cur INTO @f, @u, @t, @d;
    END

    CLOSE cur;
    DEALLOCATE cur;

    PRINT 'Всего ' + CAST(@TotalSubjects AS NVARCHAR(10)) + ' предметов (' + CAST(@TotalDuplicates AS NVARCHAR(10)) + ' из которых идентичны)';
    
    DROP TABLE #FacCounts;
END
EXEC Subj_inf;

--3
CREATE PROCEDURE Add_stud
    @faculty_name NVARCHAR(50),
    @form_name NVARCHAR(25),
    @last_name NVARCHAR(20),
    @f_name NVARCHAR(20),
    @s_name NVARCHAR(20),
    @dr_date DATE,
    @in_date DATE
AS
BEGIN
    DECLARE @faculty_id INT;
    DECLARE @form_id INT;
    DECLARE @hours_id INT;

    SELECT @faculty_id = id FROM faculty WHERE faculty_name = @faculty_name;
    IF @faculty_id IS NULL
    BEGIN
        PRINT 'факультета нет';
        RETURN;
    END

    SELECT @form_id = id FROM form WHERE form_name = @form_name;
    IF @form_id IS NULL
    BEGIN
        PRINT 'формы обучения нет';
        RETURN;
    END

    SELECT TOP 1 @hours_id = id FROM [hours]
    WHERE course = 1; 

    IF @hours_id IS NULL
    BEGIN
        PRINT 'Не найден час для первого курса. Проверьте таблицу hours.';
        RETURN;
    END

    INSERT INTO stud (
        last_name, f_name, s_name, dr_date, in_date, exm
    )
    VALUES (
        @last_name, @f_name, @s_name, @dr_date, @in_date, 1 
    );

    DECLARE @stud_id INT = SCOPE_IDENTITY();

    INSERT INTO process (stud_id, hours_id)
    VALUES (@stud_id, @hours_id);

    PRINT 'Студент успешно зачислен на первый курс.';
END

EXEC Add_stud
    @faculty_name = 'ФПК',
    @form_name = 'Очная',
    @last_name = 'Дорн',
    @f_name = 'Рогал',
    @s_name = '',
    @dr_date = '2002-02-04',
    @in_date = '2020-08-27';

----------- 5 ----------------------
--1
CREATE FUNCTION dbo.Stud_info 
( @s_name NVARCHAR(20) )
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @result NVARCHAR(20)

    IF (@s_name IS NULL OR LTRIM(RTRIM(@s_name)) = '')
        SET @result = N'иностранец'
    ELSE
        SET @result = N'гражданин'

    RETURN @result
END

SELECT 
    last_name,
    f_name,
    s_name,
    dbo.Stud_info(s_name) AS ИнформацияОГражданстве
FROM stud;

--2
CREATE FUNCTION dbo.PowerTeach
( @teach_id INT )
RETURNS INT
AS
BEGIN
    DECLARE @total INT

    SELECT @total = SUM(h.all_h)
    FROM work w
    JOIN [hours] h ON w.hours_id = h.id
    WHERE w.teach_id = @teach_id

    RETURN ISNULL(@total, 0)
END

SELECT 
    t.id,
    t.last_name,
    t.f_name,
    dbo.PowerTeach(t.id) AS ОбщиеЧасы
FROM teach t;

----------- 6 --------------
--(1)
CREATE VIEW FPKstud
AS
SELECT 
    s.last_name,
    s.f_name,
    s.s_name,
    h.course,
    f.form_name
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty fac ON h.faculty_id = fac.id
JOIN form f ON h.form_id = f.id
WHERE fac.faculty_name = N'ФПК';
--2
CREATE VIEW zaochn
AS
SELECT 
    fac.faculty_name,
    h.course,
    SUM(h.all_h) AS sum_h_zaochn
FROM [hours] h
JOIN faculty fac ON h.faculty_id = fac.id
JOIN form f ON h.form_id = f.id
WHERE f.form_name = N'заочная'
GROUP BY fac.faculty_name, h.course;
--3
CREATE VIEW otlichn
AS
SELECT 
    fac.faculty_name,
    h.course,
    f.form_name,
    COUNT(*) AS otlichn
FROM stud s
JOIN process p ON s.id = p.stud_id
JOIN [hours] h ON p.hours_id = h.id
JOIN faculty fac ON h.faculty_id = fac.id
JOIN form f ON h.form_id = f.id
WHERE s.exm > 8
GROUP BY fac.faculty_name, h.course, f.form_name;
--4
CREATE VIEW slab
AS
SELECT 
    s.last_name,
    s.f_name,
    s.s_name,
    AVG(CAST(s.exm AS FLOAT)) AS ОценкиСлабоуспСтудентов
FROM stud s
WHERE s.exm < 6
GROUP BY s.last_name, s.f_name, s.s_name;

SELECT * FROM FPKstud
SELECT * FROM zaochn
SELECT * FROM otlichn
SELECT * FROM slab

--(2)
--1= Модернизирующие \ (у меня) JOIN нескольких таблиц
--2= Модернизирующие \ (у меня) SUM + GROUP BY
--3= Только чтение \ (у меня) COUNT + GROUP BY
--4= Модернизирующие \ (у меня) AVG + GROUP BY


------------ 7 ----------------
--1
SELECT 
    t.last_name,
    t.f_name,
    t.s_name,
    SUM(h.all_h) AS ОбщиеЧасы,
    CASE 
        WHEN SUM(h.all_h) > 450 THEN '20%'
        WHEN SUM(h.all_h) > 300 THEN '10%'
        ELSE '0%'
    END AS bonus
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN [hours] h ON w.hours_id = h.id
GROUP BY t.last_name, t.f_name, t.s_name;

--2
SELECT 
    s.last_name AS Фамилия,
    s.f_name AS Имя,
    s.s_name AS Отчество,
    CASE 
        WHEN s.s_name IS NULL OR s.s_name = '' THEN N'Иностранное'
        ELSE N'РБ'
    END AS Гражданство
FROM stud s

UNION ALL

SELECT 
    t.last_name AS Фамилия,
    t.f_name AS Имя,
    t.s_name AS Отчество,
    CASE 
        WHEN t.s_name IS NULL OR t.s_name = '' THEN N'Иностранное'
        ELSE N'РБ'
    END AS Гражданство
FROM teach t;

--3
SELECT 
    t.last_name,
    t.f_name,
    t.s_name
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN [hours] h ON w.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE f.faculty_name IN (N'ФПК', N'ФПМ')
GROUP BY t.last_name, t.f_name, t.s_name
HAVING COUNT(DISTINCT f.faculty_name) = 2;

--4
SELECT DISTINCT 
    t.last_name,
    t.f_name,
    t.s_name
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN [hours] h ON w.hours_id = h.id
JOIN faculty f ON h.faculty_id = f.id
WHERE f.faculty_name = N'ФПК'
AND NOT EXISTS (
    SELECT 1
    FROM work w2
    JOIN [hours] h2 ON w2.hours_id = h2.id
    JOIN faculty f2 ON h2.faculty_id = f2.id
    WHERE w2.teach_id = t.id
      AND f2.faculty_name = N'ФПМ'
)
UNION ALL
SELECT N'none', N'none', N'none'
WHERE NOT EXISTS (
    SELECT 1
    FROM teach t
    JOIN work w ON t.id = w.teach_id
    JOIN [hours] h ON w.hours_id = h.id
    JOIN faculty f ON h.faculty_id = f.id
    WHERE f.faculty_name = N'ФПК'
    AND NOT EXISTS (
        SELECT 1
        FROM work w2
        JOIN [hours] h2 ON w2.hours_id = h2.id
        JOIN faculty f2 ON h2.faculty_id = f2.id
        WHERE w2.teach_id = t.id
          AND f2.faculty_name = N'ФПМ'
    )
);

SELECT 
    t.last_name AS teacher_last_name,
    t.f_name AS teacher_first_name,
    t.s_name AS teacher_middle_name,
    fac.faculty_name AS faculty_name
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN hours h ON w.hours_id = h.id
JOIN faculty fac ON h.faculty_id = fac.id
WHERE fac.faculty_name = N'ФПМ';

SELECT 
    t.last_name AS teacher_last_name,
    t.f_name AS teacher_first_name,
    t.s_name AS teacher_middle_name,
    fac.faculty_name AS faculty_name
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN hours h ON w.hours_id = h.id
JOIN faculty fac ON h.faculty_id = fac.id
WHERE fac.faculty_name = N'ФПК';


SELECT 
    t.last_name AS teacher_last_name,
    t.f_name AS teacher_first_name,
    t.s_name AS teacher_middle_name,
    s.subj AS subject_name,
    h.course AS course
FROM teach t
JOIN work w ON t.id = w.teach_id
JOIN subj s ON w.subj_id = s.id
JOIN hours h ON w.hours_id = h.id
JOIN faculty fac ON h.faculty_id = fac.id
WHERE fac.faculty_name = N'ФПК'  -- Преподаватели, работающие на ФПК
AND NOT EXISTS (
    SELECT 1
    FROM hours h2
    JOIN faculty fac2 ON h2.faculty_id = fac2.id
    JOIN work w2 ON w2.hours_id = h2.id
    WHERE fac2.faculty_name = N'ФПМ'  -- Исключаем преподавателей, работающих на ФПМ
    AND w2.teach_id = t.id
);
--5
SELECT N'Студентов' AS Тип, COUNT(*) AS Кол_во
FROM stud

UNION ALL

SELECT N'Преподавателей', COUNT(*)
FROM teach

UNION ALL

SELECT N'Всего человек', COUNT(*) 
FROM (
    SELECT id FROM stud
    UNION ALL
    SELECT id FROM teach
) AS all_people;