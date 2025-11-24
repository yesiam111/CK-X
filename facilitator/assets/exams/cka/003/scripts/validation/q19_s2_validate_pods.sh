#!/bin/bash
set -e

# Check high priority pod
kubectl get pod high-priority -n scheduling || {
    echo "Pod high-priority not found in namespace scheduling"
    exit 1
}

# Check low priority pod
kubectl get pod low-priority -n scheduling || {
    echo "Pod low-priority not found in namespace scheduling"
    exit 1
}

# Check if pods are running
for POD in high-priority low-priority; do
    STATUS=$(kubectl get pod $POD -n scheduling -o jsonpath='{.status.phase}')
    if [[ "$STATUS" != "Running" ]]; then
        echo "Pod $POD is not running. Current status: $STATUS"
        exit 1
    fi
done

echo "Pods validation successful"
exit 0 