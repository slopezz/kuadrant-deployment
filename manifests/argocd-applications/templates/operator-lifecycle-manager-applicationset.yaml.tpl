---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: operator-lifecycle-manager
spec:
  ignoreApplicationDifferences:
    - jsonPointers:
        - /spec/syncPolicy
        - /spec/source/targetRevision
  goTemplate: true
  generators:
    - clusters:
        selector:
          matchExpressions:
            # A cluster secret is not automatically created for the local cluster, so we need to
            # add one (or edit the in-cluster cluste rthrough the argocd UI) for it. Only after
            # evaluating that the secret exists it is safe to evaluate the other installation conditions
            - key: argocd.argoproj.io/secret-type
              operator: Exists
            # Only install argocd through the repo yamls if the cluster secret has been marked with the
            # following label. This allows users to make use of the resources in this repo while managing
            # their own installation of argocd
            - key: vendor
              operator: NotIn
              values:
                - "OpenShift"
  template:
    metadata:
      name: {{` "olm.{{.nameNormalized}}" `}}
    spec:
      destination:
        namespace: olm
        name: {{` "{{.name}}" `}}
      project: default
      source:
        path: manifests/operator-lifecycle-manager
        repoURL: {{ $.Values.repoURL }}
        targetRevision: {{ $.Values.targetRevision }}
      syncPolicy:
        automated:
          selfHeal: true
          prune: true
        syncOptions:
          - ServerSideApply=true
