-- =============================================
-- 个性化AI辅助学习平台数据库初始化脚本
-- 基于数据库设计文档创建
-- =============================================

-- 创建数据库
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'AILearningPlatform')
BEGIN
    CREATE DATABASE AILearningPlatform;
END
GO

USE AILearningPlatform;
GO

-- =============================================
-- 1. 创建基础表结构
-- =============================================

-- 用户表
CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) UNIQUE NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    real_name NVARCHAR(50) NOT NULL,
    phone NVARCHAR(20),
    created_at DATETIME DEFAULT GETDATE(),
    last_login DATETIME,
    status TINYINT DEFAULT 1
);

-- 角色表
CREATE TABLE Roles (
    role_id INT PRIMARY KEY IDENTITY(1,1),
    role_name NVARCHAR(20) UNIQUE NOT NULL,
    description NVARCHAR(200),
    permissions NVARCHAR(MAX)
);

-- 用户角色关联表
CREATE TABLE UserRoles (
    user_id INT,
    role_id INT,
    assigned_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id) ON DELETE CASCADE
);

-- 课程表
CREATE TABLE Courses (
    course_id INT PRIMARY KEY IDENTITY(1,1),
    course_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    cover_image NVARCHAR(255),
    teacher_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    status TINYINT DEFAULT 0,
    difficulty_level TINYINT DEFAULT 1,
    estimated_hours INT DEFAULT 0,
    FOREIGN KEY (teacher_id) REFERENCES Users(user_id)
);

