
echo  "Enter schema name: "
read schema_name
#echo $schema_name
echo "Dump type tables/functions/triggers/views/materializedview: "
read sub_dir
host="<>"
echo $host
user="edsadmin"
db="ohl"
export PGPASSFILE='/Users/.pgpass'
export targetdir='/Users/Desktop/OHL-Postgres'
echo $targetdir
cd $targetdir

if [ -d $schema_name ]; then
echo "$schema_name directory already exists";
else 
`mkdir -p $targetdir/$schema_name`;
echo "$schema_name directory created"
fi
cd $targetdir/$schema_name

if [ -d $sub_dir ]; then
echo "$sub_dir directory already exists";
else 
`mkdir -p $targetdir/$schema_name/$sub_dir`;
echo "$sub_dir directory created"
fi

cd $targetdir/$schema_name/$sub_dir





psql -h $host -U $user -d $db -X -A -t -c  \
"select proname
FROM pg_proc p
INNER JOIN pg_namespace ns ON p.pronamespace = ns.oid
WHERE ns.nspname = '$schema_name';  "  | while read -a Record1 ;  do
#echo $Record1

psql -h $host -U $user -d $db -X -A -t -c  \
"SELECT 
'-- FUNCTION: ' || ns.nspname||'.'||proname||'()
-- DROP FUNCTION' || ns.nspname||'.'||proname||'();   

'
|| pg_get_functiondef(p.oid) || ';


ALTER FUNCTION ' || ns.nspname||'.'||proname||'() 

OWNER TO gp_eds_owner;
'

|| 'GRANT EXECUTE ON FUNCTION '|| ns.nspname||'.'||proname||'() TO PUBLIC;

'


as function

--select pg_get_functiondef(p.oid),ns.nspname||'.'||proname
FROM pg_proc p
INNER JOIN pg_namespace ns ON p.pronamespace = ns.oid
WHERE ns.nspname = '$schema_name' and proname = '$Record1';  "  > "$schema_name.$Record1().sql"  #| while read -r Record ;  do

done

echo 'completed dump'


