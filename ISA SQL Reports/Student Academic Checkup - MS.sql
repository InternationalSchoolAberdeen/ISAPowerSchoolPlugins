select
	distinct
	s.student_number as "Student Number",
	s.lastfirst as "Student Name",
	c.course_name as "Course Name",
	pgf.grade as "Final Grade",
	min(sgs.standardgrade) AS "Lowest Standard Grade",
	count(distinct assignmentsec.name) as "Missing Assignments"
from cc
join students s on s.id = cc.studentid
join sections sec on sec.id = cc.sectionid
join courses c on c.course_number = sec.course_number
join standardgradesection sgs on sgs.sectionsdcid = sec.dcid
join assignmentsection assignmentsec on assignmentsec.sectionsdcid = sec.dcid
join assignmentscore ascore on ascore.assignmentsectionid = assignmentsec.assignmentsectionid and ascore.studentsdcid = s.dcid
join pgfinalgrades pgf on pgf.sectionid = cc.sectionid and pgf.studentid = cc.studentid
where s.enroll_status = 0 and sgs.gradelevel = s.grade_level and ascore.ismissing = 1 and ascore.isexempt = 0 and s.grade_level in (%param1%) and (pgf.grade in ('1','2') or sgs.standardgrade in ('1','2'))
group by s.lastfirst, c.course_name, s.student_number, pgf.grade
order by s.lastfirst, c.course_name