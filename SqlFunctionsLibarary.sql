--1. Write a function that returns a list of books with the minimum number of pages issued by a particular publisher.
--1. Müəyyən Publisher tərəfindən çap olunmuş minimum səhifəli kitabların siyahısını çıxaran funksiya yazın
CREATE FUNCTION MinPrintPagesBooks()
RETURNS TABLE
RETURN 
SELECT TOP 1 WITH TIES Press.[Name] AS PressName, Books.[Name] AS BooksName, Books.Pages AS BooksPages
FROM Press INNER JOIN Books
ON Press.Id = Books.Id_Press
ORDER BY Books.Pages

SELECT * FROM MinPrintPagesBooks()

--2. Write a function that returns the names of publishers who have published books with an average number of pages greater than N. The average number of pages is passed through the parameter.
--2. Orta səhifə sayı N-dən çox səhifəli kitab çap edən Publisherlərin adını qaytaran funksiya yazın. N parameter olaraq göndərilir.
CREATE FUNCTION AveragePagesGreaterThanBooks(@n int)
RETURNS TABLE
RETURN
SELECT AVG(Books.Pages) AS AveragePages, Press.[Name] AS PressName
FROM Press INNER JOIN Books
ON Press.Id = Books.Id_Press
GROUP BY Press.[Name]
HAVING AVG(Books.Pages) > @n

SELECT * FROM AveragePagesGreaterThanBooks(400)

--3. Write a function that returns the total sum of the pages of all the books in the library issued by the specified publisher.
--3. Müəyyən Publisher tərəfindən çap edilmiş bütün kitab səhifələrinin cəmini tapan və qaytaran funksiya yazın.
CREATE FUNCTION SumPagesBooks(@pressName nvarchar(50))
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @sumPages int = 0;
	SELECT @sumPages = SUM(Books.Pages)
	FROM Press INNER JOIN Books
	ON Press.Id = Books.Id_Press
	GROUP BY Press.[Name]
	HAVING Press.[Name] = @pressName

	RETURN @sumPages;
END

SELECT dbo.SumPagesBooks('BHV') AS SumPages

--4. Write a function that returns a list of names and surnames of all students who took books between the two specified dates.
--4. Müəyyən iki tarix aralığında kitab götürmüş Studentlərin ad və soyadını list şəklində qaytaran funksiya yazın.
CREATE FUNCTION DateInNotNullStudents()
RETURNS TABLE
RETURN
SELECT Students.FirstName, Students.LastName, S_Cards.DateOut, S_Cards.DateIn
FROM S_Cards INNER JOIN Students
ON S_Cards.Id_Student = Students.Id
WHERE DateIn IS NOT NULL

SELECT * FROM DateInNotNullStudents()

--5. Write a function that returns a list of students who are currently working with the specified book of a certain author.
--5. Müəyyən kitabla hal hazırda işləyən bütün tələbələrin siyahısını qaytaran funksiya yazın.
CREATE FUNCTION DateInNullStudents()
RETURNS TABLE
RETURN
SELECT Students.FirstName, Students.LastName, S_Cards.DateOut, S_Cards.DateIn
FROM S_Cards INNER JOIN Students
ON S_Cards.Id_Student = Students.Id
WHERE DateIn IS NULL

SELECT * FROM DateInNullStudents()

--6. Write a function that returns information about publishers whose total number of pages of books issued by them is greater than N.
--6. Çap etdiyi bütün səhifə cəmi N-dən böyük olan Publisherlər haqqında informasiya qaytaran funksiya yazın.
CREATE FUNCTION SumPagesGreaterThanBooks(@n int)
RETURNS TABLE
RETURN
SELECT SUM(Books.Pages) AS AveragePages, Press.Id AS PressId, Press.[Name] AS PressName
FROM Press INNER JOIN Books
ON Press.Id = Books.Id_Press
GROUP BY Press.Id, Press.[Name]
HAVING SUM(Books.Pages) > @n

SELECT * FROM SumPagesGreaterThanBooks(1000)

--7. Write a function that returns information about the most popular author among students and about the number of books of this author taken in the library.
--7.Studentlər arasında Ən popular autor və onun götürülmüş kitablarının sayı haqqında informasiya verən funksiya yazın 
CREATE FUNCTION AuthorsBooksCount()
RETURNS TABLE
RETURN
SELECT TOP 1 WITH TIES Authors.*, COUNT(Books.Id) BooksCount
FROM S_Cards INNER JOIN Books ON S_Cards.Id_Book = Books.Id
INNER JOIN Authors ON Books.Id_Author = Authors.Id
GROUP BY Authors.Id, Authors.FirstName, Authors.LastName
ORDER BY COUNT(Books.Id) DESC

SELECT * FROM AuthorsBooksCount()

--8. Write a function that returns a list of books that were taken by both teachers and students.
--Studentlər və Teacherlər (hər ikisi) tərəfindən götürülmüş (ortaq - həm onlar həm bunlar) kitabların listini qaytaran funksiya yazın.
CREATE FUNCTION TakesTeachersAndStudentsBooks()
RETURNS TABLE
RETURN
SELECT Books.*
FROM S_Cards INNER JOIN Books ON S_Cards.Id_Book = Books.Id
INNER JOIN T_Cards ON T_Cards.Id_Book = Books.Id

SELECT * FROM TakesTeachersAndStudentsBooks()

--9. Write a function that returns the number of students who did not take books.
--9. Kitab götürməyən tələbələrin sayını qaytaran funksiya yazın.
CREATE FUNCTION NotTakesStudentsBooksCount()
RETURNS int
AS
BEGIN
DECLARE @stdCount int = 0;
	SELECT @stdCount = COUNT(*)
	FROM S_Cards RIGHT JOIN Books ON S_Cards.Id_Book = Books.Id 
	RIGHT JOIN Students ON S_Cards.Id_Student = Students.Id
	WHERE S_Cards.Id IS NULL
	RETURN @stdCount
END

SELECT dbo.NotTakesStudentsBooksCount() AS StudentsCount

--10. Write a function that returns a list of librarians and the number of books issued by each of them.
--10. Kitabxanaçılar və onların verdiyi kitabların sayını qaytaran funksiya yazın.
CREATE FUNCTION LibsBooksCount()
RETURNS TABLE
RETURN
SELECT FirstName + LastName AS LibsFullName,
((SELECT COUNT(*) FROM S_Cards
WHERE S_Cards.Id_Lib = Libs.Id
GROUP BY S_Cards.Id_Lib) +
(SELECT COUNT(*) FROM T_Cards
WHERE T_Cards.Id_Lib = Libs.Id
GROUP BY T_Cards.Id_Lib)) AS Total
FROM Libs


