/*Query 1 - Query used for playlist performance*/
WITH t1
AS (SELECT
  p.PlaylistID,
  p.Name AS playlist,
  COUNT(t.trackID) AS track_count
FROM Playlist p
JOIN PlaylistTrack pt
  ON pt.PlaylistID = p.PlaylistID
JOIN Track t
  ON pt.TrackID = t.TrackID
JOIN MediaType mt
  ON t.MediaTypeID = mt.MediaTypeID
  AND mt.name NOT LIKE '%video%'
GROUP BY 1,
         2),

t2
AS (SELECT
  SUM(il.UnitPrice * il.Quantity) AS sales,
  pt.playlistID
FROM InvoiceLine il
JOIN Invoice i
  ON i.InvoiceID = il.InvoiceID
JOIN Track t
  ON il.trackID = t.TrackID
JOIN PlaylistTrack pt
  ON t.TrackID = pt.TrackID
GROUP BY 2)

SELECT
  t1.playlistID,
  playlist,
  track_count,
  (sales / track_count) AS avg_track_rev
FROM t1
JOIN t2
  ON t1.PlaylistID = t2.PlaylistID
ORDER BY 4 DESC;

/*Query 2 - Query used for "music" playlist strucutre*/
SELECT
  g.name AS genre,
  COUNT(*) AS tracks
FROM track t
JOIN MediaType mt
  ON t.MediaTypeID = mt.MediaTypeID
  AND mt.name NOT LIKE '%video%'
JOIN Genre g
  ON t.GenreID = g.GenreID
JOIN PlaylistTrack pt
  ON t.trackID = pt.TrackID
  AND pt.PlaylistID = '1'
GROUP BY 1
ORDER BY 2 DESC;

/*Query 3 - Query used for TOP10 rock artists*/
WITH t1
AS (SELECT
  t.trackID,
  t.name AS song,
  ar.name AS artist,
  g.name AS genre
FROM genre g
JOIN track t
  ON t.genreID = g.genreID
  AND genre = 'Rock'
JOIN Album a
  ON t.albumID = a.albumID
JOIN Artist ar
  ON a.ArtistID = ar.ArtistID),

t2
AS (SELECT
  SUM(il.UnitPrice * il.Quantity) AS sales,
  t.trackID
FROM InvoiceLine il
JOIN Invoice i
  ON i.InvoiceID = il.InvoiceID
JOIN Track t
  ON il.trackID = t.TrackID
GROUP BY 2)

SELECT
  artist,
  SUM(sales) AS artist_sales
FROM t1
JOIN t2
  ON t1.trackID = t2.trackID
  AND t1.trackID NOT IN (SELECT
    trackID
  FROM PlaylistTrack pt
  WHERE playlistID = '17')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

/*Query 4 - Query used for data storage usage*/
SELECT
  (AVG(bytes) / AVG(milliseconds)) AS bpms,
  mt.name AS 'type'
FROM MediaType mt
JOIN Track t
  ON mt.MediaTypeID = t.MediaTypeID
  AND mt.name NOT LIKE '%video%'
GROUP BY 2
ORDER BY 1 DESC;
