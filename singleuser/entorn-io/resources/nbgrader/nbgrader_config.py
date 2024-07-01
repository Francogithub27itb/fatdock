c = get_config()
import os

###############################################################################
# Begin additions by nbgrader quickstart
###############################################################################

# You only need this if you are running nbgrader on a shared
# server set up.
c.CourseDirectory.course_id = os.environ['COURSE_NAME']

# Update this list with other assignments you want
c.CourseDirectory.db_assignments = [dict(name="ps1")]

# Change the students in this list with that actual students in
# your course
#c.CourseDirectory.db_students = [
#    dict(id="bitdiddle", first_name="Ben", last_name="Bitdiddle"),
#    dict(id="hacker", first_name="Alyssa", last_name="Hacker"),
#    dict(id="reasoner", first_name="Louis", last_name="Reasoner")
#]

c.IncludeHeaderFooter.header = "source/header.ipynb"

###############################################################################
# End additions by nbgrader quickstart
###############################################################################

# Configuration file for nbgrader-generate-config.

