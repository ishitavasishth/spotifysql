-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--Checking if all is imported

select *
from spotify;

--EDA- Exploratory Data Analysis 

select count (distinct artist)
from spotify;

select count(distinct album)
from spotify;

select distinct album_type
from spotify;

select duration_min 
from spotify;

select max(duration_min) 
from spotify;

select min(duration_min) 
from spotify;

select * 
from spotify
where duration_min = 0;

--let's delete the songs where duration is 0, it does not make sense
delete from spotify
where duration_min = 0;

select distinct channel 
from spotify;

select distinct most_played_on
from spotify;


--DATA ANALYSIS

--EASY CATEGORY

--1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track
from spotify
where stream > 1000000000;

--2. List all albums along with their respective artists.

select distinct album, artist
from spotify
order by 1;

--3. Get the total number of comments for tracks where licensed = TRUE.

select track, sum(comments) as Total_comments
from spotify
where licensed = 'true'
group by 1
order by 2 desc;

--4. Find all tracks that belong to the album type single.

select track, album_type
from spotify
where album_type ilike 'Single';


--5. Count the total number of tracks by each artist.

select artist,count(track) as count_track
from spotify
group by 1;


--Medium Level- SQL Queries

--1. Calculate the average danceability of tracks in each album.

select album, avg(danceability) as avg_danceability
from spotify
group by album
order by 2 desc;


--2. Find the top 5 tracks with the highest energy values.

select track, sum(energy) as Total_Energy
from spotify
group by 1
having sum(energy) is not null
order by 2 desc
limit 5;


--3. List all tracks along with their views and likes where official_video = TRUE.
select * from spotify;

select track, sum(views) as total_views, sum(likes) as total_likes 
from spotify
where official_video = 'true'
group by 1;

--4. For each album, calculate the total views of all associated tracks.
select album, track, sum(views) as total_views
from spotify
group by 1, 2
order by 3 desc;

select * from spotify;
--5. Retrieve the track names that have been streamed on Spotify more than YouTube.
select *
from (select track, 
coalesce(sum(case when most_played_on = 'Youtube' then stream end),0) as stream_on_youtube,
coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as stream_on_spotify
from spotify
group by 1) as t1
where (stream_on_spotify > stream_on_youtube)
and
(stream_on_youtube <> 0)
;


---- Advanced Level


--1. Find the top 3 most-viewed tracks for each artist using window functions.

with ranking_artist 
as 
(select artist, track, sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1,2
order by 1,3 desc
)
select * from ranking_artist
where rank <=3;

--2. Write a query to find tracks where the liveness score is above the average.

select track, artist, liveness
from spotify 
where liveness > 
(select avg(liveness)
from spotify); 


--3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks 
--in each album.

with cte
as
(select album, max(energy) as max_energy, min(energy) as min_energy
from spotify
group by 1)
select album, max_energy-min_energy as energy_diff
from cte
order by 2 desc;