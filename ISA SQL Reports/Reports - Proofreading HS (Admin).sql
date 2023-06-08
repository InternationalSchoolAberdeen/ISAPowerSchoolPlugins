select s.lastfirst as "Student Name", s.grade_level, c.course_name as "Course Name", sec.expression as "Section", u.lastfirst as "Teacher Name", pgf.grade as "Final Grade", pgf.comment_value as "Final Comment", st.name as "Standard Name", sgs.standardgrade as "Standard Grade"
from cc
join students s on s.id = cc.studentid
join sections sec on sec.id = cc.sectionid
join courses c on c.course_number = sec.course_number
join schoolstaff ss on ss.id = cc.teacherid
join users u on u.dcid = ss.users_dcid
join pgfinalgrades pgf on pgf.sectionid=cc.sectionid and pgf.studentid=cc.studentid
join standardgradesection sgs on sgs.sectionsdcid =sec.dcid and sgs.studentsdcid = s.dcid
join standard st on st.standardid = sgs.standardid
where s.grade_level = '%param1%' and sgs.storecode='%param2%' and s.grade_level = sgs.gradelevel and s.enroll_status = 0
order by s.lastfirst, sec.expression, st.standardid;


/* Version 1 -> DOES NOT WORK!*/
WITH ProofreadingData AS (
	SELECT
		s.lastfirst AS "Student Name",
		s.grade_level AS "Grade",
		c.course_name AS "Course Name",
		u.lastfirst AS "Teacher Name",
		pgf.grade AS "Final Grade",
		pgf.comment_value AS "Final Comment",
		st.name AS "Standard Name",
		sgs.standardgrade AS "Standard Grade",
		sgs.whenmodified AS "Last Updated",
		ROW_NUMBER() OVER (PARTITION BY s.dcid, sgs.standardid ORDER BY sgs.whenmodified) AS Rank
	FROM cc
	JOIN students s ON s.id = cc.studentid
	JOIN sections sec ON sec.id = cc.sectionid
	JOIN courses c ON c.course_number = sec.course_number
	JOIN schoolstaff ss ON ss.id = cc.teacherid
	JOIN users u ON u.dcid = ss.users_dcid
	JOIN pgfinalgrades pgf ON pgf.sectionid = cc.sectionid AND pgf.studentid = cc.studentid
	JOIN standardgradesection sgs ON sgs.sectionsdcid = sec.dcid AND sgs.studentsdcid = s.dcid
	JOIN standard st ON st.standardid = sgs.standardid
	WHERE s.grade_level = 9 AND sgs.storecode = 'S1' AND s.grade_level = sgs.gradelevel AND s.enroll_status = 0
)

SELECT
	"Student Name",
	"Grade",
	"Teacher Name",
	MAX(CASE WHEN Rank = 1 THEN
		"Final Grade" || ', ' || ', ' || "Standard Name" || ', ' || "Standard Grade"
	END) AS "Standard One",
	MAX(CASE WHEN Rank = 2 THEN
		"Final Grade" || ', ' || "Standard Name" || ', ' || "Standard Grade"
	END) AS "Standard Two",
	MAX(CASE WHEN Rank = 3 THEN
		"Final Grade" || ', ' || "Standard Name" || ', ' || "Standard Grade"
	END) AS "Standard Three"
FROM ProofreadingData
GROUP BY "Student Name", "Grade", "Teacher Name"
ORDER BY "Grade", "Student Name";



/* Latest Script Version -> 07-06-2023 */
SELECT
  subquery."Student Name",
  subquery.grade_level,
  subquery."Course Name",
  subquery."Teacher Name",
  CASE WHEN "Standard Name" = 'Responsibility' THEN to_char('Standard Grade = ' || subquery."Final Grade" || subquery."Standard Grade" || ', Comment = ' || subquery."Final Comment") END AS "Responsibility",
  CASE WHEN "Standard Name" = 'Collaboration' THEN to_char('Standard Grade = ' || subquery."Final Grade" || subquery."Standard Grade" || ', Comment = ' || subquery."Final Comment") END AS "Collaboration",
  CASE WHEN "Standard Name" = 'Engagement' THEN to_char('Standard Grade = ' || subquery."Final Grade" || subquery."Standard Grade" || ', Comment = ' || subquery."Final Comment") END AS "Engagement",
  subquery."Last Updated"
