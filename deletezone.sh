#!/bin/bash

# Variables (update these)
HOSTED_ZONE_ID="Z123456ABCDEFG"               # Replace with your hosted zone ID
RECORD_NAME="example.yourdomain.com."         # Must end with a dot
RECORD_TYPE="A"                               # Record type (A, CNAME, etc.)
RECORD_VALUE="192.0.2.1"                      # IP or value of the record
TTL=300

# Create the change batch JSON
cat > /tmp/delete-record.json <<EOF
{
  "Comment": "Delete record set via CLI",
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "$RECORD_TYPE",
        "TTL": $TTL,
        "ResourceRecords": [
          {
            "Value": "$RECORD_VALUE"
          }
        ]
      }
    }
  ]
}
EOF

# Delete the record
aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch file:///tmp/delete-record.json
