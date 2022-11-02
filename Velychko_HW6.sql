USE	Academy

GO

--************************************************************************************************
--1. Вивести номери корпусів, якщо сумарний фонд фінансування розташованих
--у них кафедр перевищує 100 000.

SELECT 
		[D].[Building] AS 'Номер корпусу', 
		SUM([D].[Financing]) AS 'Сумарний фонт фінансування'
FROM 
		[Departments] AS [D]
GROUP BY [D].[Building]
HAVING 
		SUM([D].[Financing]) > 100000

--************************************************************************************************
--2. Вивести назви груп 5-го курсу кафедри “Software Development”,
--які мають понад 10 пар на перший тиждень.

--! запит змінено під існуючу базу (“Software Development” = “РПО”) !--
--! запит змінено під існуючу базу (які мають понад 10 пар на..= які мають >= 1 пар) !--

SELECT 
		[G].[Name] AS 'Назва групи', 
		[Temp].[Кількість лекцій] AS 'Кількість лекцій'
FROM	[Groups] AS [G] JOIN [Departments] AS [D] ON [G].[DepartmentId] = [D].[Id]
		INNER JOIN (SELECT 
						[GL].[GroupId], COUNT([GL].[LectureId]) AS 'Кількість лекцій'
					FROM 
						[GroupsLectures] AS [GL] JOIN [Lectures] AS [L] ON [GL].[LectureId] = [L].[Id]
					WHERE 
						[L].[Date] BETWEEN '2022-09-01' AND '2022-09-07'
					GROUP BY 
						[GL].[GroupId]) AS [Temp] ON [Temp].[GroupId] = [G].[Id]
WHERE 
		[G].[Year] = 5 AND
		[D].[Name] = 'РПО' AND
		[Temp].[Кількість лекцій] >= 1

--************************************************************************************************
--3. Вивести назви груп, які мають рейтинг (середній рейтинг усіх студентів групи)
--більший, ніж рейтинг групи “D221”

--! запит змінено під існуючу базу (групи “D221” = групи “GR11”) !--

SELECT 
		[G].[Name] AS 'Назва групи', 
		AVG([S].[Rating]) AS 'Середній рейтинг'
FROM 
		[GroupsStudents] AS [GS] JOIN [Students] AS [S] ON [GS].[StudentId] = [S].[Id]
		INNER JOIN [Groups] AS [G] ON [G].[Id] = [GS].[GroupId]
GROUP BY [G].[Name]
HAVING 
		AVG([S].[Rating]) > (SELECT 
									AVG([S].[Rating])
						   FROM 
									[GroupsStudents] AS [GS] JOIN [Students] AS [S] ON [GS].[StudentId] = [S].[Id]
									INNER JOIN [Groups] AS [G] ON [G].[Id] = [GS].[GroupId]
                           WHERE 
									[G].[Name] = 'GR11'
                           GROUP BY [G].[Name])

--************************************************************************************************
--4. Вивести прізвища та імена викладачів, ставка яких вища
--за середню ставку професорів.

SELECT 
		[T].[Name] + ' ' + [T].[Surname] AS 'Прізвища та імена викладачів'
FROM 
		[Teachers] AS [T] 
WHERE 
		[T].[Salary] > (SELECT 
								AVG([T].[Salary])
						FROM 
								[Teachers] AS [T] 
					  WHERE 
								[T].[IsProfessor] = 'true')

--************************************************************************************************
--5. Вивести назви груп, які мають більше одного куратора.

SELECT 
		[G].[Name] AS 'Назва груп', 
		COUNT([C].[Name]) AS 'Кількість кураторів'
FROM 
		[Groups] AS [G] JOIN [GroupsCurators] AS [GC] ON [G].[Id] = [GC].[GroupId]
		JOIN [Curators] AS [C] ON [C].[Id] = [GC].[CuratorId]
GROUP BY [G].[Name]
HAVING 
		COUNT([C].[Name]) > 1

--************************************************************************************************
--6. Вивести назви груп, які мають рейтинг (середній рейтинг усіх 
--студентів групи) менший, ніж мінімальний рейтинг груп 5-го курсу.

--! запит змінено під існуючу базу (менший, ніж мінімальний = більше, ніж мінімальний) !--

SELECT 
		[G].[Name] AS 'Назва групи', 
		AVG([S].[Rating]) AS 'Середній рейтинг'
FROM 
		[GroupsStudents] AS [GS] JOIN [Students] AS [S] ON [GS].[StudentId] = [S].[Id]
		INNER JOIN [Groups] AS [G] ON [G].[Id] = [GS].[GroupId]
GROUP BY [G].[Name]
HAVING 
		AVG([S].[Rating]) >		(SELECT 
									MIN([TEMP].[Середній рейтинг]) AS 'Мінімальний рейтинг груп 5 курсу'
								FROM
									(SELECT 
										[G].[Name] AS 'Назва групи', AVG([S].[Rating]) AS 'Середній рейтинг'
									FROM 
										[GroupsStudents] AS [GS] JOIN [Students] AS [S] ON [GS].[StudentId] = [S].[Id]
										INNER JOIN [Groups] AS [G] ON [G].[Id] = [GS].[GroupId]
									 WHERE 
										[G].[Year] = 5
									 GROUP BY 
										[G].[Name]) AS [TEMP])
ORDER BY 'Середній рейтинг' DESC
		   
