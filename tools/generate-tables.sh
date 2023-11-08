#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

FILE=${SCRIPT_DIR}/../test_route_tables.go
TABLES=${SCRIPT_DIR}/../route-tables/*.txt

consts=()

cat <<EOF > $FILE
// Code generated by go generate
package gateway

EOF

for rt in $(ls $TABLES)
do
    name=$(echo $rt | awk 'BEGIN { FS = "/"} ; { print $NF }' | cut -d '.' -f 1)
    consts+=("\t${name} = \"${name}\"\n")
done

cat <<EOF >> $FILE
const (
$(echo -e ${consts[@]})
)

var routeTables = map[string][]byte {
EOF

for rt in $(ls $TABLES)
do
    name=$(echo $rt | awk 'BEGIN { FS = "/"} ; { print $NF }' | cut -d '.' -f 1)
    echo -e "\t${name}: []byte(\`" >> $FILE
    cat $rt | sed 's/%/%%/g' >> $FILE
    echo -e "\`),\n" >> $FILE
done
echo "}" >> $FILE

go fmt $FILE