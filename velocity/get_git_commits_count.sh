#!/bin/bash
# REPOS=... - manually specify repos
if [ -z "$PG_PASS" ]
then
  echo "$0: you need to set PG_PASS=..."
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: you need to provide 1st argument proect database name: gha, prometheus, cncf, allprj etc."
  exit 2
fi 
if [ -z "$2" ]
then
  echo "$0: you need to provide 2nd argument date-from in YYYY-MM-DD format"
  exit 3
fi
if [ -z "$3" ]
then 
  echo "$0: you need to provide 3rd date-to in YYYY-MM-DD format"
  exit 4
fi
if [ -z "$REPOS" ]
then
  repos=`db.sh psql "${1}" -tAc "select distinct name from gha_repos"`
else
  repos="${REPOS//[,\']/}"
fi
cwd=`pwd`
log="${cwd}/git.log"
> "${log}"
repos_dir="/devstats_repos"
mkdir "${repos_dir}" 2>/dev/null
function finish {
  rm -rf "${repos_dir}"
}
trap finish EXIT
for orgrepo in $repos
do
  if [[ ! $orgrepo == *"/"* ]]
  then
    echo "malformed repo ${orgrepo}, skipping"
    continue
  fi
  IFS='/'
  arr=($orgrepo)
  unset IFS
  org=${arr[0]}
  repo=${arr[1]}
  cd "${repos_dir}" && mkdir "${org}" 2>/dev/null
  cd "${org}" || echo "cannot cd to ${repos_dir}/${org} directory"
  echo "analysis ${orgrepo}"
  GIT_TERMINAL_PROMPT=0 git clone -n "https://github.com/${orgrepo}.git" 1>/dev/null 2>/dev/null && cd "${repo}" && git log --all --pretty=format:"%aE~~~~%cE~~~~%H" --since="${2}" --until="${3}" >> "${log}" 2>/dev/null
  if [ ! "$?" = "0" ]
  then
    echo "problems getting $orgrepo git log"
  else
    echo "" >> "${log}"
  fi
  cd .. && rm -rf "${repo}"
done
cd "${cwd}"
sed -i '/^$/d' "${log}"
vim --not-a-term -c '%s/"//g' -c '%s/,//g' -c '%s/\~\~\~\~/,/g' -c 'wq!' "${log}"
echo "author_email,committer_email,sha" > out
cat "${log}" | sort | uniq >> out && mv out "${log}"
ls -l "${log}"
cp "${log}" /tmp/
bots=`cat /etc/gha2db/util_sql/only_bots.sql`
commits=`db.sh psql "${1}" -q -c 'create temp table tcom(c text, a text, sha varchar(40))' -c "\copy tcom from '/tmp/git.log' with (format csv)" -c "create temp table bots as select distinct email from gha_actors_emails where actor_id in (select id from gha_actors where lower(login) $bots)" -c "select count(distinct sha) from tcom where a not in (select email from bots) and c not in (select email from bots)" -tAc 'drop table bots' -c 'drop table tcom'`
echo "${1}: ${2} - ${3}: ${commits} commits"
echo "$commits" > commits.txt
