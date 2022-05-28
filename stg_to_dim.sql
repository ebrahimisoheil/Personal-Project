-- Create dim_countries

CREATE TABLE dim_countries
(
id INTEGER PRIMARY KEY AUTOINCREMENT,
country TEXT
);

-- Insert data into countries

INSERT INTO dim_countries 
SELECT DISTINCT NULL AS id, country FROM stg_users;


-- Create dim_cities

CREATE TABLE dim_cities
(
id INTEGER PRIMARY KEY AUTOINCREMENT,
city TEXT NOT NULL,
country_id INTEGER,
FOREIGN KEY(country_id) REFERENCES dim_countries(id)
);

-- Insert data into dim_cities


INSERT INTO dim_cities 
WITH city_country AS (
SELECT DISTINCT city, country FROM stg_users su 
),
city_country_id AS (
SELECT cc.city, dc.id FROM dim_countries dc
LEFT JOIN city_country cc ON dc.country = cc.country 
)
SELECT NULL AS "id", city, id AS "country_id" FROM city_country_id ;



-- create dim_users

CREATE TABLE dim_users
(
		id TEXT PRIMARY KEY,
		firstname TEXT,
		lastname TEXT,
		city_id INTEGER,
		register_date DATETIME,
		updated_at DATETIME,
		FOREIGN KEY(city_id) REFERENCES dim_cities(id) 
);

-- Insert data into dim_users

INSERT INTO dim_users
WITH users AS 
(
	SELECT 
	id AS "id",
	firstname,
	lastname,
	datetime(registerDate) AS "register_date",
	datetime(updatedDate) AS "updated_at",
	city,
	country
	FROM 
	stg_users su 
) ,
city_users AS (
   SELECT
	users.*,
	c.id AS "city_id"
	FROM 
	users LEFT JOIN dim_cities c on c.city = users.city
)
SELECT 
			id,
			firstname,
			lastname,
			city_id,
			register_date,
			updated_at 
FROM city_users;

-- Create fct_posts

CREATE TABLE fct_posts (
		id TEXT PRIMARY KEY,
		owner_id TEXT,
		likes INTEGER,
		publish_date DATE,
FOREIGN KEY (owner_id) REFERENCES dim_users(id)
);

-- Insert data into fct_posts


INSERT INTO fct_posts 
with posts as (
SELECT 
		id,
		owner_id,
		likes,
		date(publishDate) as "publish_date"
FROM stg_posts sp 
)
SELECT * FROM posts;


-- Create dim_post_tag

CREATE TABLE dim_post_tag (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		post_id TEXT,
		tag TEXT,
FOREIGN KEY(post_id) REFERENCES fct_posts(id)
);

-- Insert data into dim_post_tag

INSERT INTO dim_post_tag 
SELECT 	
	  null as "id",	
	  id as "post_id",
	  SUBSTR(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  0,
	  INSTR(REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''), ',' )
		       )
		      as 'tag'
FROM stg_posts sp 
UNION 
SELECT 	
	  null as "id",
	  id as "post_id",
      SUBSTR(
      
	  REPLACE(
	  TRIM(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  SUBSTR(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  0,
	  INSTR(REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''), ',' )+1 
		      )
	  )
	  ,
	  ' ',
	  ''),
	  0,
	  INSTR(
	  REPLACE(
	  TRIM(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  SUBSTR(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  0,
	  INSTR(REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''), ',' )+1 
		      )
	  )
	  ,
	  ' ',
	  '')
	  
	  , ',' )
		       
	  )
		      as 'tag'
FROM stg_posts sp 
UNION 
SELECT 	
	  null as "id",	
	  id as "post_id",
	  SUBSTR(
	  REPLACE(
	  TRIM(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  SUBSTR(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  0,
	  INSTR(REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''), ',' )+1 
		      )
	  )
	  ,
	  ' ',
	  ''),
	  INSTR(	  REPLACE(
	  TRIM(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  SUBSTR(
	  REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''),
	  0,
	  INSTR(REPLACE(REPLACE(REPLACE(tags, ']',''),'[',''), '''' , ''), ',' )+1 
		      )
	  )
	  ,
	  ' ',
	  '') , ',') + 1 ) as "tag"
FROM stg_posts sp ;

-- Create fct_comments


CREATE TABLE fct_comments(
	id TEXT PRIMARY KEY,
	message TEXT,
	post_id TEXT,
	owner_id TEXT,
	publish_date DATETIME,
FOREIGN KEY(owner_id) REFERENCES dim_users(id),
FOREIGN KEY(post_id)  REFERENCES fct_posts(id)
);


-- Insert data into fct_comments


insert into fct_comments 
WITH comments as (
SELECT 
		id, 
		message as "text",
		post as "post_id",
		owner_id,
		publish_date as "publish_date"
FROM stg_comments sc 
)
SELECT * FROM comments;

-- How Many Users are added daily:


SELECT 
		du.register_date,
		count(*) as "daily_added_users"
FROM 
		dim_users du 
GROUP BY 1 
ORDER BY 1;


-- What is the average time between registration and first comment?

SELECT 
		AVG(ROUND((JULIANDAY(fc2.publish_date) - JULIANDAY(du.register_date)))) as "avg_between_register_and_first_comment"
FROM 
fct_comments fc2 
LEFT JOIN 
dim_users du
on 
du.id = fc2.owner_id;


-- Which cities have the most activity, in terms of posts per day?

SELECT 
		fp.publish_date,
		dc.city,
		dc2.country, 
		count(*) as "number_of_posts"
FROM 
		fct_posts fp
LEFT JOIN 
		dim_users u 
on u.id = fp.owner_id 
LEFT JOIN 
		dim_cities dc 
on u.city_id = dc.id
LEFT JOIN 
		dim_countries dc2 
on dc2.id = dc.country_id 
GROUP BY 1,2,3
ORDER BY 4 desc 
LIMIT 10


-- Which tags are most frequently encountered, across user posts?

SELECT 
		tag,
		count(*) as "tags_frequency"
FROM
dim_post_tag dpt 
GROUP BY 1
ORDER BY 2 desc 
LIMIT 10














