#!/bin/bash
$target=$PROJECT_ROOT/DEBIAN/postinst
cp postinst.template $target
perl -p -i -e "s,<PROJECT_NAME>,$PROJECT_NAME,g" $target
