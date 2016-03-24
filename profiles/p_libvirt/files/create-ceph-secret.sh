#!/bin/bash
set -ex

SECRET=`mktemp`
cat > $SECRET <<EOF
<secret ephemeral='no' private='no'>
        <usage type='ceph'>
                <name>client.$1 secret</name>
        </usage>
</secret>
EOF

#Secret 73f9b93b-7246-4dc6-b56a-f7e2f18c3fab created
uuid=`virsh secret-define --file $SECRET|sed -e 's/^Secret \([0-9a-f-]*\) created/\1/'`
rm $SECRET

virsh secret-set-value --secret $uuid --base64 $2