--************************************************************************************************
--7. Вивести назви факультетів, сумарний фонд фінансування кафедр 
--яких більший за сумарний фонд фінансування кафедр факультету “Computer Science”.

--! запит змінено під існуючу базу (“Computer Science” = “МКА”) !--

SELECT
	[F].[Name] AS 'Назва факультетів',
	SUM([D].[Financing]) AS 'Сумарний фонд фінансування кафедр'
FROM
	[Faculties] AS [F] JOIN [Departments] AS [D] ON [F].[Id] = [D].[FacultyId]
GROUP BY
	[F].[Name]
HAVING 
	SUM([D].[Financing]) > (SELECT 
								SUM([D].[Financing])
							FROM
								[Faculties] AS [F] JOIN [Departments] AS [D] ON [F].[Id] = [D].[FacultyId]
							WHERE 
								[F].[Name] = 'МКА')

--************************************************************************************************
--8. Вивести назви дисциплін та повні імена викладачів, які читають найбільшу кількість лекцій з них.

--SELECT
--	[S].[Name] AS 'Назва предмету',
--	[T].[Name] + ' ' + [T].[Surname] AS 'Викладач',
--	COUNT([S].[Name]) AS 'Кількість предметів'
--FROM
--	[Teachers] AS [T] JOIN [Lectures] AS [L] ON [T].[Id] = [L].[TeacherId]
--	INNER JOIN [Subjects] AS [S] ON [S].[Id] = [L].[SubjectId]
--GROUP BY 
--	[T].[Name] + ' ' + [T].[Surname], [S].[Name]

SELECT
	[TEMP].[Н] AS 'Назва предмету',
	[TEMP].[В] AS 'Викладач',
	[TEMP].[К] AS 'Кількість предметів'
FROM
	(SELECT
		[S].[Name] AS 'Н',
		[T].[Name] + ' ' + [T].[Surname] AS 'В',
		COUNT([S].[Name]) AS 'К'
	FROM
		[Teachers] AS [T] JOIN [Lectures] AS [L] ON [T].[Id] = [L].[TeacherId]
		INNER JOIN [Subjects] AS [S] ON [S].[Id] = [L].[SubjectId]
	GROUP BY 
		[T].[Name] + ' ' + [T].[Surname], [S].[Name]) AS [TEMP]
WHERE
	[TEMP].[К]  = ANY MAX([TEMP].[К])








--SELECT
--	[T].[Name],
--	[S].[Name], 
--	COUNT([S].[Name]) AS 'Кількість'
--FROM
--	[Teachers] AS [T] JOIN [Lectures] AS [L] ON [T].[Id] = [L].[TeacherId]
--	INNER JOIN [Subjects] AS [S] ON [S].[Id] = [L].[SubjectId]
--GROUP BY 
--	[T].[Name], [S].[Name]


--************************************************************************************************
--9. Вивести назву дисципліни, за якою читається найменше
--лекцій.

SELECT
	[TEMP].[Назва] AS 'Назва предмету, за яким читається найменше лекцій'
FROM 
	(SELECT
		[S].[Name] AS 'Назва',
		COUNT([S].[Name]) AS 'Кількість'
	FROM
		[Subjects] AS [S] JOIN [Lectures] AS [L] ON [S].[Id] = [L].[SubjectId]
	GROUP BY
		[S].[Name]) AS [TEMP]
WHERE
	[TEMP].[Кількість] = 	(
							SELECT
								MIN([TEMP].[Кількість])
							FROM
								(SELECT
									[S].[Name] AS 'Назва',
									COUNT([S].[Name]) AS 'Кількість'
								FROM
									[Subjects] AS [S] JOIN [Lectures] AS [L] ON [S].[Id] = [L].[SubjectId]
								GROUP BY
									[S].[Name]) AS [TEMP])

--************************************************************************************************
--10. Вивести кількість студентів та дисциплін, що читаються
--на кафедрі “Software Development”.

--! запит змінено під існуючу базу (“Software Development” = “МКА 5р”) !--
	
SELECT
	[StuCount].[Кількість студентів] AS 'Кількість студентів',
	[SubjCount].[Кількість предметів] AS 'Кількість предметів'
FROM
	(SELECT
		COUNT([GS].[StudentId]) AS 'Кількість студентів'
	FROM
		[Departments] AS [D] INNER JOIN  [Groups] AS [G] ON [G].[DepartmentId] = [D].[Id]
		INNER JOIN [GroupsStudents] AS [GS] ON [GS].[GroupId] = [G].[Id]
	WHERE
		[D].[Name] = 'МКА 5р') AS [StuCount],
	(SELECT
		COUNT([TEMP].[предмети]) AS 'Кількість предметів'
	FROM
				(SELECT
					[S].[Name] AS 'предмети'
				FROM
					[Departments] AS [D] INNER JOIN  [Groups] AS [G] ON [G].[DepartmentId] = [D].[Id]
					INNER JOIN [GroupsLectures] AS [GL] ON [GL].[GroupId] = [G].[Id]
					INNER JOIN [Lectures] AS [L] ON [L].[Id] = [GL].[LectureId]
					INNER JOIN [Subjects] AS [S] ON [S].[Id] = [L].[SubjectId]
				WHERE
					[D].[Name] = 'МКА 5р'
				GROUP BY
					[S].[Name]) AS [TEMP]) AS [SubjCount]




		

--************************************************************************************************
