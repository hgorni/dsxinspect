# dsxinspect
A script to search for terms inside a Datastage .dsx export and, optionally, output a .dsx for each job where the searched term is found.

This script will run in any environment containing a perl installation. No extra libs were used besides the ones contained within a default perl installation.

The script can be used, for example, to perform searches within large .dsx files (e.g. full exports of a project). It is able to search for simple terms and also regular expressions. Optionally, the script can also output one .dsx containing a full job definition for each job where the searched term is found.

Usage:

dsxinspect -f *path/to/dsx/file* -q 'term' [-o /out/dir] [-c]
  
*  -f path to the .dsx file containing the job exports (e.g. /backup/datastage_full_project.dsx)
*  -q search term (e.g. CORPDW.SALES_FACTS) or a regular expression (e.g. 'FROM\s+CORPDW\.SALES_[A-Z]+\s+')
*  -o (optional) for every job containing the searched term a .dsx file containing the full job definition is written to this directory
*  -c (optional) makes the search case-sensitive
  
