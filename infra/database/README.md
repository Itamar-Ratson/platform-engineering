remember to restart oidc

Found the issue! There's an OIDC provider mismatch:
The Problem

Current cluster OIDC: 3E0B46096BF1C9B1D868462BDA7519D8
IAM role trust policy: 8F9E1C79DD7EFFEA8993D18965AD5384

The IAM role was created for a different EKS cluster. That's why IRSA can't work - the trust relationship points to the wrong OIDC provider.
Fix: Recreate the IAM Role
1. Delete the Existing Role