-- 章节表
CREATE TABLE Chapters (
    chapter_id INT PRIMARY KEY IDENTITY(1,1),
    course_id INT NOT NULL,
    title NVARCHAR(100) NOT NULL,
    content NVARCHAR(MAX),
    order_num INT NOT NULL,
    video_url NVARCHAR(255),
    document_url NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- 选课表
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at DATETIME DEFAULT GETDATE(),
    progress DECIMAL(5,2) DEFAULT 0,
    status TINYINT DEFAULT 1,
    UNIQUE(user_id, course_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- 学习记录表
CREATE TABLE StudyRecords (
    record_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    chapter_id INT,
    study_duration INT DEFAULT 0,
    progress DECIMAL(5,2) DEFAULT 0,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    completed TINYINT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (chapter_id) REFERENCES Chapters(chapter_id)
);

-- 考试表
CREATE TABLE Exams (
    exam_id INT PRIMARY KEY IDENTITY(1,1),
    course_id INT NOT NULL,
    exam_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    total_score INT DEFAULT 100,
    pass_score INT DEFAULT 60,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

-- 题目表
CREATE TABLE Questions (
    question_id INT PRIMARY KEY IDENTITY(1,1),
    exam_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    question_type TINYINT NOT NULL, -- 1:单选 2:多选 3:填空 4:简答
    options NVARCHAR(MAX),
    correct_answer NVARCHAR(MAX) NOT NULL,
    score INT DEFAULT 1,
    difficulty TINYINT DEFAULT 1,
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id) ON DELETE CASCADE
);

-- 考试记录表
CREATE TABLE ExamRecords (
    record_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL,
    exam_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    submit_time DATETIME,
    score INT DEFAULT 0,
    status TINYINT DEFAULT 0, -- 0:进行中 1:已完成
    answers NVARCHAR(MAX),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id) ON DELETE CASCADE
);

-- 论坛帖子表
CREATE TABLE ForumPosts (
    post_id INT PRIMARY KEY IDENTITY(1,1),
    course_id INT,
    user_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 回复表
CREATE TABLE Replies (
    reply_id INT PRIMARY KEY IDENTITY(1,1),
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    like_count INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    FOREIGN KEY (post_id) REFERENCES ForumPosts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- =============================================
-- 2. 添加约束
-- =============================================

-- 检查约束
ALTER TABLE Users ADD CONSTRAINT CK_Users_Status 
CHECK (status IN (0, 1));

ALTER TABLE Courses ADD CONSTRAINT CK_Courses_Difficulty 
CHECK (difficulty_level BETWEEN 1 AND 5);

ALTER TABLE Enrollments ADD CONSTRAINT CK_Enrollments_Progress 
CHECK (progress BETWEEN 0 AND 100);

ALTER TABLE ExamRecords ADD CONSTRAINT CK_ExamRecords_Score 
CHECK (score >= 0);

ALTER TABLE Questions ADD CONSTRAINT CK_Questions_Type 
CHECK (question_type BETWEEN 1 AND 4);

ALTER TABLE Questions ADD CONSTRAINT CK_Questions_Difficulty 
CHECK (difficulty BETWEEN 1 AND 5);

-- =============================================
-- 3. 创建索引
-- =============================================

-- 用户表索引
CREATE INDEX IX_Users_Username ON Users(username);
CREATE INDEX IX_Users_Email ON Users(email);
CREATE INDEX IX_Users_Status ON Users(status);

-- 课程表索引
CREATE INDEX IX_Courses_TeacherId ON Courses(teacher_id);
CREATE INDEX IX_Courses_Status ON Courses(status);
CREATE INDEX IX_Courses_Difficulty ON Courses(difficulty_level);

-- 学习记录索引
CREATE INDEX IX_StudyRecords_UserId ON StudyRecords(user_id);
CREATE INDEX IX_StudyRecords_CourseId ON StudyRecords(course_id);
CREATE INDEX IX_StudyRecords_StartTime ON StudyRecords(start_time);

-- 考试记录索引
CREATE INDEX IX_ExamRecords_UserId ON ExamRecords(user_id);
CREATE INDEX IX_ExamRecords_ExamId ON ExamRecords(exam_id);
CREATE INDEX IX_ExamRecords_Status ON ExamRecords(status);

-- 论坛帖子索引
CREATE INDEX IX_ForumPosts_CourseId ON ForumPosts(course_id);
CREATE INDEX IX_ForumPosts_UserId ON ForumPosts(user_id);
CREATE INDEX IX_ForumPosts_CreatedAt ON ForumPosts(created_at);

-- 选课表索引
CREATE INDEX IX_Enrollments_UserId ON Enrollments(user_id);
CREATE INDEX IX_Enrollments_CourseId ON Enrollments(course_id);

-- =============================================
-- 4. 创建视图
-- =============================================

-- 学生课程视图
GO
CREATE VIEW StudentCourseView AS
SELECT 
    u.user_id,
    u.real_name AS student_name,
    c.course_id,
    c.course_name,
    e.progress,
    e.enrolled_at,
    t.real_name AS teacher_name
FROM Users u
JOIN Enrollments e ON u.user_id = e.user_id
JOIN Courses c ON e.course_id = c.course_id
JOIN Users t ON c.teacher_id = t.user_id
WHERE e.status = 1;
GO

-- 考试成绩视图
GO
CREATE VIEW ExamScoreView AS
SELECT 
    u.real_name AS student_name,
    c.course_name,
    ex.exam_name,
    er.score,
    ex.total_score,
    er.submit_time,
    CASE WHEN er.score >= ex.pass_score THEN '通过' ELSE '未通过' END AS result
FROM Users u
JOIN ExamRecords er ON u.user_id = er.user_id
JOIN Exams ex ON er.exam_id = ex.exam_id
JOIN Courses c ON ex.course_id = c.course_id
WHERE er.status = 1;
GO

-- 学习统计视图
GO
CREATE VIEW StudyStatisticsView AS
SELECT 
    u.user_id,
    u.real_name,
    COUNT(DISTINCT e.course_id) AS enrolled_courses,
    AVG(e.progress) AS avg_progress,
    SUM(sr.study_duration) AS total_study_time
FROM Users u
LEFT JOIN Enrollments e ON u.user_id = e.user_id
LEFT JOIN StudyRecords sr ON u.user_id = sr.user_id
GROUP BY u.user_id, u.real_name;
GO

-- 学习行为分析视图
GO
CREATE VIEW LearningBehaviorAnalysis AS
SELECT 
    u.user_id,
    u.real_name,
    c.course_id,
    c.course_name,
    c.difficulty_level,
    AVG(sr.study_duration) AS avg_study_duration,
    AVG(CAST(er.score AS FLOAT)) AS avg_exam_score,
    COUNT(sr.record_id) AS study_sessions,
    MAX(sr.end_time) AS last_study_time
FROM Users u
JOIN StudyRecords sr ON u.user_id = sr.user_id
JOIN Courses c ON sr.course_id = c.course_id
LEFT JOIN ExamRecords er ON u.user_id = er.user_id 
    AND er.exam_id IN (SELECT exam_id FROM Exams WHERE course_id = c.course_id)
GROUP BY u.user_id, u.real_name, c.course_id, c.course_name, c.difficulty_level;
GO

-- =============================================
-- 5. 创建触发器
-- =============================================

-- 更新学习进度触发器
CREATE TRIGGER TR_UpdateStudyProgress
ON StudyRecords
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE e
    SET progress = (
        SELECT AVG(CASE WHEN sr.completed = 1 THEN 100 ELSE sr.progress END)
        FROM StudyRecords sr
        WHERE sr.user_id = e.user_id AND sr.course_id = e.course_id
    )
    FROM Enrollments e
    INNER JOIN inserted i ON e.user_id = i.user_id AND e.course_id = i.course_id;
END;
GO

-- 论坛统计触发器
CREATE TRIGGER TR_UpdateForumStats
ON Replies
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE fp
    SET updated_at = GETDATE()
    FROM ForumPosts fp
    INNER JOIN inserted i ON fp.post_id = i.post_id;
END;
GO

-- 课程更新时间触发器
CREATE TRIGGER TR_UpdateCourseTimestamp
ON Courses
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Courses
    SET updated_at = GETDATE()
    WHERE course_id IN (SELECT course_id FROM inserted);
END;
GO

-- =============================================
-- 6. 插入初始数据
-- =============================================

-- 插入角色数据
INSERT INTO Roles (role_name, description, permissions) VALUES
('学生', '学生角色，可以选课学习、参加考试、论坛互动', 'course:view,exam:take,forum:post'),
('教师', '教师角色，可以创建课程、管理学生、查看成绩', 'course:create,course:manage,student:view,grade:view'),
('管理员', '管理员角色，拥有系统全部权限', 'system:all');

-- 插入管理员用户（密码：admin123，已加盐哈希）
INSERT INTO Users (username, password_hash, email, real_name, phone, status) VALUES
('admin', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'admin123salt_key'), 2), 'admin@ailearning.com', '系统管理员', '13800000000', 1);

-- 为管理员分配角色
INSERT INTO UserRoles (user_id, role_id) VALUES
(1, 3); -- 管理员角色

-- 插入示例教师用户
INSERT INTO Users (username, password_hash, email, real_name, phone, status) VALUES
('teacher1', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'teacher123salt_key'), 2), 'teacher1@ailearning.com', '张老师', '13800000001', 1),
('teacher2', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'teacher123salt_key'), 2), 'teacher2@ailearning.com', '李老师', '13800000002', 1);