FROM
  (
    SELECT
      mainquery.*,
      ROW_NUMBER() OVER (
        PARTITION BY mainquery."Student Name", mainquery."Course Name"
        ORDER BY mainquery."Last Updated" DESC
      ) AS rn
    FROM
      (
        SELECT
          s.lastfirst AS "Student Name",
          s.grade_level,
          c.course_name AS "Course Name",
          sec.expression AS "Section",
          u.lastfirst AS "Teacher Name",
          pgf.grade AS "Final Grade",
          pgf.comment_value AS "Final Comment",
          st.name AS "Standard Name",
          sgs.standardgrade AS "Standard Grade",
          pgf.lastgradeupdate AS "Last Updated"
        FROM
          cc
          JOIN students s ON s.id = cc.studentid
          JOIN sections sec ON sec.id = cc.sectionid
          JOIN courses c ON c.course_number = sec.course_number
          JOIN schoolstaff ss ON ss.id = cc.teacherid
          JOIN users u ON u.dcid = ss.users_dcid
          JOIN pgfinalgrades pgf ON pgf.sectionid = cc.sectionid AND pgf.studentid = cc.studentid
          JOIN standardgradesection sgs ON sgs.sectionsdcid = sec.dcid AND sgs.studentsdcid = s.dcid
          JOIN standard st ON st.standardid = sgs.standardid
        WHERE
          s.grade_level = 10
          AND sgs.storecode = 'S2'
          AND s.grade_level = sgs.gradelevel
          AND s.enroll_status = 0
      ) mainquery
  ) subquery
WHERE
  subquery.rn <= 3

ORDER BY
  subquery."Student Name",
  subquery."Section",
  subquery."Standard Name";


/* Final (Almost) Working Version - 08-06-2023*/
SELECT
  "Student Name",
  grade_level,
  "Course Name",
  "Section",
  "Teacher Name",
  "Final Grade",
  "Final Comment",
  MAX(CASE WHEN "Standard Name" = 'Responsibility' THEN "Standard Grade" END) AS "Responsibility Grade",
  MAX(CASE WHEN "Standard Name" = 'Collaboration' THEN "Standard Grade" END) AS "Collaboration Grade",
  MAX(CASE WHEN "Standard Name" = 'Engagement' THEN "Standard Grade" END) AS "Engagement Grade",
  "Last Updated"
FROM
  (
    SELECT
      s.lastfirst AS "Student Name",
      s.grade_level,
      c.course_name AS "Course Name",
      sec.expression AS "Section",
      u.lastfirst AS "Teacher Name",
      pgf.grade AS "Final Grade",
      to_char(pgf.comment_value) AS "Final Comment",
      st.name AS "Standard Name",
      sgs.standardgrade AS "Standard Grade",
      pgf.lastgradeupdate AS "Last Updated",
      ROW_NUMBER() OVER (
        PARTITION BY s.lastfirst, c.course_name
        ORDER BY pgf.lastgradeupdate DESC
      ) AS rn
    FROM
      cc
      JOIN students s ON s.id = cc.studentid
      JOIN sections sec ON sec.id = cc.sectionid
      JOIN courses c ON c.course_number = sec.course_number
      JOIN schoolstaff ss ON ss.id = cc.teacherid
      JOIN users u ON u.dcid = ss.users_dcid
      JOIN pgfinalgrades pgf ON pgf.sectionid = cc.sectionid AND pgf.studentid = cc.studentid
      JOIN standardgradesection sgs ON sgs.sectionsdcid = sec.dcid AND sgs.studentsdcid = s.dcid
      JOIN standard st ON st.standardid = sgs.standardid
    WHERE
      s.grade_level = 10
      AND sgs.storecode = 'S2'
      AND s.grade_level = sgs.gradelevel
      AND s.enroll_status = 0
  ) subquery
WHERE
  rn <= 3
GROUP BY
  "Student Name",
  grade_level,
  "Course Name",
  "Section",
  "Teacher Name",
  "Final Grade",
  "Final Comment",
  "Last Updated"
ORDER BY
  "Student Name",
  "Course Name",
  "Section";