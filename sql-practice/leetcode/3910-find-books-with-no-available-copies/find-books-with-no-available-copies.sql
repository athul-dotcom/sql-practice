SELECT 
    a.book_id,
    a.title,
    a.author,
    a.genre,
    a.publication_year,
    COUNT(CASE WHEN b.return_date IS NULL THEN 1 END) AS current_borrowers
FROM library_books a 
JOIN borrowing_records b ON a.book_id = b.book_id
GROUP BY a.book_id, a.title, a.author, a.genre, a.publication_year, a.total_copies
HAVING a.total_copies = current_borrowers
ORDER BY current_borrowers DESC, a.title ASC;