-- 为教师分配角色
INSERT INTO UserRoles (user_id, role_id) VALUES
(2, 2), -- 教师角色
(3, 2); -- 教师角色

-- 插入示例学生用户
INSERT INTO Users (username, password_hash, email, real_name, phone, status) VALUES
('student1', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'student123salt_key'), 2), 'student1@ailearning.com', '王同学', '13800000003', 1),
('student2', CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'student123salt_key'), 2), 'student2@ailearning.com', '刘同学', '13800000004', 1);

-- 为学生分配角色
INSERT INTO UserRoles (user_id, role_id) VALUES
(4, 1), -- 学生角色
(5, 1); -- 学生角色

-- 插入示例课程
INSERT INTO Courses (course_name, description, teacher_id, status, difficulty_level, estimated_hours) VALUES
('Python基础编程', 'Python编程语言基础课程，适合初学者', 2, 1, 1, 40),
('数据结构与算法', '计算机科学核心课程，学习各种数据结构和算法', 2, 1, 3, 60),
('Web前端开发', 'HTML、CSS、JavaScript前端开发技术', 3, 1, 2, 50);

-- 插入课程章节
INSERT INTO Chapters (course_id, title, content, order_num) VALUES
(1, 'Python环境搭建', 'Python开发环境的安装和配置', 1),
(1, '变量和数据类型', 'Python基本数据类型和变量使用', 2),
(1, '控制结构', '条件语句和循环语句的使用', 3),
(2, '数组和链表', '线性数据结构的实现和应用', 1),
(2, '栈和队列', '栈和队列数据结构详解', 2),
(3, 'HTML基础', 'HTML标记语言基础知识', 1),
(3, 'CSS样式', 'CSS样式表的使用方法', 2);

-- =============================================
-- 7. 创建存储过程
-- =============================================

-- 用户登录验证存储过程
CREATE PROCEDURE sp_UserLogin
    @Username NVARCHAR(50),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @HashedPassword NVARCHAR(255);
    SET @HashedPassword = CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', @Password + 'salt_key'), 2);
    
    SELECT 
        u.user_id,
        u.username,
        u.real_name,
        u.email,
        r.role_name
    FROM Users u
    INNER JOIN UserRoles ur ON u.user_id = ur.user_id
    INNER JOIN Roles r ON ur.role_id = r.role_id
    WHERE u.username = @Username 
        AND u.password_hash = @HashedPassword 
        AND u.status = 1;
    
    -- 更新最后登录时间
    UPDATE Users 
    SET last_login = GETDATE() 
    WHERE username = @Username AND password_hash = @HashedPassword;
END;
GO

-- 获取用户学习统计存储过程
CREATE PROCEDURE sp_GetUserStudyStats
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        COUNT(DISTINCT e.course_id) AS total_courses,
        AVG(e.progress) AS avg_progress,
        SUM(sr.study_duration) AS total_study_time,
        COUNT(DISTINCT er.exam_id) AS exams_taken,
        AVG(CAST(er.score AS FLOAT)) AS avg_exam_score
    FROM Users u
    LEFT JOIN Enrollments e ON u.user_id = e.user_id
    LEFT JOIN StudyRecords sr ON u.user_id = sr.user_id
    LEFT JOIN ExamRecords er ON u.user_id = er.user_id AND er.status = 1
    WHERE u.user_id = @UserId
    GROUP BY u.user_id;
END;
GO

-- 课程推荐存储过程
CREATE PROCEDURE sp_GetCourseRecommendations
    @UserId INT,
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH UserSimilarity AS (
        SELECT 
            e1.user_id AS user1,
            e2.user_id AS user2,
            COUNT(*) AS common_courses
        FROM Enrollments e1
        JOIN Enrollments e2 ON e1.course_id = e2.course_id AND e1.user_id != e2.user_id
        WHERE e1.user_id = @UserId
        GROUP BY e1.user_id, e2.user_id
        HAVING COUNT(*) >= 1
    ),
    RecommendedCourses AS (
        SELECT 
            e.course_id,
            c.course_name,
            c.description,
            c.difficulty_level,
            COUNT(*) AS recommendation_strength
        FROM UserSimilarity us
        JOIN Enrollments e ON us.user2 = e.user_id
        JOIN Courses c ON e.course_id = c.course_id
        WHERE e.course_id NOT IN (
            SELECT course_id FROM Enrollments WHERE user_id = @UserId
        )
        AND c.status = 1
        GROUP BY e.course_id, c.course_name, c.description, c.difficulty_level
    )
    SELECT TOP (@TopN)
        course_id,
        course_name,
        description,
        difficulty_level,
        recommendation_strength
    FROM RecommendedCourses
    ORDER BY recommendation_strength DESC;
END;
GO

PRINT '数据库初始化完成！';
PRINT '默认管理员账号：admin / admin123';
PRINT '默认教师账号：teacher1 / teacher123, teacher2 / teacher123';
PRINT '默认学生账号：student1 / student123, student2 / student123';
PRINT '请及时修改默认密码以确保安全！';